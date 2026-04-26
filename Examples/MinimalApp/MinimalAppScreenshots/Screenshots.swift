import Screenshotz
import Testing
@testable import MinimalApp

@MainActor
@Test(arguments: ["en-US", "de-DE"])
func recordScreenshots(locale: String) async throws {
    try await Screenshotz.record("1", locale: locale) { RootView(selectedTab: 0) }
    try await Screenshotz.record("2", locale: locale) { RootView(selectedTab: 1) }
}
