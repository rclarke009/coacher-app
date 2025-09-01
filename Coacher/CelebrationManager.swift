import SwiftUI
import Foundation

// CelebrationStyle is now defined in CelebrationOverlay.swift

class CelebrationManager: ObservableObject {
    @AppStorage("celebrationStyle") private var celebrationStyle: CelebrationStyle = .playful
    @AppStorage("showCelebrations") private var showCelebrations: Bool = true
    
    // Encouraging phrases for celebrations
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
    
    var currentStyle: CelebrationStyle {
        get { celebrationStyle }
        set { 
            celebrationStyle = newValue
            objectWillChange.send()
        }
    }
    
    var celebrationsEnabled: Bool {
        get { showCelebrations }
        set { 
            showCelebrations = newValue
            objectWillChange.send()
        }
    }
    
    func randomEncouragingPhrase() -> String {
        encouragingPhrases.randomElement() ?? encouragingPhrases[0]
    }
    
    func shouldCelebrate() -> Bool {
        return showCelebrations
    }
}
