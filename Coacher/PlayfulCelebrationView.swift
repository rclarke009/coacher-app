import SwiftUI

struct PlayfulCelebrationView: View {
    let encouragingPhrase: String
    @Binding var isVisible: Bool
    
    @State private var sparkleScale: CGFloat = 0.0
    @State private var confettiOffset: CGFloat = -100
    @State private var textOpacity: Double = 0.0
    @State private var ringScale: CGFloat = 0.0
    @State private var ringOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Sparkly ring animation
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.blue, .teal, .green, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .scaleEffect(ringScale)
                .opacity(ringOpacity)
                .overlay(
                    // Sparkles around the ring
                    ForEach(0..<12, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .foregroundColor(.yellow)
                            .font(.caption)
                            .offset(
                                x: cos(Double(index) * .pi / 6) * 60,
                                y: sin(Double(index) * .pi / 6) * 60
                            )
                            .scaleEffect(sparkleScale)
                            .opacity(sparkleScale)
                    }
                )
            
            // Confetti pieces
            ForEach(0..<8, id: \.self) { index in
                ConfettiPiece(
                    color: confettiColors[index % confettiColors.count],
                    delay: Double(index) * 0.1
                )
                .offset(y: confettiOffset)
            }
            
            // Encouraging text
            Text(encouragingPhrase)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .opacity(textOpacity)
        }
        .onAppear {
            startCelebration()
        }
    }
    
    private let confettiColors: [Color] = [.blue, .green, .yellow, .pink, .purple, .orange, .red, .teal]
    
    private func startCelebration() {
        // Ring animation
        withAnimation(.easeOut(duration: 0.3)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }
        
        // Sparkles animation
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            sparkleScale = 1.0
        }
        
        // Confetti animation
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            confettiOffset = 200
        }
        
        // Text animation
        withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
            textOpacity = 1.0
        }
        
        // Hide everything after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 0.3)) {
                isVisible = false
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let delay: Double
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).delay(delay)) {
                    rotation = 360
                    scale = 0.5
                }
            }
    }
}

#Preview {
    PlayfulCelebrationView(
        encouragingPhrase: "🌱 One healthier choice, done.",
        isVisible: .constant(true)
    )
}
