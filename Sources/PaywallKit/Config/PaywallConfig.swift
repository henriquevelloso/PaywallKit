//
//  PaywallConfig.swift
//  PaywallKit
//
//  Centralized configuration for paywall appearance & logic.
//

import Foundation

/// A benefit to show on the paywall screen
public struct Benefit {
    public let title: String          // Localized string key
    public let description: String    // Localized string key
    public let iconName: String       // SFSymbol or asset name

    public init(title: String, description: String, iconName: String) {
        self.title = title
        self.description = description
        self.iconName = iconName
    }
}

/// PaywallKit configuration singleton, for easy project-wide customization.
public struct PaywallConfig {
    // Adicionar @MainActor a todas as propriedades static var
    @MainActor public static var paymentEngine: PaymentEngine = .storeKit2
    @MainActor public static var paywallType: PurchaseType = .full
    @MainActor public static var backgroundImagesFull: [String] = ["full_bg1", "full_bg2"]
    @MainActor public static var backgroundImagesPromo: [String] = ["promo_bg1", "promo_bg2"]
    @MainActor public static var benefits: [Benefit] = [
        Benefit(title: "paywall_benefit_premium_title", description: "paywall_benefit_premium_desc", iconName: "star.fill"),
        Benefit(title: "paywall_benefit_priority_title", description: "paywall_benefit_priority_desc", iconName: "bolt.fill")
        // Unlimited extension!
    ]
    @MainActor public static var revenueCatApiKey: String = ""
    @MainActor public static var adaptyApiKey: String = "" // Para uso futuro
    @MainActor public static var qonversionApiKey: String = "" // Para uso futuro
    @MainActor public static var productIdentifiers: [ProductID: String] = [:]

    /// Método de configuração opcional para definir todos os valores de uma vez.
    /// Também precisa ser @MainActor se modifica propriedades @MainActor.
    @MainActor
    public static func configure(
        paymentEngine: PaymentEngine,
        paywallType: PurchaseType,
        backgroundImagesFull: [String]? = nil, // Tornar opcionais se não forem sempre fornecidos
        backgroundImagesPromo: [String]? = nil, // Tornar opcionais
        benefits: [Benefit]? = nil, // Tornar opcionais
        revenueCatApiKey: String = "",
        adaptyApiKey: String = "",
        qonversionApiKey: String = "",
        productIdentifiers: [ProductID: String]
    ) {
        self.paymentEngine = paymentEngine
        self.paywallType = paywallType
        if let backgroundImagesFull { self.backgroundImagesFull = backgroundImagesFull }
        if let backgroundImagesPromo { self.backgroundImagesPromo = backgroundImagesPromo }
        if let benefits { self.benefits = benefits }
        self.revenueCatApiKey = revenueCatApiKey
        self.adaptyApiKey = adaptyApiKey
        self.qonversionApiKey = qonversionApiKey
        self.productIdentifiers = productIdentifiers
    }
}
