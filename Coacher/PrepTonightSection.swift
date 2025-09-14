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
    @Binding var todayEntry: DailyEntry // Add today's entry to access whatGotInTheWay
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var reminderManager = ReminderManager.shared
    
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

                // Show reflection-based encouragement if user wrote about what got in the way
                if !todayEntry.whatGotInTheWay.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(getReflectionEncouragement())
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 4)
                } else {
                    // Show generic encouragement when no reflection text
                    Text("Let's do a prep to make tomorrow better.")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 4)
                }




                // Water bottle first (everyone needs water)
                HStack {
                    Image(systemName: entry.waterReady ? "checkmark.square.fill" : "square")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
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
                        .foregroundColor(colorScheme == .dark ? .white : .black)
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
                        .foregroundColor(colorScheme == .dark ? .white : .black)
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
                        .foregroundColor(colorScheme == .dark ? .white : .black)
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
                                .foregroundColor(colorScheme == .dark ? .white : .black)
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
                        .foregroundColor(colorScheme == .dark ? .brightBlue : .white)
                        .font(.title2)
                }
                .disabled(newOtherItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            // Show reflection-based encouragement if user wrote about what got in the way
            if !entry.whatGotInTheWay.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text(getReflectionEncouragement())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .id(refreshTrigger) // Force UI refresh when needed
        .onChange(of: todayEntry.whatGotInTheWay) { _, _ in 
            // Force UI refresh when user types in the "what got in the way" box
            refreshTrigger.toggle()
        }
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
    
    private func getReflectionEncouragement() -> String {
        let reflectionText = todayEntry.whatGotInTheWay.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let encouragementTemplates = [
            "You wrote: '\(reflectionText)'. Let's do a prep to make that better tomorrow.",
            "You mentioned: '\(reflectionText)'. Let's set up something tomorrow to help with that.",
            "Today you noticed: '\(reflectionText)'. What might make tomorrow smoother?",
            "You identified: '\(reflectionText)'. Let's prepare for a smoother day tomorrow.",
            "You reflected on: '\(reflectionText)'. Time to set yourself up for success!",
            "You recognized: '\(reflectionText)'. Let's make tomorrow different."
        ]
        
        // Use a simple hash of the reflection text to consistently pick the same template
        let hash = reflectionText.hashValue
        let templateIndex = abs(hash) % encouragementTemplates.count
        
        return encouragementTemplates[templateIndex]
    }
}


#Preview {
    PrepTonightSection(
        entry: .constant(DailyEntry()),
        todayEntry: .constant(DailyEntry())
    )
    .padding()
}
