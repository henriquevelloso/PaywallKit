

# Getting Started with PaywallKit

This guide will help you get started with PaywallKit in your iOS app.

## Prerequisites

Before you begin, ensure you have:

- Xcode 14.0 or later
- iOS 15.0+ deployment target
- Active Apple Developer account
- [Optional] RevenueCat account if using RevenueCat integration

## Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to File → Add Packages...
2. Enter the package URL:
   ```
   https://github.com/henriquevelloso/PaywallKit
   ```
3. Select version rules (Usually "Up to Next Major" 1.0.0)
4. Click Add Package

### Basic Setup

1. Import the package:
   ```swift
   import PaywallKit
   ```

2. Configure payment engine:
   ```swift
   PaywallConfig.paymentEngine = .storeKit2  // or .revenueCat
   ```

3. Set default paywall type:
   ```swift
   PaywallConfig.paywallType = .full  // or .trial, .promo
   ```

4. Present the paywall:
   ```swift
   PaywallContainerView()
   ```

## Next Steps

- Check out [Configuration Guide](configuration.md) for detailed setup
- See [Customization Guide](customization.md) for styling options
- Review [Best Practices](best-practices.md) for implementation tips

