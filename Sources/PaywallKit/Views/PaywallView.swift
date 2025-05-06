//
//  PaywallView.swift
//
//  Layout for .full and .trial.
//

import SwiftUI
import StoreKit

public struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()

    public init() {}

    public var body: some View {
        ZStack {
            PaywallCarouselView(images: PaywallConfig.backgroundImagesFull)

            ScrollView {
                VStack(spacing: 24) {
                    // Logo placeholder
                    Image(systemName: "app.fill")
                        .font(.largeTitle)

                    Text(String(localized: "Get Pro"))
                        .font(.title).bold()
                    Text(String(localized: "Unlock the most powerful AI assistant"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Benefits
                    ForEach(PaywallConfig.benefits, id: \.title) { BenefitView(benefit: $0) }

                    // Product cards placeholder
                    Text("(Product cards here)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    PurchaseButton(
                        product: viewModel.products.first,
                        action: {
                            // SAFETY: guard against missing product
                            guard let product = viewModel.products.first else { return }
                            Task { await viewModel.purchase(product) }
                        },
                        isLoading: .constant(viewModel.isLoading)
                    )

                    TermsPrivacyRestoreView {
                        Task { await viewModel.restore() }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
