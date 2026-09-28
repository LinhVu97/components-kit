import SwiftUI

public struct BackButtonView: View {
    public var imageName: String
    public var iconSize: CGFloat
    public var buttonSize: CGFloat
    public var onBack: () -> Void

    public init(
        imageName: String = "IconBackButton",
        iconSize: CGFloat = 36,
        buttonSize: CGFloat = 44,
        onBack: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.iconSize = iconSize
        self.buttonSize = buttonSize
        self.onBack = onBack
    }

    public var body: some View {
        Button("Settings", systemImage: "chevron.left") {
            Task { @MainActor in
                onBack()
            }
        }.font(.system(size: iconSize)).labelStyle(.iconOnly)
    }
}

#Preview {
    VStack {
        BackButtonView() {
            print("Back button pressed")
        }
    }.background(.red)
}
