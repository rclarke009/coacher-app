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
    @EnvironmentObject private var celebrationManager: CelebrationManager
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]
    
    @StateObject private var timeManager = TimeManager()
    @State private var entry: DailyEntry = DailyEntry()
    @State private var tomorrowEntry: DailyEntry = DailyEntry()
    @State private var showingNeedHelp = false
    @State private var showingSuccessCapture = false
    @State private var hasUnsavedChanges = false
    @State private var autoSaveTimer: Timer?
    @State private var showingCelebration = false
    @State private var celebrationTitle = ""
    @State private var celebrationSubtitle = ""
    
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
                            accent: .dimmedGreen,
                            collapsed: $lastNightPrepExpanded,
                            dimmed: true
                        ) {
                            LastNightPrepReviewView(entry: getLastNightEntry())
                        }
                    }
                    
            // Morning Focus (Today) - Primary in Day Phase
            MorningFocusCard(
                title: "Morning Focus (Today)",
                icon: "sun.max.fill"
            ) {
                        MorningFocusSection(entry: $entry)
                            .onChange(of: entry.myWhy) { _, _ in scheduleAutoSave() }
                            .onChange(of: entry.challenge) { _, _ in scheduleAutoSave() }
                            .onChange(of: entry.challengeOther) { _, _ in scheduleAutoSave() }
                            .onChange(of: entry.chosenSwap) { _, _ in scheduleAutoSave() }
                            .onChange(of: entry.commitFrom) { _, _ in scheduleAutoSave() }
                            .onChange(of: entry.commitTo) { _, _ in scheduleAutoSave() }
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
                            PrepTonightSection(entry: $tomorrowEntry, todayEntry: $entry)
                                .onChange(of: tomorrowEntry.stickyNotes) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.preppedProduce) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.waterReady) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.breakfastPrepped) { _, _ in hasUnsavedChanges = true }
                                .onChange(of: tomorrowEntry.nightOther) { _, _ in hasUnsavedChanges = true }
                        }
                    }
                    
                    // Success Flow Buttons
                    HStack(spacing: 12) {
                        // I Need Help Button
                        Button(action: { showingNeedHelp = true }) {
                            Label("I Need Help", systemImage: "hand.raised.fill")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.helpButtonBlue)
                        .accessibilityLabel("I Need Help")
                        .accessibilityHint("Opens support options for when you're struggling with cravings or challenges")
                        
                        // I Did Great Button
                        Button(action: { showingSuccessCapture = true }) {
                            Label("I Did Great!", systemImage: "checkmark.circle.fill")
                                .font(.title3)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .accessibilityLabel("I Did Great")
                        .accessibilityHint("Capture and celebrate a success or positive moment")
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .navigationTitle("Today")
            .onAppear { 
                loadOrCreateToday()
                loadOrCreateTomorrow()
                setDefaultExpansionStates()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Refresh data when app becomes active to show current day's data
                loadOrCreateToday()
                loadOrCreateTomorrow()
                setDefaultExpansionStates()
            }

            .sheet(isPresented: $showingNeedHelp) {
                NeedHelpView()
            }
            .sheet(isPresented: $showingSuccessCapture) {
                SuccessCaptureView()
            }
            .overlay(
                CelebrationOverlay(
                    isPresented: $showingCelebration,
                    title: celebrationTitle,
                    subtitle: celebrationSubtitle
                )
            )
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
            
            // Inherit custom prep items from today's entry
            if !entry.safeCustomPrepItems.isEmpty {
                tomorrowEntry.customPrepItems = entry.customPrepItems
                // Reset completion status for tomorrow
                tomorrowEntry.completedCustomPrepItems = []
            }
            
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
    
    private func scheduleAutoSave() {
        hasUnsavedChanges = true
        
        // Cancel existing timer
        autoSaveTimer?.invalidate()
        
        // Schedule auto-save after 2 seconds of inactivity
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            autoSave()
        }
    }
    
    private func autoSave() {
        try? context.save()
        hasUnsavedChanges = false
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func saveEntry() {
        try? context.save()
        hasUnsavedChanges = false
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        hideKeyboard()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func triggerCelebration(title: String, subtitle: String) {
        celebrationTitle = title
        celebrationSubtitle = subtitle
        showingCelebration = true
    }
}



#Preview {
    TodayView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self], inMemory: true)
}
