# PaywallKit

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0%2B-orange.svg" />
  <img src="https://img.shields.io/badge/iOS-16.0%2B-blue.svg" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" />
</p>

PaywallKit is a **SwiftUI-only** library that lets you build beautiful, configurable paywalls in minutes.
It supports both **StoreKit 2** and **RevenueCat** out-of-the-box, offers three ready-made layouts, and can be customized entirely via a single `PaywallConfig` struct.

## Features

| Category      | Highlights                                                      |
|---------------|-----------------------------------------------------------------|
| Dual Engine   | Switch between **StoreKit 2** and **RevenueCat** with one line.   |
| Layouts       | `.full`, `.trial`, `.promo` – choose at launch or per-instance.   |
| Components    | Benefit list, product cards, restore button, links to ToS & Privacy. |
| Carousel      | Optional rotating background images (different sets per paywall). |
| Type Safety   | Enum-based `ProductID` – define once, reuse everywhere.           |
| Modern API    | Async/await, Swift 6, SwiftUI (no UIKit).                       |
| Resources     | Bundled asset catalog + `Localizable.strings` (ready for i18n).   |

## Table of Contents
1.  [Requirements](#requirements)
2.  [Installation](#installation)
3.  [Quick Start](#quick-start)
4.  [Configuration](#configuration)
    *   [Payment Engine](#payment-engine)
    *   [Paywall Type](#paywall-type)
    *   [Product IDs](#product-ids)
    *   [UI Customization](#ui-customization)
5.  [Usage](#usage)
6.  [Project Structure](#project-structure)
7.  [Contributing](#contributing)
8.  [License](#license)

## Requirements

|         | Minimum |
|---------|---------|
| iOS     | 16.0    |
| Xcode   | 15.0    |
| Swift   | 6.0     |

RevenueCat SDK (if used) is pulled automatically via Swift Package Manager when you select the `.revenueCat` engine.

## Installation

### Swift Package Manager (Xcode)

1.  In Xcode, open your project and navigate to **File → Add Packages…**
2.  Enter the repository URL in the search bar:
    ```
    https://github.com/henriquevelloso/PaywallKit
    ```
3.  For **Dependency Rule**, select **Up to Next Major Version** (recommended).
4.  Click **Add Package**.
5.  Choose the `PaywallKit` library and add it to your desired target.

## Quick Start

1.  **Import PaywallKit** in your Swift file:
    ```swift
    import PaywallKit
    ```

2.  **Configure Core Settings** (typically in your `AppDelegate`'s `application(_:didFinishLaunchingWithOptions:)` method or your `App` struct's `init()`):
    ```swift
    // In AppDelegate.swift or YourApp.swift
    import PaywallKit

    // ...
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Choose your payment engine
        PaywallConfig.paymentEngine = .storeKit2 // Or .revenueCat

        // If using RevenueCat, provide your API key
        if PaywallConfig.paymentEngine == .revenueCat {
            PaywallConfig.revenueCatAPIKey = "YOUR_REVENUECAT_API_KEY" // Replace with your actual key
            // Initialize RevenueCat SDK with your API key as per RevenueCat's documentation
            // Purchases.configure(withAPIKey: PaywallConfig.revenueCatAPIKey)
        }
        
        // (Optional) Set a default paywall type for your app
        PaywallConfig.defaultPaywallType = .full // Or .trial, .promo

        // (Optional) Define your product IDs
        // PaywallConfig.productIdentifiers = [
        //     .monthly: "your_monthly_product_id",
        //     .annual: "your_annual_product_id",
        //     .lifetime: "your_lifetime_product_id"
        // ]
        
        // (Optional) Customize titles, subtitles, features, images etc.
        // See "UI Customization" section for more details.
        // Example:
        // PaywallConfig.fullScreenPaywall.title = "Unlock Everything"

        return true
    }
    ```
    *Note: For RevenueCat, ensure you also initialize the RevenueCat SDK (`Purchases.configure(withAPIKey:)`) as per their official documentation.*

3.  **Display the Paywall** from any SwiftUI view:
    ```swift
    // In a SwiftUI View where you want to trigger the paywall
    import SwiftUI
    import PaywallKit

    struct YourAppView: View {
        @State private var shouldShowPaywall = false

        var body: some View {
            Button("Unlock Premium Features") {
                shouldShowPaywall = true
            }
            .sheet(isPresented: $shouldShowPaywall) {
                // Uses the default type from PaywallConfig.defaultPaywallType
                // and other globally configured settings.
                PaywallContainerView()
                
                // Or, specify a type and/or a custom configuration for this instance:
                // let customConfig = PaywallConfig.full // Start with a base
                // customConfig.title = "Special Offer!" 
                // PaywallContainerView(type: .promo, config: customConfig)
            }
        }
    }
    ```

## Configuration

PaywallKit is designed to be highly configurable globally via the `PaywallConfig` static properties, or on a per-instance basis by passing a `PaywallConfig` object to `PaywallContainerView`.

### Payment Engine

Set your desired payment processing backend. This should be done early in your app's lifecycle.

### Payment Engine

Set your desired payment processing backend. This should be done early in your app's lifecycle.


## Usage

To display a paywall, use the `PaywallContainerView` in your SwiftUI views. You can customize its appearance and behavior by passing a `PaywallConfig` object.

```swift
import SwiftUI
import PaywallKit

struct YourAppView: View {
    @State private var shouldShowPaywall = false

    var body: some View {
        Button("Unlock Premium Features") {
            shouldShowPaywall = true
        }
        .sheet(isPresented: $shouldShowPaywall) {
            PaywallContainerView()
        }
    }
}
```

## Project Structure

The PaywallKit project is structured into several folders:

*   `Sources/PaywallKit`: Contains the main source code for the library.
*   `Sources/PaywallKit/Views`: Holds the SwiftUI views used to display the paywall.
*   `Sources/PaywallKit/ViewModels`: Contains the view models that manage the paywall's state and logic.
*   `Sources/PaywallKit/Managers`: Includes managers for handling purchases and revenue cat integration.
*   `Sources/PaywallKit/Config`: Holds configuration classes and structs.
*   `Sources/PaywallKit/Models`: Defines data models used throughout the library.

## Contributing

Contributions are welcome! Please see the `CONTRIBUTING.md` file for more details on how to contribute.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
