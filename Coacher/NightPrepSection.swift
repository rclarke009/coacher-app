//
//  NightPrepSection.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct NightPrepSection: View {
    @Binding var entry: DailyEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Night Prep (5 minutes)")
                .font(.title3)
                .bold()
            
            Toggle("Put sticky notes where I usually grab the less-healthy choice", isOn: $entry.stickyNotes)
            
            Toggle("Wash/cut veggies or fruit and place them at eye level", isOn: $entry.preppedProduce)
            
            Toggle("Put water bottle in fridge or by my bed", isOn: $entry.waterReady)
            
            Toggle("Prep quick breakfast/snack", isOn: $entry.breakfastPrepped)
            
            TextField("Other…", text: $entry.nightOther, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NightPrepSection(entry: .constant(DailyEntry()))
}
