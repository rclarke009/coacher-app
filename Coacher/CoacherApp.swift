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
    @StateObject private var hybridManager = HybridLLMManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(celebrationManager)
                .environmentObject(reminderManager)
                .environmentObject(notificationHandler)
                .environmentObject(hybridManager)
                .onAppear {
                    setupNotifications()
                    startBackgroundModelLoading()
                }
        }
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self, SuccessNote.self, EveningPrepItem.self, UserSettings.self, AudioRecording.self, EmotionalTakeoverNote.self, HabitHelperNote.self])
    }
    
    private func setupNotifications() {
        Task {
            let granted = await reminderManager.requestNotificationPermissions()
            if granted {
                await reminderManager.scheduleReminders()
            }
        }
    }
    
private func startBackgroundModelLoading() {
    // Skip AI loading on simulator to prevent crashes
    #if targetEnvironment(simulator)
    print("📱 Running on simulator - skipping AI model loading for App Store screenshots")
    return
    #endif
    
    // Start loading the AI model in the background immediately
    // Users won't see this happening - it's completely invisible
    Task {
        await hybridManager.loadModel()
    }
}
}
