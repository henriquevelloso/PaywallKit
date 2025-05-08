//
//  RevenueCatPurchaseManager.swift
//  PaywallKit
//
//  Handles purchases using RevenueCat SDK.
//

import Foundation
import StoreKit
import RevenueCat

/// RevenueCat implementation for PaywallKit; must link RevenueCat at integration.
public final class RevenueCatPurchaseManager: PurchaseManagerProtocol, ObservableObject {
    // CORREÇÃO: Mudar para public(set) para permitir leitura pelo ViewModel
    public internal(set) var products: [ProductID: Package] = [:]
    private var currentEntitlements: Set<ProductID> = []
    private var isInitialized = false

    public init() {}

    // MARK: - Initialization / Configuration
    @MainActor
    public func initialize() async throws {
        guard !PaywallConfig.revenueCatApiKey.isEmpty else {
            throw NSError(domain: "PaywallKit.RevenueCat", code: 101, userInfo: [NSLocalizedDescriptionKey: "RevenueCat API key not set in PaywallConfig"])
        }
        
        if !isInitialized {
            Purchases.logLevel = .debug // Mude para .info ou .error em produção
            Purchases.configure(withAPIKey: PaywallConfig.revenueCatApiKey)
            isInitialized = true
        }
        
        let offerings = try await Purchases.shared.offerings()
        guard let allPackages = offerings.current?.availablePackages, !allPackages.isEmpty else {
            throw NSError(domain: "PaywallKit.RevenueCat", code: 102, userInfo: [NSLocalizedDescriptionKey: "No available RevenueCat products."])
        }
        
        var localProducts: [ProductID: Package] = [:]
        for (pid, identifier) in PaywallConfig.productIdentifiers {
            if let pkg = allPackages.first(where: { $0.storeProduct.productIdentifier == identifier }) {
                localProducts[pid] = pkg
            }
        }
        
        if localProducts.isEmpty {
            throw NSError(domain: "PaywallKit.RevenueCat", code: 103, userInfo: [NSLocalizedDescriptionKey: "None of the configured products found in RevenueCat."])
        }
        
        self.products = localProducts
        await self.updateEntitlements()
    }

    // MARK: - Purchase Flow
    public func purchase(productID: ProductID) async throws {
        guard let packageToPurchase = products[productID] else {
            throw NSError(domain: "PaywallKit.RevenueCat", code: 104, userInfo: [NSLocalizedDescriptionKey: "Product not available in RevenueCat"])
        }

        let result = try await Purchases.shared.purchase(package: packageToPurchase)
        
        if result.userCancelled {
            throw NSError(domain: SKErrorDomain, code: SKError.paymentCancelled.rawValue, userInfo: [NSLocalizedDescriptionKey: "User cancelled purchase."])
        }
        await self.updateEntitlements(with: result.customerInfo)
        // Sucesso
    }

    // MARK: - Restore
    public func restore() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        await self.updateEntitlements(with: customerInfo)
        // Sucesso
    }

    // MARK: - Entitlement
    public func hasAccess(productID: ProductID) -> Bool {
        return currentEntitlements.contains(productID)
    }

    // MARK: - Internal: Update Entitlements
    @MainActor
    private func updateEntitlements(with customerInfo: CustomerInfo? = nil) async {
        let infoToProcess: CustomerInfo?
        if let customerInfo {
            infoToProcess = customerInfo
        } else {
            do {
                infoToProcess = try await Purchases.shared.customerInfo()
            } catch {
                print("[PaywallKit.RevenueCat] Error fetching customer info: \(error.localizedDescription)")
                return // Não atualiza entitlements se falhar
            }
        }

        guard let finalInfo = infoToProcess else { return }
        
        var newEntitlements: Set<ProductID> = []
        let activeStoreProductIdentifiers = finalInfo.entitlements.active.values.map { $0.productIdentifier }
        
        for (localProductID, configuredStoreIdentifier) in PaywallConfig.productIdentifiers {
            if activeStoreProductIdentifiers.contains(configuredStoreIdentifier) {
                newEntitlements.insert(localProductID)
            }
        }
        self.currentEntitlements = newEntitlements
    }
}
