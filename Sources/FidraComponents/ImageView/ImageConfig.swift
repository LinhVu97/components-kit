import Foundation
import Kingfisher

public enum ImageConfig {

    public static func setup(
        memoryLimitMB: Int = 150,
        diskLimitMB: Int = 700,
        diskExpirationDays: Int = 7
    ) {
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = memoryLimitMB * 1024 * 1024
        cache.diskStorage.config.sizeLimit = UInt(diskLimitMB) * 1024 * 1024
        cache.diskStorage.config.expiration = .days(diskExpirationDays)
    }

    public static func processor(size: CGSize) -> ImageProcessor {
        DownsamplingImageProcessor(size: size)
    }
}
