import SwiftUI

struct LookResultView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let look: MakeupLook

    @State private var showingShareSheet = false
    @State private var showingSocialShare = false
    @State private var generatedImageURL: String?
    @State private var isGeneratingImage = false
    @State private var imageError: String?

    // Image generation state
    @State private var geminiImageData: String?

    private let lookService = LookGeneratorService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Reference Image (AI-generated)
                    referenceImageSection

                    // Color Palette
                    colorPaletteSection

                    // Steps
                    stepsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(look.lookName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            toggleSave()
                        } label: {
                            Image(systemName: appState.isLookSaved(look) ? "heart.fill" : "heart")
                                .foregroundColor(.pink)
                        }

                        Menu {
                            Button {
                                HapticManager.selectionChanged()
                                showingSocialShare = true
                            } label: {
                                Label("Share to Social", systemImage: "camera.fill")
                            }

                            Button {
                                HapticManager.selectionChanged()
                                showingShareSheet = true
                            } label: {
                                Label("Share as Text", systemImage: "doc.text")
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [generateShareText()])
            }
            .sheet(isPresented: $showingSocialShare) {
                SocialShareView(look: look)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Vibe badge
            Text(look.vibe)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)

            // Context
            HStack {
                Label(look.occasion.displayName, systemImage: look.occasion.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("•")
                    .foregroundColor(.secondary)

                Label(look.mood.displayName, systemImage: look.mood.icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Reference Image Section

    @ViewBuilder
    private var referenceImageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reference Image")
                    .font(.headline)

                Spacer()

                if APIConfig.geminiAPIKey != nil {
                    Text("Powered by Gemini")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Gemini generated image
            if let imageData = geminiImageData {
                Base64ImageView(base64String: imageData)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            } else if isGeneratingImage {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                        .scaleEffect(1.2)
                    Text("Generating your look...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("This may take up to 30 seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color.pink.opacity(0.1), Color.purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            } else if APIConfig.useImageGeneration {
                // Generate button
                Button {
                    generateGeminiImage()
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate Reference Image")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }

                if let error = imageError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            } else {
                // No API key - show placeholder
                VStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Image generation unavailable")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Add API key to enable this feature")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .onAppear {
            // Track in history
            appState.addToHistory(look)
        }
    }

    // MARK: - Color Palette Section

    private var colorPaletteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Palette")
                .font(.headline)

            HStack(spacing: 12) {
                ColorSwatchView(spec: look.colorPalette.eyeshadow, label: "Eyes")
                ColorSwatchView(spec: look.colorPalette.lips, label: "Lips")
                ColorSwatchView(spec: look.colorPalette.blush, label: "Blush")
                ColorSwatchView(spec: look.colorPalette.brows, label: "Brows")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Steps Section

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step-by-Step Guide")
                .font(.headline)

            ForEach(Array(look.steps.enumerated()), id: \.element.id) { index, step in
                StepCard(step: step, number: index + 1)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Actions

    private func toggleSave() {
        if appState.isLookSaved(look) {
            HapticManager.lightImpact()
            appState.removeLook(look)
        } else {
            // Check if user can save (free tier limit check)
            guard appState.canSaveLookOrShowPaywall() else { return }
            HapticManager.doubleTap()
            appState.saveLook(look)
        }
    }

    private func generateImage() {
        guard !isGeneratingImage else { return }

        HapticManager.mediumImpact()
        isGeneratingImage = true
        imageError = nil

        Task {
            do {
                let imageURL = try await lookService.generateLookImage(for: look)
                await MainActor.run {
                    HapticManager.success()
                    self.generatedImageURL = imageURL
                    self.isGeneratingImage = false
                }
            } catch {
                await MainActor.run {
                    HapticManager.error()
                    self.imageError = "Failed to generate image. Please try again."
                    self.isGeneratingImage = false
                }
            }
        }
    }

    private func generateGeminiImage() {
        guard !isGeneratingImage else { return }

        HapticManager.mediumImpact()
        isGeneratingImage = true
        imageError = nil

        Task {
            do {
                let imageData = try await lookService.generateLookImage(for: look)
                await MainActor.run {
                    HapticManager.success()
                    self.geminiImageData = imageData
                    self.isGeneratingImage = false
                }
            } catch {
                await MainActor.run {
                    HapticManager.error()
                    self.imageError = "Failed to generate image. Please try again."
                    self.isGeneratingImage = false
                }
            }
        }
    }

    private func generateShareText() -> String {
        """
        My \(look.lookName) Look from GlowGuide

        \(look.vibe)
        For: \(look.occasion.displayName) | Mood: \(look.mood.displayName)

        Colors:
        - Eyes: \(look.colorPalette.eyeshadow.name)
        - Lips: \(look.colorPalette.lips.name)
        - Blush: \(look.colorPalette.blush.name)

        Steps:
        \(look.steps.enumerated().map { "\($0.offset + 1). \($0.element.area): \($0.element.instruction)" }.joined(separator: "\n"))

        Created with GlowGuide
        """
    }
}

// MARK: - Step Card

struct StepCard: View {
    let step: MakeupStep
    let number: Int

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Number badge
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.pink)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: step.icon)
                            .foregroundColor(.pink)
                        Text(step.area)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text(step.instruction)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(isExpanded ? nil : 2)
                }

                Spacer()

                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }

            // Tip (shown when expanded)
            if isExpanded, let tip = step.tip {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text(tip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.leading, 36)
                .transition(.opacity)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Base64 Image View

struct Base64ImageView: View {
    let base64String: String

    var body: some View {
        if let image = decodeBase64Image() {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            VStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text("Decode error")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private func decodeBase64Image() -> UIImage? {
        // Handle data URL format: data:image/png;base64,xxxxx
        var base64Data = base64String

        if base64String.contains(",") {
            base64Data = String(base64String.split(separator: ",").last ?? "")
        }

        guard let data = Data(base64Encoded: base64Data) else {
            return nil
        }

        return UIImage(data: data)
    }
}

#Preview {
    LookResultView(look: .sample)
        .environmentObject(AppState())
}
