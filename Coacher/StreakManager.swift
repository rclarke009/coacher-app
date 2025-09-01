import Foundation
import SwiftUI

class StreakManager: ObservableObject {
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @AppStorage("longestStreak") private var longestStreak: Int = 0
    @AppStorage("lastActivityDate") private var lastActivityDate: Date = Date.distantPast
    @AppStorage("lastMilestoneCelebrated") private var lastMilestoneCelebrated: Int = 0
    
    // Milestone thresholds
    private let milestoneThresholds = [3, 7, 14, 30, 100]
    
    // Milestone quotes for different streak lengths
    private let milestoneQuotes: [Int: [String]] = [
        3: [
            "Three days straight — your new habit is taking root. 🌱",
            "Consistency is growing — keep watering it.",
            "That's a solid start! You're proving to yourself you can do this.",
            "Momentum is on your side now — ride the wave!"
        ],
        7: [
            "One week strong — your future self is cheering! 🎉",
            "Seven days in a row — amazing consistency!",
            "A whole week of swaps adds up — you've changed your tomorrow, seven times over.",
            "This is no fluke. You're building a real pattern."
        ],
        14: [
            "Two weeks of dedication — you're unstoppable! 🚀",
            "Fortnight fighter! Your habit is becoming second nature.",
            "Fourteen days strong — you've proven this isn't temporary.",
            "Halfway to a month! You're building something lasting."
        ],
        30: [
            "One month of consistency — you're a habit master! 👑",
            "Thirty days strong — you've transformed your life!",
            "A full month of healthy choices — this is who you are now.",
            "Monthly master! You've built a foundation that lasts."
        ],
        100: [
            "Century club! 100 days of dedication! 🏆",
            "One hundred days strong — you're absolutely incredible!",
            "A hundred days of healthy choices — you've changed your life forever.",
            "Century achievement unlocked! You're a legend!"
        ]
    ]
    
    var streak: Int { currentStreak }
    var longest: Int { longestStreak }
    
    // Check if today's activity should trigger a milestone celebration
    func shouldCelebrateMilestone() -> Bool {
        guard currentStreak > 0 else { return false }
        
        // Check if we've hit a new milestone
        for threshold in milestoneThresholds {
            if currentStreak == threshold && lastMilestoneCelebrated < threshold {
                return true
            }
        }
        return false
    }
    
    // Get the current milestone level (if any)
    func currentMilestoneLevel() -> Int? {
        guard currentStreak > 0 else { return nil }
        
        for threshold in milestoneThresholds.reversed() {
            if currentStreak >= threshold {
                return threshold
            }
        }
        return nil
    }
    
    // Get a random quote for the current milestone
    func milestoneQuote() -> String? {
        guard let level = currentMilestoneLevel(),
              let quotes = milestoneQuotes[level] else { return nil }
        
        return quotes.randomElement() ?? quotes[0]
    }
    
    // Mark milestone as celebrated
    func markMilestoneCelebrated() {
        if let level = currentMilestoneLevel() {
            lastMilestoneCelebrated = level
        }
    }
    
    // Record activity for today
    func recordActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastActivity = Calendar.current.startOfDay(for: lastActivityDate)
        
        if Calendar.current.isDate(today, inSameDayAs: lastActivity) {
            // Already recorded today
            return
        }
        
        if Calendar.current.isDate(today, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: lastActivity) ?? Date.distantFuture) {
            // Consecutive day - increment streak
            currentStreak += 1
        } else if Calendar.current.isDate(today, inSameDayAs: lastActivity) == false {
            // New day but not consecutive - reset streak
            currentStreak = 1
        }
        
        // Update longest streak if needed
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastActivityDate = today
    }
    
    // Reset streak (for testing or user request)
    func resetStreak() {
        currentStreak = 0
        lastActivityDate = Date.distantPast
        lastMilestoneCelebrated = 0
    }
    
    // Get streak status for display
    func streakStatus() -> String {
        if currentStreak == 0 {
            return "Start your streak today!"
        } else if currentStreak == 1 {
            return "1 day streak"
        } else {
            return "\(currentStreak) day streak"
        }
    }
    
    // Check if streak is in danger (missed yesterday)
    func isStreakInDanger() -> Bool {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayStart = Calendar.current.startOfDay(for: yesterday)
        let lastActivity = Calendar.current.startOfDay(for: lastActivityDate)
        
        return Calendar.current.isDate(yesterdayStart, inSameDayAs: lastActivity) == false
    }
    
    // Get days since last activity
    func daysSinceLastActivity() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let lastActivity = Calendar.current.startOfDay(for: lastActivityDate)
        
        let components = Calendar.current.dateComponents([.day], from: lastActivity, to: today)
        return components.day ?? 0
    }
}
