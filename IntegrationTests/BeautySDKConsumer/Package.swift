// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BeautySDKConsumer",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../../BeautySDK")
    ],
    targets: [
        .executableTarget(
            name: "BeautySDKConsumer",
            dependencies: [
                .product(name: "BeautySDK", package: "BeautySDK")
            ]
        )
    ]
)
