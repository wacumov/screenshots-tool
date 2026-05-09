import SwiftUI

public struct DeviceFrame<Content: View>: View {
    public enum Device {
        case iphone
        case ipad
    }

    public enum Orientation {
        case portrait
        case landscape
    }

    private let device: Device
    private let orientation: Orientation
    private let content: Content

    public init(
        _ device: Device,
        orientation: Orientation = .portrait,
        @ViewBuilder content: () -> Content
    ) {
        self.device = device
        self.orientation = orientation
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            let metrics = Metrics<Content>(device: device, orientation: orientation)
            let size = metrics.size(in: geometry.size)
            let screenSize = metrics.screenSize(in: size)

            ZStack {
                RoundedRectangle(cornerRadius: metrics.frameRadius(for: size), style: .continuous)
                    .fill(.black)
                    .shadow(color: .black.opacity(0.28), radius: metrics.shadowRadius, y: metrics.shadowY)

                RoundedRectangle(cornerRadius: metrics.screenRadius(for: size), style: .continuous)
                    .fill(.black)
                    .overlay(
                        content
                            .frame(width: screenSize.width, height: screenSize.height)
                            .clipShape(RoundedRectangle(cornerRadius: metrics.screenRadius(for: size), style: .continuous))
                    )
                    .frame(width: screenSize.width, height: screenSize.height)

                if device == .iphone {
                    Capsule()
                        .fill(.black)
                        .frame(width: metrics.cameraSize(in: size).width, height: metrics.cameraSize(in: size).height)
                        .offset(metrics.cameraOffset(in: size))
                }
            }
            .frame(width: size.width, height: size.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(Metrics<Content>(device: device, orientation: orientation).frameRatio, contentMode: .fit)
    }
}

private struct Metrics<Content: View> {
    let device: DeviceFrame<Content>.Device
    let orientation: DeviceFrame<Content>.Orientation

    var frameRatio: CGFloat {
        switch (device, orientation) {
        case (.iphone, .portrait):
            return 1206 / 2622
        case (.iphone, .landscape):
            return 2622 / 1206
        case (.ipad, .portrait):
            return 3 / 4
        case (.ipad, .landscape):
            return 4 / 3
        }
    }

    var shadowRadius: CGFloat {
        switch device {
        case .iphone:
            return 18
        case .ipad:
            return 24
        }
    }

    var shadowY: CGFloat {
        switch device {
        case .iphone:
            return 10
        case .ipad:
            return 14
        }
    }

    func size(in bounds: CGSize) -> CGSize {
        if bounds.width / bounds.height > frameRatio {
            return CGSize(width: bounds.height * frameRatio, height: bounds.height)
        } else {
            return CGSize(width: bounds.width, height: bounds.width / frameRatio)
        }
    }

    func screenSize(in frameSize: CGSize) -> CGSize {
        let inset = bezel(in: frameSize)
        let maxSize = CGSize(width: frameSize.width - inset * 2, height: frameSize.height - inset * 2)

        if maxSize.width / maxSize.height > frameRatio {
            return CGSize(width: maxSize.height * frameRatio, height: maxSize.height)
        } else {
            return CGSize(width: maxSize.width, height: maxSize.width / frameRatio)
        }
    }

    func bezel(in frameSize: CGSize) -> CGFloat {
        min(frameSize.width, frameSize.height) * (device == .iphone ? 0.035 : 0.028)
    }

    func frameRadius(for frameSize: CGSize) -> CGFloat {
        min(frameSize.width, frameSize.height) * (device == .iphone ? 0.11 : 0.055)
    }

    func screenRadius(for frameSize: CGSize) -> CGFloat {
        min(frameSize.width, frameSize.height) * (device == .iphone ? 0.075 : 0.035)
    }

    func cameraSize(in frameSize: CGSize) -> CGSize {
        let side = min(frameSize.width, frameSize.height)
        switch orientation {
        case .portrait:
            return CGSize(width: side * 0.24, height: side * 0.035)
        case .landscape:
            return CGSize(width: side * 0.035, height: side * 0.24)
        }
    }

    func cameraOffset(in frameSize: CGSize) -> CGSize {
        let inset = bezel(in: frameSize) * 1.5
        switch orientation {
        case .portrait:
            return CGSize(width: 0, height: -frameSize.height / 2 + inset * 2.2)
        case .landscape:
            return CGSize(width: -frameSize.width / 2 + inset * 2.2, height: 0)
        }
    }
}
