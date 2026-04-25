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
        outputDirectory: URL = URL(fileURLWithPath: "screenshots/iphone", isDirectory: true),
        @ViewBuilder content: () -> Content
    ) async throws -> URL {
        let snapshotting = Snapshotting<Content, UIImage>.image(
            layout: .fixed(width: 440, height: 956),
            traits: UITraitCollection(displayScale: 3)
        )

        let image = await withCheckedContinuation { continuation in
            snapshotting.snapshot(content()).run {
                continuation.resume(returning: $0)
            }
        }

        let fileURL = outputDirectory
            .appendingPathComponent(name, isDirectory: false)
            .appendingPathExtension("png")

        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )
        try snapshotting.diffing.toData(image).write(to: fileURL)

        return fileURL
    }
}
#endif
