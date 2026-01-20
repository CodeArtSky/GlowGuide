import UIKit

/// Centralized haptic feedback manager for consistent tactile experience
enum HapticManager {

    // MARK: - Impact Feedback

    /// Light tap - for subtle selections
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium tap - for button presses
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Heavy tap - for important actions
    static func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Soft tap - for gentle feedback
    static func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Rigid tap - for firm feedback
    static func rigidImpact() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success feedback - green checkmark moments
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Warning feedback - caution moments
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    /// Error feedback - failure moments
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed - for pickers, toggles, tabs
    static func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Custom Patterns

    /// Double tap pattern - for favorites/save actions
    static func doubleTap() {
        lightImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            lightImpact()
        }
    }

    /// Celebration pattern - for achievements/completions
    static func celebration() {
        success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            lightImpact()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            lightImpact()
        }
    }
}
