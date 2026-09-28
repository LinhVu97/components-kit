//
//  GlassCard.swift
//  FidraComponents
//

import SwiftUI

public struct GlassCard<Content: View>: View {
    private let style: GlassStyle
    private let cornerRadius: CGFloat
    private let compactPadding: CGFloat
    private let regularPadding: CGFloat
    private let maxWidth: CGFloat?
    private let content: () -> Content

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    public init(
        style: GlassStyle = .regular,
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16,
        regularPadding: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.compactPadding = padding
        self.regularPadding = regularPadding ?? padding
        self.maxWidth = maxWidth
        self.content = content
    }

    private var currentPadding: CGFloat {
        #if os(iOS)
        return sizeClass == .regular ? regularPadding : compactPadding
        #else
        return regularPadding
        #endif
    }

    public var body: some View {
        content()
            .padding(currentPadding)
            .frame(maxWidth: maxWidth)
            .glassStyle(style, shape: .rect(cornerRadius: cornerRadius))
    }
}
