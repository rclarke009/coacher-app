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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Night Prep Section
                    NightPrepSection(entry: $entry)
                    
                    Divider()
                    
                    // Morning Focus Section
                    MorningFocusSection(entry: $entry)
                    
                    Divider()
                    
                    // End of Day Section
                    EndOfDaySection(entry: $entry)
                    
                    // Quick Capture Button
                    Button(action: { showingQuickCapture = true }) {
                        Label("Quick Capture", systemImage: "mic.circle.fill")
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
                    SaveButton(entry: entry)
                }
            }
            .sheet(isPresented: $showingQuickCapture) {
                QuickCaptureView()
            }
        }
    }
    
    private func loadOrCreateToday() {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        if let existing = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: startOfDay) }) {
            entry = existing
        } else {
            entry = DailyEntry()
            entry.date = startOfDay
            context.insert(entry)
            try? context.save()
        }
    }
}

struct SaveButton: View {
    let entry: DailyEntry
    
    var body: some View {
        Button("Save") {
            // Entry is automatically saved by SwiftData when modified
        }
        .disabled(false) // Always enabled since SwiftData auto-saves
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self], inMemory: true)
}
