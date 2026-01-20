import Foundation

// MARK: - App Store Metadata
// Use this file to store and organize all App Store submission content

enum AppStoreMetadata {

    // MARK: - App Information

    static let appName = "GlowGuide"
    static let subtitle = "AI-Powered Beauty Looks"
    static let bundleID = "com.yourcompany.GlowGuide"
    static let category = "Lifestyle"
    static let secondaryCategory = "Photo & Video"

    // MARK: - App Store Description

    static let description = """
    Discover your perfect makeup look with GlowGuide - your AI-powered beauty companion.

    PERSONALIZED LOOKS
    Get makeup recommendations tailored to your skin tone, face shape, and style preferences. Our AI understands your unique beauty profile to suggest looks that complement you perfectly.

    OCCASION-BASED SUGGESTIONS
    Whether you're heading to work, a date night, a wedding, or just a casual brunch, GlowGuide suggests the perfect look for every occasion.

    MOOD-MATCHED BEAUTY
    Tell us how you want to feel - confident, glamorous, natural, or bold - and we'll create a look that matches your mood.

    STEP-BY-STEP GUIDES
    Each look comes with detailed, easy-to-follow instructions. From primer to finishing touches, we guide you through every step.

    COLOR PALETTE RECOMMENDATIONS
    See exactly which shades work best for your coloring with our personalized color palette suggestions for eyes, lips, blush, and brows.

    SAVE & SHARE
    Save your favorite looks to revisit anytime. Share stunning social media-ready cards with friends or on Instagram and TikTok.

    AI-GENERATED REFERENCE IMAGES
    Visualize your look before you start with beautiful AI-generated reference images powered by DALL-E.

    Features:
    - Personalized skin tone and face shape analysis
    - 8 occasion categories (Work, Date, Wedding, Party, and more)
    - 8 mood options to match your vibe
    - Detailed step-by-step makeup tutorials
    - Custom color palette recommendations
    - Save unlimited looks to your favorites
    - Share-ready social media cards
    - Look history to track what you've tried
    - Beautiful, intuitive interface

    GlowGuide makes professional makeup guidance accessible to everyone. Download now and discover the beauty looks that are perfect for you!
    """

    static let promotionalText = "Your AI beauty advisor - personalized makeup looks for every occasion"

    // MARK: - Keywords (100 characters max)

    static let keywords = "makeup,beauty,ai,looks,tutorial,cosmetics,skincare,style,glamour,guide"

    // MARK: - What's New (Version Notes)

    static let whatsNew = """
    - AI-powered personalized makeup recommendations
    - Occasion and mood-based look suggestions
    - Step-by-step makeup tutorials
    - Social media sharing with beautiful cards
    - Save your favorite looks
    - Look history tracking
    """

    // MARK: - Support Information

    static let supportURL = "https://yourwebsite.com/support"
    static let marketingURL = "https://yourwebsite.com"
    static let privacyPolicyURL = "https://yourwebsite.com/privacy"

    // MARK: - Privacy Policy Content

    static let privacyPolicy = """
    GLOWGUIDE PRIVACY POLICY

    Last Updated: January 2026

    1. INFORMATION WE COLLECT

    GlowGuide collects minimal information to provide you with personalized makeup recommendations:

    - Profile Information: Skin tone, face shape, and style preferences you provide during onboarding
    - Usage Data: Looks you've viewed, saved, and shared (stored locally on your device)
    - Analytics: Anonymous usage statistics to improve the app experience

    2. HOW WE USE YOUR INFORMATION

    - To generate personalized makeup look recommendations
    - To save your favorite looks and browsing history
    - To improve our AI recommendation algorithms
    - To provide customer support

    3. DATA STORAGE

    All personal preferences and saved looks are stored locally on your device. We do not store your personal information on external servers.

    4. THIRD-PARTY SERVICES

    GlowGuide uses the following third-party services:
    - OpenAI API: For generating makeup recommendations and reference images
    - Apple's standard analytics (if enabled)

    These services have their own privacy policies that govern their data practices.

    5. DATA SHARING

    We do not sell, trade, or share your personal information with third parties for marketing purposes.

    6. YOUR RIGHTS

    You can:
    - Delete all your data by uninstalling the app
    - Reset your profile preferences at any time within the app
    - Opt out of analytics through your device settings

    7. CHILDREN'S PRIVACY

    GlowGuide is not intended for children under 13. We do not knowingly collect information from children.

    8. CHANGES TO THIS POLICY

    We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy within the app.

    9. CONTACT US

    If you have questions about this privacy policy, please contact us at:
    privacy@yourcompany.com

    By using GlowGuide, you agree to this privacy policy.
    """

    // MARK: - Age Rating Information

    static let ageRating = "4+" // No objectionable content

    // MARK: - Screenshot Captions (for App Store)

    static let screenshotCaptions = [
        "AI-Powered Beauty Recommendations",
        "Choose Your Occasion",
        "Match Your Mood",
        "Step-by-Step Makeup Guide",
        "Personalized Color Palettes",
        "Save Your Favorite Looks",
        "Share to Social Media"
    ]
}

// MARK: - Screenshot Frame Generator

import SwiftUI

struct AppStoreScreenshotView: View {
    let caption: String
    let deviceFrame: DeviceFrame
    let content: AnyView

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.949, green: 0.325, blue: 0.541),
                    Color(red: 0.600, green: 0.200, blue: 0.800)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Caption text
                Text(caption)
                    .font(.system(size: deviceFrame.captionSize, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 60)

                // Device mockup with content
                ZStack {
                    // Device frame
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.black)
                        .frame(width: deviceFrame.frameWidth, height: deviceFrame.frameHeight)

                    // Screen content
                    content
                        .frame(width: deviceFrame.screenWidth, height: deviceFrame.screenHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                }
                .shadow(color: .black.opacity(0.3), radius: 30, y: 20)

                Spacer()
            }
        }
        .frame(width: deviceFrame.canvasWidth, height: deviceFrame.canvasHeight)
    }
}

// MARK: - Device Frame Sizes

enum DeviceFrame {
    case iPhone65 // 6.5" (iPhone 11 Pro Max, 12 Pro Max, etc.)
    case iPhone55 // 5.5" (iPhone 8 Plus, etc.)
    case iPad129  // 12.9" iPad Pro

    var canvasWidth: CGFloat {
        switch self {
        case .iPhone65: return 1284
        case .iPhone55: return 1242
        case .iPad129: return 2048
        }
    }

    var canvasHeight: CGFloat {
        switch self {
        case .iPhone65: return 2778
        case .iPhone55: return 2208
        case .iPad129: return 2732
        }
    }

    var frameWidth: CGFloat {
        switch self {
        case .iPhone65: return 380
        case .iPhone55: return 350
        case .iPad129: return 550
        }
    }

    var frameHeight: CGFloat {
        switch self {
        case .iPhone65: return 780
        case .iPhone55: return 700
        case .iPad129: return 750
        }
    }

    var screenWidth: CGFloat {
        frameWidth - 20
    }

    var screenHeight: CGFloat {
        frameHeight - 30
    }

    var captionSize: CGFloat {
        switch self {
        case .iPhone65: return 64
        case .iPhone55: return 56
        case .iPad129: return 72
        }
    }
}

// MARK: - Screenshot Export Helper

struct ScreenshotExportView: View {
    @State private var selectedDevice: DeviceFrame = .iPhone65

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Device picker
                    Picker("Device", selection: $selectedDevice) {
                        Text("iPhone 6.5\"").tag(DeviceFrame.iPhone65)
                        Text("iPhone 5.5\"").tag(DeviceFrame.iPhone55)
                        Text("iPad 12.9\"").tag(DeviceFrame.iPad129)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // Preview of all screenshots
                    ForEach(Array(AppStoreMetadata.screenshotCaptions.enumerated()), id: \.offset) { index, caption in
                        VStack {
                            Text("Screenshot \(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            AppStoreScreenshotView(
                                caption: caption,
                                deviceFrame: selectedDevice,
                                content: AnyView(
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .overlay(
                                            Text("Screen \(index + 1)")
                                                .foregroundColor(.gray)
                                        )
                                )
                            )
                            .scaleEffect(0.15)
                            .frame(width: 200, height: 400)
                        }
                    }
                }
            }
            .navigationTitle("Screenshot Generator")
        }
    }
}

#Preview("Screenshot Export") {
    ScreenshotExportView()
}
