// swift-tools-version: 6.0
import PackageDescription

// Local host validation reuses the exact production renderer sources.
// This executable is not an application product or a distribution package.
let package = Package(
    name: "BeautyEditorValidation",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../BeautySDK")],
    targets: [
        .executableTarget(name: "BeautyEditorPixelCheck",
            dependencies: [.product(name: "BeautySDK", package: "BeautySDK")],
            path: ".",
            exclude: ["Tests", "UITests", "Sources/Assets.xcassets", "Sources/Info.plist",
                      "Sources/BeautyEditorApp.swift", "Sources/BeautyEditorChrome.swift",
                      "Sources/BeautySlider.swift", "Sources/EditorScreen.swift",
                      "Sources/EditorModel.swift", "Sources/PhotoLibraryWriter.swift",
                      "BeautyEditor.xcodeproj", "project.yml", "scripts", "README.md", "AGENTS.md", "VALIDATION.md",
                      "design-assets.json"],
            sources: ["Sources/PhotoRenderer.swift", "Sources/EditorState.swift",
                      "Sources/ToolCatalog.swift", "Validation/PixelCheck.swift"])
    ]
)
