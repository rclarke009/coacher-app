//
//  DailyEntry.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import Foundation
import SwiftData

@Model
final class DailyEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    
    // Night Prep
    var stickyNotes: Bool
    var preppedProduce: Bool
    var waterReady: Bool
    var breakfastPrepped: Bool
    var nightOther: String
    
    // Morning Focus
    var myWhy: String
    var challenge: Challenge
    var challengeOther: String
    var chosenSwap: String
    var commitFrom: String   // instead of ___
    var commitTo: String     // Today I will ___ instead of ___
    
    // End of Day
    var followedSwap: Bool?
    var feelAboutIt: String
    var whatGotInTheWay: String
    
    // Voice notes (file URLs in app sandbox)
    var voiceNotes: [URL]
    
    init() {
        self.id = UUID()
        self.date = Date()
        self.stickyNotes = false
        self.preppedProduce = false
        self.waterReady = false
        self.breakfastPrepped = false
        self.nightOther = ""
        self.myWhy = ""
        self.challenge = Challenge.none
        self.challengeOther = ""
        self.chosenSwap = ""
        self.commitFrom = ""
        self.commitTo = ""
        self.followedSwap = nil
        self.feelAboutIt = ""
        self.whatGotInTheWay = ""
        self.voiceNotes = []
    }
    
    // Computed properties for convenience
    var hasAnyNightPrep: Bool {
        stickyNotes || preppedProduce || waterReady || breakfastPrepped || !nightOther.isEmpty
    }
    
    var hasAnyMorningFocus: Bool {
        !myWhy.isEmpty || challenge != .none || !chosenSwap.isEmpty || !commitTo.isEmpty || !commitFrom.isEmpty
    }
    
    var hasAnyEndOfDay: Bool {
        followedSwap != nil || !feelAboutIt.isEmpty || !whatGotInTheWay.isEmpty
    }
    
    var hasAnyAction: Bool {
        hasAnyNightPrep || hasAnyMorningFocus || hasAnyEndOfDay
    }
}

enum Challenge: String, Codable, CaseIterable, Identifiable {
    case none, skippingMeals, lateNightSnacking, sugaryDrinks, onTheGo, emotionalEating, other
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .none: return "Select..."
        case .skippingMeals: return "Skipping meals"
        case .lateNightSnacking: return "Late-night snacking"
        case .sugaryDrinks: return "Sugary drinks"
        case .onTheGo: return "Eating on the go / fast food"
        case .emotionalEating: return "Emotional eating"
        case .other: return "Other"
        }
    }
}
