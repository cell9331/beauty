# Phase 26: Geometry Facade and Landmark Routing Foundation - Pattern Map

**Mapped:** 2026-07-06
**Files analyzed:** 16 new/modified files
**Analogs found:** 16 / 16

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | facade/controller | request-response | `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | exact |
| `BeautySDK/Sources/BeautySDK/BeautySDK.swift` | facade/export config | request-response | `BeautySDK/Sources/BeautySDK/BeautySDK.swift` | exact |
| `BeautySDK/Sources/BeautySDK/*Geometry*Routing*.swift` or private extension | service/adapter | transform | `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` + `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` | role-match |
| `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | service | request-response | `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | exact |
| `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` | model | transform | `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` | exact |
| `BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift` | service | transform | `BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift` | exact |
| `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift` | utility | transform | `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | exact |
| `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` | model | request-response | `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` | exact |
| `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` | model | request-response | `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryRoutingTests.swift` or focused additions to `BeautyEngineTests.swift` | test | request-response | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift` | test | request-response | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift` | exact |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | test | request-response | `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` / `MissingLandmarkDegradationTests.swift` | test | transform | same files | exact |
| Root docs and evidence docs: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `docs/meitu-function-blueprint/*`, `PLANS.md` | docs/config | batch | `QUALITY_SCORE.md`, `SHAPE_FEATURE_LEDGER.md`, `EXAMPLE_IMAGE_VALIDATION.md` | role-match |

## Pattern Assignments

### `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` (facade/controller, request-response)

**Analog:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`

**Imports pattern** (lines 1-8):
```swift
import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import ImageIO
import BeautyCore
import BeautyEffects
```

Add `BeautyDetection` only if the facade directly constructs the detector/routing seam; this is allowed by `BeautySDK/Package.swift` lines 32-35.

**Facade validation + result assembly pattern** (lines 72-88):
```swift
public func processResult(
    image: CIImage,
    metadata: BeautyInputMetadata,
    parameters: BeautyParameters
) throws -> BeautyResult<CIImage> {
    _ = metadata
    guard image.extent.isFiniteAndNonEmpty else {
        throw BeautyError.invalidInput
    }
    let validated = try BeautySDKResources.validate(parameters: parameters)
    let plan = BeautyEffectResolver.resolve(parameters: validated)
    return BeautyResult(
        output: BeautyColorEffectPipeline.apply(to: image, plan: plan),
        warnings: plan.warnings,
        metrics: plan.metrics,
        detectionSummary: initialDetectionSummary
    )
}
```

Copy this shape, but insert the geometry-triggered detection/routing step after resource validation and before `BeautyEffectResolver.resolve(...)`. Preserve the no-detection path by keeping `initialDetectionSummary` when geometry-triggering parameters are absent.

**Compatibility summary pattern** (lines 99-101):
```swift
private var initialDetectionSummary: BeautyDetectionSummary {
    configuration.enableFaceTracking ? .notRun : .disabled
}
```

Phase 26 should keep this exact behavior for no-op, color, filter, and basic skin paths.

**Input validation pattern** (lines 77-80 and 103-112):
```swift
guard image.extent.isFiniteAndNonEmpty else {
    throw BeautyError.invalidInput
}
```

```swift
guard width > 0, height > 0 else {
    throw BeautyError.invalidInput
}
guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else {
    throw BeautyError.unsupportedPixelFormat
}
```

Do not run detection before these guards and `BeautySDKResources.validate(parameters:)`.

---

### `BeautySDK/Sources/BeautySDK/BeautySDK.swift` (facade/export config, request-response)

**Analog:** `BeautySDK/Sources/BeautySDK/BeautySDK.swift`

**Public export + SPI testing pattern** (lines 1-9):
```swift
@_exported import BeautyCore
import BeautyRender

public enum BeautySDKModule {
    public static let name = "BeautySDK"
}

@_spi(Testing) public typealias SDKTestingCopyRenderPass = CopyRenderPass
@_spi(Testing) public typealias SDKTestingRenderGraph = RenderGraph
@_spi(Testing) public typealias SDKTestingRenderPass = RenderPass
```

If facade tests need deterministic detection injection, copy the SPI style: expose only a narrow testing alias or initializer under `@_spi(Testing)`. Do not export `BeautyFaceObservation`, landmark groups, `FaceGeometry`, provider types, or control points as public API.

---

### `BeautySDK/Sources/BeautySDK/*Geometry*Routing*.swift` or private extension (service/adapter, transform)

**Analogs:** `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`, `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift`

**Detector output pattern** (`VisionFaceDetector.swift` lines 28-31):
```swift
struct VisionFaceDetectionResult: Equatable, Sendable {
    let observations: [BeautyFaceObservation]
    let summary: BeautyDetectionSummary
}
```

**Internal observation pattern** (`BeautyFaceObservation.swift` lines 3-22):
```swift
struct BeautyFaceObservation: Equatable, Sendable {
    let stableID: String?
    let confidence: Double
    let normalizedArea: Double
    let imageBounds: CoordinateRect?
    let landmarks: BeautyFaceLandmarks
}
```

**Internal geometry pattern** (`WarpControlPoint.swift` lines 30-55):
```swift
struct FaceGeometry: Equatable, Sendable {
    let bounds: FaceBounds
    let faceContour: [SIMD2<Float>]
    let leftEye: [SIMD2<Float>]
    let rightEye: [SIMD2<Float>]
    let nose: [SIMD2<Float>]
    let outerLips: [SIMD2<Float>]
    let freshness: LandmarkGeometryFreshness
}
```

The adapter should be internal-only. It can map one selected `BeautyFaceObservation` into a minimal deterministic `FaceGeometry` sufficient to activate resolver/provider intent. Keep raw bounds, points, and landmark availability out of public `BeautyResult`.

**Landmark availability pattern** (`BeautyFaceObservation.swift` lines 33-58):
```swift
struct BeautyFaceLandmarks: Equatable, Sendable {
    private static let requiredGeometryGroups: Set<BeautyLandmarkGroup> = [
        .faceContour,
        .leftEye,
        .rightEye,
        .nose,
        .outerLips
    ]

    let availableGroups: Set<BeautyLandmarkGroup>

    var hasRequiredGeometry: Bool {
        Self.requiredGeometryGroups.isSubset(of: availableGroups)
    }
}
```

Use this availability model to preserve missing-landmark degradation. Do not invent public landmark booleans.

---

### `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` (service, request-response)

**Analog:** `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`

**Imports pattern** (lines 1-4):
```swift
import BeautyCore
import CoreGraphics
import Foundation
import Vision
```

**Injectable provider seam** (lines 33-52):
```swift
struct VisionFaceDetector: Sendable {
    enum Failure: Error, Equatable, Sendable {
        case detectorUnavailable
        case detectionTimedOut
    }

    typealias ObservationProvider = @Sendable (BeautyInputMetadata) throws -> [VisionDetectionObservation]

    private let minimumConfidence: Double
    private let observationProvider: ObservationProvider
    private var selectionPolicy: FaceSelectionPolicy
}
```

Facade tests should reuse or wrap this seam. Avoid a second fake detector model with divergent summary behavior.

**Detection disabled and failure handling pattern** (lines 54-86):
```swift
mutating func detect(
    metadata: BeautyInputMetadata,
    imageExtent: CGSize = CGSize(width: 1, height: 1),
    previewExtent: CGSize? = nil,
    configuration: BeautyConfiguration = .default
) -> VisionFaceDetectionResult {
    guard configuration.enableFaceTracking else {
        selectionPolicy.reset()
        return VisionFaceDetectionResult(observations: [], summary: .disabled)
    }

    do {
        let observations = try observationProvider(metadata)
        return summarize(observations, metadata: metadata, imageExtent: imageExtent, previewExtent: previewExtent, configuration: configuration)
    } catch let failure as Failure {
        selectionPolicy.reset()
        return VisionFaceDetectionResult(observations: [], summary: summary(for: failure))
    } catch {
        selectionPolicy.reset()
        return VisionFaceDetectionResult(
            observations: [],
            summary: BeautyDetectionSummary(availability: .skipped, reasons: [.detectorUnavailable])
        )
    }
}
```

Detection failures degrade to summaries. Do not throw raw Vision errors from the facade path.

**Summary degradation pattern** (lines 111-120 and 190-206):
```swift
let usableDetections = detections.filter { detection in
    detection.confidence >= minimumConfidence && detection.landmarks.hasRequiredGeometry
}

guard !usableDetections.isEmpty else {
    selectionPolicy.reset()
    return VisionFaceDetectionResult(
        observations: [],
        summary: degradedSummary(for: detections)
    )
}
```

```swift
return BeautyDetectionSummary(
    availability: .partial,
    reasons: [.missingLandmarks],
    faceCount: detections.count,
    usedFaceCount: 0
)
```

Use these states for facade evidence: `.usable`, `.noFace`, `.lowConfidence`, `.partial`, `.skipped`, `.disabled`, and `.notRun`.

---

### `BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift`

**Selected-face pattern** (lines 13-40):
```swift
mutating func select(
    from observations: [BeautyFaceObservation],
    configuration: BeautyConfiguration
) -> FaceSelectionResult {
    guard !observations.isEmpty else {
        previousPrimaryStableID = nil
        return FaceSelectionResult(selectedFaces: [], summary: .noFace)
    }

    let faceBudget = max(1, configuration.maximumFaceCount)
    let orderedFaces = orderByAreaThenStableID(observations)
    let selectedFaces = Array(orderedFaces.prefix(faceBudget))
    previousPrimaryStableID = selectedFaces.first?.stableID
}
```

Phase 26 should route only `selectedFaces.first` into `FaceGeometry` even if `maximumFaceCount` later grows beyond one.

**Public-safe count summary pattern** (lines 27-40):
```swift
var reasons: [DetectionDegradationReason] = []
if observations.count > faceBudget {
    reasons.append(.faceLimitApplied)
}

return FaceSelectionResult(
    selectedFaces: selectedFaces,
    summary: BeautyDetectionSummary(
        availability: .usable,
        reasons: reasons,
        faceCount: observations.count,
        usedFaceCount: selectedFaces.count
    )
)
```

Only counts/reasons should cross the public result boundary.

---

### `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift` (utility, transform)

**Analog:** `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift`

**Metadata-aware mapper pattern** (lines 14-26):
```swift
let metadata: BeautyInputMetadata
let imageExtent: CGSize
let previewExtent: CGSize?

init(
    metadata: BeautyInputMetadata,
    imageExtent: CGSize,
    previewExtent: CGSize? = nil
) {
    self.metadata = metadata
    self.imageExtent = imageExtent
    self.previewExtent = previewExtent
}
```

**Rect mapping and error pattern** (lines 42-56):
```swift
func map(
    rect: CoordinateRect,
    from source: CoordinateSpace,
    to destination: CoordinateSpace
) throws -> CoordinateRect {
    try validateImageExtent()
    guard rect.isFinite else {
        throw MappingError.invalidCoordinate
    }

    let mappedCorners = try rect.corners.map { corner in
        try map(point: corner, from: source, to: destination)
    }
    return CoordinateRect.bounding(mappedCorners)
}
```

Keep coordinate math centralized here. If mapping fails, follow `VisionFaceDetector`'s `.partial` / `.mappingFailed` summary pattern rather than leaking coordinates.

---

### `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`

**Public vs internal resolver overload pattern** (lines 3-10):
```swift
public enum BeautyEffectResolver {
    public static func resolve(parameters: BeautyParameters) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: nil, treatsMissingFaceAsNoFace: false)
    }

    static func resolve(parameters: BeautyParameters, faceGeometry: FaceGeometry?) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: faceGeometry, treatsMissingFaceAsNoFace: true)
    }
}
```

The facade geometry route should call the internal `faceGeometry` overload after detection has been intentionally triggered. Preserve the public overload for no-detection compatibility.

**Geometry trigger source pattern** (lines 66-83):
```swift
let hasGeometryValues = anyNonZero(
    strengths.faceSlim,
    strengths.faceSmall,
    strengths.faceVShape,
    strengths.jawSlim,
    strengths.chinLength,
    strengths.eyeSize,
    strengths.eyeDistance,
    strengths.eyeYPosition,
    strengths.eyeTailLift,
    strengths.noseSlim,
    strengths.noseWingSlim,
    strengths.noseTipSize,
    strengths.noseBridge,
    strengths.mouthSize,
    strengths.mouthWidth,
    strengths.smile
)
```

Copy this domain list when implementing the facade's geometry-trigger helper, adding lip-region work (`lipColor`) as Phase 26 context requires. Basic skin/color/filter alone must not trigger detection.

**No-face degradation pattern** (lines 269-280):
```swift
if noUsableFace {
    let skippedFaceDependentCount = skippedDomains
        .intersection([.skin, .faceShape, .eyes, .nose, .mouth, .lipColor])
        .count
    if skippedFaceDependentCount > 0 {
        metrics["beauty.effects.skippedFaceDomains"] = Double(skippedFaceDependentCount)
    }
}
metrics["beauty.effects.activeCount"] = Double(activeDomains.count)
metrics["beauty.effects.cappedCount"] = Double(cappedCount)
if geometryPointCount > 0 {
    metrics["beauty.effects.geometryPointCount"] = Double(geometryPointCount)
}
```

If `geometryPointCount` is judged too revealing, rename it to a safer aggregate in code/tests/docs together. Keep only counts and flags.

**Warning pattern** (lines 339-343 and 346-350):
```swift
BeautyValidationWarning(
    code: "face_effects_skipped_no_face",
    message: "Face-dependent geometry was skipped because no usable face was available."
)
```

```swift
BeautyValidationWarning(
    code: "eye_inputs_missing",
    message: "Eye geometry was skipped because required eye inputs were unavailable."
)
```

Warnings use stable codes and redacted text. Do not include raw errors, coordinates, object dumps, or local paths.

---

### `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`

**Control-point aggregation pattern** (lines 1-16):
```swift
enum BeautyGeometryEffectPipeline {
    static func controlPoints(for plan: BeautyEffectPlan, face: FaceGeometry) -> [WarpControlPoint] {
        guard !plan.activeDomains.isDisjoint(with: [.faceShape, .eyes, .nose, .mouth]) else {
            return []
        }

        return controlPoints(for: plan.effectiveStrengths, face: face)
    }
}
```

Phase 26 should use this only as internal/test proof of geometry intent. Do not add `BeautyExampleRenderer` geometry cases or saved PNG claims.

---

### `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` (model, request-response)

**Analog:** `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift`

**Public redacted summary pattern** (lines 1-23):
```swift
public enum DetectionAvailability: String, Codable, Equatable, Sendable {
    case notRun
    case disabled
    case noFace
    case usable
    case partial
    case lowConfidence
    case skipped
    case reused
    case stale
}

public enum DetectionDegradationReason: String, Codable, Equatable, Sendable {
    case noFaceDetected
    case lowConfidenceFace
    case missingLandmarks
    case staleDetection
    case faceLimitApplied
    case detectorUnavailable
    case detectionTimedOut
    case mappingFailed
    case orientationMetadataMissing
}
```

**Counts-only initializer pattern** (lines 25-47):
```swift
public struct BeautyDetectionSummary: Codable, Equatable, Sendable {
    public let availability: DetectionAvailability
    public let reasons: [DetectionDegradationReason]
    public let faceCount: Int
    public let usedFaceCount: Int
    public let detectionDurationMs: Double?
    public let mappingDurationMs: Double?
}
```

Do not add bounding boxes, points, IDs, Vision objects, raw strings, or image paths here.

---

### `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` (model, request-response)

**Analog:** `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift`

**Public envelope pattern** (lines 1-17):
```swift
public struct BeautyResult<Output>: @unchecked Sendable {
    public let output: Output
    public let warnings: [BeautyValidationWarning]
    public let metrics: [String: Double]
    public let detectionSummary: BeautyDetectionSummary?
}
```

Phase 26 public evidence should continue to flow through these fields only.

---

### Focused facade tests (test, request-response)

**Analogs:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift`, `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift`

**Facade test imports pattern** (`BeautyEngineTests.swift` lines 1-5):
```swift
import CoreImage
import CoreVideo
import ImageIO
import XCTest
import BeautySDK
```

If SPI is needed, use `@_spi(Testing) import BeautySDK`; keep tests centered on the public facade result.

**Public result assertion pattern** (`BeautyEngineTests.swift` lines 49-58):
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

For Phase 26, assert detection is triggered only by geometry parameters and that the result contains `.usable` / degraded summaries plus aggregate metrics.

**Compatibility no-detection pattern** (`BeautyEngineMetadataCompatibilityTests.swift` lines 23-28 and 49-60):
```swift
let oldOutput = try engine.process(pixelBuffer: input, orientation: .up, parameters: .init())
let newResult = try engine.processResult(pixelBuffer: input, metadata: metadata, parameters: .init())

XCTAssertEqual(try PixelBufferFixtures.bytes(from: oldOutput), try PixelBufferFixtures.bytes(from: newResult.output))
XCTAssertEqual(newResult.detectionSummary, .notRun)
```

```swift
let engine = try BeautyEngine(configuration: BeautyConfiguration(enableFaceTracking: false))
let result = try engine.processResult(pixelBuffer: input, metadata: metadata, parameters: .init())

XCTAssertEqual(result.detectionSummary?.availability, .disabled)
XCTAssertEqual(result.detectionSummary?.reasons, [])
```

Add Phase 26 tests that preserve `.notRun` for default/color/filter/basic-skin and `.disabled` when face tracking is off.

**Redaction assertion pattern** (`BeautyEngineTests.swift` lines 151-158):
```swift
let combined = (
    result.warnings.map { "\($0.code) \($0.message)" } +
    Array(result.metrics.keys) +
    (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
).joined(separator: " ")
for forbidden in ["landmark", "boundingBox", "VNFaceObservation", "/private/var", "NSError", "rawPresetJson", "image bytes"] {
    XCTAssertFalse(combined.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
}
```

Use this exact pattern for facade geometry-route evidence.

**Facade import boundary pattern** (`BeautySDKFacadeTests.swift` lines 1-10):
```swift
import XCTest
import BeautySDK

final class BeautySDKFacadeTests: XCTestCase {
    func testFacadeProductCanBeImported() {
        XCTAssertEqual(BeautySDKModule.name, "BeautySDK")
    }
}
```

Keep public API exposure tests importing only `BeautySDK`.

---

### Detector tests (test, request-response)

**Analog:** `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`

**Internal test imports pattern** (lines 1-4):
```swift
import ImageIO
import XCTest
import BeautyCore
@testable import BeautyDetection
```

**No-face, low-confidence, missing-landmark patterns** (lines 7-58):
```swift
var detector = VisionFaceDetector { _ in [] }
let result = detector.detect(metadata: metadata())
XCTAssertEqual(result.summary.availability, .noFace)
XCTAssertEqual(result.summary.reasons, [.noFaceDetected])
```

```swift
VisionDetectionObservation(
    stableID: "low",
    confidence: 0.20,
    normalizedArea: 0.40,
    landmarks: .complete
)
```

```swift
VisionDetectionObservation(
    stableID: "partial",
    confidence: 0.90,
    normalizedArea: 0.40,
    landmarks: .missingRequiredGeometry
)
```

Copy these states into any additional detector/routing tests; they are the required deterministic states from D-04.

**Selection and count pattern** (lines 61-79):
```swift
let result = detector.detect(
    metadata: metadata(),
    configuration: BeautyConfiguration(maximumFaceCount: 1)
)

XCTAssertEqual(result.observations.map(\.stableID), ["a"])
XCTAssertEqual(result.summary.availability, .usable)
XCTAssertEqual(result.summary.reasons, [.faceLimitApplied])
XCTAssertEqual(result.summary.faceCount, 2)
XCTAssertEqual(result.summary.usedFaceCount, 1)
```

**Raw diagnostic redaction pattern** (lines 114-127):
```swift
let forbiddenTokens = ["VNFaceObservation", "boundingBox", "landmark", "NSError", "/"]
for token in forbiddenTokens {
    XCTAssertFalse(
        diagnostic.contains(token),
        "diagnostic leaked \(token): \(diagnostic)",
        file: file,
        line: line
    )
}
```

---

### Resolver/provider tests (test, transform)

**Analogs:** `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`

**Internal effects test imports pattern** (`BeautyEffectResolverTests.swift` lines 1-3):
```swift
import XCTest
import BeautyCore
@testable import BeautyEffects
```

**Public resolver no-geometry pattern** (`BeautyEffectResolverTests.swift` lines 62-82):
```swift
let plan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(
        brightness: 0.2,
        faceSlim: 1,
        eyeSize: 1,
        noseSlim: 1,
        mouthSize: 1,
        lipColor: 1
    )
)

XCTAssertTrue(plan.activeDomains.contains(.color))
XCTAssertFalse(plan.activeDomains.contains(.faceShape))
XCTAssertTrue(plan.skippedDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .lipColor]))
XCTAssertNil(plan.metrics["beauty.effects.geometryPointCount"])
```

This is the baseline that the facade should change only when geometry-triggered detection produces internal geometry.

**Internal no-face degradation pattern** (`BeautyEffectResolverTests.swift` lines 85-102):
```swift
let plan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(skinSmoothing: 0.4, skinWhitening: 0.3),
    faceGeometry: nil
)

XCTAssertFalse(plan.activeDomains.contains(.skin))
XCTAssertTrue(plan.skippedDomains.contains(.skin))
XCTAssertTrue(plan.warnings.contains { $0.code == "face_effects_skipped_no_face" })
XCTAssertEqual(plan.metrics["beauty.effects.skippedFaceDomains"], 1)
```

**Group-specific degradation pattern** (`MissingLandmarkDegradationTests.swift` lines 68-113):
```swift
let noFace = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: nil)
XCTAssertTrue(noFace.activeDomains.contains(.color))
XCTAssertTrue(noFace.activeDomains.contains(.filter))
XCTAssertFalse(noFace.activeDomains.contains(.faceShape))
XCTAssertTrue(noFace.skippedDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .lipColor]))
```

```swift
let missingMouth = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .missingMouth)
XCTAssertTrue(missingMouth.activeDomains.contains(.eyes))
XCTAssertTrue(missingMouth.activeDomains.contains(.nose))
XCTAssertFalse(missingMouth.activeDomains.contains(.mouth))
XCTAssertFalse(missingMouth.activeDomains.contains(.lipColor))
```

**Stale/reused pattern** (`MissingLandmarkDegradationTests.swift` lines 97-109):
```swift
let stale = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .stale)
XCTAssertFalse(stale.activeDomains.contains(.eyes))
XCTAssertFalse(stale.activeDomains.contains(.nose))
XCTAssertTrue(stale.warnings.contains { $0.code == "geometry_stale_skipped" })

let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .reused)
XCTAssertTrue(reused.activeDomains.contains(.eyes))
XCTAssertTrue(reused.activeDomains.contains(.nose))
XCTAssertTrue(reused.warnings.contains { $0.code == "geometry_stale_reduced" })
```

---

### Root docs and evidence docs (docs/config, batch)

**Analogs:** `QUALITY_SCORE.md`, `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`

**Quality scan pattern** (`QUALITY_SCORE.md` lines 240-260):
```bash
rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects" BeautyDemo
```

```bash
rg -n "SwiftUI|UIKit" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects 2>/dev/null
```

```bash
rg -n "UIImage" BeautySDK/Sources BeautyDemo/BeautyDemo 2>/dev/null
```

Add Phase 26 active-source scans beside this style. Include raw geometry/diagnostic terms over `BeautySDK/Sources/BeautyCore`, `BeautySDK/Sources/BeautySDK`, detection/effects routing code, and active Demo surfaces where relevant.

**Ledger anti-overclaim pattern** (`SHAPE_FEATURE_LEDGER.md` lines 16-18 and 29-39):
```markdown
4. **No fake completion:** A tool is not implemented just because it appears in a Demo rail. It must have SDK behavior and verification.
5. **Geometry needs output proof:** Geometry provider/resolver evidence is useful, but geometry tools remain below `implemented` until public facade processing can produce representative saved output through the SDK verification path.
```

```markdown
Before marking a second-level tool `implemented`:
5. Public `BeautySDK` facade can exercise the behavior.
6. `BeautyExampleRenderer` or an equivalent SDK-only verification path records visible output when applicable.
```

Do not mark `脸型` rows `implemented` in Phase 26.

**Renderer deferral pattern** (`EXAMPLE_IMAGE_VALIDATION.md` lines 71-83):
```markdown
Face-shape, eye, nose, mouth, eyebrow, and 3D sculpt branches already have internal planning/provider tests, but full visual image output needs face detection plus geometry rendering integration.

Current status boundaries:

- `3D塑颜` remains `blocked-by-geometry-output`.
- `比例`, `脸型`, `眼睛`, `嘴唇`, and `鼻子` remain `partial`.
- `眉毛` and unpromoted branches remain `future`.
```

Phase 26 may document routing foundation, but saved-output updates belong to Phase 27.

## Shared Patterns

### Target Dependency Boundary

**Source:** `BeautySDK/Package.swift` lines 16-35
**Apply to:** `BeautyEngine.swift`, any internal routing helper, tests
```swift
.target(name: "BeautyDetection", dependencies: ["BeautyCore"]),
.target(
    name: "BeautyEffects",
    dependencies: ["BeautyCore", "BeautyDetection", "BeautyRender", "BeautyResources"]
),
.target(
    name: "BeautySDK",
    dependencies: ["BeautyCore", "BeautyDetection", "BeautyRender", "BeautyEffects", "BeautyResources"]
)
```

`BeautySDK` may orchestrate internal targets. `BeautyDemo` and `BeautyExampleRenderer` remain facade-only.

### Redacted Public Diagnostics

**Source:** `BeautyDetectionSummary.swift` lines 25-47; `BeautyResult.swift` lines 1-17
**Apply to:** Facade route, detector summary handling, tests, docs
```swift
public let reasons: [DetectionDegradationReason]
public let faceCount: Int
public let usedFaceCount: Int
public let detectionDurationMs: Double?
public let mappingDurationMs: Double?
```

Public evidence is limited to summary availability, reason codes, counts, warnings, and numeric metrics. No coordinates, points, bounding boxes, raw Vision objects, control points, image bytes, paths, or raw errors.

### Degrade Before Fail

**Source:** `VisionFaceDetector.swift` lines 74-86; `BeautyEffectResolver.swift` lines 269-280
**Apply to:** Geometry-triggered detection failures, no-face/partial/low-confidence paths
```swift
} catch let failure as Failure {
    selectionPolicy.reset()
    return VisionFaceDetectionResult(observations: [], summary: summary(for: failure))
} catch {
    selectionPolicy.reset()
    return VisionFaceDetectionResult(
        observations: [],
        summary: BeautyDetectionSummary(
            availability: .skipped,
            reasons: [.detectorUnavailable]
        )
    )
}
```

Then call resolver with `faceGeometry: nil` only when geometry-triggered detection was attempted and no usable face is available.

### Geometry Resolver Ownership

**Source:** `BeautyEffectResolver.swift` lines 144-267
**Apply to:** Facade routing and adapter
```swift
if hasFaceShapeValues {
    if staleGeometry {
        skippedDomains.insert(.faceShape)
        metrics["beauty.effects.skippedFaceDomains"] = 1
        appendStaleGeometryWarningIfNeeded()
    } else if let faceGeometry {
        let conflict = GeometryConflictResolver().resolve(strengths: strengths)
        strengths = conflict.strengths
        extraWarnings.append(contentsOf: conflict.warnings)
        metrics.merge(conflict.metrics) { _, new in new }
    }
}
```

Do not duplicate group-specific degradation in the facade. The facade should decide whether to detect/adapt; resolver should decide active/skipped domains.

### Test Redaction

**Source:** `BeautyEngineTests.swift` lines 151-158; `MissingLandmarkDegradationTests.swift` lines 246-254
**Apply to:** All new facade/detector/effects tests
```swift
for forbidden in ["landmark", "control point", "controlPoint", "bounding", "VNFaceObservation", "/private/var", "image bytes", "SIMD", "[0."] {
    XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
}
```

Keep tests strict enough to catch raw geometry leakage, but allow stable aggregate metric keys if names are intentionally safe.

### Active-Source Scan Pattern

**Source:** `QUALITY_SCORE.md` lines 240-260 and Phase 25 evidence style in lines 160-164
**Apply to:** Phase 26 verification plans
```bash
rg -n "VNFaceObservation|boundingBox|landmark|controlPoint|SIMD|/private/var|NSError|rawPresetJson|image bytes" \
  BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK \
  BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects
```

Planner should tune expected hits for internal source versus public surfaces. Public `BeautySDK` and `BeautyCore` hits are stricter; internal detection/effects may contain type names but must not leak through public result strings.

## No Analog Found

All inferred Phase 26 file roles have usable analogs. The only partial-match item is the likely new internal landmark-to-`FaceGeometry` adapter because no exact adapter file exists today; copy from `BeautyFaceObservation`, `FaceGeometry`, `CoordinateMapper`, and `BeautyEffectResolver` instead of inventing a public model.

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `BeautySDK/Sources/BeautySDK/*Geometry*Routing*.swift` or equivalent private extension | service/adapter | transform | No exact facade-to-`FaceGeometry` adapter exists yet; closest pieces are detector observations, coordinate mapper, and internal `FaceGeometry`. |

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, root docs, `docs/meitu-function-blueprint`
**Files scanned:** 54 SDK source/test files plus root/evidence docs from Phase 26 canonical references
**Pattern extraction date:** 2026-07-06
