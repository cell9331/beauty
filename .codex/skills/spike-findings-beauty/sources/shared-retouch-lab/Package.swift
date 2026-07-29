// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RetouchSpikeLab",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "retouch-spike-lab", targets: ["RetouchSpikeLab"])
    ],
    targets: [
        .executableTarget(name: "RetouchSpikeLab")
    ]
)
