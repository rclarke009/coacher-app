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
    @State private var refreshTrigger = false // Force UI refresh
    @State private var localCustomItems: [String] = [] // Local state for custom items
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Prep Tonight (5 minutes)")
                    .font(.subheadline)
                    .bold()
                
                Spacer()
            }
            
            // Default prep items
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Put water bottle in fridge or by my bed", isOn: $entry.waterReady)
                Toggle("Prep quick breakfast/snack", isOn: $entry.breakfastPrepped)
                Toggle("Put sticky notes where I usually grab the less-healthy choice", isOn: $entry.stickyNotes)
                Toggle("Wash/cut veggies or fruit and place them at eye level", isOn: $entry.preppedProduce)
            }
            
            // Custom prep items (no visual separation - equally important)
            if !localCustomItems.isEmpty {
                List {
                    ForEach(localCustomItems, id: \.self) { item in
                        HStack {
                            Toggle(item, isOn: .constant(true)) // For now, always enabled
                                .toggleStyle(.button)
                                .buttonStyle(.plain)
                            
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteCustomItems)
                }
                .listStyle(.plain)
                .frame(minHeight: CGFloat(localCustomItems.count * 44)) // Adjust height based on content
                .onAppear {
                    print("🔍 DEBUG: PrepTonightSection - Custom items displayed: \(localCustomItems.count) items")
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
        .id(refreshTrigger) // Force view refresh when refreshTrigger changes
        .onAppear {
            // Debug @Query state
            print("🔍 DEBUG: PrepTonightSection - onAppear: @Query has \(userSettings.count) UserSettings objects")
            if !userSettings.isEmpty {
                print("🔍 DEBUG: PrepTonightSection - onAppear: First UserSettings has \(userSettings[0].customEveningPrepItems.count) items")
                print("🔍 DEBUG: PrepTonightSection - onAppear: First UserSettings ID: \(userSettings[0].id)")
            }
            
            // Load custom items from settings into local state
            // Force a fresh fetch from the database
            if let currentSettings = userSettings.first {
                localCustomItems = currentSettings.customEveningPrepItems
                print("🔍 DEBUG: PrepTonightSection - onAppear: loaded \(localCustomItems.count) custom items from database")
                print("🔍 DEBUG: PrepTonightSection - onAppear: items: \(localCustomItems)")
            } else {
                print("🔍 DEBUG: PrepTonightSection - onAppear: no UserSettings found")
                localCustomItems = []
            }
        }

    }
    
    private func addCustomItem() {
        let trimmedItem = newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedItem.isEmpty else { return }
        
        print("🔍 DEBUG: PrepTonightSection - Adding custom item: '\(trimmedItem)'")
        print("🔍 DEBUG: PrepTonightSection - Current local items: \(localCustomItems.count)")
        
        // Get or create UserSettings object
        let currentSettings: UserSettings
        if let existing = userSettings.first {
            currentSettings = existing
            print("🔍 DEBUG: PrepTonightSection - Using existing UserSettings with \(existing.customEveningPrepItems.count) items")
        } else {
            // Create new UserSettings if none exist
            currentSettings = UserSettings()
            context.insert(currentSettings)
            print("🔍 DEBUG: PrepTonightSection - Created new UserSettings")
            
            // Force an immediate save to ensure the object is tracked
            try? context.save()
            print("🔍 DEBUG: PrepTonightSection - Initial context save after creating UserSettings")
        }
        
        // Add to the UserSettings object
        currentSettings.addCustomItem(trimmedItem)
        print("🔍 DEBUG: PrepTonightSection - Added to UserSettings, now has \(currentSettings.customEveningPrepItems.count) items")
        
        // Update local state immediately for UI
        localCustomItems.append(trimmedItem)
        
        newOtherItem = ""
        
        print("🔍 DEBUG: PrepTonightSection - After adding, local items: \(localCustomItems.count)")
        print("🔍 DEBUG: PrepTonightSection - Local items array: \(localCustomItems)")
        
        // Save to database with a slight delay to ensure proper tracking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try? self.context.save()
            print("🔍 DEBUG: PrepTonightSection - Delayed context save completed")
            
            // Force another save to ensure persistence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                try? self.context.save()
                print("🔍 DEBUG: PrepTonightSection - Second delayed context save completed")
                
                // Verify the object was saved by fetching again
                let descriptor = FetchDescriptor<UserSettings>()
                do {
                    let results = try self.context.fetch(descriptor)
                    print("🔍 DEBUG: PrepTonightSection - Verification fetch found \(results.count) UserSettings objects")
                    if let first = results.first {
                        print("🔍 DEBUG: PrepTonightSection - Verification: first object has \(first.customEveningPrepItems.count) items")
                    }
                } catch {
                    print("🔍 DEBUG: PrepTonightSection - Verification fetch error: \(error)")
                }
            }
        }
        print("🔍 DEBUG: PrepTonightSection - Context save initiated")
        
        // Force UI refresh since SwiftData @Query isn't updating automatically
        refreshTrigger.toggle()
        print("🔍 DEBUG: PrepTonightSection - Refresh triggered: \(refreshTrigger)")
    }
    
    private func deleteCustomItems(at offsets: IndexSet) {
        print("🔍 DEBUG: PrepTonightSection - Deleting custom items at offsets: \(offsets)")
        print("🔍 DEBUG: PrepTonightSection - Current local items: \(localCustomItems.count)")
        
        // Get UserSettings object (should exist if we're deleting items)
        if let currentSettings = userSettings.first {
            // Remove from the UserSettings object
            let itemsToRemove = offsets.map { localCustomItems[$0] }
            currentSettings.removeCustomItems(itemsToRemove)
            print("🔍 DEBUG: PrepTonightSection - Removed from UserSettings, now has \(currentSettings.customEveningPrepItems.count) items")
        } else {
            print("🔍 DEBUG: PrepTonightSection - WARNING: No UserSettings found to remove items from")
        }
        
        // Update local state immediately for UI
        localCustomItems.remove(atOffsets: offsets)
        
        print("🔍 DEBUG: PrepTonightSection - After deleting, local items: \(localCustomItems.count)")
        
        // Save to database
        try? context.save()
        print("🔍 DEBUG: PrepTonightSection - Context saved after deletion")
    }
}

#Preview {
    PrepTonightSection(entry: .constant(DailyEntry()))
        .padding()
}
