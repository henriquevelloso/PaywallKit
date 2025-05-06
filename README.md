# PaywallKit

Drop-in **SwiftUI paywalls** for StoreKit 2 or RevenueCat, entregue como **Swift Package** para fácil reutilização em vários apps.

<https://github.com/henriquevelloso/PaywallKit>

---

## ✨ Principais recursos

* 1-linha para alternar **StoreKit 2 ↔︎ RevenueCat**  
* Três layouts prontos: **Full**, **Trial**, **Promo**  
* Enum único de `ProductID` (zero repetição)  
* Carrossel de imagens de fundo configurável  
* Componentes compartilhados (benefits, restore, terms)  
* 100 % SwiftUI, iOS 16+, Swift 6

---

## 🔧 Requisitos

|            | Versão mínima |
|------------|---------------|
| iOS        | 16            |
| Xcode      | 15            |
| Swift      | 6             |

---

## 📦 Instalação via SPM

### 1. Pelo Xcode (GUI)

1. **Xcode → File → Add Packages…**  
2. Cole a URL do repositório:
   ```
   https://github.com/henriquevelloso/PaywallKit
   ```
3. Selecione o produto **PaywallKit** → **Add Package**.

### 2. Pelo `Package.swift` (projetos SPM)

---

## 3 · Quick-start (4 Steps = < 2 min)

| Step | Code | What it does |
|------|------|--------------|
| 1 | `import PaywallKit` | Access everything |
| 2 | `PaywallConfig.paymentEngine = .storeKit2` | Pick **StoreKit 2** (or `.revenueCat`) globally |
| 3 | `PaywallConfig.paywallType = .full` | Choose the UI layout: `.full`, `.trial`, `.promo` |
| 4 | `PaywallContainerView()` | Present the paywall anywhere |
