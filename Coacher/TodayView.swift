//
//  TodayView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]
    
    @StateObject private var timeManager = TimeManager()
    @State private var entry: DailyEntry = DailyEntry()
    @State private var tomorrowEntry: DailyEntry = DailyEntry()
    @State private var showingNeedHelp = false
    @State private var hasUnsavedChanges = false
    
    // Section expansion states
    @State private var lastNightPrepExpanded = false
    @State private var morningFocusExpanded = true
    @State private var endOfDayExpanded = false
    @State private var prepTonightExpanded = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    // Last Night's Prep (for Today) - Day Phase only
                    if timeManager.isDayPhase {
                        SectionCard(
                            title: "Last Night's Prep (for Today)",
                            icon: "moon.stars.fill",
                            accent: .purple,
                            collapsed: $lastNightPrepExpanded,
                            dimmed: true
                        ) {
                            LastNightPrepReviewView(entry: getLastNightEntry())
                        }
                    }
                    
                    // Morning Focus (Today) - Primary in Day Phase
                    SectionCard(
                        title: "Morning Focus (Today)",
                        icon: "sun.max.fill",
                        accent: .teal,
                        collapsed: $morningFocusExpanded,
                        dimmed: timeManager.isEveningPhase
                    ) {
                        MorningFocusSection(entry: $entry)
                            .onChange(of: entry.myWhy) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.challenge) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.challengeOther) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.chosenSwap) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.commitFrom) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.commitTo) { _, _ in hasUnsavedChanges = true }
                    }
                    
                    // End-of-Day Check-In - Primary in Evening Phase
                    SectionCard(
                        title: "End-of-Day Check-In",
                        icon: "clock.fill",
                        accent: .teal,
                        collapsed: $endOfDayExpanded,
                        dimmed: timeManager.isDayPhase
                    ) {
                        EndOfDaySection(
                            entry: $entry,
                            onCelebrationTrigger: { _, _ in }
                        )
                            .onChange(of: entry.followedSwap) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.feelAboutIt) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.whatGotInTheWay) { _, _ in hasUnsavedChanges = true }
                    }
                    
                    // Prep Tonight (for Tomorrow) - Evening Phase only
                    if timeManager.isEveningPhase {
                        SectionCard(
                            title: "Prep Tonight (for Tomorrow)",
                            icon: "moon.stars.fill",
                            accent: .teal,
                            collapsed: $prepTonightExpanded,
                            dimmed: false
                        ) {
                            PrepTonightSection(entry: $tomorrowEntry)
                                .onChange(of: tomorrowEntry.stickyNotes) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.preppedProduce) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.waterReady) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.breakfastPrepped) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.nightOther) { _, _ in hasUnsavedChanges = true }
                        }
                    }
                    
                    // I Need Help Button
                    Button(action: { showingNeedHelp = true }) {
                        Label("I Need Help", systemImage: "hand.raised.fill")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("Today")
            .onAppear { 
                loadOrCreateToday()
                loadOrCreateTomorrow()
                setDefaultExpansionStates()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SaveButton(entry: entry, hasUnsavedChanges: hasUnsavedChanges) {
                        saveEntry()
                    }
                }
            }
            .sheet(isPresented: $showingNeedHelp) {
                NeedHelpView()
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func loadOrCreateToday() {
        let startOfDay = timeManager.todayDate
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfDay) }) {
            entry = existing
        } else {
            entry = DailyEntry()
            entry.date = startOfDay
            context.insert(entry)
            try? context.save()
        }
    }
    
    private func loadOrCreateTomorrow() {
        let startOfTomorrow = timeManager.tomorrowDate
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfTomorrow) }) {
            tomorrowEntry = existing
        } else {
            tomorrowEntry = DailyEntry()
            tomorrowEntry.date = startOfTomorrow
            context.insert(tomorrowEntry)
            try? context.save()
        }
    }
    

    
    private func getLastNightEntry() -> DailyEntry? {
        let startOfLastNight = timeManager.lastNightDate
        return entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfLastNight) })
    }
    
    private func setDefaultExpansionStates() {
        if timeManager.isDayPhase {
            morningFocusExpanded = true
            endOfDayExpanded = false
            lastNightPrepExpanded = false
        } else {
            morningFocusExpanded = false
            endOfDayExpanded = true
            prepTonightExpanded = true
        }
    }
    
    private func saveEntry() {
        try? context.save()
        hasUnsavedChanges = false
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        hideKeyboard()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SaveButton: View {
    let entry: DailyEntry
    let hasUnsavedChanges: Bool
    let onSave: () -> Void
    
    var body: some View {
        Button(action: onSave) {
            HStack(spacing: 4) {
                if hasUnsavedChanges {
                    Image(systemName: "circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                Text(hasUnsavedChanges ? "Save" : "Saved")
                    .fontWeight(hasUnsavedChanges ? .semibold : .medium)
            }
        }
        .buttonStyle(.bordered)
        .tint(hasUnsavedChanges ? .orange : .secondary)
        .disabled(!hasUnsavedChanges)
        .animation(.easeInOut(duration: 0.2), value: hasUnsavedChanges)
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self], inMemory: true)
}
