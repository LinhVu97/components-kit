import SwiftUI

/// Adaptive grid that automatically adjusts column count based on available width.
/// Uses `LazyVGrid` with `adaptive` columns for fluid resizing.
@available(iOS 14, *)
public struct GridAdaptive<Data, ItemContent: View>: View where Data: RandomAccessCollection, Data.Element: Identifiable {
    private let data: Data
    private let minItemWidth: CGFloat
    private let spacing: CGFloat
    private let contentInsets: EdgeInsets
    private let content: (Data.Element) -> ItemContent

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    public init(
        _ data: Data,
        minItemWidth: CGFloat = 160,
        spacing: CGFloat = 12,
        contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16),
        @ViewBuilder content: @escaping (Data.Element) -> ItemContent
    ) {
        self.data = data
        self.minItemWidth = minItemWidth
        self.spacing = spacing
        self.contentInsets = contentInsets
        self.content = content
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: minItemWidth), spacing: spacing)]
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(data) { item in
                    content(item)
                }
            }
            .padding(currentInsets)
        }
    }

    private var currentInsets: EdgeInsets {
        #if os(iOS)
        if sizeClass == .regular {
            return EdgeInsets(
                top: contentInsets.top,
                leading: contentInsets.leading + 8,
                bottom: contentInsets.bottom,
                trailing: contentInsets.trailing + 8
            )
        }
        return contentInsets
        #else
        return contentInsets
        #endif
    }
}

/// Adaptive grid with fixed column counts per size class.
@available(iOS 14, *)
public struct GridColumnsAdaptive<Data, ItemContent: View>: View where Data: RandomAccessCollection, Data.Element: Identifiable {
    private let data: Data
    private let compactColumns: Int
    private let regularColumns: Int
    private let spacing: CGFloat
    private let contentInsets: EdgeInsets
    private let embedInScrollView: Bool
    private let minimumCellWidth: CGFloat
    private let content: (Data.Element) -> ItemContent

    @State private var containerWidth: CGFloat = 0

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    public init(
        _ data: Data,
        compactColumns: Int = 2,
        regularColumns: Int = 4,
        spacing: CGFloat = 12,
        contentInsets: EdgeInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16),
        embedInScrollView: Bool = true,
        minimumCellWidth: CGFloat = 140,
        @ViewBuilder content: @escaping (Data.Element) -> ItemContent
    ) {
        self.data = data
        self.compactColumns = compactColumns
        self.regularColumns = regularColumns
        self.spacing = spacing
        self.contentInsets = contentInsets
        self.embedInScrollView = embedInScrollView
        self.minimumCellWidth = minimumCellWidth
        self.content = content
    }

    private var resolvedColumnCount: Int {
        #if os(iOS)
        if containerWidth > 0 {
            let availableWidth = max(
                0,
                containerWidth - contentInsets.leading - contentInsets.trailing
            )
            let regularThreshold = minimumCellWidth * CGFloat(regularColumns)
                + spacing * CGFloat(max(regularColumns - 1, 0))

            if availableWidth >= regularThreshold {
                return regularColumns
            }
            return compactColumns
        }

        return sizeClass == .regular ? regularColumns : compactColumns
        #else
        return regularColumns
        #endif
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: resolvedColumnCount)
    }

    private var layoutIdentity: String {
        "\(resolvedColumnCount)-\(Int(containerWidth.rounded()))"
    }

    public var body: some View {
        if embedInScrollView {
            ScrollView {
                gridContent
            }
        } else {
            gridContent
        }
    }

    private var gridContent: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(data) { item in
                content(item)
            }
        }
        .padding(contentInsets)
        .background {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: GridContainerWidthKey.self, value: geometry.size.width)
            }
        }
        .onPreferenceChange(GridContainerWidthKey.self) { containerWidth = $0 }
        .id(layoutIdentity)
    }
}

private struct GridContainerWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
