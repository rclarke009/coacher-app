//
//  EmotionalTakeoverFlow.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import AVFoundation

struct EmotionalTakeoverFlow: View {
    let onComplete: (EmotionalTakeoverNote) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentStep: EmotionalStep = .nameIt
    @State private var bodySensation = ""
    @State private var partNeed = ""
    @State private var nextTimePlan = ""
    @State private var neutralThings = ["", "", ""]
    @State private var audioPlayer: AVAudioPlayer?
    
    enum EmotionalStep: Int, CaseIterable {
        case nameIt = 0, noticeBody = 1, completeStressCycle = 2, pendulate = 3, soothePart = 4, rehearsePlan = 5
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress indicator
                ProgressView(value: Double(currentStep.rawValue), total: Double(EmotionalStep.allCases.count - 1))
                    .padding(.horizontal)
                
                // Content based on current step
                switch currentStep {
                case .nameIt:
                    NameItStep {
                        currentStep = .noticeBody
                    }
                case .noticeBody:
                    NoticeBodyStep(bodySensation: $bodySensation) {
                        currentStep = .completeStressCycle
                    }
                case .completeStressCycle:
                    CompleteStressCycleStep {
                        currentStep = .pendulate
                    }
                case .pendulate:
                    PendulateStep(neutralThings: $neutralThings) {
                        currentStep = .soothePart
                    }
                case .soothePart:
                    SoothePartStep(partNeed: $partNeed) {
                        currentStep = .rehearsePlan
                    }
                case .rehearsePlan:
                    RehearsePlanStep(nextTimePlan: $nextTimePlan) {
                        completeFlow()
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentStep != .nameIt {
                        Button("Back") {
                            if let currentIndex = EmotionalStep.allCases.firstIndex(of: currentStep) {
                                currentStep = EmotionalStep.allCases[currentIndex - 1]
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
            .navigationTitle("When Emotions Take Over")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func completeFlow() {
        let note = EmotionalTakeoverNote(
            step2_bodySensation: bodySensation,
            step5_partNeed: partNeed.isEmpty ? nil : partNeed,
            step6_nextTimePlan: nextTimePlan,
            completedAllSteps: true
        )
        onComplete(note)
    }
}

// MARK: - Step Views

struct NameItStep: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            Text("Old memory, new trigger")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Something from the past got stirred up. My body is reacting to an old danger, not right now.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
}

struct NoticeBodyStep: View {
    @Binding var bodySensation: String
    let onNext: () -> Void
    
    @State private var selectedPrompt = ""
    @State private var customText = ""
    @State private var showingTextCapture = false
    
    private let bodyPrompts = [
        "stomach tightness",
        "heat in face", 
        "hollow chest",
        "tension in shoulders",
        "racing heart",
        "shallow breathing"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Where do you feel this in your body?")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            // Prompt chips
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(bodyPrompts, id: \.self) { prompt in
                    Button(prompt) {
                        selectedPrompt = prompt
                        bodySensation = prompt
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selectedPrompt == prompt ? Color.blue : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(selectedPrompt == prompt ? .white : .primary)
                    .font(.subheadline)
                }
            }
            .padding(.horizontal)
            
            // Custom input
            VStack(alignment: .leading, spacing: 8) {
                Text("Or describe it in your own words:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Button("Add custom description") {
                    showingTextCapture = true
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            if !bodySensation.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What you're feeling:")
                        .font(.headline)
                    
                    Text(bodySensation)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.secondarySystemBackground))
                        )
                }
                .padding(.horizontal)
            }
            
            Button("Continue", action: onNext)
                .buttonStyle(.borderedProminent)
                .disabled(bodySensation.isEmpty)
                .padding(.top)
        }
        .padding()
        .sheet(isPresented: $showingTextCapture) {
            CustomBodySensationView(bodySensation: $bodySensation)
        }
    }
}

struct CompleteStressCycleStep: View {
    let onNext: () -> Void
    
    @State private var showingAudio = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.walk")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("Let your body complete the stress cycle")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Let your body do what it wants safely—sigh, shake, stretch, cry, or press feet down.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                Button("Play Voo Breath Audio") {
                    playVooBreath()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("Done") {
                    onNext()
                }
                .buttonStyle(.bordered)
            }
            .padding(.top)
        }
        .padding()
        .onAppear {
            setupAudio()
        }
    }
    
    private func setupAudio() {
        // TODO: Add actual audio file when provided
        // For now, just show the button but don't play anything
    }
    
    private func playVooBreath() {
        // TODO: Implement audio playback when file is provided
        // For now, just continue after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onNext()
        }
    }
}

struct PendulateStep: View {
    @Binding var neutralThings: [String]
    let onNext: () -> Void
    
    @State private var timerCompleted = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Pendulate Between Discomfort and Safety")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Feel it for 5-10 seconds, then look around and name 3 neutral things.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            ProgressTimerButton(
                title: "Feel it for 10 seconds",
                duration: 10.0
            ) {
                timerCompleted = true
            }
            .padding(.horizontal)
            
            if timerCompleted {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Now look around and name 3 neutral things you see:")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(0..<3, id: \.self) { index in
                        TextField("Thing \(index + 1)", text: $neutralThings[index])
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal)
                
                Button("Continue", action: onNext)
                    .buttonStyle(.borderedProminent)
                    .disabled(neutralThings.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
                    .padding(.top)
            }
        }
        .padding()
    }
}

struct SoothePartStep: View {
    @Binding var partNeed: String
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.fill")
                .font(.system(size: 80))
                .foregroundStyle(.pink)
            
            Text("Soothe the Part that Reached for Food")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Talk to the part of you that needed something. Thank it for trying to help, then ask what it really needs.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("What did this part need? (optional)")
                    .font(.headline)
                
                Text("Example: 'I needed comfort' or 'I needed to feel safe' or 'I needed to escape this feeling'")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                
                TextField("What did this part need?", text: $partNeed, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
            .padding(.horizontal)
            
            Button("Continue", action: onNext)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding()
    }
}

struct RehearsePlanStep: View {
    @Binding var nextTimePlan: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
            
            Text("Rehearse a Gentle Next-Time Plan")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("If this same conflict came up again, what could my adult self try first?")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Your plan:")
                    .font(.headline)
                
                TextField("What could my adult self try first?", text: $nextTimePlan, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(4...8)
            }
            .padding(.horizontal)
            
            Button("Complete", action: onComplete)
                .buttonStyle(.borderedProminent)
                .disabled(nextTimePlan.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.top)
        }
        .padding()
    }
}

struct CustomBodySensationView: View {
    @Binding var bodySensation: String
    @Environment(\.dismiss) private var dismiss
    @State private var textInput = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Describe what you're feeling in your body")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                TextEditor(text: $textInput)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .frame(minHeight: 120)
                
                Spacer()
                
                Button("Save") {
                    bodySensation = textInput
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationTitle("Custom Description")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    EmotionalTakeoverFlow { note in
        print("Completed: \(note)")
    }
}
