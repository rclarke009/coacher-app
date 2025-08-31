//
//  MiniCoachView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import AVFoundation
import Speech

struct MiniCoachView: View {
    let type: CravingType
    let onComplete: (CravingNote) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: MiniCoachStep = .introduction
    @State private var voiceText = ""
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer?
    @State private var transcribedText = ""
    @State private var showingTextEditor = false
    
    enum MiniCoachStep: Int, CaseIterable {
        case introduction = 0, action = 1, capture = 2, save = 3
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress indicator
                ProgressView(value: Double(currentStep.rawValue), total: Double(MiniCoachStep.allCases.count - 1))
                    .padding(.horizontal)
                
                // Content based on current step
                switch currentStep {
                case .introduction:
                    IntroductionStep(type: type) {
                        currentStep = .action
                    }
                case .action:
                    ActionStep(type: type) {
                        currentStep = .capture
                    }
                case .capture:
                    CaptureStep(
                        type: type,
                        voiceText: $voiceText,
                        isRecording: $isRecording,
                        audioRecorder: $audioRecorder,
                        recordingTime: $recordingTime,
                        recordingTimer: $recordingTimer,
                        transcribedText: $transcribedText,
                        showingTextEditor: $showingTextEditor
                    ) {
                        currentStep = .save
                    }
                case .save:
                    SaveStep(
                        type: type,
                        text: transcribedText.isEmpty ? voiceText : transcribedText
                    ) {
                        let note = CravingNote(
                            type: type,
                            text: transcribedText.isEmpty ? voiceText : transcribedText,
                            keptAudio: false
                        )
                        onComplete(note)
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentStep != .introduction {
                        Button("Back") {
                            if let currentIndex = MiniCoachStep.allCases.firstIndex(of: currentStep) {
                                currentStep = MiniCoachStep.allCases[currentIndex - 1]
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            .navigationTitle(type.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTextEditor) {
                TextEditorView(text: $transcribedText, originalText: voiceText)
            }
        }
    }
}

struct IntroductionStep: View {
    let type: CravingType
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: type.icon)
                .font(.system(size: 80))
                .foregroundStyle(Color(type.color))
            
            Text("Let's address this \(type.displayName.lowercased()) craving")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(introductionText)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button("Continue", action: onNext)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
    
    private var introductionText: String {
        switch type {
        case .stress:
            return "Stress and emotional triggers can create powerful cravings. Let's take a moment to understand what's happening and find a healthier way forward."
        case .habit:
            return "Habitual behaviors often happen automatically. Let's identify the triggers and create a plan to break the pattern."
        case .physical:
            return "Your body might be telling you something important. Let's check what you actually need and find healthy ways to meet those needs."
        case .other:
            return "Sometimes cravings are complex and hard to categorize. Let's explore what's happening and find the best path forward."
        }
    }
}

struct ActionStep: View {
    let type: CravingType
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Quick Actions")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(actionItems, id: \.self) { item in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(item)
                            .font(.body)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            
            Text("Now let's capture what's happening so you can track patterns and get better support.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Capture My Experience", action: onNext)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
    
    private var actionItems: [String] {
        switch type {
        case .stress:
            return [
                "Take 3 deep breaths",
                "Drink a glass of water",
                "Set a 5-minute timer before deciding"
            ]
        case .habit:
            return [
                "Identify the trigger (time/place)",
                "Choose a healthier swap (gum, water, walk)",
                "Create a new routine"
            ]
        case .physical:
            return [
                "Drink water first",
                "Check when you last ate",
                "Try a protein-rich snack"
            ]
        case .other:
            return [
                "Pause and assess",
                "Ask yourself what you really need",
                "Choose one small action"
            ]
        }
    }
}

struct CaptureStep: View {
    let type: CravingType
    @Binding var voiceText: String
    @Binding var isRecording: Bool
    @Binding var audioRecorder: AVAudioRecorder?
    @Binding var recordingTime: TimeInterval
    @Binding var recordingTimer: Timer?
    @Binding var transcribedText: String
    @Binding var showingTextEditor: Bool
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Capture Your Experience")
                .font(.title2)
                .bold()
            
            if voiceText.isEmpty && transcribedText.isEmpty {
                // Voice recording interface
                VStack(spacing: 20) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(isRecording ? .red : .blue)
                    
                    if isRecording {
                        Text("Recording... \(Int(recordingTime))s")
                            .font(.title3)
                            .foregroundStyle(.red)
                        
                        Text("Keep it under 20 seconds")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Tap to start recording")
                            .font(.title3)
                            .foregroundStyle(.primary)
                        
                        Text("Describe what's happening")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button(action: toggleRecording) {
                        Text(isRecording ? "Stop Recording" : "Start Recording")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isRecording ? .red : .blue)
                    .padding(.horizontal)
                }
            } else {
                // Show transcribed text
                VStack(spacing: 16) {
                    Text("Your Recording:")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(transcribedText.isEmpty ? voiceText : transcribedText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.secondarySystemBackground))
                        )
                    
                    Button("Edit Text") {
                        showingTextEditor = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Continue", action: onNext)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .onAppear {
            requestMicrophonePermission()
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            // Handle permission result
        }
    }
    
    private func startRecording() {
        // TODO: Implement actual audio recording
        isRecording = true
        recordingTime = 0
        
        // Start timer for 20-second limit
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingTime += 1
            if recordingTime >= 20 {
                stopRecording()
            }
        }
        
        // Simulate recording for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            stopRecording()
        }
    }
    
    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Simulate transcription for now
        if voiceText.isEmpty {
            voiceText = "I was feeling \(type.displayName.lowercased()) and needed support. This is a simulated transcription of what I would have said."
        }
    }
}

struct SaveStep: View {
    let type: CravingType
    let text: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("Experience Captured!")
                .font(.title2)
                .bold()
            
            Text("Your \(type.displayName.lowercased()) craving has been recorded and tagged for future reference.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("What was saved:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(text)
                    .font(.caption)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
            }
            
            Button("Complete", action: onComplete)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
}

struct TextEditorView: View {
    @Binding var text: String
    let originalText: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $text)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        text = originalText
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if text.isEmpty {
                text = originalText
            }
        }
    }
}

#Preview {
    MiniCoachView(type: .stress) { _ in }
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self], inMemory: true)
}
