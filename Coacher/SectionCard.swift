//
//  SectionCard.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct SectionCard<Content: View>: View {
    enum Accent {
        case blue, purple, teal, gray
    }
    
    let title: String
    let icon: String?
    let accent: Accent
    @Binding var collapsed: Bool
    var dimmed: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            // Header with integrated title and chevron
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title).font(.headline)
                Spacer()
                Image(systemName: collapsed ? "chevron.down" : "chevron.up")
                    .font(.subheadline)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(headerForeground)
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(headerBackground)
            .clipShape(.rect(cornerRadius: 16, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(.snappy) { collapsed.toggle() } }

            // Content integrated into the same card background
            if !collapsed {
                VStack(alignment: .leading, spacing: 12) {
                    content
                }
                .padding(14)
                .padding(.top, 0) // Reduce top padding to connect with header
            }
        }
        .background(headerBackground) // Single background for entire card
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .overlay( // dim whole card if "past"
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(dimmed ? 0.05 : 0))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(title))
    }

    // MARK: - Colors
    private var headerBackground: some ShapeStyle {
        switch accent {
        case .blue:
            return Color.brandBlue.opacity(0.15).gradient
        case .purple:
            return Color.brandBlue.opacity(0.12).gradient
        case .teal:
            return Color.leafGreen.opacity(0.15).gradient
        case .gray:
            return Color.dynamicSecondaryText.opacity(0.14).gradient
        }
    }
    
    private var headerForeground: Color {
        switch accent {
        case .blue:
            // Use brighter blue for dark mode to make text pop
            return colorScheme == .dark ? Color(hex: "4A90E2") : .brandBlue
        case .purple:
            return .brandBlue
        case .teal:
            return .leafGreen
        case .gray:
            return .dynamicSecondaryText
        }
    }
    
    private var cardBackground: some ShapeStyle {
        Color.dynamicCardBackground
    }
    
    private var borderColor: Color {
        switch accent {
        case .blue:
            return Color.brandBlue.opacity(0.25)
        case .purple:
            return Color.brandBlue.opacity(0.20)
        case .teal:
            return Color.leafGreen.opacity(0.25)
        case .gray:
            return Color.dynamicSecondaryText.opacity(0.22)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Active section (blue)
        SectionCard(
            title: "Morning Focus (Today)",
            icon: "sun.max.fill",
            accent: .blue,
            collapsed: .constant(false),
            dimmed: false
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Step 1 – My Why (2 minutes)").font(.subheadline).bold()
                TextEditor(text: .constant("Sample why text"))
                    .frame(minHeight: 80)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary))
            }
        }
        
        // Past section (purple, dimmed)
        SectionCard(
            title: "Last Night's Prep (for Today)",
            icon: "moon.stars.fill",
            accent: .purple,
            collapsed: .constant(true),
            dimmed: true
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("No prep was done last night")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        
        // Evening section (teal)
        SectionCard(
            title: "End-of-Day Check-In",
            icon: "clock.fill",
            accent: .teal,
            collapsed: .constant(false),
            dimmed: false
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("How did today go?")
                    .font(.subheadline)
                    .bold()
                Text("Sample end-of-day content")
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding()
}
