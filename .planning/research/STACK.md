# Stack Research

**Domain:** Modular iOS beauty SDK with rich SwiftUI Demo app
**Researched:** 2026-06-10
**Confidence:** HIGH for Apple-platform stack; MEDIUM for feature breadth prioritization

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Swift | Apple Swift 6.3.2 observed locally | SDK and Demo implementation language | Native Apple-platform language, supports value models, Sendable contracts, Swift Package targets, and testable public APIs. |
| Xcode | 26.5 observed locally | Project build, simulator builds, package integration | Current repo already uses an Xcode 26.5 iOS app project with object version 77 and generated Info.plist settings. |
| Swift Package Manager | Xcode/Swift toolchain version | `BeautySDK` package and internal targets | Matches the existing root architecture contract and keeps SDK modules reusable outside the Demo app. |
| SwiftUI | iOS SDK 26.5 observed locally | Demo app UI | Current app shell already uses SwiftUI; root frontend contract expects SwiftUI state and a rich parameter UI. |
| Observation / Observable state | iOS 17+ style, available in current platform family | Demo state stores | Fits SwiftUI parameter stores and avoids overcoupling SDK internals to UI state. |
| AVFoundation | iOS SDK framework | Camera capture and frame delivery | Standard Apple API for camera sessions and `AVCaptureVideoDataOutput` sample buffers. |
| Vision | iOS SDK framework | Face detection, landmarks, future person segmentation | Apple-supported local face-landmark and segmentation path; aligns with privacy and no-network constraints. |
| Metal | iOS SDK framework | Real-time render pipeline and geometry/color passes | Required for efficient camera-frame processing, texture reuse, and custom warp/filter effects. |
| Core Image | iOS SDK framework | Still-image filters, color adjustments, LUT prototyping | Useful for still-image processing and some color/filter paths before all effects are custom Metal. |
| XCTest | Xcode toolchain | Unit, package, and future UI tests | Needed to move beyond documentation-only quality evidence. |

### Supporting Frameworks

| Framework | Version | Purpose | When to Use |
|-----------|---------|---------|-------------|
| CoreVideo | iOS SDK 26.5 observed | `CVPixelBuffer`, texture cache input/output | Realtime frame and no-op processing foundation. |
| CoreMedia | iOS SDK 26.5 observed | Sample timing and frame metadata | Camera pipelines, timestamp propagation, frame dropping metrics. |
| CoreGraphics | iOS SDK 26.5 observed | Geometry, image orientation, public lightweight types | Public value models and orientation/extent contracts. |
| OSLog | iOS SDK 26.5 observed | Diagnostics and privacy-aware logging | SDK and Demo logging with redaction rules. |
| Metal Performance Shaders | iOS SDK 26.5 observed | Optimized blur/sharpen/image kernels | Use when a standard GPU operation exists and is faster than custom shaders. |
| Accelerate | iOS SDK 26.5 observed | CPU-side numeric/image operations | Only for offline or setup operations where GPU is unnecessary. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `xcodebuild -list` | Discover schemes and targets | Current repo lists only `BeautyDemo`; use before build/test commands. |
| Explicit iOS Simulator destination | Reliable build evidence | Avoid generic destination choosing incompatible `My Mac`. |
| Swift Package tests | Validate SDK modules | Add with `BeautySDK/Tests/**` as soon as the package exists. |
| Xcode GPU tools / Instruments | Performance profiling | Needed once Metal render passes and camera preview exist. |
| `rg` and `git diff --check` | Documentation/code hygiene | Already part of repo workflow. |

## Installation

No external package installation is recommended for the foundation.

Recommended initial package work:

```bash
mkdir -p BeautySDK/Sources BeautySDK/Tests
swift package init --type library --name BeautySDK
```

Then reshape the package into the target layout required by `ARCHITECTURE.md`:

```text
BeautyCore
BeautyDetection
BeautyRender
BeautyEffects
BeautyResources
BeautySDK
```

The Demo app should add the local package through the Xcode project and import only:

```swift
import BeautySDK
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Swift Package internal targets | Multiple separate packages | Only if modules need independent versioning/distribution later. |
| Vision landmarks | Custom ML face landmark model | Only after Vision precision, performance, or landmark coverage proves insufficient. |
| Metal render graph | Core Image-only pipeline | Acceptable for early still-image color/filter prototype, not enough for full realtime geometry effects. |
| Local Swift/Metal implementation | Third-party beauty SDK | Only if the product pivots from building a SDK to wrapping a vendor SDK. |
| SwiftUI Demo | UIKit Demo | UIKit may be useful for `MTKView`/camera preview wrappers, but app composition should stay SwiftUI unless measurement shows a real issue. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Realtime `UIImage` conversion | Extra copies and main-thread pressure in camera preview | Pass `CVPixelBuffer` / textures through the pipeline. |
| Demo imports of internal SDK targets | Makes Demo unlike a real host app and breaks facade verification | `import BeautySDK` only. |
| Network processing by default | Violates local-first privacy posture for faces/photos | On-device Vision, Metal, Core Image, and local resources. |
| Full feature build before no-op foundation | Hides integration, testing, and performance problems | Foundation -> no-op flow -> detection -> render graph -> effects. |
| Unversioned LUT/makeup/sticker files | Resource drift and unsafe loading | Versioned manifests with validation in `BeautyResources`. |

## Stack Patterns by Variant

**If the phase is SDK foundation:**
- Use Swift Package targets with no UI framework dependencies in core targets.
- Because this preserves SDK reuse and makes facade tests meaningful.

**If the phase is realtime camera:**
- Use AVFoundation sample buffers, CoreVideo pixel buffers, Metal texture caches, and bounded in-flight processing.
- Because latency and frame dropping are more important than processing every captured frame.

**If the phase is still-image editing:**
- Use image orientation normalization and a quality processing mode.
- Because still images can spend more time preserving quality than live preview.

**If the phase is resource-backed effects:**
- Use `BeautyResources` manifests for presets, LUTs, makeup packs, and stickers.
- Because resources are product data and must be versioned, validated, and diagnosable.

## Version Compatibility

| Package or Framework | Compatible With | Notes |
|----------------------|-----------------|-------|
| `BeautyDemo` Xcode project | Xcode 26.5 observed locally | Older Xcode versions may not handle object version 77 cleanly. |
| `BeautySDK` Swift package | Current Swift/Xcode toolchain | Start with source package; binary distribution can come later. |
| SwiftUI/Observation | iOS 17+ design style | Deployment target is currently 26.5, so modern state APIs are acceptable unless compatibility goals change. |
| Vision/Metal/Core Image | iOS SDK 26.5 observed locally | Use availability checks only if future requirements lower deployment target. |

## Sources

- Apple Developer Documentation, `AVCaptureVideoDataOutput`: https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutput
- Apple Technical Note TN2445, Handling Frame Drops with `AVCaptureVideoDataOutput`: https://developer.apple.com/library/archive/technotes/tn2445/_index.html
- Apple Developer Documentation, `VNDetectFaceLandmarksRequest`: https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest
- Apple Developer Documentation, Metal: https://developer.apple.com/documentation/metal
- Apple Developer Documentation, `CIColorCube`: https://developer.apple.com/documentation/coreimage/cicolorcube
- Apple Developer Documentation, PackageDescription / Swift Package Manager: https://developer.apple.com/documentation/PackageDescription
- Apple Developer Documentation, Observation: https://developer.apple.com/documentation/observation
- Apple Developer Documentation, privacy manifests for apps and third-party SDKs: https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk
- Local files: `.planning/PROJECT.md`, `.planning/codebase/STACK.md`, `.planning/codebase/ARCHITECTURE.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `docs/01_product_feature_plan.md`.

---
*Stack research for: modular iOS beauty SDK*
*Researched: 2026-06-10*
