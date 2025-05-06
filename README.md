# PaywallKit

A reusable SwiftUI package for displaying in-app paywalls with support for both StoreKit2 and RevenueCat.

## Features

- **Dual Purchase Engine**: Switch between StoreKit2 and RevenueCat globally via a single configuration flag.
- **Pre‑configured Paywall Types**: Full, Trial, and Promo paywalls ready to use out of the box.
- **Modular Architecture**: Clear separation of Models, Managers, ViewModels, and Views.
- **SwiftUI Components**:  
  - `PaywallView` and `PaywallPromoView` for standard and promotional layouts.  
  - `BenefitsSection` to highlight your app’s benefits.  
  - `PaywallOptionsScroll` and `PaywallOptionCard` for subscription options.  
  - `PaywallFooterView` with Terms, Privacy, and Restore Purchase links.
- **Customizable**: Provide your own product IDs, assets, benefit descriptions, and localization strings via `PaywallConfig`.
- **Resource Bundling**: Includes support for asset catalogs and `Localizable.strings` in the package.

## Requirements

- iOS 15.0 or later  
- Xcode 14.0 or later  
- Swift 5.7 or later  

## Installation

Add the package to your project via Swift Package Manager:

1. In Xcode, go to **File → Add Packages…**
2. Enter your repository URL, e.g.:  
   ```
   https://github.com/YourUsername/PaywallKit.git
   ```
3. Select the **PaywallKit** library target and click **Add Package**.

## Usage

### 1. Import the Package

```swift
import PaywallKit
```

### 2. Configure the Purchase Engine

Set the global engine at app launch (e.g., in `App.swift` or `SceneDelegate`):

```swift
PurchaseSettings.shared.engine = .revenueCat  // or .storeKit2
```

### 3. Choose a Paywall Configuration

Use one of the built‑in presets or create your own:

```swift
let config = PaywallConfig.full
// Or customize:
// let config = PaywallConfig(
//     productIDs: [.weeklyTrial, .annual],
//     promoProductIDs: [.lifetimePromo],
//     backgroundImages: ["customBg1", "customBg2"],
//     promoBackgroundImages: ["promoCustom1"],
//     benefits: [Benefit(iconName: "star.fill", title: "Awesome Feature", description: "Description here")],
//     showTerms: true,
//     showPrivacy: true,
//     showRestore: true
// )
```

### 4. Display the Paywall

Embed the paywall view in your SwiftUI hierarchy:

```swift
// Full paywall
PaywallContainerView(type: .full, config: PaywallConfig.full)

// Trial-only paywall
PaywallContainerView(type: .trial, config: PaywallConfig.trial)

// Promotional paywall
PaywallContainerView(type: .promo, config: PaywallConfig.promo)
```

## Customization

- **Assets**: Replace or add your own image sets under `Resources/Backgrounds.xcassets` and `Resources/PromoBackgrounds.xcassets`.
- **Localization**: Edit `Resources/Localizable.strings` to provide translations for buttons and labels.
- **Benefits & UI**: Update the `PaywallConfig` arrays to adjust benefit icons, titles, and descriptions.

## License

This project is open source under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](https://github.com/YourUsername/PaywallKit/issues) or submit a pull request.

## Acknowledgments

- Built with SwiftUI and StoreKit2.  
- Powered by RevenueCat for subscription management.
