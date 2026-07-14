# Phase 19: Beauty Shaping Core Modules - Pattern Map

**Mapped:** 2026-06-29
**Files analyzed:** 19
**Analogs found:** 19 / 19

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` | role-match |
| `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service | request-response | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | config | transform | `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | exact |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | service | transform | `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | role-match |
| `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | role-match |
| `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` | test | transform | `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | role-match |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | test | transform | `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | role-match |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | test | event-driven | `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | test | request-response | `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | role-match |
| `docs/meitu-function-blueprint/features/beauty-shaping/**/*.md` | config | batch | `docs/meitu-function-blueprint/features/beauty-shaping/README.md` | exact |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | config | batch | `docs/meitu-function-blueprint/features/beauty-shaping/README.md` | role-match |
| `docs/meitu-function-blueprint/MODULES.md` | config | batch | `docs/meitu-function-blueprint/features/beauty-shaping/README.md` | role-match |

## Pattern Assignments

### `BeautySDK/Sources/BeautyEffects/Warp/*WarpProvider.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift`

**Provider entry pattern** (lines 1-10):
```swift
struct EyeWarpProvider: WarpControlPointProvider {
    func makeControlPoints(
        face: FaceGeometry,
        strengths: BeautyEffectiveStrengths
    ) -> WarpControlPointResult {
        guard let leftCenter = LandmarkGeometryHelper.center(of: face.leftEye),
              let rightCenter = LandmarkGeometryHelper.center(of: face.rightEye)
        else {
            return WarpControlPointResult(points: [], skipReason: "eye_inputs_missing")
        }
```

**Strength-gated transform pattern** (lines 12-43):
```swift
var points: [WarpControlPoint] = []

if strengths.eyeSize > 0 {
    points.append(contentsOf: sizePoints(
        centers: [leftCenter, rightCenter],
        face: face,
        strength: strengths.eyeSize
    ))
}
```

**Clamp/safety pattern** (lines 135-148):
```swift
private func makePoint(
    source: SIMD2<Float>,
    target: SIMD2<Float>,
    radius: Float,
    strength: Float
) -> WarpControlPoint {
    WarpControlPoint(
        source: LandmarkGeometryHelper.clamp(source),
        target: LandmarkGeometryHelper.clamp(target),
        radius: min(max(radius, 0.035), 0.24),
        strength: strength,
        falloff: 2
    )
}
```

**Mouth signed-control pattern** (source: `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift`, lines 12-24, 32-42):
```swift
if abs(strengths.mouthSize) > Float.ulpOfOne {
    points.append(contentsOf: sizePoints(face: face, center: center, strength: strengths.mouthSize))
}

let target = strength < 0 ?
    LandmarkGeometryHelper.move(source, toward: center, by: displacement) :
    move(source, awayFrom: center, by: displacement)
```

**Apply to:** Provider hardening for face/chin/eye/nose/mouth only. Do not add eyebrow or 3D sculpt providers in Phase 19.

---

### `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` (service, request-response)

**Analog:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`

**Imports and public/internal entrypoints** (lines 1-10):
```swift
import BeautyCore

public enum BeautyEffectResolver {
    public static func resolve(parameters: BeautyParameters) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: nil, treatsMissingFaceAsNoFace: false)
    }

    static func resolve(parameters: BeautyParameters, faceGeometry: FaceGeometry?) -> BeautyEffectPlan {
        resolve(parameters: parameters, faceGeometry: faceGeometry, treatsMissingFaceAsNoFace: true)
    }
```

**Existing public shaping strength map** (lines 40-59):
```swift
strengths.faceSlim = capUnit(normalized.faceSlim, cap: BeautySafetyCaps.faceSlim, cappedCount: &cappedCount)
strengths.faceSmall = capUnit(normalized.faceSmall, cap: BeautySafetyCaps.faceSmall, cappedCount: &cappedCount)
strengths.faceVShape = capUnit(normalized.faceVShape, cap: BeautySafetyCaps.faceVShape, cappedCount: &cappedCount)
strengths.jawSlim = capUnit(normalized.jawSlim, cap: BeautySafetyCaps.jawSlim, cappedCount: &cappedCount)
strengths.chinLength = capSigned(normalized.chinLength, cap: BeautySafetyCaps.chinLength, cappedCount: &cappedCount)
```

**Domain degradation pattern** (lines 175-199):
```swift
if anyNonZero(strengths.eyeSize, strengths.eyeDistance, strengths.eyeYPosition, strengths.eyeTailLift) {
    if staleGeometry {
        skippedDomains.insert(.eyes)
        metrics["beauty.effects.skippedEyeDomains"] = 1
        appendStaleGeometryWarningIfNeeded()
    } else if let faceGeometry {
        let result = EyeWarpProvider().makeControlPoints(face: faceGeometry, strengths: strengths)
        if result.points.isEmpty {
            skippedDomains.insert(.eyes)
            metrics["beauty.effects.skippedEyeDomains"] = 1
            extraWarnings.append(Self.eyeSkippedWarning)
        } else {
            activeDomains.insert(.eyes)
            geometryPointCount += result.points.count
        }
```

**Redacted metrics/warnings pattern** (lines 277-297, 346-386):
```swift
metrics["beauty.effects.activeCount"] = Double(activeDomains.count)
metrics["beauty.effects.cappedCount"] = Double(cappedCount)
if geometryPointCount > 0 {
    metrics["beauty.effects.geometryPointCount"] = Double(geometryPointCount)
}

private static var eyeSkippedWarning: BeautyValidationWarning {
    BeautyValidationWarning(
        code: "eye_inputs_missing",
        message: "Eye geometry was skipped because required eye inputs were unavailable."
    )
}
```

**Apply to:** Resolver hardening, stale/reused/missing-face behavior, geometry point count evidence, and redaction tests. Do not change the facade entrypoint to inject public face geometry in Phase 19.

---

### `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift`

**Imports/result pattern** (lines 1-7):
```swift
import BeautyCore

struct GeometryConflictResolution: Equatable, Sendable {
    let strengths: BeautyEffectiveStrengths
    let warnings: [BeautyValidationWarning]
    let metrics: [String: Double]
}
```

**Combined weakening pattern** (lines 16-53):
```swift
func resolve(strengths: BeautyEffectiveStrengths) -> GeometryConflictResolution {
    let total = geometryTotal(strengths)
    guard total > totalThreshold else {
        return GeometryConflictResolution(strengths: strengths, warnings: [], metrics: [:])
    }

    let scale = totalThreshold / total
    var weakened = strengths
    weakened.faceSlim *= scale
    weakened.faceSmall *= scale
    weakened.faceVShape *= scale
```

**Redacted metric pattern** (lines 41-52):
```swift
return GeometryConflictResolution(
    strengths: weakened,
    warnings: [
        BeautyValidationWarning(
            code: "combined_geometry_weakened",
            message: "Combined geometry strength was reduced for natural output."
        )
    ],
    metrics: [
        "beauty.effects.weakenedCount": Double(nonZeroFaceShapeFieldCount(strengths)),
        "beauty.effects.geometryStrengthScale": Double(scale)
    ]
)
```

**Apply to:** Any Phase 19 combined shaping behavior. Prefer this resolver over per-provider ad hoc weakening.

---

### `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` (service, transform)

**Analog:** `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`

**Internal aggregation pattern** (lines 1-16):
```swift
enum BeautyGeometryEffectPipeline {
    static func controlPoints(for plan: BeautyEffectPlan, face: FaceGeometry) -> [WarpControlPoint] {
        guard !plan.activeDomains.isDisjoint(with: [.faceShape, .eyes, .nose, .mouth]) else {
            return []
        }

        return controlPoints(for: plan.effectiveStrengths, face: face)
    }

    static func controlPoints(for strengths: BeautyEffectiveStrengths, face: FaceGeometry) -> [WarpControlPoint] {
        FaceShapeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            ChinWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            EyeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            NoseWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
            MouthWarpProvider().makeControlPoints(face: face, strengths: strengths).points
```

**MVP proxy evidence boundary** (lines 18-33):
```swift
/// MVP fixture proxy until the production warp pass consumes control points directly.
static func applyMVPProxy(toBGRA bytes: [UInt8], plan: BeautyEffectPlan, face: FaceGeometry) -> [UInt8] {
    let points = controlPoints(for: plan, face: face)
    guard !points.isEmpty else {
        return bytes
    }
```

**Apply to:** Internal provider/control-point evidence only. This pattern does not justify adding `BeautyExampleRenderer` geometry cases or claiming saved-image completion.

---

### `BeautySDK/Tests/BeautyEffectsTests/*WarpProviderTests.swift` (test, transform)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift`

**Imports/test target pattern** (lines 1-5):
```swift
import XCTest
import BeautyCore
@testable import BeautyEffects

final class FaceShapeWarpProviderTests: XCTestCase {
```

**Provider assertion pattern** (lines 6-25):
```swift
func testFaceSlimCreatesSymmetricCheekPointsMovingInward() {
    let result = FaceShapeWarpProvider().makeControlPoints(
        face: .fixture,
        strengths: strengths(faceSlim: 1)
    )

    XCTAssertNil(result.skipReason)
    XCTAssertEqual(result.points.count, 2)
```

**Fixture pattern** (lines 100-138):
```swift
extension FaceGeometry {
    static let fixture = FaceGeometry(
        bounds: FaceBounds(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
        faceContour: [
            SIMD2<Float>(0.31, 0.38),
            SIMD2<Float>(0.34, 0.55),
            SIMD2<Float>(0.39, 0.72),
```

**Missing-input fixture pattern** (lines 145-168):
```swift
static let missingLeftEye = FaceGeometry(
    bounds: fixture.bounds,
    faceContour: fixture.faceContour,
    leftEye: [],
    rightEye: fixture.rightEye,
    nose: fixture.nose
)
```

**Apply to:** Focused XCTest for current public shaping fields. Keep tests internal to `BeautyEffects`; do not import SwiftUI or Demo targets.

---

### `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` (test, event-driven)

**Analog:** `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`

**Domain-specific missing landmark pattern** (lines 39-57):
```swift
func testMissingNoseSkipsOnlyNoseAndKeepsEyeAndSafeDomainsActive() {
    let plan = BeautyEffectResolver.resolve(
        parameters: BeautyParameters(
            brightness: 0.2,
            eyeSize: 0.2,
            noseSlim: 1,
            filterId: "soft_clean",
            filterIntensity: 0.5
        ),
        faceGeometry: .missingNose
    )

    XCTAssertFalse(plan.activeDomains.contains(.nose))
    XCTAssertTrue(plan.activeDomains.contains(.eyes))
```

**Redaction scan pattern** (lines 24-36):
```swift
let combined = (
    plan.warnings.map { "\($0.code) \($0.message)" } +
    Array(plan.metrics.keys)
).joined(separator: " ")

for forbidden in ["/private/var", "VNFaceObservation", "bounding", "CoordinateRect", "image bytes", "[0.", "SIMD"] {
    XCTAssertFalse(combined.contains(forbidden), "Unexpected sensitive term: \(forbidden)")
}
```

**MVP proxy evidence pattern** (lines 59-75):
```swift
let output = BeautyGeometryEffectPipeline.applyMVPProxy(toBGRA: input, plan: plan, face: .fixture)

XCTAssertTrue(plan.activeDomains.contains(.nose))
XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" })
XCTAssertGreaterThan(plan.metrics["beauty.effects.geometryPointCount"] ?? 0, 0)
XCTAssertNotEqual(output, input)
```

**Apply to:** Missing eye/nose/mouth/lip, stale, and reused degradation evidence. Assertions should prove unaffected safe domains remain active and sensitive geometry data stays absent.

---

### `docs/meitu-function-blueprint/features/beauty-shaping/**/*.md` (config, batch)

**Analog:** `docs/meitu-function-blueprint/features/beauty-shaping/README.md`

**Family contract pattern** (lines 7-13):
```markdown
## Technical Core

- SDK owner: `BeautyEffects` geometry providers plus `BeautyRender` unified warp pass.
- Detection dependency: face landmarks and pose quality.
- Public model: existing `BeautyParameters` where available; new public parameters require explicit design updates.
- Safety: combined geometry weakening, caps, and missing-landmark degradation.
```

**Branch status table pattern** (lines 16-24):
```markdown
| Branch | Status | Primary owner | Current public `BeautyParameters` coverage | Future parameter needs | Evidence expectation |
| --- | --- | --- | --- | --- | --- |
| `3D塑颜` | blocked-by-geometry-output | `BeautyEffects` | None | Symmetry, vertical, horizontal, tilt | Requires detection/render integration and public facade saved-image output before visible completion. |
| `比例` | partial | `BeautyEffects` | `faceSmall` | Forehead, mid-face, philtrum, lower-face, short-face, head-face | Current provider/resolver evidence is partial; facade-visible geometry output is still required. |
```

**Blocked/future branch detail patterns** (sources: `3d-sculpt/README.md` lines 9-16, `eyebrows/README.md` lines 9-16):
```markdown
- Status: `blocked-by-geometry-output`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyDetection` pose/landmarks and `BeautyRender` unified warp output.
- Current public `BeautyParameters` coverage: none.
- Future parameter needs: symmetry, vertical, horizontal, and tilt controls.
- Evidence expectation: public facade detection plus geometry render integration must produce saved example-image output before this branch can be marked `implemented`.
```

```markdown
- Status: `future`.
- Primary owner: `BeautyEffects` if promoted.
- Dependencies: future landmarks or resource support only after design approval.
- Current public `BeautyParameters` coverage: none.
- Future parameter needs: position, thickness, length, distance, head distance, tilt, and peak controls.
- Evidence expectation: no v1.3 completion evidence until explicitly promoted.
```

**Apply to:** Branch docs, `FEATURE_MATRIX.md`, and `MODULES.md`. Keep `3D塑颜` blocked, `眉毛` future, and face/eye/nose/mouth/proportion partial unless public facade geometry saved-image output exists.

## Shared Patterns

### Public Parameter Boundary

**Source:** `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`
**Apply to:** Resolver, provider tests, docs, negative scans

```swift
// lines 16-35
public var faceSlim: Float
public var faceSmall: Float
public var faceVShape: Float
public var jawSlim: Float
public var chinLength: Float

public var eyeSize: Float
public var eyeDistance: Float
public var eyeYPosition: Float
public var eyeTailLift: Float

public var noseSlim: Float
public var noseWingSlim: Float
public var noseTipSize: Float
public var noseBridge: Float

public var mouthSize: Float
public var mouthWidth: Float
public var smile: Float
public var lipColor: Float
```

Do not add public fields, coding keys, initializer parameters, or normalized copies for advanced shaping controls in Phase 19.

### Safety Caps

**Source:** `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift`
**Apply to:** Providers, resolver, tests

```swift
// lines 8-27
static let faceSlim: Float = 0.60
static let faceSmall: Float = 0.45
static let faceVShape: Float = 0.50
static let jawSlim: Float = 0.45
static let chinLength: Float = 0.35

static let eyeSize: Float = 0.45
static let eyeDistance: Float = 0.30
static let eyeYPosition: Float = 0.25
static let eyeTailLift: Float = 0.30
```

Use caps for effective strengths and assertions. Public parameter normalization remains `[-1, 1]` or `[0, 1]` in `BeautyParameters`.

### Facade/Renderer Boundary

**Source:** `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
**Apply to:** Negative scans and planning constraints

```swift
// lines 1-10
import AppKit
import CoreImage
import Foundation
import ImageIO
import BeautySDK

struct RenderCase {
    let id: String
    let displayName: String
    let parameters: BeautyParameters
}
```

```swift
// lines 44-95
let cases = [
    RenderCase(
        id: "skinSmoothing_0p50",
        displayName: "skinSmoothing 0.50",
        parameters: BeautyParameters(skinSmoothing: 0.50)
    ),
```

Renderer remains facade-only and currently has skin/color/filter cases. Do not add geometry render cases such as face/eye/nose/mouth/proportion/3D/eyebrow outputs in Phase 19.

### Redacted Diagnostics

**Source:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`
**Apply to:** All warnings, metrics, tests, and docs that mention degradation

```swift
// lines 374-386
private static var reusedGeometryWarning: BeautyValidationWarning {
    BeautyValidationWarning(
        code: "geometry_stale_reduced",
        message: "Reused face geometry reduced effective geometry strength."
    )
}

private static var staleGeometryWarning: BeautyValidationWarning {
    BeautyValidationWarning(
        code: "geometry_stale_skipped",
        message: "Stale face geometry skipped strong geometry output."
    )
}
```

Diagnostics may expose stable codes and counts only. Do not expose landmarks, control points, bounding boxes, Vision objects, paths, image bytes, or SIMD values.

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| _None_ | n/a | n/a | Existing Phase 19 scope is entirely covered by current providers, resolver/caps, tests, renderer boundary, and blueprint docs. |

## Metadata

**Analog search scope:** `BeautySDK/Sources/BeautyEffects`, `BeautySDK/Sources/BeautyCore/Models`, `BeautySDK/Sources/BeautyExampleRenderer`, `BeautySDK/Tests/BeautyEffectsTests`, `docs/meitu-function-blueprint/features/beauty-shaping`, `docs/meitu-function-blueprint`.
**Files scanned:** 39
**Pattern extraction date:** 2026-06-29
