import ScreenshotsTool
import Testing
@testable import MinimalApp

@MainActor
@Test(arguments: ["en-US", "de-DE"])
func recordScreenshots(locale: String) async throws {
    try await ScreenshotsTool.record("1", locale: locale) { RootView(selectedTab: 0) }
    try await ScreenshotsTool.record("2", locale: locale) { RootView(selectedTab: 1) }
}
