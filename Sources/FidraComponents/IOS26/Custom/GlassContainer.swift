//
//  GlassContainer.swift
//  FidraComponents
//

import SwiftUI

public struct GlassContainer<Content: View>: View {
    private let spacing: CGFloat
    private let content: () -> Content

    public init(
        spacing: CGFloat = 40,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing, content: content)
        } else {
            content()
        }
    }
}
