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
    
    // New flexible evening prep system
    var eveningPrepItems: [EveningPrepItem]?
    var customPrepItems: [String]? // All custom prep items (regardless of completion status)
    var completedCustomPrepItems: [String]? // Track which custom prep items were completed today
    
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
    var voiceNotes: [URL]?
    
    // Craving notes for "I Need Help" flow
    var cravingNotes: [CravingNote]?
    
    init() {
        self.id = UUID()
        self.date = Date()
        self.stickyNotes = false
        self.preppedProduce = false
        self.waterReady = false
        self.breakfastPrepped = false
        self.nightOther = ""
        self.eveningPrepItems = nil
        self.customPrepItems = nil
        self.completedCustomPrepItems = nil
        self.myWhy = ""
        self.challenge = Challenge.none
        self.challengeOther = ""
        self.chosenSwap = ""
        self.commitFrom = ""
        self.commitTo = ""
        self.followedSwap = nil
        self.feelAboutIt = ""
        self.whatGotInTheWay = ""
        self.voiceNotes = nil
        self.cravingNotes = nil
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
    
    // Helper computed properties for optional arrays
    var safeEveningPrepItems: [EveningPrepItem] {
        eveningPrepItems ?? []
    }
    
    var safeCustomPrepItems: [String] {
        customPrepItems ?? []
    }
    
    var safeCompletedCustomPrepItems: [String] {
        completedCustomPrepItems ?? []
    }
    
    var safeVoiceNotes: [URL] {
        voiceNotes ?? []
    }
    
    var safeCravingNotes: [CravingNote] {
        cravingNotes ?? []
    }
    
    // MARK: - Array Management Helpers
    func ensureArraysInitialized() {
        if eveningPrepItems == nil {
            eveningPrepItems = []
        }
        if customPrepItems == nil {
            customPrepItems = []
        }
        if completedCustomPrepItems == nil {
            completedCustomPrepItems = []
        }
        if voiceNotes == nil {
            voiceNotes = []
        }
        if cravingNotes == nil {
            cravingNotes = []
        }
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
