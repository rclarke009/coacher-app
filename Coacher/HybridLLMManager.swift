import Foundation
import SwiftUI
import SwiftData

/// Hybrid LLM Manager that can switch between local and cloud AI
@MainActor
class HybridLLMManager: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var isGeneratingResponse = false
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
        print("🔄 HybridLLMManager: Starting model loading...")
        await MainActor.run {
            errorMessage = nil
            // Reset loading state when switching modes
            isModelLoaded = false
        }
        
        if self.isUsingCloudAI {
            print("🔄 HybridLLMManager: Loading ONLINE AI mode...")
            print("🔄 HybridLLMManager: Checking cloud AI connectivity...")
            // No loading state for online AI - just check connectivity
            await self.cloudManager.loadModel()
            await MainActor.run {
                self.isModelLoaded = self.cloudManager.isModelLoaded
                self.errorMessage = self.cloudManager.errorMessage
                print("🔄 HybridLLMManager: Cloud AI ready - isModelLoaded: \(self.isModelLoaded)")
            }
        } else {
            print("🔄 HybridLLMManager: Loading LOCAL AI mode...")
            await MainActor.run {
                self.isLoading = true
                print("🔄 HybridLLMManager: isLoading set to true for local AI")
            }
            
            // Add timeout handling for local AI model loading
            await withTimeout(seconds: 30) {
                await self.localManager.loadModel()
                await MainActor.run {
                    self.isModelLoaded = self.localManager.isModelLoaded
                    self.errorMessage = self.localManager.errorMessage
                    print("🔄 HybridLLMManager: Local AI loaded - isModelLoaded: \(self.isModelLoaded)")
                }
            }
            
            await MainActor.run {
                self.isLoading = false
                print("🔄 HybridLLMManager: isLoading set to false, isModelLoaded: \(self.isModelLoaded)")
            }
        }
    }
    
    /// Helper function to add timeout to async operations
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async -> T) async -> T? {
        return await withTaskGroup(of: T?.self) { group in
            group.addTask {
                await operation()
            }
            
            group.addTask {
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                return nil
            }
            
            return await group.first { $0 != nil } ?? nil
        }
    }
    
    /// Generate a response using the appropriate AI
    func generateResponse(for userMessage: String, context: String = "") async -> String {
        guard isModelLoaded else {
            return "AI model not loaded yet. Please wait..."
        }
        
        await MainActor.run {
            isGeneratingResponse = true
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
            isGeneratingResponse = false
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
