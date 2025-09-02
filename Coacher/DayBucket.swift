//
//  DayBucket.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct DayBucket: View {
    let offset: Int // -1..-7 for past, 0 for today
    let entries: [DailyEntry]
    var entryToday: Binding<DailyEntry>? = nil
    var hasUnsavedChanges: Binding<Bool>? = nil
    
    @StateObject private var timeManager = TimeManager()
    @State private var lastNightPrepCollapsed = true
    @State private var morningFocusCollapsed = false
    
    // Separate state for past days to allow expansion
    @State private var pastLastNightPrepCollapsed = true
    @State private var pastMorningFocusCollapsed = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header label
            if offset == 0 {
                Text("Today")
                    .font(.title3.weight(.semibold))
            } else {
                Text(formattedDate(for: offset))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            
            if offset < 0 {
                // PAST: collapsed + dimmed, but expandable to show journey
                SectionCard(
                    title: "Last Night's Prep",
                    icon: "moon.stars.fill",
                    accent: .dimmedGreen,
                    collapsed: $pastLastNightPrepCollapsed,
                    dimmed: true
                ) {
                    PastNightPrepPreview(offset: offset)
                }
                .onTapGesture {
                    print("🔍 DEBUG: Past Last Night Prep tapped! offset: \(offset)")
                    print("🔍 DEBUG: pastLastNightPrepCollapsed before: \(pastLastNightPrepCollapsed)")
                    withAnimation(.snappy) {
                        pastLastNightPrepCollapsed.toggle()
                    }
                    print("🔍 DEBUG: pastLastNightPrepCollapsed after: \(pastLastNightPrepCollapsed)")
                }
                
                SectionCard(
                    title: "Morning Focus",
                    icon: "sun.max.fill",
                    accent: .goldenYellow,
                    collapsed: $pastMorningFocusCollapsed,
                    dimmed: true
                ) {
                    PastMorningFocusPreview(offset: offset)
                }
                .onTapGesture {
                    print("🔍 DEBUG: Past Morning Focus tapped! offset: \(offset)")
                    print("🔍 DEBUG: pastMorningFocusCollapsed before: \(pastMorningFocusCollapsed)")
                    withAnimation(.snappy) {
                        pastMorningFocusCollapsed.toggle()
                    }
                    print("🔍 DEBUG: pastMorningFocusCollapsed after: \(pastMorningFocusCollapsed)")
                }
            } else {
                // TODAY
                SectionCard(
                    title: "Last Night's Prep (for Today)",
                    icon: "moon.stars.fill",
                    accent: .dimmedGreen,
                    collapsed: $lastNightPrepCollapsed,
                    dimmed: true
                ) {
                    LastNightPrepReviewView(entry: getLastNightEntry())
                }
                .onTapGesture {
                    print("🔍 DEBUG: Today Last Night Prep tapped!")
                    print("🔍 DEBUG: lastNightPrepCollapsed before: \(lastNightPrepCollapsed)")
                    withAnimation(.snappy) {
                        lastNightPrepCollapsed.toggle()
                    }
                    print("🔍 DEBUG: lastNightPrepCollapsed after: \(lastNightPrepCollapsed)")
                }
                
                SectionCard(
                    title: "Morning Focus (Today)",
                    icon: "sun.max.fill",
                    accent: .goldenYellow,
                    collapsed: $morningFocusCollapsed
                ) {
                    if let entryToday = entryToday, let hasUnsavedChanges = hasUnsavedChanges {
                        MorningFocusSection(entry: entryToday)
                            .onChange(of: entryToday.wrappedValue.myWhy) { _, _ in hasUnsavedChanges.wrappedValue = true }
                            .onChange(of: entryToday.wrappedValue.challenge) { _, _ in hasUnsavedChanges.wrappedValue = true }
                            .onChange(of: entryToday.wrappedValue.challengeOther) { _, _ in hasUnsavedChanges.wrappedValue = true }
                            .onChange(of: entryToday.wrappedValue.chosenSwap) { _, _ in hasUnsavedChanges.wrappedValue = true }
                            .onChange(of: entryToday.wrappedValue.commitFrom) { _, _ in hasUnsavedChanges.wrappedValue = true }
                            .onChange(of: entryToday.wrappedValue.commitTo) { _, _ in hasUnsavedChanges.wrappedValue = true }
                    } else {
                        MorningFocusSection(entry: .constant(DailyEntry()))
                    }
                }
                .onTapGesture {
                    print("🔍 DEBUG: Today Morning Focus tapped!")
                    print("🔍 DEBUG: morningFocusCollapsed before: \(morningFocusCollapsed)")
                    withAnimation(.snappy) {
                        morningFocusCollapsed.toggle()
                    }
                    print("🔍 DEBUG: morningFocusCollapsed after: \(morningFocusCollapsed)")
                }
            }
        }
        .onAppear {
            setDefaultCollapsedStates()
        }
    }
    
    private func setDefaultCollapsedStates() {
        print("🔍 DEBUG: setDefaultCollapsedStates called for offset: \(offset)")
        if offset == 0 {
            // Today: Morning Focus expanded by default
            morningFocusCollapsed = false
            lastNightPrepCollapsed = true
            print("🔍 DEBUG: Today - morningFocusCollapsed: \(morningFocusCollapsed), lastNightPrepCollapsed: \(lastNightPrepCollapsed)")
        } else {
            // Past days: both collapsed by default
            pastMorningFocusCollapsed = true
            pastLastNightPrepCollapsed = true
            print("🔍 DEBUG: Past day - pastMorningFocusCollapsed: \(pastMorningFocusCollapsed), pastLastNightPrepCollapsed: \(pastLastNightPrepCollapsed)")
        }
    }
    
    private func formattedDate(for offset: Int) -> String {
        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: offset, to: Date())!
        let f = DateFormatter()
        f.dateFormat = "EEE • MMM d"
        return f.string(from: date)
    }
    
    private func getLastNightEntry() -> DailyEntry? {
        let startOfLastNight = timeManager.lastNightDate
        return entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfLastNight) })
    }
}

#Preview {
    VStack(spacing: 20) {
        // Past day
        DayBucket(offset: -1, entries: [])
        
        // Today
        DayBucket(offset: 0, entries: [], entryToday: .constant(DailyEntry()), hasUnsavedChanges: .constant(false))
    }
    .padding()
}
