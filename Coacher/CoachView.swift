//
//  CoachView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI

struct CoachView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var hybridManager = HybridLLMManager()
    @State private var userMessage = ""
    @State private var isGenerating = false
    // Removed isUserAtBottom - no automatic scrolling
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat Messages
                ScrollViewReader { proxy in
                    ZStack {
                        ScrollView {
                                    LazyVStack(spacing: 16) {
                                        if hybridManager.chatHistory.isEmpty {
                                    // Welcome Message
                                    VStack(spacing: 20) {
                                        Image(systemName: "brain.head.profile")
                                            .font(.system(size: 60))
                                            .foregroundColor(.brandBlue)
                                        
                                        Text("AI Coach")
                                            .font(.largeTitle)
                                            .bold()
                                            .foregroundColor(.dynamicText)
                                        
                                        Text("I'm here to help you build healthier habits and achieve your goals. What would you like to work on today?")
                                            .font(.body)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.dynamicSecondaryText)
                                            .padding(.horizontal, 20)
                                    }
                                    .padding(.top, 40)
                                        } else {
                                            // Chat Messages
                                            ForEach(hybridManager.chatHistory) { message in
                                                ChatBubble(message: message)
                                                    .id(message.id)
                                            }
                                        }
                                
                                if isGenerating {
                                    HStack {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Thinking...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .id("generating")
                                }
                                
                                // Removed invisible anchor - no automatic scrolling
                            }
                            .padding()
                        }
                        // Removed scroll position detection - no automatic scrolling
                        .onTapGesture {
                            // Dismiss keyboard when tapping on chat area
                            hideKeyboard()
                        }
                        // Removed all automatic scrolling - users have full control
                        
                        // Removed floating scroll button - no automatic scrolling
                    }
                }
                
                // Message Input
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("Ask your AI coach...", text: $userMessage, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(1...4)
                            .onSubmit {
                                sendMessage()
                            }
                            .onTapGesture {
                                // Don't dismiss keyboard when tapping text field
                            }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.brandBlue)
                                .clipShape(Circle())
                        }
                        .disabled(userMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                    }
                    
                            // AI Mode Indicator
                            if hybridManager.isModelLoaded {
                                HStack {
                                    Text(hybridManager.modelStatus)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    if hybridManager.isUsingCloudAI {
                                        Text("Tokens: \(hybridManager.getCurrentTokenUsage())")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                }
                .padding()
                .background(Color.cardBackground)
                .onTapGesture {
                    // Don't dismiss keyboard when tapping input area
                }
            }
            .padding()
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.inline)
            //.background(Color(.systemBackground))
            .background(
                Color.appBackground
                    .ignoresSafeArea(.all)
            )
                .onAppear {
                    Task {
                        await hybridManager.loadModel()
                    }
                }
                .onChange(of: hybridManager.isUsingCloudAI) { _ in
                    Task {
                        await hybridManager.updateAIMode()
                    }
                }

        }
    }
    
    // MARK: - Message Handling
    
    private func sendMessage() {
        let message = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        userMessage = ""
        isGenerating = true
        hideKeyboard() // Dismiss keyboard when sending
        
        Task {
            _ = await hybridManager.generateResponse(for: message)
            await MainActor.run {
                isGenerating = false
            }
        }
    }
    
    // MARK: - Keyboard Management
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Scroll Position Detection
    
    // Scroll position is now detected using onScrollGeometryChange
    // which provides accurate scroll offset information
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

// MARK: - Chat Bubble Component

struct ChatBubble: View {
    let message: LLMMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color.brandBlue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(Color.cardBackground)
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    CoachView()
}