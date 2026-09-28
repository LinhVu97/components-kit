//
//  GlassTabBar.swift
//  FidraComponents
//

import SwiftUI

public enum GlassTabBarMinimizeBehavior: Sendable, Equatable {
    case automatic
    case never
    case onScrollDown
    case onScrollUp
}

extension View {
    @ViewBuilder
    public func glassTabBarMinimizeBehaviorIfAvailable(
        _ behavior: GlassTabBarMinimizeBehavior = .onScrollDown
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.tabBarMinimizeBehavior(behavior.tabBarMinimizeBehavior)
        } else {
            self
        }
    }

    @ViewBuilder
    public func glassTabBarBottomAccessoryIfAvailable<Content: View>(
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        if #available(iOS 26.0, *) {
            self.tabViewBottomAccessory(content: content)
        } else {
            self
        }
    }
}

@available(iOS 26.0, *)
extension GlassTabBarMinimizeBehavior {
    var tabBarMinimizeBehavior: TabBarMinimizeBehavior {
        switch self {
        case .automatic:
            return .automatic
        case .never:
            return .never
        case .onScrollDown:
            return .onScrollDown
        case .onScrollUp:
            return .onScrollUp
        }
    }
}

// Prominent tab usage (inside TabView builder — Tab is not a standalone View):
//
// Tab(value: TabItem.camera, role: .prominent) {
//     Color.clear
// } label: {
//     Label("Camera", systemImage: "camera.fill")
// }
// .glassTabBarMinimizeBehaviorIfAvailable(.onScrollDown)
