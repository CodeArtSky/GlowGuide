import SwiftUI

// MARK: - App Icon Design View
// This view can be rendered at 1024x1024 to export as an app icon

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient (pink to purple)
            LinearGradient(
                colors: [
                    Color(red: 0.949, green: 0.325, blue: 0.541),  // #F2538A - Pink
                    Color(red: 0.600, green: 0.200, blue: 0.800)   // #9933CC - Purple
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle radial glow effect
            RadialGradient(
                colors: [
                    Color.white.opacity(0.25),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 600
            )
            // Main icon design
            VStack(spacing: 0) {
                // Sparkle/glow symbol representing AI beauty
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 40
                        )
                        .frame(width: 500, height: 500)

                    // Inner filled circle (face silhouette area)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.95),
                                    Color.white.opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 380, height: 380)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)

                    // Stylized "G" letter with sparkle
                    Text("G")
                        .font(.system(size: 280, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.949, green: 0.325, blue: 0.541),
                                    Color(red: 0.600, green: 0.200, blue: 0.800)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .offset(x: 10)

                    // Sparkle accents
                    SparkleView()
                        .offset(x: 150, y: -140)

                    SparkleView(size: 40)
                        .offset(x: -180, y: 100)

                    SparkleView(size: 30)
                        .offset(x: 170, y: 150)
                }
            }
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 0)) // iOS handles corner radius
    }
}

// MARK: - Sparkle Accent View

struct SparkleView: View {
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            // 4-point star sparkle
            ForEach(0..<4) { i in
                Capsule()
                    .fill(Color.white)
                    .frame(width: size * 0.2, height: size)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
        .shadow(color: Color.white.opacity(0.8), radius: 10)
    }
}

// MARK: - Alternative Icon (Lipstick Design)

struct AppIconAlternativeView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.949, green: 0.325, blue: 0.541),
                    Color(red: 0.700, green: 0.200, blue: 0.600)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle pattern overlay
            RadialGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 800
            )

            // Makeup brush/wand icon
            VStack(spacing: -20) {
                // Brush tip (sparkle effect)
                ZStack {
                    // Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white,
                                    Color.white.opacity(0.5),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 180
                            )
                        )
                        .frame(width: 360, height: 360)

                    // Main sparkle
                    Image(systemName: "sparkle")
                        .font(.system(size: 200, weight: .regular))
                        .foregroundColor(.white)
                        .shadow(color: Color.white.opacity(0.8), radius: 30)
                }

                // Handle (subtle)
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 300)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            }
            .offset(y: 50)

            // Small sparkle accents
            SparkleView(size: 50)
                .offset(x: -280, y: -280)

            SparkleView(size: 35)
                .offset(x: 300, y: -200)

            SparkleView(size: 25)
                .offset(x: -200, y: 300)
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - Icon Export Helper

struct AppIconExportView: View {
    @State private var selectedStyle = 0
    @State private var exportedImage: UIImage?
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("App Icon Preview")
                    .font(.headline)

                // Preview at scaled size
                Group {
                    if selectedStyle == 0 {
                        AppIconView()
                    } else {
                        AppIconAlternativeView()
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 44))
                .shadow(radius: 10)

                // Style picker
                Picker("Style", selection: $selectedStyle) {
                    Text("Letter G").tag(0)
                    Text("Sparkle Wand").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Export button
                Button {
                    exportIcon()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export 1024x1024 PNG")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }

                Text("Export the icon and add it to Assets.xcassets/AppIcon.appiconset/")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Icon Generator")
            .sheet(isPresented: $showingShareSheet) {
                if let image = exportedImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }

    @MainActor
    private func exportIcon() {
        let iconView: any View = selectedStyle == 0 ? AppIconView() : AppIconAlternativeView()
        let renderer = ImageRenderer(content: AnyView(iconView.frame(width: 1024, height: 1024)))
        renderer.scale = 1.0

        if let image = renderer.uiImage {
            exportedImage = image
            showingShareSheet = true
        }
    }
}

#Preview("App Icon - Letter G") {
    AppIconView()
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 44))
}

#Preview("App Icon - Sparkle Wand") {
    AppIconAlternativeView()
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 44))
}

#Preview("Icon Export Tool") {
    AppIconExportView()
}
