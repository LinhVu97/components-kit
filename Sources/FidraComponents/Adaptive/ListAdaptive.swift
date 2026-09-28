import SwiftUI

/// Adaptive List that adjusts content width and insets based on size class.
/// On regular width (iPad / large window): constrains content with readable width and extra insets.
/// On compact width (iPhone / small window): full-width standard list.
@available(iOS 15, *)
public struct ListAdaptive<Content: View>: View {
    private let maxContentWidth: CGFloat
    private let compactInsets: EdgeInsets
    private let regularInsets: EdgeInsets
    private let content: () -> Content

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    public init(
        maxContentWidth: CGFloat = 700,
        compactInsets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        regularInsets: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.maxContentWidth = maxContentWidth
        self.compactInsets = compactInsets
        self.regularInsets = regularInsets
        self.content = content
    }

    public var body: some View {
        List {
            content()
                .listRowInsets(currentInsets)
        }
        #if os(iOS)
        .frame(maxWidth: sizeClass == .regular ? maxContentWidth : .infinity)
        .frame(maxWidth: .infinity)
        #endif
    }

    private var currentInsets: EdgeInsets {
        #if os(iOS)
        return sizeClass == .regular ? regularInsets : compactInsets
        #else
        return regularInsets
        #endif
    }
}
