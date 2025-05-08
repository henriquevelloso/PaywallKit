//
//  PaywallPromoView.swift
//  PaywallKit
//
//  Promotional view with distinct background and single offer emphasis.
//

import SwiftUI

public struct PaywallPromoView: View {
    @StateObject var viewModel: PaywallViewModel

    public init(viewModel: PaywallViewModel = .shared) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            PaywallCarouselView(images: PaywallConfig.backgroundImagesPromo)
                .frame(height: 180)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Text(String(localized: "paywall_promo_title"))
                        .font(.largeTitle.bold())
                        .padding(.bottom, 4)

                    ForEach(PaywallConfig.benefits, id: \.title) { benefit in
                        BenefitView(benefit: benefit)
                    }

                    if let promoProduct = viewModel.productDisplayOrder.first {
                        PurchaseButton(
                            title: viewModel.title(for: promoProduct),
                            isLoading: viewModel.isPurchasing && viewModel.selectedProductId == promoProduct,
                            isEnabled: !viewModel.isPurchasing,
                            action: { viewModel.purchase(promoProduct) }
                        )
                        .padding(.vertical, 18)
                    }

                    TermsPrivacyRestoreView {
                        viewModel.restorePurchases()
                    }
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 22)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
        .overlay {
            if viewModel.isLoadingInitial {
                Color.black.opacity(0.18).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
private protocol ProductDisplayable {
    var displayName: String { get }
    var displayPrice: String { get }
}

private struct MockProduct: ProductDisplayable {
    let displayName: String
    let displayPrice: String
}

private class PromoPreviewViewModel: PaywallViewModel {
    let mockProducts: [ProductID: ProductDisplayable] = [
        .lifetimePromo: MockProduct(displayName: "Lifetime Promo", displayPrice: "R$59,90"),
    ]

    override var productDisplayOrder: [ProductID] { [.lifetimePromo] }
    override func title(for productId: ProductID) -> String {
        guard let p = mockProducts[productId] else { return "" }
        return "\(p.displayName) • \(p.displayPrice)"
    }
}

#Preview {
    PaywallPromoView(viewModel: PromoPreviewViewModel())
        .environment(\.colorScheme, .light)
        .previewDisplayName("PaywallPromoView - Light")
}

#Preview {
    PaywallPromoView(viewModel: PromoPreviewViewModel())
        .environment(\.colorScheme, .dark)
        .previewDisplayName("PaywallPromoView - Dark")
}
#endif
