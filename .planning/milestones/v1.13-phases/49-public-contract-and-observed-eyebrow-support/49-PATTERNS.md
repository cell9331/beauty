# Phase 49: Public Contract and Observed Eyebrow Support - Pattern Map

**Mapped:** 2026-07-24
**Files analyzed:** 18 likely new/modified files
**Analogs found:** 18 / 18

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | model | transform / Codable round-trip | same file's Phase 45 face-field additions | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | test | transform / Codable round-trip | same file's face and eye compatibility matrices | exact |
| `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | test | file-I/O / decode | same file's preset-neutrality tests | exact |
| `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` | model | request-response | `BeautyObservedFaceSupport` in the same file | exact |
| `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | service | request-response / transform | same file's observed-face capture and mapping | exact |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | test | request-response / event-driven lifecycle | same file's actual Vision face-support and isolation tests | exact |
| `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift` | test | transform / concurrent request-response | same file's face-axis canonicalization matrix | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` | utility | transform | same file's open-face-path validation | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` | model | transform / request-response | `BeautyFaceSemanticSupport` and `FaceGeometry` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` | test | transform | same file's face topology and local-failure matrices | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | test | transform | existing inert/unrouted parameter assertions | role-match |
| `.planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py` | utility | batch / file-I/O | archived Phase 45 `check_face_support_boundaries.py` | exact |
| `DESIGN.md` | config/documentation | batch | Phase 45 observed-face contract sections | exact |
| `ARCHITECTURE.md` | config/documentation | batch | Phase 45 package-boundary sections | exact |
| `SECURITY.md` | config/documentation | batch | Phase 45 privacy/validation sections | exact |
| `RELIABILITY.md` | config/documentation | batch | Phase 45 lifecycle/error sections | exact |
| `PRODUCT_SENSE.md` | config/documentation | batch | Phase 45 acceptance/nonclaim sections | exact |
| `PLANS.md` | config/documentation | batch | `C-2026-07-23-phase-45-*` completion records | exact |

No new target, module, provider, resolver production path, renderer, facade, Demo file, resource, manifest, dependency, persistence, or network file should be created or modified in Phase 49.

## Pattern Assignments

### `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` (model, transform/Codable)

**Analog:** the existing additive fields in the same file.

**Stored-property, coding-key, and defaulted-source pattern** (lines 16-24, 74-83, 129-137):

```swift
public var chinLength: Float
public var faceContourSmooth: Float
public var templeFullness: Float
public var cheekboneSlim: Float
public var chinTaper: Float

case chinLength
case faceContourSmooth
case templeFullness
case cheekboneSlim
case chinTaper

chinLength: Float = 0,
faceContourSmooth: Float = 0,
templeFullness: Float = 0,
cheekboneSlim: Float = 0,
chinTaper: Float = 0,
```

Copy this manual evolution pattern for exactly seven fields: `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, `eyebrowTilt`, and `eyebrowPeakDefinition`.

**Legacy decode and reconstruction pattern** (lines 230-285, 288-342):

```swift
let container = try decoder.container(keyedBy: CodingKeys.self)
self.init(
    // ...
    faceContourSmooth: try container.decodeFloatIfPresent(.faceContourSmooth),
    // ...
)

public func normalized() -> BeautyParameters {
    BeautyParameters(
        // every stored value is reconstructed
        faceContourSmooth: faceContourSmooth
    )
}
```

The helper at lines 361-364 makes a missing key decode as zero. Add every eyebrow argument to both reconstruction sites. Do not add reset/diff APIs: reset is `.init()`, and diff behavior is synthesized `Equatable` snapshot comparison.

**Normalization pattern** (lines 345-357):

```swift
private static func clampUnit(_ value: Float) -> Float {
    clampFinite(value, lower: 0, upper: 1)
}

private static func clampSigned(_ value: Float) -> Float {
    clampFinite(value, lower: -1, upper: 1)
}

private static func clampFinite(_ value: Float, lower: Float, upper: Float) -> Float {
    guard value.isFinite else { return 0 }
    return min(max(value, lower), upper)
}
```

Use `clampSigned` for the first six fields and `clampUnit` only for `eyebrowPeakDefinition`. Current inventory becomes exactly 59 stored fields / 58 numeric fields; historical 31/33/38/48/52 fixtures stay historical.

---

### Public compatibility tests

**Analogs:** `BeautyParametersTests.swift` and `BeautyResourceCatalogTests.swift`.

**Boundary and independence matrix** (`BeautyParametersTests.swift` lines 452-501, 520-562):

```swift
for entry in nonFiniteValues {
    XCTAssertEqual(
        BeautyParameters(eyeDistance: entry.value).eyeDistance,
        0
    )
}

let distinct = BeautyParameters(
    noseRootNarrowing: 0.21,
    noseTipLift: 0.37
)
XCTAssertNotEqual(
    distinct,
    BeautyParameters(noseRootNarrowing: 0.37, noseTipLift: 0.21)
)
```

Build the brow matrix with `-2, -1, 0, 1, 2, NaN, ±infinity`, pairwise unequal values, mutable assignment followed by `normalized()`, equality, `.init()` replacement, and round-trip checks.

**Current-versus-historical count pattern** (`BeautyParametersTests.swift` lines 821-848):

```swift
XCTAssertEqual(object.count, 33) // historical fixture: preserve
// ...
XCTAssertEqual(object.count, 52) // current complete model: update to 59
XCTAssertEqual(decoded, parameters)
```

Add a real legacy 52-key payload with no brow keys and assert seven zeros. Do not mechanically replace every `52`.

**Preset pattern:** `BeautyResourceCatalogTests.swift` already loads bundled presets through `BeautyResourceCatalog.bundled()` and decodes their `BeautyParameters`. Extend its neutral-field assertions, while the boundary checker pins all five existing bytes/hashes and rejects any eyebrow key. Do not edit preset JSON.

**Inertness pattern:** extend `BeautyEffectResolverTests.swift` with a nonzero seven-field input and assert the shipped plan/emissions are unchanged. Do not add eyebrow cases to resolver production code.

---

### `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` (request-local model)

**Analog:** `BeautyObservedFaceSupport` (lines 38-75).

```swift
package struct BeautyObservedFaceSupport: Equatable, Sendable {
    package let contour: [CoordinatePoint]?
    package let medianLine: [CoordinatePoint]?
}

extension BeautyObservedFaceSupport:
    CustomStringConvertible,
    CustomDebugStringConvertible,
    CustomReflectable
{
    package var description: String {
        "BeautyObservedFaceSupport(contourCount: \(contour?.count ?? 0), ...)"
    }

    package var customMirror: Mirror {
        Mirror(self, children: [
            "contourCount": contour?.count ?? 0,
            "medianLineCount": medianLine?.count ?? 0,
        ], displayStyle: .struct)
    }
}
```

Create a distinct eyebrow carrier rather than reusing `BeautyObservedEyeSupport`. Keep left/right optional independently, immutable, `package`, `Equatable`, and `Sendable`; do not conform it to `Codable`. The leaf and enclosing `BeautyFaceObservation` diagnostic surfaces (lines 108-134) may expose only availability/side counts and point counts.

---

### `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` (Vision capture and mapping service)

**Analog:** the Phase 45 observed-face path in the same file.

**Single request and immediate value-copy seam** (lines 637-665):

```swift
let request = VNDetectFaceLandmarksRequest()
// ...
try handler.perform([request])

return (request.results ?? []).map { observation in
    let payload = Self.landmarks(from: observation.landmarks)
    return VisionDetectionObservation(
        // ...
        observedFaceSupport: payload.observedFaceSupport
    )
}
```

Extend `landmarks(from:)` at lines 547-601 to copy `landmarks.leftEyebrow` and `.rightEyebrow` immediately. Preflight each framework region before allocation/mapping: open-path classification, nonzero count, and a fixed maximum of 16. Never retain `VNFaceLandmarkRegion2D`, add a second request, or substitute eye/face points.

**Independent optional-region mapping** (lines 294-327, 439-473):

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

Mirror this local-failure shape for each brow. A rejected left brow must not remove the right brow, selected face, eye support, or face support. Accepted points pass through `mapPoints` once only.

**Mapper-derived axes and whole-array reversal** (lines 458-503):

```swift
let direction = SIMD2<Double>(last.x - first.x, last.y - first.y)
let projection = direction.x * canonicalAxis.x + direction.y * canonicalAxis.y
guard projection.isFinite, abs(projection) > 0.000_001 else {
    return nil
}
return projection > 0 ? mapped : Array(mapped.reversed())
```

Reuse `mappedFaceAxes`, but brow canonicalization also needs mapped face center. Classify side from centroid projection onto face-right, classify inner-to-outer endpoint direction from the same axis, and reverse the whole array only. Reject epsilon-degenerate or declared-side-mismatched traces. Preview mirroring must remain irrelevant.

---

### Detection and mapping tests

**Analogs:** `VisionFaceDetectorTests.swift` plus `FaceObservationMappingTests.swift`.

Copy the face mapping matrix at `FaceObservationMappingTests.swift` lines 250-321: forward/reversed arrays, four orientations, input mirror on/off, preview mirror on/off, equality of canonical results, and exact adjacency assertions. Copy local rejection at lines 343-385: malformed one-side input becomes nil while the valid sibling remains. Copy lifecycle isolation at lines 388-430: consecutive opposite metadata and task-group parallel detector values must retain only their own aggregate counts.

`VisionFaceDetectorTests.swift` should additionally prove direct use of the actual Vision brow properties, zero mapper calls for preflight-rejected 0/17/non-open regions, exactly one call per accepted point plus fixed axis probes, sibling-domain retention, repeated/alternating requests, interruption, and valid→stale/no-face clearing.

---

### `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` (semantic adapter)

**Analog:** open face-path validation at lines 20-38 and 394-499.

**Separate constants and pure validation** (lines 20-38, 394-440):

```swift
static let minimumFaceContourPointCount = 7
static let maximumFaceContourPointCount = 32
static let minimumFaceDirectionMagnitude: Float = 0.000_001

guard (minimumFaceContourPointCount...maximumFaceContourPointCount).contains(input.count),
      faceInputIsValid(input),
      !facePathHasNonAdjacentIntersections(input),
      let local = faceRelativePoints(input, bounds: bounds)
else {
    return nil
}
```

Add brow-specific constants/helpers rather than using the closed-eye constants. Research defaults are 4...16 exact-bit-unique points, endpoint chord 0.08...0.50 face width, vertical span at most 0.25 face height, and side/order magnitude greater than `1e-6`. Treat the brow as an open polyline: do not close endpoints, calculate polygon area/winding, or sort points.

**Independent semantic eligibility** (lines 470-499):

```swift
guard let observed,
      let contourInput = observed.contour,
      let contour = validatedFaceContour(contourInput, bounds: bounds)
else {
    return nil
}
// Optional sibling support is validated separately; valid primary support survives.
```

Validate left and right independently. Derive `pairedEligible` only after both valid sides occupy distinct canonical sides. A malformed side must not contaminate the valid side, face support, or eye support.

---

### `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` (semantic carrier and parent)

**Analog:** `BeautyFaceSemanticSupport` and `FaceGeometry` (lines 44-92, 115-167, 174-217).

```swift
struct BeautyFaceSemanticSupport: Equatable, Sendable {
    let contour: [SIMD2<Float>]
    let medianLine: [SIMD2<Float>]?
    let apexIndex: Int?
}

extension BeautyFaceSemanticSupport:
    CustomStringConvertible,
    CustomDebugStringConvertible,
    CustomReflectable
{
    var description: String {
        "BeautyFaceSemanticSupport(contourCount: \(contour.count), ...)"
    }
}
```

Add package-target-internal eyebrow semantic values only: canonical trace plus the minimum endpoints/center/interior apex evidence needed downstream. Attach them to `FaceGeometry` with default-nil initializer arguments. Update `FaceGeometry.description`, `debugDescription`, and `customMirror` to expose only availability, paired eligibility, and aggregate counts.

---

### Adapter tests

**Analog:** `BeautyFaceGeometryAdapterTests.swift`.

Copy the inclusive boundary-matrix organization at lines 500-560, the malformed finite/bounds/exact-duplicate cases at lines 563-603, the canonical-adjacency/reversed-direction assertions at lines 605-636, non-adjacent intersection rejection at lines 638-677, and sibling-preservation behavior at lines 679-701.

Add brow-specific cases for counts 3/4/5/15/16/17; exact-bit duplicates; non-finite/out-of-unit points; zero/short/long chord; excessive vertical span; wrong side/order; non-adjacent crossings; valid-left/invalid-right and inverse; paired eligibility; legacy face/eye sibling invariance; and redacted description/reflection/mirror/dump.

---

### `check_eyebrow_support_boundaries.py` (batch/file-I-O safeguard)

**Analog:** `.planning/milestones/v1.12-phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py`.

Reuse its fail-closed architecture:

- path containment and repository discovery (`safe_path`, lines 123-155);
- `rg`-based allowlist scans (`run_search`/`rg_scan`, lines 104-201);
- manifest/Demo baseline checks (`check_baseline`, lines 237-254);
- public inventory, Codable/persistence, diagnostics, network, imports, models, resource manifests, semantic scope, preset bytes, and artifact checks (`check_*`, lines 257-556);
- deterministic `live_checks` registry (lines 557-573);
- temporary adversarial fixtures and positive/negative self-tests (`build_*`, `self_test`, lines 576-856);
- nonzero exit on any failed result (`print_results`/`main`, lines 857-881).

Adapt required-source tokens to actual `leftEyebrow`/`rightEyebrow`, open-path preflight, package-only carriers, and redaction/lifecycle markers. Add negative self-tests for eye-contour substitution, synthetic/generated traces, `Codable`, public/SPI exposure, provider/resolver/renderer activation, Demo imports, resource/model/dependency additions, network/persistence, changed preset hashes/keys, and coordinate or stable-signature diagnostics.

## Shared Patterns

### Package-only, request-scoped evidence

**Sources:** `BeautyFaceObservation.swift` lines 17-54; `WarpControlPoint.swift` lines 44-67.

Raw detector values use `package`; derived effects values remain target-internal. Both are immutable `Equatable, Sendable` values, absent from `Codable`, storage, network, and shared mutable state. Framework landmark objects end at `VisionFaceDetector.landmarks(from:)`.

### Aggregate-only diagnostics

**Sources:** `BeautyFaceObservation.swift` lines 56-75 and 108-134; `VisionFaceDetector.swift` lines 35-61; `WarpControlPoint.swift` lines 69-92 and 174-217.

Every leaf and enclosing parent explicitly controls `description`, `debugDescription`, and `customMirror`. Only fixed labels, booleans, and counts are allowed. Tests must also capture `dump`; reject coordinates, `CGPoint`/`SIMD`, arrays, hashes/signatures, or biometric/profile-like values.

### Local fail-closed behavior

**Sources:** `VisionFaceDetector.swift` lines 294-327 and 439-473; `BeautyFaceGeometryAdapter.swift` lines 470-499.

Optional regions are rejected locally via optional results. Observation-level invalid shared bounds may still fail the observation, but one malformed eyebrow cannot erase unrelated valid regions. No retry, fallback, cache, or remapping is permitted.

### Open-path adjacency

**Sources:** `VisionFaceDetector.swift` lines 458-473; `BeautyFaceGeometryAdapter.swift` lines 394-468.

Canonicalization is whole-array reversal only. Validation checks exact-bit uniqueness and non-adjacent segment crossings without connecting last to first. Screen-axis sorting and polygon rules are prohibited.

### Owner-document closeout

Follow the completed Phase 45 record pattern in `PLANS.md`: state exact public counts, request-local capture/mapping bounds, independent validation/eligibility, privacy/isolation evidence, commands and real outcomes, requirements closed, and explicit downstream nonclaims. Update only the authoritative sections of `DESIGN.md`, `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, and `PRODUCT_SENSE.md`; do not duplicate the same contract text across all documents.

## No Analog Found

None. Every likely Phase 49 file has an exact or strong role-match analog in the current face/eye support code or archived Phase 45 artifacts.

## Metadata

**Analog search scope:** `BeautySDK/Sources/BeautyCore`, `BeautySDK/Sources/BeautyDetection`, `BeautySDK/Sources/BeautyEffects`, `BeautySDK/Tests`, `.planning/milestones/v1.12-phases/45-public-contract-and-observed-face-support`, and root owner documents.

**Primary analogs read:** 11 source/test/checker files; Phase 49 context/research; `AGENTS.md`; `PLANS.md`.

**Pattern extraction date:** 2026-07-24

**Planning caution:** the research records a missing local `example-images/input/portraits/e1.png`; Phase 49 must preflight or provision an authorized fixture before claiming a green full suite. Do not weaken unrelated tests or fabricate the closeout result.
