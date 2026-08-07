// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BeautySDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "BeautySDK", targets: ["BeautySDK"]),
        .executable(name: "BeautyExampleRenderer", targets: ["BeautyExampleRenderer"])
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
        .executableTarget(
            name: "BeautyExampleRenderer",
            dependencies: ["BeautySDK"]
        ),
        .testTarget(name: "BeautySDKTests", dependencies: ["BeautySDK"]),
        .testTarget(name: "BeautyCoreTests", dependencies: ["BeautyCore", "BeautySDK"]),
        .testTarget(name: "BeautyDetectionTests", dependencies: ["BeautyCore", "BeautyDetection"]),
        .testTarget(
            name: "BeautyEffectsTests",
            dependencies: ["BeautyCore", "BeautyDetection", "BeautyRender", "BeautyResources", "BeautyEffects"]
        ),
        .testTarget(name: "BeautyRenderTests", dependencies: ["BeautyCore", "BeautyRender", "BeautySDK"]),
        .testTarget(name: "BeautyResourcesTests", dependencies: ["BeautyCore", "BeautyResources"])
    ]
)
