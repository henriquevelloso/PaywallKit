
//
//  PurchaseButton.swift
//

import SwiftUI
import StoreKit

/// Dark, rounded button used at the bottom of the paywall.
struct PurchaseButton: View {
    var product: Product?
    let action: () -> Void
    @Binding var isLoading: Bool

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Label {
                    Text(product?.displayName ?? String(localized: "Subscribe"))
                        .bold()
                } icon: {
                    Image(systemName: "crown.fill")
                }
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(product == nil || isLoading)
    }
}
