
//
//  StoreKitPurchaseManager.swift
//
//  Minimal stub to keep the package compiling.
//

import Foundation
import StoreKit

@MainActor
final class StoreKitPurchaseManager: PurchaseManaging {

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var products: [Product] = []

    // MARK: - Public API

    func fetchProducts() async {
        // TODO: implement product request via StoreKit 2
    }

    func purchase(_ product: Product) async throws {
        // TODO: implement purchase logic
    }

    func restore() async throws {
        // TODO: implement restore logic
    }
}
