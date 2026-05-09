#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import UIKit

public extension ScreenshotsTool {
    @MainActor
    @discardableResult
    static func record<Content: View>(
        _ name: String,
        locale: String,
        path: String = "screenshots",
        file: StaticString = #filePath,
        @ViewBuilder content: () -> Content
    ) async throws -> URL {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }.first!
        let window = scene.windows.first { $0.isKeyWindow } ?? scene.windows.first!

        let host = UIHostingController(
            rootView: content().environment(\.locale, Locale(identifier: locale))
        )

        let config = ViewImageConfig(
            safeArea: window.safeAreaInsets,
            size: window.bounds.size,
            traits: window.traitCollection
        )

        let snapshotting = Snapshotting<UIViewController, UIImage>.image(
            on: config,
            drawHierarchyInKeyWindow: true,
            traits: window.traitCollection
        )

        let image = await withCheckedContinuation { continuation in
            snapshotting.snapshot(host).run {
                continuation.resume(returning: $0)
            }
        }

        let deviceFolder = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]?
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            ?? (window.traitCollection.userInterfaceIdiom == .pad ? "ipad" : "iphone")

        let directory = URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .appendingPathComponent(path, isDirectory: true)
            .appendingPathComponent(locale, isDirectory: true)
            .appendingPathComponent(deviceFolder, isDirectory: true)

        let fileURL = directory
            .appendingPathComponent(name, isDirectory: false)
            .appendingPathExtension("png")

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        try snapshotting.diffing.toData(image).write(to: fileURL)

        return fileURL
    }
}
#endif
