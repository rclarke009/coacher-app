import Foundation
import UserNotifications
import SwiftUI

class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    
    @AppStorage("nightPrepReminder") private var nightPrepReminder = true
    @AppStorage("morningFocusReminder") private var morningFocusReminder = true
    @AppStorage("nightPrepTime") private var nightPrepTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    @AppStorage("morningFocusTime") private var morningFocusTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    
    private init() {}
    
    func requestNotificationPermissions() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        print("🔍 DEBUG: ReminderManager - Requesting notification permissions...")

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print("🔍 DEBUG: ReminderManager - Notification permissions granted: \(granted)")
            return granted
        } catch {
            print("🔍 DEBUG: ReminderManager - Failed to request notification permissions: \(error)")
            return false
        }
    }
    
    func scheduleReminders() async {
        let center = UNUserNotificationCenter.current()
        
        print("🔍 DEBUG: ReminderManager - Starting to schedule reminders...")
        print("🔍 DEBUG: ReminderManager - Night prep reminder enabled: \(nightPrepReminder)")
        print("🔍 DEBUG: ReminderManager - Morning focus reminder enabled: \(morningFocusReminder)")

        // Remove existing notifications
        center.removeAllPendingNotificationRequests()
        print("🔍 DEBUG: ReminderManager - Removed all existing notifications")

        // Schedule night prep reminder
        if nightPrepReminder {
            await scheduleNightPrepReminder()
        }
        
        // Schedule morning focus reminder
        if morningFocusReminder {
            await scheduleMorningFocusReminder()
        }
        
        // List all pending notifications for debugging
        let pendingRequests = await center.pendingNotificationRequests()
        print("🔍 DEBUG: ReminderManager - Total pending notifications: \(pendingRequests.count)")
        for request in pendingRequests {
            print("🔍 DEBUG: ReminderManager - Pending notification: \(request.identifier) - \(request.content.title)")
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                print("🔍 DEBUG: ReminderManager - Next trigger date: \(trigger.nextTriggerDate()?.description ?? "nil")")
            }
        }
    }
    
    private func scheduleNightPrepReminder() async {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Evening Prep! 🌙"
        content.body = "Plan your tomorrow and set yourself up for success"
        content.sound = .default
        content.userInfo = ["destination": "nightPrep"]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: nightPrepTime)
        
        print("🔍 DEBUG: ReminderManager - Scheduling night prep reminder for \(components.hour ?? 0):\(components.minute ?? 0)")

        var trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Ensure the trigger is valid
        if trigger.nextTriggerDate() == nil {
            print("🔍 DEBUG: ReminderManager - Time has passed today, scheduling for tomorrow")
            // If the time has passed today, schedule for tomorrow
            var tomorrow = Date()
            tomorrow = calendar.date(byAdding: .day, value: 1, to: tomorrow) ?? tomorrow
            let tomorrowComponents = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            let combinedComponents = DateComponents(
                year: tomorrowComponents.year,
                month: tomorrowComponents.month,
                day: tomorrowComponents.day,
                hour: components.hour,
                minute: components.minute
            )
            trigger = UNCalendarNotificationTrigger(dateMatching: combinedComponents, repeats: false)
            print("🔍 DEBUG: ReminderManager - Scheduled for tomorrow at \(combinedComponents.hour ?? 0):\(combinedComponents.minute ?? 0)")
        } else {
            print("🔍 DEBUG: ReminderManager - Scheduled for today at \(components.hour ?? 0):\(components.minute ?? 0)")
        }
        
        let request = UNNotificationRequest(
            identifier: "nightPrepReminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("🔍 DEBUG: ReminderManager - Successfully scheduled night prep reminder")
            if let nextDate = trigger.nextTriggerDate() {
                print("🔍 DEBUG: ReminderManager - Next night prep reminder will fire at: \(nextDate)")
            }
        } catch {
            print("🔍 DEBUG: ReminderManager - Failed to schedule night prep reminder: \(error)")
        }
    }
    
    private func scheduleMorningFocusReminder() async {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Morning Focus Time! ☀️"
        content.body = "Review your plan and set your intentions for the day"
        content.sound = .default
        content.userInfo = ["destination": "morningFocus"]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: morningFocusTime)
        
        print("🔍 DEBUG: ReminderManager - Scheduling morning focus reminder for \(components.hour ?? 0):\(components.minute ?? 0)")

        var trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Ensure the trigger is valid
        if trigger.nextTriggerDate() == nil {
            print("🔍 DEBUG: ReminderManager - Time has passed today, scheduling for tomorrow")
            // If the time has passed today, schedule for tomorrow
            var tomorrow = Date()
            tomorrow = calendar.date(byAdding: .day, value: 1, to: tomorrow) ?? tomorrow
            let tomorrowComponents = calendar.dateComponents([.year, .month, .day], from: tomorrow)
            let combinedComponents = DateComponents(
                year: tomorrowComponents.year,
                month: tomorrowComponents.month,
                day: tomorrowComponents.day,
                hour: components.hour,
                minute: components.minute
            )
            trigger = UNCalendarNotificationTrigger(dateMatching: combinedComponents, repeats: false)
            print("🔍 DEBUG: ReminderManager - Scheduled for tomorrow at \(combinedComponents.hour ?? 0):\(combinedComponents.minute ?? 0)")
        } else {
            print("🔍 DEBUG: ReminderManager - Scheduled for today at \(components.hour ?? 0):\(components.minute ?? 0)")
        }
        
        let request = UNNotificationRequest(
            identifier: "morningFocusReminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("🔍 DEBUG: ReminderManager - Successfully scheduled morning focus reminder")
            if let nextDate = trigger.nextTriggerDate() {
                print("🔍 DEBUG: ReminderManager - Next morning focus reminder will fire at: \(nextDate)")
            }
        } catch {
            print("🔍 DEBUG: ReminderManager - Failed to schedule morning focus reminder: \(error)")
        }
    }
    
    func updateReminders() async {
        print("🔍 DEBUG: ReminderManager - updateReminders() called")
        await scheduleReminders()
    }
    
    // MARK: - Testing Methods
    
    func scheduleTestReminder() async {
        let center = UNUserNotificationCenter.current()
        
        print("🔍 DEBUG: ReminderManager - Scheduling test reminder for 10 seconds from now")
        
        let content = UNMutableNotificationContent()
        content.title = "Test Reminder! 🧪"
        content.body = "This is a test notification to verify reminders are working"
        content.sound = .default
        content.userInfo = ["destination": "test"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "testReminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("🔍 DEBUG: ReminderManager - Test reminder scheduled successfully")
        } catch {
            print("🔍 DEBUG: ReminderManager - Failed to schedule test reminder: \(error)")
        }
    }
    
    func checkNotificationStatus() async {
        let center = UNUserNotificationCenter.current()
        
        let settings = await center.notificationSettings()
        print("🔍 DEBUG: ReminderManager - Notification settings:")
        print("🔍 DEBUG: ReminderManager - Authorization status: \(settings.authorizationStatus.rawValue)")
        print("🔍 DEBUG: ReminderManager - Alert setting: \(settings.alertSetting.rawValue)")
        print("🔍 DEBUG: ReminderManager - Sound setting: \(settings.soundSetting.rawValue)")
        print("🔍 DEBUG: ReminderManager - Badge setting: \(settings.badgeSetting.rawValue)")
        
        let pendingRequests = await center.pendingNotificationRequests()
        print("🔍 DEBUG: ReminderManager - Pending notifications: \(pendingRequests.count)")
        for request in pendingRequests {
            print("🔍 DEBUG: ReminderManager - \(request.identifier): \(request.content.title)")
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                print("🔍 DEBUG: ReminderManager - Next trigger: \(trigger.nextTriggerDate()?.description ?? "nil")")
            } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                print("🔍 DEBUG: ReminderManager - Time interval trigger: \(trigger.timeInterval) seconds")
            }
        }
    }
}
