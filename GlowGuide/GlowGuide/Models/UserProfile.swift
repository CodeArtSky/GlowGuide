import Foundation

// MARK: - User Profile
struct UserProfile: Codable {
    var id: String
    var skinTone: SkinTone
    var faceShape: FaceShape?
    var stylePreference: StylePreference
    var savedLookIds: [String]
    var hasCompletedOnboarding: Bool

    init(id: String = UUID().uuidString,
         skinTone: SkinTone = .medium,
         faceShape: FaceShape? = nil,
         stylePreference: StylePreference = .natural,
         savedLookIds: [String] = [],
         hasCompletedOnboarding: Bool = false) {
        self.id = id
        self.skinTone = skinTone
        self.faceShape = faceShape
        self.stylePreference = stylePreference
        self.savedLookIds = savedLookIds
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}

// MARK: - Look Request
struct LookRequest: Codable {
    let skinTone: SkinTone
    let faceShape: FaceShape?
    let stylePreference: StylePreference
    let occasion: Occasion
    let mood: Mood
}
