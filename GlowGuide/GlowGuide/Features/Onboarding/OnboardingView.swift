import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep = 0
    @State private var selectedSkinTone: SkinTone = .medium
    @State private var selectedStyle: StylePreference = .natural

    // Animation states
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var buttonsOpacity: Double = 0

    private let totalSteps = 3

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator (hidden on welcome screen)
            if currentStep > 0 {
                HStack(spacing: 8) {
                    ForEach(1..<totalSteps) { index in
                        Capsule()
                            .fill(index <= currentStep ? Color.pink : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            TabView(selection: $currentStep) {
                // Step 0: Welcome
                welcomeStep
                    .tag(0)

                // Step 1: Skin Tone
                skinToneStep
                    .tag(1)

                // Step 2: Style Preference
                styleStep
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.4), value: currentStep)
        }
        .background(
            LinearGradient(
                colors: [Color.pink.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    // MARK: - Welcome Step

    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Spacer()

            // Animated logo/icon
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.pink.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity * 0.5)

                // Main icon
                Image(systemName: "sparkles")
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                    titleOffset = 0
                    titleOpacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
                    buttonsOpacity = 1.0
                }
            }

            VStack(spacing: 16) {
                Text("GlowGuide")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)

                Text("Your AI-Powered Makeup Artist")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .offset(y: titleOffset)
                    .opacity(titleOpacity)
            }

            Spacer()

            VStack(spacing: 20) {
                // Feature highlights
                VStack(spacing: 16) {
                    FeatureRow(icon: "wand.and.stars", text: "Personalized looks for any occasion")
                    FeatureRow(icon: "paintpalette", text: "Colors matched to your skin tone")
                    FeatureRow(icon: "list.bullet.clipboard", text: "Step-by-step application guides")
                }
                .padding(.horizontal, 40)
                .opacity(buttonsOpacity)

                Spacer().frame(height: 20)

                Button {
                    HapticManager.mediumImpact()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep = 1
                    }
                } label: {
                    HStack {
                        Text("Get Started")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
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
                    .shadow(color: .pink.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 40)
                .opacity(buttonsOpacity)
            }
            .padding(.bottom, 50)
        }
    }

    // MARK: - Skin Tone Step

    private var skinToneStep: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 8)

                Text("What's your skin tone?")
                    .font(.title)
                    .fontWeight(.bold)

                Text("This helps us recommend the perfect colors for you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(SkinTone.allCases) { tone in
                    SkinToneButton(
                        tone: tone,
                        isSelected: selectedSkinTone == tone
                    ) {
                        HapticManager.selectionChanged()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSkinTone = tone
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    HapticManager.mediumImpact()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep = 2
                    }
                } label: {
                    Text("Continue")
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
                        .shadow(color: .pink.opacity(0.3), radius: 8, y: 4)
                }

                Button {
                    HapticManager.lightImpact()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep = 0
                    }
                } label: {
                    Text("Back")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Style Step

    private var styleStep: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "paintbrush.pointed")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 8)

                Text("Your Style")
                    .font(.title)
                    .fontWeight(.bold)

                Text("How would you describe your makeup style?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(StylePreference.allCases) { style in
                    StyleButton(
                        style: style,
                        isSelected: selectedStyle == style
                    ) {
                        HapticManager.selectionChanged()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedStyle = style
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    HapticManager.success()
                    HapticManager.celebration()
                    appState.completeOnboarding(
                        skinTone: selectedSkinTone,
                        stylePreference: selectedStyle
                    )
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Let's Glow!")
                            .font(.headline)
                    }
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
                    .shadow(color: .pink.opacity(0.3), radius: 8, y: 4)
                }

                Button {
                    HapticManager.lightImpact()
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentStep = 1
                    }
                } label: {
                    Text("Back")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - Supporting Views

struct SkinToneButton: View {
    let tone: SkinTone
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(tone.color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 3)
                    )
                    .shadow(color: isSelected ? Color.pink.opacity(0.4) : .black.opacity(0.1), radius: isSelected ? 8 : 4)
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(tone.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .pink : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct StyleButton: View {
    let style: StylePreference
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: style.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .white : .pink)

                Text(style.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: isSelected ? .pink.opacity(0.3) : .black.opacity(0.05), radius: isSelected ? 10 : 8, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
