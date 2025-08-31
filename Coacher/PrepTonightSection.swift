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
    
    @State private var newOtherItem = ""
    @State private var showingEveningPrepManager = false
    
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
                Toggle("Put sticky notes where I usually grab the less-healthy choice", isOn: $entry.stickyNotes)
                Toggle("Wash/cut veggies or fruit and place them at eye level", isOn: $entry.preppedProduce)
                Toggle("Put water bottle in fridge or by my bed", isOn: $entry.waterReady)
                Toggle("Prep quick breakfast/snack", isOn: $entry.breakfastPrepped)
            }
            
            // Custom prep items
            if !entry.customEveningPrepItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Items:")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.secondary)
                    
                    ForEach(entry.customEveningPrepItems, id: \.self) { item in
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
        
        if !entry.customEveningPrepItems.contains(trimmedItem) {
            entry.customEveningPrepItems.append(trimmedItem)
            newOtherItem = ""
            
            // Save to database
            try? context.save()
        }
    }
    
    private func removeCustomItem(_ item: String) {
        entry.customEveningPrepItems.removeAll { $0 == item }
        
        // Save to database
        try? context.save()
    }
}

#Preview {
    PrepTonightSection(entry: .constant(DailyEntry()))
        .padding()
}
