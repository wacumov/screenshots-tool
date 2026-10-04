import SwiftUI

/// A caption above the app screen in a device frame, on any background.
public struct MarketingScreenshot<Background: View, Content: View>: View {
    private let caption: Text
    private let captionColor: Color
    private let background: Background
    private let content: Content

    public init(
        _ caption: LocalizedStringKey,
        captionColor: Color = .white,
        background: Background,
        @ViewBuilder content: () -> Content
    ) {
        self.caption = Text(caption)
        self.captionColor = captionColor
        self.background = background
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let isPhone = max(geometry.size.width, geometry.size.height) / side > 1.7
            ZStack {
                background
                VStack(spacing: side * 0.05) {
                    caption
                        .font(.system(size: side * 0.085, weight: .heavy, design: .rounded))
                        .foregroundStyle(captionColor)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                    DeviceFrame(isPhone ? .iphone : .ipad) {
                        content
                    }
                }
                .padding(side * 0.06)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MarketingScreenshot("Simple rules, clever puzzles", background: LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom)) {
        Color.white
    }
}
