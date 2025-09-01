//
//  Color+Extensions.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let brandBlue = Color(hex: "0C2F89")
    static let leafGreen = Color(hex: "5CB85C")
    static let leafYellow = Color(hex: "FFD54F")
    static let brightYellow = Color(hex: "FFC107") // Brighter yellow for better visibility in light mode
    static let stressOrange = Color(hex: "FF8C00") // Orange color for stress/emotional cards
    
    // MARK: - Light Mode Colors
    static let lightBackground = Color(hex: "FAFAFA")
    static let textLight = Color(hex: "1C1C1E")
    
    // MARK: - Dark Mode Colors
    static let darkBackground = Color(hex: "0A1B3D")
    static let textDarkPrimary = Color.white
    static let textDarkSecondary = Color(hex: "B0BEC5")
    
    // MARK: - Semantic Colors
    static let success = leafGreen
    static let highlight = leafYellow
    static let primary = brandBlue
    
    // MARK: - Dynamic Colors (adapts to light/dark mode)
    static let dynamicBackground = Color(.systemBackground)
    static let dynamicCardBackground = Color(.secondarySystemBackground)
    static let dynamicText = Color(.label)
    static let dynamicSecondaryText = Color(.secondaryLabel)
    
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
