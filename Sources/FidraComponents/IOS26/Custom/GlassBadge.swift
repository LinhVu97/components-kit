//
//  GlassBadge.swift
//  FidraComponents
//

import SwiftUI

public struct GlassBadge: View {
    private let text: String
    private let icon: String?
    private let style: GlassStyle
    private let shape: GlassShape

    public init(
        _ text: String,
        icon: String? = nil,
        style: GlassStyle = .regular,
        shape: GlassShape = .capsule
    ) {
        self.text = text
        self.icon = icon
        self.style = style
        self.shape = shape
    }

    public var body: some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .glassStyle(style, shape: shape)
    }
}
