# MLC-LLM Setup Guide for Coacher App

## Overview

This guide will help you integrate MLC-LLM (Machine Learning Compilation for Large Language Models) into your Coacher weight loss app to provide local, on-device AI coaching.

## What We've Set Up

### ✅ Completed Setup
1. **MLCLLMManager.swift** - Core manager class for handling local LLM operations
2. **CoachView Integration** - Updated to use MLC-LLM instead of mock responses
3. **Settings Integration** - Added AI Coach section in Settings for model management
4. **Model Status Indicators** - Visual feedback for model loading and status
5. **Prompt Engineering** - Structured prompts for weight loss coaching context

### 🔄 Current Status
- **Mock Implementation**: Currently using simulated responses while MLC-LLM is being set up
- **Ready for Integration**: All infrastructure is in place for real MLC-LLM

## Next Steps: Adding MLC-LLM Swift Package

### Step 1: Add MLC-LLM Package to Xcode

1. **Open Xcode** and navigate to your Coacher project
2. **Go to File → Add Package Dependencies**
3. **Enter the MLC-LLM package URL**:
   ```
   https://github.com/mlc-ai/mlc-llm-swift
   ```
4. **Select the latest version** and click "Add Package"
5. **Choose your Coacher target** when prompted

### Step 2: Update MLCLLMManager.swift

Replace the mock implementation with real MLC-LLM calls:

```swift
import MLCLLM

// In loadModel() function:
func loadModel() async {
    await MainActor.run {
        isLoading = true
        errorMessage = nil
    }
    
    do {
        // Initialize MLC-LLM
        let modelPath = Bundle.main.path(forResource: "Llama-2-7b-chat-q4f16_1", ofType: nil)
        let model = try await LLMChat.create(modelPath: modelPath)
        
        await MainActor.run {
            self.model = model
            isModelLoaded = true
            isLoading = false
        }
    } catch {
        await MainActor.run {
            errorMessage = "Failed to load model: \(error.localizedDescription)"
            isLoading = false
        }
    }
}

// In generateResponse() function:
func generateResponse(for userMessage: String, context: String = "") async -> String {
    guard let model = model else {
        return "Model not loaded yet. Please wait..."
    }
    
    let fullPrompt = createPrompt(userMessage: userMessage, context: context)
    
    do {
        let response = try await model.generate(prompt: fullPrompt, maxTokens: 150)
        return response
    } catch {
        return "Sorry, I encountered an error: \(error.localizedDescription)"
    }
}
```

### Step 3: Download Model Files

1. **Download the Llama-2-7B model** from MLC-AI:
   ```bash
   # Using curl (recommended)
   curl -L https://mlc.ai/skyward/Llama-2-7b-chat-q4f16_1-1k.tar.gz -o Llama-2-7b-chat-q4f16_1.tar.gz
   tar -xzf Llama-2-7b-chat-q4f16_1.tar.gz
   ```

2. **Add model files to Xcode**:
   - Drag the extracted model folder into your Xcode project
   - Make sure "Add to target" is checked for your Coacher target
   - The model should appear in your project navigator

### Step 4: Update Info.plist

Add required permissions for model loading:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Step 5: Test the Integration

1. **Build and run** the app
2. **Navigate to Settings → AI Coach**
3. **Tap "Load Model"** to download and initialize the model
4. **Go to Coach tab** and test a conversation

## Model Options

### Recommended Models for Coacher

| Model | Size | Speed | Quality | Use Case |
|-------|------|-------|---------|----------|
| **Llama-2-7B-Chat** | ~4GB | Fast | Good | Primary choice |
| **Llama-2-13B-Chat** | ~8GB | Medium | Better | If device supports it |
| **Mistral-7B-Instruct** | ~4GB | Fast | Excellent | Alternative option |

### Model Quantization

- **Q4F16**: Good balance of size and quality (recommended)
- **Q8F16**: Higher quality, larger size
- **Q4F32**: Smaller size, lower quality

## Performance Considerations

### Device Requirements
- **iPhone 12 or newer** (A14 Bionic or better)
- **4GB+ RAM** for 7B models
- **8GB+ RAM** for 13B models
- **2GB+ free storage** for model files

### Optimization Tips
1. **Load model on app launch** in background
2. **Cache responses** for common queries
3. **Use streaming responses** for better UX
4. **Implement model unloading** when app goes to background

## Troubleshooting

### Common Issues

**Build Errors:**
- Ensure MLC-LLM package is properly added
- Check that model files are included in target
- Verify iOS deployment target is 15.0+

**Model Loading Failures:**
- Check device has sufficient storage
- Verify model file integrity
- Ensure network connectivity for initial download

**Performance Issues:**
- Try smaller model variants
- Reduce max tokens in generation
- Implement response caching

### Debug Information

The app includes debug logging. Check Xcode console for:
- Model loading progress
- Generation timing
- Error messages

## Advanced Features

### Custom Prompt Engineering

The current prompt is optimized for weight loss coaching. You can customize it in `MLCLLMManager.swift`:

```swift
private func createPrompt(userMessage: String, context: String) -> String {
    let systemPrompt = """
    You are a supportive weight loss coach. Your role is to:
    - Provide encouraging, evidence-based advice
    - Help users understand their eating patterns
    - Suggest healthy alternatives and swaps
    - Be empathetic and non-judgmental
    - Keep responses concise and actionable
    
    Context about the user's journey: \(context)
    
    User message: \(userMessage)
    
    Coach response:
    """
    
    return systemPrompt
}
```

### Context Integration

Enhance responses by including user data:

```swift
private func getUserContext() -> String {
    // Get today's entry for context
    let today = Calendar.current.startOfDay(for: Date())
    
    // Query today's entry from SwiftData
    if let todayEntry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
        return """
        User's today's focus: \(todayEntry.myWhy)
        Chosen swap: \(todayEntry.chosenSwap)
        Commitment: \(todayEntry.commitment)
        """
    }
    
    return "User is working on weight loss goals and seeking support."
}
```

## Security & Privacy

### On-Device Processing
- All AI processing happens locally on the device
- No data is sent to external servers
- User conversations remain private

### Data Handling
- Chat history is stored locally using SwiftData
- Model files are bundled with the app
- No internet connection required for AI features

## Future Enhancements

### Planned Features
1. **Model Switching** - Allow users to choose different models
2. **Response Customization** - Adjust coaching style preferences
3. **Offline Model Updates** - Download newer model versions
4. **Multi-language Support** - Support for different languages
5. **Voice Integration** - Combine with speech recognition

### Performance Improvements
1. **Model Quantization** - Further optimize model size
2. **Response Caching** - Cache common responses
3. **Background Processing** - Load models in background
4. **Memory Management** - Optimize memory usage

## Support

For issues with MLC-LLM integration:
1. Check the [MLC-LLM Swift documentation](https://mlc.ai/mlc-llm/docs/get_started/ios.html)
2. Review the [MLC-LLM GitHub repository](https://github.com/mlc-ai/mlc-llm-swift)
3. Check device compatibility and requirements

---

**Note**: This setup provides a foundation for local AI coaching. The mock implementation ensures the app works while you integrate the real MLC-LLM package.
