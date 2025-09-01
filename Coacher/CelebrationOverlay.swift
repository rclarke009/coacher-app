import SwiftUI

struct CelebrationOverlay: View {
    @Binding var isPresented: Bool
    let title: String
    let subtitle: String
    
    @EnvironmentObject private var celebrationManager: CelebrationManager
    
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
                            ZStack {
                                // Apple with bite
                                ZStack {
                                    // Main apple body
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.red.opacity(0.8), lineWidth: 2)
                                        )
                                    
                                    // Bite taken out (using a smaller circle overlay)
                                    Circle()
                                        .fill(Color(red: 0.99, green: 0.97, blue: 0.94))
                                        .frame(width: 25, height: 25)
                                        .offset(x: 15, y: -15)
                                    
                                    // Apple stem
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.brown)
                                        .frame(width: 4, height: 8)
                                        .offset(x: 0, y: -34)
                                }
                                .scaleEffect(plantScale)
                                .animation(
                                    .easeInOut(duration: 1.5)
                                        .repeatCount(1, autoreverses: false),
                                    value: plantScale
                                )
                            }
                            
                            // Commented out leaves for potential future use
                            /*
                            ZStack {
                                // Left leaf
                                Ellipse()
                                    .fill(Color.green)
                                    .frame(width: 20, height: 12)
                                    .offset(x: -15, y: 0)
                                    .rotationEffect(.degrees(-8))
                                    .scaleEffect(leafRotation ? 1.1 : 1.0)
                                    .animation(
                                        .easeInOut(duration: 0.8)
                                            .repeatCount(3, autoreverses: true)
                                            .delay(0.2),
                                        value: leafRotation
                                    )
                                
                                // Right leaf
                                Ellipse()
                                    .fill(Color.green)
                                    .frame(width: 20, height: 12)
                                    .offset(x: 15, y: 0)
                                    .rotationEffect(.degrees(8))
                                    .scaleEffect(leafRotation ? 1.1 : 1.0)
                                    .animation(
                                        .easeInOut(duration: 0.8)
                                            .repeatCount(3, autoreverses: true)
                                            .delay(0.4),
                                        value: leafRotation
                                    )
                                
                                // Center leaf
                                Ellipse()
                                    .fill(Color.green)
                                    .frame(width: 24, height: 14)
                                    .offset(x: 0, y: -5)
                                    .scaleEffect(leafRotation ? 1.15 : 1.0)
                                    .animation(
                                        .easeInOut(duration: 0.8)
                                            .repeatCount(3, autoreverses: true),
                                        value: leafRotation
                                    )
                            }
                            */
                        }
                        .frame(width: 200, height: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.99, green: 0.97, blue: 0.94))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                        
                        // Text overlay
                        VStack(spacing: 0) {
                            Text(subtitle)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.99, green: 0.97, blue: 0.94))
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
        
        if celebrationManager.animationsEnabled {
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
        } else {
            // No animations - just show the plant at full size
            plantScale = 1.0
            glowOpacity = 0.0
        }
        
        // Text fade in
        withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
            textOpacity = 1.0
        }
        
        // Auto-dismiss after animation
        let dismissDelay = celebrationManager.animationsEnabled ? 4.5 : 2.5
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) {
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
        title: "Swap logged!",
        subtitle: "Small steps, big wins."
    )
}
