// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CyphlensSSE",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CyphlensSSE",
            targets: ["CyphlensSSE"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "CyphlensSSE",
            path: "Frameworks/CyphlensSSE.xcframework"
        ),
    ]
)
