//
//  ToastView.swift
//  MusicPainter
//
//  Created by hi on 27/2/25.
//

import SwiftUI

struct ToastView: View {
    let toast: Toast
    let config: ToastConfig
    
    private var styleColors: ToastStyleColors {
        config.colors(for: toast.style)
    }
    
    private var bgColor: Color {
        styleColors.backgroundColor ?? toast.style.defaultColor
    }
    
    private var fgColor: Color {
        styleColors.textColor ?? .white
    }
    
    private var transitionEdge: Edge {
        config.position == .top ? .top : .bottom
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if config.showIcon {
                Image(systemName: toast.style.icon)
                    .foregroundColor(fgColor)
            }
            
            TextView(toast.message)
                .font(.system(size: 14))
                .lineLimit(4)
                .foregroundColor(fgColor)
            
            Spacer()
            
            Button {
                ToastManager.shared.removeToast(toast)
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(fgColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .modifier(ToastBackgroundModifier(
            useGlassEffect: config.useGlassEffect,
            glassStyle: config.glassStyle,
            bgColor: bgColor
        ))
        .padding(.horizontal, 16)
        .transition(.move(edge: transitionEdge).combined(with: .opacity))
    }
}

private struct ToastBackgroundModifier: ViewModifier {
    let useGlassEffect: Bool
    let glassStyle: GlassStyle
    let bgColor: Color

    func body(content: Content) -> some View {
        if useGlassEffect {
            content.glassStyle(glassStyle, shape: .rect(cornerRadius: 12))
        } else {
            content
                .background(RoundedRectangle(cornerRadius: 8).fill(bgColor))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager = ToastManager.shared

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    private var isBottom: Bool {
        toastManager.config.position == .bottom
    }

    private var maxToastWidth: CGFloat {
        #if os(iOS)
        return sizeClass == .regular ? 480 : .infinity
        #else
        return 480
        #endif
    }

    private var edgePadding: CGFloat {
        #if os(iOS)
        return sizeClass == .regular ? 64 : 48
        #else
        return 64
        #endif
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                if isBottom { Spacer() }

                ForEach(toastManager.toasts) { toast in
                    ToastView(toast: toast, config: toastManager.config)
                        .frame(maxWidth: maxToastWidth)
                }

                if !isBottom { Spacer() }
            }
            .padding(isBottom ? .bottom : .top, edgePadding)
            .animation(.easeInOut(duration: 0.3), value: toastManager.toasts)
        }
    }
}

extension View {
    public func toastView() -> some View {
        self.modifier(ToastModifier())
    }
} 
