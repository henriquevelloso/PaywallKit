
//
//  ProductID.swift
//
//  Enum-based product identifiers.  
//  Host app should extend this enum OR provide the raw values in PaywallConfig.
//

import Foundation

public enum ProductID: String, CaseIterable {
    case weekly
    case weeklyTrial
    case annual
    case lifetime
    case lifetimePromo
}
