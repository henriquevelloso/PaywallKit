
//
//  RevenueCatPurchaseManager.swift
//
//  Minimal stub to keep the package compiling.
//

import Foundation
import StoreKit
import RevenueCat

@MainActor
final class RevenueCatPurchaseManager: PurchaseManaging {

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var products: [Product] = []

    init() {
        // Lazy init – host app must call Purchases.configure elsewhere.
    }

    // MARK: - Public API

    func fetchProducts() async {
        // TODO: map RevenueCat offerings to StoreKit Product
    }

    func purchase(_ product: Product) async throws {
        // TODO: implement purchase via RevenueCat
    }

    func restore() async throws {
        // TODO: call Purchases.shared.restorePurchases()
    }
}
