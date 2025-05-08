//
//  PaywallViewModel.swift
//  PaywallKit
//
//  Central ViewModel for Paywall. Handles state, product presentation, and purchase/restore logic.
//

import Foundation
import SwiftUI
import StoreKit // Para SKError e Product (StoreKit)
import RevenueCat // Agora importado diretamente

@MainActor
public class PaywallViewModel: ObservableObject {
    // Singleton instance (can use another with .init() if needed)
    public static let shared = PaywallViewModel()

    // MARK: - State

    /// All available products/packages (StoreKit2 or RevenueCat, depending on engine)
    @Published private(set) var storeKitProducts: [ProductID: StoreKit.Product] = [:]
    @Published private(set) var revenueCatPackages: [ProductID: Package] = [:]

    /// Current error message (to show on Alert)
    @Published public var errorMessage: String?
    /// True if currently loading any initial data (incl. products)
    @Published public var isLoadingInitial: Bool = false
    /// If a purchase is in progress
    @Published public var isPurchasing: Bool = false
    /// Show Error Alert
    @Published public var hasError: Bool = false
    /// The Product being purchased (for button loading)
    @Published public var selectedProductId: ProductID?

    // MARK: - Product Display Order

    /// Order in which products appear on UI (could be configured, or sorted)
    public var productDisplayOrder: [ProductID] {
        // Default: order as in config, or sorted
        Array(loadedProductIDs)
    }

    /// Tracks which products are available for purchase (after loading)
    private var loadedProductIDs: Set<ProductID> = []

    // MARK: - Internal

    private let purchaseManager: PurchaseManagerProtocol

    public init(purchaseManager: PurchaseManagerProtocol? = nil) {
        self.purchaseManager = purchaseManager ?? PurchaseManager()
        Task {
            // isLoadingInitial e errorMessage são atualizados dentro de loadProducts
            await self.loadProducts()
        }
    }

    // MARK: - Load Products
    public func loadProducts() async {
        errorMessage = nil
        isLoadingInitial = true
        defer { isLoadingInitial = false }
        
        do {
            // CORREÇÃO: Chamar o método async throws diretamente
            try await purchaseManager.initialize()
            self.populateProductsFromEngine() // Esta função deve ser síncrona e usar os dados já carregados pelo manager
            self.loadedProductIDs = Set(self._allLoadedProductIDs())
        } catch {
            self.errorMessage = error.localizedDescription
            self.hasError = true
        }
    }

    /// Called after successful engine initialize to fetch products into dictionary
    @MainActor // Garantir que está no MainActor para acessar PaywallConfig
    private func populateProductsFromEngine() {
        // Acesso a PaywallConfig.paymentEngine é @MainActor
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            if let manager = purchaseManager as? StoreKitPurchaseManager {
                self.storeKitProducts = manager.products // Assumindo que products em StoreKitPurchaseManager é acessível
            }
        case .revenueCat:
            if let manager = purchaseManager as? RevenueCatPurchaseManager {
                // CORREÇÃO: Acessar 'products' que deve ser public(set) ou similar
                self.revenueCatPackages = manager.products
            }
        }
    }

    /// Returns all currently loaded ProductIDs for display purposes
    @MainActor
    private func _allLoadedProductIDs() -> [ProductID] {
        // Acesso a PaywallConfig.paymentEngine é @MainActor
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            return Array(storeKitProducts.keys)
        case .revenueCat:
            return Array(revenueCatPackages.keys)
        }
    }

    // MARK: - UI Text Builders
    @MainActor // Garantir que está no MainActor para acessar PaywallConfig e published properties
    public func title(for productId: ProductID) -> String {
        // Acesso a PaywallConfig.paymentEngine é @MainActor
        switch PaywallConfig.paymentEngine {
        case .storeKit2:
            guard let product = storeKitProducts[productId] else { return "" }
            return "\(product.displayName) • \(product.displayPrice)"
        case .revenueCat:
            guard let pkg = revenueCatPackages[productId] else { return "" }
            // CORREÇÃO: RevenueCat's StoreProduct tem localizedPriceString
            // e localizedTitle. pkg.product é o SKProduct legado.
            // Usar pkg.storeProduct para informações mais recentes.
            let title = pkg.storeProduct.localizedTitle
            let price = pkg.storeProduct.localizedPriceString
            return "\(title) • \(price)"
        }
    }

    // MARK: - Purchase/Redeem Actions
    public func purchase(_ productId: ProductID) {
        guard !isPurchasing else { return }
        
        Task { @MainActor in // Garantir que atualizações de UI aconteçam no MainActor
            selectedProductId = productId
            isPurchasing = true
            errorMessage = nil
            
            do {
                // CORREÇÃO: Chamar o método async throws diretamente
                try await purchaseManager.purchase(productID: productId)
                // Sucesso na compra - opcionalmente mostrar mensagem/navegar
            } catch let error as NSError {
                if error.domain == SKErrorDomain && error.code == SKError.Code.paymentCancelled.rawValue {
                    // Usuário cancelou, geralmente não mostramos erro
                } else {
                    self.errorMessage = error.localizedDescription
                    self.hasError = true
                }
            } catch { // Outros erros
                self.errorMessage = error.localizedDescription
                self.hasError = true
            }
            
            self.isPurchasing = false
            self.selectedProductId = nil
        }
    }

    public func restorePurchases() {
        Task { @MainActor in // Garantir que atualizações de UI aconteçam no MainActor
            isPurchasing = true
            errorMessage = nil
            
            do {
                // CORREÇÃO: Chamar o método async throws diretamente
                try await purchaseManager.restore()
                // Sucesso na restauração - opcionalmente mostrar mensagem
            } catch {
                self.errorMessage = error.localizedDescription
                self.hasError = true
            }
            
            self.isPurchasing = false
        }
    }
}
