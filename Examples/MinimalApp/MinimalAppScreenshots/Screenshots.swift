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
        MarketingScreenshot(title: title, content: image)
    }
}

private struct MarketingScreenshot<Content: View>: View {
    let title: LocalizedStringKey
    let content: Content

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let ratio = max(geometry.size.width, geometry.size.height) / side
            let device: DeviceFrame<Content>.Device = ratio > 1.7 ? .iphone : .ipad

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.82, blue: 0.50),
                        Color(red: 0.99, green: 0.45, blue: 0.32),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: side * 0.04) {
                    Text(title)
                        .font(.system(size: side * 0.075, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.22), radius: 8, y: 4)

                    DeviceFrame(device) {
                        content
                    }
                    .frame(maxWidth: geometry.size.width * 0.88, maxHeight: geometry.size.height * 0.78)
                }
                .padding(side * 0.055)
            }
        }
    }
}
