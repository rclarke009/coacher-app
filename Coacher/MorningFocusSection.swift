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
        VStack(alignment: .leading, spacing: 12) {
            // Step 1 – My Why
            Text("Step 1 – My Why (2 minutes)")
                .font(.subheadline)
                .bold()
            TextEditor(text: $entry.myWhy)
                .frame(minHeight: 80)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))

            // Step 2 – Identify a Challenge
            Text("Step 2 – Identify a Challenge (3 minutes)")
                .font(.subheadline)
                .bold()
            Menu {
                Button("Skipping meals") { entry.challenge = .skippingMeals }
                Button("Late-night snacking") { entry.challenge = .lateNightSnacking }
                Button("Sugary drinks") { entry.challenge = .sugaryDrinks }
                Button("Eating on the go / fast food") { entry.challenge = .onTheGo }
                Button("Emotional eating") { entry.challenge = .emotionalEating }
                Button("Other") { entry.challenge = .other }
            } label: {
                HStack {
                    Text(entry.challenge == .none ? "Select…" : entry.challenge.displayName)
                        .foregroundColor(entry.challenge == .none ? .leafYellow : .dynamicText)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.leafYellow)
                        .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.leafYellow, lineWidth: 2)
                        .background(Color.dynamicCardBackground)
                )
            }

            if entry.challenge == .other {
                TextField("Describe the challenge…", text: $entry.challengeOther)
                    .textFieldStyle(.roundedBorder)
            }

            // Step 3 – Choose My Swap
            Text("Step 3 – Choose My Swap (3 minutes)")
                .font(.subheadline)
                .bold()
            TextField("What healthier choice will I do instead?", text: $entry.chosenSwap)
                .textFieldStyle(.roundedBorder)

            // Step 4 – Commit
            Text("Step 4 – Commit (2 minutes)")
                .font(.subheadline)
                .bold()
            Text("Today I will … instead of …")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                TextField("do this…", text: $entry.commitTo)
                Text("instead of")
                TextField("not this…", text: $entry.commitFrom)
            }
            .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    MorningFocusSection(entry: .constant(DailyEntry()))
}
