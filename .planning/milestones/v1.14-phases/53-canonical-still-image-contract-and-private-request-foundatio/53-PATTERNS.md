# Phase 53: Canonical Still-Image Contract and Private Request Foundation - Pattern Map

**Mapped:** 2026-07-30
**Files analyzed:** 13 likely new/modified source and test files
**Analogs found:** 12 / 13 (the canonical raster has no exact production analog)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift` | model | file-I/O / transform | `BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift` | role-match only |
| `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift` | service | transform / file-I/O | `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | data-flow match |
| `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` | model | transform / request-response | same file's observed face/brow carriers | exact |
| `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | service | request-response / transform | same file's face/brow extraction and mapping | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | controller/facade | request-response | existing still-image and pixel-buffer overloads | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` | service/router | request-response | existing `resolveStillImageGeometry` | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` | test support/provider | event-driven | `SDKTestingFaceDetectionProvider` in the same file | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service | transform | existing `requiresFaceGeometry` admission query | exact role |
| `BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift` | test | file-I/O / transform | `BeautyEngineTests` input ceiling and bitmap helpers | role-match |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift` | test | request-response | `BeautyEngineGeometryFacadeTests.swift` | exact role |
| `BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift` | test | request-response / transform | `VisionFaceDetectorTests.swift`, `FaceObservationMappingTests.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | test | CRUD / serialization | existing exact-59 assertions in same file | exact |
| `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | tests | CRUD / transform | existing preset-count and rendered-byte regressions in same files | exact |

## Pattern Assignments

### `BeautyCanonicalStillImage.swift` and `BeautyStillImageCanonicalizer.swift`

**Analogs:** `BeautyInputMetadata.swift` for a small immutable carrier; `BeautyEngine.swift` for fail-fast input validation and typed errors. There is no existing owned, canonical RGBA8 production carrier, so use the Phase 53 research/Spike 013 algorithm rather than copying the existing device-RGB test helper.

**Access/import pattern** (`BeautyInputMetadata.swift` lines 1-16):

```swift
import Foundation
import ImageIO

public struct BeautyInputMetadata: Codable, Equatable, Sendable {
    public let orientation: CGImagePropertyOrientation
    public let isInputMirrored: Bool
```

The new raster must be `package`, immutable, non-`Codable`, and carry no diagnostic representation of its bytes. It belongs in `BeautyCore`, which cannot import `BeautyDetection`, `BeautyEffects`, or `BeautySDK`. The canonicalizer belongs in the facade target because it needs Core Image plus configured admission/ceiling ownership.

**Fail-fast/overflow pattern** (`BeautyEngine.swift` lines 127-137, 155-177):

```swift
let extent = image.extent
guard extent.isFiniteAndNonEmpty,
      dimensionsAreWithinPixelLimit(
        width: extent.width,
        height: extent.height,
        maximumPixelCount: maximumPixelCount
      )
else {
    throw BeautyError.invalidInput
}
```

The checked division at lines 155-177 is the existing overflow-safe pixel-count convention. Preserve ordering: decoded extent/pixel ceiling, resource/admission decision, local-only color/orientation checks, checked `rowBytes` and allocation, one render, alpha scan, then Vision. Use existing payload-free `.invalidInput` or `.unsupportedPixelFormat` unless a new case provides a distinct safe caller action (`BeautyError.swift` lines 3-15, 29-32, 62-65).

**Core canonicalization pattern** (Phase 53 research; no exact live analog):

```swift
let oriented = input.oriented(forExifOrientation: Int32(metadata.orientation.rawValue))
let bounds = oriented.extent.integral
let rowBytes = try checkedMultiply(width, 4)
var rgba = Data(count: try checkedMultiply(rowBytes, height))

rgba.withUnsafeMutableBytes { storage in
    context.render(
        oriented,
        toBitmap: storage.baseAddress!,
        rowBytes: rowBytes,
        bounds: bounds,
        format: .RGBA8,
        colorSpace: sRGB
    )
}
guard stride(from: 3, to: rgba.count, by: 4).allSatisfy({ rgba[$0] == 255 }) else {
    throw BeautyError.invalidInput
}
```

Also consume `isInputMirrored`, translate to zero origin, and emit normalized metadata (`.up`, not mirrored). Reuse a `CIContext` but never engine/static-cache request pixels. Do not copy `BeautyEngineTests.swift` lines 346-356: that helper deliberately uses `CGColorSpaceCreateDeviceRGB()` and is incompatible with the new explicit-sRGB contract.

### `BeautyFaceObservation.swift` and `VisionFaceDetector.swift`

**Analog:** observed face and eyebrow support in these same files.

**Private carrier/redaction pattern** (`BeautyFaceObservation.swift` lines 38-74, 82-107):

```swift
package struct BeautyObservedFaceSupport: Equatable, Sendable {
    package let contour: [CoordinatePoint]?
    package let medianLine: [CoordinatePoint]?
}

extension BeautyObservedFaceSupport: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String {
        "BeautyObservedFaceSupport(contourCount: \(contour?.count ?? 0), medianLineCount: \(medianLine?.count ?? 0))"
    }
}
```

Add `BeautyObservedLipSupport` with independently optional `outer` and `inner`, then append optional properties/defaulted initializer parameters to both `VisionDetectionObservation` and `BeautyFaceObservation`. Expose counts/availability only through description/debug/mirror; never stable IDs, points, bounds, confidence, pixels, or `Codable`.

**Local fail-closed mapping pattern** (`VisionFaceDetector.swift` lines 312-345, 451-480, 483-516):

```swift
let contour = mapFaceRegion(
    support.contour,
    maximumPointCount: 32,
    canonicalAxis: axes.right,
    in: visionBounds,
    with: mapper
)
let medianLine = mapFaceRegion(
    support.medianLine,
    maximumPointCount: 16,
    canonicalAxis: axes.down,
    in: visionBounds,
    with: mapper
)
observedFaceSupport = contour != nil || medianLine != nil
    ? BeautyObservedFaceSupport(contour: contour, medianLine: medianLine)
    : nil
```

Use a fixed pre-map point ceiling, finite closed-unit checks, and one `mapPoints` call per accepted lip region. A malformed inner region must not erase valid outer support or the containing face. Do not synthesize lips from face bounds.

**Exactly-one Vision request pattern** (`VisionFaceDetector.swift` lines 831-845):

```swift
let request = VNDetectFaceLandmarksRequest()
let handler = VNImageRequestHandler(
    ciImage: stillImage,
    orientation: input.metadata.orientation,
    options: [:]
)
try handler.perform([request])
return (request.results ?? []).map { observation in
    let payload = Self.landmarks(from: observation.landmarks)
```

Retain this single provider invocation. The admitted route supplies the canonical image and `.up`; it must not add a second feature-specific request or mapper. Existing `summarize` builds one `CoordinateMapper`, maps usable observations once, then applies `FaceSelectionPolicy` (`VisionFaceDetector.swift` lines 189-256).

### `BeautyEngine.swift`, `BeautyEngineGeometryDetection.swift`, and `BeautyEffectResolver.swift`

**Analog:** current public still-image orchestration (`BeautyEngine.swift` lines 86-111) and guarded geometry route (`BeautyEngineGeometryDetection.swift` lines 14-55).

```swift
try Self.validate(image: image, maximumPixelCount: configuration.maximumInputPixelCount)
let validated = try BeautySDKResources.validate(parameters: parameters)
let route = resolveStillImageGeometry(
    image: image,
    metadata: metadata,
    imageExtent: image.extent.size,
    parameters: validated
)
return BeautyResult(
    output: BeautyColorEffectPipeline.apply(
        to: image,
        plan: route.plan,
        selectedFaceObservation: route.selectedFaceObservation
    ),
    warnings: route.plan.warnings,
    metrics: route.plan.metrics,
    detectionSummary: route.detectionSummary
)
```

Branch only after cheap image/resource validation. The feature-neutral admission query must return false in production throughout Phase 53; an injected package/testing seam may force the active route. Put the current sequence in an explicitly legacy helper so the no-admission branch is byte-identical. Missing/no-face local support must still allow unrelated face-agnostic color effects.

**Realtime isolation pattern** (`BeautyEngine.swift` lines 47-64):

```swift
let validated = try BeautySDKResources.validate(parameters: parameters)
let plan = BeautyEffectResolver.resolve(parameters: validated)
return BeautyResult(
    output: try BeautyColorEffectPipeline.apply(to: pixelBuffer, plan: plan),
    warnings: plan.warnings,
    metrics: plan.metrics,
    detectionSummary: initialDetectionSummary
)
```

Leave this overload structurally free of canonicalizer, Vision, local request context, and future local providers. `reset()` may reset existing selection tracking but must acquire no canonical pixels/support cache (`BeautyEngine.swift` lines 114-117).

`BeautyStillImageRequestContext` should be a stack-local/package-only value owned by the facade route and contain the canonical raster plus only the current selected mapped observation. Do not store it on `BeautyEngine`.

### `BeautyEngineTestingSupport.swift`

**Analog:** `SDKTestingFaceDetectionProvider` (`BeautyEngineTestingSupport.swift` lines 58-105).

```swift
@_spi(Testing) public final class SDKTestingFaceDetectionProvider: @unchecked Sendable {
    private let lock = NSLock()
    private let fixtures: [SDKTestingFaceDetectionFixture]
    private var invocationCountValue = 0

    public var invocationCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return invocationCountValue
    }

    package func makeObservationProvider() -> VisionFaceDetector.ObservationProvider {
        { [self] _ in
            switch nextFixture() {
```

Use the same locked counter/fixture-sequence pattern for canonicalizer/admission hooks only if direct package tests cannot inject them. SPI may expose aggregate counters and opaque fixture choices, never raw lip coordinates or canonical bytes. Production ownership remains package-only.

### `BeautyCanonicalStillImageTests.swift`

**Analogs:** `BeautyEngineTests.swift` lines 170-203 for exact-limit/one-over/error-order tests and lines 346-357 for bitmap extraction shape (replace device RGB with explicit sRGB).

```swift
let engine = try BeautyEngine(configuration: BeautyConfiguration(maximumInputPixelCount: 4))
let invalidResource = BeautyParameters(filterId: "missing_filter", filterIntensity: 1)
XCTAssertThrowsError(try engine.process(image: image, orientation: .up, parameters: invalidResource)) { error in
    XCTAssertEqual(error as? BeautyError, .invalidInput)
}
```

Build tiny asymmetric in-memory images; add no portrait fixture. Table-drive all eight EXIF cases and mirror input, explicit sRGB/Display-P3, nonzero/fractional/empty/infinite extents, exact/over ceiling, checked-allocation overflow, gray/CMYK/nil/extended color, and partial/zero alpha. Assert invalid inputs stop before detector/provider counters. Byte identity is appropriate for lossless orientation variants, not for equivalent profile encodings.

### `StillImageRequestSupportTests.swift`

**Analog:** `VisionFaceDetectorTests.swift` lines 250-336 and `FaceObservationMappingTests.swift` lines 388-475.

```swift
let first = detector.detect(metadata: metadata())
let second = detector.detect(metadata: metadata())

XCTAssertEqual(provider.invocationCount, 2)
XCTAssertNotNil(first.observations.first?.observedFaceSupport?.contour)
XCTAssertNil(second.observations.first?.observedFaceSupport)
```

Copy the valid-invalid-valid/local-failure structure: oversized/malformed one-region support becomes nil while its peer remains mapped. Copy the independent-value concurrency oracle using `withTaskGroup`, but do not claim same-engine concurrent safety. Add exact aggregate-only `description`, `String(reflecting:)`, `dump`, and `Mirror` label allowlists following `VisionFaceDetectorTests.swift` lines 338-417.

### `BeautyEngineLocalRetouchFoundationTests.swift`

**Analog:** facade calls in `BeautyEngineGeometryFacadeTests.swift` and the pixel-limit/error-order tests above.

Exercise both existing public image overloads, not a parallel facade. With test admission enabled, assert one canonicalization, one observation-provider call, one mapping route, and identical canonical object identity at detector/render seams. Then assert default/no-local calls take the legacy route and preserve bytes, warnings, metrics, and summary. Run the same parameters through the pixel-buffer overload and assert all local counters remain zero; reset must add no local retained state.

### Compatibility tests (`BeautyParametersTests`, `BeautyResourceCatalogTests`, `BeautyRendererOutputRegressionTests`)

**Exact-inventory pattern** (`BeautyParametersTests.swift` lines 115-124, 161-187):

```swift
let labels = Mirror(reflecting: sourceStyle).children.compactMap(\.label)
XCTAssertEqual(labels.count, 59)

let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
XCTAssertEqual(object.count, 59)
XCTAssertEqual(Set(object.keys), Set(Mirror(reflecting: parameters).children.compactMap(\.label)))
```

Keep the count exactly 59 in Phase 53 and add a reusable no-candidate assertion covering stored properties, coding keys, preset keys, resolver/provider/renderer cases, and source defaults. `BeautyResourceCatalogTests.swift` lines 30-37 establishes the exact five-preset pattern. `BeautyRendererOutputRegressionTests.swift` lines 547-694 establishes rendering through the public facade and byte comparison before watermarking; extend it with no-local byte neutrality rather than creating a private rendering entry.

## Shared Patterns

### Access Control and Dependency Direction

- Preserve `BeautySDK -> BeautyEffects -> BeautyDetection -> BeautyCore`.
- `BeautyCore` canonical types import only lower/platform frameworks; Detection may consume Core types; Detection must never import Effects or BeautySDK.
- Raw support and canonical pixels are `package`, immutable, non-`Codable`, and request-local. Host apps continue importing only `BeautySDK`.
- `@_spi(Testing)` is limited to opaque fixture selection and aggregate invocation counters. Do not expose raw support or bytes through SPI.

### Failure and Privacy

- Input contract failures throw fixed typed `BeautyError` values before Vision; missing face/region support degrades via `BeautyDetectionSummary`/warnings.
- Descriptions, mirrors, metrics, and errors expose allowlisted counts/reasons only. Never expose metadata, paths, dimensions, IDs, coordinates, masks, pupil/lip data, or image bytes.
- Local region mapping fails independently; no stale fallback, global failure, or cross-request cache.

### Compatibility Boundary

- Production admission remains false and the legacy still-image path remains untouched for all shipped parameters.
- No candidate public field, coding key, preset key, provider, renderer case, or inert route is allowed in Phase 53.
- Pixel-buffer/realtime routes cannot reference canonicalizer/request-context types.
- Do not claim encoded-byte/gain-map validation from an already-decoded `CIImage`, cross-profile topology identity, HDR/transparent support, same-engine concurrency, cancellation, or performance readiness.

## No Exact Analog Found

| File | Role | Data Flow | Reason / Planner Source |
|---|---|---|---|
| `BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift` | model | file-I/O / transform | No live production type owns one RGBA8 allocation and multiple immutable views. Use the concrete Core Image render pattern in `53-RESEARCH.md` and the `spike-findings-beauty/references/still-image-integration.md` normalize-once contract; do not copy device-RGB helpers. |

## Metadata

**Analog search scope:** live `BeautySDK/Sources/**` and `BeautySDK/Tests/**`; stale `.planning/codebase` maps were not used.

**Strong analogs read:** `BeautyEngine.swift`, `BeautyEngineGeometryDetection.swift`, `BeautyFaceObservation.swift`, `VisionFaceDetector.swift`, `BeautyEngineTestingSupport.swift`, plus focused live test ranges.

**Pattern extraction date:** 2026-07-30
