//
//  ContentView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TimelineScreen()
                .tabItem { Label("Today", systemImage: "calendar") }
            CoachView()
                .tabItem { Label("Coach", systemImage: "message") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self, EveningPrepItem.self, UserSettings.self, AudioRecording.self], inMemory: true)
}
