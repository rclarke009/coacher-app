//
//  EndOfDaySection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct EndOfDaySection: View {
    @Binding var entry: DailyEntry
    @EnvironmentObject private var celebrationManager: CelebrationManager
    @Environment(\.colorScheme) private var colorScheme
    let onCelebrationTrigger: (String, String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("End-of-Day Check-In (Optional)")
                .font(.subheadline)
                .bold()
            
            HStack {
                Image(systemName: (entry.followedSwap ?? false) ? "checkmark.square.fill" : "square")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .onTapGesture {
                        let wasUnchecked = entry.followedSwap != true
                        entry.followedSwap?.toggle()
                        if entry.followedSwap == nil {
                            entry.followedSwap = true
                        }
                        
                        // Trigger celebration if checking the box and celebrations are enabled
                        if wasUnchecked && entry.followedSwap == true && celebrationManager.shouldCelebrate() {
                            // Record activity for streak tracking
                            celebrationManager.recordActivity()
                            
                            // Show regular celebration
                            onCelebrationTrigger(
                                "Swap logged!",
                                celebrationManager.randomEncouragingPhrase()
                            )
                        }
                    }
                Text("I followed my swap")
                    .onTapGesture {
                        let wasUnchecked = entry.followedSwap != true
                        entry.followedSwap?.toggle()
                        if entry.followedSwap == nil {
                            entry.followedSwap = true
                        }
                        
                        // Trigger celebration if checking the box and celebrations are enabled
                        if wasUnchecked && entry.followedSwap == true && celebrationManager.shouldCelebrate() {
                            // Record activity for streak tracking
                            celebrationManager.recordActivity()
                            
                            // Show regular celebration
                            onCelebrationTrigger(
                                "Swap logged!",
                                celebrationManager.randomEncouragingPhrase()
                            )
                        }
                    }
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $entry.feelAboutIt)
                    .frame(minHeight: 60)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
                    .padding(0)
                
                if entry.feelAboutIt.isEmpty {
                    Text("How do you feel about today?")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
            )
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $entry.whatGotInTheWay)
                    .frame(minHeight: 60)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                    .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
                    .padding(0)
                
                if entry.whatGotInTheWay.isEmpty {
                    Text("What got in the way today?")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
            )
        }
        .onChange(of: entry.whatGotInTheWay) { _, _ in
            // This triggers UI updates in other views that depend on whatGotInTheWay
        }
    }
}

#Preview {
    EndOfDaySection(
        entry: .constant(DailyEntry()),
        onCelebrationTrigger: { _, _ in }
    )
}
