//
//  PaywallView.swift
//  PaywallKit
//
//  Main view for the full-featured paywall with background carousel and all options.
//

import SwiftUI

public struct PaywallView: View {
    @StateObject var viewModel: PaywallViewModel

    public init(viewModel: PaywallViewModel = .shared) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Background carousel
            PaywallCarouselView(images: PaywallConfig.backgroundImagesFull)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Text(String(localized: "paywall_title"))
                            .font(.largeTitle).bold()
                        Text(String(localized: "paywall_subtitle"))
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    // Benefits list
                    ForEach(PaywallConfig.benefits, id: \.title) { benefit in
                        BenefitView(benefit: benefit)
                    }

                    // Product Buttons
                    VStack(alignment: .center, spacing: 12) {
                        ForEach(viewModel.productDisplayOrder, id: \.self) { productId in
                            PurchaseButton(
                                title: viewModel.title(for: productId),
                                isLoading: viewModel.isPurchasing && viewModel.selectedProductId == productId,
                                isEnabled: !viewModel.isPurchasing,
                                action: { viewModel.purchase(productId) }
                            )
                        }
                    }

                    // Restore/Terms
                    TermsPrivacyRestoreView {
                        viewModel.restorePurchases()
                    }
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text("paywall_error_title"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("paywall_alert_dismiss")))
        }
        .overlay {
            if viewModel.isLoadingInitial {
                Color.black.opacity(0.18).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.3)
            }
        }
    }
}

#if DEBUG

private protocol ProductDisplayable {
    var displayName: String { get }
    var displayPrice: String { get }
}

private struct MockProduct: ProductDisplayable {
    let displayName: String
    let displayPrice: String
}

private class PreviewViewModel: PaywallViewModel {
    // Mocks simulando produtos vindos do StoreKit
    let mockProducts: [ProductID: ProductDisplayable] = [
        .weekly: MockProduct(displayName: "Weekly", displayPrice: "R$4,90"),
        .annual: MockProduct(displayName: "Annual", displayPrice: "R$69,90"),
        .lifetime: MockProduct(displayName: "Lifetime", displayPrice: "R$109,90")
    ]

    override var productDisplayOrder: [ProductID] { [.weekly, .annual, .lifetime] }
    override func title(for productId: ProductID) -> String {
        guard let p = mockProducts[productId] else { return "" }
        return "\(p.displayName) • \(p.displayPrice)"
    }
}

#Preview("PaywallView - StoreKit2 Preview") {
    PaywallView(viewModel: PreviewViewModel())
        .environment(\.colorScheme, .light)
}

#Preview("PaywallView - StoreKit2 Dark") {
    PaywallView(viewModel: PreviewViewModel())
        .environment(\.colorScheme, .dark)
}
#endif
