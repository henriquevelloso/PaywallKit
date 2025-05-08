//
//  PurchaseButton.swift
//  PaywallKit
//
//  Reusable purchase/subscribe/buy button for Paywall.
//

import SwiftUI

public struct PurchaseButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    public init(title: String, isLoading: Bool = false, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: {
            if !isLoading && isEnabled { action() }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isEnabled ? Color.accentColor : Color.gray.opacity(0.4))
                    .frame(height: 56)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(height: 56)
                } else {
                    Text(title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
            }
        }
        .disabled(isLoading || !isEnabled)
        .animation(.easeInOut(duration: 0.15), value: isLoading)
    }
}

#if DEBUG
#Preview("PurchaseButton - enabled") {
    PurchaseButton(title: "Subscribe now", isLoading: false, isEnabled: true) { }
        .padding()
}
#Preview("PurchaseButton - loading") {
    PurchaseButton(title: "Loading...", isLoading: true, isEnabled: false) { }
        .padding()
}
#endif
