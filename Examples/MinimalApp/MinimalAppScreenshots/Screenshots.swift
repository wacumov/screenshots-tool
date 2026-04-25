import Screenshotz
import Testing
@testable import MinimalApp

@MainActor
@Test func recordScreenshotOne() async throws {
    try await Screenshotz.record("1") {
        FirstView()
    }
}
