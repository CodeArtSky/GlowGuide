import Foundation

/// Client for interacting with Google Gemini API for image generation
actor GeminiAPIClient {

    // MARK: - Errors

    enum APIError: LocalizedError {
        case missingAPIKey
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        case decodingError(String)
        case networkError(Error)
        case noImageGenerated

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "Gemini API key not configured"
            case .invalidURL:
                return "Invalid API URL"
            case .invalidResponse:
                return "Invalid response from API"
            case .httpError(let code, let message):
                return "HTTP Error \(code): \(message)"
            case .decodingError(let details):
                return "Failed to decode response: \(details)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .noImageGenerated:
                return "No image was generated"
            }
        }
    }

    // MARK: - Request/Response Models

    struct GeminiRequest: Codable {
        let contents: [Content]
        let generationConfig: GenerationConfig

        struct Content: Codable {
            let parts: [Part]
        }

        struct Part: Codable {
            let text: String
        }

        struct GenerationConfig: Codable {
            let responseModalities: [String]
        }
    }

    struct GeminiResponse: Codable {
        let candidates: [Candidate]?

        struct Candidate: Codable {
            let content: Content?
        }

        struct Content: Codable {
            let parts: [Part]?
        }

        struct Part: Codable {
            let text: String?
            let inlineData: InlineData?
        }

        struct InlineData: Codable {
            let mimeType: String
            let data: String
        }
    }

    // MARK: - Public Methods

    /// Generate a makeup reference image using Gemini
    func generateLookImage(for look: MakeupLook) async throws -> String {
        guard let apiKey = APIConfig.geminiAPIKey else {
            throw APIError.missingAPIKey
        }

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp-image-generation:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        // Build image prompt
        let imagePrompt = buildImagePrompt(for: look)

        // Create request body
        let requestBody = GeminiRequest(
            contents: [
                GeminiRequest.Content(parts: [
                    GeminiRequest.Part(text: "Generate an image: \(imagePrompt)")
                ])
            ],
            generationConfig: GeminiRequest.GenerationConfig(
                responseModalities: ["TEXT", "IMAGE"]
            )
        )

        // Create HTTP request
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.timeoutInterval = 90

        let encoder = JSONEncoder()
        httpRequest.httpBody = try encoder.encode(requestBody)

        // Make request
        let (data, response) = try await URLSession.shared.data(for: httpRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Decode response
        let decoder = JSONDecoder()
        let geminiResponse = try decoder.decode(GeminiResponse.self, from: data)

        // Find the image part in the response
        guard let parts = geminiResponse.candidates?.first?.content?.parts else {
            throw APIError.noImageGenerated
        }

        // Look for inlineData (image)
        for part in parts {
            if let inlineData = part.inlineData {
                // Return as data URL for display in SwiftUI
                return "data:\(inlineData.mimeType);base64,\(inlineData.data)"
            }
        }

        throw APIError.noImageGenerated
    }

    // MARK: - Private Methods

    private func buildImagePrompt(for look: MakeupLook) -> String {
        """
        Professional beauty photography portrait of a woman with \(look.lookName) makeup look.
        Style: \(look.vibe), perfect for \(look.occasion.rawValue).
        Makeup: \(look.colorPalette.eyeshadow.name) eyeshadow, \(look.colorPalette.lips.name) lips, \(look.colorPalette.blush.name) blush.
        High-end beauty editorial, studio lighting, clean background, photorealistic.
        """
    }
}
