// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "fltrWallet-lib",
    platforms: [ .iOS(.v14), ],
    products: [
        .library(
            name: "fltrWallet-lib",
            targets: ["fltrWallet-lib"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", branch: "main"),
        .package(url: "https://github.com/fltrWallet/fltrBtc", branch: "main"),
        .package(url: "https://github.com/fltrWallet/fltrUI", branch: "main"),
    ],
    targets: [
        .target(
            name: "fltrWallet-lib",
            dependencies: [ "fltrBtc",
                            "fltrUI",
                            .product(name: "NIO",
                                     package: "swift-nio"),
                            .product(name: "NIOTransportServices",
                                     package: "swift-nio-transport-services"), ],
            path: "Sources/fltrWallet",
            resources: [ .process("Resources"), ]),
    ]
)
