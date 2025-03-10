// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

//@available(macOS 14.0, *)
public struct MaterialButton<Content> : View where Content : View {

    public let paddingH: CGFloat
    public let paddingV: CGFloat
    public let fontSize: CGFloat
    public let fontColor: Color
    public let backgroundColor: Color
    public let radius: CGFloat
    public let action: () -> Void
    @ViewBuilder public let label: () -> Content
    
    public init(
        paddingH: CGFloat = 16,
        paddingV: CGFloat = 8,
        fontSize: CGFloat = 17,
        fontColor: Color = .white,
        backgroundColor: Color = .accentColor, 
        radius: CGFloat = 4, 
        action: @escaping () -> Void, 
        label: @escaping () -> Content
    ) {
        self.paddingH = paddingH
        self.paddingV = paddingV
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.radius = radius
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: {}, label: {
            label()
        })
        .buttonStyle(
            MaterialButtonStyle(
                paddingH: paddingH,
                paddingV: paddingV,
                fontSize: fontSize,
                fontColor: fontColor,
                backgroundColor: backgroundColor,
                radius: radius,
                action: action
            )
        )
    }
}

//@available(macOS 14.0, *)
public struct MaterialButtonStyle : ButtonStyle {

    public let paddingH: CGFloat
    public let paddingV: CGFloat
    public let fontSize: CGFloat
    public let fontColor: Color
    public let backgroundColor: Color
    public let radius: CGFloat
    public let action: () -> Void
    public let backgroundColorPressed: Color = .white.opacity(0.15)
    
    @State private var isPressed = false
    @State private var rippleRadius: CGFloat = 0
    @State private var tapPoint: CGPoint = .zero
    @State private var size: CGSize = .zero
    
    public init(
        paddingH: CGFloat = 16,
        paddingV: CGFloat = 8,
        fontSize: CGFloat = 17,
        fontColor: Color = .white,
        backgroundColor: Color, 
        radius: CGFloat, 
        action: @escaping () -> Void
    ) {
        self.paddingH = paddingH
        self.paddingV = paddingV
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.radius = radius
        self.action = action
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, paddingH)
            .padding(.vertical, paddingV)
            .background {
                GeometryReader { reader in
                    Rectangle()
                        .fill(backgroundColor)
                        .overlay {
                            Circle()
                                .fill(isPressed ? backgroundColorPressed : .clear)
                                .offset(x: tapPoint.x - size.width / 2, y: tapPoint.y - size.height / 2)
                                .frame(width: rippleRadius * 2, height: rippleRadius * 2)
                        }
                        .onAppear {
                            size.width = reader.size.width
                            size.height = reader.size.height
                        }
                        .onChange(of: reader.size) {
                            size = reader.size
                        }
                }
            }
            .font(.system(size: fontSize))
            .foregroundColor(fontColor)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPressed {
                            isPressed = true
                            rippleRadius = max(min(size.width, size.height) / 4, 8)
                            
                            tapPoint.x = value.location.x
                            tapPoint.y = value.location.y

                            withAnimation(.easeInOut(duration: 0.1)) {
                                rippleRadius = getRippleRadius()
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPressed = false
                        }
                        if abs(value.translation.width) < 2 && abs(value.translation.height) < 2
                                && value.location.x >= 0 && value.location.x <= size.width
                                && value.location.y >= 0 && value.location.y <= size.height {
                            action()
                        }
                    }
            )
    }
    
    private func getRippleRadius()-> CGFloat {
        let xLenMax = max(tapPoint.x, size.width - tapPoint.x)
        let yLenMax = max(tapPoint.y, size.height - tapPoint.y)
        
        return sqrt(pow(xLenMax, 2) + pow(yLenMax, 2))
    }
    
}
