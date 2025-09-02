//
//  MorningFocusSection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct MorningFocusSection: View {
    @Binding var entry: DailyEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Step 1 – My Why
            StepCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step 1 – My Why (2 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $entry.myWhy)
                        .frame(minHeight: 80)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
                }
            }
            
            // Step 2 – Identify a Challenge
            StepCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step 2 – Identify a Challenge (3 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Menu {
                        Button("Skipping meals") { entry.challenge = .skippingMeals }
                        Button("Late-night snacking") { entry.challenge = .lateNightSnacking }
                        Button("Sugary drinks") { entry.challenge = .sugaryDrinks }
                        Button("Eating on the go / fast food") { entry.challenge = .onTheGo }
                        Button("Emotional eating") { entry.challenge = .emotionalEating }
                        Button("Other") { entry.challenge = .other }
                    } label: {
                        HStack {
                            Text(entry.challenge == .none ? "Select…" : entry.challenge.displayName)
                                .foregroundColor(entry.challenge == .none ? .brightYellow : .dynamicText)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.brightYellow)
                                .font(.caption)
                        }
                    }
                    
                    if entry.challenge == .other {
                        TextField("Describe the challenge…", text: $entry.challengeOther)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            
            // Step 3 – Choose My Swap
            StepCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step 3 – Choose My Swap (3 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    TextField("What healthier choice will I do instead?", text: $entry.chosenSwap)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            // Step 4 – Commit (Special treatment)
            CommitCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Step 4 – Commit (2 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Today I will … instead of …")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        TextField("do this…", text: $entry.commitTo)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("instead of")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("not this…", text: $entry.commitFrom)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
        }
    }
}

// MARK: - Custom Components

struct StepCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
                )
            
            // Spacer between steps
            Spacer()
                .frame(height: 16)
        }
    }
}

struct CommitCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
                .padding(20) // Extra padding for final step
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.08)) // Light blue background
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

#Preview {
    ScrollView {
        MorningFocusSection(entry: .constant(DailyEntry()))
            .padding()
    }
    .background(Color(.systemGroupedBackground))
}
