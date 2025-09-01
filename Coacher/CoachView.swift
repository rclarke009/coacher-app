//
//  CoachView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct CoachView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Coming Soon Icon
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 100))
                    .foregroundColor(.brandBlue)
                
                // Coming Soon Title
                Text("AI Coach")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.dynamicText)
                
                // Coming Soon Message
                VStack(spacing: 16) {
                    Text("Coming Soon")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.brandBlue)
                    
                    Text("Your personalized AI coach is being trained to help you make healthier choices and build better habits.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.dynamicSecondaryText)
                        .padding(.horizontal, 40)
                }
                
                // Feature Preview
                VStack(spacing: 12) {
                    FeaturePreviewRow(icon: "message.circle.fill", text: "Personalized conversations")
                    FeaturePreviewRow(icon: "brain.head.profile", text: "Smart habit coaching")
                    FeaturePreviewRow(icon: "chart.line.uptrend.xyaxis", text: "Progress tracking")
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FeaturePreviewRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.brandBlue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.dynamicText)
            
            Spacer()
        }
    }
}

#Preview {
    CoachView()
}