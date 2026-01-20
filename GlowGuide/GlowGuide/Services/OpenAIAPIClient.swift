import Foundation

/// Client for interacting with OpenAI API to generate makeup recommendations and images
actor OpenAIAPIClient {

    // MARK: - Errors

    enum APIError: LocalizedError {
        case missingAPIKey
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        case decodingError(String)
        case networkError(Error)

        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "OpenAI API key not configured"
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
            }
        }
    }

    // MARK: - Chat Completions Models

    struct ChatRequest: Codable {
        let model: String
        let messages: [ChatMessage]
        let max_tokens: Int
        let temperature: Double

        struct ChatMessage: Codable {
            let role: String
            let content: String
        }
    }

    struct ChatResponse: Codable {
        let id: String
        let choices: [Choice]

        struct Choice: Codable {
            let message: Message
            let finish_reason: String?
        }

        struct Message: Codable {
            let role: String
            let content: String
        }
    }

    // MARK: - DALL-E Image Models

    struct ImageRequest: Codable {
        let model: String
        let prompt: String
        let n: Int
        let size: String
        let quality: String
    }

    struct ImageResponse: Codable {
        let created: Int
        let data: [ImageData]

        struct ImageData: Codable {
            let url: String?
            let revised_prompt: String?
        }
    }

    // MARK: - AI Response Model (for parsing GPT-4's JSON output)

    struct AILookResponse: Codable {
        let lookName: String
        let vibe: String
        let colorPalette: AIColorPalette
        let steps: [AIStep]

        struct AIColorPalette: Codable {
            let eyeshadow: AIColor
            let eyeliner: AIColor
            let lips: AIColor
            let blush: AIColor
            let brows: AIColor
        }

        struct AIColor: Codable {
            let hexColor: String
            let name: String
            let detail: String
        }

        struct AIStep: Codable {
            let area: String
            let instruction: String
            let tip: String
        }
    }

    // MARK: - Public Methods

    /// Generate a makeup look recommendation using GPT-4
    func generateLookRecommendation(request: LookRequest) async throws -> MakeupLook {
        guard let apiKey = APIConfig.openAIAPIKey else {
            throw APIError.missingAPIKey
        }

        guard let url = URL(string: APIConfig.openAIChatURL) else {
            throw APIError.invalidURL
        }

        // Build the prompt
        let prompt = buildPrompt(for: request)

        // Create request body
        let requestBody = ChatRequest(
            model: APIConfig.openAIModel,
            messages: [
                ChatRequest.ChatMessage(role: "system", content: "You are an expert makeup artist. Always respond with valid JSON only, no markdown or explanation."),
                ChatRequest.ChatMessage(role: "user", content: prompt)
            ],
            max_tokens: APIConfig.maxTokens,
            temperature: 0.7
        )

        // Create HTTP request
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        httpRequest.timeoutInterval = APIConfig.requestTimeout

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

        // Decode OpenAI response
        let decoder = JSONDecoder()
        let chatResponse = try decoder.decode(ChatResponse.self, from: data)

        // Extract text content
        guard let textContent = chatResponse.choices.first?.message.content else {
            throw APIError.invalidResponse
        }

        // Parse the JSON from GPT-4's response
        let aiLook = try parseAIResponse(textContent)

        // Convert to MakeupLook
        return convertToMakeupLook(aiLook: aiLook, request: request)
    }

    /// Generate a reference image using DALL-E 3
    func generateLookImage(for look: MakeupLook) async throws -> String {
        guard let apiKey = APIConfig.openAIAPIKey else {
            throw APIError.missingAPIKey
        }

        guard let url = URL(string: APIConfig.openAIImagesURL) else {
            throw APIError.invalidURL
        }

        // Build image prompt from the look
        let imagePrompt = buildImagePrompt(for: look)

        // Create request body
        let requestBody = ImageRequest(
            model: APIConfig.dalleModel,
            prompt: imagePrompt,
            n: 1,
            size: APIConfig.dalleImageSize,
            quality: APIConfig.dalleImageQuality
        )

        // Create HTTP request
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        httpRequest.timeoutInterval = 60 // DALL-E can take longer

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

        // Decode DALL-E response
        let decoder = JSONDecoder()
        let imageResponse = try decoder.decode(ImageResponse.self, from: data)

        guard let imageUrl = imageResponse.data.first?.url else {
            throw APIError.invalidResponse
        }

        return imageUrl
    }

    // MARK: - Private Methods

    private func buildPrompt(for request: LookRequest) -> String {
        """
        Create a personalized makeup look recommendation.

        User Profile:
        - Skin Tone: \(request.skinTone.rawValue)
        - Face Shape: \(request.faceShape?.rawValue ?? "not specified")
        - Style Preference: \(request.stylePreference.rawValue)
        - Occasion: \(request.occasion.rawValue)
        - Mood: \(request.mood.rawValue)

        Generate a complete makeup look that:
        1. Complements the user's skin tone
        2. Is appropriate for the occasion
        3. Reflects the desired mood
        4. Matches their style preference

        Respond with ONLY a valid JSON object (no markdown, no explanation) in this exact format:
        {
            "lookName": "Creative name for this look",
            "vibe": "2-3 word vibe description",
            "colorPalette": {
                "eyeshadow": {"hexColor": "XXXXXX", "name": "Color Name", "detail": "finish/technique"},
                "eyeliner": {"hexColor": "XXXXXX", "name": "Color Name", "detail": "style"},
                "lips": {"hexColor": "XXXXXX", "name": "Color Name", "detail": "finish"},
                "blush": {"hexColor": "XXXXXX", "name": "Color Name", "detail": "placement"},
                "brows": {"hexColor": "XXXXXX", "name": "Color Name", "detail": "style"}
            },
            "steps": [
                {"area": "Base", "instruction": "Detailed instruction", "tip": "Pro tip"},
                {"area": "Eyes", "instruction": "Detailed instruction", "tip": "Pro tip"},
                {"area": "Eyeliner", "instruction": "Detailed instruction", "tip": "Pro tip"},
                {"area": "Lips", "instruction": "Detailed instruction", "tip": "Pro tip"},
                {"area": "Blush", "instruction": "Detailed instruction", "tip": "Pro tip"},
                {"area": "Highlight", "instruction": "Detailed instruction", "tip": "Pro tip"}
            ]
        }

        Important:
        - Use 6-character hex codes WITHOUT the # symbol
        - Choose colors that complement \(request.skinTone.rawValue) skin tones
        - Make instructions specific and actionable
        - Include 6 steps: Base, Eyes, Eyeliner, Lips, Blush, Highlight
        """
    }

    private func buildImagePrompt(for look: MakeupLook) -> String {
        """
        Professional beauty photography portrait of a woman with \(look.vibe.lowercased()) makeup look.

        Makeup details:
        - Eyeshadow: \(look.colorPalette.eyeshadow.name) with \(look.colorPalette.eyeshadow.detail) finish
        - Lips: \(look.colorPalette.lips.name) \(look.colorPalette.lips.detail) lipstick
        - Blush: \(look.colorPalette.blush.name) on cheeks
        - Well-defined \(look.colorPalette.brows.detail) brows

        Style: High-end beauty editorial, soft studio lighting, clean background, focus on face and makeup.
        The look is perfect for \(look.occasion.rawValue) occasion.
        Professional makeup application, photorealistic, 4K quality.
        """
    }

    private func parseAIResponse(_ text: String) throws -> AILookResponse {
        // Extract JSON from response (GPT might add extra text)
        let jsonString = extractJSON(from: text)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw APIError.decodingError("Failed to convert response to data")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(AILookResponse.self, from: jsonData)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    private func extractJSON(from text: String) -> String {
        // Find JSON object boundaries
        guard let startIndex = text.firstIndex(of: "{"),
              let endIndex = text.lastIndex(of: "}") else {
            return text
        }
        return String(text[startIndex...endIndex])
    }

    private func convertToMakeupLook(aiLook: AILookResponse, request: LookRequest) -> MakeupLook {
        let colorPalette = ColorPalette(
            eyeshadow: ColorSpec(
                hexColor: aiLook.colorPalette.eyeshadow.hexColor,
                name: aiLook.colorPalette.eyeshadow.name,
                detail: aiLook.colorPalette.eyeshadow.detail
            ),
            eyeliner: ColorSpec(
                hexColor: aiLook.colorPalette.eyeliner.hexColor,
                name: aiLook.colorPalette.eyeliner.name,
                detail: aiLook.colorPalette.eyeliner.detail
            ),
            lips: ColorSpec(
                hexColor: aiLook.colorPalette.lips.hexColor,
                name: aiLook.colorPalette.lips.name,
                detail: aiLook.colorPalette.lips.detail
            ),
            blush: ColorSpec(
                hexColor: aiLook.colorPalette.blush.hexColor,
                name: aiLook.colorPalette.blush.name,
                detail: aiLook.colorPalette.blush.detail
            ),
            brows: ColorSpec(
                hexColor: aiLook.colorPalette.brows.hexColor,
                name: aiLook.colorPalette.brows.name,
                detail: aiLook.colorPalette.brows.detail
            )
        )

        let steps = aiLook.steps.map { step in
            MakeupStep(
                area: step.area,
                instruction: step.instruction,
                tip: step.tip
            )
        }

        return MakeupLook(
            lookName: aiLook.lookName,
            vibe: aiLook.vibe,
            occasion: request.occasion,
            mood: request.mood,
            colorPalette: colorPalette,
            steps: steps
        )
    }
}
