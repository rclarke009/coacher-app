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
                .font(.title3)
                .bold()
            
            Toggle("I followed my swap", isOn: Binding(
                get: { entry.followedSwap ?? false },
                set: { entry.followedSwap = $0 }
            ))
            
            if entry.followedSwap == true {
                TextField("If yes, how do I feel about it?", text: $entry.feelAboutIt, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .submitLabel(.done)
            } else if entry.followedSwap == false {
                TextField("If no, what got in the way?", text: $entry.whatGotInTheWay, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .submitLabel(.done)
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
    EndOfDaySection(entry: .constant(DailyEntry()))
}
