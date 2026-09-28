import SwiftUI

/// Reads current size classes and provides content based on layout context.
/// Safe for iOS 27 resizable windows, iPad resize, and iPhone Mirroring.
@available(iOS 14, *)
public struct SizeClassReader<Content: View>: View {
    private let content: (LayoutContext) -> Content

    public init(
        @ViewBuilder content: @escaping (LayoutContext) -> Content
    ) {
        self.content = content
    }

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontal
    @Environment(\.verticalSizeClass) private var vertical

    public var body: some View {
        let context = LayoutContext(
            horizontal: horizontal ?? .compact,
            vertical: vertical ?? .regular
        )
        content(context)
    }
    #else
    public var body: some View {
        content(LayoutContext(horizontal: .regular, vertical: .regular))
    }
    #endif
}

public struct LayoutContext: Sendable {
    public let horizontal: UserInterfaceSizeClass
    public let vertical: UserInterfaceSizeClass

    public var isCompact: Bool {
        horizontal == .compact
    }

    public var isRegular: Bool {
        horizontal == .regular
    }

    /// Compact both dimensions (small iPhone or tiny iPad window)
    public var isCompactAll: Bool {
        horizontal == .compact && vertical == .compact
    }

    /// Regular both dimensions (full-size iPad or large window)
    public var isRegularAll: Bool {
        horizontal == .regular && vertical == .regular
    }
}
