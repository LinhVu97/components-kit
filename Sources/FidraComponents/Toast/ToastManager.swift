//
//  ToastManager.swift
//  MusicPainter
//
//  Created by hi on 27/2/25.
//

import SwiftUI
import Combine

public enum ToastPosition {
    case top
    case bottom
}

public struct ToastStyleColors {
    public var backgroundColor: Color?
    public var textColor: Color?
    
    public init(backgroundColor: Color? = nil, textColor: Color? = nil) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}

public struct ToastConfig {
    public var position: ToastPosition
    public var showIcon: Bool
    public var useGlassEffect: Bool
    public var glassStyle: GlassStyle
    public var successColors: ToastStyleColors
    public var errorColors: ToastStyleColors
    public var infoColors: ToastStyleColors
    
    public init(
        position: ToastPosition = .top,
        showIcon: Bool = true,
        useGlassEffect: Bool = false,
        glassStyle: GlassStyle = .regular,
        successColors: ToastStyleColors = ToastStyleColors(),
        errorColors: ToastStyleColors = ToastStyleColors(),
        infoColors: ToastStyleColors = ToastStyleColors()
    ) {
        self.position = position
        self.showIcon = showIcon
        self.useGlassEffect = useGlassEffect
        self.glassStyle = glassStyle
        self.successColors = successColors
        self.errorColors = errorColors
        self.infoColors = infoColors
    }
    
    func colors(for style: ToastStyle) -> ToastStyleColors {
        switch style {
        case .success: return successColors
        case .error: return errorColors
        case .info: return infoColors
        }
    }
}

public enum ToastStyle {
    case success
    case error
    case info
    
    var defaultColor: Color {
        switch self {
        case .success: return Color.green
        case .error: return Color.red
        case .info: return Color.blue
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

struct Toast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let style: ToastStyle
    let duration: TimeInterval
    
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
public class ToastManager: ObservableObject {
    @Published var toasts: [Toast] = []
    @Published public var config: ToastConfig = ToastConfig()
    
    public static let shared = ToastManager()
    private init() {}
    
    public func configure(_ config: ToastConfig) {
        self.config = config
    }
    
    func show(message: String, style: ToastStyle = .info, duration: TimeInterval = 2.0) {
        let toast = Toast(message: message, style: style, duration: duration)
        toasts.append(toast)
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            removeToast(toast)
        }
    }
    
    public func showSuccess(message: String, duration: TimeInterval = 2.0) {
        show(message: message, style: .success, duration: duration)
    }
    
    public func showError(message: String, duration: TimeInterval = 2.0) {
        show(message: message, style: .error, duration: duration)
    }
    
    public func showInfo(message: String, duration: TimeInterval = 2.0) {
        show(message: message, style: .info, duration: duration)
    }
    
    func removeToast(_ toast: Toast) {
        toasts.removeAll { $0.id == toast.id }
    }
} 
