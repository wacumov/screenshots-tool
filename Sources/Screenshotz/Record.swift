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
        outputDirectory: URL? = nil,
        file: StaticString = #filePath,
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

        let directory = outputDirectory ?? URL(fileURLWithPath: "\(file)")
            .deletingLastPathComponent()
            .appendingPathComponent("screenshots/iphone", isDirectory: true)

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
