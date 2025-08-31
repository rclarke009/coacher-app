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
                VStack(spacing: 20) {
                    // Last Night's Prep (for Today) - Day Phase only
                    if timeManager.isDayPhase {
                        CollapsibleSection(
                            title: "Last Night's Prep",
                            isExpanded: lastNightPrepExpanded,
                            isDimmed: true
                        ) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundStyle(.purple)
                                Text("Last Night's Prep (for Today)")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                        } content: {
                            LastNightPrepReviewView(entry: getLastNightEntry())
                        } onToggle: {
                            lastNightPrepExpanded.toggle()
                        }
                    }
                    
                    // Morning Focus (Today) - Primary in Day Phase
                    CollapsibleSection(
                        title: "Morning Focus",
                        isExpanded: morningFocusExpanded,
                        isDimmed: timeManager.isEveningPhase
                    ) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(timeManager.isDayPhase ? .blue : .secondary)
                            Text("Morning Focus (Today)")
                                .font(.headline)
                                .foregroundStyle(timeManager.isDayPhase ? .primary : .secondary)
                        }
                    } content: {
                        MorningFocusSection(entry: $entry)
                            .onChange(of: entry.myWhy) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.challenge) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.challengeOther) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.chosenSwap) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.commitFrom) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.commitTo) { _, _ in hasUnsavedChanges = true }
                    } onToggle: {
                        morningFocusExpanded.toggle()
                    }
                    
                    // End-of-Day Check-In - Primary in Evening Phase
                    CollapsibleSection(
                        title: "End-of-Day Check-In",
                        isExpanded: endOfDayExpanded,
                        isDimmed: timeManager.isDayPhase
                    ) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(timeManager.isEveningPhase ? .blue : .secondary)
                            Text("End-of-Day Check-In")
                                .font(.headline)
                                .foregroundStyle(timeManager.isEveningPhase ? .primary : .secondary)
                        }
                    } content: {
                        EndOfDaySection(entry: $entry)
                            .onChange(of: entry.followedSwap) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.feelAboutIt) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.whatGotInTheWay) { _, _ in hasUnsavedChanges = true }
                    } onToggle: {
                        endOfDayExpanded.toggle()
                    }
                    
                    // Prep Tonight (for Tomorrow) - Evening Phase only
                    if timeManager.isEveningPhase {
                        CollapsibleSection(
                            title: "Prep Tonight",
                            isExpanded: prepTonightExpanded,
                            isDimmed: false
                        ) {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundStyle(.blue)
                                Text("Prep Tonight (for Tomorrow)")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                            }
                        } content: {
                            PrepTonightSection(entry: $tomorrowEntry)
                                .onChange(of: tomorrowEntry.stickyNotes) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.preppedProduce) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.waterReady) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.breakfastPrepped) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.nightOther) { _, _ in hasUnsavedChanges = true }
                        } onToggle: {
                            prepTonightExpanded.toggle()
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
                .padding()
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
