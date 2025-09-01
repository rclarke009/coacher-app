//
//  HistoryView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

enum TimelineItem: Identifiable {
    case entry(DailyEntry)
    case audioRecording(AudioRecording)
    
    var id: String {
        switch self {
        case .entry(let entry):
            return "entry-\(entry.id.uuidString)"
        case .audioRecording(let recording):
            return "recording-\(recording.id.uuidString)"
        }
    }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \DailyEntry.date, order: .reverse) private var entries: [DailyEntry]
    @Query(sort: \AudioRecording.date, order: .reverse) private var audioRecordings: [AudioRecording]
    
    var body: some View {
        let _ = print("🔍 DEBUG: HistoryView - ModelContext: \(context)")
        let _ = print("🔍 DEBUG: HistoryView - Found \(entries.count) daily entries")
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Streak Heatmap
                    StreakHeatmap(entryDates: Set(entries.map { Calendar.current.startOfDay(for: $0.date) }))
                        .padding(.horizontal)
                    
                    // Weekly Completion Ring
                    WeeklyCompletionRing(entries: entries)
                        .padding(.horizontal)
                    
                    // Combined Timeline (Entries + Audio Recordings)
                    LazyVStack(spacing: 12) {
                        let combinedItems = createCombinedTimeline()
                        ForEach(combinedItems, id: \.id) { item in
                            switch item {
                            case .entry(let entry):
                                EntryRowView(entry: entry)
                            case .audioRecording(let recording):
                                AudioRecordingRow(recording: recording)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("History")
        }
    }
    
    private func createCombinedTimeline() -> [TimelineItem] {
        var items: [TimelineItem] = []
        
        // Add daily entries
        for entry in entries {
            items.append(.entry(entry))
        }
        
        // Add audio recordings
        for recording in audioRecordings {
            items.append(.audioRecording(recording))
        }
        
        // Sort by date (most recent first)
        return items.sorted { first, second in
            let firstDate: Date
            let secondDate: Date
            
            switch first {
            case .entry(let entry):
                firstDate = entry.date
            case .audioRecording(let recording):
                firstDate = recording.date
            }
            
            switch second {
            case .entry(let entry):
                secondDate = entry.date
            case .audioRecording(let recording):
                secondDate = recording.date
            }
            
            return firstDate > secondDate
        }
    }
}

struct EntryRowView: View {
    let entry: DailyEntry
    
    var body: some View {
        NavigationLink(destination: EntryDetailView(entry: entry)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.date, style: .date)
                        .font(.headline)
                    
                    Spacer()
                    
                    if entry.hasAnyAction {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                if entry.hasAnyAction {
                    HStack {
                        if entry.hasAnyNightPrep {
                            Label("Night Prep", systemImage: "moon.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        
                        if entry.hasAnyMorningFocus {
                            Label("Morning Focus", systemImage: "sun.max.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        
                        if entry.hasAnyEndOfDay {
                            Label("End of Day", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                } else {
                    Text("No actions logged")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}



struct EntryDetailView: View {
    let entry: DailyEntry
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                NightPrepSection(entry: .constant(entry))
                Divider()
                MorningFocusSection(entry: .constant(entry))
                Divider()
                EndOfDaySection(
                    entry: .constant(entry),
                    onCelebrationTrigger: { _, _ in }
                )
            }
            .padding()
        }
        .navigationTitle(entry.date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WeeklyCompletionRing: View {
    let entries: [DailyEntry]
    
    private var weeklyProgress: Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        let daysThisWeek = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
        }
        
        let completedDays = daysThisWeek.filter { date in
            entries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: date) && entry.hasAnyAction
            }
        }.count
        
        return Double(completedDays) / 7.0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: weeklyProgress)
                    .stroke(Color.teal, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: weeklyProgress)
                
                VStack {
                    Text("\(Int(weeklyProgress * 100))%")
                        .font(.title2)
                        .bold()
                    Text("\(Int(weeklyProgress * 7))/7 days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}





#Preview {
    HistoryView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, AudioRecording.self], inMemory: true)
}
