//
//  SparkleProgressView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 9/6/25.
//

import SwiftUI

struct SparkleProgressView: View {
    @State private var progress: Double = 0.0
    @State private var sparkles: [Sparkle] = []
    @State private var animationTimer: Timer?
    
    let isLoading: Bool
    let progressValue: Double
    
    init(isLoading: Bool, progressValue: Double = 0.0) {
        self.isLoading = isLoading
        self.progressValue = progressValue
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress bar with sparkles
            ZStack {
                // Background track
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                
                // Progress fill
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.brandBlue, .helpButtonBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, progress * 200))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    
                    Spacer(minLength: 0)
                }
                
                // Sparkles overlay
                ForEach(sparkles) { sparkle in
                    Circle()
                        .fill(Color.white)
                        .frame(width: sparkle.size, height: sparkle.size)
                        .position(x: sparkle.x, y: sparkle.y)
                        .opacity(sparkle.opacity)
                        .scaleEffect(sparkle.scale)
                        .animation(.easeInOut(duration: sparkle.duration), value: sparkle.opacity)
                }
            }
            .frame(width: 200)
            .clipped()
            
            // Loading text
            Text("Preparing your AI coach...")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("This may take a few minutes on first launch")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            if isLoading {
                startProgressAnimation()
                startSparkleAnimation()
            }
        }
        .onDisappear {
            stopAnimations()
        }
        .onChange(of: isLoading) { newValue in
            if newValue {
                startProgressAnimation()
                startSparkleAnimation()
            } else {
                // Model finished loading - show completion
                completeProgress()
            }
        }
        .onChange(of: progressValue) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                progress = newValue
            }
        }
    }
    
    private func startProgressAnimation() {
        // Simulate progress if no real progress value provided
        if progressValue == 0.0 {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.6)) {
                    if progress < 0.98 {
                        // More realistic progress pattern:
                        // - Quick initial progress (0-30%)
                        // - Slower middle phase (30-80%) 
                        // - Quick finish (80-98%)
                        let increment: Double
                        if progress < 0.3 {
                            increment = 0.015  // Quick start
                        } else if progress < 0.8 {
                            increment = 0.008  // Slower middle
                        } else {
                            increment = 0.012  // Quick finish
                        }
                        progress += increment
                    }
                }
            }
        } else {
            progress = progressValue
        }
    }
    
    private func startSparkleAnimation() {
        // Create sparkles periodically
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if isLoading {
                addSparkle()
            }
        }
    }
    
    private func addSparkle() {
        let sparkle = Sparkle(
            x: CGFloat.random(in: 20...180),
            y: CGFloat.random(in: 4...12),
            size: CGFloat.random(in: 2...6),
            opacity: 0.0,
            scale: 0.5,
            duration: Double.random(in: 0.8...1.5)
        )
        
        sparkles.append(sparkle)
        
        // Animate sparkle appearance
        withAnimation(.easeOut(duration: 0.3)) {
            if let index = sparkles.firstIndex(where: { $0.id == sparkle.id }) {
                sparkles[index].opacity = 1.0
                sparkles[index].scale = 1.0
            }
        }
        
        // Remove sparkle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + sparkle.duration) {
            withAnimation(.easeIn(duration: 0.3)) {
                sparkles.removeAll { $0.id == sparkle.id }
            }
        }
    }
    
    private func completeProgress() {
        // Animate to 100% completion
        withAnimation(.easeInOut(duration: 0.8)) {
            progress = 1.0
        }
        
        // Stop the timer but keep sparkles for a moment
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Clear sparkles after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                sparkles.removeAll()
            }
        }
    }
    
    private func stopAnimations() {
        animationTimer?.invalidate()
        animationTimer = nil
        sparkles.removeAll()
    }
}

struct Sparkle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
    var duration: Double
}

#Preview {
    VStack(spacing: 40) {
        SparkleProgressView(isLoading: true)
        SparkleProgressView(isLoading: false)
    }
    .padding()
}
