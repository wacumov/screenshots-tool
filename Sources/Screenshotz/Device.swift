import Foundation

public struct Device: Sendable {
    public let folder: String
    public let width: CGFloat
    public let height: CGFloat
    public let scale: CGFloat

    public init(folder: String, width: CGFloat, height: CGFloat, scale: CGFloat) {
        self.folder = folder
        self.width = width
        self.height = height
        self.scale = scale
    }

    public static let iphone = Device(folder: "iphone", width: 440, height: 956, scale: 3)
    public static let ipad = Device(folder: "ipad", width: 1032, height: 1376, scale: 2)
}
