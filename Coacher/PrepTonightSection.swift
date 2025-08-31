//
//  PrepTonightSection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct PrepTonightSection: View {
    @Binding var entry: DailyEntry
    @Environment(\.modelContext) private var context
    @Query private var userSettings: [UserSettings]
    
    @State private var newOtherItem = ""
    @State private var showingEveningPrepManager = false
    
    private var settings: UserSettings {
        if let existing = userSettings.first {
            return existing
        } else {
            let newSettings = UserSettings()
            context.insert(newSettings)
            try? context.save()
            return newSettings
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Prep Tonight (5 minutes)")
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Button(action: { showingEveningPrepManager = true }) {
                    Image(systemName: "gear")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            
            // Default prep items
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Put water bottle in fridge or by my bed", isOn: $entry.waterReady)
                Toggle("Prep quick breakfast/snack", isOn: $entry.breakfastPrepped)
                Toggle("Put sticky notes where I usually grab the less-healthy choice", isOn: $entry.stickyNotes)
                Toggle("Wash/cut veggies or fruit and place them at eye level", isOn: $entry.preppedProduce)
            }
            
            // Custom prep items (no visual separation - equally important)
            if !settings.customEveningPrepItems.isEmpty {
                ForEach(settings.customEveningPrepItems, id: \.self) { item in
                    HStack {
                        Toggle(item, isOn: .constant(true)) // For now, always enabled
                            .toggleStyle(.button)
                            .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button(action: {
                            removeCustomItem(item)
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onAppear {
                    print("🔍 DEBUG: PrepTonightSection - Custom items displayed: \(settings.customEveningPrepItems.count) items")
                }
            } else {
                Text("No custom items yet")
                    .foregroundStyle(.secondary)
                    .onAppear {
                        print("🔍 DEBUG: PrepTonightSection - No custom items to display")
                    }
            }
            
            // Add new custom item
            HStack {
                TextField("Add custom prep item...", text: $newOtherItem, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .submitLabel(.done)
                
                Button(action: addCustomItem) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .disabled(newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .sheet(isPresented: $showingEveningPrepManager) {
            EveningPrepManager()
        }
    }
    
    private func addCustomItem() {
        let trimmedItem = newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedItem.isEmpty else { return }
        
        print("🔍 DEBUG: PrepTonightSection - Adding custom item: '\(trimmedItem)'")
        print("🔍 DEBUG: PrepTonightSection - Current settings has \(settings.customEveningPrepItems.count) items")
        
        settings.addCustomItem(trimmedItem)
        newOtherItem = ""
        
        print("🔍 DEBUG: PrepTonightSection - After adding, settings has \(settings.customEveningPrepItems.count) items")
        print("🔍 DEBUG: PrepTonightSection - Items: \(settings.customEveningPrepItems)")
        
        // Save to database
        try? context.save()
        print("🔍 DEBUG: PrepTonightSection - Context saved")
    }
    
    private func removeCustomItem(_ item: String) {
        settings.removeCustomItem(item)
        
        // Save to database
        try? context.save()
    }
}

#Preview {
    PrepTonightSection(entry: .constant(DailyEntry()))
        .padding()
}
