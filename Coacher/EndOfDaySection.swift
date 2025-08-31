//
//  EndOfDaySection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct EndOfDaySection: View {
    @Binding var entry: DailyEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("End-of-Day Check-In (Optional)")
                .font(.subheadline)
                .bold()
            
            Toggle("I followed my swap", isOn: Binding(
                get: { entry.followedSwap ?? false },
                set: { entry.followedSwap = $0 }
            ))
            
            TextField("If yes, how do I feel about it?", text: $entry.feelAboutIt)
                .textFieldStyle(.roundedBorder)
            
            TextField("If no, what got in the way?", text: $entry.whatGotInTheWay)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    EndOfDaySection(entry: .constant(DailyEntry()))
}
