# Phase 27: Geometry Render Output and Verification Harness - Pattern Map

**Mapped:** 2026-07-07
**Files analyzed:** 12
**Analogs found:** 12 / 12

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | utility/executable | file-I/O, request-response | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | test | file-I/O, transform | `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | facade/service | request-response, transform | `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` | facade/service | request-response, transform | `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` | service/utility | transform | `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | service/utility | transform | `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | test | request-response, transform | `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | exact |
| `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` | utility | file-I/O, batch | `.planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py` | exact |
| `.planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md` | evidence/doc | batch | `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` | exact |

## Pattern Assignments

### `BeautySDK/Sources/BeautyExampleRenderer/main.swift` (utility/executable, file-I/O)

**Analog:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift`

**Imports pattern** (lines 1-5):
```swift
import AppKit
import CoreImage
import Foundation
import ImageIO
import BeautySDK
```

**Case matrix pattern** (lines 44-95): append the single combined face-shape case to the existing `cases` array. Keep public `BeautySDK` only; do not import internal targets.
```swift
let cases = [
    RenderCase(
        id: "skinSmoothing_0p50",
        displayName: "skinSmoothing 0.50",
        parameters: BeautyParameters(skinSmoothing: 0.50)
    ),
    ...
    RenderCase(
        id: "skinCombo_0p50",
        displayName: "skin combo 0.50",
        parameters: BeautyParameters(
            skinSmoothing: 0.50,
            skinWhitening: 0.50,
            skinRosy: 0.35,
            skinSharpen: 0.25
        )
    )
]
```

**Render/write pattern** (lines 119-149): keep `BeautyEngine.processResult(image:metadata:parameters:)`, watermarked PNG naming, and ignored output directory behavior.
```swift
let engine = try BeautyEngine(configuration: .default)
let context = CIContext(options: [
    .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
    .outputColorSpace: CGColorSpaceCreateDeviceRGB()
])

for imageURL in imageURLs {
    guard let inputImage = CIImage(contentsOf: imageURL, options: [.applyOrientationProperty: true]) else {
        throw ExampleRendererError.imageLoadFailed(imageURL.path)
    }

    for renderCase in renderCases {
        let result = try engine.processResult(
            image: inputImage,
            metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
            parameters: renderCase.parameters
        )
        guard let cgImage = context.createCGImage(result.output, from: result.output.extent) else {
            throw ExampleRendererError.renderFailed(imageURL.path)
        }
        ...
        try png.write(to: destination, options: .atomic)
    }
}
```

### `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` (test, file-I/O/transform)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`

**Imports and facade-only scan pattern** (lines 1-4, 30-45):
```swift
import CoreImage
import ImageIO
import XCTest
import BeautySDK

XCTAssertTrue(source.contains("import BeautySDK"), "BeautyExampleRenderer/main.swift should import BeautySDK")

for forbiddenTarget in ["BeautyCore", "BeautyDetection", "BeautyEffects", "BeautyRender", "BeautyResources"] {
    XCTAssertFalse(
        source.contains("import \(forbiddenTarget)"),
        "BeautyExampleRenderer/main.swift should not import \(forbiddenTarget)"
    )
}
```

**Renderer inventory pattern** (lines 10-20, 30-37): add the new geometry case ID in declaration order.
```swift
private static let expectedRendererCaseIDs = [
    "skinSmoothing_0p50",
    ...
    "skinCombo_0p50"
]

XCTAssertEqual(
    rendererCaseIDs(in: source),
    Self.expectedRendererCaseIDs,
    "BeautyExampleRenderer/main.swift renderer case IDs changed"
)
```

**Pre-watermark byte comparison pattern** (lines 48-66, 110-139): reuse this for geometry-vs-baseline output-delta tests, rendering both outputs through the same DeviceRGB RGBA8 context.
```swift
XCTAssertEqual(result.output.extent, input.extent, "\(fixtureName) changed extent before watermark")
XCTAssertEqual(
    try renderedRGBABytes(from: result.output, named: fixtureName),
    try renderedRGBABytes(from: input, named: fixtureName),
    "\(fixtureName) changed rendered RGBA bytes before watermark"
)
```

### `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` (facade/service, request-response)

**Analog:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`

**Imports pattern** (lines 1-8): facade can import internal targets; public executable cannot.
```swift
import CoreGraphics
import CoreImage
import CoreVideo
import Foundation
import ImageIO
import BeautyCore
import BeautyDetection
import BeautyEffects
```

**Still-image facade pattern** (lines 83-103): keep validation, resource validation, geometry route resolution, and `BeautyResult` construction. Phase 27 should change the output call to the geometry-capable internal render entry while preserving warnings, metrics, and summary wiring.
```swift
public func processResult(
    image: CIImage,
    metadata: BeautyInputMetadata,
    parameters: BeautyParameters
) throws -> BeautyResult<CIImage> {
    guard image.extent.isFiniteAndNonEmpty else {
        throw BeautyError.invalidInput
    }
    let validated = try BeautySDKResources.validate(parameters: parameters)
    let route = resolveStillImageGeometry(
        metadata: metadata,
        imageExtent: image.extent.size,
        parameters: validated
    )
    return BeautyResult(
        output: BeautyColorEffectPipeline.apply(to: image, plan: route.plan),
        warnings: route.plan.warnings,
        metrics: route.plan.metrics,
        detectionSummary: route.detectionSummary
    )
}
```

### `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` (facade/service, request-response)

**Analog:** `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`

**Route model pattern** (lines 5-8): extend narrowly if selected face must be carried to rendering; keep route internal.
```swift
struct BeautyEngineGeometryRoute {
    let plan: BeautyEffectPlan
    let detectionSummary: BeautyDetectionSummary
}
```

**Detection gating and degradation pattern** (lines 16-47): preserve no-geometry `.notRun`, disabled tracking, selected-face routing, and redacted metrics.
```swift
guard BeautyEffectResolver.requiresFaceGeometry(parameters: parameters) else {
    return BeautyEngineGeometryRoute(
        plan: BeautyEffectResolver.resolve(parameters: parameters),
        detectionSummary: initialDetectionSummary
    )
}

guard configuration.enableFaceTracking else {
    let plan = BeautyEffectResolver.resolve(
        parameters: parameters,
        selectedFaceObservation: nil
    )
    return BeautyEngineGeometryRoute(
        plan: withDetectionMetrics(plan, summary: .disabled, geometryRequired: true),
        detectionSummary: .disabled
    )
}
```

**Redacted metric pattern** (lines 49-65):
```swift
metrics["beauty.detection.geometryRequired"] = geometryRequired ? 1 : 0
metrics["beauty.detection.faceCount"] = Double(summary.faceCount)
metrics["beauty.detection.usedFaceCount"] = Double(summary.usedFaceCount)
return BeautyEffectPlan(
    activeDomains: plan.activeDomains,
    skippedDomains: plan.skippedDomains,
    warnings: plan.warnings,
    metrics: metrics,
    effectiveStrengths: plan.effectiveStrengths
)
```

### `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` (service/utility, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`

**Public wrapper/internal overload pattern** (lines 95-100): add package/internal geometry-observation overloads beside existing public image entry; keep raw `FaceGeometry` private to `BeautyEffects`.
```swift
public static func apply(to image: CIImage, plan: BeautyEffectPlan) -> CIImage {
    apply(to: image, plan: plan, face: nil)
}

static func apply(to image: CIImage, plan: BeautyEffectPlan, face: FaceGeometry?) -> CIImage {
    guard plan.hasVisibleColorOutput else {
        return image.cropped(to: image.extent)
    }
```

**Same-dimension crop pattern** (lines 139-142, 253-277): every image transform returns `cropped(to: image.extent)`.
```swift
output = applyLipColor(to: output, plan: plan, face: face)

return output.cropped(to: image.extent)
```

**Geometry-aware masking pattern** (lines 244-277): use internal face geometry only inside `BeautyEffects`, and compose over the original image.
```swift
private static func applyLipColor(to image: CIImage, plan: BeautyEffectPlan, face: FaceGeometry?) -> CIImage {
    guard plan.activeDomains.contains(.lipColor),
          plan.effectiveStrengths.lipColor > 0,
          let face,
          let center = LandmarkGeometryHelper.center(of: face.outerLips)
    else {
        return image
    }
    ...
    return tinted.cropped(to: rect).composited(over: image).cropped(to: extent)
}
```

### `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` (service/utility, transform)

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

**Deterministic MVP proxy pattern** (lines 18-34): if Phase 27 remains proxy-based, copy this deterministic non-identity pattern rather than adding subjective visual claims.
```swift
/// MVP fixture proxy until the production warp pass consumes control points directly.
static func applyMVPProxy(toBGRA bytes: [UInt8], plan: BeautyEffectPlan, face: FaceGeometry) -> [UInt8] {
    let points = controlPoints(for: plan, face: face)
    guard !points.isEmpty else {
        return bytes
    }

    let lift = UInt8(min(12, max(1, points.count)))
    var output = bytes
    ...
    return output
}
```

### `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` (test, request-response/transform)

**Analog:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`

**SPI fixture seam pattern** (lines 1-4, 6-33): use this for focused tests or a narrow fallback verifier; do not make it the primary renderer proof.
```swift
import CoreImage
import XCTest
@_spi(Testing) import BeautySDK

let provider = SDKTestingFaceDetectionProvider([.usableFace])
let engine = try BeautyEngine(faceDetectionProvider: provider)
let result = try engine.processResult(
    image: Self.image,
    metadata: BeautyInputMetadata(orientation: .up, source: .photo),
    parameters: BeautyParameters(
        brightness: 0.2,
        faceSlim: 0.4,
        eyeSize: 0.4,
        noseSlim: 0.4,
        mouthSize: 0.4,
        lipColor: 0.4
    )
)
```

**No-geometry detection skip pattern** (lines 35-56):
```swift
for parameters in inputs {
    let result = try engine.processResult(
        image: Self.image,
        metadata: BeautyInputMetadata(orientation: .up, source: .photo),
        parameters: parameters
    )
    XCTAssertEqual(result.detectionSummary?.availability, .notRun)
    XCTAssertNil(result.metrics["beauty.detection.geometryRequired"])
}

XCTAssertEqual(provider.invocationCount, 0)
```

**Degradation matrix pattern** (lines 79-107): use one table-driven test for no-face, low-confidence, missing landmarks, detector unavailable, and timeout.
```swift
let cases: [(SDKTestingFaceDetectionFixture, DetectionAvailability, DetectionDegradationReason)] = [
    (.noFace, .noFace, .noFaceDetected),
    (.lowConfidence, .lowConfidence, .lowConfidenceFace),
    (.missingLandmarks, .partial, .missingLandmarks),
    (.detectorUnavailable, .skipped, .detectorUnavailable),
    (.detectionTimedOut, .skipped, .detectionTimedOut)
]
```

**Raw-leak assertion pattern** (lines 126-154): apply to new facade output tests and any fallback evidence tests.
```swift
for forbidden in [
    "VNFaceObservation",
    "boundingBox",
    "controlPoint",
    "/private/var",
    "NSError",
    "AVError",
    "rawPresetJson",
    "raw JSON",
    "image bytes",
    "landmarks=",
    "landmarkCoordinates",
    "rawLandmark",
    "SIMD"
] {
    XCTAssertFalse(metadata.contains(forbidden), "Unexpected sensitive term: \(forbidden)", file: file, line: line)
}
```

### `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` (test, transform)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`

**Imports pattern** (lines 1-4):
```swift
import XCTest
import BeautyCore
import BeautyDetection
@testable import BeautyEffects
```

**Missing/stale/reused degradation pattern** (lines 69-115):
```swift
let noFace = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: nil)
XCTAssertTrue(noFace.activeDomains.contains(.color))
XCTAssertTrue(noFace.activeDomains.contains(.filter))
XCTAssertFalse(noFace.activeDomains.contains(.faceShape))
XCTAssertTrue(noFace.skippedDomains.isSuperset(of: [.faceShape, .eyes, .nose, .mouth, .lipColor]))
XCTAssertTrue(noFace.warnings.contains { $0.code == "face_effects_skipped_no_face" })

let stale = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .stale)
XCTAssertFalse(stale.activeDomains.contains(.eyes))
XCTAssertFalse(stale.activeDomains.contains(.nose))
XCTAssertTrue(stale.warnings.contains { $0.code == "geometry_stale_skipped" })

let reused = BeautyEffectResolver.resolve(parameters: parameters, faceGeometry: .reused)
XCTAssertLessThan(reused.effectiveStrengths.eyeSize, BeautySafetyCaps.eyeSize)
XCTAssertLessThan(reused.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
XCTAssertTrue(reused.warnings.contains { $0.code == "geometry_stale_reduced" })
```

**Selected-face missing group pattern** (lines 247-294): use `selectedFaceObservation` when testing the public-facade route into effects planning.
```swift
let missingEye = BeautyEffectResolver.resolve(
    parameters: parameters,
    selectedFaceObservation: .fixture(missing: [.leftEye])
)
XCTAssertFalse(missingEye.activeDomains.contains(.eyes))
XCTAssertTrue(missingEye.activeDomains.contains(.nose))
XCTAssertTrue(missingEye.warnings.contains { $0.code == "eye_inputs_missing" })
```

### `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` (test, transform)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift`

**Combined strength cap/weaken pattern** (lines 43-84): reuse for GEO-04 combined-strength evidence.
```swift
let plan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(
        skinSmoothing: 1,
        skinWhitening: 1,
        skinRosy: 1,
        skinSharpen: 1,
        brightness: 0.2,
        faceSlim: 1,
        faceSmall: 1,
        faceVShape: 1,
        jawSlim: 1,
        chinLength: 1,
        ...
    ),
    faceGeometry: .fixture
)

XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
XCTAssertTrue(plan.warnings.contains { $0.code == "combined_geometry_weakened" })
XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
XCTAssertLessThan(plan.effectiveStrengths.faceSlim, BeautySafetyCaps.faceSlim)
```

**Visible output fixture pattern** (lines 132-152): for image-output tests, compare rendered bytes after applying the same pipeline with a fixture face.
```swift
let inputBytes = rgbaBytes(from: image)
...
let output = BeautyColorEffectPipeline.apply(to: image, plan: plan, face: .fixture)
XCTAssertNotEqual(rgbaBytes(from: output), inputBytes, presetID)
```

### `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` (test, transform)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift`

**Face-shape combined resolver pattern** (lines 6-25, 64-74):
```swift
func testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum() {
    let independent = strengths(
        faceSlim: 1,
        faceSmall: 1,
        faceVShape: 1,
        jawSlim: 1,
        chinLength: 1,
        ...
    )
    let resolved = GeometryConflictResolver().resolve(strengths: independent)

    XCTAssertLessThan(resolved.strengths.geometryTotal, independent.geometryTotal)
    XCTAssertTrue(resolved.warnings.contains { $0.code == "combined_geometry_weakened" })
}
```

**Deterministic geometry output pattern** (lines 76-102):
```swift
let points = BeautyGeometryEffectPipeline.controlPoints(for: plan, face: .fixture)

XCTAssertFalse(points.isEmpty)
XCTAssertEqual(points, BeautyGeometryEffectPipeline.controlPoints(for: plan, face: .fixture))

let output = BeautyGeometryEffectPipeline.applyMVPProxy(toBGRA: input, plan: plan, face: .fixture)

XCTAssertNotEqual(output, input)
XCTAssertEqual(output, BeautyGeometryEffectPipeline.applyMVPProxy(toBGRA: input, plan: plan, face: .fixture))
```

### `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` (utility, file-I/O/batch)

**Analog:** `.planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py`

**Imports/no-dependency pattern** (lines 1-9):
```python
#!/usr/bin/env python3
"""Validate Phase 24 BeautyExampleRenderer generated PNG invariants."""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path
```

**PNG dimension parser pattern** (lines 37-55):
```python
def read_png_dimensions(path: Path, label: str) -> tuple[int, int]:
    try:
        with path.open("rb") as handle:
            signature = handle.read(8)
            if signature != b"\x89PNG\r\n\x1a\n":
                raise RendererOutputError(f"{label}: not a PNG")
            ...
            return struct.unpack(">II", ihdr[:8])
    except OSError:
        raise RendererOutputError(f"{label}: unreadable") from None
```

**Invariant loop pattern** (lines 81-139): mirror this and add geometry-vs-baseline non-identity checks for the new combined face-shape output.
```python
for fixture_name in FIXTURE_NAMES:
    fixture_path = input_dir / fixture_name
    ...
    for case_id in RENDERER_CASE_IDS:
        output_name = f"{fixture_path.stem}__{case_id}.png"
        output_path = output_dir / output_name
        ...
        if output_dimensions != fixture_dimensions:
            failures.append(
                f"{output_label}: dimensions {output_dimensions[0]}x{output_dimensions[1]} "
                f"!= {fixture_name} {fixture_dimensions[0]}x{fixture_dimensions[1]}"
            )
            continue

        if output_bytes == fixture_bytes:
            failures.append(f"{output_label}: byte-identical to {fixture_name}")
            continue
```

**Pass/fail output pattern** (lines 139-152): report counts and dimensions only, not hashes or raw pixel data.
```python
expected = len(FIXTURE_NAMES) * len(RENDERER_CASE_IDS)
if failures:
    print(f"renderer output check failed: {checked}/{expected} passed")
    for failure in failures:
        print(f"FAIL: {failure}")
    return 1

print(f"renderer output check passed: {checked}/{expected} outputs")
```

### `.planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md` (evidence/doc, batch)

**Analog:** `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md`

**Frontmatter and non-claims pattern** (lines 1-10, 25-31):
```markdown
---
phase: 24-renderer-output-regression-hardening
status: draft
updated: 2026-07-02
requirements:
  - RENDER-01
  - RENDER-02
  - RENDER-03
  - RENDER-04
---

## Non-Claims

- Phase 24 evidence covers current skin, color, and filter renderer outputs only.
- Phase 24 does not assert market visual quality, naturalness, device coverage, reference-app parity, or shipping readiness.
- Phase 24 does not implement geometry saved-output and does not mark geometry-heavy branches visually complete.
- Generated PNGs remain local ignored artifacts under `example-images/out/`; Markdown evidence and helper commands are the repository evidence.
```

**Command evidence table pattern** (lines 32-44): record exact commands, counts, dimensions, helper result, ignore policy, import scan, raw-leak scan, and no-overclaim scan.
```markdown
| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Focused renderer regression tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Executed 2 tests, 0 failures. | RENDER-01, RENDER-02 |
| Renderer all-case run | passed | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 45 PNG outputs: 5 fixtures times 9 current renderer cases. | RENDER-03 |
```

**Evidence allowlist pattern** (lines 93-98): apply verbatim in spirit to Phase 27, adding redacted geometry metric names only.
```markdown
This artifact is limited to relative paths, fixture names, case IDs, counts, dimensions, command status, file-size/change status, factual watermark notes, blocker class, impact, next step, and rerun protocol.

It does not include raw pixel payloads, machine-local absolute paths, facial measurement payloads, unredacted framework diagnostics, service-transfer claims, or committed PNG baselines.
```

## Shared Patterns

### Public Facade Boundary
**Source:** `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` lines 38-45 and `BeautySDK/Sources/BeautyExampleRenderer/main.swift` lines 1-5  
**Apply to:** `BeautyExampleRenderer`, renderer inventory tests, renderer evidence.

The executable imports `BeautySDK` only. Tests should keep scanning for forbidden internal target imports.

### Redacted Geometry Metrics and Warnings
**Source:** `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` lines 49-65; `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` lines 126-154  
**Apply to:** facade changes, helper/evidence summaries, fallback verifier, degradation tests.

Use aggregate keys such as `beauty.detection.geometryRequired`, `beauty.detection.faceCount`, `beauty.detection.usedFaceCount`, and `beauty.effects.geometryPointCount`. Do not emit coordinates, landmarks, bounding boxes, control points, Vision objects, raw framework errors, local paths, raw JSON, or image bytes.

### Same-Dimension Output
**Source:** `BeautyColorEffectPipeline.swift` lines 139-142 and `BeautyRendererOutputRegressionTests.swift` lines 60-65  
**Apply to:** geometry render entry, facade output-delta tests, Python helper.

Every transform must crop back to the input extent, and tests/helpers must assert output dimensions match input dimensions.

### Deterministic Non-Identity
**Source:** `GeometryConflictResolverTests.swift` lines 88-102 and `check_renderer_outputs.py` lines 132-137  
**Apply to:** geometry output-delta tests and Phase 27 helper.

Geometry evidence should prove output differs from the no-geometry baseline and remains deterministic. Do not use brittle committed hashes.

### Degradation Coverage
**Source:** `BeautyEngineGeometryFacadeTests.swift` lines 79-107; `MissingLandmarkDegradationTests.swift` lines 69-115; `CombinedEffectSafetyTests.swift` lines 43-84  
**Apply to:** GEO-04 tests and evidence.

Cover no-face, missing-landmark, stale/reused, and combined-strength paths with focused XCTest plus Markdown summaries. Renderer PNG evidence is required for happy/no-face paths; other degradation paths may stay test/helper evidence.

### Evidence Wording
**Source:** `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` lines 25-31 and 93-98  
**Apply to:** `27-GEOMETRY-RENDERER-EVIDENCE.md`, `27-VERIFICATION.md`, root/planning closeout docs.

Record commands, output counts, dimensions, helper results, ignored-output status, and factual representative notes only. Avoid commercial quality, naturalness, release readiness, broad device parity, full Meitu parity, and `SHAPE_FEATURE_LEDGER.md` implementation-status promotion.

## No Analog Found

None. The phase can copy from existing renderer, facade, effects, helper, degradation-test, and evidence patterns.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `.planning/phases/24-renderer-output-regression-hardening`, root contract docs, `docs/meitu-function-blueprint`  
**Files scanned:** 102 source/test/helper files in the primary SDK/helper scope, plus Phase 27 context/research/validation and selected root/docs contracts  
**Pattern extraction date:** 2026-07-07
