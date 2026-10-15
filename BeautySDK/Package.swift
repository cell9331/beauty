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
        // Pinned official iOS binaries. Only the three vision runtime assets
        // are needed; importing the upstream Common product also links its
        // unrelated audio/text/retrieval tasks.
        .binaryTarget(
            name: "MediaPipeTasksCommonBinary",
            url: "https://dl.google.com/cpdc/20261005-190020/MediaPipeTasksCommon-1.1.0.xcframework.zip",
            checksum: "d2194b929b91f0c866b2f8d65003e08c474f6c85e8ca7293511e9ff4a780aa68"
        ),
        .binaryTarget(
            name: "MediaPipeTaskGraphsBinary",
            url: "https://dl.google.com/cpdc/20261005-190020/MediaPipeTaskGraphs-1.1.0.xcframework.zip",
            checksum: "6e59def0a86dcf8b357d6dc4220c8f45a3704449e7c7734677f2db50671c7def"
        ),
        .binaryTarget(
            name: "MediaPipeTasksVision",
            url: "https://dl.google.com/cpdc/20261005-190020/MediaPipeTasksVision-1.1.0.xcframework.zip",
            checksum: "d66d9929a28febdd52aba49b3336e1550e4526ab0b772c49321db05af5c7614e"
        ),
        .target(
            name: "BeautyDetection",
            dependencies: [
                "BeautyCore",
                .target(name: "MediaPipeTasksCommonBinary", condition: .when(platforms: [.iOS])),
                .target(name: "MediaPipeTaskGraphsBinary", condition: .when(platforms: [.iOS])),
                .target(name: "MediaPipeTasksVision", condition: .when(platforms: [.iOS]))
            ],
            resources: [.copy("Resources/face_landmarker.task")],
            linkerSettings: [
                // Required by MediaPipe's C++ calculator registration.
                .unsafeFlags(["-Xlinker", "-all_load", "-ObjC"], .when(platforms: [.iOS])),
                .linkedLibrary("c++", .when(platforms: [.iOS])),
                .linkedLibrary("sqlite3", .when(platforms: [.iOS])),
                .linkedFramework("Accelerate", .when(platforms: [.iOS])),
                .linkedFramework("AVFoundation", .when(platforms: [.iOS])),
                .linkedFramework("AudioToolbox", .when(platforms: [.iOS])),
                .linkedFramework("CoreMedia", .when(platforms: [.iOS])),
                .linkedFramework("CoreGraphics", .when(platforms: [.iOS])),
                .linkedFramework("CoreImage", .when(platforms: [.iOS])),
                .linkedFramework("CoreVideo", .when(platforms: [.iOS])),
                .linkedFramework("QuartzCore", .when(platforms: [.iOS]))
            ]
        ),
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
