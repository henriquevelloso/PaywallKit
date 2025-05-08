//
//  PurchaseManager.swift
//  PaywallKit
//
//  Abstracts purchase logic for different payment engines.
//  Uses PurchaseManagerProtocol for flexibility.
//

import Foundation

/// Purchase result states
public enum PurchaseResult {
    case success
    case userCancelled
    case failed(Error)
    case restored
}

/// Protocol defining the purchase actions available to PaywallKit views
@MainActor
public protocol PurchaseManagerProtocol: AnyObject {
    /// Load available products & current purchase states
    func initialize() async throws
    /// Begin purchase for product
    func purchase(productID: ProductID) async throws
    /// Restore purchases
    func restore() async throws
    /// Check premium access [optional, e.g., for unlocking]
    func hasAccess(productID: ProductID) -> Bool // Este pode permanecer síncrono
}

/// Facade: Selects payment engine and forwards requests to the appropriate manager
public final class PurchaseManager: PurchaseManagerProtocol {
    private var engine: PurchaseManagerProtocol

    @MainActor
    public init() {
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            self.engine = StoreKitPurchaseManager()
        case .revenueCat:
            self.engine = RevenueCatPurchaseManager()
        }
    }

    public func initialize() async throws {
        try await engine.initialize()
    }

    public func purchase(productID: ProductID) async throws {
        try await engine.purchase(productID: productID)
    }

    public func restore() async throws {
        try await engine.restore()
    }

    public func hasAccess(productID: ProductID) -> Bool {
        engine.hasAccess(productID: productID)
    }
}
