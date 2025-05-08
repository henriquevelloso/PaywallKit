
//
//  PaymentEngine.swift
//  PaywallKit
//
//  Enum for selecting payment engine (StoreKit2, RevenueCat etc).
//

import Foundation

/// Enum for supporting multiple payment backend options.
public enum PaymentEngine {
    case storeKit2
    case revenueCat
    // Add new engines here for future extensibility
}
