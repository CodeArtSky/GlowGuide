import Foundation
import StoreKit
import Combine

// MARK: - Subscription Status

enum SubscriptionStatus: String, Codable {
    case none
    case monthly
    case yearly
    case lifetime
    case trial
}

// MARK: - Subscription Manager

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    // Product IDs (must match App Store Connect)
    private let monthlyProductID = "com.glowguide.pro.monthly"
    private let yearlyProductID = "com.glowguide.pro.yearly"
    private let lifetimeProductID = "com.glowguide.pro.lifetime"

    // Published properties
    @Published var subscriptionStatus: SubscriptionStatus = .none
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Usage tracking for free tier (lifetime totals until subscription)
    @Published var looksGenerated: Int = 0
    @Published var savedLooksCount: Int = 0

    // Free tier limits (total, not daily)
    let freeLookLimit = 3
    let freeSavedLookLimit = 3

    // Storage keys
    private let usageKey = "GlowGuide.LooksGenerated"
    private let savedCountKey = "GlowGuide.SavedLooksCount"

    private var updateListenerTask: Task<Void, Error>?

    init() {
        loadUsageData()
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public Properties

    var isPro: Bool {
        subscriptionStatus != .none
    }

    var canGenerateLook: Bool {
        isPro || looksGenerated < freeLookLimit
    }

    var canSaveLook: Bool {
        isPro || savedLooksCount < freeSavedLookLimit
    }

    var remainingFreeLooks: Int {
        max(0, freeLookLimit - looksGenerated)
    }

    var remainingSavedSlots: Int {
        max(0, freeSavedLookLimit - savedLooksCount)
    }

    // MARK: - Product Loading

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let productIDs: Set<String> = [monthlyProductID, yearlyProductID, lifetimeProductID]
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
            print("Loaded \(products.count) products")
        } catch {
            print("Failed to load products: \(error)")
            errorMessage = "Failed to load subscription options"
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return transaction

        case .userCancelled:
            return nil

        case .pending:
            return nil

        @unknown default:
            return nil
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Restore failed: \(error)")
            errorMessage = "Failed to restore purchases"
        }
    }

    // MARK: - Subscription Status

    func updateSubscriptionStatus() async {
        var newStatus: SubscriptionStatus = .none

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                switch transaction.productID {
                case monthlyProductID:
                    newStatus = .monthly
                case yearlyProductID:
                    newStatus = .yearly
                case lifetimeProductID:
                    newStatus = .lifetime
                default:
                    break
                }

                purchasedProductIDs.insert(transaction.productID)
            }
        }

        subscriptionStatus = newStatus
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Usage Tracking

    func recordLookGeneration() {
        looksGenerated += 1
        saveUsageData()
    }

    func recordSavedLook() {
        savedLooksCount += 1
        saveUsageData()
    }

    func recordRemovedLook() {
        savedLooksCount = max(0, savedLooksCount - 1)
        saveUsageData()
    }

    func syncSavedLooksCount(_ count: Int) {
        savedLooksCount = count
        saveUsageData()
    }

    private func loadUsageData() {
        looksGenerated = UserDefaults.standard.integer(forKey: usageKey)
        savedLooksCount = UserDefaults.standard.integer(forKey: savedCountKey)
    }

    private func saveUsageData() {
        UserDefaults.standard.set(looksGenerated, forKey: usageKey)
        UserDefaults.standard.set(savedLooksCount, forKey: savedCountKey)
    }

    // MARK: - Helper Methods

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    var monthlyProduct: Product? {
        product(for: monthlyProductID)
    }

    var yearlyProduct: Product? {
        product(for: yearlyProductID)
    }

    var lifetimeProduct: Product? {
        product(for: lifetimeProductID)
    }

    var yearlySavingsPercent: Int {
        guard let monthly = monthlyProduct, let yearly = yearlyProduct else { return 0 }
        let monthlyAnnual = monthly.price * 12
        let savings = (monthlyAnnual - yearly.price) / monthlyAnnual * 100
        return Int(NSDecimalNumber(decimal: savings).doubleValue.rounded())
    }

    // MARK: - Debug/Testing

    #if DEBUG
    /// Reset subscription status for testing (clears StoreKit test transactions)
    func resetForTesting() {
        subscriptionStatus = .none
        purchasedProductIDs.removeAll()
        looksGenerated = 0
        savedLooksCount = 0
        saveUsageData()
        print("[SubscriptionManager] Reset for testing - subscription status cleared")
    }
    #endif
}

// MARK: - Store Errors

enum StoreError: Error, LocalizedError {
    case verificationFailed
    case purchaseFailed
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed"
        case .purchaseFailed:
            return "Purchase could not be completed"
        case .productNotFound:
            return "Product not found"
        }
    }
}

// MARK: - Product Extensions

extension Product {
    var displayPricePerMonth: String {
        switch id {
        case "com.glowguide.pro.monthly":
            return displayPrice + "/mo"
        case "com.glowguide.pro.yearly":
            let monthlyPrice = price / 12
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = priceFormatStyle.locale
            return (formatter.string(from: monthlyPrice as NSDecimalNumber) ?? "") + "/mo"
        case "com.glowguide.pro.lifetime":
            return "One-time"
        default:
            return displayPrice
        }
    }

    var subscriptionPeriodText: String {
        switch id {
        case "com.glowguide.pro.monthly":
            return "Monthly"
        case "com.glowguide.pro.yearly":
            return "Yearly"
        case "com.glowguide.pro.lifetime":
            return "Lifetime"
        default:
            return ""
        }
    }
}
