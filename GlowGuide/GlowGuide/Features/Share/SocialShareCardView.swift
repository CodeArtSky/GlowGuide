import SwiftUI

// MARK: - Social Share Card View (Instagram Stories / TikTok format)
struct SocialShareCardView: View {
    let look: MakeupLook
    let cardStyle: ShareCardStyle

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient based on style
                cardStyle.backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top section with logo
                    headerSection
                        .padding(.top, 60)

                    Spacer()

                    // Main content area
                    mainContentSection

                    Spacer()

                    // Color palette section
                    colorPaletteSection
                        .padding(.vertical, 24)

                    // Quick steps preview
                    stepsPreviewSection

                    Spacer()

                    // Footer with branding
                    footerSection
                        .padding(.bottom, 60)
                }
                .padding(.horizontal, 32)
            }
        }
        .frame(width: 1080, height: 1920) // Instagram Stories dimensions
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("GlowGuide")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: cardStyle.accentColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("AI-Powered Beauty")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    // MARK: - Main Content Section

    private var mainContentSection: some View {
        VStack(spacing: 24) {
            // Look name
            Text(look.lookName)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Vibe badge
            Text(look.vibe)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: cardStyle.accentColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: cardStyle.accentColors[0].opacity(0.5), radius: 20, y: 10)
                )

            // Occasion & Mood tags
            HStack(spacing: 16) {
                TagView(icon: look.occasion.icon, text: look.occasion.displayName, style: cardStyle)
                TagView(icon: look.mood.icon, text: look.mood.displayName, style: cardStyle)
            }
        }
    }

    // MARK: - Color Palette Section

    private var colorPaletteSection: some View {
        VStack(spacing: 20) {
            Text("COLOR PALETTE")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(4)

            HStack(spacing: 24) {
                ColorCircle(spec: look.colorPalette.eyeshadow, label: "Eyes")
                ColorCircle(spec: look.colorPalette.lips, label: "Lips")
                ColorCircle(spec: look.colorPalette.blush, label: "Blush")
                ColorCircle(spec: look.colorPalette.brows, label: "Brows")
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Steps Preview Section

    private var stepsPreviewSection: some View {
        VStack(spacing: 16) {
            Text("QUICK STEPS")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(4)

            VStack(spacing: 12) {
                ForEach(Array(look.steps.prefix(4).enumerated()), id: \.element.id) { index, step in
                    HStack(spacing: 16) {
                        // Step number
                        Text("\(index + 1)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: cardStyle.accentColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )

                        // Step area
                        Text(step.area)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        // Step icon
                        Image(systemName: step.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.08))
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.white.opacity(0.05))
        )
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("Get your personalized look")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Text("Download GlowGuide")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: cardStyle.accentColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
}

// MARK: - Supporting Views

struct TagView: View {
    let icon: String
    let text: String
    let style: ShareCardStyle

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(text)
                .font(.system(size: 22, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.white.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ColorCircle: View {
    let spec: ColorSpec
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(spec.color)
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 3)
                )
                .shadow(color: spec.color.opacity(0.5), radius: 12, y: 6)

            Text(label)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Share Card Styles

enum ShareCardStyle: String, CaseIterable, Identifiable {
    case glam
    case natural
    case bold
    case soft

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .glam: return "Glam"
        case .natural: return "Natural"
        case .bold: return "Bold"
        case .soft: return "Soft"
        }
    }

    var backgroundGradient: LinearGradient {
        switch self {
        case .glam:
            return LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16213E"), Color(hex: "0F3460")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .natural:
            return LinearGradient(
                colors: [Color(hex: "2D3436"), Color(hex: "636E72"), Color(hex: "B2BEC3")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .bold:
            return LinearGradient(
                colors: [Color(hex: "2C003E"), Color(hex: "512B58"), Color(hex: "8B2635")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .soft:
            return LinearGradient(
                colors: [Color(hex: "3A1C71"), Color(hex: "D76D77"), Color(hex: "FFAF7B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var accentColors: [Color] {
        switch self {
        case .glam:
            return [Color(hex: "E94560"), Color(hex: "FF6B6B")]
        case .natural:
            return [Color(hex: "81ECEC"), Color(hex: "74B9FF")]
        case .bold:
            return [Color(hex: "FF6B6B"), Color(hex: "FFA502")]
        case .soft:
            return [Color(hex: "FDA7DF"), Color(hex: "D980FA")]
        }
    }
}

// MARK: - Image Renderer Extension

extension View {
    @MainActor
    func renderToImage(scale: CGFloat = 1.0) -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        return renderer.uiImage
    }
}

// MARK: - Social Share Sheet View

struct SocialShareView: View {
    let look: MakeupLook
    @Environment(\.dismiss) var dismiss

    @State private var selectedStyle: ShareCardStyle = .glam
    @State private var isRendering = false
    @State private var renderedImage: UIImage?
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Preview card (scaled down)
                ScrollView {
                    VStack(spacing: 24) {
                        // Card preview
                        SocialShareCardView(look: look, cardStyle: selectedStyle)
                            .frame(width: 270, height: 480) // Scaled preview
                            .scaleEffect(0.25)
                            .frame(width: 270, height: 480)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)

                        // Style selector
                        styleSelector

                        // Share button
                        shareButton
                            .padding(.top, 16)
                    }
                    .padding()
                }
            }
            .navigationTitle("Share to Social")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = renderedImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }

    // MARK: - Style Selector

    private var styleSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Style")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(ShareCardStyle.allCases) { style in
                    CardStyleButton(
                        style: style,
                        isSelected: selectedStyle == style
                    ) {
                        HapticManager.selectionChanged()
                        withAnimation(.spring(response: 0.3)) {
                            selectedStyle = style
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            generateAndShare()
        } label: {
            HStack {
                if isRendering {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share to Instagram / TikTok")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.pink, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .pink.opacity(0.3), radius: 12, y: 6)
        }
        .disabled(isRendering)
    }

    // MARK: - Actions

    @MainActor
    private func generateAndShare() {
        isRendering = true
        HapticManager.mediumImpact()

        // Create the full-size card for rendering
        let cardView = SocialShareCardView(look: look, cardStyle: selectedStyle)

        // Render to image at proper scale
        if let image = cardView.renderToImage(scale: 1.0) {
            renderedImage = image
            isRendering = false
            HapticManager.success()
            showingShareSheet = true
        } else {
            isRendering = false
            HapticManager.error()
        }
    }
}

// MARK: - Card Style Button

struct CardStyleButton: View {
    let style: ShareCardStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Mini gradient preview
                RoundedRectangle(cornerRadius: 8)
                    .fill(style.backgroundGradient)
                    .frame(width: 60, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? style.accentColors[0] : .clear, lineWidth: 3)
                    )

                Text(style.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .pink : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SocialShareView(look: .sample)
}
