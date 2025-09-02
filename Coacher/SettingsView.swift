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
    @EnvironmentObject private var reminderManager: ReminderManager
    @Query private var achievements: [Achievement]
    @StateObject private var mlcManager = SimplifiedMLCManager()
    
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
                        .onChange(of: nightPrepReminder) { _, _ in
                            Task {
                                await reminderManager.updateReminders()
                            }
                        }
                    if nightPrepReminder {
                        DatePicker("Time", selection: $nightPrepTime, displayedComponents: .hourAndMinute)
                            .onChange(of: nightPrepTime) { _, _ in
                                Task {
                                    await reminderManager.updateReminders()
                                }
                            }
                    }
                    
                    Toggle("Morning Focus Reminder", isOn: $morningFocusReminder)
                        .onChange(of: morningFocusReminder) { _, _ in
                            Task {
                                await reminderManager.updateReminders()
                            }
                        }
                    if morningFocusReminder {
                        DatePicker("Time", selection: $morningFocusTime, displayedComponents: .hourAndMinute)
                            .onChange(of: morningFocusTime) { _, _ in
                                Task {
                                    await reminderManager.updateReminders()
                                }
                            }
                    }
                    
                    // Test buttons for debugging
                    HStack {
                        Button("Test Reminder (10s)") {
                            Task {
                                await reminderManager.scheduleTestReminder()
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Check Status") {
                            Task {
                                await reminderManager.checkNotificationStatus()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Section("Gamification") {
                    Toggle("Show animations", isOn: $celebrationManager.animationsEnabled)
                    
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
                
                Section("AI Coach") {
                    HStack {
                        Text("Model Status")
                        Spacer()
                        Text(mlcManager.modelStatus)
                            .foregroundStyle(.secondary)
                    }
                    
                    if mlcManager.isModelLoaded {
                        HStack {
                            Text("Model")
                            Spacer()
                            Text("Llama-2-7B")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Quantization")
                            Spacer()
                            Text("Q4F16")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !mlcManager.isModelLoaded && !mlcManager.isLoading {
                        Button("Load Model") {
                            Task {
                                await mlcManager.loadModel()
                            }
                        }
                        .foregroundColor(.brandBlue)
                    }
                    
                    if mlcManager.errorMessage != nil {
                        Text(mlcManager.errorMessage ?? "")
                            .foregroundStyle(.red)
                            .font(.caption)
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
