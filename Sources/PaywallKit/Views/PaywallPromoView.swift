//
//  PaywallPromoView.swift
//
//  Layout for .promo (lifetimePromo only).
//

import SwiftUI
import StoreKit

public struct PaywallPromoView: View {
    @StateObject private var viewModel = PaywallViewModel()

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            PaywallCarouselView(images: PaywallConfig.backgroundImagesPromo)
                .frame(height: 240)

            VStack(spacing: 12) {
                Text(String(localized: "Special Lifetime Offer"))
                    .font(.title2).bold()
                Text(String(localized: "Pay once, use forever. Limited time."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            PurchaseButton(product: viewModel.products.first,
                           action: { Task { await viewModel.purchase(viewModel.products.first!) } },
                           isLoading: .constant(viewModel.isLoading))
                .padding(.horizontal)

            TermsPrivacyRestoreView {
                Task { await viewModel.restore() }
            }
            .padding(.bottom, 12)
        }
    }
}
