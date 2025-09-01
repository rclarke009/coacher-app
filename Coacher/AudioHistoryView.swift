//
//  AudioHistoryView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 9/1/25.
//

import SwiftUI
import SwiftData

struct AudioHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AudioRecording.date, order: .reverse) private var audioRecordings: [AudioRecording]
    
    var body: some View {
        NavigationView {
            List {
                if audioRecordings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "mic.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
                        Text("No Audio Recordings Yet")
                            .font(.title2)
                            .bold()
                        
                        Text("Your voice recordings and transcriptions will appear here")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(audioRecordings) { recording in
                        AudioRecordingRow(recording: recording)
                    }
                    .onDelete(perform: deleteRecordings)
                }
            }
            .navigationTitle("Audio History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func deleteRecordings(offsets: IndexSet) {
        for index in offsets {
            let recording = audioRecordings[index]
            
            // Delete the audio file
            do {
                try FileManager.default.removeItem(at: recording.audioURL)
                print("🔍 DEBUG: Deleted audio file at \(recording.audioURL)")
            } catch {
                print("🔍 DEBUG: Failed to delete audio file: \(error)")
            }
            
            // Delete the database record
            modelContext.delete(recording)
        }
        
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("🔍 DEBUG: Failed to save after deletion: \(error)")
        }
    }
}

struct AudioRecordingRow: View {
    let recording: AudioRecording
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.date, style: .date)
                        .font(.headline)
                    
                    Text(recording.date, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let type = recording.type {
                    Label(type.displayName, systemImage: type.icon)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(type.color.opacity(0.2))
                        )
                        .foregroundStyle(type.color)
                }
            }
            
            Text(recording.transcription)
                .font(.body)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Label("\(Int(recording.duration))s", systemImage: "waveform")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement audio playback
                    print("🔍 DEBUG: Play audio for \(recording.id)")
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AudioHistoryView()
        .modelContainer(for: [AudioRecording.self], inMemory: true)
}
