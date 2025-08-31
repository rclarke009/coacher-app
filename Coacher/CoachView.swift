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
                        .submitLabel(.send)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding()
            }
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if messages.isEmpty {
                    addSystemMessage()
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                hideKeyboard()
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
        
        // Clear input and hide keyboard
        newMessage = ""
        hideKeyboard()
        
        // Generate varied coach response based on user input
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let coachResponse = generateCoachResponse(to: trimmedMessage)
            let message = LLMMessage(role: .assistant, content: coachResponse)
            context.insert(message)
            try? context.save()
            isLoading = false
        }
        
        try? context.save()
    }
    
    private func generateCoachResponse(to userMessage: String) -> String {
        let responses = [
            "I hear you. Let's focus on one small, doable step. What feels manageable right now about your goal?",
            "That's a great observation. What's one tiny action you could take in the next 5 minutes to move toward your goal?",
            "I understand this challenge. Let's break it down - what's the smallest possible step you could take today?",
            "You're showing real awareness here. How can we make this easier? What would help you feel more supported?",
            "This is exactly the kind of reflection that leads to change. What's one thing you could do differently next time?",
            "I appreciate you sharing this. Let's focus on progress, not perfection. What's one small win you can celebrate?",
            "That sounds challenging. What would your future self thank you for doing right now?",
            "You're not alone in this struggle. What's one tiny habit that could make a big difference over time?"
        ]
        
        // Use the user's message to seed a pseudo-random response
        let hash = userMessage.hashValue
        let index = abs(hash) % responses.count
        return responses[index]
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct EmptyChatView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.brandBlue)
            
            Text("Start a conversation with your coach")
                .font(.title2)
                .bold()
                .foregroundColor(.dynamicText)
            
            Text("Share your thoughts, challenges, or ask for guidance. Your coach is here to help you make the next healthy choice.")
                .multilineTextAlignment(.center)
                .foregroundColor(.dynamicSecondaryText)
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
    @Environment(\.colorScheme) private var colorScheme
    
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
                            .fill(message.role == .user ? Color.brandBlue : Color.dynamicCardBackground)
                    )
                    .foregroundColor(message.role == .user ? .white : .dynamicText)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.dynamicSecondaryText)
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
