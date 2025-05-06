//
//  PaywallConfig.swift
//
//  Centralized configuration used by every host app.
//  All user-facing strings that don’t live in Text() must be wrapped
//  with String(localized:) so they are ready for localization.
//

import Foundation

/// Main, per-app configuration.
/// A host application can override any of these values on launch.
public struct PaywallConfig {

    // MARK: - Engine (mutable, so isolate on main actor)
    @MainActor public static var paymentEngine: PaymentEngine = .storeKit2

    // MARK: - Paywall type selection (full, trial, promo)
    @MainActor public static var paywallType: PurchaseType = .full

    // MARK: - Assets
    @MainActor public static var backgroundImagesFull: [String] = []
    @MainActor public static var backgroundImagesPromo: [String] = []

    // MARK: - RevenueCat
    @MainActor public static var revenueCatAPIKey: String = ""

    // MARK: - Benefits (shown as bullet points on the UI)
    public struct Benefit {
        public let title: String
        public let subtitle: String
        public let iconSystemName: String

        public init(title: String,
                    subtitle: String,
                    iconSystemName: String) {
            self.title = title
            self.subtitle = subtitle
            self.iconSystemName = iconSystemName
        }
    }

    @MainActor public static var benefits: [Benefit] = []
}
