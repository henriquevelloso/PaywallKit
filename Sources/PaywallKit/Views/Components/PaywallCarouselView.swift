
//
//  PaywallCarouselView.swift
//

import SwiftUI

/// Simple horizontal paging carousel for background images.
struct PaywallCarouselView: View {
    let images: [String]
    @State private var index: Int = 0

    var body: some View {
        TabView(selection: $index) {
            ForEach(images.indices, id: \.self) { i in
                Image(images[i])
                    .resizable()
                    .scaledToFill()
                    .tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}
