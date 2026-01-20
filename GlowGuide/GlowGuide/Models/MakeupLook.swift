import Foundation
import SwiftUI

// MARK: - Makeup Look
struct MakeupLook: Codable, Identifiable {
    let id: String
    let lookName: String
    let vibe: String
    let occasion: Occasion
    let mood: Mood
    let colorPalette: ColorPalette
    let steps: [MakeupStep]
    let imageURL: String?
    let createdAt: Date

    init(id: String = UUID().uuidString,
         lookName: String,
         vibe: String,
         occasion: Occasion,
         mood: Mood,
         colorPalette: ColorPalette,
         steps: [MakeupStep],
         imageURL: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.lookName = lookName
        self.vibe = vibe
        self.occasion = occasion
        self.mood = mood
        self.colorPalette = colorPalette
        self.steps = steps
        self.imageURL = imageURL
        self.createdAt = createdAt
    }
}

// MARK: - Color Palette
struct ColorPalette: Codable {
    let eyeshadow: ColorSpec
    let eyeliner: ColorSpec
    let lips: ColorSpec
    let blush: ColorSpec
    let brows: ColorSpec
}

// MARK: - Color Spec
struct ColorSpec: Codable {
    let hexColor: String
    let name: String
    let detail: String?  // e.g., "winged", "matte", "natural"

    var color: Color {
        Color(hex: hexColor)
    }
}

// MARK: - Makeup Step
struct MakeupStep: Codable, Identifiable {
    var id: String { area }
    let area: String
    let instruction: String
    let tip: String?

    var icon: String {
        switch area.lowercased() {
        case "base", "foundation": return "drop.fill"
        case "eyes", "eyeshadow": return "eye.fill"
        case "eyeliner": return "pencil.tip"
        case "lips": return "mouth.fill"
        case "blush", "cheeks": return "heart.fill"
        case "brows", "eyebrows": return "eyebrow"
        case "highlight": return "sparkles"
        case "contour": return "triangle.fill"
        default: return "paintbrush.fill"
        }
    }
}

// MARK: - Sample Data
extension MakeupLook {
    static let sample = MakeupLook(
        lookName: "Golden Hour Glow",
        vibe: "Warm & Radiant",
        occasion: .dateNight,
        mood: .confident,
        colorPalette: ColorPalette(
            eyeshadow: ColorSpec(hexColor: "C4956A", name: "Warm Bronze", detail: "shimmer"),
            eyeliner: ColorSpec(hexColor: "4A3728", name: "Deep Brown", detail: "subtle wing"),
            lips: ColorSpec(hexColor: "B85C5C", name: "Dusty Rose", detail: "satin"),
            blush: ColorSpec(hexColor: "E8A090", name: "Peach Glow", detail: "apples"),
            brows: ColorSpec(hexColor: "5D4037", name: "Soft Brown", detail: "feathered")
        ),
        steps: [
            MakeupStep(area: "Base", instruction: "Apply light-coverage foundation, focusing on evening out skin tone. Set with translucent powder on T-zone only.", tip: "Use a damp beauty sponge for natural finish"),
            MakeupStep(area: "Eyes", instruction: "Apply warm bronze shadow on lid, blend darker shade into crease. Add shimmer to inner corner.", tip: "Build color gradually for dimension"),
            MakeupStep(area: "Eyeliner", instruction: "Line upper lash line with brown liner, creating a subtle wing at outer corner.", tip: "Keep wing short and angled upward"),
            MakeupStep(area: "Lips", instruction: "Apply dusty rose lipstick, blot, and reapply for lasting color.", tip: "Use lip liner in similar shade to prevent bleeding"),
            MakeupStep(area: "Blush", instruction: "Smile and apply peach blush to the apples of cheeks, blending upward toward temples.", tip: "Start light - you can always add more"),
            MakeupStep(area: "Highlight", instruction: "Dab highlighter on cheekbones, brow bone, and cupid's bow.", tip: "Use fingers for natural placement")
        ],
        imageURL: nil
    )
}
