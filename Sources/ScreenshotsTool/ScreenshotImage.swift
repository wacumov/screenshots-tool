#if os(iOS)
import SwiftUI
import UIKit

public struct ScreenshotImage: View {
    private let image: UIImage

    public init(_ url: URL) throws {
        guard let image = UIImage(contentsOfFile: url.path) else {
            throw MissingScreenshotImageError(url: url)
        }
        self.image = image
    }

    public var body: some View {
        Image(uiImage: image)
            .resizable()
    }
}

private struct MissingScreenshotImageError: LocalizedError {
    let url: URL

    var errorDescription: String? {
        "Cannot read screenshot image at \(url.path)."
    }
}
#endif
