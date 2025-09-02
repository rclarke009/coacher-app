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
            StepCard(stepNumber: "①", accentColor: .blue) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Why (2 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    TextEditor(text: $entry.myWhy)
                        .frame(minHeight: 100) // Increased height
                        .foregroundColor(.white)
                        .background(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Step 2 – Identify a Challenge
            StepCard(stepNumber: "②", accentColor: .teal) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Identify a Challenge (3 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.teal)
                    
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
                                .foregroundColor(entry.challenge == .none ? .brightYellow : .white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.brightYellow)
                                .font(.caption)
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    if entry.challenge == .other {
                        TextField("Describe the challenge…", text: $entry.challengeOther)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            
            // Step 3 – Choose My Swap
            StepCard(stepNumber: "③", accentColor: .purple) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose My Swap (3 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    
                    TextField("What healthier choice will I do instead?", text: $entry.chosenSwap)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Step 4 – Commit (Special treatment)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("④")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                CommitCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Commit (2 minutes)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text("Today I will … instead of …")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("I will...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    TextEditor(text: $entry.commitTo)
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding(12)
                                        .frame(minHeight: 60) // Two rows to start
                                        .background(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("instead of...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    TextEditor(text: $entry.commitFrom)
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .padding(12)
                                        .frame(minHeight: 60) // Two rows to start
                                        .background(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Custom Components

struct StepCard<Content: View>: View {
    let stepNumber: String
    let accentColor: Color
    let content: Content
    
    init(stepNumber: String, accentColor: Color, @ViewBuilder content: () -> Content) {
        self.stepNumber = stepNumber
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(stepNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(accentColor)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(stepBackgroundColor)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                )
            
            // Spacer between steps
            Spacer()
                .frame(height: 16)
        }
    }
    
    private var stepBackgroundColor: Color {
        switch accentColor {
        case .blue:
            return Color.blue.opacity(0.08) // Light blue for step 1
        case .teal:
            return Color.teal.opacity(0.08) // Light teal for step 2
        case .purple:
            return Color.purple.opacity(0.08) // Light purple for step 3
        default:
            return Color(.systemGray6)
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
                        .fill(Color.blue.opacity(0.12)) // Brighter blue background for commitment
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.4), lineWidth: 1.5) // Stronger border for commitment
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
