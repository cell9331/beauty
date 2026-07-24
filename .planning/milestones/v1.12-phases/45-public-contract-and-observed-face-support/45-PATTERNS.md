# Phase 45: Public Contract and Observed Face Support - Pattern Map

**Mapped:** 2026-07-21
**Files analyzed:** 17 likely new/modified files
**Analogs found:** 17 / 17

## Scope Boundary

This map follows the reduced four-row scope only: `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`. Phase 45 adds compatible storage and validated observed contour/median support, but does **not** add providers, resolver routing, safety caps, facade/renderer cases, Demo UI, semantic models, person mattes, or changes to bundled preset bytes.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | model | transform / Codable | same file's Phase 41 eye and Phase 38 mouth fields | exact |
| `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` | model | request-response / ephemeral | `BeautyObservedEyeSupport` in same file | exact lifecycle |
| `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | service | request-response / transform | current observed-eye mapping in same file | exact lifecycle, topology divergence |
| `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` | model | transform / ephemeral | `BeautyEyeSemanticSupport` and `FaceGeometry` in same file | exact lifecycle |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` | adapter/service | transform | current eye validation and legacy face proxy in same file | role-match, topology divergence |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | test | transform / Codable | Phase 41 eye contract tests in same file | exact |
| `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | test | file-I/O / decode | nose and mouth missing-key preset tests in same file | exact |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | test | request-response | injected eye support and real portrait tests in same file | exact lifecycle |
| `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` | test | transform | eye orientation/mirror order matrix in same file | exact lifecycle, direction divergence |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` | test | transform | eye boundary/isolation matrix in same file | role-match, topology divergence |
| `.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py` | utility/test | batch / file-I/O | archived Phase 41 `check_eye_support_boundaries.py` | exact |
| `DESIGN.md` | documentation | batch | current face/eye parameter and geometry invariants | exact owner |
| `SECURITY.md` | documentation | batch | current observed-eye privacy/input boundary | exact owner |
| `RELIABILITY.md` | documentation | batch | current degradation/diagnostic contracts | exact owner |
| `PRODUCT_SENSE.md` | documentation | batch | current public scalar acceptance/non-claims | exact owner |
| `PLANS.md` | documentation | event-driven ledger | Phase 41 completion record | exact owner |
| `.planning/STATE.md` | config/documentation | event-driven state | current phase state transitions | exact owner |

## Pattern Assignments

### `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` (model, Codable transform)

**Analog:** the existing manually maintained field lifecycle in the same file.

**Storage and key pattern** (lines 16-20, 57-74):

```swift
public var faceSlim: Float
public var faceSmall: Float
public var faceVShape: Float
public var jawSlim: Float
public var chinLength: Float

enum CodingKeys: String, CodingKey {
    // ...
    case faceSlim
    case faceSmall
    case faceVShape
    case jawSlim
    case chinLength
}
```

Add all four fields to stored properties and `CodingKeys`; keep `chinLength` signed and distinct.

**Default/source compatibility and validation pattern** (lines 121-125, 172-176):

```swift
faceSlim: Float = 0,
faceSmall: Float = 0,
faceVShape: Float = 0,
jawSlim: Float = 0,
chinLength: Float = 0,
// ...
self.faceSlim = Self.clampUnit(faceSlim)
self.faceSmall = Self.clampUnit(faceSmall)
self.faceVShape = Self.clampUnit(faceVShape)
self.jawSlim = Self.clampUnit(jawSlim)
self.chinLength = Self.clampSigned(chinLength)
```

Use `clampUnit` for all four new positive-only fields. Do not copy the signed `chinLength` clamp for `chinTaper`.

**Missing-key and normalized-copy pattern** (lines 214-265, 268-339):

```swift
self.init(
    // ...
    faceSlim: try container.decodeFloatIfPresent(.faceSlim),
    // ...
)

public func normalized() -> BeautyParameters {
    BeautyParameters(
        // every stored field forwarded exactly once
    )
}

func decodeFloatIfPresent(_ key: BeautyParameters.CodingKeys) throws -> Float {
    try decodeIfPresent(Float.self, forKey: key) ?? 0
}
```

Copy the full seven-site lifecycle atomically: property, key, defaulted argument, assignment, decoder argument, `normalized()` forwarding, and tests. Inventory becomes exactly 52 stored fields (51 numeric plus `filterId`).

---

### `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` (ephemeral model)

**Analog:** `BeautyObservedEyeSupport` and its carrier (lines 17-35, 38-63).

```swift
/// This value intentionally has no Codable or diagnostic representation.
package struct BeautyObservedEyeSupport: Equatable, Sendable {
    package let side: BeautyObservedEyeSide
    package let contour: [CoordinatePoint]
    package let pupil: [CoordinatePoint]?
}

package struct BeautyFaceObservation: Equatable, Sendable {
    // ...
    package let observedEyeSupport: [BeautyObservedEyeSupport]?
}
```

Add one package-only, immutable, `Equatable, Sendable` observed-face envelope, with contour and median independently optional, then carry it as an optional on `BeautyFaceObservation`. It must remain non-public, non-SPI, non-Codable, non-descriptive, and request-scoped.

**Required divergence:** unlike eyes, there is one face payload, no left/right side enum, and no pair-order state. Independent region absence is meaningful: valid contour + invalid/missing median must survive as contour-only support.

---

### `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` (service, mapping transform)

**Analog:** `VisionDetectionObservation` payload seam (lines 7-29), `mapObservation` (lines 209-269), `mapPoints` (lines 339-368), and Vision landmark acquisition (lines 371-424, 461-488).

**Carrier/import pattern** (lines 1-29):

```swift
import BeautyCore
import CoreGraphics
import CoreImage
import Foundation
import Vision

package struct VisionDetectionObservation: Equatable, Sendable {
    package let visionBounds: CoordinateRect?
    package let landmarks: BeautyFaceLandmarks
    package let observedEyeSupport: [BeautyObservedEyeSupport]?
}
```

Extend this injected/source payload rather than creating a request or detector.

**Compose face-local point then map once pattern** (current `mapPoints`, lines 339-368):

```swift
let visionPoint = CoordinatePoint(
    x: bounds.x + point.x * bounds.width,
    y: bounds.y + point.y * bounds.height
)
let mapped = try mapper.map(
    point: visionPoint,
    from: .visionNormalized,
    to: .imageNormalized
)
guard mapped.isFinite,
      (0...1).contains(mapped.x),
      (0...1).contains(mapped.y)
else { throw CoordinateMapper.MappingError.invalidCoordinate }
```

Reuse the composition and `CoordinateMapper`; do not hand-roll orientation/mirror transforms.

**Default Vision request pattern** (lines 461-488):

```swift
let request = VNDetectFaceLandmarksRequest()
// ...
let payload = Self.landmarks(from: observation.landmarks)
return VisionDetectionObservation(
    visionBounds: CoordinateRect(/* observation.boundingBox */),
    landmarks: payload.0,
    observedEyeSupport: payload.1
)
```

Extend `landmarks(from:)` to capture `landmarks.faceContour.normalizedPoints` and `landmarks.medianLine.normalizedPoints` from the existing request.

**Error-handling divergence:** the current outer catch at lines 175-200 converts any point mapping error into zero observations plus `.mappingFailed`. Do not reuse that behavior for malformed face-support regions. Preflight each raw region for bounded count/finite/closed-unit input, map each independently, and turn only that region into `nil`. Invalid shared face bounds may still fail the whole observation.

**Canonical direction divergence:** reuse the mapper-derived axis idea from `deriveEyeOrder`, but canonicalize each open path only by whole-array reversal. Contour direction projects `(last-first)` onto mapped face-local right; median projects onto mapped face-local down. Never sort points by X, angle, or distance.

---

### `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` (internal semantic model)

**Analog:** `BeautyEyeSemanticSupport` and optional support fields on `FaceGeometry` (lines 11-42, 65-113).

```swift
struct BeautyEyeSemanticSupport: Equatable, Sendable {
    let contour: [SIMD2<Float>]
    let pupil: SIMD2<Float>?
    var contourEligible: Bool { !contour.isEmpty }
    var pupilEligible: Bool { pupil != nil }
}

struct FaceGeometry: Equatable, Sendable {
    let faceContour: [SIMD2<Float>]
    let leftEyeSupport: BeautyEyeSemanticSupport?
    let rightEyeSupport: BeautyEyeSemanticSupport?
}
```

Add a target-internal `BeautyFaceSemanticSupport` (or equivalent) and an optional `observedFaceSupport` on `FaceGeometry`. Keep separate eligibility levels for contour-only and contour-plus-centerline/apex evidence. Preserve `FaceGeometry.faceContour` as the existing seven-point compatibility proxy.

---

### `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` (adapter, validation transform)

**Analog:** current detector-to-effects validation seam and its legacy proxy.

**Independent attachment pattern** (lines 20-24, 80-94):

```swift
static func makeGeometry(from observation: BeautyFaceObservation) -> FaceGeometry {
    let bounds = makeBounds(from: observation)
    let landmarks = observation.landmarks.availableGroups
    // validate optional observed support
    return FaceGeometry(
        bounds: bounds,
        faceContour: landmarks.contains(.faceContour) ? faceContour(in: bounds) : [],
        // existing domains unchanged
        leftEyeSupport: leftSupport,
        rightEyeSupport: rightSupport
    )
}
```

Build the legacy proxy and all existing eye/nose/lip geometry exactly as today, then independently attach validated observed-face support. A malformed face payload must not trigger an early return that clears sibling domains.

**Legacy proxy that must remain unchanged** (lines 366-375):

```swift
private static func faceContour(in bounds: FaceBounds) -> [SIMD2<Float>] {
    [
        point(bounds, x: 0.05, y: 0.30),
        point(bounds, x: 0.12, y: 0.58),
        point(bounds, x: 0.28, y: 0.84),
        point(bounds, x: 0.50, y: 0.94),
        point(bounds, x: 0.72, y: 0.84),
        point(bounds, x: 0.88, y: 0.58),
        point(bounds, x: 0.95, y: 0.30)
    ]
}
```

**Validation pattern to reuse selectively** (lines 146-183): finite/closed-unit checks, exact-bit uniqueness, bounded counts, finite derived dimensions, and pure named predicates.

**Open-polyline divergences (mandatory):**

- Use face-specific constants: contour `7...32`, median `3...16`; do not reuse eye `6...16` or eye width/height ratios.
- Require every point unique, not merely four unique points.
- Preserve adjacency and canonical reversal from detection; do not use the eye angular sort at lines 185-192.
- Do not use `polygonArea` at lines 319-327. The face contour is open; use endpoint chord separation plus maximum perpendicular curvature/depth.
- Validate contour width `0.50...1.00`, height `0.20...1.00`, endpoint horizontal separation `>= 0.35`, curvature `>= 0.10`.
- Validate median net-down projection `>= 0.25` independently.
- Only after both regions validate, enforce median bottom chord position `0.15...0.85`, nearest-apex distance `<= 0.40`, and at least two contour points on each side of the apex index.
- A bad median preserves contour eligibility; a bad contour cannot produce centerline eligibility.

---

### `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` (contract tests)

**Analog:** Phase 41 eye contract tests and Phase 38 mouth tests in the same file.

Current exact inventory assertions occur at lines 102-116, 184-207, 249-252, 641-652, and 708-722. Update live 48-field assertions to 52, but retain historical literal fixture counts 31 and 33. The legacy-38 reconstruction at lines 139-165 must remove all ten eye keys plus all four new face keys so it remains exactly 38.

Copy the existing matrices:

- positive-only values: negative → 0, distinct in-range retained, >1 → 1, NaN/±infinity → 0;
- direct mutation + `normalized()` reapplies rules without mutating the source;
- `Mirror` labels/count and JSON object count are exactly 52;
- full unequal 52-key round trip proves no aliasing;
- legacy 48-key decode and source-style initializer omission yield four zeros;
- `chinTaper` remains independent of signed `chinLength`.

---

### `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` (resource decode tests)

**Analog:** nose test lines 29-49 and mouth test lines 51-86.

```swift
let presets = try BeautyResourceCatalog.bundled().builtInPresets()
XCTAssertEqual(presets.count, 5)
for preset in presets {
    XCTAssertEqual(preset.parameters.lipPeakDefinition, 0, "\(preset.id) lipPeakDefinition")
}
```

Add assertions that all five bundled presets decode all four new fields as zero. Do not edit preset JSON; the checker must also prove the four keys are absent and the five files retain their baseline SHA-256 values.

---

### Detection and adapter test files

#### `VisionFaceDetectorTests.swift`

**Analog:** injected eye mapping lines 137-168 and real fixture test lines 233-258.

Inject contour and median independently, assert exact mapped points and independent nil preservation, and extend the six-portrait default-provider test to require at least one aggregate complete observed-face support without coordinate logging. Copy the structured/redacted assertions at lines 171-185, but change malformed face-region expectations from whole-observation `.mappingFailed` to retained observation plus region-local absence.

#### `FaceObservationMappingTests.swift`

**Analog:** full `.up/.right/.left/.down` × mirrored matrix at lines 142-176.

Copy the metadata matrix and add forward/reversed contour plus forward/reversed median inputs. Assert identical canonical arrays under each orientation/input-mirror combination; preview mirroring must not affect image-normalized support. Add exact closed-unit 0/1 acceptance and just-outside/non-finite region-local rejection.

#### `BeautyFaceGeometryAdapterTests.swift`

**Analog:** current exact-boundary and field-local eye tests, especially lines 84-115, 123-183, 188-298.

Create face-named fixture helpers and tests before implementation. Cover 6/7/8 and 31/32/33 contour counts; 2/3/4 and 15/16/17 median counts; duplicates; non-finite/out-of-unit; flat/collinear; width/height/chord/curvature boundaries; median direction/side/apex consistency; and contour-only survival. Assert the exact seven legacy proxy points and safe eye/nose/lip siblings are unchanged for every malformed observed-face case.

---

### `check_face_support_boundaries.py` (batch/static gate)

**Analog:** `.planning/milestones/v1.11-phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py`.

**Fail-closed subprocess pattern** (analog lines 70-103, 155-176): classify `rg` exit 0 as matches, 1 as clean no-match, and every other status/exception as failure.

**Repository containment pattern** (analog lines 103-139): locate a root only when `.git` and `BeautySDK/Package.swift` exist; resolve every scanned path under root and reject symlink escapes/missing required paths.

**Checks to copy/adapt** (analog symbols):

- `check_baseline`: keep `BeautySDK/Package.swift` and `BeautyDemo` unchanged from `9aedd6b40a7c033ac86cea2c75e06bac138cf9ef`;
- `check_public_inventory`: expect exactly the new 52-field contract;
- `check_public_geometry`: reject public/SPI observed face support and raw geometry;
- `check_codable_persistence`, `check_diagnostics`, `check_network`, `check_imports`, `check_artifacts`;
- add semantic-model/resource/dependency prohibition and exact five-preset key-absence + SHA-256 checks;
- preserve adversarial `--self-test` mutation fixtures (analog lines 453-574).

The face checker should use face-specific names and allowlists; do not loosen the eye helper by importing it.

---

### Contract documentation and ledger files

Use the current owning sections rather than duplicating one narrative everywhere:

| File | Record only this owned fact | Analog |
|---|---|---|
| `DESIGN.md` | 52-field scalar lifecycle; observed open-polyline/median support separated from seven-point proxy; eligibility invariants | current eye support/parameter design sections |
| `SECURITY.md` | package-only, ephemeral, non-Codable/non-diagnostic support; bounded finite input; no semantic resource/dependency | current observed-eye privacy boundary |
| `RELIABILITY.md` | region-local degradation, fixed aggregate reasons/counts, no raw coordinates; legacy sibling preservation | current eye degradation contract |
| `PRODUCT_SENSE.md` | exactly four new independent public intents and Phase 45 acceptance; no provider/readiness claim | existing nose/mouth/eye acceptance rows |
| `PLANS.md` | implementation status and actual verification evidence only | `C-2026-07-16-phase-41-public-contract-observed-eye-support` |
| `.planning/STATE.md` | phase/plan transition and compact evidence pointer | existing GSD phase state format |

Do not update branch-level `脸型` to complete and do not claim the four rows implemented in product ledgers during Phase 45; provider/output/safety ownership remains Phases 46-48.

## Shared Patterns

### Access and privacy

**Source:** `BeautyFaceObservation.swift` lines 17-22 and `WarpControlPoint.swift` lines 11-15.

All raw/derived support values are immutable package/internal `Equatable, Sendable` values with no Codable, persistence, public/SPI, logging, or diagnostic representation.

### Coordinate mapping

**Source:** `VisionFaceDetector.swift` lines 169-177 and 339-368.

One `CoordinateMapper` instance per detection call; compose face-bounds-local points into Vision image coordinates, map once into image-normalized coordinates, and validate finite closed-unit results.

### Field-local failure

Observed face contour and median validity is independent. Malformed optional face support becomes absent support, not an exception that removes the selected face or legacy eye/nose/mouth work. Invalid shared face bounds remain a legitimate observation-level mapping failure.

### Compatibility

Missing JSON keys decode to zero through `decodeFloatIfPresent`; public initializer additions default to zero; bundled preset bytes remain unchanged; the old seven-point `faceContour` remains the sole compatibility path for the five shipped face fields.

### Testing

Follow exact below/equal/above boundary matrices, all orientation/mirror combinations, unequal-value anti-aliasing, and redacted failure assertions. Synthetic injected observations are normative for precise thresholds; six real portraits provide only aggregate availability evidence.

## No Analog Found

None. Every likely file has a strong lifecycle or ownership analog. The key caveat is that the closest observed-eye analog must be deliberately diverged for face **open-polyline** topology and region-local degradation.

## Explicit Non-Files / Forbidden Changes

- Do not modify `BeautySDK/Package.swift` or any `BeautyDemo/**` source.
- Do not modify the five bundled preset JSON files; test missing-key decoding and verify fixed bytes instead.
- Do not create a new target, detector, Vision request, model/resource, provider, resolver case, safety cap, facade case, renderer case, gallery, or public geometry type.
- Do not add double-chin, double-chin Pro, or hairline fields/support; those three semantic-region rows are deferred.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, root contract documents, and archived Phase 41 under `.planning/milestones/v1.11-phases/41-public-contract-and-observed-eye-support`

**Primary analog files read:** 11 source/test/helper files plus Phase 41 pattern map

**Pattern extraction date:** 2026-07-21
