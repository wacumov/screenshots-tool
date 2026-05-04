import SwiftUI

public struct Screenshot<Content: View> {
    public let name: String
    public let content: @MainActor () -> Content

    public init(
        _ name: String,
        @ViewBuilder content: @escaping @MainActor () -> Content
    ) {
        self.name = name
        self.content = content
    }
}
