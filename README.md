# screenshots-tool

App Store screenshots from SwiftUI views, recorded in the simulator.

## Use

Add a unit-test target hosted by the app, depending on `ScreenshotsTool`:

```swift
import ScreenshotsTool
import SwiftUI
import Testing
@testable import MyApp

@MainActor
@Test(arguments: ["en-US", "de-DE"])
func recordScreenshots(locale: String) async throws {
    let raw = try await ScreenshotsTool.record("1", locale: locale, path: "raw") {
        GameView()
    }
    let image = try ScreenshotImage(raw)
    try await ScreenshotsTool.record("1", locale: locale, path: "output") {
        MarketingScreenshot("Simple rules, clever puzzles", background: Color.indigo) {
            image
        }
    }
}
```

Run the test on each device you need, for example iPhone 17 Pro Max (6.9") and iPad Pro 13-inch:

```sh
xcodebuild test -scheme MyAppScreenshots -destination "platform=iOS Simulator,name=iPhone 17 Pro Max"
```

Files go to `<path>/<locale>/<device>/<name>.png` next to the test file, at the device's native size. `asctool upload-screenshots` reads this layout.

## API

- `ScreenshotsTool.record(_:locale:path:content:)` — renders a view in the key window and saves a PNG.
- `ScreenshotImage(url)` — a saved PNG as a view.
- `MarketingScreenshot(_:captionColor:background:content:)` — caption above the screen in a device frame.
- `DeviceFrame(.iphone | .ipad)` — the frame alone.

Example: [Examples/MinimalApp](Examples/MinimalApp).
