//
//  MorningFocusSection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct MorningFocusSection: View {
    @Binding var entry: DailyEntry
    @State private var isMorningFocusCompleted = false
    private let reminderManager = ReminderManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Step 1 – My Why
            StepCard(stepIcon: AnyView(TripleQuestionMarkIcon(color: .blue)), accentColor: .blue) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Why (2 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    TextEditor(text: $entry.myWhy)
                        .frame(minHeight: 100) // Increased height
                        .foregroundColor(.primary)
                        .background(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Step 2 – Identify a Challenge
            StepCard(stepIcon: AnyView(MountainIcon(color: .teal)), accentColor: .teal) {
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
                                .foregroundColor(entry.challenge == .none ? .brightYellow : Color(.label))
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
                        TextEditor(text: $entry.challengeOther)
                            .foregroundColor(.primary)
                            .font(.subheadline)
                            .padding(12)
                            .frame(minHeight: 60) // Two rows to start, expandable
                            .background(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.6)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            
            // Step 3 – Choose My Swap
            StepCard(stepIcon: AnyView(RecycleArrowsIcon(color: .purple)), accentColor: .purple) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose My Swap (3 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    
                    TextEditor(text: $entry.chosenSwap)
                        .foregroundColor(Color(.label))
                        .font(.subheadline)
                        .padding(12)
                        .frame(minHeight: 60) // Two rows to start, expandable
                        .background(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 0.6)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Step 4 – Commit (Special treatment)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    LargeCheckboxIcon(color: .blue, isChecked: $isMorningFocusCompleted)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                CommitCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Commit (2 minutes)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Today I will...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    TextEditor(text: $entry.commitTo)
                                        .foregroundColor(Color(.label))
                                        .font(.subheadline)
                                        .padding(12)
                                        .frame(minHeight: 60) // Two rows to start
                                        .background(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.4), lineWidth: 0.6)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("instead of...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    TextEditor(text: $entry.commitFrom)
                                        .foregroundColor(Color(.label))
                                        .font(.subheadline)
                                        .padding(12)
                                        .frame(minHeight: 60) // Two rows to start
                                        .background(Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.4), lineWidth: 0.6)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: isMorningFocusCompleted) { _, newValue in
            if newValue {
                // Reset the morning reminder for today since they completed their morning focus
                reminderManager.cancelMorningReminder()
            }
        }
    }
}

// MARK: - Custom Icons

struct TripleQuestionMarkIcon: View {
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text("?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .scaleEffect(1.0)
            Text("?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .scaleEffect(1.2)
            Text("?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .scaleEffect(1.0)
        }
    }
}

struct MountainIcon: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // Mountain peaks
            Path { path in
                path.move(to: CGPoint(x: 8, y: 16))
                path.addLine(to: CGPoint(x: 4, y: 8))
                path.addLine(to: CGPoint(x: 6, y: 6))
                path.addLine(to: CGPoint(x: 10, y: 4))
                path.addLine(to: CGPoint(x: 14, y: 6))
                path.addLine(to: CGPoint(x: 16, y: 8))
                path.addLine(to: CGPoint(x: 12, y: 16))
                path.closeSubpath()
            }
            .fill(color)
            .frame(width: 20, height: 20)
        }
    }
}

struct RecycleArrowsIcon: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // Curved arrows in a circle
            ForEach(0..<3) { index in
                Path { path in
                    let angle = Double(index) * 120 * .pi / 180
                    let centerX: Double = 10
                    let centerY: Double = 10
                    let radius: Double = 6
                    
                    let startX = centerX + radius * cos(angle)
                    let startY = centerY + radius * sin(angle)
                    let endX = centerX + radius * cos(angle + 60 * .pi / 180)
                    let endY = centerY + radius * sin(angle + 60 * .pi / 180)
                    
                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addQuadCurve(
                        to: CGPoint(x: endX, y: endY),
                        control: CGPoint(x: centerX, y: centerY)
                    )
                }
                .stroke(color, lineWidth: 2)
                .frame(width: 20, height: 20)
            }
        }
    }
}

struct LargeCheckboxIcon: View {
    let color: Color
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isChecked ? color : Color.clear)
                    )
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Components

struct StepCard<Content: View>: View {
    let stepIcon: AnyView
    let accentColor: Color
    let content: Content
    
    init(stepIcon: AnyView, accentColor: Color, @ViewBuilder content: () -> Content) {
        self.stepIcon = stepIcon
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                stepIcon
                
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
        return Color.blue.opacity(0.15) // Light blue background for all steps
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
                        .fill(Color.blue.opacity(0.15)) // Light blue background for commitment
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.4), lineWidth: 0.8) // Thinner border for commitment
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
