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
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self, SuccessNote.self, EveningPrepItem.self, UserSettings.self, AudioRecording.self])
    }
    
    private func setupNotifications() {
        Task {
            let granted = await reminderManager.requestNotificationPermissions()
            if granted {
                await reminderManager.scheduleReminders()
            }
        }
    }
}
