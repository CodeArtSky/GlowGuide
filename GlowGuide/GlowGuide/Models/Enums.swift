import Foundation
import SwiftUI

// MARK: - Skin Tone
enum SkinTone: String, Codable, CaseIterable, Identifiable {
    case fair = "fair"
    case light = "light"
    case medium = "medium"
    case tan = "tan"
    case deep = "deep"
    case rich = "rich"

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .fair: return Color(hex: "FFE4C4")
        case .light: return Color(hex: "DEB887")
        case .medium: return Color(hex: "C19A6B")
        case .tan: return Color(hex: "A0785A")
        case .deep: return Color(hex: "8B5A2B")
        case .rich: return Color(hex: "5D4037")
        }
    }
}

// MARK: - Face Shape
enum FaceShape: String, Codable, CaseIterable, Identifiable {
    case oval = "oval"
    case round = "round"
    case square = "square"
    case heart = "heart"
    case oblong = "oblong"

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

// MARK: - Style Preference
enum StylePreference: String, Codable, CaseIterable, Identifiable {
    case natural = "Natural"
    case bold = "Bold"
    case glamorous = "Glamorous"
    case minimal = "Minimal"

    var id: String { rawValue }
    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .natural: return "leaf"
        case .bold: return "star.fill"
        case .glamorous: return "sparkles"
        case .minimal: return "circle"
        }
    }
}

// MARK: - Occasion
enum Occasion: String, Codable, CaseIterable, Identifiable {
    case business = "Business Meeting"
    case dateNight = "Date Night"
    case event = "Special Event"
    case casual = "Everyday Casual"
    case wedding = "Wedding Guest"
    case party = "Night Out"

    var id: String { rawValue }
    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .business: return "briefcase.fill"
        case .dateNight: return "heart.fill"
        case .event: return "star.fill"
        case .casual: return "sun.max.fill"
        case .wedding: return "gift.fill"
        case .party: return "moon.stars.fill"
        }
    }

    var color: Color {
        switch self {
        case .business: return .blue
        case .dateNight: return .pink
        case .event: return .purple
        case .casual: return .orange
        case .wedding: return .mint
        case .party: return .indigo
        }
    }
}

// MARK: - Mood
enum Mood: String, Codable, CaseIterable, Identifiable {
    case confident = "Confident"
    case fresh = "Fresh & Natural"
    case mysterious = "Mysterious"
    case playful = "Playful"
    case elegant = "Elegant"
    case bold = "Bold"

    var id: String { rawValue }
    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .confident: return "bolt.fill"
        case .fresh: return "leaf.fill"
        case .mysterious: return "moon.fill"
        case .playful: return "face.smiling.fill"
        case .elegant: return "crown.fill"
        case .bold: return "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .confident: return .red
        case .fresh: return .green
        case .mysterious: return .purple
        case .playful: return .yellow
        case .elegant: return .gray
        case .bold: return .orange
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
