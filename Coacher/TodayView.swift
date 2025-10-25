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
    @State private var showingNeedHelp = false
    @State private var showingSuccessCapture = false
    @State private var hasUnsavedChanges = false
    @State private var autoSaveTimer: Timer?
    
    // Section expansion states
    @State private var lastNightPrepExpanded = false
    @State private var morningFocusCollapsed = false
    @State private var endOfDayCollapsed = true
    @State private var hasCompletedMorningToday = false
    @State private var shouldResetMorningFlow = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 14) {
                    
            // Morning Focus (Today) - Primary in Day Phase
            if entry.morningFlowCompletedToday && !shouldResetMorningFlow {
                // Show summary card when morning flow is completed
                MorningSummaryDisplayCard(entry: entry, onRestart: {
                    shouldResetMorningFlow = true
                })
            } else {
                SectionCard(
                    title: "Morning Focus (Today)",
                    icon: "sun.max.fill",
                    accent: .blue,
                    collapsed: $morningFocusCollapsed
                ) {
                            CareFirstMorningFocusSection(entry: $entry)
                                .onChange(of: entry.whyThisMatters) { _, _ in scheduleAutoSave() }
                                .onChange(of: entry.identityStatement) { _, _ in scheduleAutoSave() }
                                .onChange(of: entry.todaysFocus) { _, _ in scheduleAutoSave() }
                                .onChange(of: entry.stressResponse) { _, _ in scheduleAutoSave() }
                                .onChange(of: entry.morningFlowCompletedToday) { _, isCompleted in
                                    if isCompleted {
                                        shouldResetMorningFlow = false
                                    }
                                }
                        }
            }
                    
                    // End-of-Day Check-In - Primary in Evening Phase
                    SectionCard(
                        title: "End-of-Day Check-In",
                        icon: "clock.fill",
                        accent: .teal,
                        collapsed: $endOfDayCollapsed,
                        dimmed: timeManager.isDayPhase
                    ) {
                        CareFirstEndOfDaySection(
                            entry: $entry,
                            onCelebrationTrigger: { _, _ in },
                            scrollProxy: proxy
                        )
                            .onChange(of: entry.didCareAction) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.whatHelpedCalm) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.comfortEatingMoment) { _, _ in hasUnsavedChanges = true }
                            .onChange(of: entry.smallWinsForTomorrow) { _, _ in hasUnsavedChanges = true }
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
            }
            .navigationTitle("Today")
            .onAppear {
                loadOrCreateToday()
                setDefaultExpansionStates()
                checkMorningCompletionToday()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Refresh data when app becomes active to show current day's data
                loadOrCreateToday()
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
                    isPresented: $celebrationManager.showingTinyCelebration,
                    title: "",
                    subtitle: celebrationManager.celebrationMessage
                )
            )
            .overlay(
                CelebrationOverlay(
                    isPresented: $celebrationManager.showingMediumCelebration,
                    title: "",
                    subtitle: celebrationManager.celebrationMessage
                )
            )
            .overlay(
                CelebrationOverlay(
                    isPresented: $celebrationManager.showingBigCelebration,
                    title: "",
                    subtitle: celebrationManager.celebrationMessage
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
            
            // Carry over yesterday's whatElseCouldHelp as today's stressResponse
            if let yesterdayEntry = getYesterdayEntry(), 
               let whatElseCouldHelp = yesterdayEntry.whatElseCouldHelp,
               !whatElseCouldHelp.isEmpty {
                entry.stressResponse = whatElseCouldHelp
            }
            
            context.insert(entry)
            try? context.save()
        }
    }
    
    private func getYesterdayEntry() -> DailyEntry? {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: timeManager.todayDate) ?? timeManager.todayDate
        return entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: yesterday) })
    }
    
    

    
    private func getLastNightEntry() -> DailyEntry? {
        let startOfLastNight = timeManager.lastNightDate
        return entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfLastNight) })
    }
    
    private func setDefaultExpansionStates() {
        if timeManager.isDayPhase {
            morningFocusCollapsed = false  // Expanded during day
            endOfDayCollapsed = true       // Collapsed during day
        } else {
            morningFocusCollapsed = true   // Collapsed during evening
            endOfDayCollapsed = false      // Expanded during evening
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
    
    private func checkMorningCompletionToday() {
        let today = Calendar.current.startOfDay(for: Date())
        let savedDate = UserDefaults.standard.object(forKey: "morningCompletedDate") as? Date
        
        if let savedDate = savedDate, Calendar.current.isDate(savedDate, inSameDayAs: today) {
            hasCompletedMorningToday = true
        } else {
            hasCompletedMorningToday = false
        }
    }
    
}

// MARK: - Morning Summary Display Card

struct MorningSummaryDisplayCard: View {
    let entry: DailyEntry
    let onRestart: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingRestartConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.title3)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .accessibilityHidden(true)
                
                Text("Morning Focus (Today)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                // Show checkmark when completed
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
                    .accessibilityLabel("Completed")
            }
            .padding(.horizontal, 14).padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.morningFocusBackground)
            )
            .clipShape(.rect(cornerRadius: 16, style: .continuous))

            // Summary content
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Text("You're ready to win the day")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                        Text("Your Plan")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                
                // Summary content in blue cards
                VStack(spacing: 12) {
                    // Why This Matters
                    if !entry.whyThisMatters.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        SummaryItem(
                            label: "Why This Matters",
                            text: entry.whyThisMatters,
                            color: .blue
                        )
                    }
                    
                    // Identity Statement
                    if let identity = entry.identityStatement, !identity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        SummaryItem(
                            label: "I Am Someone Who...",
                            text: identity,
                            color: .blue
                        )
                    }
                    
                    // Today's Focus
                    if !entry.todaysFocus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        SummaryItem(
                            label: "Today's Focus",
                            text: entry.todaysFocus,
                            color: .blue
                        )
                    }
                    
                    // Stress Response
                    if !entry.stressResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        SummaryItem(
                            label: "Stress Response",
                            text: entry.stressResponse,
                            color: .blue
                        )
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button("Restart") {
                        showingRestartConfirmation = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.blue)
                    
                    Spacer()
                }
            }
            .padding(14)
            .padding(.top, 0) // Reduce top padding to connect with header
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.morningFocusBackground)
        )
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .confirmationDialog("Restart Morning Flow", isPresented: $showingRestartConfirmation) {
            Button("Restart", role: .destructive) {
                onRestart()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset your morning flow so you can go through it again. Your current answers will be pre-filled.")
        }
    }
}


#Preview {
    TodayView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self], inMemory: true)
}
