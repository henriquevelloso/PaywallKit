//
//  PaywallViewModel.swift
//

import Foundation
import StoreKit

@MainActor
public final class PaywallViewModel: ObservableObject {

    // MARK: - Public, bindable properties
    @Published public private(set) var products: [Product] = []
    @Published public private(set) var isLoading: Bool = false

    // MARK: - Private
    private let purchaseManager: any PurchaseManaging

    public init(purchaseManager: any PurchaseManaging = PurchaseManagerFactory.make()) {
        self.purchaseManager = purchaseManager
        Task {
            await purchaseManager.fetchProducts()
            // Pull first snapshot (simple, non-reactive for now)
            products = purchaseManager.products
            isLoading = purchaseManager.isLoading
        }
    }

    // MARK: - API wrappers
    public func purchase(_ product: Product) async {
        do {
            try await purchaseManager.purchase(product)
        } catch {
            // TODO: surface error to UI
        }
    }

    public func restore() async {
        do {
            try await purchaseManager.restore()
        } catch {
            // TODO: surface error to UI
        }
    }

    // NOTE: Reactive bridging removed for now – we’ll revisit with Combine/async-sequence later.
}
