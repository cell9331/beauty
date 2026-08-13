# Technology Stack

**Analysis Date:** 2026-08-13

## Languages

**Primary:**
- Swift 6 language/toolchain - SDK, renderer, Demo, and tests under `BeautySDK/Sources/`, `BeautySDK/Tests/`, `BeautyDemo/BeautyDemo/`, and `BeautyDemo/BeautyDemoTests/`. The package declares Swift tools 6.0 in `BeautySDK/Package.swift`; the inspected host provides Apple Swift 6.3.3.
- Metal Shading Language - Bundled warp shader source at `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`.

**Secondary:**
- JSON - Bundled resource manifest and presets in `BeautySDK/Sources/BeautyResources/Resources/manifest.json` and `BeautySDK/Sources/BeautyResources/Resources/Presets/*.json`; Xcode asset metadata in `BeautyDemo/BeautyDemo/Assets.xcassets/**/Contents.json`.
- JavaScript/HTML/CSS - Offline, local-only review and reference utilities under `.planning/phases/54-rights-approved-evidence-and-eligibility-decisions/` and the static reference pages in `meituxiuxiu/html/`.
- Python and shell - Deterministic planning/security gates under `.planning/phases/` and the no-skip test wrapper at `scripts/run-no-skip-swiftpm.sh`.
- Markdown - Current repository contracts in `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and `PLANS.md`.

## Runtime

**Environment:**
- iOS 17+ library support and macOS 14+ renderer/test support are declared in `BeautySDK/Package.swift`.
- `BeautyDemo` is an iOS/iPadOS application target; the checked-in Xcode project currently sets `IPHONEOS_DEPLOYMENT_TARGET = 26.5` in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- The inspected development host provides Xcode 26.6 (build 17F113) and Apple Swift 6.3.3; these are observed tools, while the durable package contract remains `// swift-tools-version: 6.0` in `BeautySDK/Package.swift`.

**Package Manager:**
- Swift Package Manager, driven by `BeautySDK/Package.swift`.
- Lockfile: missing by design; `BeautySDK/Package.swift` declares no remote package dependencies, so no `Package.resolved` is required.
- The Demo consumes the local package through `XCLocalSwiftPackageReference "../BeautySDK"` in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.

## Frameworks

**Core:**
- SwiftUI - App shell, editor, home, panel, and camera preview UI under `BeautyDemo/BeautyDemo/`.
- Foundation and Combine - Models, serialization, state observation, and app pipelines in `BeautySDK/Sources/` and `BeautyDemo/BeautyDemo/`.
- Core Image/Core Graphics/ImageIO - Still-image canonicalization, color rendering, metadata/orientation handling, and output encoding in `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`, and `BeautySDK/Sources/BeautyExampleRenderer/main.swift`.
- Core Video/Core Media - Pixel-buffer frame transport and camera handling in `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift`, `BeautySDK/Sources/BeautyRender/PixelBufferFactory.swift`, and `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift`.
- Vision - On-device face landmark detection in `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` using `VNDetectFaceLandmarksRequest`.
- AVFoundation - Camera permission, capture session, video output, and preview layer in `BeautyDemo/BeautyDemo/Camera/`.
- PhotosUI/UIKit - Local photo selection and UIKit bridging in `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` and `BeautyDemo/BeautyDemo/Editor/ParameterJSONSheetView.swift`.
- AppKit - macOS-only example renderer input/output support in `BeautySDK/Sources/BeautyExampleRenderer/main.swift`.

**Testing:**
- XCTest - Six SwiftPM test targets declared in `BeautySDK/Package.swift`, with suites under `BeautySDK/Tests/BeautyCoreTests/`, `BeautySDK/Tests/BeautyDetectionTests/`, `BeautySDK/Tests/BeautyEffectsTests/`, `BeautySDK/Tests/BeautyRenderTests/`, `BeautySDK/Tests/BeautyResourcesTests/`, and `BeautySDK/Tests/BeautySDKTests/`.
- XCTest/Xcode test target - Demo integration and state tests under `BeautyDemo/BeautyDemoTests/`, configured by `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- CryptoKit - Test-only SHA-256 validation of bundled resources in `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift`.

**Build/Dev:**
- Swift Package Manager builds the `BeautySDK` library and `BeautyExampleRenderer` executable defined in `BeautySDK/Package.swift`.
- Xcode builds `BeautyDemo` and `BeautyDemoTests` from `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` and links the local `BeautySDK` product.
- SwiftPM processes resource bundles from `BeautySDK/Sources/BeautyResources/Resources/` and `BeautySDK/Sources/BeautyRender/Shaders/`.
- `scripts/run-no-skip-swiftpm.sh` is the repository’s strict wrapper for executing the SwiftPM suite with documented opt-in Vision fixtures enabled on a suitable host.

## Key Dependencies

**Critical:**
- `BeautyCore` - Shared public value types, canonical still-image carrier, errors, parameters, presets, and diagnostics in `BeautySDK/Sources/BeautyCore/`.
- `BeautyDetection` - Vision detection, landmark mapping, face selection, and request-local observed support in `BeautySDK/Sources/BeautyDetection/`.
- `BeautyRender` - Pixel-buffer abstractions, render graph, copy pass, and bundled Metal resource in `BeautySDK/Sources/BeautyRender/`.
- `BeautyResources` - Validated bundled manifest/preset catalog in `BeautySDK/Sources/BeautyResources/`.
- `BeautyEffects` - Effect planning, geometry/color pipelines, warps, local-retouch providers, and composition in `BeautySDK/Sources/BeautyEffects/`.
- `BeautySDK` - Public facade that re-exports `BeautyCore` and coordinates the internal modules in `BeautySDK/Sources/BeautySDK/BeautySDK.swift` and `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.

**Infrastructure:**
- Apple platform frameworks only; `BeautySDK/Package.swift` has an empty external `dependencies` collection and declares no third-party products.
- Bundled presets and manifest are compiled as SwiftPM resources from `BeautySDK/Sources/BeautyResources/Resources/`; load them through `BeautyResourceCatalog` in `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift` rather than direct filesystem paths.
- The shipped geometry implementation is currently Core Image-backed in `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`; `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` is packaged infrastructure, not proof that the still-image facade executes a production Metal warp pass.

## Configuration

**Environment:**
- No `.env`, `.env.*`, or `*.env` files are present in the inspected repository. Runtime API keys and service credentials are not part of the current stack.
- Private native-Vision fixture suites are opt-in through test-process environment configuration documented and consumed by tests such as `BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift`; local fixture media remains outside committed source.
- Do not add network credentials or external model configuration without reopening the dependency, privacy, licensing, and security contracts in `SECURITY.md`.

**Build:**
- `BeautySDK/Package.swift` owns package platforms, products, targets, dependencies, and resource processing.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` owns Demo/test build settings, local package linkage, automatic signing, bundle identifiers, and generated Info.plist keys.
- Demo bundle identifiers are `com.yakang.BeautyDemo` and `com.yakang.BeautyDemoTests` in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- Demo marketing/build versions are `1.0` / `1` and targeted device family is iPhone+iPad (`1,2`) in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- The generated Demo Info.plist contains camera and photo-library purpose strings through `INFOPLIST_KEY_NSCameraUsageDescription` and `INFOPLIST_KEY_NSPhotoLibraryUsageDescription` in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.

## Platform Requirements

**Development:**
- Use a Swift 6-capable Xcode toolchain for `BeautySDK/Package.swift`; current package minimums are iOS 17 and macOS 14.
- Run package tests with `swift test --package-path BeautySDK`; use `scripts/run-no-skip-swiftpm.sh` only on a host with the authorized local Vision fixtures configured.
- Inspect schemes with `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj`; build the Demo using an explicit compatible iOS Simulator destination as required by `AGENTS.md`.
- Keep package code portable across the declared iOS/macOS platforms; app-only frameworks such as SwiftUI, PhotosUI, UIKit, and AVFoundation belong under `BeautyDemo/BeautyDemo/`.

**Production:**
- `BeautySDK` is an automatic SwiftPM library product in `BeautySDK/Package.swift`; the repository also contains the `BeautyDemo` application and macOS `BeautyExampleRenderer` evidence executable.
- The current repository is local-first and dependency-free at the package level. Distribution, packaging, shipping, launch, and release readiness are explicitly outside the archived v1.15 evidence in `PLANS.md`.
- Reassess `PrivacyInfo.xcprivacy`, required-reason APIs, third-party licenses, and binary/resource distribution before turning the source package into a distributed SDK, as required by `SECURITY.md`.

---

*Stack analysis: 2026-08-13*
