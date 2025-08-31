//
//  SettingsView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var celebrationManager: CelebrationManager
    @Query private var achievements: [Achievement]
    
    @AppStorage("showStreakWidgets") private var showStreakWidgets = true
    @AppStorage("nightPrepReminder") private var nightPrepReminder = true
    @AppStorage("morningFocusReminder") private var morningFocusReminder = true
    @AppStorage("nightPrepTime") private var nightPrepTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    @AppStorage("morningFocusTime") private var morningFocusTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    
    var body: some View {
        NavigationView {
            List {
                Section("Reminders") {
                    Toggle("Night Prep Reminder", isOn: $nightPrepReminder)
                    if nightPrepReminder {
                        DatePicker("Time", selection: $nightPrepTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("Morning Focus Reminder", isOn: $morningFocusReminder)
                    if morningFocusReminder {
                        DatePicker("Time", selection: $morningFocusTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Gamification") {
                    Toggle("Show celebrations", isOn: $celebrationManager.celebrationsEnabled)
                    
                    if celebrationManager.celebrationsEnabled {
                        Picker("Celebration Style", selection: $celebrationManager.currentStyle) {
                            ForEach(CelebrationStyle.allCases, id: \.self) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Toggle("Show streak widgets", isOn: $showStreakWidgets)
                    
                    if !achievements.isEmpty {
                        HStack {
                            Text("Achievements earned")
                            Spacer()
                            Text("\(achievements.count)")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button("Reset achievements") {
                            resetAchievements()
                        }
                        .foregroundStyle(.red)
                    }
                }
                
                Section("Data & Privacy") {
                    Button("Export data") {
                        exportData()
                    }
                    .foregroundColor(.leafGreen)
                    
                    Button("Import data") {
                        importData()
                    }
                    .foregroundColor(.leafYellow)
                    
                    Button("Clear all data") {
                        clearAllData()
                    }
                    .foregroundStyle(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func resetAchievements() {
        // TODO: Show confirmation dialog
        for achievement in achievements {
            context.delete(achievement)
        }
        try? context.save()
    }
    
    private func exportData() {
        // TODO: Implement data export
    }
    
    private func importData() {
        // TODO: Implement data import
    }
    
    private func clearAllData() {
        // TODO: Show confirmation dialog and implement data clearing
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self], inMemory: true)
}
