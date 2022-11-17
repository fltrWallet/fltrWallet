// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "fltrWallet",
    platforms: [ .iOS(.v14), ],
    products: [
        .library(
            name: "fltrWallet",
            targets: ["fltrWallet"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", branch: "main"),
        .package(url: "https://github.com/fltrWallet/fltrBtc", branch: "main"),
        .package(url: "https://github.com/fltrWallet/fltrUI", branch: "main"),
    ],
    targets: [
        .target(
            name: "fltrWallet",
            dependencies: [ "fltrBtc",
                            "fltrUI",
                            .product(name: "NIO",
                                     package: "swift-nio"),
                            .product(name: "NIOTransportServices",
                                     package: "swift-nio-transport-services"), ],
            resources: [ .process("Resources"), ]),
    ]
)
