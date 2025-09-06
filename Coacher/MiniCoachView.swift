//
//  MiniCoachView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import AVFoundation
import Speech
import SwiftData

struct MiniCoachView: View {
    let type: CravingType
    let onComplete: (CravingNote) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentStep: MiniCoachStep = .introduction
    @State private var voiceText = ""
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer?
    @State private var transcribedText = ""
    @State private var showingTextEditor = false
    @State private var savedAudioURL: URL?
    @State private var showRecordingError = false
    @State private var showingTextCapture = false
    
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
                        showingTextEditor: $showingTextEditor,
                        savedAudioURL: $savedAudioURL,
                        showRecordingError: $showRecordingError
                    ) {
                        currentStep = .save
                    }
                case .save:
                    SaveStep(
                        type: type,
                        text: transcribedText.isEmpty ? voiceText : transcribedText
                    ) {
                        // Save audio recording to database if we have one and meaningful content
                        if let audioURL = savedAudioURL {
                            let transcription = transcribedText.isEmpty ? voiceText : transcribedText
                            
                            // Only save if we have meaningful transcription content
                            if !transcription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                let recording = AudioRecording(
                                    transcription: transcription,
                                    type: type,
                                    duration: recordingTime
                                )
                            
                                print("🔍 DEBUG: Creating AudioRecording with transcription: '\(transcription)'")
                                print("🔍 DEBUG: AudioRecording type: \(type.displayName)")
                                print("🔍 DEBUG: AudioRecording duration: \(recordingTime)")
                                
                                modelContext.insert(recording)
                                
                                do {
                                    try modelContext.save()
                                    print("🔍 DEBUG: Successfully saved audio recording to database")
                                    print("🔍 DEBUG: Recording ID: \(recording.id)")
                                    print("🔍 DEBUG: Recording date: \(recording.date)")
                                    
                                    // Clean up the audio file after successful transcription
                                    try FileManager.default.removeItem(at: audioURL)
                                    print("🔍 DEBUG: Cleaned up audio file: \(audioURL.lastPathComponent)")
                                } catch {
                                    print("🔍 DEBUG: Failed to save audio recording: \(error)")
                                }
                            } else {
                                print("🔍 DEBUG: No meaningful transcription to save, cleaning up audio file")
                                // Clean up the audio file even if we don't save the recording
                                try? FileManager.default.removeItem(at: audioURL)
                            }
                        } else {
                            print("🔍 DEBUG: No savedAudioURL to save")
                        }
                        
                        let note = CravingNote(
                            type: type,
                            text: transcribedText.isEmpty ? voiceText : transcribedText,
                            keptAudio: savedAudioURL != nil
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
                        .foregroundColor(colorScheme == .dark ? .white : .blue)
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
            .alert("Recording Issue", isPresented: $showRecordingError) {
                Button("Try Text Instead") {
                    showingTextCapture = true
                }
                Button("Try Recording Again") {
                    // Reset recording state
                    voiceText = ""
                    transcribedText = ""
                    savedAudioURL = nil
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("We couldn't process your recording. You can try typing instead, or try recording again.")
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
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
                .foregroundStyle(type.color)
            
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
    @Binding var savedAudioURL: URL?
    @Binding var showRecordingError: Bool
    let onNext: () -> Void
    
    @State private var showingTextCapture = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Capture Your Experience")
                .font(.title2)
                .bold()
            
            if voiceText.isEmpty && transcribedText.isEmpty {
                // Capture options
                VStack(spacing: 20) {
                    Text("How would you like to capture this moment?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 16) {
                        // Voice Recording Button
                        Button(action: toggleRecording) {
                            VStack(spacing: 12) {
                                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(isRecording ? .red : .blue)
                                
                                Text(isRecording ? "Stop Recording" : "Voice Note")
                                    .font(.headline)
                                
                                if isRecording {
                                    Text("\(Int(recordingTime))s")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                } else {
                                    Text("Tap to record")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isRecording ? .red : .blue, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Text Input Button
                        Button(action: { showingTextCapture = true }) {
                            VStack(spacing: 12) {
                                Image(systemName: "text.bubble.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.green)
                                
                                Text("Text Note")
                                    .font(.headline)
                                
                                Text("Type it out")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.green, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
            } else {
                // Show captured content
                VStack(spacing: 16) {
                    Text("Your Experience:")
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
        .sheet(isPresented: $showingTextCapture) {
            MiniCoachTextCaptureView(
                type: type,
                onSave: { text in
                    transcribedText = text
                    voiceText = text
                }
            )
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
            DispatchQueue.main.async {
                if granted {
                    print("🔍 DEBUG: Microphone permission granted")
                    // Also request speech recognition permission
                    SFSpeechRecognizer.requestAuthorization { status in
                        DispatchQueue.main.async {
                            switch status {
                            case .authorized:
                                print("🔍 DEBUG: Speech recognition permission granted")
                            case .denied:
                                print("🔍 DEBUG: Speech recognition permission denied")
                            case .restricted:
                                print("🔍 DEBUG: Speech recognition permission restricted")
                            case .notDetermined:
                                print("🔍 DEBUG: Speech recognition permission not determined")
                            @unknown default:
                                print("🔍 DEBUG: Speech recognition permission unknown status")
                            }
                        }
                    }
                } else {
                    print("🔍 DEBUG: Microphone permission denied")
                }
            }
        }
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            
            // Start timer for 20-second limit
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                recordingTime += 1
                if recordingTime >= 20 {
                    stopRecording()
                }
            }
            
            print("🔍 DEBUG: Started recording to \(audioFilename)")
        } catch {
            print("🔍 DEBUG: Failed to start recording: \(error)")
        }
    }
    
    private func stopRecording() {
        if let recorder = audioRecorder {
            savedAudioURL = recorder.url
            recorder.stop()
        }
        
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingTime = 0
        
        // Transcribe the recorded audio
        if let audioURL = savedAudioURL {
            transcribeAudio(from: audioURL)
        }
        
        print("🔍 DEBUG: Stopped recording, saved URL: \(savedAudioURL?.absoluteString ?? "nil")")
    }
    
    private func transcribeAudio(from url: URL) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        guard let recognizer = recognizer, recognizer.isAvailable else {
            print("🔍 DEBUG: Speech recognition not available")
            // Don't fill in confusing default text - let user know recording didn't work
            DispatchQueue.main.async {
                self.showRecordingError = true
            }
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        recognizer.recognitionTask(with: request) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("🔍 DEBUG: Speech recognition error: \(error)")
                    // Don't fill in confusing default text - let user know recording didn't work
                    if self.voiceText.isEmpty {
                        self.showRecordingError = true
                    }
                } else if let result = result, result.isFinal {
                    let transcription = result.bestTranscription.formattedString
                    print("🔍 DEBUG: Transcription completed: \(transcription)")
                    self.voiceText = transcription
                    self.transcribedText = transcription
                }
            }
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
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $text)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
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
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MiniCoachTextCaptureView: View {
    let type: CravingType
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var textInput = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                        .accessibilityLabel("Text input")
                        .accessibilityHidden(false)
                    
                    Text("Describe Your Experience")
                        .font(.title2)
                        .bold()
                    
                    Text("What's happening with this \(type.displayName.lowercased()) craving?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // Text Input
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your thoughts:")
                        .font(.headline)
                    
                    TextEditor(text: $textInput)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.quaternary, lineWidth: 1)
                        )
                        .padding(.horizontal, 4)
                        .accessibilityLabel("Your thoughts")
                        .accessibilityHint("Describe what's happening with your \(type.displayName.lowercased()) craving")
                    
                    Text("\(textInput.count) characters")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        onSave(textInput)
                        dismiss()
                    }) {
                        Text("Save & Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("Cancel", action: { dismiss() })
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Text Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    MiniCoachView(type: .habit) { _ in }
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self], inMemory: true)
}
