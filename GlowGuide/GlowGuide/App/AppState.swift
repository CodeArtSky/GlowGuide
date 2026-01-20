import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var savedLooks: [MakeupLook] = []
    @Published var favoriteLookIds: Set<String> = []
    @Published var recentlyViewedLooks: [MakeupLook] = []
    @Published var isLoading = false
    @Published var currentLook: MakeupLook?
    @Published var showPaywall = false
    @Published var paywallTrigger: PaywallTrigger = .general

    // Subscription manager reference
    let subscriptionManager = SubscriptionManager.shared

    private let lookService: LookGeneratorService
    private let storageKey = "GlowGuide.UserProfile"
    private let looksStorageKey = "GlowGuide.SavedLooks"
    private let favoritesStorageKey = "GlowGuide.FavoriteLooks"
    private let historyStorageKey = "GlowGuide.RecentlyViewed"
    private let maxHistoryItems = 20

    init() {
        self.lookService = LookGeneratorService()

        // Load saved profile
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
        } else {
            self.userProfile = UserProfile()
        }

        // Load saved looks
        if let data = UserDefaults.standard.data(forKey: looksStorageKey),
           let looks = try? JSONDecoder().decode([MakeupLook].self, from: data) {
            self.savedLooks = looks
        }

        // Load favorite look IDs
        if let data = UserDefaults.standard.data(forKey: favoritesStorageKey),
           let favorites = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.favoriteLookIds = favorites
        }

        // Load recently viewed looks
        if let data = UserDefaults.standard.data(forKey: historyStorageKey),
           let history = try? JSONDecoder().decode([MakeupLook].self, from: data) {
            self.recentlyViewedLooks = history
        }

        // Sync saved looks count with subscription manager (must be after savedLooks is loaded)
        syncSavedLooksCount()
    }

    // MARK: - Profile Management

    func updateProfile(_ profile: UserProfile) {
        userProfile = profile
        saveProfile()
    }

    func completeOnboarding(skinTone: SkinTone, stylePreference: StylePreference) {
        userProfile.skinTone = skinTone
        userProfile.stylePreference = stylePreference
        userProfile.hasCompletedOnboarding = true
        saveProfile()
    }

    private func saveProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // MARK: - Look Generation

    func generateLook(occasion: Occasion, mood: Mood) async {
        isLoading = true
        defer { isLoading = false }

        let request = LookRequest(
            skinTone: userProfile.skinTone,
            faceShape: userProfile.faceShape,
            stylePreference: userProfile.stylePreference,
            occasion: occasion,
            mood: mood
        )

        do {
            let look = try await lookService.generateLook(request: request)
            currentLook = look
        } catch {
            print("Error generating look: \(error)")
            // For MVP, fallback to sample data
            currentLook = MakeupLook.sample
        }
    }

    // MARK: - Saved Looks

    func saveLook(_ look: MakeupLook) {
        if !savedLooks.contains(where: { $0.id == look.id }) {
            savedLooks.insert(look, at: 0)
            userProfile.savedLookIds.append(look.id)
            saveLooks()
            saveProfile()
            subscriptionManager.recordSavedLook()
        }
    }

    func removeLook(_ look: MakeupLook) {
        savedLooks.removeAll { $0.id == look.id }
        userProfile.savedLookIds.removeAll { $0 == look.id }
        saveLooks()
        saveProfile()
        subscriptionManager.recordRemovedLook()
    }

    func isLookSaved(_ look: MakeupLook) -> Bool {
        savedLooks.contains { $0.id == look.id }
    }

    private func saveLooks() {
        if let data = try? JSONEncoder().encode(savedLooks) {
            UserDefaults.standard.set(data, forKey: looksStorageKey)
        }
    }

    // MARK: - Favorites

    func toggleFavorite(_ look: MakeupLook) {
        if favoriteLookIds.contains(look.id) {
            favoriteLookIds.remove(look.id)
        } else {
            favoriteLookIds.insert(look.id)
        }
        saveFavorites()
    }

    func isLookFavorite(_ look: MakeupLook) -> Bool {
        favoriteLookIds.contains(look.id)
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteLookIds) {
            UserDefaults.standard.set(data, forKey: favoritesStorageKey)
        }
    }

    // MARK: - History

    func addToHistory(_ look: MakeupLook) {
        // Remove if already in history (to move to front)
        recentlyViewedLooks.removeAll { $0.id == look.id }
        // Add to front
        recentlyViewedLooks.insert(look, at: 0)
        // Trim to max size
        if recentlyViewedLooks.count > maxHistoryItems {
            recentlyViewedLooks = Array(recentlyViewedLooks.prefix(maxHistoryItems))
        }
        saveHistory()
    }

    func clearHistory() {
        recentlyViewedLooks.removeAll()
        saveHistory()
    }

    func removeFromHistory(_ look: MakeupLook) {
        recentlyViewedLooks.removeAll { $0.id == look.id }
        saveHistory()
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(recentlyViewedLooks) {
            UserDefaults.standard.set(data, forKey: historyStorageKey)
        }
    }

    // MARK: - Reset

    func resetOnboarding() {
        userProfile.hasCompletedOnboarding = false
        saveProfile()
    }

    // MARK: - Subscription Integration

    private func syncSavedLooksCount() {
        subscriptionManager.syncSavedLooksCount(savedLooks.count)
    }

    /// Check if user can generate a look, showing paywall if needed
    func canGenerateLookOrShowPaywall() -> Bool {
        if subscriptionManager.canGenerateLook {
            return true
        }
        paywallTrigger = .freeLimitReached
        showPaywall = true
        return false
    }

    /// Check if user can save a look, showing paywall if needed
    func canSaveLookOrShowPaywall() -> Bool {
        if subscriptionManager.canSaveLook {
            return true
        }
        paywallTrigger = .savedLimitReached
        showPaywall = true
        return false
    }

    /// Record a look generation (for free tier tracking)
    func recordLookGeneration() {
        subscriptionManager.recordLookGeneration()
    }

    /// Show paywall for a specific reason
    func showPaywallWith(trigger: PaywallTrigger) {
        paywallTrigger = trigger
        showPaywall = true
    }

    /// Convenience property for pro status
    var isPro: Bool {
        subscriptionManager.isPro
    }
}

// MARK: - Paywall Trigger

enum PaywallTrigger {
    case general
    case freeLimitReached
    case savedLimitReached
    case premiumFeature

    var title: String {
        switch self {
        case .general:
            return "Unlock GlowGuide Pro"
        case .freeLimitReached:
            return "Free Limit Reached"
        case .savedLimitReached:
            return "Save Limit Reached"
        case .premiumFeature:
            return "Premium Feature"
        }
    }

    var message: String {
        switch self {
        case .general:
            return "Get unlimited AI-powered beauty recommendations"
        case .freeLimitReached:
            return "You've used all 3 free looks. Upgrade to Pro for unlimited access!"
        case .savedLimitReached:
            return "You've saved 3 looks. Upgrade to Pro for unlimited favorites!"
        case .premiumFeature:
            return "This feature is available for Pro members"
        }
    }
}
