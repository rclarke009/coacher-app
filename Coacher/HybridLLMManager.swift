import Foundation
import SwiftUI
import SwiftData

/// Hybrid LLM Manager that can switch between local and cloud AI
@MainActor
class HybridLLMManager: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var chatHistory: [LLMMessage] = []
    @Published var isUsingCloudAI = false
    @AppStorage("useCloudAI") private var useCloudAI = false
    
    // Managers
    private let localManager = MLXLLMManager()
    private let cloudManager = BackendLLMManager()
    
    // Configuration
    private let maxTokens = 2000
    
    init() {
        chatHistory = []
        isUsingCloudAI = useCloudAI
    }
    
    // MARK: - Model Management
    
    /// Load the appropriate AI model based on user preference
    func loadModel() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        if isUsingCloudAI {
            await cloudManager.loadModel()
            await MainActor.run {
                isModelLoaded = cloudManager.isModelLoaded
                errorMessage = cloudManager.errorMessage
            }
        } else {
            await localManager.loadModel()
            await MainActor.run {
                isModelLoaded = localManager.isModelLoaded
                errorMessage = localManager.errorMessage
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    /// Generate a response using the appropriate AI
    func generateResponse(for userMessage: String, context: String = "") async -> String {
        guard isModelLoaded else {
            return "AI model not loaded yet. Please wait..."
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        let response: String
        
        if isUsingCloudAI {
            response = await cloudManager.generateResponse(for: userMessage, context: context)
        } else {
            response = await localManager.generateResponse(for: userMessage, context: context)
        }
        
        // Save the message to our chat history
        await saveMessage(userMessage, isUser: true)
        await saveMessage(response, isUser: false)
        
        await MainActor.run {
            isLoading = false
        }
        
        return response
    }
    
    // MARK: - AI Mode Switching
    
    /// Switch to local AI mode
    func switchToLocalAI() async {
        await MainActor.run {
            isUsingCloudAI = false
            useCloudAI = false
            // Clear chat history when switching modes for privacy
            chatHistory.removeAll()
        }
        await loadModel()
    }
    
    /// Switch to cloud AI mode
    func switchToCloudAI() async {
        await MainActor.run {
            isUsingCloudAI = true
            useCloudAI = true
            // Clear chat history when switching modes for privacy
            chatHistory.removeAll()
        }
        await loadModel()
    }
    
    /// Update AI mode based on user preference change
    func updateAIMode() async {
        await MainActor.run {
            isUsingCloudAI = useCloudAI
            // Clear chat history when switching modes for privacy
            chatHistory.removeAll()
        }
        await loadModel()
    }
    
    // MARK: - Message Management
    
    private func saveMessage(_ content: String, isUser: Bool) async {
        await MainActor.run {
            let role: Role = isUser ? .user : .assistant
            let message = LLMMessage(
                role: role,
                content: content,
                timestamp: Date()
            )
            chatHistory.append(message)
        }
    }
    
    // MARK: - Model Status
    
    var modelStatus: String {
        if isLoading {
            return "Loading AI model..."
        } else if isModelLoaded {
            if isUsingCloudAI {
                return "Enhanced Cloud AI Ready (2000 token limit)"
            } else {
                return "Local AI Ready (Private & Offline)"
            }
        } else {
            return "AI model not loaded"
        }
    }
    
    var currentModeDescription: String {
        if isUsingCloudAI {
            return "Enhanced Cloud Coach\nRicher conversations, requires internet"
        } else {
            return "Local Coach\nFast, private, offline"
        }
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
        localManager.clearError()
        cloudManager.clearError()
    }
    
    // MARK: - Cleanup
    
    func unloadModel() async {
        await MainActor.run {
            isModelLoaded = false
            chatHistory.removeAll()
        }
        await localManager.unloadModel()
        await cloudManager.unloadModel()
    }
    
    // MARK: - Testing Utilities
    
    /// Get current token usage for testing (rough estimate for display)
    func getCurrentTokenUsage() -> Int {
        let totalText = chatHistory.map { $0.content }.joined()
        return totalText.count / 4 // Rough token estimation
    }
}
