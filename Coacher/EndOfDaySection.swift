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
    @State private var showingCelebration = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("End-of-Day Check-In (Optional)")
                .font(.subheadline)
                .bold()
            
            HStack {
                Image(systemName: (entry.followedSwap ?? false) ? "checkmark.square.fill" : "square")
                    .foregroundColor(.leafGreen)
                    .onTapGesture {
                        let wasUnchecked = entry.followedSwap != true
                        entry.followedSwap?.toggle()
                        if entry.followedSwap == nil {
                            entry.followedSwap = true
                        }
                        
                        // Trigger celebration if checking the box and celebrations are enabled
                        if wasUnchecked && entry.followedSwap == true && celebrationManager.shouldCelebrate() {
                            showingCelebration = true
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
                            showingCelebration = true
                        }
                    }
            }
            
            TextField("If yes, how do I feel about it?", text: $entry.feelAboutIt)
                .textFieldStyle(.roundedBorder)
            
            TextField("If no, what got in the way?", text: $entry.whatGotInTheWay)
                .textFieldStyle(.roundedBorder)
        }
        .overlay(
            // Celebration overlay
            Group {
                if celebrationManager.currentStyle != .off {
                    CelebrationOverlay(
                        isPresented: $showingCelebration,
                        style: celebrationManager.currentStyle,
                        title: "Swap logged!",
                        subtitle: celebrationManager.randomEncouragingPhrase()
                    )
                }
            }
        )
    }
}

#Preview {
    EndOfDaySection(entry: .constant(DailyEntry()))
}
