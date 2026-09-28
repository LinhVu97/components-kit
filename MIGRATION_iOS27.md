# Migration Guide: iOS 27 - iPad Resize & iPhone Mirroring

## Bối cảnh

Từ iOS 27 / iPadOS 26+:
- **iPad apps** được resize tự do qua hệ thống windowing mới
- **iPhone-only apps trên iPad** cũng resizable như iPad app
- **iPhone Mirroring trên Mac** cho phép resize cửa sổ tự do
- `UIRequiresFullScreen` bị deprecated
- Scene-based lifecycle bắt buộc

## Checklist cho từng ứng dụng

### 1. [BẮT BUỘC] Adopt Scene-based Lifecycle

```swift
// ❌ Cũ: AppDelegate lifecycle
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}

// ✅ Mới: Scene lifecycle (UIKit)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
}

// ✅ Hoặc SwiftUI App
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. [BẮT BUỘC] Xóa UIRequiresFullScreen

- Xóa `UIRequiresFullScreen` khỏi `Info.plist`
- Nếu cần backward compat:

```xml
<key>UIRequiresFullScreenIgnoredStartingWithVersion</key>
<integer>26</integer>
```

### 3. [BẮT BUỘC] Loại bỏ UIScreen.main

```swift
// ❌ Không dùng
let scale = UIScreen.main.scale
let bounds = UIScreen.main.bounds

// ✅ UIKit: dùng từ windowScene
let scale = view.traitCollection.displayScale
let bounds = view.window?.windowScene?.effectiveGeometry.coordinateSpace.bounds

// ✅ SwiftUI: dùng Environment
@Environment(\.displayScale) var displayScale
```

> **FidraComponents đã fix:** `ImageLoader` và `ImageView` đã chuyển sang dùng `@Environment(\.displayScale)`

### 4. [BẮT BUỘC] Không dùng userInterfaceIdiom cho layout

```swift
// ❌ Không dùng cho layout decisions
if UIDevice.current.userInterfaceIdiom == .phone {
    // compact layout
}

// ✅ Dùng size classes
@Environment(\.horizontalSizeClass) var sizeClass

if sizeClass == .compact {
    // compact layout
}

// ✅ Hoặc dùng FidraComponents
SizeClassReader { context in
    if context.isCompact {
        CompactView()
    } else {
        RegularView()
    }
}
```

### 5. [BẮT BUỘC] Thay thế Interface Orientation checks

```swift
// ❌ Orientation bị ignore trong resizable environment
// iPhone Mirroring luôn báo Portrait
if orientation == .landscape { ... }

// ✅ Dùng size classes
@Environment(\.horizontalSizeClass) var horizontal
@Environment(\.verticalSizeClass) var vertical

// horizontal == .regular → wide layout
// vertical == .compact → landscape-like
```

### 6. [BẮT BUỘC] Đảm bảo Launch Screen

iOS 27 yêu cầu launch screen cho App Store submission. Đảm bảo có `LaunchScreen.storyboard` hoặc launch screen config trong Info.plist.

### 7. [KHUYẾN NGHỊ] Cấu hình windowResizability

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .windowSize(.default) // FidraComponents helper
        }
        .windowResizability(.contentMinSize) // iOS 17+
    }
}
```

### 8. [KHUYẾN NGHỊ] Xử lý Interactive Resize

```swift
// Defer expensive work khi đang resize
ContentView()
    .trackInteractiveResize { isResizing in
        // pause heavy rendering during resize
    }
```

## FidraComponents Adaptive Utilities

### StackAdaptive
Auto-switch HStack/VStack theo size class:

```swift
StackAdaptive(spacing: 16) {
    CardView()
    DetailView()
}
// → VStack trên compact, HStack trên regular
```

### SizeClassReader
Đọc layout context:

```swift
SizeClassReader { context in
    if context.isRegularAll {
        SidebarLayout()
    } else {
        TabLayout()
    }
}
```

### ResponsivePadding

```swift
Text("Hello")
    .responsivePadding(.horizontal, compact: 16, regular: 32)
```

### ListAdaptive
List tự giới hạn content width trên regular size (tránh dòng quá rộng trên iPad):

```swift
ListAdaptive(maxContentWidth: 700) {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
```

### GridAdaptive
Grid tự điều chỉnh số cột theo available width (dùng `adaptive` columns):

```swift
GridAdaptive(items, minItemWidth: 160, spacing: 12) { item in
    CardView(item: item)
}
```

### GridColumnsAdaptive
Grid với số cột cố định theo size class:

```swift
GridColumnsAdaptive(items, compactColumns: 2, regularColumns: 4) { item in
    CardView(item: item)
}
// → 2 cột trên compact, 4 cột trên regular
```

### GlassCard (cập nhật)

```swift
GlassCard(
    padding: 12,
    regularPadding: 20,   // padding lớn hơn trên regular size
    maxWidth: 600          // giới hạn chiều rộng trên iPad
) {
    ContentView()
}
```

## Danh sách kiểm tra trước khi submit

- [ ] App dùng Scene-based lifecycle
- [ ] Không có `UIRequiresFullScreen` (hoặc có `IgnoredStartingWithVersion`)
- [ ] Không có `UIScreen.main` references
- [ ] Không dùng `userInterfaceIdiom` cho layout
- [ ] Không dùng `interfaceOrientation` cho layout
- [ ] Có launch screen
- [ ] Test trên iPad với nhiều window size (minimum 375x486)
- [ ] Test iPhone Mirroring trên Mac
- [ ] Test Split View và Slide Over
- [ ] Toast/overlay hiển thị đúng ở mọi kích thước
