//
//  SectionCard.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct SectionCard<Content: View>: View {
    enum Accent { case blue, purple, teal, gray }
    let title: String
    let icon: String?
    let accent: Accent
    @Binding var collapsed: Bool
    var dimmed: Bool = false
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            // Header strip
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

            // Content (connected to header via a subtle border + same card)
            if !collapsed {
                VStack(alignment: .leading, spacing: 12) {
                    content
                }
                .padding(14)
                .background(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
                .clipShape(.rect(cornerRadius: 16, style: .continuous))
                .overlay( // soft shadow below only
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black.opacity(0.04))
                        .blur(radius: 0.5)
                        .offset(y: 1)
                        .allowsHitTesting(false)
                )
            }
        }
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
        case .blue:   return Color.blue.opacity(0.15).gradient
        case .purple: return Color.purple.opacity(0.16).gradient
        case .teal:   return Color.teal.opacity(0.16).gradient
        case .gray:   return Color.gray.opacity(0.14).gradient
        }
    }
    private var headerForeground: Color {
        switch accent {
        case .blue:   return .blue
        case .purple: return .purple
        case .teal:   return .teal
        case .gray:   return .secondary
        }
    }
    private var cardBackground: some ShapeStyle {
        Color(.systemBackground)
    }
    private var borderColor: Color {
        switch accent {
        case .blue:   return Color.blue.opacity(0.25)
        case .purple: return Color.purple.opacity(0.25)
        case .teal:   return Color.teal.opacity(0.25)
        case .gray:   return Color.gray.opacity(0.22)
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
