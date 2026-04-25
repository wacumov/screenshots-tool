#if os(iOS)
import Foundation
import SnapshotTesting
import SwiftUI
import UIKit

public extension Screenshotz {
    @MainActor
    @discardableResult
    static func record<Content: View>(
        _ name: String,
        locale: String,
        device: Device = .iphone,
        folder: String = "screenshots",
        file: StaticString = #filePath,
        @ViewBuilder content: () -> Content
    ) async throws -> URL {
        let view = AnyView(content().environment(\.locale, Locale(identifier: locale)))

        let snapshotting = Snapshotting<AnyView, UIImage>.image(
            drawHierarchyInKeyWindow: true,
            layout: .fixed(width: device.width, height: device.height),
            traits: UITraitCollection(displayScale: device.scale)
        )

        let image = await withCheckedContinuation { continuation in
            snapshotting.snapshot(view).run {
                continuation.resume(returning: $0)
            }
        }

        let directory = URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .appendingPathComponent(folder, isDirectory: true)
            .appendingPathComponent(device.folder, isDirectory: true)
            .appendingPathComponent(locale, isDirectory: true)

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
