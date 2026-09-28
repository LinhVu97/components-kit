import SwiftUI

/// Applies different modifiers based on horizontal size class.
@available(iOS 14, *)
public struct ResponsiveModifier<Compact: ViewModifier, Regular: ViewModifier>: ViewModifier {
    private let compact: Compact
    private let regular: Regular

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    public init(compact: Compact, regular: Regular) {
        self.compact = compact
        self.regular = regular
    }

    public func body(content: Content) -> some View {
        #if os(iOS)
        if sizeClass == .regular {
            content.modifier(regular)
        } else {
            content.modifier(compact)
        }
        #else
        content.modifier(regular)
        #endif
    }
}

extension View {
    /// Apply different modifiers for compact vs regular size class.
    public func responsive<C: ViewModifier, R: ViewModifier>(
        compact: C,
        regular: R
    ) -> some View {
        modifier(ResponsiveModifier(compact: compact, regular: regular))
    }
}

/// Applies different padding based on horizontal size class.
@available(iOS 14, *)
public struct ResponsivePaddingModifier: ViewModifier {
    private let compactPadding: CGFloat
    private let regularPadding: CGFloat
    private let edges: Edge.Set

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    public init(edges: Edge.Set = .all, compact: CGFloat, regular: CGFloat) {
        self.edges = edges
        self.compactPadding = compact
        self.regularPadding = regular
    }

    public func body(content: Content) -> some View {
        #if os(iOS)
        content.padding(edges, sizeClass == .regular ? regularPadding : compactPadding)
        #else
        content.padding(edges, regularPadding)
        #endif
    }
}

extension View {
    public func responsivePadding(
        _ edges: Edge.Set = .all,
        compact: CGFloat,
        regular: CGFloat
    ) -> some View {
        modifier(ResponsivePaddingModifier(edges: edges, compact: compact, regular: regular))
    }
}
