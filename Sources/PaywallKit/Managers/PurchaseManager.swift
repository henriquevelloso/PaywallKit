
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
public protocol PurchaseManagerProtocol: AnyObject {
    /// Load available products & current purchase states
    func initialize(completion: @escaping (Result<Void, Error>) -> Void)
    /// Begin purchase for product
    func purchase(productID: ProductID, completion: @escaping (PurchaseResult) -> Void)
    /// Restore purchases
    func restore(completion: @escaping (PurchaseResult) -> Void)
    /// Check premium access [optional, e.g., for unlocking]
    func hasAccess(productID: ProductID) -> Bool
}

/// Facade: Selects payment engine and forwards requests to the appropriate manager
public final class PurchaseManager: PurchaseManagerProtocol {
    private var engine: PurchaseManagerProtocol

    public init() {
        // Select payment engine based on config
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            self.engine = StoreKitPurchaseManager()
        case .revenueCat:
            self.engine = RevenueCatPurchaseManager()
        }
    }

    public func initialize(completion: @escaping (Result<Void, Error>) -> Void) {
        engine.initialize(completion: completion)
    }

    public func purchase(productID: ProductID, completion: @escaping (PurchaseResult) -> Void) {
        engine.purchase(productID: productID, completion: completion)
    }

    public func restore(completion: @escaping (PurchaseResult) -> Void) {
        engine.restore(completion: completion)
    }

    public func hasAccess(productID: ProductID) -> Bool {
        engine.hasAccess(productID: productID)
    }
}

