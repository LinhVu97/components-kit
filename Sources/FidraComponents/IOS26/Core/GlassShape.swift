//
//  GlassShape.swift
//  FidraComponents
//

import SwiftUI

public enum GlassShape: Sendable, Equatable {
    case capsule
    case circle
    case rect(cornerRadius: CGFloat)
}
