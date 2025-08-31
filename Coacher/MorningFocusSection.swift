//
//  MorningFocusSection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct MorningFocusSection: View {
    @Binding var entry: DailyEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Morning Focus (10 minutes)")
                .font(.title3)
                .bold()
            
            // Step 1 – My Why
            VStack(alignment: .leading, spacing: 8) {
                Text("Step 1 – My Why (2 minutes)")
                    .bold()
                TextEditor(text: $entry.myWhy)
                    .frame(minHeight: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                    .padding(.horizontal, 4)
            }
            
            // Step 2 – Identify a Challenge
            VStack(alignment: .leading, spacing: 8) {
                Text("Step 2 – Identify a Challenge (3 minutes)")
                    .bold()
                Picker("Challenge", selection: $entry.challenge) {
                    ForEach(Challenge.allCases) { challenge in
                        Text(challenge.displayName)
                            .tag(challenge)
                    }
                }
                .pickerStyle(.menu)
                
                if entry.challenge == .other {
                    TextField("Describe the challenge…", text: $entry.challengeOther, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                }
            }
            
            // Step 3 – Choose My Swap
            VStack(alignment: .leading, spacing: 8) {
                Text("Step 3 – Choose My Swap (3 minutes)")
                    .bold()
                TextField("What healthier choice will I do instead?", text: $entry.chosenSwap, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
            }
            
            // Step 4 – Commit
            VStack(alignment: .leading, spacing: 8) {
                Text("Step 4 – Commit (2 minutes)")
                    .bold()
                Text("Today I will … instead of …")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    TextField("do this…", text: $entry.commitTo, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...2)
                    
                    Text("instead of")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("not this…", text: $entry.commitFrom, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    MorningFocusSection(entry: .constant(DailyEntry()))
}
