//
//  TimelineScreen.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

enum DayKey: Hashable { case day(Int) } // -1..-7 past, 0 today

struct TimelineScreen: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]
    
    @StateObject private var timeManager = TimeManager()
    @State private var entryToday = DailyEntry()
    @State private var showingNeedHelp = false
    @State private var hasUnsavedChanges = false
    @State private var showingCelebration = false
    @State private var celebrationTitle = ""
    @State private var celebrationSubtitle = ""
    @State private var celebrationStyle: CelebrationStyle = .playful
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // 7 PAST DAYS (collapsed, dimmed)
                        ForEach((1...7).reversed(), id: \.self) { back in
                            DayBucket(offset: -back, entries: entries)
                                .id(DayKey.day(-back))
                        }
                        
                        // TODAY (expanded morning)
                        DayBucket(offset: 0, entries: entries, entryToday: $entryToday, hasUnsavedChanges: $hasUnsavedChanges)
                            .id(DayKey.day(0))
                        
                        // TONIGHT ONLY (no future placeholders)
                        TonightBucket(
                            entries: entries, 
                            entryToday: $entryToday, 
                            hasUnsavedChanges: $hasUnsavedChanges,
                            onCelebrationTrigger: triggerCelebration
                        )
                        
                        // I Need Help Button
                        Button(action: { showingNeedHelp = true }) {
                            Label("I Need Help", systemImage: "hand.raised.fill")
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .onAppear { 
                    loadOrCreateToday()
                    proxy.scrollTo(DayKey.day(0), anchor: .center)
                }
                .navigationTitle("Today")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        SaveButton(entry: entryToday, hasUnsavedChanges: hasUnsavedChanges) {
                            saveEntry()
                        }
                    }
                }
                .sheet(isPresented: $showingNeedHelp) {
                    NeedHelpView()
                }
                .overlay(
                    // Global celebration overlay - truly full screen
                    CelebrationOverlay(
                        isPresented: $showingCelebration,
                        style: celebrationStyle,
                        title: celebrationTitle,
                        subtitle: celebrationSubtitle
                    )
                )
            }
        }
    }
    
    private func loadOrCreateToday() {
        let startOfDay = timeManager.todayDate
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfDay) }) {
            entryToday = existing
        } else {
            entryToday = DailyEntry()
            entryToday.date = startOfDay
            context.insert(entryToday)
            try? context.save()
        }
    }
    
    private func saveEntry() {
        try? context.save()
        hasUnsavedChanges = false
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func triggerCelebration(title: String, subtitle: String, style: CelebrationStyle) {
        celebrationTitle = title
        celebrationSubtitle = subtitle
        celebrationStyle = style
        showingCelebration = true
    }
}

#Preview {
    TimelineScreen()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self], inMemory: true)
}
