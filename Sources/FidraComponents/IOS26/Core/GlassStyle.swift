//
//  GlassStyle.swift
//  FidraComponents
//

import SwiftUI

public enum GlassStyle: Sendable, Equatable {
    case regular
    case clear
    case tinted(Color)
    case interactive
    case tintedInteractive(Color)
    case disabled

    public var isEnabled: Bool {
        if case .disabled = self { return false }
        return true
    }

    @available(iOS 26, *)
    var glass: Glass {
        switch self {
        case .regular, .disabled:
            return .regular
        case .clear:
            return .clear
        case .tinted(let color):
            return .regular.tint(color)
        case .interactive:
            return .regular.interactive()
        case .tintedInteractive(let color):
            return .regular.tint(color).interactive()
        }
    }
}
