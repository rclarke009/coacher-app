//
//  NightPrepSection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct NightPrepSection: View {
    @Binding var entry: DailyEntry
    @Environment(\.modelContext) private var context
    @Query private var userSettings: [UserSettings]
    
    @State private var newOtherItem = ""
    
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
                Text("Night Prep (5 minutes)")
                    .font(.title3)
                    .bold()
                
                Spacer()
            }
            
            // Default prep items
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: entry.waterReady ? "checkmark.square.fill" : "square")
                        .foregroundStyle(entry.waterReady ? .blue : .secondary)
                        .onTapGesture {
                            entry.waterReady.toggle()
                        }
                    Text("Put water bottle in fridge or by my bed")
                        .onTapGesture {
                            entry.waterReady.toggle()
                        }
                    Spacer()
                }
                
                HStack {
                    Image(systemName: entry.breakfastPrepped ? "checkmark.square.fill" : "square")
                        .foregroundStyle(entry.breakfastPrepped ? .blue : .secondary)
                        .onTapGesture {
                            entry.breakfastPrepped.toggle()
                        }
                    Text("Prep quick breakfast/snack")
                        .onTapGesture {
                            entry.breakfastPrepped.toggle()
                        }
                    Spacer()
                }
                
                HStack {
                    Image(systemName: entry.stickyNotes ? "checkmark.square.fill" : "square")
                        .foregroundStyle(entry.stickyNotes ? .blue : .secondary)
                        .onTapGesture {
                            entry.stickyNotes.toggle()
                        }
                    Text("Put sticky notes where I usually grab the less-healthy choice")
                        .onTapGesture {
                            entry.stickyNotes.toggle()
                        }
                    Spacer()
                }
                
                HStack {
                    Image(systemName: entry.preppedProduce ? "checkmark.square.fill" : "square")
                        .foregroundStyle(entry.preppedProduce ? .blue : .secondary)
                        .onTapGesture {
                            entry.preppedProduce.toggle()
                        }
                    Text("Wash/cut veggies or fruit and place them at eye level")
                        .onTapGesture {
                            entry.preppedProduce.toggle()
                        }
                    Spacer()
                }
            }
            
            // Custom prep items (no visual separation - equally important)
            if !settings.customEveningPrepItems.isEmpty {
                List {
                    ForEach(settings.customEveningPrepItems, id: \.self) { item in
                        HStack {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundStyle(.blue)
                                .onTapGesture {
                                    // For now, always enabled - could add individual tracking later
                                }
                            Text(item)
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteCustomItems)
                }
                .listStyle(.plain)
                .frame(minHeight: CGFloat(settings.customEveningPrepItems.count * 44)) // Adjust height based on content
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )

    }
    
    private func addCustomItem() {
        let trimmedItem = newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedItem.isEmpty else { return }
        
        print("🔍 DEBUG: Adding custom item: '\(trimmedItem)'")
        print("🔍 DEBUG: Current settings has \(settings.customEveningPrepItems.count) items")
        
        settings.addCustomItem(trimmedItem)
        newOtherItem = ""
        
        print("🔍 DEBUG: After adding, settings has \(settings.customEveningPrepItems.count) items")
        print("🔍 DEBUG: Items: \(settings.customEveningPrepItems)")
        
        // Save to database
        try? context.save()
        print("🔍 DEBUG: Context saved")
    }
    
    private func deleteCustomItems(at offsets: IndexSet) {
        for index in offsets {
            let item = settings.customEveningPrepItems[index]
            settings.removeCustomItem(item)
        }
        
        // Save to database
        try? context.save()
    }
}

#Preview {
    NightPrepSection(entry: .constant(DailyEntry()))
}
