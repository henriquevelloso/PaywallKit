//
//  PurchaseManager.swift
//
//  High-level facade chosen via PaywallConfig.paymentEngine.
//  Concrete StoreKit / RevenueCat managers live in dedicated files.
//

import Foundation
import StoreKit
import RevenueCat

@MainActor
public protocol PurchaseManaging: ObservableObject {
    var isLoading: Bool { get }
    var products: [Product] { get }
    func fetchProducts() async
    func purchase(_ product: Product) async throws
    func restore() async throws
}

// MARK: - Factory helper
@MainActor
public enum PurchaseManagerFactory {
    public static func make() -> any PurchaseManaging {
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            return StoreKitPurchaseManager()
        case .revenueCat:
            return RevenueCatPurchaseManager()
        }
    }
}
