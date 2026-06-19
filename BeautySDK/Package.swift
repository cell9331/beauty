// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BeautySDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "BeautySDK", targets: ["BeautySDK"])
    ],
    targets: [
        .target(name: "BeautyCore"),
        .target(name: "BeautyDetection", dependencies: ["BeautyCore"]),
        .target(
            name: "BeautyRender",
            dependencies: ["BeautyCore"],
            resources: [.process("Shaders")]
        ),
        .target(
            name: "BeautyResources",
            dependencies: ["BeautyCore"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "BeautyEffects",
            dependencies: ["BeautyCore", "BeautyDetection", "BeautyRender", "BeautyResources"]
        ),
        .target(
            name: "BeautySDK",
            dependencies: ["BeautyCore", "BeautyDetection", "BeautyRender", "BeautyEffects", "BeautyResources"]
        ),
        .testTarget(name: "BeautySDKTests", dependencies: ["BeautySDK"]),
        .testTarget(name: "BeautyCoreTests", dependencies: ["BeautyCore", "BeautySDK"]),
        .testTarget(name: "BeautyDetectionTests", dependencies: ["BeautyCore", "BeautyDetection"]),
        .testTarget(name: "BeautyRenderTests", dependencies: ["BeautyCore", "BeautyRender"]),
        .testTarget(name: "BeautyResourcesTests", dependencies: ["BeautyCore", "BeautyResources"])
    ]
)
