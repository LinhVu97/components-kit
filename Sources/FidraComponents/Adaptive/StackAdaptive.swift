import SwiftUI

/// Auto-switches between HStack (regular width) and VStack (compact width).
/// Responds dynamically to iPad resize, Split View, and iPhone Mirroring.
@available(iOS 14, *)
public struct StackAdaptive<Content: View>: View {
    private let horizontalAlignment: HorizontalAlignment
    private let verticalAlignment: VerticalAlignment
    private let spacing: CGFloat?
    private let content: () -> Content

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    public init(
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        #if os(iOS)
        if sizeClass == .regular {
            HStack(alignment: verticalAlignment, spacing: spacing) {
                content()
            }
        } else {
            VStack(alignment: horizontalAlignment, spacing: spacing) {
                content()
            }
        }
        #else
        HStack(alignment: verticalAlignment, spacing: spacing) {
            content()
        }
        #endif
    }
}
