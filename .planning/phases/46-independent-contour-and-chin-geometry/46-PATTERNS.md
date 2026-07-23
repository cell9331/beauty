# Phase 46: Independent Contour and Chin Geometry - Pattern Map

**Mapped:** 2026-07-23
**Files analyzed:** 24 new/modified files
**Analogs found:** 23 / 24

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` | model | transform | same file, existing geometry fields | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | config | transform | same file, Phase 44 eye caps | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service | request-response / transform | same file, eye/nose/mouth preflight and convergence | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift` | provider | transform | `EyeWarpProvider.swift` named emissions; same file for legacy vectors | role/data-flow composite |
| `BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift` | provider | transform | `EyeWarpProvider.swift` named emissions; same file for signed chin vector | role/data-flow composite |
| `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | service | transform | same file, 33-field shared scale | exact |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | provider/dispatcher | streaming transform | same file, unified provider concatenation | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` | test provider | request-response | same file, `.usableFace` observation fixture | exact |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | test | transform | same file plus eye/nose provider ownership tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | test | request-response | same file, routing/cap/provider-empty tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | test | transform | same file, total/count/scale tables | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | test | transform | same file, bounded convergence/source scan | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | test | event-driven state transition | same file, fresh/reused/stale/no-face matrices | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift` | test | streaming transform | same file, unified dispatch/output extent | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | test | request-response | same file, isolated public geometry rows and redaction | exact |
| `DESIGN.md` | contract doc | batch | existing Phase 42/45 contract entries | role match |
| `ARCHITECTURE.md` | contract doc | batch | existing provider/resolver boundary entries | role match |
| `SECURITY.md` | contract doc | batch | existing observed-support boundary/redaction entries | role match |
| `RELIABILITY.md` | contract doc | batch | existing degradation/aggregate-diagnostic entries | role match |
| `PRODUCT_SENSE.md` | acceptance doc | batch | existing phase acceptance entries | role match |
| `PLANS.md` | ledger | event-driven | existing completed phase records | exact |
| `BeautySDK/Tests/BeautyEffectsTests/` shared asymmetric observed-support fixture (location at planner discretion) | test fixture | transform | existing `FaceGeometry.fixture` conventions | role match |
| optional Phase 46 boundary checker | utility | file-I/O / batch | Phase 45 fail-closed checker | role match |
| new contour-band/chord/median interpolation helper (if split from providers) | utility | transform | no direct live analog | none |

No new target, dependency, resource, render pass, public facade method, public result type, Demo source, generated image, or semantic model is in scope.

## Pattern Assignments

### Planning ledger and caps

**Apply to:** `BeautyEffectPlan.swift`, `BeautySafetyCaps.swift`, `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`

**Analog:** `BeautyEffectPlan.swift:25-74`, `BeautySafetyCaps.swift:8-29`

```swift
public struct BeautyEffectiveStrengths: Equatable, Sendable {
    public var faceSlim: Float = 0
    public var faceSmall: Float = 0
    public var faceVShape: Float = 0
    public var jawSlim: Float = 0
    public var chinLength: Float = 0
    // append the four positive-only effective values beside this domain
    public init() {}
}

enum BeautySafetyCaps {
    static let faceSlim: Float = 0.60
    // Phase 46 additions must be explicitly marked provisional.
}
```

Keep `BeautyEffectiveStrengths` a plain value ledger with zero defaults. Apply each new positive scalar with `capUnit`, not `capSigned`; the established cap helpers are at `BeautyEffectResolver.swift:455-469`.

**Resolver cap/routing pattern** (`BeautyEffectResolver.swift:91-110`):

```swift
strengths.faceSlim = capUnit(
    normalized.faceSlim,
    cap: BeautySafetyCaps.faceSlim,
    cappedCount: &cappedCount
)
```

Add the four fields to `requiresFaceGeometry`, reusable-work detection, exact `0.5` reuse scaling, stale/no-face handling, and face-domain request checks. Preserve the distinction between “requested” evidence and final emission-owned activity.

**Conflict pattern** (`GeometryConflictResolver.swift:16-69`):

```swift
let total = geometryTotal(strengths)
guard total > totalThreshold else {
    return GeometryConflictResolution(strengths: strengths, warnings: [], metrics: [:])
}
let scale = totalThreshold / total
var weakened = strengths
weakened.faceSlim *= scale
// scale every geometry field exactly once
```

Mirror each new field in all three inventories: scaling, `geometryTotal`, and nonzero count. Use absolute value only for signed fields; the four Phase 46 fields are positive-only.

### Face and chin named emissions

**Apply to:** `FaceShapeWarpProvider.swift`, `ChinWarpProvider.swift`

**Primary analog:** `EyeWarpProvider.swift:4-44,61-99`

```swift
struct EyeWarpFieldEmissions: Equatable, Sendable {
    let eyeSize: [WarpControlPoint]
    let eyeDistance: [WarpControlPoint]

    var points: [WarpControlPoint] {
        eyeSize + eyeDistance
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.eyeSize != 0, eyeSize.isEmpty { sanitized.eyeSize = 0 }
        if strengths.eyeDistance != 0, eyeDistance.isEmpty { sanitized.eyeDistance = 0 }
        return sanitized
    }
}

func makeControlPoints(face: FaceGeometry, strengths: BeautyEffectiveStrengths)
    -> WarpControlPointResult {
    let emissions = fieldEmissions(face: face, strengths: strengths)
    return WarpControlPointResult(points: emissions.points)
}
```

Create seven face arrays and two chin arrays with stable concatenation order. `sanitizing(_:)` must zero only a requested field whose own array is empty. Do not use one aggregate face guard: shipped fields may use the seven-point compatibility proxy, while the additions must use only eligible observed support.

**Legacy-vector preservation anchors:**

- `FaceShapeWarpProvider.swift:43-63` — shipped face-slim sources/vector/radius.
- `FaceShapeWarpProvider.swift:65-75` — shipped full-contour small-face transform.
- `FaceShapeWarpProvider.swift:77-107` — shipped V/jaw lower-face vectors.
- `ChinWarpProvider.swift:9-28` — signed vertical apex/chin-length vector.

These bodies should be moved behind named emissions without changing their sources, targets, radii, strength, falloff, or ordering.

**Bounded point construction** (`FaceShapeWarpProvider.swift:110-123`):

```swift
WarpControlPoint(
    source: LandmarkGeometryHelper.clamp(source),
    target: LandmarkGeometryHelper.clamp(target),
    radius: min(max(radius, 0.04), 0.35),
    strength: strength,
    falloff: 2
)
```

For the new algorithms, validate every intermediate as finite before final clamping; clamping must not hide invalid math. Use canonical observed-contour order and disjoint half-open path-progress bands. Smoothing uses interior neighbor chords and mean-centered lateral displacement; taper uses only `apexIndex - 1` and `apexIndex + 1`, interpolates median X at each source Y, and keeps target Y unchanged.

### Monotone provider-empty convergence

**Apply to:** `BeautyEffectResolver.swift`

**Analog:** `BeautyEffectResolver.swift:217-230,475-506`

```swift
strengths = eyeProvider
    .fieldEmissions(face: faceGeometry, strengths: strengths)
    .sanitizing(strengths)

var retainedBaseline = strengths
for _ in 0..<28 {
    let resolution = GeometryConflictResolver().resolve(strengths: retainedBaseline)
    let nextBaseline = eyeProvider
        .fieldEmissions(face: faceGeometry, strengths: resolution.strengths)
        .sanitizing(retainedBaseline)
    if nextBaseline == retainedBaseline { return resolution }
    retainedBaseline = nextBaseline
}
```

Extend the preflight and every convergence pass to face and chin before eye/nose/mouth. Change the exact ceiling to 37. Critically, evaluate emissions at scaled strengths but sanitize the retained unscaled baseline; never reconstruct from the original request, because that can revive removed work.

After convergence, recompute final face/chin/eye/nose/mouth emissions once. Use those arrays as the sole authority for final effective strengths, domain activity, skipped-domain behavior, aggregate point count, and pipeline dispatch.

### Unified dispatch

**Apply to:** `BeautyGeometryEffectPipeline.swift`

**Analog:** `BeautyGeometryEffectPipeline.swift:5-20`

```swift
static func controlPoints(
    for strengths: BeautyEffectiveStrengths,
    face: FaceGeometry
) -> [WarpControlPoint] {
    FaceShapeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
        ChinWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
        EyeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
        NoseWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
        MouthWarpProvider().makeControlPoints(face: face, strengths: strengths).points
}
```

Keep this provider order and the one existing warp. Do not call this unified method separately to count a face domain: that includes sibling eye/nose/mouth arrays and causes double counting. Count each final provider emission array once in the resolver, then dispatch the same final strengths here.

### Deterministic facade fixture and route

**Apply to:** `BeautyEngineTestingSupport.swift`, `BeautyEngineGeometryFacadeTests.swift`

**Fixture analog:** `BeautyEngineTestingSupport.swift:29-41`

```swift
case .usableFace:
    return [
        VisionDetectionObservation(
            stableID: "fixture",
            confidence: 0.96,
            normalizedArea: 0.24,
            visionBounds: CoordinateRect(x: 0.30, y: 0.20, width: 0.40, height: 0.60),
            landmarks: .complete
        )
    ]
```

Attach deterministic asymmetric raw contour and median input to this existing observation seam. Keep it testing-SPI only and do not add a public geometry/result type.

**Facade assertion pattern** (`BeautyEngineGeometryFacadeTests.swift:17-44`):

```swift
XCTAssertEqual(provider.invocationCount, 1, name)
XCTAssertEqual(result.output.extent, Self.image.extent, name)
XCTAssertEqual(result.detectionSummary?.availability, .usable, name)
XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1, name)
XCTAssertGreaterThan(result.metrics["beauty.effects.geometryPointCount"] ?? 0, 0, name)
```

Retain the same redaction scan: diagnostics must not acquire provider, contour, coordinate, path, index, support-measurement, or filesystem details.

### Provider and integration tests

**Apply to:** all seven Phase 46 test files

Use current XCTest style: explicit construction, direct provider/resolver call, and exact `XCTAssertEqual`/bounded floating comparisons. The closest live patterns are:

- `FaceShapeWarpProviderTests.swift` — source/target/radius/falloff and zero/missing-input assertions.
- `GeometryConflictResolverTests.swift:49-100` — exact warning keys, weakened count, scale, and signed/unsigned strength checks.
- `CombinedEffectSafetyTests.swift:46-72` — table-driven provider-empty removal and source-level convergence-bound assertion.
- `MissingLandmarkDegradationTests.swift` — fresh/reused/stale/no-face and valid-sibling matrices.
- `BeautyGeometryEffectPipelineTests.swift:23-46` — provider dispatch plus stable extent/pixel locality.
- `BeautyEngineGeometryFacadeTests.swift:17-44` — isolated public request route and aggregate redaction.

For each new field assert the named array directly, exact source subset, direction, finite closed-unit source/target, bounded radius/falloff, zero neutrality, nearest shipped-field distinction, and unchanged shipped arrays. Use an asymmetric complete fixture plus contour-only and missing/malformed-centerline variants. Point-count symmetry alone is not acceptable evidence.

## Shared Patterns

### Eligibility and fail-closed isolation

Use `observedFaceSupport.contourEligible` for smoothing/temple/cheekbone and require `centerlineEligible`, non-nil median, and a valid apex index for taper. New fields must never fall back to `FaceGeometry.faceContour`; only shipped fields retain that compatibility behavior. Missing support empties and sanitizes the dependent field while valid siblings remain active.

### Finite and bounded geometry

Follow `WarpControlPoint`/provider conventions: image-normalized `SIMD2<Float>`, finite inputs and intermediates, unit-bounded sources and targets, clamped conservative radius, fixed local falloff `2`, and O(n) contour work within Phase 45's 32/16 support ceilings.

### Aggregate-only error handling

Follow `BeautyEffectResolver.swift:572-633`: fixed warning code and generic message, with numeric aggregate metrics only. Do not interpolate field name, source index, contour/median/apex details, coordinates, bounds, displacement, provider identity, or support-derived measurements.

### Documentation ownership

Update each owner in its existing phase-entry style: `DESIGN.md` for provisional geometry/caps/convergence, `ARCHITECTURE.md` for provider/resolver boundaries, `SECURITY.md` for support validation and redaction, `RELIABILITY.md` for degradation/diagnostics, `PRODUCT_SENSE.md` for provider/routing acceptance only, and `PLANS.md` for completion plus exact verification evidence. Do not claim decoded output, naturalness, final caps, row promotion, or release readiness.

## No Analog Found

| File/Concern | Role | Data Flow | Reason |
|---|---|---|---|
| optional split contour-band/chord/median interpolation helper | utility | transform | No current provider consumes canonical observed face contour for these transforms. Keep private in the provider unless a small shared face/chin helper materially reduces duplication; use the research algorithm constraints, not a synthetic proxy analog. |

## Metadata

**Analog search scope:** `BeautySDK/Sources/BeautyEffects/{Planning,Warp,Render}`, `BeautySDK/Sources/BeautySDK`, `BeautySDK/Tests/{BeautyEffectsTests,BeautyCoreTests}`, and root owner documents.

**Strong analogs read:** `BeautyEffectResolver.swift`, `EyeWarpProvider.swift`, `FaceShapeWarpProvider.swift`, `GeometryConflictResolver.swift`, `BeautyGeometryEffectPipeline.swift`; associated current tests were searched for exact assertion and fixture patterns.

**Pattern extraction date:** 2026-07-23
