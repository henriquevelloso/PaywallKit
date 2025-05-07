

# PaywallKit Best Practices

## Configuration

1. **Initialize Early**
   ```swift
   // In App/SceneDelegate
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       setupPaywallKit()
       return true
   }
   
   private func setupPaywallKit() {
       PaywallConfig.paymentEngine = .storeKit2
       PaywallConfig.paywallType = .full
       // Other configurations...
   }
   ```

2. **Error Handling**
   ```swift
   .sheet(isPresented: $showPaywall) {
       PaywallContainerView()
           .onDisappear {
               // Handle dismissal
           }
   }
   ```

3. **Testing**
   - Use StoreKit Configuration files
   - Test all purchase flows
   - Verify restoration works
   - Test network errors

## Performance

1. **Image Optimization**
   - Optimize background images
   - Use appropriate image formats
   - Consider screen sizes

2. **Memory Management**
   - Don't keep paywalls presented unnecessarily
   - Clean up any observers

## User Experience

1. **Presentation Timing**
   - Choose appropriate moments
   - Don't interrupt critical flows
   - Consider user journey

2. **Error Communication**
   - Clear error messages
   - Provide recovery options
   - Guide users through issues

