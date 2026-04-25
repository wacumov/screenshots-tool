// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Screenshotz",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Screenshotz",
            targets: ["Screenshotz"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.19.2"
        ),
    ],
    targets: [
        .target(
            name: "Screenshotz",
            dependencies: [
                .product(
                    name: "SnapshotTesting",
                    package: "swift-snapshot-testing"
                ),
            ]
        ),
    ]
)
