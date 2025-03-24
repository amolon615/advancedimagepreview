// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdvancedImagePreview",
    platforms: [
        .iOS(.v17)
       ],
    products: [
        .library(
            name: "AdvancedImagePreview",
            targets: ["AdvancedImagePreview"]),
    ],
    targets: [
        .target(
            name: "AdvancedImagePreview"),
    ]
)
