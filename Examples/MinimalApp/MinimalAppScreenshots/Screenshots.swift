import Screenshotz
import Testing
@testable import MinimalApp

@MainActor
@Test(arguments: ["en-US", "de-DE"])
func recordScreenshotOne(locale: String) async throws {
    try await Screenshotz.record("1", locale: locale) {
        FirstView()
    }
}
