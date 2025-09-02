//
//  ContentView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var notificationHandler: NotificationHandler
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineScreen()
                .tabItem { Label("Today", systemImage: "calendar") }
                .tag(0)
            CoachView()
                .tabItem { Label("Coach", systemImage: "message") }
                .tag(1)
            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
                .tag(2)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
        }
        .accentColor(.leafGreen)
        .onReceive(notificationHandler.$shouldShowTab) { tabIndex in
            if tabIndex != 0 { // Only change if it's not the default value
                selectedTab = tabIndex
                notificationHandler.shouldShowTab = 0 // Reset
            }
        }
        .overlay(
            // Status bar cover - tiny strip to hide distracting system elements
            VStack {
                Rectangle()
                    .fill(Color(hex: "e7f7fd"))
                    .frame(height: 50) // Covers status bar area
                    .ignoresSafeArea(.all, edges: .top)
                Spacer()
            }
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self, EveningPrepItem.self, UserSettings.self, AudioRecording.self], inMemory: true)
}
