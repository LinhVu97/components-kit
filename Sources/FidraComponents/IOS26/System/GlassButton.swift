//
//  GlassButton.swift
//  FidraComponents
//

import SwiftUI

public enum GlassButtonRole: Sendable, Equatable {
    case regular
    case prominent
    case interactive
    case tintedInteractive(Color)
    case clearTintedInteractive(Color)
}

public struct GlassButton<Label: View>: View {
    private let role: GlassButtonRole
    private let action: () -> Void
    private let label: () -> Label

    public init(
        role: GlassButtonRole = .regular,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(action: action, label: label)
            .glassButtonStyle(role)
    }
}

extension GlassButton where Label == Text {
    public init(
        _ title: String,
        role: GlassButtonRole = .regular,
        action: @escaping () -> Void
    ) {
        self.role = role
        self.action = action
        self.label = { Text(title) }
    }

    /// CTA with clear glass + brand tint + interactive feedback.
    public init(
        _ title: String,
        tint: Color,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.role = isEnabled ? .clearTintedInteractive(tint) : .regular
        self.action = action
        self.label = { Text(title) }
    }
}
