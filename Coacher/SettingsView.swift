//
//  SettingsView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var celebrationManager: CelebrationManager
    @EnvironmentObject private var reminderManager: ReminderManager
    @EnvironmentObject private var hybridManager: HybridLLMManager
    @Environment(\.colorScheme) private var colorScheme
    @Query private var achievements: [Achievement]
    @StateObject private var mlcManager = SimplifiedMLCManager()
    @State private var showOnboarding = false
    @AppStorage("useCloudAI") private var useCloudAI = false
    
    @AppStorage("showStreakWidgets") private var showStreakWidgets = true
    @AppStorage("nightPrepReminder") private var nightPrepReminder = true
    @AppStorage("morningFocusReminder") private var morningFocusReminder = true
    @AppStorage("nightPrepTime") private var nightPrepTime = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    @AppStorage("morningFocusTime") private var morningFocusTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    
    var body: some View {
        NavigationView {
            List {
                Section("Reminders") {
                    Toggle("Night Prep Reminder", isOn: $nightPrepReminder)
                        .onChange(of: nightPrepReminder) { _, _ in
                            Task {
                                await reminderManager.updateReminders()
                            }
                        }
                    if nightPrepReminder {
                        DatePicker("Time", selection: $nightPrepTime, displayedComponents: .hourAndMinute)
                            .onChange(of: nightPrepTime) { _, _ in
                                Task {
                                    await reminderManager.updateReminders()
                                }
                            }
                    }
                    
                    Toggle("Morning Focus Reminder", isOn: $morningFocusReminder)
                        .onChange(of: morningFocusReminder) { _, _ in
                            Task {
                                await reminderManager.updateReminders()
                            }
                        }
                    if morningFocusReminder {
                        DatePicker("Time", selection: $morningFocusTime, displayedComponents: .hourAndMinute)
                            .onChange(of: morningFocusTime) { _, _ in
                                Task {
                                    await reminderManager.updateReminders()
                                }
                            }
                    }
                    

                }
                
                Section("AI Coach") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AI Mode")
                                    .font(.headline)
                                Text(useCloudAI ? "Enhanced Cloud Coach" : "Local Coach")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: $useCloudAI)
                                .labelsHidden()
                                .onChange(of: useCloudAI) { _ in
                                    Task {
                                        await hybridManager.updateAIMode()
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            if useCloudAI {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: "cloud.fill")
                                            .foregroundColor(.blue)
                                        Text("Enhanced Cloud Coach")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    Text("• Richer, more detailed conversations")
                                    Text("• Requires internet connection")
                                    Text("• Data sent to OpenAI servers")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            } else {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.green)
                                        Text("Local Coach")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    Text("• Fast, private, and secure")
                                    Text("• Works offline (airplane mode)")
                                    Text("• Data never leaves your device")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Personalization") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your name", text: Binding(
                            get: { UserDefaults.standard.string(forKey: "userName") ?? "" },
                            set: { UserDefaults.standard.set($0, forKey: "userName") }
                        ))
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(colorScheme == .dark ? .white : .secondary)
                        .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
                        .accessibilityLabel("Name")
                        .accessibilityHint("Enter your name for personalization")
                    }
                    
                    Button(action: {
                        print("🔄 DEBUG: Replay Onboarding button tapped")
                        showOnboarding = true
                        print("🔄 DEBUG: showOnboarding set to true")
                    }) {
                        Text("Replay Onboarding")
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Replay Onboarding")
                    .accessibilityHint("Restart the app introduction and setup process")
                }
                
                Section("AI Configuration") {
                    HStack {
                        Text("OpenAI API Key")
                        Spacer()
                        TextField("sk-...", text: Binding(
                            get: { KeychainManager.shared.getOpenAIKey() ?? "" },
                            set: { 
                                if $0.isEmpty {
                                    _ = KeychainManager.shared.deleteOpenAIKey()
                                } else {
                                    _ = KeychainManager.shared.storeOpenAIKey($0)
                                }
                            }
                        ))
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(colorScheme == .dark ? .white : .secondary)
                        .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
                        .accessibilityLabel("OpenAI API Key")
                        .accessibilityHint("Enter your OpenAI API key for enhanced AI features")
                    }
                    
                    if useCloudAI {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Online AI enabled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Add API key to enable online AI features")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Gamification") {
                    Toggle("Show animations", isOn: $celebrationManager.animationsEnabled)
                    
                    Toggle("Show streak widgets", isOn: $showStreakWidgets)
                    
                    if !achievements.isEmpty {
                        HStack {
                            Text("Achievements earned")
                            Spacer()
                            Text("\(achievements.count)")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button("Reset achievements") {
                            resetAchievements()
                        }
                        .foregroundStyle(.red)
                    }
                }
                
                Section("AI Coach") {
                    HStack {
                        Text("Model Status")
                        Spacer()
                        Text(mlcManager.modelStatus)
                            .foregroundStyle(.secondary)
                    }
                    
                    if mlcManager.isModelLoaded {
                        HStack {
                            Text("Model")
                            Spacer()
                            Text("Llama-2-7B")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Quantization")
                            Spacer()
                            Text("Q4F16")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !mlcManager.isModelLoaded && !mlcManager.isLoading {
                        Button("Load Model") {
                            Task {
                                await mlcManager.loadModel()
                            }
                        }
                        .foregroundColor(.brandBlue)
                    }
                    
                    if mlcManager.errorMessage != nil {
                        Text(mlcManager.errorMessage ?? "")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                
                Section("Data & Privacy") {
                    Button("Export data") {
                        exportData()
                    }
                    .foregroundColor(.leafGreen)
                    
                    Button("Import data") {
                        importData()
                    }
                    .foregroundColor(.leafYellow)
                    
                    Button("Clear all data") {
                        clearAllData()
                    }
                    .foregroundStyle(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .background(
                Color.appBackground
                    .ignoresSafeArea(.all)
            )
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
                .onAppear {
                    print("🔄 DEBUG: OnboardingView fullScreenCover appeared")
                }
        }
    }
    
    private func resetAchievements() {
        // TODO: Show confirmation dialog
        for achievement in achievements {
            context.delete(achievement)
        }
        try? context.save()
    }
    
    private func exportData() {
        // TODO: Implement data export
    }
    
    private func importData() {
        // TODO: Implement data import
    }
    
    private func clearAllData() {
        // TODO: Show confirmation dialog and implement data clearing
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self], inMemory: true)
}
