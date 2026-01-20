import SwiftUI

@main
struct GlowGuideApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.userProfile.hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: appState.userProfile.hasCompletedOnboarding)
        .sheet(isPresented: $appState.showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
