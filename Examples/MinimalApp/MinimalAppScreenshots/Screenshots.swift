import Screenshotz
import Testing
@testable import MinimalApp

@MainActor
@Test(arguments: ["en-US", "de-DE"], [Device.iphone, Device.ipad])
func recordScreenshots(locale: String, device: Device) async throws {
    try await Screenshotz.record("1", locale: locale, device: device) { FirstView() }
    try await Screenshotz.record("2", locale: locale, device: device) { SecondView() }
}

@MainActor
@Test(arguments: ["en-US", "de-DE"], [Device.iphone, Device.ipad])
func recordLandscapeScreenshots(locale: String, device: Device) async throws {
    let device = device.landscape
    try await Screenshotz.record("1", locale: locale, device: device, folder: "screenshots-landscape") { FirstView() }
    try await Screenshotz.record("2", locale: locale, device: device, folder: "screenshots-landscape") { SecondView() }
}
