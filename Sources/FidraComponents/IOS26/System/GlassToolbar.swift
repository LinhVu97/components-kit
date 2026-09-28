//
//  GlassToolbar.swift
//  FidraComponents
//

import SwiftUI

public enum GlassToolbarVisibilityPriority: Sendable, Equatable {
    case automatic
    case low
    case high
}

@available(iOS 16.0, *)
extension ToolbarContent {
    @ToolbarContentBuilder
    public func glassToolbarPriority(_ priority: GlassToolbarVisibilityPriority) -> some ToolbarContent {
        #if compiler(>=6.4)
        if #available(iOS 27.0, *) {
            switch priority {
            case .automatic:
                self.visibilityPriority(.automatic)
            case .low:
                self.visibilityPriority(.low)
            case .high:
                self.visibilityPriority(.high)
            }
        } else {
            self
        }
        #else
        self
        #endif
    }
}

/// Groups toolbar actions into the system overflow menu (iOS 27+) or trailing group fallback.
@available(iOS 16.0, *)
public struct GlassToolbarOverflow<Content: View>: ToolbarContent {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    @ToolbarContentBuilder
    public var body: some ToolbarContent {
        #if compiler(>=6.4)
        if #available(iOS 27.0, *) {
            ToolbarOverflowMenu(content: { content })
        } else {
            ToolbarItemGroup(placement: .primaryAction) {
                content
            }
        }
        #else
        ToolbarItemGroup(placement: .primaryAction) {
            content
        }
        #endif
    }
}

extension View {
    @ViewBuilder
    public func glassToolbarBackgroundHiddenIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbarBackground(.hidden, for: .navigationBar)
        } else {
            self
        }
    }
}
