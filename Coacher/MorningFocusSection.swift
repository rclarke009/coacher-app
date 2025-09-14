//
//  EndOfDaySection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct MorningFocusSection: View {
    @Binding var entry: DailyEntry
    @EnvironmentObject private var celebrationManager: CelebrationManager
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var reminderManager = ReminderManager.shared
    let onCelebrationTrigger: (String, String) -> Void = { _, _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Step 1 – My Why
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.helpButtonBlue)
                            .frame(width: 24, height: 24)
                        Text("1")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Text("My Why (2 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                TextEditor(text: $entry.myWhy)
                    .frame(minHeight: 60)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .background(colorScheme == .dark ? Color.blue : Color.clear)
                    .padding(0)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
                    )
                    .accessibilityLabel("My Why")
                    .accessibilityHint("Enter your personal motivation for making healthy choices today")
            }
            
            Spacer()
                .frame(height: 16)
            
            // Step 2 – Identify a Challenge
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.helpButtonBlue)
                            .frame(width: 24, height: 24)
                        Text("2")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Text("Focus on a Challenge (3 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Menu {
                    Button("Skipping meals") { 
                        entry.challenge = .skippingMeals
                        UserDefaults.standard.set("skippingMeals", forKey: "lastSelectedChallenge")
                    }
                    Button("Late-night snacking") { 
                        entry.challenge = .lateNightSnacking
                        UserDefaults.standard.set("lateNightSnacking", forKey: "lastSelectedChallenge")
                    }
                    Button("Sugary drinks") { 
                        entry.challenge = .sugaryDrinks
                        UserDefaults.standard.set("sugaryDrinks", forKey: "lastSelectedChallenge")
                    }
                    Button("Eating on the go / fast food") { 
                        entry.challenge = .onTheGo
                        UserDefaults.standard.set("onTheGo", forKey: "lastSelectedChallenge")
                    }
                    Button("Emotional eating") { 
                        entry.challenge = .emotionalEating
                        UserDefaults.standard.set("emotionalEating", forKey: "lastSelectedChallenge")
                    }
                    Button("Other") { 
                        entry.challenge = .other
                        UserDefaults.standard.set("other", forKey: "lastSelectedChallenge")
                    }
                } label: {
                    HStack {
                        Text(entry.challenge == .none ? "Select…" : entry.challenge.displayName)
                            .foregroundColor(entry.challenge == .none ? .teal : Color(.label))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.teal)
                            .font(.caption)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
                    )
                }
                
                if entry.challenge == .other {
                    TextEditor(text: $entry.challengeOther)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .font(.subheadline)
                        .background(colorScheme == .dark ? Color.blue : Color.clear)
                        .padding(0)
                        .frame(minHeight: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
                        )
                        .accessibilityLabel("Other challenge")
                        .accessibilityHint("Describe the specific challenge you're facing")
                }
            }
            
            Spacer()
                .frame(height: 16)
            
            // Step 3 – My Better Choice (Swap)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.helpButtonBlue)
                            .frame(width: 24, height: 24)
                        Text("3")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Text("My Better Choice (3 minutes)")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                if entry.challenge != .none {
                    Text("In step 2, you mentioned \(entry.challenge.displayName.lowercased()), let's choose a healthy swap.")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                }
                
HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today I will...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextEditor(text: $entry.commitTo)
                            .foregroundColor(colorScheme == .dark ? .white : Color(.label))
                            .font(.subheadline)
                            .background(colorScheme == .dark ? Color.blue : Color.clear)
                                
                                //.background(Color.clear)   // clears system bg

                            .padding(0)
                            .frame(minHeight: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
                            )
                            .accessibilityLabel("Today I will")
                            .accessibilityHint("Enter what you commit to doing today")
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("instead of...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextEditor(text: $entry.commitFrom)
                            .foregroundColor(colorScheme == .dark ? .white : Color(.label))
                            .font(.subheadline)
                            .background(colorScheme == .dark ? Color.blue : Color.clear)
                            .padding(0)
                            .frame(minHeight: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
                            )
                            .accessibilityLabel("Instead of")
                            .accessibilityHint("Enter what you're avoiding or replacing")
                    }
                }
            }
            
            
        }
        .onAppear {
            // Only load if the current entry doesn't have a challenge selected
            guard entry.challenge == .none else { return }
            
            let savedChallengeRaw = UserDefaults.standard.string(forKey: "lastSelectedChallenge")
            guard let savedChallengeRaw = savedChallengeRaw,
                  let savedChallenge = Challenge(rawValue: savedChallengeRaw) else { return }
            
            entry.challenge = savedChallenge
        }
        .onChange(of: entry.commitTo) { _, newValue in
            // Check if morning focus is completed (both commit fields filled)
            if !newValue.isEmpty && !entry.commitFrom.isEmpty {
                reminderManager.cancelMorningReminder()
            }
        }
        .onChange(of: entry.commitFrom) { _, newValue in
            // Check if morning focus is completed (both commit fields filled)
            if !newValue.isEmpty && !entry.commitTo.isEmpty {
                reminderManager.cancelMorningReminder()
            }
        }
    }










            
    }

#Preview {
    MorningFocusSection(entry: .constant(DailyEntry()))
}



// //
// //  MorningFocusSection.swift
// //  Coacher
// //
// //  Created by Rebecca Clarke on 8/30/25.
// //

// import SwiftUI
// import SwiftData

// struct MorningFocusSection: View {
//     @Binding var entry: DailyEntry
//     @StateObject private var reminderManager = ReminderManager.shared
//     @Environment(\.colorScheme) private var colorScheme
    
//     var body: some View {
//         VStack(alignment: .leading, spacing: 0) {
//             // Step 1 – My Why
//             HStack {
//                 Text("①")
//                     .font(.title2)
//                     .fontWeight(.bold)
//                     .foregroundColor(.blue)
//                 Text("My Why (2 minutes)")
//                     .font(.headline)
//                     .fontWeight(.semibold)
//                     .foregroundColor(.blue)
//                 Spacer()
//             }
//             .padding(.bottom, 8)
            
//             // TextEditor(text: $entry.myWhy)
//             //     .frame(minHeight: 60) // Two lines, expandable
//             //     .foregroundColor(colorScheme == .dark ? .white : .primary)
//             //     .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
//             //     .padding(2)
//             //     .overlay(
//             //         RoundedRectangle(cornerRadius: 8)
//             //             .stroke(Color(.systemGray2), lineWidth: 0.25)
//             //     )
//            TextEditor(text: $entry.myWhy)
//                 .frame(minHeight: 60)
//                 .foregroundColor(colorScheme == .dark ? .white : .primary)
//                 .background(colorScheme == .dark ? Color.blue : Color.clear)
//                 .padding(2)
//                 .overlay(
//                     RoundedRectangle(cornerRadius: 8)
//                         .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
//                 )

//                 .accessibilityLabel("My Why")
//                 .accessibilityHint("Enter your personal motivation for making healthy choices today")
                
//             // StepCard(stepNumber: "①", accentColor: .blue) {
//                 //VStack(alignment: .leading, spacing: 8) {
//                     // Text("My Why (2 minutes)")
//                         // .font(.headline)
//                         // .fontWeight(.semibold)
//                         // .foregroundColor(.blue)
                    
//                     // TextEditor(text: $entry.myWhy)
//                     //     .frame(minHeight: 60) // Two lines, expandable
//                     //     .foregroundColor(.primary)
//                 //}
//             //             }
            
//             // Add more space before step 2
//             Spacer()
//                 .frame(height: 24)
            
//             // Step 2 – Identify a Challenge
//             HStack {
//                 Text("②")
//                     .font(.title2)
//                     .fontWeight(.bold)
//                     .foregroundColor(.teal)
//                 Text("Identify a Challenge (3 minutes)")
//                     .font(.headline)
//                     .fontWeight(.semibold)
//                     .foregroundColor(.teal)
//                 Spacer()
//             }
//             .padding(.bottom, 4)
            
//             Menu {
//                 Button("Skipping meals") { entry.challenge = .skippingMeals }
//                 Button("Late-night snacking") { entry.challenge = .lateNightSnacking }
//                 Button("Sugary drinks") { entry.challenge = .sugaryDrinks }
//                 Button("Eating on the go / fast food") { entry.challenge = .onTheGo }
//                 Button("Emotional eating") { entry.challenge = .emotionalEating }
//                 Button("Other") { entry.challenge = .other }
//             } label: {
//                 HStack {
//                     Text(entry.challenge == .none ? "Select…" : entry.challenge.displayName)
//                         .foregroundColor(entry.challenge == .none ? .teal : Color(.label))
//                     Spacer()
//                     Image(systemName: "chevron.down")
//                         .foregroundColor(.teal)
//                         .font(.caption)
//                 }
//                 .padding(12)
//             }
            
//             if entry.challenge == .other {
//                 TextEditor(text: $entry.challengeOther)
//                     .foregroundColor(colorScheme == .dark ? .white : .primary)
//                     .font(.subheadline)
//                     .background(colorScheme == .dark ? Color.blue : Color.clear)
//                     .padding(2)
//                     .frame(minHeight: 60) // Two rows to start, expandable
//                     .overlay(
//                         RoundedRectangle(cornerRadius: 8)
//                             .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
//                     )
//                     .accessibilityLabel("Other challenge")
//                     .accessibilityHint("Describe the specific challenge you're facing")
//             }
            
//             // Add space before step 3
//             Spacer()
//                 .frame(height: 24)
            
//             // Step 3 – Choose My Swap
//             HStack {
//                 Text("③")
//                     .font(.title2)
//                     .fontWeight(.bold)
//                     .foregroundColor(.purple)
//                 Text("Choose My Swap (3 minutes)")
//                     .font(.headline)
//                     .fontWeight(.semibold)
//                     .foregroundColor(.purple)
//                 Spacer()
//             }
//             .padding(.bottom, 8)
            
//             TextEditor(text: $entry.chosenSwap)
//                 .foregroundColor(colorScheme == .dark ? .white : Color(.label))
//                 .font(.subheadline)
//                 .background(colorScheme == .dark ? Color.blue : Color.clear)
//                 .padding(2)
//                 .frame(minHeight: 60) // Two rows to start, expandable
//                 .overlay(
//                     RoundedRectangle(cornerRadius: 8)
//                         .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
//                 )
//                 .accessibilityLabel("My Swap")
//                 .accessibilityHint("Enter the healthy alternative you'll choose instead")
            
//             // Add space before step 4
//             Spacer()
//                 .frame(height: 24)
            
//             // Step 4 – Commit (Special treatment)
//             HStack {
//                 Text("④")
//                     .font(.title2)
//                     .fontWeight(.bold)
//                     .foregroundColor(.blue)
//                 Text("Commit (2 minutes)")
//                     .font(.headline)
//                     .fontWeight(.semibold)
//                     .foregroundColor(.blue)
//                 Spacer()
//             }
//             .padding(.bottom, 8)
                
//                 VStack(spacing: 12) {
//                             HStack(spacing: 16) {
//                                 VStack(alignment: .leading, spacing: 4) {
//                                     Text("Today I will...")
//                                         .padding(.leading, 16)
                                    
//                                     TextEditor(text: $entry.commitTo)
//                                         .foregroundColor(colorScheme == .dark ? .white : Color(.label))
//                                         .font(.subheadline)
//                                         .background(colorScheme == .dark ? Color.blue : Color.clear)
//                                         .padding(2)
//                                         .frame(minHeight: 60) // Two rows to start
//                                         .overlay(
//                                             RoundedRectangle(cornerRadius: 8)
//                                                 .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
//                                         )
//                                         .accessibilityLabel("Today I will")
//                                         .accessibilityHint("Enter what you commit to doing today")
//                                 }
                                
//                                 VStack(alignment: .leading, spacing: 4) {
//                                     Text("instead of...")
//                                         .padding(.leading, 16)
                                    
//                                     TextEditor(text: $entry.commitFrom)
//                                         .foregroundColor(colorScheme == .dark ? .white : Color(.label))
//                                         .font(.subheadline)
//                                         .background(colorScheme == .dark ? Color.blue : Color.clear)
//                                         .padding(2)
//                                         .frame(minHeight: 60) // Two rows to start
//                                         .overlay(
//                                             RoundedRectangle(cornerRadius: 8)
//                                                 .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
//                                         )
//                                         .accessibilityLabel("Instead of")
//                                         .accessibilityHint("Enter what you're avoiding or replacing")
//                                 }
//                             }
//                         }
//         }
//         .onChange(of: entry.commitTo) { _, newValue in
//             // Check if morning focus is completed (both commit fields filled)
//             if !newValue.isEmpty && !entry.commitFrom.isEmpty {
//                 reminderManager.cancelMorningReminder()
//             }
//         }
//         .onChange(of: entry.commitFrom) { _, newValue in
//             // Check if morning focus is completed (both commit fields filled)
//             if !newValue.isEmpty && !entry.commitTo.isEmpty {
//                 reminderManager.cancelMorningReminder()
//             }
//         }
//     }
// }


// // MARK: - Custom Components

// struct StepCard<Content: View>: View {
//     let stepNumber: String
//     let accentColor: Color
//     let content: Content
//     @Environment(\.colorScheme) private var colorScheme
    
//     init(stepNumber: String, accentColor: Color, @ViewBuilder content: () -> Content) {
//         self.stepNumber = stepNumber
//         self.accentColor = accentColor
//         self.content = content()
//     }
    
//     var body: some View {
//         VStack(alignment: .leading, spacing: 0) {
//             HStack {
//                 Text(stepNumber)
//                     .font(.title2)
//                     .fontWeight(.bold)
//                     .foregroundColor(colorScheme == .dark ? .black : accentColor)
                
//                 Spacer()
//             }
//             .padding(.bottom, 8)
            
//             content
//                 .padding(16)
//                 .background(
//                     RoundedRectangle(cornerRadius: 12)
//                         .fill(stepBackgroundColor)
//                         .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
//                 )
            
//             // Spacer between steps
//             Spacer()
//                 .frame(height: 16)
//         }
//     }
    
//     private var stepBackgroundColor: Color {
//         @Environment(\.colorScheme) var colorScheme
//         return colorScheme == .dark ? Color.leafGreen : Color.leafGreen.opacity(0.15)
//     }
// }

// struct CommitCard<Content: View>: View {
//     let content: Content
//     @Environment(\.colorScheme) private var colorScheme
    
//     init(@ViewBuilder content: () -> Content) {
//         self.content = content()
//     }
    
//     var body: some View {
//         VStack(alignment: .leading, spacing: 0) {
//             content
//                 .padding(20) // Extra padding for final step
//                 .background(
//                     RoundedRectangle(cornerRadius: 12)
//                         .fill(colorScheme == .dark ? Color.white : Color.blue.opacity(0.15)) // White in dark mode
//                         .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
//                 )
//         }
//     }
// }

// #Preview {
//     ScrollView {
//         MorningFocusSection(entry: .constant(DailyEntry()))
//             .padding()
//     }
//     .background(Color(.systemGroupedBackground))
// }
