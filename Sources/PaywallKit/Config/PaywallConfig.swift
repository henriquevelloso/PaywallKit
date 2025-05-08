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
    /// Select payment engine (StoreKit2, RevenueCat, or others)
    public static var paymentEngine: PaymentEngine = .storeKit2

    /// Global paywall type (full, trial, promo)
    public static var paywallType: PurchaseType = .full

    /// Images for full paywall backgrounds (asset names)
    public static var backgroundImagesFull: [String] = ["full_bg1", "full_bg2"]

    /// Images for promo paywall backgrounds (asset names)
    public static var backgroundImagesPromo: [String] = ["promo_bg1", "promo_bg2"]

    /// List of benefits shown on the paywall
    public static var benefits: [Benefit] = [
        Benefit(title: "paywall_benefit_premium_title", description: "paywall_benefit_premium_desc", iconName: "star.fill"),
        Benefit(title: "paywall_benefit_priority_title", description: "paywall_benefit_priority_desc", iconName: "bolt.fill")
        // Unlimited extension!
    ]

    /// RevenueCat API key (required if using .revenueCat as paymentEngine)
    public static var revenueCatApiKey: String = ""
    
    /// Adapty API key (only needed if/when supporting Adapty in future)
    public static var adaptyApiKey: String = ""
    
    /// Qonversion API key (only needed if/when supporting Qonversion in future)
    public static var qonversionApiKey: String = ""
    
    /// Product Identifiers, supplied at integration by the main app.
    public static var productIdentifiers: [ProductID: String] = [:]
}
