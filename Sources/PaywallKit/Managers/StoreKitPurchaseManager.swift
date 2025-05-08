//
//  StoreKitPurchaseManager.swift
//  PaywallKit
//
//  Handles native StoreKit2 purchases.
//

import Foundation
import StoreKit

/// Native StoreKit2 implementation for purchases.
public final class StoreKitPurchaseManager: PurchaseManagerProtocol, ObservableObject {
    // MARK: - State

    /// Loaded StoreKit products, mapped by ProductID
    @Published private(set) var products: [ProductID: Product] = [:]
    /// Map of purchase/entitlement state by ProductID
    private var purchasedProductIDs: Set<ProductID> = []
    private var updateTask: Task<Void, Never>? = nil

    public init() {}

    deinit {
        updateTask?.cancel()
    }

    // MARK: - Initialization & Product Load

    /// Loads products and starts observing transactions.
    @MainActor
    public func initialize() async throws {
        // Cancel any existing observer
        updateTask?.cancel()
        // Start update listener for real-time entitlement changes
        updateTask = listenForTransactions()
        try await self.loadProducts()
    }

    @MainActor
    private func loadProducts() async throws {
        let identifiers = PaywallConfig.productIdentifiers.map { $0.value }
        guard !identifiers.isEmpty else {
            throw NSError(domain: "PaywallKit.StoreKit", code: 1, userInfo: [NSLocalizedDescriptionKey : "No product identifiers set in PaywallConfig"])
        }
        let storeProducts = try await Product.products(for: Set(identifiers))
        var idMap: [ProductID: Product] = [:]
        for (pid, identifier) in PaywallConfig.productIdentifiers {
            if let product = storeProducts.first(where: { $0.id == identifier }) {
                idMap[pid] = product
            }
        }
        if idMap.isEmpty {
            throw NSError(domain: "PaywallKit.StoreKit", code: 2, userInfo: [NSLocalizedDescriptionKey : "No products matched the identifiers."])
        }
        self.products = idMap
        // Update purchased state after loading products
        await self.updatePurchasedProducts()
    }

    // MARK: - Purchase Logic

    /// Initiates a StoreKit2 purchase for a given productID
    @MainActor
    public func purchase(productID: ProductID) async throws {
        guard let product = products[productID] else {
            throw NSError(domain: "PaywallKit.StoreKit", code: 3, userInfo: [NSLocalizedDescriptionKey : "Product not loaded."])
        }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                // Mark entitlement and finish transaction
                purchasedProductIDs.insert(productID)
                await transaction.finish()
                // Sucesso
            case .unverified(_, let error):
                throw error
            }
        case .userCancelled:
            throw NSError(domain: SKErrorDomain, code: SKError.paymentCancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "User cancelled purchase."])
        case .pending:
            throw NSError(domain: "PaywallKit.StoreKit", code: 4, userInfo: [NSLocalizedDescriptionKey : "Purchase is pending approval."])
        @unknown default:
            throw NSError(domain: "PaywallKit.StoreKit", code: 5, userInfo: [NSLocalizedDescriptionKey: "Unknown StoreKit result"])
        }
    }
    
    // MARK: - Restore Purchases

    /// Restores previously purchased products
    @MainActor
    public func restore() async throws {
        try await AppStore.sync()
        await self.updatePurchasedProducts()
        // Sucesso
    }
    
    // MARK: - Entitlement

    /// Checks if user has valid entitlement for the given product
    public func hasAccess(productID: ProductID) -> Bool {
        return purchasedProductIDs.contains(productID)
    }

    // MARK: - Transaction observation (real‑time entitlement updates)

    /// Observes transaction updates for current user
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached(priority: .background) { [weak self] in
            for await _ in Transaction.updates {
                await self?.updatePurchasedProducts()
            }
        }
    }
    /// Updates purchasedProductIDs with the user's current entitlements
    @MainActor
    private func updatePurchasedProducts() async {
        var newPurchasedIDs: Set<ProductID> = []
        for (pid, identifier) in PaywallConfig.productIdentifiers {
            if await Self.isPurchased(productIdentifier: identifier) {
                newPurchasedIDs.insert(pid)
            }
        }
        self.purchasedProductIDs = newPurchasedIDs
    }

    /// Check if product identifier has active transaction (valid purchase or subscription)
    static func isPurchased(productIdentifier: String) async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productIdentifier && transaction.revocationDate == nil && !transaction.isUpgraded {
                    return true
                }
            }
        }
        return false
    }
}
