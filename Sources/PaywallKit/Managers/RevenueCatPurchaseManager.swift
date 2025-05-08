//
//  RevenueCatPurchaseManager.swift
//  PaywallKit
//
//  Handles purchases using RevenueCat SDK.
//

import Foundation
#if canImport(RevenueCat)
import RevenueCat
#endif

/// RevenueCat implementation for PaywallKit; must link RevenueCat at integration.
public final class RevenueCatPurchaseManager: PurchaseManagerProtocol, ObservableObject {
    #if canImport(RevenueCat)
    private var products: [ProductID: Package] = [:]
    private var currentEntitlements: Set<ProductID> = []
    private var isInitialized = false
    #endif

    public init() {}

    // MARK: - Initialization / Configuration

    public func initialize(completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(RevenueCat)
        guard !PaywallConfig.apiKey.isEmpty else {
            completion(.failure(NSError(domain: "PaywallKit", code: 101, userInfo: [NSLocalizedDescriptionKey: "RevenueCat API key not set in PaywallConfig"])))
            return
        }
        if !isInitialized {
            Purchases.logLevel = .info    // Show logs for debugging
            Purchases.configure(withAPIKey: PaywallConfig.apiKey)
            isInitialized = true
        }
        // Fetch offerings and map products
        Purchases.shared.getOfferings { [weak self] offerings, error in
            if let error { completion(.failure(error)); return }
            guard let self,
                  let allPackages = offerings?.current?.availablePackages, !allPackages.isEmpty else {
                completion(.failure(NSError(domain: "PaywallKit", code: 102, userInfo: [NSLocalizedDescriptionKey: "No available RevenueCat products."])))
                return
            }
            var revenueCatProducts: [ProductID: Package] = [:]
            for (pid, identifier) in PaywallConfig.productIdentifiers {
                if let pkg = allPackages.first(where: { $0.product.productIdentifier == identifier }) {
                    revenueCatProducts[pid] = pkg
                }
            }
            if revenueCatProducts.isEmpty {
                completion(.failure(NSError(domain: "PaywallKit", code: 103, userInfo: [NSLocalizedDescriptionKey: "None of the configured products found in RevenueCat."])))
                return
            }
            self.products = revenueCatProducts
            Task { await self.updateEntitlements() }
            completion(.success(()))
        }
        #else
        completion(.failure(NSError(domain: "PaywallKit", code: 100, userInfo: [NSLocalizedDescriptionKey: "RevenueCat not available in this build."])))
        #endif
    }

    // MARK: - Purchase Flow

    public func purchase(productID: ProductID, completion: @escaping (PurchaseResult) -> Void) {
        #if canImport(RevenueCat)
        guard let package = products[productID] else {
            completion(.failed(NSError(domain: "PaywallKit", code: 104, userInfo: [NSLocalizedDescriptionKey: "Product not available in RevenueCat"])))
            return
        }

        Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
            if let error = error {
                completion(.failed(error))
                return
            }
            if userCancelled {
                completion(.userCancelled)
                return
            }
            // Check effective entitlement (will update via observer as well)
            Task { await self.updateEntitlements() }
            completion(.success)
        }
        #else
        completion(.failed(NSError(domain: "PaywallKit", code: 100, userInfo: [NSLocalizedDescriptionKey: "RevenueCat not available in this build."])))
        #endif
    }

    // MARK: - Restore

    public func restore(completion: @escaping (PurchaseResult) -> Void) {
        #if canImport(RevenueCat)
        Purchases.shared.restorePurchases { [weak self] (customerInfo, error) in
            if let error = error {
                completion(.failed(error))
                return
            }
            Task { await self?.updateEntitlements() }
            completion(.restored)
        }
        #else
        completion(.failed(NSError(domain: "PaywallKit", code: 100, userInfo: [NSLocalizedDescriptionKey: "RevenueCat not available in this build."])))
        #endif
    }

    // MARK: - Entitlement

    public func hasAccess(productID: ProductID) -> Bool {
        #if canImport(RevenueCat)
        return currentEntitlements.contains(productID)
        #else
        return false
        #endif
    }

    // MARK: - Internal: Update Entitlements

    #if canImport(RevenueCat)
    @MainActor
    private func updateEntitlements() async {
        // Map active entitlements to ProductID by identifier
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            guard let self, let info = info else { return }
            var entitled: Set<ProductID> = []
            let identifiers = info.entitlements.active.values.flatMap { $0.productIdentifiers }
            for (pid, id) in PaywallConfig.productIdentifiers where identifiers.contains(id) {
                entitled.insert(pid)
            }
            self.currentEntitlements = entitled
        }
    }
    #endif
}
