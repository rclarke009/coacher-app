//
//  CoacherApp.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

@main
struct CoacherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self, EveningPrepItem.self, UserSettings.self])
    }
}
