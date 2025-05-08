

//
//  PaywallViewModel.swift
//  PaywallKit
//
//  Central ViewModel for Paywall. Handles state, product presentation, and purchase/restore logic.
//

import Foundation
import SwiftUI

#if canImport(StoreKit)
import StoreKit
#endif
#if canImport(RevenueCat)
import RevenueCat
#endif

@MainActor
public class PaywallViewModel: ObservableObject {
    // Singleton instance (can use another with .init() if needed)
    public static let shared = PaywallViewModel()

    // MARK: - State

    /// All available products/packages (StoreKit2 or RevenueCat, depending on engine)
    @Published private(set) var storeKitProducts: [ProductID: StoreKit.Product] = [:]
    @Published private(set) var revenueCatPackages: [ProductID: Package] = [:]

    /// Current error message (to show on Alert)
    @Published public var errorMessage: String?
    /// True if currently loading any initial data (incl. products)
    @Published public var isLoadingInitial: Bool = false
    /// If a purchase is in progress
    @Published public var isPurchasing: Bool = false
    /// Show Error Alert
    @Published public var hasError: Bool = false
    /// The Product being purchased (for button loading)
    @Published public var selectedProductId: ProductID?

    // MARK: - Product Display Order

    /// Order in which products appear on UI (could be configured, or sorted)
    public var productDisplayOrder: [ProductID] {
        // Default: order as in config, or sorted
        Array(loadedProductIDs)
    }

    /// Tracks which products are available for purchase (after loading)
    private var loadedProductIDs: Set<ProductID> = []

    // MARK: - Internal

    private let purchaseManager: PurchaseManagerProtocol

    public init(purchaseManager: PurchaseManagerProtocol? = nil) {
        self.purchaseManager = purchaseManager ?? PurchaseManager()
        Task { await self.loadProducts() }
    }

    // MARK: - Load Products

    /// Load products from the engine, populating either storeKitProducts or revenueCatPackages
    public func loadProducts() async {
        errorMessage = nil
        isLoadingInitial = true
        defer { isLoadingInitial = false }
        await withCheckedContinuation { continuation in
            purchaseManager.initialize { [weak self] result in
                guard let self else {
                    continuation.resume()
                    return
                }
                switch result {
                case .success():
                    self.populateProductsFromEngine()
                    self.loadedProductIDs = Set(self._allLoadedProductIDs())
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
                }
                continuation.resume()
            }
        }
    }

    /// Called after successful engine initialize to fetch products into dictionary
    private func populateProductsFromEngine() {
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            #if canImport(StoreKit)
            if let manager = purchaseManager as? StoreKitPurchaseManager {
                self.storeKitProducts = manager.products
            }
            #endif
        case .revenueCat:
            #if canImport(RevenueCat)
            if let manager = purchaseManager as? RevenueCatPurchaseManager {
                self.revenueCatPackages = manager.products
            }
            #endif
        }
    }

    /// Returns all currently loaded ProductIDs for display purposes
    private func _allLoadedProductIDs() -> [ProductID] {
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            return Array(storeKitProducts.keys)
        case .revenueCat:
            return Array(revenueCatPackages.keys)
        }
    }

    // MARK: - UI Text Builders

    /// Returns the composed StoreKit or RevenueCat title + price for the provided productID. (Never hardcoded)
    public func title(for productId: ProductID) -> String {
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            #if canImport(StoreKit)
            guard let product = storeKitProducts[productId] else { return "" }
            return "\(product.displayName) • \(product.displayPrice)"
            #else
            return ""
            #endif
        case .revenueCat:
            #if canImport(RevenueCat)
            guard let pkg = revenueCatPackages[productId] else { return "" }
            return "\(pkg.product.localizedTitle) • \(pkg.product.localizedPriceString)"
            #else
            return ""
            #endif
        }
    }

    // MARK: - Purchase/Redeem Actions

    /// Start purchase flow for product
    public func purchase(_ productId: ProductID) {
        guard !isPurchasing else { return }
        selectedProductId = productId
        isPurchasing = true
        errorMessage = nil

        purchaseManager.purchase(productID: productId) { [weak self] result in
            guard let self = self else { return }
            self.isPurchasing = false
            self.selectedProductId = nil
            switch result {
            case .success:
                // Purchased – optionally handle events or success popups here
                break
            case .restored:
                // Possibly show a toast or notification
                break
            case .userCancelled:
                // Do nothing for user cancellation
                break
            case .failed(let error):
                self.errorMessage = error.localizedDescription
                self.hasError = true
            }
        }
    }

    /// Restore any previously purchased products
    public func restorePurchases() {
        isPurchasing = true
        errorMessage = nil
        purchaseManager.restore { [weak self] result in
            guard let self = self else { return }
            self.isPurchasing = false
            switch result {
            case .success, .restored:
                // User's purchases have been restored
                break
            case .failed(let error):
                self.errorMessage = error.localizedDescription
                self.hasError = true
            case .userCancelled:
                // Ignore
                break
            }
        }
    }
}

