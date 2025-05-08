//
//  TermsPrivacyRestoreView.swift
//  PaywallKit
//
//  Shows links to Terms & Conditions, Privacy Policy, and Restore Purchases.
//

import SwiftUI

public struct TermsPrivacyRestoreView: View {
    let onRestore: (() -> Void)?

    public init(onRestore: (() -> Void)? = nil) {
        self.onRestore = onRestore
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 16) {
                Link(
                    String(localized: "paywall_terms_title"),
                    destination: URL(string: "https://YOUR_TERMS_URL")! // customize on app integration
                )
                Text("•")
                    .foregroundColor(.secondary)
                Link(
                    String(localized: "paywall_privacy_title"),
                    destination: URL(string: "https://YOUR_PRIVACY_URL")! // customize on app integration
                )
            }
            .font(.footnote)
            .foregroundColor(.secondary)

            if let onRestore {
                Button(action: onRestore) {
                    Text(String(localized: "paywall_restore_button"))
                        .font(.footnote)
                        .underline()
                }
                .padding(.top, 2)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 4)
    }
}

#if DEBUG
#Preview {
    TermsPrivacyRestoreView(onRestore: { print("restore tapped") })
        .padding()
}
#endif
