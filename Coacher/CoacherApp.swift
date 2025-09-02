//
//  CoacherApp.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct CoacherApp: App {
    @StateObject private var celebrationManager = CelebrationManager()
    @StateObject private var reminderManager = ReminderManager.shared
    @StateObject private var notificationHandler = NotificationHandler.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(celebrationManager)
                .environmentObject(reminderManager)
                .environmentObject(notificationHandler)
                .onAppear {
                    setupNotifications()
                }
        }
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self, EveningPrepItem.self, UserSettings.self, AudioRecording.self])
    }
    
    private func setupNotifications() {
        print("🔍 DEBUG: CoacherApp - setupNotifications() called")
        Task {
            let granted = await reminderManager.requestNotificationPermissions()
            print("🔍 DEBUG: CoacherApp - Notification permissions granted: \(granted)")
            if granted {
                print("🔍 DEBUG: CoacherApp - Scheduling reminders...")
                await reminderManager.scheduleReminders()
                print("🔍 DEBUG: CoacherApp - Reminders scheduled")
            } else {
                print("🔍 DEBUG: CoacherApp - Notification permissions denied")
            }
        }
    }
}
