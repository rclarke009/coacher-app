import SwiftUI
import Foundation

// CelebrationStyle is now defined in CelebrationOverlay.swift

class CelebrationManager: ObservableObject {
    @AppStorage("celebrationStyle") private var celebrationStyle: CelebrationStyle = .playful
    @AppStorage("showCelebrations") private var showCelebrations: Bool = true
    
    // Encouraging phrases for celebrations
    private let encouragingPhrases = [
        "🌱 One healthier choice, done.",
        "🌟 That swap makes you stronger.",
        "🎈 Small steps, big wins.",
        "💪 You're building momentum!",
        "✨ Every choice counts!",
        "🌿 Growing healthier habits!",
        "🎯 Great job staying on track!",
        "🚀 You're making progress!"
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
