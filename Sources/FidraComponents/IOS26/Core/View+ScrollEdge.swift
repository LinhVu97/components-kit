//
//  View+ScrollEdge.swift
//  FidraComponents
//

import SwiftUI

public enum GlassScrollEdgeStyle: Sendable, Equatable {
    case automatic
    case soft
    case hard
}

extension View {
    @ViewBuilder
    public func scrollEdgeEffectStyleIfAvailable(
        _ style: GlassScrollEdgeStyle = .soft,
        for edges: Edge.Set = .all
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.scrollEdgeEffectStyle(style.scrollEdgeEffectStyle, for: edges)
        } else {
            self
        }
    }

    @ViewBuilder
    public func scrollEdgeEffectHiddenIfAvailable(for edges: Edge.Set = .all) -> some View {
        if #available(iOS 26.0, *) {
            self.scrollEdgeEffectHidden(for: edges)
        } else {
            self
        }
    }
}

@available(iOS 26.0, *)
extension GlassScrollEdgeStyle {
    var scrollEdgeEffectStyle: ScrollEdgeEffectStyle {
        switch self {
        case .automatic:
            return .automatic
        case .soft:
            return .soft
        case .hard:
            return .hard
        }
    }
}
