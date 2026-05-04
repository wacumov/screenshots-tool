// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "screenshots-tool",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "ScreenshotsTool",
            targets: ["ScreenshotsTool"]
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
            name: "ScreenshotsTool",
            dependencies: [
                .product(
                    name: "SnapshotTesting",
                    package: "swift-snapshot-testing"
                ),
            ]
        ),
    ]
)
