import Foundation

/// API Configuration for GlowGuide
/// Manages API keys and settings for external services
enum APIConfig {

    // MARK: - OpenAI API

    /// OpenAI API key - loaded from environment or Info.plist
    static var openAIAPIKey: String? {
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        if let plistKey = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String, !plistKey.isEmpty {
            return plistKey
        }
        return nil
    }

    /// OpenAI chat completions endpoint (for GPT-4)
    static let openAIChatURL = "https://api.openai.com/v1/chat/completions"

    /// OpenAI images endpoint (for DALL-E 3)
    static let openAIImagesURL = "https://api.openai.com/v1/images/generations"

    /// OpenAI model for text generation
    static let openAIModel = "gpt-4o"

    /// DALL-E model for image generation
    static let dalleModel = "dall-e-3"

    /// DALL-E image size
    static let dalleImageSize = "1024x1024"

    /// DALL-E image quality
    static let dalleImageQuality = "standard"

    // MARK: - Feature Flags

    /// Whether to use AI-generated looks (requires OpenAI API key)
    static var useAIGeneration: Bool {
        openAIAPIKey != nil
    }

    /// Whether to generate images with DALL-E
    static var useImageGeneration: Bool {
        openAIAPIKey != nil
    }

    // MARK: - Request Settings

    /// Request timeout in seconds
    static let requestTimeout: TimeInterval = 30

    /// Maximum tokens for GPT-4 response
    static let maxTokens = 2048
}
