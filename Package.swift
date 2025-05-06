// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PaywallKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PaywallKit",
            targets: ["PaywallKit"]),
    ],
    dependencies: [
        // RevenueCat via SPM
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PaywallKit",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios")
            ],
            path: "Sources/PaywallKit",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PaywallKitTests",
            dependencies: ["PaywallKit"]
        )
    ]
)
