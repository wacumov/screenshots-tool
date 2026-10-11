import SwiftUI

public struct DeviceFrame<Content: View>: View {
    public enum Device {
        case iphone
        case ipad
        /// The outer display of iPhone Duo.
        case iphoneDuo
    }

    public enum Orientation {
        case portrait
        case landscape
    }

    private let device: Device
    private let orientation: Orientation
    private let statusBar: Bool
    private let statusBarTitle: String?
    private let content: Content

    public init(
        _ device: Device,
        orientation: Orientation = .portrait,
        statusBar: Bool = true,
        statusBarTitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.device = device
        self.orientation = orientation
        self.statusBar = statusBar
        self.statusBarTitle = statusBarTitle
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

                metrics.frameShape(for: size)
                    .fill(.black)
                    .shadow(color: .black.opacity(0.28), radius: metrics.shadowRadius, y: metrics.shadowY)

                metrics.screenShape(for: size)
                    .fill(.black)
                    .overlay(
                        content
                            .frame(width: screenSize.width, height: screenSize.height)
                            .overlay(alignment: .top) {
                                if statusBar && orientation == .portrait && device != .iphoneDuo {
                                    StatusBar(isPhone: device == .iphone, title: statusBarTitle, screenSize: screenSize)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if statusBar && orientation == .portrait && device == .iphoneDuo {
                                    VerticalStatusBar(screenSize: screenSize)
                                }
                            }
                            .clipShape(metrics.screenShape(for: size))
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
        case (.iphoneDuo, .portrait):
            return 1398 / 2034
        case (.iphoneDuo, .landscape):
            return 2034 / 1398
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
        device == .ipad ? 0.028 : 0.035
    }

    var shadowRadius: CGFloat {
        switch device {
        case .iphone, .iphoneDuo:
            return 18
        case .ipad:
            return 24
        }
    }

    var shadowY: CGFloat {
        switch device {
        case .iphone, .iphoneDuo:
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

    func frameShape(for frameSize: CGSize) -> UnevenRoundedRectangle {
        let bezel = bezel(in: frameSize)
        let screen = screenShape(for: frameSize)
        return UnevenRoundedRectangle(
            topLeadingRadius: screen.cornerRadii.topLeading + bezel,
            bottomLeadingRadius: screen.cornerRadii.bottomLeading + bezel,
            bottomTrailingRadius: screen.cornerRadii.bottomTrailing + bezel,
            topTrailingRadius: screen.cornerRadii.topTrailing + bezel,
            style: .continuous
        )
    }

    /// iPhone Duo outer display corners are 8 pt on the hinge side and 59 pt on the other side.
    func screenShape(for frameSize: CGSize) -> UnevenRoundedRectangle {
        guard device == .iphoneDuo else {
            let radius = screenRadius(for: frameSize)
            return UnevenRoundedRectangle(cornerRadii: .init(topLeading: radius, bottomLeading: radius, bottomTrailing: radius, topTrailing: radius), style: .continuous)
        }
        let screenWidth = screenSize(in: frameSize).width
        let (hinge, outer) = (screenWidth * 8 / 466, screenWidth * 59 / 466)
        return UnevenRoundedRectangle(
            topLeadingRadius: hinge,
            bottomLeadingRadius: hinge,
            bottomTrailingRadius: outer,
            topTrailingRadius: outer,
            style: .continuous
        )
    }


    func screenRadius(for frameSize: CGSize) -> CGFloat {
        min(frameSize.width, frameSize.height) * (device == .ipad ? 0.035 : 0.088)
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
    let isPhone: Bool
    let title: String?
    let screenSize: CGSize

    // 9:41 on January 9, 2007, the time Apple uses in its marketing.
    private static let date = Date(timeIntervalSince1970: 1_168_364_460)

    var body: some View {
        if isPhone {
            let fontSize = screenSize.width * 0.0425
            HStack(spacing: 0) {
                Text("9:41")
                    .font(.system(size: fontSize, weight: .semibold))
                    .frame(maxWidth: .infinity)
                Spacer().frame(width: screenSize.width * 0.3)
                icons(fontSize: fontSize)
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.black)
            .frame(height: screenSize.width * 0.16)
        } else {
            let fontSize = screenSize.width * 0.013
            HStack(spacing: fontSize) {
                Text("9:41")
                Text(Self.date, format: .dateTime.weekday(.abbreviated))
                    + Text(" ")
                    + Text(Self.date, format: .dateTime.month(.abbreviated).day())
                if let title {
                    Text(title).fontWeight(.semibold)
                }
                Spacer()
                icons(fontSize: fontSize)
            }
            .font(.system(size: fontSize, weight: .medium))
            .foregroundStyle(.black)
            .padding(.horizontal, screenSize.width * 0.025)
            .frame(height: fontSize * 2.35)
        }
    }

    private func icons(fontSize: CGFloat) -> some View {
        HStack(spacing: fontSize * 0.3) {
            Image(systemName: "cellularbars")
            Image(systemName: "wifi")
            Image(systemName: "battery.100percent")
                .font(.system(size: fontSize * 1.15))
        }
        .font(.system(size: fontSize * 0.85, weight: .semibold))
    }
}

/// The status bar of the iPhone Duo outer display, at the top of its trailing column.
private struct VerticalStatusBar: View {
    let screenSize: CGSize

    var body: some View {
        let unit = screenSize.width / 466
        VStack(spacing: 6 * unit) {
            Text("9:41")
                .font(.system(size: 16 * unit, weight: .semibold))
            Circle()
                .trim(from: 0.12, to: 0.88)
                .stroke(style: StrokeStyle(lineWidth: 3.5 * unit, lineCap: .round))
                .rotationEffect(.degrees(90))
                .frame(width: 40 * unit, height: 40 * unit)
                .overlay {
                    WiFiShape()
                        .frame(width: 15 * unit, height: 11 * unit)
                }
            HStack(spacing: 3 * unit) {
                ForEach(0 ..< 4) { index in
                    Circle()
                        .frame(width: 4 * unit, height: 4 * unit)
                        .offset(y: (index == 0 || index == 3 ? 0 : 1.5) * unit)
                }
            }
            .offset(y: -8 * unit)
        }
        .foregroundStyle(.black)
        .frame(width: 84 * unit)
        .padding(.top, 81 * unit)
        .offset(x: -3 * unit)
    }
}

/// The Wi-Fi glyph, drawn as a shape because the SF Symbol does not render here on iOS 27.1.
private struct WiFiShape: View {
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let center = CGPoint(x: size.width / 2, y: size.height * 0.95)
            let lineWidth = size.height * 0.16
            ZStack {
                ForEach(1 ..< 4) { index in
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: size.height * 0.95 * CGFloat(index) / 3.2,
                            startAngle: .degrees(-135),
                            endAngle: .degrees(-45),
                            clockwise: false
                        )
                    }
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                }
                Circle()
                    .frame(width: lineWidth * 1.6, height: lineWidth * 1.6)
                    .position(x: center.x, y: center.y - lineWidth * 0.3)
            }
        }
    }
}
