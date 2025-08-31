//
//  CoachView.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import SwiftUI
import SwiftData

struct CoachView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \LLMMessage.timestamp) private var messages: [LLMMessage]
    @State private var newMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                if messages.isEmpty {
                    EmptyChatView()
                } else {
                    ChatMessagesView(messages: messages)
                }
                
                Divider()
                
                // Message Input
                HStack {
                    TextField("Type your message...", text: $newMessage, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding()
            }
            .navigationTitle("Coach")
            .onAppear {
                if messages.isEmpty {
                    addSystemMessage()
                }
            }
        }
    }
    
    private func addSystemMessage() {
        let systemMessage = LLMMessage(
            role: .system,
            content: "You are a compassionate, pragmatic weight-loss coach. Focus on tiny, doable actions and pattern awareness. Use the user's daily context (why, chosen swap, commitment). Avoid shame. Offer one concrete next step. Keep replies under 120 words unless asked."
        )
        context.insert(systemMessage)
        try? context.save()
    }
    
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        // Add user message
        let userMessage = LLMMessage(role: .user, content: trimmedMessage)
        context.insert(userMessage)
        
        // Clear input
        newMessage = ""
        
        // Simulate coach response (TODO: Replace with real LLM)
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let coachResponse = LLMMessage(
                role: .assistant,
                content: "I hear you. Let's focus on one small, doable step. What feels manageable right now about your goal?"
            )
            context.insert(coachResponse)
            try? context.save()
            isLoading = false
        }
        
        try? context.save()
    }
}

struct EmptyChatView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Start a conversation with your coach")
                .font(.title2)
                .bold()
            
            Text("Share your thoughts, challenges, or ask for guidance. Your coach is here to help you make the next healthy choice.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ChatMessagesView: View {
    let messages: [LLMMessage]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messages) { message in
                    if message.role != .system {
                        MessageBubble(message: message)
                    }
                }
            }
            .padding()
        }
    }
}

struct MessageBubble: View {
    let message: LLMMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.role == .user ? Color.blue : Color(.secondarySystemBackground))
                    )
                    .foregroundStyle(message.role == .user ? .white : .primary)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

#Preview {
    CoachView()
        .modelContainer(for: [DailyEntry.self, Achievement.self, LLMMessage.self], inMemory: true)
}
