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
    private(set) var products: [ProductID: Product] = [:]
    /// Map of purchase/entitlement state by ProductID
    private var purchasedProductIDs: Set<ProductID> = []

    private var updateTask: Task<Void, Never>? = nil

    public init() {}

    deinit {
        updateTask?.cancel()
    }

    // MARK: - Initialization & Product Load

    /// Loads products and starts observing transactions.
    public func initialize(completion: @escaping (Result<Void, Error>) -> Void) {
        // Cancel any existing observer
        updateTask?.cancel()
        // Start update listener for real-time entitlement changes
        updateTask = listenForTransactions()
        
        Task {
            do {
                try await loadProducts()
                await MainActor.run {
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }

    /// Loads available products from the App Store.
    private func loadProducts() async throws {
        let identifiers = PaywallConfig.productIdentifiers.map { $0.value }
        guard !identifiers.isEmpty else {
            throw NSError(domain: "PaywallKit", code: 1, userInfo: [NSLocalizedDescriptionKey : "No product identifiers set in PaywallConfig"])
        }
        let storeProducts = try await Product.products(for: Set(identifiers))
        var idMap: [ProductID: Product] = [:]
        for (pid, identifier) in PaywallConfig.productIdentifiers {
            if let product = storeProducts.first(where: { $0.id == identifier }) {
                idMap[pid] = product
            }
        }
        if idMap.isEmpty {
            throw NSError(domain: "PaywallKit", code: 2, userInfo: [NSLocalizedDescriptionKey : "No products matched the identifiers."])
        }
        self.products = idMap
        // Update purchased state after loading products
        await updatePurchasedProducts()
    }

    // MARK: - Purchase Logic

    /// Initiates a StoreKit2 purchase for a given productID
    public func purchase(productID: ProductID, completion: @escaping (PurchaseResult) -> Void) {
        guard let product = products[productID] else {
            completion(.failed(NSError(domain: "PaywallKit", code: 3, userInfo: [NSLocalizedDescriptionKey : "Product not loaded."])))
            return
        }

        Task {
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        // Mark entitlement and finish transaction
                        purchasedProductIDs.insert(productID)
                        await transaction.finish()
                        await MainActor.run { completion(.success) }
                    case .unverified(_, let error):
                        await MainActor.run { completion(.failed(error)) }
                    }
                case .userCancelled:
                    await MainActor.run { completion(.userCancelled) }
                case .pending:
                    await MainActor.run {
                        let pendingError = NSError(domain: "PaywallKit", code: 4,
                                            userInfo: [NSLocalizedDescriptionKey : "Purchase is pending approval."])
                        completion(.failed(pendingError))
                    }
                @unknown default:
                    await MainActor.run {
                        let unknownError = NSError(domain: "PaywallKit", code: 5,
                                                  userInfo: [NSLocalizedDescriptionKey: "Unknown StoreKit result"])
                        completion(.failed(unknownError))
                    }
                }
            } catch {
                await MainActor.run { completion(.failed(error)) }
            }
        }
    }
    
    // MARK: - Restore Purchases

    /// Restores previously purchased products
    public func restore(completion: @escaping (PurchaseResult) -> Void) {
        Task {
            do {
                // Updates internal purchasedProductIDs via transaction observation
                try await AppStore.sync()
                await updatePurchasedProducts()
                await MainActor.run { completion(.restored) }
            } catch {
                await MainActor.run { completion(.failed(error)) }
            }
        }
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
            for await result in Transaction.updates {
                _ = self   // Retain self
                // We'll ignore the actual transaction, just reload state
                await self?.updatePurchasedProducts()
            }
        }
    }
    /// Updates purchasedProductIDs with the user's current entitlements
    @MainActor
    private func updatePurchasedProducts() async {
        var purchased: Set<ProductID> = []
        for (pid, identifier) in PaywallConfig.productIdentifiers {
            if await Self.isPurchased(productIdentifier: identifier) {
                purchased.insert(pid)
            }
        }
        self.purchasedProductIDs = purchased
    }

    /// Check if product identifier has active transaction (valid purchase or subscription)
    static func isPurchased(productIdentifier: String) async -> Bool {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == productIdentifier {
                    // Check not revoked/expired
                    return transaction.revocationDate == nil
                }
            case .unverified: continue
            }
        }
        return false
    }
}
