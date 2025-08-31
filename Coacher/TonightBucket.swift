//
//  TonightBucket.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct TonightBucket: View {
    let entries: [DailyEntry]
    @Binding var entryToday: DailyEntry
    @Binding var hasUnsavedChanges: Bool
    
    @StateObject private var timeManager = TimeManager()
    @State private var tomorrowEntry: DailyEntry = DailyEntry()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tonight")
                .font(.title3.weight(.semibold))
            
            SectionCard(
                title: "End-of-Day Check-In",
                icon: "checkmark.seal.fill",
                accent: .teal,
                collapsed: .constant(false)
            ) {
                EndOfDaySection(entry: $entryToday)
                    .onChange(of: entryToday.followedSwap) { _, _ in hasUnsavedChanges = true }
                    .onChange(of: entryToday.feelAboutIt) { _, _ in hasUnsavedChanges = true }
                    .onChange(of: entryToday.whatGotInTheWay) { _, _ in hasUnsavedChanges = true }
            }
            
            SectionCard(
                title: "Prep Tonight (for Tomorrow)",
                icon: "calendar.badge.clock",
                accent: .purple,
                collapsed: .constant(false)
            ) {
                PrepTonightSection(entry: $tomorrowEntry)
                    .onChange(of: tomorrowEntry.stickyNotes) { _, _ in hasUnsavedChanges = true }
                    .onChange(of: tomorrowEntry.preppedProduce) { _, _ in hasUnsavedChanges = true }
                    .onChange(of: tomorrowEntry.waterReady) { _, _ in hasUnsavedChanges = true }
                    .onChange(of: tomorrowEntry.breakfastPrepped) { _, _ in hasUnsavedChanges = true }
                    .onChange(of: tomorrowEntry.nightOther) { _, _ in hasUnsavedChanges = true }
            }
        }
        .padding(.bottom, 24)
        .onAppear {
            loadOrCreateTomorrow()
        }
    }
    
    private func loadOrCreateTomorrow() {
        let startOfTomorrow = timeManager.tomorrowDate
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfTomorrow) }) {
            tomorrowEntry = existing
        } else {
            tomorrowEntry = DailyEntry()
            tomorrowEntry.date = startOfTomorrow
        }
    }
}

#Preview {
    TonightBucket(
        entries: [],
        entryToday: .constant(DailyEntry()),
        hasUnsavedChanges: .constant(false)
    )
    .padding()
}
