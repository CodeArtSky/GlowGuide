import Foundation

/// Service for generating personalized makeup looks
/// Uses OpenAI GPT-4 when API key is available, falls back to mock data otherwise
class LookGeneratorService {

    private let openAIClient = OpenAIAPIClient()

    // MARK: - Public API

    /// Generate a makeup look based on user request
    /// Tries AI generation first, falls back to mock data on error
    func generateLook(request: LookRequest) async throws -> MakeupLook {
        // Check if AI generation is enabled
        if APIConfig.useAIGeneration {
            do {
                print("Generating AI-powered look with GPT-4...")
                let look = try await openAIClient.generateLookRecommendation(request: request)
                print("AI look generated successfully: \(look.lookName)")
                return look
            } catch {
                print("AI generation failed: \(error.localizedDescription)")
                print("Falling back to mock data...")
                return generateMockLook(for: request)
            }
        } else {
            // No API key configured, use mock data
            print("No OpenAI API key configured, using mock data")
            // Simulate network delay for consistent UX
            try await Task.sleep(nanoseconds: 1_500_000_000)
            return generateMockLook(for: request)
        }
    }

    /// Generate a reference image for the makeup look using DALL-E 3
    func generateLookImage(for look: MakeupLook) async throws -> String? {
        guard APIConfig.useImageGeneration else {
            print("Image generation not enabled")
            return nil
        }

        do {
            print("Generating reference image with DALL-E 3...")
            let imageUrl = try await openAIClient.generateLookImage(for: look)
            print("Image generated successfully")
            return imageUrl
        } catch {
            print("Image generation failed: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Mock Data Generation

    private func generateMockLook(for request: LookRequest) -> MakeupLook {
        let lookData = getLookData(occasion: request.occasion, mood: request.mood, skinTone: request.skinTone)

        return MakeupLook(
            lookName: lookData.name,
            vibe: lookData.vibe,
            occasion: request.occasion,
            mood: request.mood,
            colorPalette: lookData.palette,
            steps: lookData.steps
        )
    }

    private func getLookData(occasion: Occasion, mood: Mood, skinTone: SkinTone) -> (name: String, vibe: String, palette: ColorPalette, steps: [MakeupStep]) {

        // Contextual looks based on occasion + mood combination
        switch (occasion, mood) {
        case (.dateNight, .confident), (.dateNight, .bold):
            return (
                name: "Sultry Siren",
                vibe: "Bold & Seductive",
                palette: ColorPalette(
                    eyeshadow: ColorSpec(hexColor: "8B4513", name: "Smoky Bronze", detail: "shimmer"),
                    eyeliner: ColorSpec(hexColor: "000000", name: "Jet Black", detail: "dramatic wing"),
                    lips: ColorSpec(hexColor: "8B0000", name: "Deep Red", detail: "matte"),
                    blush: ColorSpec(hexColor: "DC143C", name: "Berry Flush", detail: "contour"),
                    brows: ColorSpec(hexColor: "3D2B1F", name: "Dark Brown", detail: "defined")
                ),
                steps: [
                    MakeupStep(area: "Base", instruction: "Apply medium-coverage foundation for a flawless canvas. Contour cheekbones and jawline.", tip: "Set with powder to ensure longevity"),
                    MakeupStep(area: "Eyes", instruction: "Apply bronze shimmer on lid, blend dark brown into crease. Build smoky effect at outer corner.", tip: "Use tape for sharp outer edge"),
                    MakeupStep(area: "Eyeliner", instruction: "Create a dramatic winged liner, extending past outer corner.", tip: "Draw wing first, then fill in"),
                    MakeupStep(area: "Lips", instruction: "Line lips with deep red liner, fill with matte lipstick. Blot and reapply.", tip: "Use concealer around lips for crisp edges"),
                    MakeupStep(area: "Blush", instruction: "Apply berry blush below cheekbones in a draping technique.", tip: "Blend upward toward temples"),
                    MakeupStep(area: "Highlight", instruction: "Apply highlight to high points: cheekbones, nose tip, cupid's bow.", tip: "Use sparingly for sophistication")
                ]
            )

        case (.business, _):
            return (
                name: "Polished Professional",
                vibe: "Clean & Confident",
                palette: ColorPalette(
                    eyeshadow: ColorSpec(hexColor: "D2B48C", name: "Soft Taupe", detail: "matte"),
                    eyeliner: ColorSpec(hexColor: "4A3728", name: "Espresso", detail: "subtle"),
                    lips: ColorSpec(hexColor: "BC8F8F", name: "Rosy Mauve", detail: "satin"),
                    blush: ColorSpec(hexColor: "FFB6C1", name: "Soft Pink", detail: "apples"),
                    brows: ColorSpec(hexColor: "5D4E37", name: "Taupe Brown", detail: "natural")
                ),
                steps: [
                    MakeupStep(area: "Base", instruction: "Apply light foundation or tinted moisturizer. Conceal under eyes and any blemishes.", tip: "Keep it natural-looking"),
                    MakeupStep(area: "Eyes", instruction: "Apply soft taupe across lid, slightly darker shade in crease for definition.", tip: "Blend well for seamless transition"),
                    MakeupStep(area: "Eyeliner", instruction: "Tightline upper waterline with espresso pencil. Optional: thin line on upper lid.", tip: "Keep it subtle and professional"),
                    MakeupStep(area: "Lips", instruction: "Apply rosy mauve lipstick for a polished, put-together look.", tip: "Blot for natural finish"),
                    MakeupStep(area: "Blush", instruction: "Apply soft pink blush to apples of cheeks.", tip: "Smile and apply to the roundest part"),
                    MakeupStep(area: "Brows", instruction: "Fill in sparse areas with light strokes. Set with clear gel.", tip: "Follow natural brow shape")
                ]
            )

        case (.party, _), (.event, .bold):
            return (
                name: "Glamour Night",
                vibe: "Sparkling & Festive",
                palette: ColorPalette(
                    eyeshadow: ColorSpec(hexColor: "FFD700", name: "Gold Glitter", detail: "shimmer"),
                    eyeliner: ColorSpec(hexColor: "000000", name: "Black", detail: "winged"),
                    lips: ColorSpec(hexColor: "FF69B4", name: "Hot Pink", detail: "gloss"),
                    blush: ColorSpec(hexColor: "FF6B6B", name: "Coral Pop", detail: "apples"),
                    brows: ColorSpec(hexColor: "3D2B1F", name: "Dark Brown", detail: "defined")
                ),
                steps: [
                    MakeupStep(area: "Base", instruction: "Apply illuminating primer, then full-coverage foundation. Set with setting spray.", tip: "Mix in liquid highlighter for all-over glow"),
                    MakeupStep(area: "Eyes", instruction: "Pack gold glitter onto center of lid. Blend darker shade into crease and outer corner.", tip: "Use glitter glue for maximum payoff"),
                    MakeupStep(area: "Eyeliner", instruction: "Create bold winged liner. Add rhinestones at outer corner for extra glam.", tip: "Waterproof formula is key for lasting wear"),
                    MakeupStep(area: "Lips", instruction: "Apply hot pink lip color topped with clear gloss for dimension.", tip: "Apply lip plumper first for fuller look"),
                    MakeupStep(area: "Blush", instruction: "Apply coral blush to apples and blend up to temples.", tip: "Layer for buildable color"),
                    MakeupStep(area: "Highlight", instruction: "Apply intense highlight to all high points. Add body shimmer to shoulders.", tip: "Go bold - it's a party!")
                ]
            )

        case (.casual, .fresh), (.casual, .playful):
            return (
                name: "Effortless Glow",
                vibe: "Fresh & Dewy",
                palette: ColorPalette(
                    eyeshadow: ColorSpec(hexColor: "F5DEB3", name: "Champagne", detail: "shimmer"),
                    eyeliner: ColorSpec(hexColor: "6B4423", name: "Brown", detail: "smudged"),
                    lips: ColorSpec(hexColor: "E8B4B8", name: "Nude Pink", detail: "balm"),
                    blush: ColorSpec(hexColor: "FFDAB9", name: "Peachy Nude", detail: "cream"),
                    brows: ColorSpec(hexColor: "8B7355", name: "Soft Brown", detail: "feathered")
                ),
                steps: [
                    MakeupStep(area: "Base", instruction: "Apply tinted moisturizer or skin tint. Spot conceal only where needed.", tip: "Less is more for everyday freshness"),
                    MakeupStep(area: "Eyes", instruction: "Sweep champagne shimmer across lid. Add touch of brown to outer corner.", tip: "Use fingers for quick application"),
                    MakeupStep(area: "Eyeliner", instruction: "Smudge brown pencil along upper lash line. Skip if you prefer minimal.", tip: "Blend with finger for soft effect"),
                    MakeupStep(area: "Lips", instruction: "Apply tinted lip balm in nude pink for healthy, hydrated lips.", tip: "Reapply throughout the day"),
                    MakeupStep(area: "Blush", instruction: "Dab cream blush on cheeks and blend with fingers.", tip: "Tap onto apples for natural flush"),
                    MakeupStep(area: "Brows", instruction: "Brush brows up with clear gel. Fill lightly if needed.", tip: "Keep brows fluffy and natural")
                ]
            )

        case (.wedding, _):
            return (
                name: "Romantic Elegance",
                vibe: "Soft & Timeless",
                palette: ColorPalette(
                    eyeshadow: ColorSpec(hexColor: "DEB887", name: "Rose Gold", detail: "shimmer"),
                    eyeliner: ColorSpec(hexColor: "4A3728", name: "Soft Brown", detail: "subtle wing"),
                    lips: ColorSpec(hexColor: "CD5C5C", name: "Dusty Rose", detail: "satin"),
                    blush: ColorSpec(hexColor: "FFB6C1", name: "Soft Rose", detail: "draping"),
                    brows: ColorSpec(hexColor: "6B4423", name: "Warm Brown", detail: "defined")
                ),
                steps: [
                    MakeupStep(area: "Base", instruction: "Apply long-wear foundation for all-day coverage. Set with fine setting powder.", tip: "Use waterproof formulas for emotional moments"),
                    MakeupStep(area: "Eyes", instruction: "Apply rose gold shimmer on lid, soft brown in crease. Highlight inner corner and brow bone.", tip: "Blend for soft, romantic effect"),
                    MakeupStep(area: "Eyeliner", instruction: "Create subtle wing with brown liner. Add individual false lashes for photos.", tip: "Individual lashes look more natural"),
                    MakeupStep(area: "Lips", instruction: "Apply dusty rose lipstick. Blot and layer for lasting color.", tip: "Bring lipstick for touch-ups"),
                    MakeupStep(area: "Blush", instruction: "Apply soft rose blush in draping technique for lifted look.", tip: "Build gradually for photography"),
                    MakeupStep(area: "Highlight", instruction: "Apply subtle highlight to cheekbones and cupid's bow.", tip: "Avoid glitter - opt for satin finish")
                ]
            )

        default:
            return (
                name: "Golden Hour Glow",
                vibe: "Warm & Radiant",
                palette: ColorPalette(
                    eyeshadow: ColorSpec(hexColor: "C4956A", name: "Warm Bronze", detail: "shimmer"),
                    eyeliner: ColorSpec(hexColor: "4A3728", name: "Deep Brown", detail: "subtle wing"),
                    lips: ColorSpec(hexColor: "B85C5C", name: "Dusty Rose", detail: "satin"),
                    blush: ColorSpec(hexColor: "E8A090", name: "Peach Glow", detail: "apples"),
                    brows: ColorSpec(hexColor: "5D4037", name: "Soft Brown", detail: "feathered")
                ),
                steps: [
                    MakeupStep(area: "Base", instruction: "Apply light-coverage foundation, focusing on evening out skin tone.", tip: "Use a damp beauty sponge"),
                    MakeupStep(area: "Eyes", instruction: "Apply warm bronze on lid, blend darker shade into crease.", tip: "Build color gradually"),
                    MakeupStep(area: "Eyeliner", instruction: "Line upper lash line with brown liner, subtle wing.", tip: "Keep wing short and angled up"),
                    MakeupStep(area: "Lips", instruction: "Apply dusty rose lipstick, blot and reapply.", tip: "Use lip liner to prevent bleeding"),
                    MakeupStep(area: "Blush", instruction: "Apply peach blush to apples of cheeks.", tip: "Start light, build up"),
                    MakeupStep(area: "Highlight", instruction: "Dab highlighter on cheekbones, brow bone, cupid's bow.", tip: "Use fingers for natural placement")
                ]
            )
        }
    }
}
