//
//  PaywallCarouselView.swift
//  PaywallKit
//
//  Carousel that displays background images.
//

import SwiftUI

public struct PaywallCarouselView: View {
    let images: [String]
    @State private var selected: Int = 0

    public init(images: [String]) {
        self.images = images
    }

    public var body: some View {
        TabView(selection: $selected) {
            ForEach(Array(images.enumerated()), id: \.offset) { index, imgName in
                Image(imgName)
                    .resizable()
                    .scaledToFill()
                    .tag(index)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 8)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 220)
        .animation(.easeInOut(duration: 0.18), value: selected)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    PaywallCarouselView(images: ["full_bg1", "full_bg2", "promo_bg1"])
        .background(Color(.systemGray6))
        .padding()
}
#endif
