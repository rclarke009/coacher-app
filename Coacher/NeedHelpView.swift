//
//  NeedHelpView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct NeedHelpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var selectedType: CravingType? {
        didSet {
            print("🔍 DEBUG: selectedType changed to: \(selectedType)")
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("I Need Help")
                    .font(.largeTitle)
                    .bold()
                
                Text("What's happening right now? Choose the category that best describes your situation.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top)
            
            // Category Selection
            VStack(spacing: 16) {
                ForEach(CravingType.allCases) { type in
                    CategoryButton(type: type) {
                        print("🔍 DEBUG: Button tapped for type: \(type)")
                        selectedType = type
                        print("🔍 DEBUG: selectedType set to: \(selectedType)")
                    }
                }
            }
            .onAppear {
                print("🔍 DEBUG: NeedHelpView - CravingType.allCases: \(CravingType.allCases)")
                for type in CravingType.allCases {
                    print("🔍 DEBUG: NeedHelpView - type: \(type), displayName: '\(type.displayName)', icon: '\(type.icon)', color: \(type.color)")
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Cancel Button
            Button("Cancel", action: { dismiss() })
                .foregroundStyle(.secondary)
                .padding(.bottom)
        }
        .sheet(item: $selectedType) { type in
            MiniCoachView(type: type, onComplete: { cravingNote in
                print("🔍 DEBUG: MiniCoachView completed with note: \(cravingNote)")
                saveCravingNote(cravingNote)
                dismiss()
            })
        }
    }
    
    private func saveCravingNote(_ note: CravingNote) {
        // TODO: Get current day's entry and add the craving note
        context.insert(note)
        try? context.save()
    }
}

struct CategoryButton: View {
    let type: CravingType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(type.color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NeedHelpView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self, CravingNote.self], inMemory: true)
}
