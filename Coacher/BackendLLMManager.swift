import Foundation
import SwiftUI
import SwiftData

/// Backend proxy-based LLM Manager for secure AI responses
@MainActor
class BackendLLMManager: ObservableObject {
    @Published var isModelLoaded = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var chatHistory: [LLMMessage] = []
    
    // Backend Configuration
    private let backendURL: String
    private let maxTokens = 2000
    private let temperature = 0.7
    
    // Response structure for backend API
    private struct ChatResponse: Codable {
        let response: String
        let usage: TokenUsage
        let model: String
        let timestamp: String
    }
    
    private struct TokenUsage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
    }
    
    init(backendURL: String = "https://lightertomorrow.com") {
        self.backendURL = backendURL
        chatHistory = []
    }
    
    // MARK: - Model Management
    
    /// Load the backend model (always ready)
    func loadModel() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Test backend connectivity
        let isBackendAvailable = await testBackendConnection()
        
        await MainActor.run {
            isModelLoaded = isBackendAvailable
            if !isBackendAvailable {
                errorMessage = "Backend service unavailable. Please check your internet connection."
            }
            isLoading = false
        }
    }
    
    /// Generate a response using the backend proxy
    func generateResponse(for userMessage: String, context: String = "") async -> String {
        guard isModelLoaded else {
            return "Backend model not loaded yet. Please wait..."
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        // Save user message
        await saveMessage(userMessage, isUser: true)
        
        do {
            let response = try await callBackendAPI(message: userMessage, context: context)
            
            // Save AI response
            await saveMessage(response, isUser: false)
            
            await MainActor.run {
                isLoading = false
            }
            
            return response
        } catch {
            let errorMessage = "Error generating response: \(error.localizedDescription)"
            
            await MainActor.run {
                self.errorMessage = errorMessage
                isLoading = false
            }
            
            return errorMessage
        }
    }
    
    // MARK: - Backend API Communication
    
    private func testBackendConnection() async -> Bool {
        guard let url = URL(string: "\(backendURL)/.netlify/functions/health") else { return false }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            print("Backend connection test failed: \(error)")
        }
        
        return false
    }
    
    private func callBackendAPI(message: String, context: String) async throws -> String {
        guard let url = URL(string: "\(backendURL)/.netlify/functions/chat") else {
            throw BackendError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Coacher-iOS/1.0", forHTTPHeaderField: "User-Agent")
        
        let requestBody = [
            "message": message,
            "context": context,
            "maxTokens": maxTokens,
            "temperature": temperature
        ] as [String: Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw BackendError.invalidRequest
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            return chatResponse.response
            
        case 429:
            throw BackendError.rateLimited
            
        case 400:
            throw BackendError.badRequest
            
        case 500:
            throw BackendError.serverError
            
        default:
            throw BackendError.unknownError(httpResponse.statusCode)
        }
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
            return "Processing your message..."
        } else if isModelLoaded {
            return "Enhanced Cloud AI Ready (2000 token limit)"
        } else {
            return "Backend service unavailable"
        }
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Cleanup
    
    func unloadModel() async {
        await MainActor.run {
            isModelLoaded = false
            chatHistory.removeAll()
        }
    }
    
    // MARK: - Testing Utilities
    
    /// Get current token usage for testing (rough estimate for display)
    func getCurrentTokenUsage() -> Int {
        let totalText = chatHistory.map { $0.content }.joined()
        return totalText.count / 4 // Rough token estimation
    }
}

// MARK: - Backend Errors

enum BackendError: LocalizedError {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case rateLimited
    case badRequest
    case serverError
    case unknownError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid backend URL"
        case .invalidRequest:
            return "Invalid request format"
        case .invalidResponse:
            return "Invalid response from backend"
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .badRequest:
            return "Invalid request. Please check your input."
        case .serverError:
            return "Backend server error. Please try again later."
        case .unknownError(let code):
            return "Unknown error (code: \(code))"
        }
    }
}
