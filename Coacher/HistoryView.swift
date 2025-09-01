//
//  HistoryView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]
    
    var body: some View {
        let _ = print("🔍 DEBUG: HistoryView - ModelContext: \(context)")
        let _ = print("🔍 DEBUG: HistoryView - Found \(entries.count) daily entries")
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Streak Heatmap
                    StreakHeatmap(entryDates: Set(entries.map { Calendar.current.startOfDay(for: $0.date) }))
                        .padding(.horizontal)
                    
                    // Weekly Completion Ring
                    WeeklyCompletionRing(entries: entries)
                        .padding(.horizontal)
                    
                    // Audio Recordings Section
                    AudioRecordingsSection()
                        .padding(.horizontal)
                    
                    // Entries List
                    LazyVStack(spacing: 12) {
                        ForEach(entries) { entry in
                            EntryRowView(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("History")
        }
    }
}

struct EntryRowView: View {
    let entry: DailyEntry
    
    var body: some View {
        NavigationLink(destination: EntryDetailView(entry: entry)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.date, style: .date)
                        .font(.headline)
                    
                    Spacer()
                    
                    if entry.hasAnyAction {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                if entry.hasAnyAction {
                    HStack {
                        if entry.hasAnyNightPrep {
                            Label("Night Prep", systemImage: "moon.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        
                        if entry.hasAnyMorningFocus {
                            Label("Morning Focus", systemImage: "sun.max.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        
                        if entry.hasAnyEndOfDay {
                            Label("End of Day", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                } else {
                    Text("No actions logged")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

struct EntryDetailView: View {
    let entry: DailyEntry
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                NightPrepSection(entry: .constant(entry))
                Divider()
                MorningFocusSection(entry: .constant(entry))
                Divider()
                EndOfDaySection(
                    entry: .constant(entry),
                    onCelebrationTrigger: { _, _, _ in }
                )
            }
            .padding()
        }
        .navigationTitle(entry.date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WeeklyCompletionRing: View {
    let entries: [DailyEntry]
    
    private var weeklyProgress: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        let daysThisWeek = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
        }
        
        let completedDays = daysThisWeek.filter { date in
            entries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: date) && entry.hasAnyAction
            }
        }.count
        
        return Double(completedDays) / 7.0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: weeklyProgress)
                    .stroke(Color.teal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: weeklyProgress)
                
                VStack {
                    Text("\(Int(weeklyProgress * 100))%")
                        .font(.title2)
                        .bold()
                    Text("\(Int(weeklyProgress * 7))/7 days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct AudioRecordingsSection: View {
    @Environment(\.modelContext) private var modelContext
    @State private var audioRecordings: [AudioRecording] = []
    
    var body: some View {
        let _ = print("🔍 DEBUG: AudioRecordingsSection - Found \(audioRecordings.count) recordings")
        let _ = print("🔍 DEBUG: AudioRecordingsSection - ModelContext: \(modelContext)")
        let _ = audioRecordings.forEach { recording in
            print("🔍 DEBUG: AudioRecordingsSection - Recording: \(recording.transcription) at \(recording.date)")
        }
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "mic.fill")
                    .foregroundStyle(.blue)
                Text("Voice Recordings")
                    .font(.headline)
                Spacer()
                Text("\(audioRecordings.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                    )
            }
            
            if audioRecordings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "mic.slash")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No voice recordings yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.tertiarySystemBackground))
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(audioRecordings.prefix(5)) { recording in
                        AudioRecordingRow(recording: recording)
                    }
                    
                    if audioRecordings.count > 5 {
                        Button("View All \(audioRecordings.count) Recordings") {
                            // TODO: Navigate to full audio recordings list
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .padding(.top, 8)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .onAppear {
            fetchAudioRecordings()
        }
    }
    
    private func fetchAudioRecordings() {
        do {
            let descriptor = FetchDescriptor<AudioRecording>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            let recordings = try modelContext.fetch(descriptor)
            print("🔍 DEBUG: fetchAudioRecordings - Found \(recordings.count) recordings")
            recordings.forEach { recording in
                print("🔍 DEBUG: fetchAudioRecordings - Recording: \(recording.transcription) at \(recording.date)")
            }
            audioRecordings = recordings
        } catch {
            print("🔍 DEBUG: fetchAudioRecordings - Error: \(error)")
        }
    }
}



#Preview {
    HistoryView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, AudioRecording.self], inMemory: true)
}
