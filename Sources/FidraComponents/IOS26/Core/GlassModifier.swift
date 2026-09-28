//
//  GlassModifier.swift
//  FidraComponents
//

import SwiftUI

struct GlassModifier: ViewModifier {
    let style: GlassStyle
    let shape: GlassShape
    let unionId: AnyHashable?
    let namespace: Namespace.ID?

    @ViewBuilder
    func body(content: Content) -> some View {
        if style.isEnabled {
            if #available(iOS 26, *), let unionId, let namespace {
                content
                    .applyGlassEffect(style: style, shape: shape)
                    .glassEffectUnion(id: unionId, namespace: namespace)
            } else {
                content
                    .applyGlassEffect(style: style, shape: shape)
            }
        } else {
            content
        }
    }
}

struct GlassButtonStyleModifier: ViewModifier {
    let role: GlassButtonRole

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.modifier(GlassButtonStyleModifier_iOS26(role: role))
        } else if #available(iOS 15, *) {
            content.modifier(GlassButtonStyleModifier_iOS15(role: role))
        } else {
            content
        }
    }
}

@available(iOS 26, *)
private struct GlassButtonStyleModifier_iOS26: ViewModifier {
    let role: GlassButtonRole

    func body(content: Content) -> some View {
        switch role {
        case .regular:
            content.buttonStyle(.glass)
        case .prominent:
            content.buttonStyle(.glassProminent)
        case .interactive:
            content.buttonStyle(.glass(.regular.interactive()))
        case .tintedInteractive(let color):
            content.buttonStyle(.glass(.regular.tint(color).interactive()))
        case .clearTintedInteractive(let color):
            content.buttonStyle(.glass(.clear.tint(color).interactive()))
        }
    }
}

@available(iOS 15, *)
private struct GlassButtonStyleModifier_iOS15: ViewModifier {
    let role: GlassButtonRole

    func body(content: Content) -> some View {
        switch role {
        case .regular, .interactive:
            content.buttonStyle(.bordered)
        case .prominent, .tintedInteractive, .clearTintedInteractive:
            content.buttonStyle(.borderedProminent)
        }
    }
}

extension View {
    @ViewBuilder
    func applyGlassEffect(style: GlassStyle, shape: GlassShape) -> some View {
        if #available(iOS 26, *) {
            applyGlassEffect_iOS26(style: style, shape: shape)
        } else if #available(iOS 15, *) {
            applyGlassFallback_iOS15(style: style, shape: shape)
        } else {
            applyGlassFallback_iOS14(style: style, shape: shape)
        }
    }

    @available(iOS 26, *)
    @ViewBuilder
    private func applyGlassEffect_iOS26(style: GlassStyle, shape: GlassShape) -> some View {
        switch shape {
        case .capsule:
            glassEffect(style.glass, in: Capsule())
        case .circle:
            glassEffect(style.glass, in: Circle())
        case .rect(let cornerRadius):
            glassEffect(style.glass, in: .rect(cornerRadius: cornerRadius))
        }
    }

    @available(iOS 15, *)
    @ViewBuilder
    private func applyGlassFallback_iOS15(style: GlassStyle, shape: GlassShape) -> some View {
        switch shape {
        case .capsule:
            background(.regularMaterial, in: Capsule())
        case .circle:
            background(.regularMaterial, in: Circle())
        case .rect(let cornerRadius):
            background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    private func applyGlassFallback_iOS14(style: GlassStyle, shape: GlassShape) -> some View {
        switch shape {
        case .capsule:
            background(Capsule().fill(Color.primary.opacity(0.08)))
        case .circle:
            background(Circle().fill(Color.primary.opacity(0.08)))
        case .rect(let cornerRadius):
            background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.primary.opacity(0.08)))
        }
    }
}
