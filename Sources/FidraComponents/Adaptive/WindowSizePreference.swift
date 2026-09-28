import SwiftUI

/// Helper for configuring window resizability on iOS 27+.
/// Wraps `windowResizability` with backward compatibility.
@available(iOS 17, *)
public struct WindowSizeConfig: Sendable {
    public let minWidth: CGFloat
    public let minHeight: CGFloat
    public let maxWidth: CGFloat?
    public let maxHeight: CGFloat?

    public init(
        minWidth: CGFloat = 320,
        minHeight: CGFloat = 480,
        maxWidth: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) {
        self.minWidth = minWidth
        self.minHeight = minHeight
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
    }

    public static let `default` = WindowSizeConfig()
    public static let phone = WindowSizeConfig(minWidth: 320, minHeight: 480)
    public static let tablet = WindowSizeConfig(minWidth: 480, minHeight: 600)
}

@available(iOS 17, *)
public struct WindowSizeModifier: ViewModifier {
    let config: WindowSizeConfig

    public func body(content: Content) -> some View {
        content.frame(
            minWidth: config.minWidth,
            maxWidth: config.maxWidth ?? .infinity,
            minHeight: config.minHeight,
            maxHeight: config.maxHeight ?? .infinity
        )
    }
}

@available(iOS 17, *)
extension View {
    public func windowSize(_ config: WindowSizeConfig = .default) -> some View {
        modifier(WindowSizeModifier(config: config))
    }
}

/// Modifier to defer expensive work during interactive resize.
@available(iOS 26, *)
public struct InteractiveResizeModifier: ViewModifier {
    @State private var isResizing = false

    private let onResizeChanged: ((Bool) -> Void)?

    public init(onResizeChanged: ((Bool) -> Void)? = nil) {
        self.onResizeChanged = onResizeChanged
    }

    public func body(content: Content) -> some View {
        content
            .onInteractiveResizeChange { resizing in
                isResizing = resizing
                onResizeChanged?(resizing)
            }
            .environment(\.isInteractivelyResizing, isResizing)
    }
}

extension EnvironmentValues {
    @Entry public var isInteractivelyResizing: Bool = false
}

@available(iOS 26, *)
extension View {
    public func trackInteractiveResize(
        onResizeChanged: ((Bool) -> Void)? = nil
    ) -> some View {
        modifier(InteractiveResizeModifier(onResizeChanged: onResizeChanged))
    }
}
