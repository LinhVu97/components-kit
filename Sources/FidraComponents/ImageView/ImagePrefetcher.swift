import Foundation
import Kingfisher

public enum ImagePrefetcher {

    public static func prefetch(_ urls: [URL]) {
        let prefetcher = Kingfisher.ImagePrefetcher(
            urls: urls,
            options: [.backgroundDecode]
        )
        prefetcher.start()
    }
}
