# SDK Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a compilable `BeautySDK` Swift Package foundation with core public models, typed errors, a minimal engine, render primitives, and Demo-facing facade wiring.

**Architecture:** Add one root Swift Package with internal targets for core, detection, render, effects, resources, and a single facade product named `BeautySDK`. First implementation returns no-effect output and proves dependency boundaries before real beauty algorithms are added.

**Tech Stack:** Swift Package Manager, Swift 5.9, XCTest, CoreGraphics, CoreVideo, ImageIO, Metal, SwiftUI Demo app, Xcode project local Swift package reference.

---

## Source Spec

Implement from:

- `docs/superpowers/specs/2026-05-25-sdk-foundation-design.md`
- `ARCHITECTURE.md`
- `DESIGN.md`
- `FRONTEND.md`
- `SECURITY.md`
- `RELIABILITY.md`
- `PRODUCT_SENSE.md`
- `QUALITY_SCORE.md`
- `docs/02_development_stages_full_plan.md`
- `docs/03_architecture_spm_skeleton.md`
- `docs/05_public_api_design.md`
- `docs/08_metal_render_pipeline_design.md`

## File Structure

Create:

```text
BeautySDK/
├── Package.swift
├── Sources/
│   ├── BeautyCore/
│   │   ├── Diagnostics/
│   │   │   ├── BeautyErrorContext.swift
│   │   │   ├── BeautyLogEvent.swift
│   │   │   ├── BeautyLogger.swift
│   │   │   └── BeautyLogSink.swift
│   │   ├── Engine/
│   │   │   └── BeautyEngine.swift
│   │   └── Models/
│   │       ├── BeautyConfiguration.swift
│   │       ├── BeautyError.swift
│   │       ├── BeautyLogLevel.swift
│   │       ├── BeautyParameters.swift
│   │       ├── BeautyPreset.swift
│   │       └── BeautyRenderQuality.swift
│   ├── BeautyDetection/
│   │   ├── BeautyFaceLandmarks.swift
│   │   ├── BeautyFaceObservation.swift
│   │   ├── CoordinateMapper.swift
│   │   └── FaceDetecting.swift
│   ├── BeautyEffects/
│   │   └── BeautyEffect.swift
│   ├── BeautyRender/
│   │   ├── CopyRenderPass.swift
│   │   ├── MetalContext.swift
│   │   ├── PixelBufferPool.swift
│   │   ├── RenderGraph.swift
│   │   ├── RenderPass.swift
│   │   ├── Shaders/
│   │   │   └── Warp.metal
│   │   └── TextureCache.swift
│   ├── BeautyResources/
│   │   ├── PresetLoader.swift
│   │   ├── ResourceBundleLocator.swift
│   │   └── Resources/
│   │       └── manifest.json
│   └── BeautySDK/
│       └── BeautySDK.swift
└── Tests/
    ├── BeautyCoreTests/
    │   ├── BeautyConfigurationTests.swift
    │   ├── BeautyEngineTests.swift
    │   ├── BeautyLoggerTests.swift
    │   └── BeautyParametersTests.swift
    ├── BeautyDetectionTests/
    │   └── BeautyDetectionShellTests.swift
    ├── BeautyEffectsTests/
    │   └── BeautyEffectTests.swift
    ├── BeautyRenderTests/
    │   ├── MetalContextTests.swift
    │   └── RenderGraphTests.swift
    ├── BeautyResourcesTests/
    │   └── PresetLoaderTests.swift
    └── BeautySDKTests/
        └── BeautySDKFacadeTests.swift
```

Modify:

```text
BeautyDemo/BeautyDemo/ContentView.swift
BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj
PLANS.md
QUALITY_SCORE.md
```

`BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` is changed only after package tests pass. If the local machine still has CommandLineTools selected instead of full Xcode, record the `xcodebuild` failure in `PLANS.md` and keep the Swift Package work as the verified checkpoint.

2026-06-10 environment recheck: full Xcode is selected at `/Applications/Xcode.app/Contents/Developer`; `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` succeeds; the current Demo shell builds with `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build`. Keep the CommandLineTools note below as historical context, but use fresh command output for new verification records.

---

### Task 1: Swift Package Skeleton

**Files:**
- Create: `BeautySDK/Package.swift`
- Create: `BeautySDK/Sources/BeautyCore/Models/BeautyLogLevel.swift`
- Create: `BeautySDK/Sources/BeautySDK/BeautySDK.swift`
- Test: `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift`

- [ ] **Step 1: Write facade import test**

Create `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift`:

```swift
import XCTest
import BeautySDK

final class BeautySDKFacadeTests: XCTestCase {
    func testFacadeExposesCoreTypes() {
        XCTAssertEqual(BeautySDKVersion.current, "0.1.0-foundation")
        XCTAssertEqual(BeautyLogLevel.error.rawValue, "error")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
swift test --package-path BeautySDK --filter BeautySDKFacadeTests/testFacadeExposesCoreTypes
```

Expected: FAIL because `BeautySDK/Package.swift` does not exist yet.

- [ ] **Step 3: Create Package.swift**

Create `BeautySDK/Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BeautySDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BeautySDK",
            targets: ["BeautySDK"]
        )
    ],
    targets: [
        .target(
            name: "BeautySDK",
            dependencies: [
                "BeautyCore",
                "BeautyDetection",
                "BeautyRender",
                "BeautyEffects",
                "BeautyResources"
            ]
        ),
        .target(
            name: "BeautyCore",
            dependencies: []
        ),
        .target(
            name: "BeautyDetection",
            dependencies: ["BeautyCore"]
        ),
        .target(
            name: "BeautyRender",
            dependencies: ["BeautyCore"],
            resources: [
                .process("Shaders")
            ]
        ),
        .target(
            name: "BeautyEffects",
            dependencies: [
                "BeautyCore",
                "BeautyDetection",
                "BeautyRender"
            ]
        ),
        .target(
            name: "BeautyResources",
            dependencies: ["BeautyCore"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "BeautyCoreTests",
            dependencies: ["BeautyCore"]
        ),
        .testTarget(
            name: "BeautyDetectionTests",
            dependencies: ["BeautyDetection"]
        ),
        .testTarget(
            name: "BeautyRenderTests",
            dependencies: ["BeautyRender"]
        ),
        .testTarget(
            name: "BeautyEffectsTests",
            dependencies: ["BeautyEffects"]
        ),
        .testTarget(
            name: "BeautyResourcesTests",
            dependencies: ["BeautyResources"]
        ),
        .testTarget(
            name: "BeautySDKTests",
            dependencies: ["BeautySDK"]
        )
    ]
)
```

- [ ] **Step 4: Add first core type**

Create `BeautySDK/Sources/BeautyCore/Models/BeautyLogLevel.swift`:

```swift
public enum BeautyLogLevel: String, Codable, CaseIterable, Sendable {
    case none
    case error
    case warning
    case info
    case debug
}
```

- [ ] **Step 5: Add facade target**

Create `BeautySDK/Sources/BeautySDK/BeautySDK.swift`:

```swift
@_exported import BeautyCore

public enum BeautySDKVersion {
    public static let current = "0.1.0-foundation"
}
```

- [ ] **Step 6: Run facade test**

Run:

```bash
swift test --package-path BeautySDK --filter BeautySDKFacadeTests/testFacadeExposesCoreTypes
```

Expected: PASS.

- [ ] **Step 7: Commit package skeleton**

```bash
git add BeautySDK/Package.swift BeautySDK/Sources/BeautyCore/Models/BeautyLogLevel.swift BeautySDK/Sources/BeautySDK/BeautySDK.swift BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift
git commit -m "feat: add BeautySDK package skeleton"
```

---

### Task 2: Core Models And Parameter Contracts

**Files:**
- Create: `BeautySDK/Sources/BeautyCore/Models/BeautyRenderQuality.swift`
- Create: `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift`
- Create: `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift`
- Create: `BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift`
- Create: `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`
- Test: `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift`
- Test: `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift`

- [ ] **Step 1: Write configuration tests**

Create `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift`:

```swift
import XCTest
import BeautyCore

final class BeautyConfigurationTests: XCTestCase {
    func testDefaultConfigurationUsesSafeValues() {
        let configuration = BeautyConfiguration.default

        XCTAssertNil(configuration.preferredProcessingSize)
        XCTAssertEqual(configuration.maximumFaceCount, 1)
        XCTAssertTrue(configuration.enableFaceTracking)
        XCTAssertEqual(configuration.detectionFrameInterval, 3)
        XCTAssertEqual(configuration.renderQuality, .balanced)
        XCTAssertFalse(configuration.enablePerformanceLog)
        XCTAssertFalse(configuration.enableDebugMode)
        XCTAssertEqual(configuration.logLevel, .error)
    }

    func testConfigurationIsSendable() {
        func acceptSendable<T: Sendable>(_ value: T) {}
        acceptSendable(BeautyConfiguration.default)
    }
}
```

- [ ] **Step 2: Write parameter tests**

Create `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift`:

```swift
import XCTest
import BeautyCore

final class BeautyParametersTests: XCTestCase {
    func testDefaultParametersAreNoEffect() {
        let parameters = BeautyParameters()

        XCTAssertEqual(parameters.skinSmoothing, 0)
        XCTAssertEqual(parameters.skinWhitening, 0)
        XCTAssertEqual(parameters.skinRosy, 0)
        XCTAssertEqual(parameters.skinSharpen, 0)
        XCTAssertEqual(parameters.brightness, 0)
        XCTAssertEqual(parameters.contrast, 0)
        XCTAssertEqual(parameters.saturation, 0)
        XCTAssertEqual(parameters.temperature, 0)
        XCTAssertEqual(parameters.tint, 0)
        XCTAssertEqual(parameters.exposure, 0)
        XCTAssertEqual(parameters.highlight, 0)
        XCTAssertEqual(parameters.shadow, 0)
        XCTAssertEqual(parameters.faceSlim, 0)
        XCTAssertEqual(parameters.faceSmall, 0)
        XCTAssertEqual(parameters.faceVShape, 0)
        XCTAssertEqual(parameters.jawSlim, 0)
        XCTAssertEqual(parameters.chinLength, 0)
        XCTAssertEqual(parameters.eyeSize, 0)
        XCTAssertEqual(parameters.eyeDistance, 0)
        XCTAssertEqual(parameters.eyeYPosition, 0)
        XCTAssertEqual(parameters.eyeTailLift, 0)
        XCTAssertEqual(parameters.noseSlim, 0)
        XCTAssertEqual(parameters.noseWingSlim, 0)
        XCTAssertEqual(parameters.noseTipSize, 0)
        XCTAssertEqual(parameters.noseBridge, 0)
        XCTAssertEqual(parameters.mouthSize, 0)
        XCTAssertEqual(parameters.mouthWidth, 0)
        XCTAssertEqual(parameters.smile, 0)
        XCTAssertEqual(parameters.lipColor, 0)
        XCTAssertNil(parameters.filterId)
        XCTAssertEqual(parameters.filterIntensity, 0)
    }

    func testParameterInitClampsInvalidValues() {
        let parameters = BeautyParameters(
            skinSmoothing: 2,
            brightness: -3,
            eyeDistance: .infinity,
            filterIntensity: .nan
        )

        XCTAssertEqual(parameters.skinSmoothing, 1)
        XCTAssertEqual(parameters.brightness, -1)
        XCTAssertEqual(parameters.eyeDistance, 0)
        XCTAssertEqual(parameters.filterIntensity, 0)
    }

    func testParameterMutationClampsInvalidValues() {
        var parameters = BeautyParameters()

        parameters.skinSmoothing = -4
        parameters.contrast = 4
        parameters.smile = .infinity
        parameters.filterIntensity = 8

        XCTAssertEqual(parameters.skinSmoothing, 0)
        XCTAssertEqual(parameters.contrast, 1)
        XCTAssertEqual(parameters.smile, 0)
        XCTAssertEqual(parameters.filterIntensity, 1)
    }

    func testCodableRoundTripPreservesValues() throws {
        let original = BeautyParameters(
            skinSmoothing: 0.25,
            brightness: -0.5,
            eyeSize: 0.4,
            filterId: "natural_clear",
            filterIntensity: 0.7
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(BeautyParameters.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func testParametersAreSendable() {
        func acceptSendable<T: Sendable>(_ value: T) {}
        acceptSendable(BeautyParameters())
    }
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run:

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests
```

Expected: FAIL because core model types are not defined.

- [ ] **Step 4: Add render quality**

Create `BeautySDK/Sources/BeautyCore/Models/BeautyRenderQuality.swift`:

```swift
public enum BeautyRenderQuality: String, Codable, CaseIterable, Sendable {
    case performance
    case balanced
    case quality
}
```

- [ ] **Step 5: Add configuration**

Create `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift`:

```swift
import CoreGraphics

public struct BeautyConfiguration: Equatable, Sendable {
    public let preferredProcessingSize: CGSize?
    public let maximumFaceCount: Int
    public let enableFaceTracking: Bool
    public let detectionFrameInterval: Int
    public let renderQuality: BeautyRenderQuality
    public let enablePerformanceLog: Bool
    public let enableDebugMode: Bool
    public let logLevel: BeautyLogLevel

    public init(
        preferredProcessingSize: CGSize? = nil,
        maximumFaceCount: Int = 1,
        enableFaceTracking: Bool = true,
        detectionFrameInterval: Int = 3,
        renderQuality: BeautyRenderQuality = .balanced,
        enablePerformanceLog: Bool = false,
        enableDebugMode: Bool = false,
        logLevel: BeautyLogLevel = .error
    ) {
        self.preferredProcessingSize = preferredProcessingSize
        self.maximumFaceCount = max(1, maximumFaceCount)
        self.enableFaceTracking = enableFaceTracking
        self.detectionFrameInterval = max(1, detectionFrameInterval)
        self.renderQuality = renderQuality
        self.enablePerformanceLog = enablePerformanceLog
        self.enableDebugMode = enableDebugMode
        self.logLevel = logLevel
    }

    public static let `default` = BeautyConfiguration()
}
```

- [ ] **Step 6: Add error and preset models**

Create `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift`:

```swift
public enum BeautyError: Error, Equatable, Sendable {
    case metalUnavailable
    case commandQueueCreationFailed
    case textureCreationFailed
    case pixelBufferCreationFailed
    case shaderFunctionNotFound(String)
    case invalidInput
    case unsupportedPixelFormat
    case resourceNotFound(String)
    case presetDecodeFailed(String)
    case lutDecodeFailed(String)
    case renderFailed(String)
    case detectionFailed(String)
}
```

Create `BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift`:

```swift
public struct BeautyPreset: Codable, Equatable, Sendable {
    public let id: String
    public let version: Int
    public let displayName: String
    public let parameters: BeautyParameters

    public init(
        id: String,
        version: Int,
        displayName: String,
        parameters: BeautyParameters
    ) {
        self.id = id
        self.version = version
        self.displayName = displayName
        self.parameters = parameters
    }
}
```

- [ ] **Step 7: Add BeautyParameters**

Create `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`:

```swift
public struct BeautyParameters: Codable, Equatable, Sendable {
    public var skinSmoothing: Float { didSet { skinSmoothing = Self.clampEnhancement(skinSmoothing) } }
    public var skinWhitening: Float { didSet { skinWhitening = Self.clampEnhancement(skinWhitening) } }
    public var skinRosy: Float { didSet { skinRosy = Self.clampEnhancement(skinRosy) } }
    public var skinSharpen: Float { didSet { skinSharpen = Self.clampEnhancement(skinSharpen) } }

    public var brightness: Float { didSet { brightness = Self.clampBidirectional(brightness) } }
    public var contrast: Float { didSet { contrast = Self.clampBidirectional(contrast) } }
    public var saturation: Float { didSet { saturation = Self.clampBidirectional(saturation) } }
    public var temperature: Float { didSet { temperature = Self.clampBidirectional(temperature) } }
    public var tint: Float { didSet { tint = Self.clampBidirectional(tint) } }
    public var exposure: Float { didSet { exposure = Self.clampBidirectional(exposure) } }
    public var highlight: Float { didSet { highlight = Self.clampBidirectional(highlight) } }
    public var shadow: Float { didSet { shadow = Self.clampBidirectional(shadow) } }

    public var faceSlim: Float { didSet { faceSlim = Self.clampEnhancement(faceSlim) } }
    public var faceSmall: Float { didSet { faceSmall = Self.clampEnhancement(faceSmall) } }
    public var faceVShape: Float { didSet { faceVShape = Self.clampEnhancement(faceVShape) } }
    public var jawSlim: Float { didSet { jawSlim = Self.clampEnhancement(jawSlim) } }
    public var chinLength: Float { didSet { chinLength = Self.clampBidirectional(chinLength) } }

    public var eyeSize: Float { didSet { eyeSize = Self.clampBidirectional(eyeSize) } }
    public var eyeDistance: Float { didSet { eyeDistance = Self.clampBidirectional(eyeDistance) } }
    public var eyeYPosition: Float { didSet { eyeYPosition = Self.clampBidirectional(eyeYPosition) } }
    public var eyeTailLift: Float { didSet { eyeTailLift = Self.clampBidirectional(eyeTailLift) } }

    public var noseSlim: Float { didSet { noseSlim = Self.clampEnhancement(noseSlim) } }
    public var noseWingSlim: Float { didSet { noseWingSlim = Self.clampEnhancement(noseWingSlim) } }
    public var noseTipSize: Float { didSet { noseTipSize = Self.clampBidirectional(noseTipSize) } }
    public var noseBridge: Float { didSet { noseBridge = Self.clampBidirectional(noseBridge) } }

    public var mouthSize: Float { didSet { mouthSize = Self.clampBidirectional(mouthSize) } }
    public var mouthWidth: Float { didSet { mouthWidth = Self.clampBidirectional(mouthWidth) } }
    public var smile: Float { didSet { smile = Self.clampEnhancement(smile) } }
    public var lipColor: Float { didSet { lipColor = Self.clampEnhancement(lipColor) } }

    public var filterId: String?
    public var filterIntensity: Float { didSet { filterIntensity = Self.clampEnhancement(filterIntensity) } }

    public init(
        skinSmoothing: Float = 0,
        skinWhitening: Float = 0,
        skinRosy: Float = 0,
        skinSharpen: Float = 0,
        brightness: Float = 0,
        contrast: Float = 0,
        saturation: Float = 0,
        temperature: Float = 0,
        tint: Float = 0,
        exposure: Float = 0,
        highlight: Float = 0,
        shadow: Float = 0,
        faceSlim: Float = 0,
        faceSmall: Float = 0,
        faceVShape: Float = 0,
        jawSlim: Float = 0,
        chinLength: Float = 0,
        eyeSize: Float = 0,
        eyeDistance: Float = 0,
        eyeYPosition: Float = 0,
        eyeTailLift: Float = 0,
        noseSlim: Float = 0,
        noseWingSlim: Float = 0,
        noseTipSize: Float = 0,
        noseBridge: Float = 0,
        mouthSize: Float = 0,
        mouthWidth: Float = 0,
        smile: Float = 0,
        lipColor: Float = 0,
        filterId: String? = nil,
        filterIntensity: Float = 0
    ) {
        self.skinSmoothing = Self.clampEnhancement(skinSmoothing)
        self.skinWhitening = Self.clampEnhancement(skinWhitening)
        self.skinRosy = Self.clampEnhancement(skinRosy)
        self.skinSharpen = Self.clampEnhancement(skinSharpen)
        self.brightness = Self.clampBidirectional(brightness)
        self.contrast = Self.clampBidirectional(contrast)
        self.saturation = Self.clampBidirectional(saturation)
        self.temperature = Self.clampBidirectional(temperature)
        self.tint = Self.clampBidirectional(tint)
        self.exposure = Self.clampBidirectional(exposure)
        self.highlight = Self.clampBidirectional(highlight)
        self.shadow = Self.clampBidirectional(shadow)
        self.faceSlim = Self.clampEnhancement(faceSlim)
        self.faceSmall = Self.clampEnhancement(faceSmall)
        self.faceVShape = Self.clampEnhancement(faceVShape)
        self.jawSlim = Self.clampEnhancement(jawSlim)
        self.chinLength = Self.clampBidirectional(chinLength)
        self.eyeSize = Self.clampBidirectional(eyeSize)
        self.eyeDistance = Self.clampBidirectional(eyeDistance)
        self.eyeYPosition = Self.clampBidirectional(eyeYPosition)
        self.eyeTailLift = Self.clampBidirectional(eyeTailLift)
        self.noseSlim = Self.clampEnhancement(noseSlim)
        self.noseWingSlim = Self.clampEnhancement(noseWingSlim)
        self.noseTipSize = Self.clampBidirectional(noseTipSize)
        self.noseBridge = Self.clampBidirectional(noseBridge)
        self.mouthSize = Self.clampBidirectional(mouthSize)
        self.mouthWidth = Self.clampBidirectional(mouthWidth)
        self.smile = Self.clampEnhancement(smile)
        self.lipColor = Self.clampEnhancement(lipColor)
        self.filterId = filterId
        self.filterIntensity = Self.clampEnhancement(filterIntensity)
    }

    private static func clampEnhancement(_ value: Float) -> Float {
        guard value.isFinite else { return 0 }
        return min(max(value, 0), 1)
    }

    private static func clampBidirectional(_ value: Float) -> Float {
        guard value.isFinite else { return 0 }
        return min(max(value, -1), 1)
    }
}
```

- [ ] **Step 8: Run core model tests**

Run:

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests
```

Expected: PASS.

- [ ] **Step 9: Commit core models**

```bash
git add BeautySDK/Sources/BeautyCore/Models BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift
git commit -m "feat: add core beauty model contracts"
```

---

### Task 3: Diagnostics Foundation

**Files:**
- Create: `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyErrorContext.swift`
- Create: `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyLogEvent.swift`
- Create: `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyLogSink.swift`
- Create: `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyLogger.swift`
- Test: `BeautySDK/Tests/BeautyCoreTests/BeautyLoggerTests.swift`

- [ ] **Step 1: Write logger tests**

Create `BeautySDK/Tests/BeautyCoreTests/BeautyLoggerTests.swift`:

```swift
import XCTest
import BeautyCore

final class BeautyLoggerTests: XCTestCase {
    func testNoneLevelDropsEvents() {
        let sink = MemoryLogSink()
        let logger = BeautyLogger(level: .none, sink: sink)

        logger.log(level: .error, category: "engine", message: "init_failed")

        XCTAssertTrue(sink.events.isEmpty)
    }

    func testErrorLevelKeepsErrorEventsAndDropsInfo() {
        let sink = MemoryLogSink()
        let logger = BeautyLogger(level: .error, sink: sink)

        logger.log(level: .info, category: "engine", message: "started")
        logger.log(level: .error, category: "render", message: "failed")

        XCTAssertEqual(sink.events.map(\.message), ["failed"])
    }
}

private final class MemoryLogSink: BeautyLogSink {
    private(set) var events: [BeautyLogEvent] = []

    func write(_ event: BeautyLogEvent) {
        events.append(event)
    }
}
```

- [ ] **Step 2: Run logger tests to verify they fail**

Run:

```bash
swift test --package-path BeautySDK --filter BeautyLoggerTests
```

Expected: FAIL because diagnostics types are not defined.

- [ ] **Step 3: Add diagnostics types**

Create `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyErrorContext.swift`:

```swift
public struct BeautyErrorContext: Equatable, Sendable {
    public let code: String
    public let reason: String
    public let metadata: [String: String]

    public init(code: String, reason: String, metadata: [String: String] = [:]) {
        self.code = code
        self.reason = reason
        self.metadata = metadata
    }
}
```

Create `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyLogEvent.swift`:

```swift
import Foundation

public struct BeautyLogEvent: Equatable, Sendable {
    public let timestamp: Date
    public let level: BeautyLogLevel
    public let category: String
    public let message: String
    public let metadata: [String: String]

    public init(
        timestamp: Date = Date(),
        level: BeautyLogLevel,
        category: String,
        message: String,
        metadata: [String: String] = [:]
    ) {
        self.timestamp = timestamp
        self.level = level
        self.category = category
        self.message = message
        self.metadata = metadata
    }
}
```

Create `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyLogSink.swift`:

```swift
public protocol BeautyLogSink: AnyObject, Sendable {
    func write(_ event: BeautyLogEvent)
}
```

Create `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyLogger.swift`:

```swift
public final class BeautyLogger: @unchecked Sendable {
    private let level: BeautyLogLevel
    private let sink: BeautyLogSink?

    public init(level: BeautyLogLevel, sink: BeautyLogSink? = nil) {
        self.level = level
        self.sink = sink
    }

    public func log(
        level eventLevel: BeautyLogLevel,
        category: String,
        message: String,
        metadata: [String: String] = [:]
    ) {
        guard shouldEmit(eventLevel) else { return }
        sink?.write(
            BeautyLogEvent(
                level: eventLevel,
                category: category,
                message: message,
                metadata: metadata
            )
        )
    }

    private func shouldEmit(_ eventLevel: BeautyLogLevel) -> Bool {
        guard level != .none else { return false }
        return priority(eventLevel) <= priority(level)
    }

    private func priority(_ level: BeautyLogLevel) -> Int {
        switch level {
        case .none:
            return 0
        case .error:
            return 1
        case .warning:
            return 2
        case .info:
            return 3
        case .debug:
            return 4
        }
    }
}
```

- [ ] **Step 4: Run logger tests**

Run:

```bash
swift test --package-path BeautySDK --filter BeautyLoggerTests
```

Expected: PASS.

- [ ] **Step 5: Commit diagnostics**

```bash
git add BeautySDK/Sources/BeautyCore/Diagnostics BeautySDK/Tests/BeautyCoreTests/BeautyLoggerTests.swift
git commit -m "feat: add local diagnostics foundation"
```

---

### Task 4: BeautyEngine No-Effect Processing

**Files:**
- Create: `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`
- Test: `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`

- [ ] **Step 1: Write engine tests**

Create `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`:

```swift
import CoreVideo
import ImageIO
import XCTest
import BeautyCore

final class BeautyEngineTests: XCTestCase {
    func testInitAndResetAreSafe() throws {
        let engine = try BeautyEngine(configuration: .default)

        engine.reset()
        engine.reset()

        XCTAssertEqual(engine.configuration, .default)
    }

    func testProcessReturnsSamePixelBufferForNoEffectFoundation() throws {
        let engine = try BeautyEngine(configuration: .default)
        let pixelBuffer = try makePixelBuffer(pixelFormat: kCVPixelFormatType_32BGRA)

        let output = try engine.process(
            pixelBuffer: pixelBuffer,
            orientation: .up,
            parameters: BeautyParameters()
        )

        XCTAssertTrue(output === pixelBuffer)
    }

    func testUnsupportedPixelFormatThrowsTypedError() throws {
        let engine = try BeautyEngine(configuration: .default)
        let pixelBuffer = try makePixelBuffer(pixelFormat: kCVPixelFormatType_OneComponent8)

        XCTAssertThrowsError(
            try engine.process(pixelBuffer: pixelBuffer, orientation: .up, parameters: BeautyParameters())
        ) { error in
            XCTAssertEqual(error as? BeautyError, .unsupportedPixelFormat)
        }
    }

    private func makePixelBuffer(pixelFormat: OSType) throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            4,
            4,
            pixelFormat,
            nil,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }

        return pixelBuffer
    }
}
```

- [ ] **Step 2: Run engine tests to verify they fail**

Run:

```bash
swift test --package-path BeautySDK --filter BeautyEngineTests
```

Expected: FAIL because `BeautyEngine` is not defined.

- [ ] **Step 3: Implement engine**

Create `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`:

```swift
import CoreVideo
import Foundation
import ImageIO

public final class BeautyEngine: @unchecked Sendable {
    public let configuration: BeautyConfiguration

    private let lock = NSLock()
    private var processedFrameCount: Int64 = 0

    public init(configuration: BeautyConfiguration = .default) throws {
        self.configuration = configuration
    }

    public func process(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        parameters: BeautyParameters
    ) throws -> CVPixelBuffer {
        try Self.validate(pixelBuffer: pixelBuffer)

        lock.lock()
        processedFrameCount += 1
        lock.unlock()

        return pixelBuffer
    }

    public func reset() {
        lock.lock()
        processedFrameCount = 0
        lock.unlock()
    }

    private static func validate(pixelBuffer: CVPixelBuffer) throws {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        guard width > 0, height > 0 else {
            throw BeautyError.invalidInput
        }

        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        guard pixelFormat == kCVPixelFormatType_32BGRA else {
            throw BeautyError.unsupportedPixelFormat
        }
    }
}
```

- [ ] **Step 4: Run engine tests**

Run:

```bash
swift test --package-path BeautySDK --filter BeautyEngineTests
```

Expected: PASS.

- [ ] **Step 5: Commit engine**

```bash
git add BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift
git commit -m "feat: add no-effect beauty engine"
```

---

### Task 5: RenderGraph And RenderPass Primitives

**Files:**
- Create: `BeautySDK/Sources/BeautyRender/RenderPass.swift`
- Create: `BeautySDK/Sources/BeautyRender/RenderGraph.swift`
- Test: `BeautySDK/Tests/BeautyRenderTests/RenderGraphTests.swift`

- [ ] **Step 1: Write RenderGraph tests**

Create `BeautySDK/Tests/BeautyRenderTests/RenderGraphTests.swift`:

```swift
import XCTest
import BeautyCore
import BeautyRender

final class RenderGraphTests: XCTestCase {
    func testRenderGraphRunsPassesInOrder() throws {
        let log = RenderLog()
        let graph = RenderGraph(passes: [
            RecordingPass(id: "first", log: log),
            RecordingPass(id: "second", log: log)
        ])

        _ = try graph.execute(RenderContext(parameters: BeautyParameters()))

        XCTAssertEqual(log.ids, ["first", "second"])
    }

    func testRenderGraphSkipsDisabledPasses() throws {
        let log = RenderLog()
        let graph = RenderGraph(passes: [
            RecordingPass(id: "first", log: log),
            DisabledPass(id: "disabled", log: log),
            RecordingPass(id: "second", log: log)
        ])

        _ = try graph.execute(RenderContext(parameters: BeautyParameters()))

        XCTAssertEqual(log.ids, ["first", "second"])
    }
}

private final class RenderLog {
    var ids: [String] = []
}

private struct RecordingPass: RenderPass {
    let id: String
    let log: RenderLog

    func shouldRun(context: RenderContext) -> Bool {
        true
    }

    func execute(context: RenderContext) throws -> RenderContext {
        log.ids.append(id)
        return context
    }
}

private struct DisabledPass: RenderPass {
    let id: String
    let log: RenderLog

    func shouldRun(context: RenderContext) -> Bool {
        false
    }

    func execute(context: RenderContext) throws -> RenderContext {
        log.ids.append(id)
        return context
    }
}
```

- [ ] **Step 2: Run render graph tests to verify they fail**

Run:

```bash
swift test --package-path BeautySDK --filter RenderGraphTests
```

Expected: FAIL because `RenderGraph`, `RenderPass`, and `RenderContext` are not defined.

- [ ] **Step 3: Add RenderPass**

Create `BeautySDK/Sources/BeautyRender/RenderPass.swift`:

```swift
import BeautyCore
import CoreVideo

public struct RenderContext {
    public let inputPixelBuffer: CVPixelBuffer?
    public let outputPixelBuffer: CVPixelBuffer?
    public let parameters: BeautyParameters

    public init(
        inputPixelBuffer: CVPixelBuffer? = nil,
        outputPixelBuffer: CVPixelBuffer? = nil,
        parameters: BeautyParameters
    ) {
        self.inputPixelBuffer = inputPixelBuffer
        self.outputPixelBuffer = outputPixelBuffer
        self.parameters = parameters
    }

    public func replacingOutput(_ pixelBuffer: CVPixelBuffer?) -> RenderContext {
        RenderContext(
            inputPixelBuffer: inputPixelBuffer,
            outputPixelBuffer: pixelBuffer,
            parameters: parameters
        )
    }
}

public protocol RenderPass {
    var id: String { get }
    func shouldRun(context: RenderContext) -> Bool
    func execute(context: RenderContext) throws -> RenderContext
}
```

- [ ] **Step 4: Add RenderGraph**

Create `BeautySDK/Sources/BeautyRender/RenderGraph.swift`:

```swift
public struct RenderGraph {
    private let passes: [RenderPass]

    public init(passes: [RenderPass]) {
        self.passes = passes
    }

    public func execute(_ context: RenderContext) throws -> RenderContext {
        var current = context

        for pass in passes where pass.shouldRun(context: current) {
            current = try pass.execute(context: current)
        }

        return current
    }
}
```

- [ ] **Step 5: Run render graph tests**

Run:

```bash
swift test --package-path BeautySDK --filter RenderGraphTests
```

Expected: PASS.

- [ ] **Step 6: Commit render graph primitives**

```bash
git add BeautySDK/Sources/BeautyRender/RenderPass.swift BeautySDK/Sources/BeautyRender/RenderGraph.swift BeautySDK/Tests/BeautyRenderTests/RenderGraphTests.swift
git commit -m "feat: add render graph primitives"
```

---

### Task 6: Metal Context, Texture Cache, Pixel Buffer Pool, And Copy Pass

**Files:**
- Create: `BeautySDK/Sources/BeautyRender/MetalContext.swift`
- Create: `BeautySDK/Sources/BeautyRender/TextureCache.swift`
- Create: `BeautySDK/Sources/BeautyRender/PixelBufferPool.swift`
- Create: `BeautySDK/Sources/BeautyRender/CopyRenderPass.swift`
- Create: `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`
- Test: `BeautySDK/Tests/BeautyRenderTests/MetalContextTests.swift`

- [ ] **Step 1: Write render resource tests**

Create `BeautySDK/Tests/BeautyRenderTests/MetalContextTests.swift`:

```swift
import CoreVideo
import Metal
import XCTest
import BeautyCore
import BeautyRender

final class MetalContextTests: XCTestCase {
    func testMetalContextEitherCreatesQueueOrThrowsTypedError() {
        do {
            let context = try MetalContext()
            XCTAssertNotNil(context.device)
            XCTAssertNotNil(context.commandQueue)
        } catch {
            XCTAssertEqual(error as? BeautyError, .metalUnavailable)
        }
    }

    func testPixelBufferPoolCreatesBGRABuffer() throws {
        let pool = try PixelBufferPool(width: 8, height: 8)
        let pixelBuffer = try pool.makePixelBuffer()

        XCTAssertEqual(CVPixelBufferGetWidth(pixelBuffer), 8)
        XCTAssertEqual(CVPixelBufferGetHeight(pixelBuffer), 8)
        XCTAssertEqual(CVPixelBufferGetPixelFormatType(pixelBuffer), kCVPixelFormatType_32BGRA)
    }

    func testCopyRenderPassPreservesInputForFoundationPath() throws {
        var input: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            4,
            4,
            kCVPixelFormatType_32BGRA,
            nil,
            &input
        )
        guard status == kCVReturnSuccess, let input else {
            throw BeautyError.pixelBufferCreationFailed
        }

        let pass = CopyRenderPass()
        let output = try pass.execute(
            context: RenderContext(
                inputPixelBuffer: input,
                parameters: BeautyParameters()
            )
        )

        XCTAssertTrue(output.outputPixelBuffer === input)
    }
}
```

- [ ] **Step 2: Run render resource tests to verify they fail**

Run:

```bash
swift test --package-path BeautySDK --filter MetalContextTests
```

Expected: FAIL because render resource types are not defined.

- [ ] **Step 3: Add MetalContext**

Create `BeautySDK/Sources/BeautyRender/MetalContext.swift`:

```swift
import BeautyCore
import Metal

public final class MetalContext: @unchecked Sendable {
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue

    public init(device providedDevice: MTLDevice? = MTLCreateSystemDefaultDevice()) throws {
        guard let device = providedDevice else {
            throw BeautyError.metalUnavailable
        }

        guard let commandQueue = device.makeCommandQueue() else {
            throw BeautyError.commandQueueCreationFailed
        }

        self.device = device
        self.commandQueue = commandQueue
    }
}
```

- [ ] **Step 4: Add TextureCache**

Create `BeautySDK/Sources/BeautyRender/TextureCache.swift`:

```swift
import BeautyCore
import CoreVideo
import Metal

public final class TextureCache: @unchecked Sendable {
    private let device: MTLDevice
    private var cache: CVMetalTextureCache?

    public init(device: MTLDevice) throws {
        self.device = device
        let status = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
        guard status == kCVReturnSuccess, cache != nil else {
            throw BeautyError.textureCreationFailed
        }
    }

    public func makeTexture(
        from pixelBuffer: CVPixelBuffer,
        pixelFormat: MTLPixelFormat = .bgra8Unorm
    ) throws -> MTLTexture {
        guard let cache else {
            throw BeautyError.textureCreationFailed
        }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var metalTexture: CVMetalTexture?

        let status = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            pixelFormat,
            width,
            height,
            0,
            &metalTexture
        )

        guard status == kCVReturnSuccess,
              let metalTexture,
              let texture = CVMetalTextureGetTexture(metalTexture) else {
            throw BeautyError.textureCreationFailed
        }

        return texture
    }
}
```

- [ ] **Step 5: Add PixelBufferPool**

Create `BeautySDK/Sources/BeautyRender/PixelBufferPool.swift`:

```swift
import BeautyCore
import CoreVideo

public final class PixelBufferPool: @unchecked Sendable {
    private let pool: CVPixelBufferPool

    public init(width: Int, height: Int, pixelFormat: OSType = kCVPixelFormatType_32BGRA) throws {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferMetalCompatibilityKey as String: true
        ]

        var pool: CVPixelBufferPool?
        let status = CVPixelBufferPoolCreate(kCFAllocatorDefault, nil, attributes as CFDictionary, &pool)

        guard status == kCVReturnSuccess, let pool else {
            throw BeautyError.pixelBufferCreationFailed
        }

        self.pool = pool
    }

    public func makePixelBuffer() throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBuffer)

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }

        return pixelBuffer
    }
}
```

- [ ] **Step 6: Add CopyRenderPass**

Create `BeautySDK/Sources/BeautyRender/CopyRenderPass.swift`:

```swift
import BeautyCore

public struct CopyRenderPass: RenderPass {
    public let id = "copy"

    public init() {}

    public func shouldRun(context: RenderContext) -> Bool {
        context.inputPixelBuffer != nil
    }

    public func execute(context: RenderContext) throws -> RenderContext {
        guard let input = context.inputPixelBuffer else {
            throw BeautyError.invalidInput
        }

        return context.replacingOutput(input)
    }
}
```

- [ ] **Step 7: Add reserved warp shader file**

Create `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`:

```metal
#include <metal_stdlib>
using namespace metal;

kernel void beauty_copy_kernel(
    texture2d<float, access::read> inputTexture [[texture(0)]],
    texture2d<float, access::write> outputTexture [[texture(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= outputTexture.get_width() || gid.y >= outputTexture.get_height()) {
        return;
    }

    outputTexture.write(inputTexture.read(gid), gid);
}
```

- [ ] **Step 8: Run render resource tests**

Run:

```bash
swift test --package-path BeautySDK --filter MetalContextTests
```

Expected: PASS. On machines without a Metal device, `testMetalContextEitherCreatesQueueOrThrowsTypedError` still passes because `.metalUnavailable` is accepted.

- [ ] **Step 9: Commit render resources**

```bash
git add BeautySDK/Sources/BeautyRender BeautySDK/Tests/BeautyRenderTests/MetalContextTests.swift
git commit -m "feat: add render resource foundation"
```

---

### Task 7: Detection, Effects, And Resources Shells

**Files:**
- Create: `BeautySDK/Sources/BeautyDetection/BeautyFaceLandmarks.swift`
- Create: `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`
- Create: `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift`
- Create: `BeautySDK/Sources/BeautyDetection/FaceDetecting.swift`
- Create: `BeautySDK/Sources/BeautyEffects/BeautyEffect.swift`
- Create: `BeautySDK/Sources/BeautyResources/PresetLoader.swift`
- Create: `BeautySDK/Sources/BeautyResources/ResourceBundleLocator.swift`
- Create: `BeautySDK/Sources/BeautyResources/Resources/manifest.json`
- Test: `BeautySDK/Tests/BeautyDetectionTests/BeautyDetectionShellTests.swift`
- Test: `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectTests.swift`
- Test: `BeautySDK/Tests/BeautyResourcesTests/PresetLoaderTests.swift`

- [ ] **Step 1: Write shell tests**

Create `BeautySDK/Tests/BeautyDetectionTests/BeautyDetectionShellTests.swift`:

```swift
import CoreGraphics
import XCTest
import BeautyDetection

final class BeautyDetectionShellTests: XCTestCase {
    func testObservationSortsLargestFaceFirst() {
        let small = BeautyFaceObservation(id: 1, boundingBox: CGRect(x: 0, y: 0, width: 0.2, height: 0.2), confidence: 0.9)
        let large = BeautyFaceObservation(id: 2, boundingBox: CGRect(x: 0, y: 0, width: 0.5, height: 0.5), confidence: 0.8)

        XCTAssertEqual([small, large].sortedByPrimaryFace().map(\.id), [2, 1])
    }
}
```

Create `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectTests.swift`:

```swift
import XCTest
import BeautyCore
import BeautyEffects

final class BeautyEffectTests: XCTestCase {
    func testNoEffectIsDisabledForDefaultParameters() {
        let effect = NoBeautyEffect(id: "foundation")

        XCTAssertFalse(effect.isEnabled(parameters: BeautyParameters()))
    }
}
```

Create `BeautySDK/Tests/BeautyResourcesTests/PresetLoaderTests.swift`:

```swift
import XCTest
import BeautyCore
import BeautyResources

final class PresetLoaderTests: XCTestCase {
    func testPresetLoaderDecodesValidPresetJSON() throws {
        let json = """
        {
          "id": "natural",
          "version": 1,
          "displayName": "Natural",
          "parameters": {
            "skinSmoothing": 0.2,
            "filterIntensity": 0.4
          }
        }
        """.data(using: .utf8)!

        let preset = try PresetLoader().decodePreset(from: json)

        XCTAssertEqual(preset.id, "natural")
        XCTAssertEqual(preset.version, 1)
        XCTAssertEqual(preset.displayName, "Natural")
        XCTAssertEqual(preset.parameters.skinSmoothing, 0.2)
        XCTAssertEqual(preset.parameters.filterIntensity, 0.4)
    }
}
```

- [ ] **Step 2: Run shell tests to verify they fail**

Run:

```bash
swift test --package-path BeautySDK --filter BeautyDetectionShellTests
swift test --package-path BeautySDK --filter BeautyEffectTests
swift test --package-path BeautySDK --filter PresetLoaderTests
```

Expected: FAIL because shell types are not defined.

- [ ] **Step 3: Add detection shells**

Create `BeautySDK/Sources/BeautyDetection/BeautyFaceLandmarks.swift`:

```swift
import CoreGraphics

public struct BeautyFaceLandmarks: Equatable, Sendable {
    public let faceContour: [CGPoint]
    public let leftEye: [CGPoint]
    public let rightEye: [CGPoint]

    public init(
        faceContour: [CGPoint] = [],
        leftEye: [CGPoint] = [],
        rightEye: [CGPoint] = []
    ) {
        self.faceContour = faceContour
        self.leftEye = leftEye
        self.rightEye = rightEye
    }
}
```

Create `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`:

```swift
import CoreGraphics

public struct BeautyFaceObservation: Equatable, Sendable {
    public let id: Int
    public let boundingBox: CGRect
    public let landmarks: BeautyFaceLandmarks
    public let confidence: Float

    public init(
        id: Int,
        boundingBox: CGRect,
        landmarks: BeautyFaceLandmarks = BeautyFaceLandmarks(),
        confidence: Float
    ) {
        self.id = id
        self.boundingBox = boundingBox
        self.landmarks = landmarks
        self.confidence = confidence
    }

    var area: CGFloat {
        boundingBox.width * boundingBox.height
    }
}

public extension Array where Element == BeautyFaceObservation {
    func sortedByPrimaryFace() -> [BeautyFaceObservation] {
        sorted { lhs, rhs in
            if lhs.area == rhs.area {
                return lhs.id < rhs.id
            }
            return lhs.area > rhs.area
        }
    }
}
```

Create `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift`:

```swift
import CoreGraphics

public struct CoordinateMapper: Sendable {
    public init() {}

    public func imageNormalizedPoint(from point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(point.x, 0), 1),
            y: min(max(point.y, 0), 1)
        )
    }
}
```

Create `BeautySDK/Sources/BeautyDetection/FaceDetecting.swift`:

```swift
import CoreVideo
import ImageIO

public protocol FaceDetecting: Sendable {
    func detectFaces(
        in pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation
    ) async throws -> [BeautyFaceObservation]
}
```

- [ ] **Step 4: Add effect shell**

Create `BeautySDK/Sources/BeautyEffects/BeautyEffect.swift`:

```swift
import BeautyCore

public protocol BeautyEffect: Sendable {
    var id: String { get }
    func isEnabled(parameters: BeautyParameters) -> Bool
}

public struct NoBeautyEffect: BeautyEffect {
    public let id: String

    public init(id: String) {
        self.id = id
    }

    public func isEnabled(parameters: BeautyParameters) -> Bool {
        false
    }
}
```

- [ ] **Step 5: Add resource shells**

Create `BeautySDK/Sources/BeautyResources/PresetLoader.swift`:

```swift
import BeautyCore
import Foundation

public struct PresetLoader: Sendable {
    public init() {}

    public func decodePreset(from data: Data) throws -> BeautyPreset {
        do {
            return try JSONDecoder().decode(BeautyPreset.self, from: data)
        } catch {
            throw BeautyError.presetDecodeFailed("Invalid preset JSON")
        }
    }
}
```

Create `BeautySDK/Sources/BeautyResources/ResourceBundleLocator.swift`:

```swift
import Foundation

public struct ResourceBundleLocator: Sendable {
    public let bundle: Bundle

    public init(bundle: Bundle = .module) {
        self.bundle = bundle
    }
}
```

Create `BeautySDK/Sources/BeautyResources/Resources/manifest.json`:

```json
{
  "schemaVersion": 1,
  "resources": []
}
```

- [ ] **Step 6: Run shell tests**

Run:

```bash
swift test --package-path BeautySDK --filter BeautyDetectionShellTests
swift test --package-path BeautySDK --filter BeautyEffectTests
swift test --package-path BeautySDK --filter PresetLoaderTests
```

Expected: PASS.

- [ ] **Step 7: Commit shells**

```bash
git add BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects BeautySDK/Sources/BeautyResources BeautySDK/Tests/BeautyDetectionTests BeautySDK/Tests/BeautyEffectsTests BeautySDK/Tests/BeautyResourcesTests
git commit -m "feat: add detection effects and resource shells"
```

---

### Task 8: Demo Facade Wiring

**Files:**
- Modify: `BeautyDemo/BeautyDemo/ContentView.swift`
- Modify: `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`

- [ ] **Step 1: Verify package tests pass before Xcode project edits**

Run:

```bash
swift test --package-path BeautySDK
```

Expected: PASS.

- [ ] **Step 2: Modify ContentView to use BeautySDK facade**

Replace `BeautyDemo/BeautyDemo/ContentView.swift` with:

```swift
import BeautySDK
import SwiftUI

struct ContentView: View {
    private let parameters = BeautyParameters()

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("BeautySDK Foundation")
                .font(.headline)

            Text("Version \(BeautySDKVersion.current)")
                .font(.subheadline)

            Text("Default smoothing \(parameters.skinSmoothing, specifier: "%.0f")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
```

- [ ] **Step 3: Add local package reference to Xcode project**

Modify `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` with these concrete additions.

Add a new `PBXBuildFile` section after `objects = {`:

```text
/* Begin PBXBuildFile section */
		A4AADD5C2FC3000000C1D57F /* BeautySDK in Frameworks */ = {isa = PBXBuildFile; productRef = A4AADD5B2FC3000000C1D57F /* BeautySDK */; };
/* End PBXBuildFile section */
```

In `PBXFrameworksBuildPhase` files, replace:

```text
			files = (
			);
```

with:

```text
			files = (
				A4AADD5C2FC3000000C1D57F /* BeautySDK in Frameworks */,
			);
```

In the `PBXNativeTarget` named `BeautyDemo`, replace:

```text
			packageProductDependencies = (
			);
```

with:

```text
			packageProductDependencies = (
				A4AADD5B2FC3000000C1D57F /* BeautySDK */,
			);
```

In the `PBXProject` object, add this property after `mainGroup = A4AADD442FC2EFA400C1D57F;`:

```text
			packageReferences = (
				A4AADD5A2FC3000000C1D57F /* XCLocalSwiftPackageReference "../BeautySDK" */,
			);
```

Add these sections before `XCBuildConfiguration`:

```text
/* Begin XCLocalSwiftPackageReference section */
		A4AADD5A2FC3000000C1D57F /* XCLocalSwiftPackageReference "../BeautySDK" */ = {
			isa = XCLocalSwiftPackageReference;
			relativePath = ../BeautySDK;
		};
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		A4AADD5B2FC3000000C1D57F /* BeautySDK */ = {
			isa = XCSwiftPackageProductDependency;
			package = A4AADD5A2FC3000000C1D57F /* XCLocalSwiftPackageReference "../BeautySDK" */;
			productName = BeautySDK;
		};
/* End XCSwiftPackageProductDependency section */
```

- [ ] **Step 4: Run Demo import boundary scan**

Run:

```bash
rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo
```

Expected: no output.

- [ ] **Step 5: Try Xcode project listing**

Run:

```bash
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
```

Expected when full Xcode is selected: lists the `BeautyDemo` scheme.

Expected in the 2026-05-25 observed environment: FAIL with `xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance`. As of the 2026-06-10 recheck, full Xcode is selected and `xcodebuild -list` succeeds. Record the actual current command output in `PLANS.md`; do not reuse stale environment failures as current evidence.

- [ ] **Step 6: Commit Demo wiring**

```bash
git add BeautyDemo/BeautyDemo/ContentView.swift BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj
git commit -m "feat: wire demo to BeautySDK facade"
```

---

### Task 9: Documentation And Quality Records

**Files:**
- Modify: `PLANS.md`
- Modify: `QUALITY_SCORE.md`

- [ ] **Step 1: Update PLANS active implementation record**

Add a new Active plan entry in `PLANS.md` for execution:

```markdown
### P-2026-05-25-sdk-foundation-implementation

| Field | Value |
| --- | --- |
| Status | `active` |
| Owner | Agent |
| Started | 2026-05-25 |
| Scope | Implement the first BeautySDK Swift Package foundation, core models, no-effect engine, render primitives, shell targets, and Demo facade wiring. |
| Source Request | `docs/superpowers/plans/2026-05-25-sdk-foundation.md` |
| Current Step | Task 1: Swift Package Skeleton |
| Verification Policy | Run `swift test --package-path BeautySDK`, architecture import scans, crash shortcut scans, and `xcodebuild -list` when full Xcode is available. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Package skeleton | `planned` | Evidence will be added after Task 1. |
| Core models | `planned` | Evidence will be added after Task 2. |
| Diagnostics | `planned` | Evidence will be added after Task 3. |
| Engine no-effect path | `planned` | Evidence will be added after Task 4. |
| Render primitives | `planned` | Evidence will be added after Tasks 5 and 6. |
| Shell targets | `planned` | Evidence will be added after Task 7. |
| Demo facade wiring | `planned` | Evidence will be added after Task 8. |
| Final verification | `planned` | Evidence will be added after Task 10. |
| Record outcome | `planned` | Evidence will be added before completion. |

Open Questions:

| Question | Current Decision |
| --- | --- |
| Can local Xcode project verification run | Current environment observed CommandLineTools selected; run and record exact result during Task 8. |
```

- [ ] **Step 2: Update quality score after evidence exists**

After Tasks 1 through 8 pass, update `QUALITY_SCORE.md` scores only for evidence-backed areas:

```markdown
| SDK Package | 2 | `BeautySDK/Package.swift` exists and `swift test --package-path BeautySDK` passes for foundation targets. | Implement real SDK facade process API and Demo runtime smoke. |
| Demo App | 2 | Demo imports only `BeautySDK` and ContentView references facade types; Xcode build remains environment-dependent until full Xcode is selected. | Build minimal integration UI and camera preview shell. |
| Tests | 2 | Swift Package unit tests cover core models, engine no-effect path, render graph, shells, and facade import. | Add render fixture, security, and UI tests. |
```

- [ ] **Step 3: Commit documentation updates**

```bash
git add PLANS.md QUALITY_SCORE.md
git commit -m "docs: record sdk foundation implementation evidence"
```

---

### Task 10: Final Verification

**Files:**
- Inspect: `BeautySDK/Package.swift`
- Inspect: `BeautySDK/Sources`
- Inspect: `BeautySDK/Tests`
- Inspect: `BeautyDemo/BeautyDemo`
- Inspect: `PLANS.md`
- Inspect: `QUALITY_SCORE.md`

- [ ] **Step 1: Run full Swift Package tests**

Run:

```bash
swift test --package-path BeautySDK
```

Expected: PASS.

- [ ] **Step 2: Run Demo internal import scan**

Run:

```bash
rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo
```

Expected: no output.

- [ ] **Step 3: Run SDK UI dependency scan**

Run:

```bash
rg -n "SwiftUI|UIKit" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects 2>/dev/null
```

Expected: no output.

- [ ] **Step 4: Run release-path crash shortcut scan**

Run:

```bash
rg -n "fatalError|try!|as!" BeautySDK/Sources BeautyDemo/BeautyDemo 2>/dev/null
```

Expected: no output.

- [ ] **Step 5: Run Xcode project list**

Run:

```bash
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
```

Expected with full Xcode: PASS and lists project schemes.

Expected with CommandLineTools: FAIL with active developer directory error. If this fails for the observed CommandLineTools reason, record it as an environment limitation and keep `swift test` plus scans as the verified evidence.

- [ ] **Step 6: Run documentation health checks**

Run:

```bash
rg -n "TO""DO|TB""D|FIX""ME|待""定|占""位|Lor""em" PLANS.md QUALITY_SCORE.md docs/superpowers/specs/2026-05-25-sdk-foundation-design.md docs/superpowers/plans/2026-05-25-sdk-foundation.md
```

Expected: no output.

- [ ] **Step 7: Move implementation plan to Completed**

In `PLANS.md`, move `P-2026-05-25-sdk-foundation-implementation` from Active to Completed with:

```markdown
### C-2026-05-25-sdk-foundation-implementation

| Field | Value |
| --- | --- |
| Completed | 2026-05-25 |
| Scope | Implemented the first BeautySDK Swift Package foundation, core models, diagnostics, no-effect engine, render primitives, shell targets, and Demo facade wiring. |
| Files | `BeautySDK/Package.swift`, `BeautySDK/Sources/`, `BeautySDK/Tests/`, `BeautyDemo/BeautyDemo/ContentView.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `PLANS.md`, `QUALITY_SCORE.md` |
| Verification | `swift test --package-path BeautySDK` passed; Demo internal import scan had no output; SDK UI dependency scan had no output; crash shortcut scan had no output; documentation unfinished-marker scan had no output. |
| Build | Record the exact `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` result from Step 5. |

Outcome:

- `BeautySDK` package foundation exists and is independently testable.
- Core parameter and configuration contracts are executable.
- The engine has a typed no-effect processing path.
- Render foundation has a pass graph and copy pass.
- Demo uses the `BeautySDK` facade only.
```

- [ ] **Step 8: Commit final record**

```bash
git add PLANS.md QUALITY_SCORE.md
git commit -m "docs: complete sdk foundation implementation record"
```

---

## Self-Review

Spec coverage:

- Package skeleton is covered by Task 1.
- Core public models are covered by Task 2.
- Diagnostics are covered by Task 3.
- No-effect engine path is covered by Task 4.
- RenderGraph, Metal context, texture cache, pixel buffer pool, and copy pass are covered by Tasks 5 and 6.
- Detection, effects, and resources target shells are covered by Task 7.
- Demo facade dependency direction is covered by Task 8.
- Planning and score records are covered by Task 9.
- Verification gates are covered by Task 10.

Unfinished-marker scan:

- This plan intentionally contains no unresolved implementation markers.

Type consistency:

- `BeautyConfiguration.default`, `BeautyLogLevel`, `BeautyRenderQuality`, `BeautyParameters`, `BeautyPreset`, `BeautyError`, and `BeautyEngine` names match the approved spec.
- `Warp.metal` matches the canonical shader name in the root contracts and audit report.
- Demo imports `BeautySDK`, not internal targets.
