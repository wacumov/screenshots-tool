import Screenshotz
import SwiftUI
import Testing

@MainActor
@Test func recordScreenshotOne() async throws {
    try await Screenshotz.record("1") {
        Text("ScreenshotOne")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
    }
}
