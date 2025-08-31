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
    
    @State private var newOtherItem = ""
    @State private var refreshTrigger = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Night Prep (5 minutes)")
                    .font(.title3)
                    .bold()
                
                Spacer()
            }
            
            // Default prep items (reordered as requested)
            VStack(alignment: .leading, spacing: 12) {
                // Water bottle first (everyone needs water)
                HStack {
                    Image(systemName: entry.waterReady ? "checkmark.square.fill" : "square")
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            entry.waterReady.toggle()
                        }
                    Text("Water bottle ready")
                        .onTapGesture {
                            entry.waterReady.toggle()
                        }
                }
                
                // Prep easy breakfast/snack second
                HStack {
                    Image(systemName: entry.breakfastPrepped ? "checkmark.square.fill" : "square")
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            entry.breakfastPrepped.toggle()
                        }
                    Text("Prep easy breakfast/snack")
                        .onTapGesture {
                            entry.breakfastPrepped.toggle()
                        }
                }
                
                // Other default items
                HStack {
                    Image(systemName: entry.stickyNotes ? "checkmark.square.fill" : "square")
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            entry.stickyNotes.toggle()
                        }
                    Text("Sticky notes for tomorrow")
                        .onTapGesture {
                            entry.stickyNotes.toggle()
                        }
                }
                
                HStack {
                    Image(systemName: entry.preppedProduce ? "checkmark.square.fill" : "square")
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            entry.preppedProduce.toggle()
                        }
                    Text("Prepped produce")
                        .onTapGesture {
                            entry.preppedProduce.toggle()
                        }
                }
            }
            
            // Custom prep items
            if !entry.completedCustomPrepItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    ForEach(entry.completedCustomPrepItems, id: \.self) { item in
                        HStack {
                            Image(systemName: entry.completedCustomPrepItems.contains(item) ? "checkmark.square.fill" : "square")
                                .foregroundStyle(.blue)
                                .onTapGesture {
                                    toggleCustomItem(item)
                                }
                            Text(item)
                                .onTapGesture {
                                    toggleCustomItem(item)
                                }
                        }
                    }
                    .onDelete(perform: deleteCustomItems)
                }
            }
            
            // Add new custom item
            HStack {
                TextField("Add custom prep item...", text: $newOtherItem)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: addCustomItem) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
                .disabled(newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .id(refreshTrigger) // Force UI refresh when needed
    }
    
    // MARK: - Custom Item Management
    
    private func addCustomItem() {
        let trimmedItem = newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedItem.isEmpty else { return }
        
        print("🔍 DEBUG: NightPrepSection - Adding custom item: '\(trimmedItem)'")
        print("🔍 DEBUG: NightPrepSection - Current custom items: \(entry.completedCustomPrepItems.count)")
        
        // Add to DailyEntry's custom prep items
        entry.completedCustomPrepItems.append(trimmedItem)
        
        // Clear the input
        newOtherItem = ""
        
        print("🔍 DEBUG: NightPrepSection - After adding, custom items: \(entry.completedCustomPrepItems.count)")
        print("🔍 DEBUG: NightPrepSection - Custom items array: \(entry.completedCustomPrepItems)")
        
        // Save the context
        try? context.save()
        print("🔍 DEBUG: NightPrepSection - Context saved")
        
        // Force UI refresh
        refreshTrigger.toggle()
        print("🔍 DEBUG: NightPrepSection - Refresh triggered: \(refreshTrigger)")
    }
    
    private func toggleCustomItem(_ item: String) {
        if entry.completedCustomPrepItems.contains(item) {
            entry.completedCustomPrepItems.removeAll { $0 == item }
            print("🔍 DEBUG: NightPrepSection - Toggled custom item: \(item), now checked: false")
        } else {
            entry.completedCustomPrepItems.append(item)
            print("🔍 DEBUG: NightPrepSection - Toggled custom item: \(item), now checked: true")
        }
        
        // Save the context
        try? context.save()
        print("🔍 DEBUG: NightPrepSection - Context saved after toggle")
        
        // Force UI refresh
        refreshTrigger.toggle()
    }
    
    private func deleteCustomItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { entry.completedCustomPrepItems[$0] }
        entry.completedCustomPrepItems.remove(atOffsets: offsets)
        
        print("🔍 DEBUG: NightPrepSection - Deleted custom items: \(itemsToDelete)")
        
        // Save the context
        try? context.save()
        print("🔍 DEBUG: NightPrepSection - Context saved after delete")
        
        // Force UI refresh
        refreshTrigger.toggle()
    }
}

#Preview {
    NightPrepSection(entry: .constant(DailyEntry()))
}
