
import SwiftUI

public struct PaywallContainerView: View {
    private let type: PurchaseType?
    
    public init(type: PurchaseType? = nil) {
        self.type = type
    }
    
    public var body: some View {
        Group {
            switch type ?? PaywallConfig.paywallType {
            case .full, .trial:
                PaywallView()
            case .promo:
                PaywallPromoView()
            }
        }
    }
}
