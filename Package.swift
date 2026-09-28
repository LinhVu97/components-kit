// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FidraComponents",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FidraComponents",
            targets: ["FidraComponents"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.5.0")),
        .package(url: "https://github.com/marmelroy/Localize-Swift.git", .upToNextMajor(from: "3.2.0"))
    ],
    targets: [
        .target(
            name: "FidraComponents",
            dependencies: [
                .product(name: "Localize_Swift", package: "Localize-Swift"),
                .product(name: "Kingfisher", package: "Kingfisher")
            ]),
    ]
)
