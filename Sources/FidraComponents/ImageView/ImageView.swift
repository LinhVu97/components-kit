import SwiftUI
import Kingfisher

public struct ImageView: View {

    private let url: URL?
    private let contentMode: SwiftUI.ContentMode
    private let cornerRadius: CGFloat
    private let placeholderImage: (@Sendable () -> AnyView)?
    private let cacheMemoryOnly: Bool
    private let useDownsampling: Bool

    @Environment(\.displayScale) private var displayScale

    // MARK: - Legacy init (backward compatible)

    public init(
        url: String,
        placeholderImage: (@Sendable () -> AnyView)? = nil,
        cacheMemoryOnly: Bool = false
    ) {
        self.url = URL(string: url)
        self.contentMode = .fill
        self.cornerRadius = 0
        self.placeholderImage = placeholderImage
        self.cacheMemoryOnly = cacheMemoryOnly
        self.useDownsampling = false
    }

    // MARK: - New init (optimized with downsampling)

    public init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        cornerRadius: CGFloat = 0
    ) {
        self.url = url
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.placeholderImage = nil
        self.cacheMemoryOnly = false
        self.useDownsampling = true
    }

    public var body: some View {
        if useDownsampling {
            downsampledBody
        } else {
            legacyBody
        }
    }

    // MARK: - Optimized body (GeometryReader + ImageLoader)

    private var downsampledBody: some View {
        GeometryReader { geometry in
            if let url = url {
                ImageLoader.shared.buildImage(
                    url: url,
                    size: geometry.size,
                    displayScale: displayScale,
                    contentMode: contentMode
                )
                .placeholder { defaultPlaceholder }
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .cornerRadius(cornerRadius)
            } else {
                defaultPlaceholder
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(cornerRadius)
            }
        }
    }

    // MARK: - Legacy body (backward compatible)

    private var legacyBody: some View {
        KFImage(url)
            .placeholder {
                if let placeholderImage = placeholderImage {
                    placeholderImage()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            SwiftUI.Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                        )
                }
            }
            .loadDiskFileSynchronously()
            .cacheMemoryOnly(cacheMemoryOnly)
            .fade(duration: 0.3)
            .resizable()
    }

    private var defaultPlaceholder: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.25),
                                Color.gray.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
    }
}
