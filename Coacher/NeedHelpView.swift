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
    @State private var selectedType: CravingType?
    @State private var showingMiniCoach = false {
        didSet {
            print("🔍 DEBUG: showingMiniCoach changed to: \(showingMiniCoach)")
        }
    }
    
    var body: some View {
        NavigationView {
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
                            showingMiniCoach = true
                            print("🔍 DEBUG: selectedType set to: \(selectedType), showingMiniCoach: \(showingMiniCoach)")
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
            .navigationBarHidden(true)
            .sheet(isPresented: $showingMiniCoach) {
                if let type = selectedType {
                    VStack {
                        Text("Test Sheet - Type: \(type.displayName)")
                            .font(.title)
                            .padding()
                        
                        Button("Close") {
                            showingMiniCoach = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
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
                    .foregroundStyle(type.color)
                    .frame(width: 30)
                    .onAppear {
                        print("🔍 DEBUG: CategoryButton - type: \(type), icon: \(type.icon), color: \(type.color)")
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .onAppear {
                            print("🔍 DEBUG: CategoryButton - displayName: '\(type.displayName)'")
                        }
                    
                    Text(type.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .onAppear {
                            print("🔍 DEBUG: CategoryButton - description: '\(type.description)'")
                        }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
