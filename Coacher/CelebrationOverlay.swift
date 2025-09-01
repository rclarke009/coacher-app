import SwiftUI

enum CelebrationStyle: String, CaseIterable, Identifiable {
    case calm = "calm"
    case playful = "playful"
    case off = "off"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .calm: return "🌱 Growing"
        case .playful: return "🌱 Growing"
        case .off: return "🚫 Off"
        }
    }
}

struct CelebrationOverlay: View {
    @Binding var isPresented: Bool
    let style: CelebrationStyle
    let title: String
    let subtitle: String
    
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var plantScale: CGFloat = 0.1
    @State private var leafRotation: Double = 0
    @State private var glowOpacity: Double = 0.0
    
    // Reset animation state when overlay appears
    private func resetAnimationState() {
        cardScale = 0.8
        cardOpacity = 0.0
        textOpacity = 0.0
        plantScale = 0.1
        leafRotation = 0
        glowOpacity = 0.0
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
                    
                    // Growing plant celebration card (smaller size)
                    VStack(spacing: 0) {
                        // Animated plant container
                        ZStack {
                            // Background glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.green.opacity(0.3), Color.clear],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .opacity(glowOpacity)
                            
                            // Growing plant animation
                            VStack(spacing: 4) {
                                // Stem
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.green)
                                    .frame(width: 4, height: 40 * plantScale)
                                    .scaleEffect(y: plantScale, anchor: .bottom)
                                
                                // Leaves
                                HStack(spacing: 8) {
                                    // Left leaf
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                        .rotationEffect(.degrees(-30 + leafRotation))
                                        .scaleEffect(plantScale)
                                    
                                    // Right leaf
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                        .rotationEffect(.degrees(30 - leafRotation))
                                        .scaleEffect(plantScale)
                                }
                                
                                // Top leaf
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.green)
                                    .rotationEffect(.degrees(leafRotation))
                                    .scaleEffect(plantScale)
                            }
                        }
                        .frame(width: 200, height: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Text overlay
                        VStack(spacing: 6) {
                            Text(title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 2, x: 0, y: 1)
                            
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .shadow(color: .black, radius: 2, x: 0, y: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.6), lineWidth: 2)
                                )
                        )
                        .offset(y: -20) // Smaller overlap
                    }
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
        // Card entrance animation
        withAnimation(.easeOut(duration: 0.4)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        
        // Plant growth animation
        withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
            plantScale = 1.0
        }
        
        // Leaf movement
        withAnimation(.easeInOut(duration: 2.0).delay(0.8).repeatCount(2, autoreverses: true)) {
            leafRotation = 15
        }
        
        // Glow effect
        withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
            glowOpacity = 1.0
        }
        
        // Text fade in
        withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
            textOpacity = 1.0
        }
        
        // Auto-dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
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
}

#Preview {
    CelebrationOverlay(
        isPresented: .constant(true),
        style: .calm,
        title: "Swap logged!",
        subtitle: "Small steps, big wins."
    )
}
