
//
//  PurchaseType.swift
//

import Foundation

/// Three global layout variants we support.
public enum PurchaseType {
    case full      // weekly / annual / lifetime
    case trial     // weekly (3-day) / annual / lifetime
    case promo     // lifetimePromo only
}
