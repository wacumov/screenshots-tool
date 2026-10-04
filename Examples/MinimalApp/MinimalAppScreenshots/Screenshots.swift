import ScreenshotsTool
import SwiftUI
import Testing
@testable import MinimalApp

@MainActor
@Test(arguments: ["en-US", "de-DE"])
func recordScreenshots(locale: String) async throws {
    if ProcessInfo.processInfo.environment["SCREENSHOTS_MODE"] == "marketing" {
        try await recordMarketingScreenshot("1", locale: locale, title: "First View") {
            RootView(selectedTab: 0)
        }
        try await recordMarketingScreenshot("2", locale: locale, title: "Second View") {
            RootView(selectedTab: 1)
        }
    } else {
        try await ScreenshotsTool.record("1", locale: locale) { RootView(selectedTab: 0) }
        try await ScreenshotsTool.record("2", locale: locale) { RootView(selectedTab: 1) }
    }
}

@MainActor
private func recordMarketingScreenshot<Content: View>(
    _ name: String,
    locale: String,
    title: LocalizedStringKey,
    @ViewBuilder content: () -> Content
) async throws {
    let rawURL = try await ScreenshotsTool.record(name, locale: locale) {
        content()
    }
    let image = try ScreenshotImage(rawURL)

    try await ScreenshotsTool.record(name, locale: locale, path: "marketing-screenshots") {
        MarketingScreenshot(
            title,
            background: LinearGradient(
                colors: [Color(red: 0.95, green: 0.82, blue: 0.50), Color(red: 0.99, green: 0.45, blue: 0.32)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ) {
            image
        }
    }
}
