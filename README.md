# PaywallKit

A lightweight Swift Package that lets you **drop-in a fully localised paywall** (StoreKit 2 or RevenueCat) into any iOS app in minutes.

> GitHub repo: <https://github.com/henriquevelloso/PaywallKit>

---

## 1 · Supported OS & Tools

|                 | Minimum |
|-----------------|---------|
| iOS             | 16.0    |
| Xcode           | 15      |
| Swift           | 6       |

---

## 2 · Install via Swift Package Manager

1. **Xcode → File → Add Packages…**  
2. Paste the repo URL  

    ```
    https://github.com/henriquevelloso/PaywallKit
    ```

3. Select the **PaywallKit** product and press **Add Package**.

That’s it—no other setup scripts are required.

---

## 3 · Quick-start (4 Steps = < 2 min)

| Step | Code | What it does |
|------|------|--------------|
| 1 | `import PaywallKit` | Access everything |
| 2 | `PaywallConfig.paymentEngine = .storeKit2` | Pick **StoreKit 2** (or `.revenueCat`) globally |
| 3 | `PaywallConfig.paywallType = .full` | Choose the UI layout: `.full`, `.trial`, `.promo` |
| 4 | `PaywallContainerView()` | Present the paywall anywhere |
