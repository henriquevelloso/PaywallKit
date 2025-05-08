//
//  BenefitView.swift
//  PaywallKit
//
//  Displays a single paywall benefit row.
//

import SwiftUI

public struct BenefitView: View {
    let benefit: Benefit

    public init(benefit: Benefit) {
        self.benefit = benefit
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: benefit.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: benefit.title))
                    .bold()
                    .foregroundColor(.primary)
                Text(String(localized: benefit.description))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}

#if DEBUG
#Preview {
    BenefitView(benefit: Benefit(
        title: "paywall_benefit_premium_title",
        description: "paywall_benefit_premium_desc",
        iconName: "star.fill"
    ))
    .padding()
    .previewDisplayName("BenefitView Preview")
}
#endif
