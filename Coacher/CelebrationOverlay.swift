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
    
    var body: some View {
        if isPresented {
            ZStack {
                // Full-screen dim background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissCelebration()
                    }
                
                // Success card
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(style.primaryColor)
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(32)
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
                                    // Traveling sparkle
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [style.secondaryColor, style.primaryColor],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 8
                                            )
                                        )
                                        .frame(width: 16, height: 16)
                                        .blur(radius: 2)
                                        .offset(
                                            x: cos(sparkleProgress * 2 * .pi) * 120,
                                            y: sin(sparkleProgress * 2 * .pi) * 80
                                        )
                                        .overlay(
                                            // Sparkle trail
                                            ForEach(0..<5, id: \.self) { index in
                                                Circle()
                                                    .fill(style.secondaryColor.opacity(0.8))
                                                    .frame(width: 4, height: 4)
                                                    .blur(radius: 1)
                                                    .offset(
                                                        x: cos((sparkleProgress - Double(index) * 0.1) * 2 * .pi) * 120,
                                                        y: sin((sparkleProgress - Double(index) * 0.1) * 2 * .pi) * 80
                                                    )
                                                    .opacity(1.0 - Double(index) * 0.2)
                                            }
                                        )
                                )
                        )
                )
                .scaleEffect(cardScale)
                .opacity(cardOpacity)
                .overlay(
                    // Text overlay
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(style.primaryColor)
                        
                        Text(title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(textOpacity)
                )
            }
            .onAppear {
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
        
        // Perimeter sparkle animation
        withAnimation(.easeInOut(duration: 2.0).delay(0.5)) {
            sparkleProgress = 1.0
        }
        
        // Auto-dismiss after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
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
        style: .playful,
        title: "Swap logged!",
        subtitle: "Small steps, big wins."
    )
}
