import SwiftUI

// MARK: - Animated Splash Screen View

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showSparkles = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var sparkleRotation: Double = 0

    let onComplete: () -> Void

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

            // Radial glow
            RadialGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .scaleEffect(isAnimating ? 1.5 : 0.5)
            .opacity(isAnimating ? 0.5 : 0)

            VStack(spacing: 16) {
                // Logo with sparkles
                ZStack {
                    // Rotating sparkle ring
                    ForEach(0..<8) { i in
                        SparkleIcon()
                            .offset(y: -80)
                            .rotationEffect(.degrees(Double(i) * 45 + sparkleRotation))
                            .opacity(showSparkles ? 0.8 : 0)
                    }

                    // Main logo text
                    Text("GlowGuide")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Tagline
                Text("AI-Powered Beauty")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(taglineOpacity)

                // Loading indicator
                if isAnimating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                        .padding(.top, 30)
                        .opacity(taglineOpacity)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Logo fade in and scale
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
            isAnimating = true
        }

        // Tagline fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            taglineOpacity = 1.0
        }

        // Sparkles appear and rotate
        withAnimation(.easeOut(duration: 0.3).delay(0.5)) {
            showSparkles = true
        }

        // Continuous sparkle rotation
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }

        // Complete splash after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                onComplete()
            }
        }
    }
}

// MARK: - Sparkle Icon

struct SparkleIcon: View {
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 16, weight: .light))
            .foregroundColor(.white)
    }
}

// MARK: - Root View with Splash

struct RootView: View {
    @StateObject private var appState = AppState()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // Main app content
            Group {
                if appState.userProfile.hasCompletedOnboarding {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(appState)
            .opacity(showSplash ? 0 : 1)

            // Splash overlay
            if showSplash {
                SplashView {
                    showSplash = false
                }
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Previews

#Preview("Splash Screen") {
    SplashView {
        print("Splash complete")
    }
}

#Preview("Root View") {
    RootView()
}
