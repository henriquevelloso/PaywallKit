
//
//  ProductID.swift
//  PaywallKit
//
//  Enum for product identifiers. Add new cases as needed.
//

import Foundation

/// Enum-based Product Identifiers for StoreKit/RevenueCat
public enum ProductID: String, CaseIterable {
    case weekly
    case weeklyTrial
    case annual
    case lifetime
    case lifetimePromo
}
