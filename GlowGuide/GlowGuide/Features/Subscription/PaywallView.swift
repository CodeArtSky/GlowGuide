import SwiftUI
import StoreKit

// MARK: - Paywall View

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Features list
                    featuresSection

                    // Pricing options
                    pricingSection

                    // Purchase button
                    purchaseButton

                    // Restore purchases
                    restoreButton

                    // Terms
                    termsSection
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.97),
                        Color(red: 0.95, green: 0.92, blue: 0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray.opacity(0.6))
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Pre-select yearly as best value
                if let yearly = subscriptionManager.yearlyProduct {
                    selectedProduct = yearly
                } else if let monthly = subscriptionManager.monthlyProduct {
                    selectedProduct = monthly
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            // Crown icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .shadow(color: .pink.opacity(0.3), radius: 20, y: 10)

            Text("Unlock GlowGuide Pro")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("Get unlimited AI-powered beauty recommendations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(spacing: 16) {
            PaywallFeatureRow(icon: "sparkles", text: "Unlimited look generations", iconColor: .pink)
            PaywallFeatureRow(icon: "paintpalette.fill", text: "All 8 occasions & moods", iconColor: .purple)
            PaywallFeatureRow(icon: "photo.artframe", text: "AI-generated reference images", iconColor: .blue)
            PaywallFeatureRow(icon: "heart.fill", text: "Save unlimited favorite looks", iconColor: .red)
            PaywallFeatureRow(icon: "square.and.arrow.up", text: "Premium social templates", iconColor: .orange)
            PaywallFeatureRow(icon: "xmark.circle", text: "No advertisements", iconColor: .green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if subscriptionManager.isLoading {
                ProgressView()
                    .padding()
            } else if subscriptionManager.products.isEmpty {
                VStack(spacing: 12) {
                    Text("Unable to load subscription options")
                        .foregroundColor(.secondary)

                    #if DEBUG
                    Text("Configure StoreKit in Xcode:\nEdit Scheme → Run → Options → StoreKit Configuration")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                    #endif

                    Button("Retry") {
                        Task {
                            await subscriptionManager.loadProducts()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                // Yearly option (highlighted)
                if let yearly = subscriptionManager.yearlyProduct {
                    PricingOptionCard(
                        product: yearly,
                        title: "Yearly",
                        subtitle: yearly.displayPrice + "/year",
                        badge: "SAVE 50%",
                        perMonthPrice: subscriptionManager.yearlyProduct?.displayPricePerMonth,
                        isSelected: selectedProduct?.id == yearly.id,
                        isPopular: true
                    ) {
                        HapticManager.selectionChanged()
                        selectedProduct = yearly
                    }
                }

                // Monthly option
                if let monthly = subscriptionManager.monthlyProduct {
                    PricingOptionCard(
                        product: monthly,
                        title: "Monthly",
                        subtitle: monthly.displayPrice + "/month",
                        badge: nil,
                        perMonthPrice: nil,
                        isSelected: selectedProduct?.id == monthly.id,
                        isPopular: false
                    ) {
                        HapticManager.selectionChanged()
                        selectedProduct = monthly
                    }
                }

                // Lifetime option
                if let lifetime = subscriptionManager.lifetimeProduct {
                    PricingOptionCard(
                        product: lifetime,
                        title: "Lifetime",
                        subtitle: lifetime.displayPrice + " once",
                        badge: "BEST VALUE",
                        perMonthPrice: nil,
                        isSelected: selectedProduct?.id == lifetime.id,
                        isPopular: false
                    ) {
                        HapticManager.selectionChanged()
                        selectedProduct = lifetime
                    }
                }
            }
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            Task {
                await purchase()
            }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Continue")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.pink, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: .pink.opacity(0.3), radius: 10, y: 5)
        }
        .disabled(selectedProduct == nil || isPurchasing)
        .opacity(selectedProduct == nil ? 0.6 : 1)
    }

    // MARK: - Restore Button

    private var restoreButton: some View {
        Button {
            Task {
                await restore()
            }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Terms Section

    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in Settings.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Terms of Service") {
                    if let url = URL(string: "https://codeartsky.github.io/GlowGuide/terms-of-service.html") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)

                Button("Privacy Policy") {
                    if let url = URL(string: "https://codeartsky.github.io/GlowGuide/privacy-policy.html") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
            }
            .foregroundColor(.pink)
        }
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func purchase() async {
        guard let product = selectedProduct else { return }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let transaction = try await subscriptionManager.purchase(product)
            if transaction != nil {
                HapticManager.success()
                dismiss()
            }
        } catch {
            HapticManager.error()
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func restore() async {
        isPurchasing = true
        defer { isPurchasing = false }

        await subscriptionManager.restorePurchases()

        if subscriptionManager.isPro {
            HapticManager.success()
            dismiss()
        } else {
            errorMessage = "No previous purchases found"
            showError = true
        }
    }
}

// MARK: - Paywall Feature Row

struct PaywallFeatureRow: View {
    let icon: String
    let text: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 32)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

// MARK: - Pricing Option Card

struct PricingOptionCard: View {
    let product: Product
    let title: String
    let subtitle: String
    let badge: String?
    let perMonthPrice: String?
    let isSelected: Bool
    let isPopular: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let badge = badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.pink, .purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let perMonth = perMonthPrice {
                        Text(perMonth)
                            .font(.caption)
                            .foregroundColor(.pink)
                    }
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.pink : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: isSelected ? .pink.opacity(0.2) : .black.opacity(0.05), radius: isSelected ? 8 : 4, y: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Upgrade Prompt View (for inline prompts)

struct UpgradePromptView: View {
    let title: String
    let message: String
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onUpgrade) {
                Text("Upgrade to Pro")
                    .fontWeight(.semibold)
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
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .padding()
    }
}

// MARK: - Free Tier Usage View

struct FreeTierUsageView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager

    var body: some View {
        if !subscriptionManager.isPro {
            HStack(spacing: 12) {
                // Free looks remaining
                UsagePill(
                    icon: "sparkles",
                    count: subscriptionManager.remainingFreeLooks,
                    total: subscriptionManager.freeLookLimit,
                    label: "looks left"
                )

                // Saved slots remaining
                UsagePill(
                    icon: "heart.fill",
                    count: subscriptionManager.remainingSavedSlots,
                    total: subscriptionManager.freeSavedLookLimit,
                    label: "saves left"
                )
            }
            .padding(.horizontal)
        }
    }
}

struct UsagePill: View {
    let icon: String
    let count: Int
    let total: Int
    let label: String

    private var progress: Double {
        Double(count) / Double(total)
    }

    private var isLow: Bool {
        count <= 1
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isLow ? .orange : .pink)

            Text("\(count)/\(total)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isLow ? Color.orange.opacity(0.1) : Color.pink.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview("Paywall") {
    PaywallView()
}

#Preview("Upgrade Prompt") {
    UpgradePromptView(
        title: "Daily Limit Reached",
        message: "You've used all 3 free looks today. Upgrade to Pro for unlimited access!",
        onUpgrade: { }
    )
}

#Preview("Usage View") {
    FreeTierUsageView(subscriptionManager: SubscriptionManager.shared)
}
