import SwiftUI
import Foundation

class CelebrationManager: ObservableObject {
    @AppStorage("showCelebrations") private var showCelebrations: Bool = true
    @AppStorage("showAnimations") private var showAnimations: Bool = true
    
    @Published var showingMilestoneCelebration = false
    @Published var milestoneStreakCount = 0
    @Published var milestoneMessage = ""
    
    private let streakManager = StreakManager()
    
    // Encouraging phrases for regular celebrations
    private let encouragingPhrases = [
        "One healthier choice, done.",
        "That swap makes you stronger.",
        "Small steps, big wins.",
        "You're building momentum!",
        "Every choice counts!",
        "Growing healthier habits!",
        "Great job staying on track!",
        "You're making progress!",
        "Little swaps, lasting change.",
        "Another brick in your strong foundation.",
        "Tiny steps grow into giant leaps.",
        "You chose health today.",
        "That's how habits are built—one choice.",
        "Momentum is on your side.",
        "Keep stacking wins like this.",
        "Today's choice shapes tomorrow's you.",
        "You're proving it's possible.",
        "That swap is a gift to your future self.",
        "Onward and upward!",
        "Next stop: a healthier you",
        "You're leveling up!",
        "Ka-ching! Another win.",
        "Your future self just high-fived you",
        "Momentum unlocked!",
        "That's how champions roll."
    ]
    
    // Get the streak manager for external access
    var streakTracker: StreakManager {
        return streakManager
    }
    
    var celebrationsEnabled: Bool {
        get { showCelebrations }
        set { 
            showCelebrations = newValue
            objectWillChange.send()
        }
    }
    
    var animationsEnabled: Bool {
        get { showAnimations }
        set { 
            showAnimations = newValue
            objectWillChange.send()
        }
    }
    
    func randomEncouragingPhrase() -> String {
        encouragingPhrases.randomElement() ?? encouragingPhrases[0]
    }
    
    func shouldCelebrate() -> Bool {
        return showCelebrations
    }
    
    // Check for milestone celebrations
    func checkForMilestoneCelebration() {
        guard showCelebrations else { return }
        
        if streakManager.shouldCelebrateMilestone() {
            milestoneStreakCount = streakManager.streak
            milestoneMessage = streakManager.milestoneQuote() ?? "Amazing achievement!"
            showingMilestoneCelebration = true
            
            // Mark milestone as celebrated
            streakManager.markMilestoneCelebrated()
        }
    }
    
    // Record activity and check for milestones
    func recordActivity() {
        streakManager.recordActivity()
        checkForMilestoneCelebration()
    }
    
    // Dismiss milestone celebration
    func dismissMilestoneCelebration() {
        showingMilestoneCelebration = false
    }
}
