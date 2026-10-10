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
    private let statusBar: Bool
    private let content: Content

    public init(
        _ device: Device,
        orientation: Orientation = .portrait,
        statusBar: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.device = device
        self.orientation = orientation
        self.statusBar = statusBar
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            let metrics = Metrics<Content>(device: device, orientation: orientation)
            let size = metrics.size(in: geometry.size)
            let screenSize = metrics.screenSize(in: size)

            ZStack {
                if device == .iphone && orientation == .portrait {
                    SideButtons(frameSize: size)
                }

                RoundedRectangle(cornerRadius: metrics.frameRadius(for: size), style: .continuous)
                    .fill(.black)
                    .shadow(color: .black.opacity(0.28), radius: metrics.shadowRadius, y: metrics.shadowY)

                RoundedRectangle(cornerRadius: metrics.screenRadius(for: size), style: .continuous)
                    .fill(.black)
                    .overlay(
                        content
                            .frame(width: screenSize.width, height: screenSize.height)
                            .overlay(alignment: .top) {
                                if statusBar && orientation == .portrait {
                                    StatusBar(device: device, screenSize: screenSize)
                                }
                            }
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

    var screenRatio: CGFloat {
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

    var frameRatio: CGFloat {
        let inset = bezelScale * 2

        if screenRatio > 1 {
            return screenRatio * (1 - inset) + inset
        } else {
            return 1 / (inset + (1 - inset) / screenRatio)
        }
    }

    var bezelScale: CGFloat {
        device == .iphone ? 0.035 : 0.028
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
        return CGSize(width: frameSize.width - inset * 2, height: frameSize.height - inset * 2)
    }

    func bezel(in frameSize: CGSize) -> CGFloat {
        min(frameSize.width, frameSize.height) * bezelScale
    }

    func frameRadius(for frameSize: CGSize) -> CGFloat {
        min(frameSize.width, frameSize.height) * (device == .iphone ? 0.125 : 0.055)
    }

    func screenRadius(for frameSize: CGSize) -> CGFloat {
        min(frameSize.width, frameSize.height) * (device == .iphone ? 0.088 : 0.035)
    }

    func cameraSize(in frameSize: CGSize) -> CGSize {
        let side = min(frameSize.width, frameSize.height)
        switch orientation {
        case .portrait:
            return CGSize(width: side * 0.24, height: side * 0.064)
        case .landscape:
            return CGSize(width: side * 0.064, height: side * 0.24)
        }
    }

    func cameraOffset(in frameSize: CGSize) -> CGSize {
        let inset = bezel(in: frameSize) * 1.5
        switch orientation {
        case .portrait:
            return CGSize(width: 0, height: -frameSize.height / 2 + inset * 1.9)
        case .landscape:
            return CGSize(width: -frameSize.width / 2 + inset * 1.9, height: 0)
        }
    }
}

private struct SideButtons: View {
    let frameSize: CGSize

    var body: some View {
        let width = frameSize.width * 0.012
        ZStack {
            button(top: 0.20, length: 0.035, edge: .leading, width: width)
            button(top: 0.26, length: 0.065, edge: .leading, width: width)
            button(top: 0.345, length: 0.065, edge: .leading, width: width)
            button(top: 0.28, length: 0.10, edge: .trailing, width: width)
        }
        .frame(width: frameSize.width + width * 2, height: frameSize.height)
    }

    private func button(top: CGFloat, length: CGFloat, edge: HorizontalAlignment, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: width / 2)
            .fill(Color(white: 0.15))
            .frame(width: width * 2, height: frameSize.height * length)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment(horizontal: edge, vertical: .top))
            .offset(y: frameSize.height * top)
    }
}

private struct StatusBar: View {
    let device: DeviceFrame<EmptyView>.Device
    let screenSize: CGSize

    init<Content>(device: DeviceFrame<Content>.Device, screenSize: CGSize) {
        self.device = device == .iphone ? .iphone : .ipad
        self.screenSize = screenSize
    }

    var body: some View {
        let isPhone = device == .iphone
        let fontSize = screenSize.width * (isPhone ? 0.04 : 0.0135)
        HStack(spacing: fontSize * 0.3) {
            Text("9:41")
                .font(.system(size: fontSize, weight: .semibold))
                .frame(maxWidth: isPhone ? .infinity : nil)
            if isPhone {
                Spacer().frame(width: screenSize.width * 0.3)
            } else {
                Spacer()
            }
            HStack(spacing: fontSize * 0.3) {
                Image(systemName: "cellularbars")
                Image(systemName: "wifi")
                Image(systemName: "battery.100percent")
                    .font(.system(size: fontSize * 1.15))
            }
            .font(.system(size: fontSize * 0.85, weight: .semibold))
            .frame(maxWidth: isPhone ? .infinity : nil)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, isPhone ? 0 : fontSize * 1.5)
        .frame(height: isPhone ? screenSize.width * 0.125 : fontSize * 2.2)
    }
}
