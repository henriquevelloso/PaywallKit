
//
//  TermsPrivacyRestoreView.swift
//

import SwiftUI

/// Common footer with Terms of Use, Privacy, and Restore.
struct TermsPrivacyRestoreView: View {
    let restoreAction: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Button(String(localized: "Restore Purchases"), action: restoreAction)
            HStack(spacing: 16) {
                Link(String(localized: "Terms of Use"),
                     destination: URL(string: "https://example.com/terms")!)
                Link(String(localized: "Privacy Policy"),
                     destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }
}
