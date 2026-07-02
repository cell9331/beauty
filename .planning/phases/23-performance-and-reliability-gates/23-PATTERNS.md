# Phase 23: Performance and Reliability Gates - Pattern Map

**Mapped:** 2026-07-02
**Files analyzed:** 9 likely new/modified files
**Analogs found:** 9 / 9

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift` | test | batch, transform | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | exact |
| `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` | evidence artifact | batch | `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` | exact |
| `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` | test | event-driven, backpressure | `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` | exact |
| `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` | component | event-driven, request-response | `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | test | request-response, transform | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` | test | CRUD, transform | `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | test | transform, degradation | `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | exact |
| `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | test | file-I/O, static scan | `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` | exact |

## Pattern Assignments

### `BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift` (test, batch/transform)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`

**Imports pattern** (lines 1-5):
```swift
import CoreImage
import CoreVideo
import ImageIO
import XCTest
import BeautySDK
```

**720p pixel-buffer fixture pattern** (lines 185-199):
```swift
enum PixelBufferFixtures {
    static func makePixelBuffer(width: Int, height: Int, pixelFormat: OSType) throws -> CVPixelBuffer {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: pixelFormat,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw BeautyError.pixelBufferCreationFailed
        }
        return pixelBuffer
    }
```

**Core `processResult(pixelBuffer:)` pattern** (lines 49-58):
```swift
let result = try engine.processResult(
    pixelBuffer: input,
    metadata: BeautyInputMetadata(orientation: .up, source: .camera),
    parameters: parameters
)

XCTAssertFalse(input === result.output)
XCTAssertNotEqual(try PixelBufferFixtures.bytes(from: result.output), try PixelBufferFixtures.bytes(from: input))
XCTAssertEqual(result.metrics["beauty.effects.activeCount"], 3)
```

**Warning/metric evidence pattern** (lines 105-117):
```swift
let result = try engine.processResult(
    pixelBuffer: input,
    metadata: BeautyInputMetadata(orientation: .up, source: .camera),
    parameters: BeautyParameters(skinSmoothing: 1)
)

XCTAssertTrue(result.warnings.contains { $0.code == "beauty_strength_capped" })
XCTAssertEqual(result.metrics["beauty.effects.cappedCount"], 1)
```

**Planner notes:** create 1280 x 720 BGRA input through the existing fixture shape; run representative cases from `23-CONTEXT.md` D-02; summarize warmups, samples, mean/max, quality mode, warning codes, and metric keys. Do not persist pixel bytes.

---

### `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` (evidence artifact, batch)

**Analog:** `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`

**Frontmatter/scope pattern** (lines 1-18):
```markdown
---
phase: 21-baseline-audit-and-quality-ledger-refresh
status: draft
updated: 2026-06-30
requirements:
  - AUD-01
  - AUD-02
  - AUD-03
  - AUD-04
---

# Phase 21 Baseline Audit

## Scope

This artifact records the current v1.4 quality, verification, and technical-debt baseline before implementation changes.
```

**Status vocabulary pattern** (lines 20-27):
```markdown
Status values:

- `passed`: command or scan ran now and passed.
- `failed`: command ran now and failed because of repo code, tests, or docs.
- `blocked`: command could not produce meaningful repo evidence because local tooling or hardware is missing.
- `not attempted`: intentionally not run in Phase 21.
- `deferred`: check belongs to a later v1.4 phase.
- `archived`: prior phase evidence cited as history, not current proof.
```

**Command table pattern** (lines 29-39):
```markdown
| Area | Status | Exact command | Evidence summary | Requirement / debt | Next step |
| --- | --- | --- | --- | --- | --- |
| Full SDK tests | passed | `swift test --package-path BeautySDK` | Built successfully and executed 141 XCTest cases with 0 failures and 0 unexpected failures. | AUD-02 | Use as current SDK automated baseline. |
```

**Blocker detail pattern** (lines 41-50):
```markdown
### Tooling Blocker Detail

- Command attempted: `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build`
- Environment: Xcode 26.6 build 17F113; Swift 6.3.3.
- Failure summary: `metal` tool could not execute because the local Xcode Metal Toolchain component is missing.
- Impact: Phase 21 cannot claim current Demo simulator build/test pass.
- Next step: run `xcodebuild -downloadComponent MetalToolchain` outside Phase 21 audit scope.
```

**Phase 22 non-claim/rerun pattern:** use `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` lines 177-183 for explicit non-claims and lines 160-167 for ordered rerun protocol.

---

### `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` (test, event-driven/backpressure)

**Analog:** `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift`

**Imports and actor pattern** (lines 1-8):
```swift
import BeautySDK
import CoreVideo
import ImageIO
import XCTest
@testable import BeautyDemo

@MainActor
final class CameraBeautyPipelineTests: XCTestCase {
```

**Bounded in-flight/latest-frame-wins pattern** (lines 46-76):
```swift
let firstStarted = expectation(description: "first frame started")
let releaseFirst = DispatchSemaphore(value: 0)
let processedTimestamps = LockedValues<TimeInterval>()
let processor = CameraFrameProcessor { frame, _ in
    processedTimestamps.append(frame.timestamp)
    if frame.timestamp == 1 {
        firstStarted.fulfill()
        _ = releaseFirst.wait(timeout: .now() + 2)
    }
    return BeautyResult(output: frame.pixelBuffer)
}
let pipeline = CameraBeautyPipeline(maxInFlight: 1, processor: processor)

pipeline.enqueue(frame: try makeFrame(timestamp: 1), parameters: .init(skinSmoothing: 0.1))
await fulfillment(of: [firstStarted], timeout: 2)

pipeline.enqueue(frame: try makeFrame(timestamp: 2), parameters: .init(skinSmoothing: 0.2))
pipeline.enqueue(frame: try makeFrame(timestamp: 3), parameters: .init(skinSmoothing: 0.3))

XCTAssertEqual(pipeline.inFlightCount, 1)
XCTAssertEqual(pipeline.droppedFrameCount, 1)
XCTAssertEqual(pipeline.lastDropReason, .backpressure)
```

**Latest parameters pattern** (lines 78-102):
```swift
pipeline.enqueue(frame: try makeFrame(timestamp: 1), parameters: .init(skinSmoothing: 0.1))
await fulfillment(of: [firstStarted], timeout: 2)
pipeline.enqueue(frame: try makeFrame(timestamp: 2), parameters: .init(skinSmoothing: 0.2))
pipeline.enqueue(frame: try makeFrame(timestamp: 3), parameters: .init(skinSmoothing: 0.9))

releaseFirst.signal()
await pipeline.waitUntilIdle()

XCTAssertEqual(processedParameters.values.map(\.skinSmoothing), [0.1, 0.9])
XCTAssertEqual(pipeline.state.latestSnapshot?.parameters.skinSmoothing, 0.9)
```

**Fixture/helper pattern** (lines 162-204): copy `makeFrame(timestamp:pixelFormat:)` and `PixelBufferTestFixtures.makePixelBuffer` shape when adding any stress case.

---

### `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` (component, event-driven)

**Analog:** `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`

**State and counters pattern** (lines 153-169):
```swift
@MainActor
final class CameraBeautyPipeline: ObservableObject {
    @Published private(set) var state: CameraProcessingState = .idle

    private(set) var inFlightCount = 0
    private(set) var droppedFrameCount = 0
    private(set) var lastDropReason: CameraFrameDropReason?
```

**Backpressure implementation pattern** (lines 181-195):
```swift
func enqueue(frame: CameraPreviewFrame, parameters: BeautyParameters) {
    let work = CameraProcessingWork(frame: frame, parameters: parameters, generation: generation)

    if inFlightCount < maxInFlight {
        start(work)
        return
    }

    if pendingWork != nil {
        droppedFrameCount += 1
        lastDropReason = .backpressure
    }
    pendingWork = work
    publishProcessingState()
}
```

**Reset pattern** (lines 197-208):
```swift
func reset() {
    generation &+= 1
    pendingWork = nil
    latestSnapshot = nil
    currentWarning = nil
    detectionStatusDebouncer.reset()
    inFlightCount = 0
    droppedFrameCount = 0
    lastDropReason = nil
    state = .idle
    resumeIdleContinuationsIfNeeded()
}
```

**SDK facade processor pattern** (lines 311-324):
```swift
nonisolated private final class BeautyEnginePixelBufferProcessor: @unchecked Sendable {
    private let engine: BeautyEngine

    nonisolated init() throws {
        self.engine = try BeautyEngine(configuration: .default)
    }

    func process(frame: CameraPreviewFrame, parameters: BeautyParameters) throws -> BeautyResult<CVPixelBuffer> {
        try engine.processResult(
            pixelBuffer: frame.pixelBuffer,
            metadata: frame.metadata,
            parameters: parameters
        )
    }
}
```

---

### `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` (test, request-response/transform)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`

**Typed error pattern** (lines 83-92):
```swift
XCTAssertThrowsError(
    try engine.process(pixelBuffer: input, orientation: .up, parameters: parameters)
) { error in
    XCTAssertEqual(error as? BeautyError, .resourceNotFound("missing_filter"))
}
```

**Reset evidence pattern** (lines 170-182):
```swift
let parameters = BeautyParameters(skinSmoothing: 0.5)
var copy = parameters
let engine = try BeautyEngine(configuration: .default)

engine.reset()
engine.reset()

XCTAssertEqual(parameters, copy)
XCTAssertEqual(engine.resetCountForTesting, 2)
copy = parameters
XCTAssertEqual(copy.skinSmoothing, 0.5)
```

**Implementation reference:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` lines 36-50 own pixel-buffer `processResult`; lines 91-97 own `reset()` and `resetCountForTesting`; lines 103-112 own pixel-buffer validation.

---

### `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` (test, CRUD/transform)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift`

**Default release-safe config pattern** (lines 6-17):
```swift
let configuration = BeautyConfiguration.default

XCTAssertNil(configuration.preferredProcessingSize)
XCTAssertEqual(configuration.maximumFaceCount, 1)
XCTAssertTrue(configuration.enableFaceTracking)
XCTAssertEqual(configuration.detectionFrameInterval, 3)
XCTAssertEqual(configuration.renderQuality, .balanced)
XCTAssertFalse(configuration.enablePerformanceLog)
XCTAssertFalse(configuration.enableDebugMode)
XCTAssertEqual(configuration.logLevel, .error)
```

**Codable/Sendable pattern** (lines 31-43):
```swift
let configuration = BeautyConfiguration(
    preferredProcessingSize: CGSize(width: 720, height: 1280),
    renderQuality: .quality,
    enablePerformanceLog: true,
    logLevel: .info
)

let data = try JSONEncoder().encode(configuration)
let decoded = try JSONDecoder().decode(BeautyConfiguration.self, from: data)
XCTAssertEqual(decoded, configuration)
assertSendable(decoded)
```

**Implementation references:** `BeautyConfiguration.swift` lines 3-13 define the stored fields/default; lines 15-33 define init defaults and clamping. `BeautyRenderQuality.swift` lines 1-5 define `.performance`, `.balanced`, `.quality`.

---

### `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` (test, transform/safety caps)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift`

**No-face degradation pattern** (lines 8-41):
```swift
let plan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(
        skinSmoothing: 0.6,
        brightness: 0.2,
        faceSlim: 1,
        eyeSize: 1,
        noseSlim: 1,
        mouthSize: 1,
        lipColor: 1,
        filterId: "soft_clean",
        filterIntensity: 0.5
    ),
    faceGeometry: nil
)

XCTAssertTrue(plan.activeDomains.contains(.color))
XCTAssertTrue(plan.activeDomains.contains(.filter))
XCTAssertFalse(plan.activeDomains.contains(.skin))
XCTAssertGreaterThanOrEqual(plan.metrics["beauty.effects.skippedFaceDomains"] ?? 0, 6)
XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
```

**High-strength cap/weakening pattern** (lines 43-84): use the all-domain `BeautyParameters(... 1 ...)` case and assert `beauty_strength_capped`, `combined_geometry_weakened`, capped/weakening metrics, and `LessThan` effective strengths.

**Redaction pattern** (lines 109-128):
```swift
let metadata = (
    plan.warnings.map { "\($0.code) \($0.message)" } +
    Array(plan.metrics.keys)
).joined(separator: " ")

for forbidden in ["VNFaceObservation", "boundingBox", "landmark", "/private/var", "NSError", "rawPresetJson", "image bytes", "SIMD", "[0."] {
    XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
}
```

---

### `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` (test, transform/degradation)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`

**Missing group degradation pattern** (lines 6-22):
```swift
let plan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(
        brightness: 0.2,
        eyeSize: 1,
        filterId: "soft_clean",
        filterIntensity: 0.5
    ),
    faceGeometry: .missingLeftEye
)

XCTAssertFalse(plan.activeDomains.contains(.eyes))
XCTAssertTrue(plan.activeDomains.contains(.color))
XCTAssertTrue(plan.activeDomains.contains(.filter))
XCTAssertEqual(plan.skippedDomains, [.eyes])
XCTAssertTrue(plan.warnings.contains { $0.code == "eye_inputs_missing" })
```

**Stale/reused degradation pattern** (lines 106-130):
```swift
let reused = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(eyeSize: 1, noseSlim: 1),
    faceGeometry: .reused
)
XCTAssertLessThan(reused.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize)
XCTAssertTrue(reused.warnings.contains { $0.code == "geometry_stale_reduced" })

let stale = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(brightness: 0.2, eyeSize: 1, noseSlim: 1),
    faceGeometry: .stale
)
XCTAssertFalse(stale.activeDomains.contains(.eyes))
XCTAssertTrue(stale.warnings.contains { $0.code == "geometry_stale_skipped" })
```

**Shared redaction helper** (lines 198-207): copy `assertRedacted(_:)` for new resolver regression checks.

---

### `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` (test, file-I/O/static scan)

**Analog:** `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift`

**Repo-relative scan helper pattern** (lines 323-365):
```swift
private func repoRoot() throws -> URL {
    var cursor = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

    while cursor.path != "/" {
        let projectPath = cursor.appendingPathComponent("BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj")
        if FileManager.default.fileExists(atPath: projectPath.path) {
            return cursor
        }
        cursor.deleteLastPathComponent()
    }

    throw SourceScanError.missingRepoRoot
}
```

**Forbidden token scan pattern** (lines 20-39):
```swift
let forbiddenTokens = [
    "URLSession",
    "http" + "://",
    "https" + "://",
    "up" + "load",
    "/private" + "/var",
    "NSError",
    "AV" + "Error"
]

let matches = try matches(for: forbiddenTokens, in: files)

XCTAssertTrue(matches.isEmpty, matches.joined(separator: "\n"))
```

**Public summary redaction pattern** (lines 253-301): build rendered user-facing/debug text, then reject `VNFaceObservation`, `boundingBox`, `CGPoint`, `CGRect`, `NSError`, `/private/var`, `http://`, and `https://`.

**Apply to Phase 23:** add a scoped scan for `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` after it exists, using the forbidden fields from `23-CONTEXT.md` D-13.

## Shared Patterns

### SDK Facade Processing
**Source:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` lines 36-50
**Apply to:** `BeautyPerformanceEvidenceTests.swift`, `BeautyEngineTests.swift`, Demo processor evidence
```swift
try Self.validate(pixelBuffer: pixelBuffer)
let validated = try BeautySDKResources.validate(parameters: parameters)
let plan = BeautyEffectResolver.resolve(parameters: validated)
return BeautyResult(
    output: try BeautyColorEffectPipeline.apply(to: pixelBuffer, plan: plan),
    warnings: plan.warnings,
    metrics: plan.metrics,
    detectionSummary: initialDetectionSummary
)
```

### Backpressure and Latest-Frame-Wins
**Source:** `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` lines 181-195, 270-277
**Apply to:** `CameraBeautyPipelineTests.swift`, Phase 23 PERF-02 evidence
```swift
if pendingWork != nil {
    droppedFrameCount += 1
    lastDropReason = .backpressure
}
pendingWork = work
```

### Reset
**Source:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` lines 91-97; `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` lines 197-208
**Apply to:** SDK reset tests, Demo pipeline reset tests, evidence non-claims

### Quality Defaults and Logging Off-by-Default
**Source:** `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` lines 15-33; `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` lines 6-17
**Apply to:** PERF-03 and PERF-05 tests

### Redaction
**Source:** `SECURITY.md` sections 2 and 2.1; `RELIABILITY.md` sections 7 and 9; `InputPipelinePrivacyTests.swift` lines 20-39 and 253-320
**Apply to:** every new test output and `23-PERFORMANCE-EVIDENCE.md`

Allowed fields: case name, duration summary, resolution bucket, quality mode, dropped-frame count, warning/metric codes, command, environment, budget comparison, blocker class, impact, next step, rerun protocol.

Forbidden fields: image bytes, local/private paths, face geometry, raw JSON, raw framework errors, user identifiers, tokens, raw diagnostics, `NSError`, `VNFaceObservation`, bounding boxes, landmark points.

### Evidence Artifact Shape
**Source:** `21-BASELINE-AUDIT.md` lines 29-50 and `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` lines 24-53, 160-183
**Apply to:** `23-PERFORMANCE-EVIDENCE.md`

Use sections for scope/non-claims, environment, command results, timing matrix, memory trend, blocker details, redaction scan, rerun protocol, and explicit non-claims.

## No Analog Found

No close-match gaps for the planned Phase 23 surfaces. The one implementation gap is semantic, not structural: current `BeautyConfiguration.renderQuality` is a stored configuration value and `BeautyEngine.processResult` does not branch on quality mode. Planner should either limit PERF-03 to current configuration-contract evidence or add minimal internal/test-focused behavior as allowed by `23-CONTEXT.md` D-09 and D-12.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `BeautyDemo/BeautyDemo`, `BeautyDemo/BeautyDemoTests`, `.planning/phases/21-*`, `.planning/evidence/v1.4`
**Files scanned:** 17 focused files plus required Phase 23/context/root docs
**Pattern extraction date:** 2026-07-02
