//
//  TextView.swift
//  FidraComponents
//
//  Created by hi on 13/8/25.
//

import SwiftUI
import Localize_Swift


public struct TextView: View {
    let text: String
    @State private var refreshID = UUID()

    public init(_ text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text.localized())
         .id(refreshID)
         .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LCLLanguageChangeNotification"))) { _ in
             refreshID = UUID()
        }
    }
}

#Preview {
    TextView("Test")
}

