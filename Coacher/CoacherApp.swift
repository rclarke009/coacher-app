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
    @StateObject private var celebrationManager = CelebrationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(celebrationManager)
        }
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self, EveningPrepItem.self, UserSettings.self, AudioRecording.self])
    }
}
