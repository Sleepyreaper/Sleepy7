// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MonetizationKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MonetizationKit", targets: ["MonetizationKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.13.0"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "MonetizationKit",
            dependencies: [
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
                .product(name: "UserMessagingPlatform", package: "swift-package-manager-google-user-messaging-platform")
            ],
            path: "Sources/MonetizationKit"
        ),
        .testTarget(
            name: "MonetizationKitTests",
            dependencies: ["MonetizationKit"],
            path: "Tests/MonetizationKitTests"
        )
    ]
)