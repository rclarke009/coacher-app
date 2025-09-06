//
//  PrepTonightSection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct PrepTonightSection: View {
    @Environment(\.modelContext) private var context
    @Binding var entry: DailyEntry
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var newOtherItem = ""
    @State private var refreshTrigger = false
    @State private var showingPrepSuggestions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with title and info button
            HStack {
                Text("Night Prep (5 minutes)")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button(action: { showingPrepSuggestions = true }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .brightBlue : .brandBlue)
                }
            }
            
            // Default prep items (reordered as requested)
            VStack(alignment: .leading, spacing: 12) {
                // Water bottle first (everyone needs water)
                HStack {
                    Image(systemName: entry.waterReady ? "checkmark.square.fill" : "square")
                        .foregroundColor(.leafGreen)
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
                        .foregroundColor(.leafGreen)
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
                        .foregroundColor(.leafGreen)
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
                        .foregroundColor(.leafGreen)
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
            if !entry.safeCustomPrepItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Items")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    ForEach(entry.safeCustomPrepItems, id: \.self) { item in
                        HStack {
                            Image(systemName: entry.safeCompletedCustomPrepItems.contains(item) ? "checkmark.square.fill" : "square")
                                .foregroundColor(.leafGreen)
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
                // TextField("Add custom prep item...", text: $newOtherItem)
                //     .textFieldStyle(.roundedBorder)
                //     .foregroundColor(colorScheme == .dark ? .white : .primary)
                //     .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $newOtherItem)
                        .frame(minHeight: 60)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                        .background(colorScheme == .dark ? Color.darkTextInputBackground : Color.clear)
                        .padding(0)
                    
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
                    )
                    
                    if newOtherItem.isEmpty {
                        Text(" Add custom prep item...")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                            .allowsHitTesting(false)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color(.systemGray2), lineWidth: 0.5)
                )



                Button(action: addCustomItem) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(colorScheme == .dark ? .brightBlue : .leafGreen)
                        .font(.title2)
                }
                .disabled(newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .id(refreshTrigger) // Force UI refresh when needed
        .sheet(isPresented: $showingPrepSuggestions) {
            NightPrepSuggestionsView()
        }
    }
    
    // MARK: - Custom Item Management
    
    private func addCustomItem() {
        let trimmedItem = newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedItem.isEmpty else { return }
        

        
        // Add to DailyEntry's custom prep items (so it stays visible)
        if entry.customPrepItems == nil {
            entry.customPrepItems = []
        }
        entry.customPrepItems?.append(trimmedItem)
        
        // Also mark it as completed initially
        if entry.completedCustomPrepItems == nil {
            entry.completedCustomPrepItems = []
        }
        entry.completedCustomPrepItems?.append(trimmedItem)
        
        // Clear the input
        newOtherItem = ""
        

        
        // Save the context
        try? context.save()

        
        // Force UI refresh
        refreshTrigger.toggle()

    }
    
    private func toggleCustomItem(_ item: String) {
        if entry.safeCompletedCustomPrepItems.contains(item) {
            entry.completedCustomPrepItems?.removeAll { $0 == item }

        } else {
            if entry.completedCustomPrepItems == nil {
                entry.completedCustomPrepItems = []
            }
            entry.completedCustomPrepItems?.append(item)

        }
        
        // Save the context
        try? context.save()

        
        // Force UI refresh
        refreshTrigger.toggle()
    }
    
    private func deleteCustomItems(offsets: IndexSet) {
        let itemsToDelete = offsets.map { entry.safeCustomPrepItems[$0] }
        
        // Remove from both arrays
        entry.customPrepItems?.remove(atOffsets: offsets)
        for item in itemsToDelete {
            entry.completedCustomPrepItems?.removeAll { $0 == item }
        }
        

        
        // Save the context
        try? context.save()

        
        // Force UI refresh
        refreshTrigger.toggle()
    }
}


#Preview {
    PrepTonightSection(entry: .constant(DailyEntry()))
        .padding()
}
