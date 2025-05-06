# PaywallKit

A reusable SwiftUI package for displaying in-app paywalls with support for both StoreKit2 and RevenueCat.
<https://github.com/henriquevelloso/PaywallKit>

---

## Features

- **Dual Purchase Engine**: Switch between StoreKit 2 and RevenueCat globally via `PaywallConfig.paymentEngine`.
- **Pre-configured Paywall Types**: Full, Trial, and Promo layouts ready to use, selectable via `PaywallConfig.paywallType`.
- **Modular Architecture**: Clear separation of Models, Managers, ViewModels, and Views.
- **Single `ProductID` Enum**: Define product IDs once, promoting clarity and avoiding duplication (used internally by views).
- **Background Carousel**: Optional rotating background images, configurable via `PaywallConfig`.
- **SwiftUI Components**:
  - `PaywallView` and `PaywallPromoView` for standard and promotional layouts.
  - `BenefitsSection` to highlight your app’s benefits.
  - `PaywallOptionsScroll` and `PaywallOptionCard` for subscription options.
  - `PaywallFooterView` with Terms, Privacy, and Restore Purchase links.
- **Customizable**: Provide your own assets, benefit descriptions, and localization strings via static properties on `PaywallConfig`.
- **Resource Bundling**: Includes support for asset catalogs and `Localizable.strings` in the package.
- **SwiftUI-only**: 100% declarative UI.

---

## Requirements

|            | Minimum   |
|------------|-----------|
| iOS        | 15.0      |
| Xcode      | 14.0      |
| Swift      | 5.7       |

---

## Installation (Swift Package Manager)

1.  In Xcode, go to **File → Add Packages…**
2.  Paste the repository URL:
    ```
    https://github.com/henriquevelloso/PaywallKit
    ```
3.  Select the **PaywallKit** library target and click **Add Package**.

---
## 🚀 Usage

This section guides you on how to integrate and configure PaywallKit in your application.

### Quick Start Guide

For a minimal setup, follow these steps:

1.  **Import PaywallKit**:
    ```swift
    import PaywallKit
    ```
2.  **Configure Core Settings** (typically in your `AppDelegate`'s `application(_:didFinishLaunchingWithOptions:)` method or your `App` struct's `init()`):
    ```swift
    // In AppDelegate.swift or YourApp.swift
    import PaywallKit // Ensure PaywallKit is imported

    // ...
    PaywallConfig.paymentEngine = .storeKit2 // Or .revenueCat
    if PaywallConfig.paymentEngine == .revenueCat {
        PaywallConfig.revenueCatAPIKey = "YOUR_REVENUECAT_API_KEY" // Replace with your actual key
    }
    PaywallConfig.paywallType = .full // Or .trial, .promo
    // ...
    ```
3.  **Display the Paywall** (from any SwiftUI view):
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
                PaywallContainerView() // This view uses the static configurations from PaywallConfig
            }
        }
    }
    ```

For more detailed configuration options, including customizing benefits, background images, and understanding product ID management, please refer to the detailed sections below and the "Customization Details" section further down.

### Detailed Configuration and Usage

The Quick Start Guide covers the essentials. Here’s a more in-depth look at each step and further customization options:

#### 1. Importing the Package
As shown in the Quick Start, to make PaywallKit's functionality available in your Swift files, you need to import it:
```swift
import PaywallKit
