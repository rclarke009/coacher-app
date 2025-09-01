import SwiftUI

enum CelebrationStyle: String, CaseIterable, Identifiable {
    case calm = "calm"
    case playful = "playful"
    case off = "off"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .calm: return "✨ Calm"
        case .playful: return "🎉 Playful"
        case .off: return "🚫 Off"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .calm: return .teal
        case .playful: return .purple
        case .off: return .clear
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .calm: return .cyan
        case .playful: return .indigo
        case .off: return .clear
        }
    }
}

struct CelebrationOverlay: View {
    @Binding var isPresented: Bool
    let style: CelebrationStyle
    let title: String
    let subtitle: String
    
    @State private var sparkleProgress: CGFloat = 0.0
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    // Reset animation state when overlay appears
    private func resetAnimationState() {
        sparkleProgress = 0.0
        cardScale = 0.8
        cardOpacity = 0.0
        textOpacity = 0.0
    }
    
    var body: some View {
        if isPresented {
            GeometryReader { geometry in
                ZStack {
                // Full-screen dim background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissCelebration()
                    }
                
                // Success card
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(style.primaryColor)
                    
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            // Perimeter sparkle trail
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    style.primaryColor.opacity(0.6),
                                    lineWidth: 2
                                )
                                .overlay(
                                    // Traveling sparkle (more visible)
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [style.secondaryColor, style.primaryColor],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 12
                                            )
                                        )
                                        .frame(width: 24, height: 24)
                                        .blur(radius: 1)
                                        .offset(
                                            x: calculateSparkleX(progress: sparkleProgress),
                                            y: calculateSparkleY(progress: sparkleProgress)
                                        )
                                        .overlay(
                                            // Sparkle trail (more visible)
                                            ForEach(0..<6, id: \.self) { index in
                                                Circle()
                                                    .fill(style.secondaryColor.opacity(0.9))
                                                    .frame(width: 6, height: 6)
                                                    .blur(radius: 0.5)
                                                    .offset(
                                                        x: calculateSparkleX(progress: sparkleProgress - Double(index) * 0.08),
                                                        y: calculateSparkleY(progress: sparkleProgress - Double(index) * 0.08)
                                                    )
                                                    .opacity(1.0 - Double(index) * 0.15)
                                            }
                                        )
                                )
                        )
                )
                .scaleEffect(cardScale)
                .opacity(cardOpacity)
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
                }
            }
            .onAppear {
                resetAnimationState()
                startCelebration()
            }
        }
    }
    
    private func startCelebration() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Card entrance animation
        withAnimation(.easeOut(duration: 0.3)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        // Text fade in
        withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
            textOpacity = 1.0
        }
        
        // Perimeter sparkle animation (more visible)
        withAnimation(.easeInOut(duration: 3.0).delay(0.5)) {
            sparkleProgress = 1.0
        }
        
        // Debug: Print animation progress
        print("Celebration started - sparkleProgress will animate from 0.0 to 1.0 over 3 seconds")
        
        // Auto-dismiss after animation (extended time)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.4) {
            dismissCelebration()
        }
    }
    
    private func dismissCelebration() {
        withAnimation(.easeIn(duration: 0.3)) {
            cardScale = 0.8
            cardOpacity = 0.0
            textOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    // MARK: - Sparkle Path Calculations
    
    /// Calculates X position for sparkle traveling around rectangular border
    /// Sparkle starts from center (0,0) and travels around the frame edge
    private func calculateSparkleX(progress: CGFloat) -> CGFloat {
        let cardWidth: CGFloat = 240  // Approximate card width
        let cardHeight: CGFloat = 160 // Approximate card height
        let perimeter = 2 * (cardWidth + cardHeight)
        let distance = progress * perimeter
        
        // Top edge (0 to cardWidth) - start from center, go to top-right
        if distance < cardWidth {
            return distance - cardWidth/2
        }
        // Right edge (cardWidth to cardWidth + cardHeight) - go down right side
        else if distance < cardWidth + cardHeight {
            return cardWidth/2
        }
        // Bottom edge (cardWidth + cardHeight to 2*cardWidth + cardHeight) - go left along bottom
        else if distance < 2*cardWidth + cardHeight {
            return (2*cardWidth + cardHeight - distance) - cardWidth/2
        }
        // Left edge (2*cardWidth + cardHeight to perimeter) - go up left side
        else {
            return -cardWidth/2
        }
    }
    
    /// Calculates Y position for sparkle traveling around rectangular border
    /// Sparkle starts from center (0,0) and travels around the frame edge
    private func calculateSparkleY(progress: CGFloat) -> CGFloat {
        let cardWidth: CGFloat = 240  // Approximate card width
        let cardHeight: CGFloat = 160 // Approximate card height
        let perimeter = 2 * (cardWidth + cardHeight)
        let distance = progress * perimeter
        
        // Top edge (0 to cardWidth) - start from center, go to top-right
        if distance < cardWidth {
            return -cardHeight/2
        }
        // Right edge (cardWidth to cardWidth + cardHeight) - go down right side
        else if distance < cardWidth + cardHeight {
            return (distance - cardWidth) - cardHeight/2
        }
        // Bottom edge (cardWidth + cardHeight to 2*cardWidth + cardHeight) - go left along bottom
        else if distance < 2*cardWidth + cardHeight {
            return cardHeight/2
        }
        // Left edge (2*cardWidth + cardHeight to perimeter) - go up left side back to center
        else {
            return (perimeter - distance) - cardHeight/2
        }
    }
}

#Preview {
    CelebrationOverlay(
        isPresented: .constant(true),
        style: .playful,
        title: "Swap logged!",
        subtitle: "Small steps, big wins."
    )
}
