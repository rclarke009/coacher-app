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
    
    @State private var entry: DailyEntry = DailyEntry()
    @State private var showingQuickCapture = false
    @State private var hasUnsavedChanges = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Night Prep Section
                    NightPrepSection(entry: $entry)
                        .onChange(of: entry.stickyNotes) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.preppedProduce) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.waterReady) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.breakfastPrepped) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.nightOther) { _, _ in hasUnsavedChanges = true }
                    
                    Divider()
                    
                    // Morning Focus Section
                    MorningFocusSection(entry: $entry)
                        .onChange(of: entry.myWhy) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.challenge) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.challengeOther) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.chosenSwap) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.commitFrom) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.commitTo) { _, _ in hasUnsavedChanges = true }
                    
                    Divider()
                    
                    // End of Day Section
                    EndOfDaySection(entry: $entry)
                        .onChange(of: entry.followedSwap) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.feelAboutIt) { _, _ in hasUnsavedChanges = true }
                        .onChange(of: entry.whatGotInTheWay) { _, _ in hasUnsavedChanges = true }
                    
                    // Quick Capture Button
                    Button(action: { showingQuickCapture = true }) {
                        Label("I'm craving / I'm stressed", systemImage: "mic.circle.fill")
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
            .onAppear { loadOrCreateToday() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SaveButton(entry: entry, hasUnsavedChanges: hasUnsavedChanges) {
                        saveEntry()
                    }
                }
            }
            .sheet(isPresented: $showingQuickCapture) {
                QuickCaptureView()
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                // Dismiss keyboard when tapping outside text fields
                hideKeyboard()
            }
        }
    }
    
    private func loadOrCreateToday() {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfDay) }) {
            entry = existing
            hasUnsavedChanges = false
        } else {
            entry = DailyEntry()
            entry.date = startOfDay
            context.insert(entry)
            try? context.save()
            hasUnsavedChanges = false
        }
    }
    
    private func saveEntry() {
        // Force a save to ensure all changes are persisted
        try? context.save()
        hasUnsavedChanges = false
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Dismiss keyboard after saving
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
