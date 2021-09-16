// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MJStream",
    platforms: [.macOS(.v10_10), .iOS(.v10)],
    products: [
        .library(name: "MJStream", targets: ["MJStream"]),
    ],
    targets: [
        .target(name: "MJStream", path: "Sources"),
        .testTarget(name: "MJStreamTests", dependencies: ["MJStream"]),
    ]
)
