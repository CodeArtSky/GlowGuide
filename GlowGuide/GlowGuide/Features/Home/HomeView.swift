import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedOccasion: Occasion?
    @State private var selectedMood: Mood?
    @State private var showingResult = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection

                    // Occasion Selection
                    occasionSection

                    // Mood Selection
                    if selectedOccasion != nil {
                        moodSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Generate Button
                    if selectedOccasion != nil && selectedMood != nil {
                        generateButton
                            .transition(.scale.combined(with: .opacity))
                    }

                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.pink.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SavedLooksView()
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        NavigationLink {
                            HistoryView()
                        } label: {
                            Label("Recent Looks", systemImage: "clock.arrow.circlepath")
                        }

                        Divider()

                        Button("Reset Onboarding") {
                            appState.resetOnboarding()
                        }

                        #if DEBUG
                        Divider()

                        Button("Reset Subscription (Debug)") {
                            appState.subscriptionManager.resetForTesting()
                        }
                        #endif
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showingResult) {
                if let look = appState.currentLook {
                    LookResultView(look: look)
                }
            }
            .sheet(isPresented: $appState.showPaywall) {
                PaywallView()
            }
        }
        .animation(.spring(response: 0.4), value: selectedOccasion)
        .animation(.spring(response: 0.4), value: selectedMood)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("GlowGuide")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("What's the occasion?")
                .font(.title3)
                .foregroundColor(.secondary)

            // Free tier usage indicator
            FreeTierUsageView(subscriptionManager: appState.subscriptionManager)
                .padding(.top, 8)
        }
        .padding(.top, 20)
    }

    // MARK: - Occasion Section

    private var occasionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("I'm going to...")
                .font(.headline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Occasion.allCases) { occasion in
                    OccasionCard(
                        occasion: occasion,
                        isSelected: selectedOccasion == occasion
                    ) {
                        HapticManager.selectionChanged()
                        withAnimation {
                            selectedOccasion = occasion
                            if selectedOccasion != occasion {
                                selectedMood = nil
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Mood Section

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("I want to feel...")
                .font(.headline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Mood.allCases) { mood in
                    MoodChip(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        HapticManager.selectionChanged()
                        withAnimation {
                            selectedMood = mood
                        }
                    }
                }
            }
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            generateLook()
        } label: {
            HStack {
                if appState.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                    Text("Get My Look")
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
        .disabled(appState.isLoading)
        .padding(.top, 20)
    }

    // MARK: - Actions

    private func generateLook() {
        guard let occasion = selectedOccasion, let mood = selectedMood else { return }

        // Check if user can generate (free tier limit check)
        guard appState.canGenerateLookOrShowPaywall() else { return }

        HapticManager.mediumImpact()
        Task {
            await appState.generateLook(occasion: occasion, mood: mood)
            appState.recordLookGeneration() // Track the generation for free tier
            HapticManager.success()
            showingResult = true
        }
    }
}

// MARK: - Supporting Views

struct OccasionCard: View {
    let occasion: Occasion
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: occasion.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : occasion.color)

                Text(occasion.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? occasion.color : Color.white)
            .cornerRadius(16)
            .shadow(color: isSelected ? occasion.color.opacity(0.3) : .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

struct MoodChip: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mood.icon)
                    .font(.system(size: 20))

                Text(mood.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(isSelected ? .white : mood.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? mood.color : mood.color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
