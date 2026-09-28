import SwiftUI
import Kingfisher

@MainActor
public final class ImageLoader {

    public static let shared = ImageLoader()

    private init() {}

    /// Build KFImage with per-window displayScale (iOS 27+ resizable environment safe)
    public func buildImage(
        url: URL,
        size: CGSize,
        displayScale: CGFloat = 0,
        contentMode: SwiftUI.ContentMode = .fill
    ) -> KFImage {
        let processor = ImageConfig.processor(size: size)
        let scaleFactor = displayScale > 0 ? displayScale : Self.fallbackScale

        return KFImage(url)
            .setProcessor(processor)
            .scaleFactor(scaleFactor)
            .cacheOriginalImage()
            .backgroundDecode()
            .fade(duration: 0.15)
            .cancelOnDisappear(true)
            .retry(maxCount: 2)
    }

    @MainActor
    private static var fallbackScale: CGFloat {
        UIScreen.main.scale
    }
}
