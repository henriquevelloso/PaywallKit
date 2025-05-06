//
//  BenefitView.swift
//

import SwiftUI

/// Single row showing an icon + title + subtitle.
struct BenefitView: View {
    let benefit: PaywallConfig.Benefit

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: benefit.iconSystemName)
                // CHANGE: Accent colour
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(benefit.title).bold()
                Text(benefit.subtitle).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}
