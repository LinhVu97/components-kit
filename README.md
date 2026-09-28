# FidraComponents

A SwiftUI component library providing reusable UI components for iOS applications.

## Components

### TextView

A text component that automatically localizes text content using Localize-Swift.

#### Features
- Automatic text localization
- Simple and clean API
- SwiftUI native implementation

#### Usage

```swift
import SwiftUI
import FidraComponents

struct ContentView: View {
    var body: some View {
        VStack {
            // Basic usage with localized text
            TextView("Hello World")
            
            // Using with dynamic content
            TextView("Welcome \(userName)")
        }
    }
}
```

#### API Reference

```swift
TextView(_ text: String)
```

**Parameters:**
- `text`: The text string to display (will be automatically localized)

**Note:** Make sure you have Localize-Swift properly configured in your project for localization to work.

---

### ImageView

A production-ready image pipeline built on Kingfisher with automatic downsampling, memory/disk caching, and prefetching.

#### Architecture

```
Sources/FidraComponents/ImageView/
├── ImageConfig.swift      # Cache config + DownsamplingImageProcessor
├── ImageLoader.swift      # Singleton, builds KFImage with optimized options
├── ImageView.swift        # SwiftUI View (GeometryReader + downsampling)
└── ImagePrefetcher.swift  # Batch prefetch utility
```

#### Features
- **Downsampling**: Loads images at display size, not original size
- **Dual caching**: Memory (~150MB) + Disk (~700MB, 7-day expiration)
- **Cancel on disappear**: Prevents wasted bandwidth in scrollable lists
- **Background decode**: Decodes off main thread
- **Retry**: Automatic retry (max 2 times)
- **Fade transition**: 0.15s smooth fade-in
- **Backward compatible**: Legacy `init(url: String)` still works

#### Setup

Call once at app launch (e.g. in `App.init` or `AppDelegate`):

```swift
import FidraComponents

// Default: memory 150MB, disk 700MB, expiration 7 days
ImageConfig.setup()

// Custom values
ImageConfig.setup(memoryLimitMB: 200, diskLimitMB: 500, diskExpirationDays: 14)
```

#### Usage

**Basic (optimized with downsampling):**

```swift
ImageView(url: URL(string: "https://cdn.com/photo.jpg"))
    .frame(width: 120, height: 120)
```

**With content mode and corner radius:**

```swift
ImageView(
    url: URL(string: "https://cdn.com/photo.jpg"),
    contentMode: .fit,
    cornerRadius: 12
)
.frame(width: 200, height: 200)
```

**In a List:**

```swift
List(items) { item in
    HStack {
        ImageView(url: item.imageURL)
            .frame(width: 80, height: 80)
        Text(item.title)
    }
}
```

**In a LazyVStack (infinite scroll):**

```swift
ScrollView {
    LazyVStack(spacing: 12) {
        ForEach(items) { item in
            ImageView(url: item.imageURL, cornerRadius: 8)
                .frame(height: 200)
        }
    }
    .padding(.horizontal)
}
```

**In a LazyVGrid (photo grid):**

```swift
let columns = [
    GridItem(.flexible(), spacing: 4),
    GridItem(.flexible(), spacing: 4),
    GridItem(.flexible(), spacing: 4)
]

ScrollView {
    LazyVGrid(columns: columns, spacing: 4) {
        ForEach(items) { item in
            ImageView(url: item.imageURL)
                .frame(height: 120)
        }
    }
}
```

**Prefetch (preload images trước khi hiển thị):**

Nên dùng khi:
- **API trả về danh sách**: Ngay sau khi nhận response, prefetch trước khi user scroll tới
- **Tab/Page sắp hiển thị**: Preload ảnh của tab tiếp theo khi user đang ở tab hiện tại
- **Onboarding/Carousel**: Prefetch toàn bộ ảnh khi vào màn hình
- **Detail screen**: Prefetch ảnh detail khi user đang ở list screen

```swift
// Sau khi fetch API xong, prefetch ngay
func fetchItems() async {
    let items = try await api.getItems()
    self.items = items
    ImagePrefetcher.prefetch(items.compactMap { $0.imageURL })
}

// Prefetch ảnh page tiếp theo trong PageView
func onPageChange(currentPage: Int) {
    let nextItems = allItems[safe: currentPage + 1] ?? []
    ImagePrefetcher.prefetch(nextItems.compactMap { $0.imageURL })
}
```

> **Lưu ý:** Không cần prefetch nếu dùng `ImageView` trong `LazyVStack`/`LazyVGrid` - Kingfisher đã tự load khi cell xuất hiện và cancel khi cell biến mất.

**Legacy usage (backward compatible):**

```swift
ImageView(url: "https://cdn.com/photo.jpg")
ImageView(
    url: "https://cdn.com/photo.jpg",
    placeholderImage: { AnyView(ProgressView()) },
    cacheMemoryOnly: true
)
```

#### API Reference

**ImageView (new):**
```swift
ImageView(url: URL?, contentMode: ContentMode = .fill, cornerRadius: CGFloat = 0)
```

**ImageView (legacy):**
```swift
ImageView(url: String, placeholderImage: (() -> AnyView)? = nil, cacheMemoryOnly: Bool = false)
```

**ImagePrefetcher:**
```swift
ImagePrefetcher.prefetch(_ urls: [URL])
```

**ImageConfig:**
```swift
ImageConfig.setup(memoryLimitMB: Int = 150, diskLimitMB: Int = 700, diskExpirationDays: Int = 7)
ImageConfig.processor(size: CGSize) -> ImageProcessor
```

**ImageLoader:**
```swift
ImageLoader.shared.buildImage(url: URL, size: CGSize, contentMode: ContentMode) -> KFImage
```

> **Note:** Do not use `KFImage` directly in UI code. Always use `ImageView` or `ImageLoader`.

---

### IOS26 — Liquid Glass

Bộ component hỗ trợ [Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass) (iOS 26 / WWDC 2026). Ưu tiên dùng API hệ thống (`.buttonStyle(.glass)`) thay vì custom glass khi có thể.

#### Architecture

```
Sources/FidraComponents/IOS26/
├── Core/
│   ├── GlassStyle.swift
│   ├── GlassShape.swift
│   ├── GlassModifier.swift
│   ├── View+Glass.swift           # .glassStyle(), .glassButtonStyle(), .glassInteractiveButtonStyle()
│   └── View+ScrollEdge.swift      # .scrollEdgeEffectStyleIfAvailable()
├── System/
│   ├── GlassButton.swift
│   ├── GlassToolbar.swift         # visibilityPriority, overflow menu (iOS 27+)
│   └── GlassTabBar.swift          # tabBarMinimizeBehavior, bottom accessory
└── Custom/
    ├── GlassBadge.swift
    ├── GlassCard.swift
    └── GlassContainer.swift
```

#### Phạm vi hiện tại

| Đã có | Ghi chú |
|-------|---------|
| `.glassStyle()`, `.glassButtonStyle()`, `.glassInteractiveButtonStyle()` | Fallback iOS 14+ |
| `GlassButton` (incl. `init(_:tint:isEnabled:)`) | Interactive CTA |
| `GlassBadge`, `GlassCard`, `GlassContainer` | |
| `.scrollEdgeEffectStyleIfAvailable()` | iOS 26+ |
| `.glassTabBarMinimizeBehaviorIfAvailable()` | iOS 26+ |
| `.glassToolbarPriority()`, `GlassToolbarOverflow` | iOS 27+ |
| Toast opt-in glass | |
| Chưa có | SwipeActions / Reorderable wrappers |

#### Yêu cầu

- Build với **Xcode 26+** và **iOS 26 SDK** để có Liquid Glass thật
- Package vẫn support **iOS 14+** — tự fallback `.regularMaterial` / `.bordered` trên OS cũ

#### Usage

**Modifier — áp glass lên bất kỳ View:**

```swift
import FidraComponents

Text("Hello")
    .padding()
    .glassStyle(.regular, shape: .capsule)

Text("Prominent")
    .padding()
    .glassStyle(.tintedInteractive(.blue), shape: .rect(cornerRadius: 16))
```

**GlassButton — interactive CTA với brand tint:**

```swift
GlassButton("Continue", tint: .orange) { submit() }

Button("Continue") { submit() }
    .font(.headline)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 6)
    .glassInteractiveButtonStyle(tint: .orange)
```

**GlassButton — system styles:**

```swift
GlassButton("Save", role: .prominent) { save() }

GlassButton(role: .regular) { share() } label: {
    Label("Share", systemImage: "square.and.arrow.up")
}
```

**Custom components:**

```swift
GlassBadge("3 visits", icon: "star.fill", style: .interactive)

GlassCard(style: .regular, cornerRadius: 16) {
    VStack {
        Text("Title").font(.headline)
        Text("Subtitle").font(.subheadline)
    }
}

// Nhóm nhiều glass elements (perf + morphing trên iOS 26)
GlassContainer(spacing: 20) {
    HStack(spacing: 12) {
        GlassBadge("A")
        GlassBadge("B")
    }
}
```

**Toast với Liquid Glass:**

```swift
ToastManager.shared.configure(ToastConfig(
    useGlassEffect: true,
    glassStyle: .regular
))

ContentView()
    .toastView()
```

**Scroll edge effect (iOS 26+):**

```swift
ScrollView { content }
    .scrollEdgeEffectStyleIfAvailable(.soft, for: .all)
```

**GlassTabBar — minimize on scroll (iOS 26+):**

```swift
TabView {
    Tab("Home", systemImage: "house") { HomeView() }
    Tab(value: TabItem.camera, role: .prominent) {
        Color.clear
    } label: {
        Label("Camera", systemImage: "camera.fill")
    }
}
.glassTabBarMinimizeBehaviorIfAvailable(.onScrollDown)
.glassTabBarBottomAccessoryIfAvailable { NowPlayingBar() }
```

**GlassToolbar — overflow & priority (iOS 27+):**

```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        Button("Settings") { }
    }
    .glassToolbarPriority(.high)

    GlassToolbarOverflow {
        Button("Archive") { }
        Button("Delete", role: .destructive) { }
    }
}
.glassToolbarBackgroundHiddenIfAvailable()
```

**Morphing (iOS 26+, SwiftUI API trực tiếp trong GlassContainer):**

```swift
@Namespace private var namespace

GlassContainer(spacing: 40) {
    if isExpanded {
        Image(systemName: "eraser.fill")
            .glassStyle()
            .glassEffectID("eraser", in: namespace)
    }
}
```

#### GlassButtonRole

| Case | iOS 26+ API | Khi nào dùng |
|------|-------------|--------------|
| `.regular` | `.glass` | Button thường |
| `.prominent` | `.glassProminent` | CTA nổi bật |
| `.interactive` | `.glass(.regular.interactive())` | Surface tương tác |
| `.tintedInteractive(Color)` | `.glass(.regular.tint(_:).interactive())` | Tương tác có màu |
| `.clearTintedInteractive(Color)` | `.glass(.clear.tint(_:).interactive())` | CTA brand (pattern phổ biến) |

#### GlassStyle

| Case | iOS 26 API | Khi nào dùng |
|------|------------|--------------|
| `.regular` | `.regular` | Mặc định, overlay nhẹ |
| `.clear` | `.clear` | Trên ảnh/nền đậm |
| `.tinted(Color)` | `.regular.tint(_:)` | Nhấn mạnh màu brand |
| `.interactive` | `.regular.interactive()` | Surface user chạm trực tiếp |
| `.tintedInteractive(Color)` | `.regular.tint(_:).interactive()` | CTA tương tác có màu |
| `.disabled` | opacity 0.5 | Trạng thái disabled |

#### GlassShape

| Case | Mô tả |
|------|-------|
| `.capsule` | Pill / chip (mặc định Apple) |
| `.circle` | Icon tròn |
| `.rect(cornerRadius:)` | Card, toast, panel lớn |

#### Fallback tự động

| iOS | Glass effect | Button style |
|-----|--------------|--------------|
| 26+ | `glassEffect(_:in:)` | `.glass` / `.glassProminent` |
| 15–25 | `.regularMaterial` | `.bordered` / `.borderedProminent` |
| 14 | Semi-transparent fill | Default button |

#### Best practices (Apple HIG)

- Liquid Glass chỉ cho **functional layer** — không dùng làm background content
- Ưu tiên `GlassButton` / `.glassButtonStyle()` thay vì `.glassStyle()` trên Button custom
- Dùng `GlassContainer` khi có **2+** glass elements cạnh nhau
- `.interactive()` chỉ trên surface user chạm — không dùng trên list scroll
- Tránh `.clipped()` / `.mask()` trên ancestor — kill glass effect
- `Form` override glass — dùng `List` nếu cần glass trên row

#### API Reference

```swift
// Core
View.glassStyle(_ style: GlassStyle = .regular, shape: GlassShape = .capsule)
View.glassButtonStyle(_ role: GlassButtonRole = .regular)
View.glassInteractiveButtonStyle(tint: Color, isEnabled: Bool = true)
View.glassStyleUnion(id:namespace:)

// Scroll edge (iOS 26+)
View.scrollEdgeEffectStyleIfAvailable(_ style: GlassScrollEdgeStyle = .soft, for: Edge.Set = .all)
View.scrollEdgeEffectHiddenIfAvailable(for: Edge.Set = .all)

// Tab bar (iOS 26+)
View.glassTabBarMinimizeBehaviorIfAvailable(_ behavior: GlassTabBarMinimizeBehavior = .onScrollDown)
View.glassTabBarBottomAccessoryIfAvailable(content:)

// Toolbar (iOS 27+)
ToolbarContent.glassToolbarPriority(_ priority: GlassToolbarVisibilityPriority)
GlassToolbarOverflow { /* buttons */ }
View.glassToolbarBackgroundHiddenIfAvailable()

// Components
GlassButton(_ title: String, role: GlassButtonRole = .regular, action: () -> Void)
GlassButton(_ title: String, tint: Color, isEnabled: Bool = true, action: () -> Void)
GlassBadge(_ text: String, icon: String? = nil, style: GlassStyle = .regular, shape: GlassShape = .capsule)
GlassCard(style: GlassStyle = .regular, cornerRadius: CGFloat = 16, padding: CGFloat = 16, content: () -> View)
GlassContainer(spacing: CGFloat = 40, content: () -> View)

ToastConfig(useGlassEffect: Bool = false, glassStyle: GlassStyle = .regular)
```

---

## Installation

Add FidraComponents to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "path/to/FidraComponents", from: "1.0.0")
]
```

## Requirements

- iOS 14.0+ (package minimum)
- iOS 26.0+ SDK + Xcode 26+ for full Liquid Glass (`IOS26` module)
- Swift 5.0+
- Xcode 12.0+ (26+ recommended)

## License

[Add your license information here]
