//
//  View+Glass.swift
//  FidraComponents
//

import SwiftUI

extension View {
    public func glassStyle(
        _ style: GlassStyle = .regular,
        shape: GlassShape = .capsule,
        unionId: AnyHashable? = nil,
        namespace: Namespace.ID? = nil
    ) -> some View {
        modifier(
            GlassModifier(
                style: style,
                shape: shape,
                unionId: unionId,
                namespace: namespace
            )
        )
    }

    public func glassButtonStyle(_ role: GlassButtonRole = .regular) -> some View {
        modifier(GlassButtonStyleModifier(role: role))
    }

    /// Interactive glass CTA — clear tint when enabled, regular glass when disabled.
    @ViewBuilder
    public func glassInteractiveButtonStyle(
        tint: Color,
        isEnabled: Bool = true
    ) -> some View {
        if isEnabled {
            self.glassButtonStyle(.clearTintedInteractive(tint))
        } else {
            self.glassButtonStyle(.regular)
        }
    }

    public func glassStyleUnion<ID: Hashable & Sendable>(
        id: ID,
        namespace: Namespace.ID
    ) -> some View {
        modifier(GlassStyleUnionModifier(id: id, namespace: namespace))
    }
}

private struct GlassStyleUnionModifier<ID: Hashable & Sendable>: ViewModifier {
    let id: ID
    let namespace: Namespace.ID

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffectUnion(id: id, namespace: namespace)
        } else {
            content
        }
    }
}
