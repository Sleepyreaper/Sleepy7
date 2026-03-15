// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CoreEngine",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "CoreEngine", targets: ["CoreEngine"])
    ],
    targets: [
        .target(
            name: "CoreEngine",
            path: "Sources/CoreEngine"
        ),
        .testTarget(
            name: "CoreEngineTests",
            dependencies: ["CoreEngine"],
            path: "Tests/CoreEngineTests"
        )
    ]
)