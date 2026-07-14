# Phase 38: Public Contract and Lip-Support Geometry - Pattern Map

**Mapped:** 2026-07-14  
**Authority:** current source/tests, then `38-CONTEXT.md` and `38-RESEARCH.md`  
**Expected implementation/test/doc files classified:** 24 direct or likely edits, 5 phase evidence artifacts  
**Primary new seam:** independently optional inner-lip availability plus explicit package-only upper/lower/inner supports; valid shipped `outerLips` geometry must remain unchanged

## Authoritative Current-State Notes

- `BeautyParameters` currently has exactly 33 stored fields: 32 numeric values plus `filterId`. Phase 38 adds five numeric stored values and locks 38 total = 37 numeric plus `filterId`.
- The public model already has the exact six manual seams needed: stored vars, `CodingKeys`, defaulted initializer arguments, clamp assignments, missing-key decode forwarding, and `normalized()` forwarding.
- `BeautyFaceLandmarks` records coarse group availability only. `BeautyFaceGeometryAdapter` constructs deterministic proxy supports from face bounds; raw Vision lip points are not retained or exposed.
- `outerLips` is globally required by the existing usable-geometry contract. `innerLips` must be optional at that level so missing inner lips disable only dependent peak/plump work.
- The current eight-point `outerLips` proxy is shipped regression input for `mouthSize`, `mouthWidth`, `smile`, and `lipColor`. Do not reshape or reorder it to make the new controls easier.
- `FaceGeometry.noseRoot` / `.noseTip` and `NoseWarpProvider` are the closest successful analog for default-empty explicit supports, pre-clamp validation, independent emissions, and no legacy fallback.
- `MouthWarpProvider` already exposes provider-owned three-field emissions and `sanitizing(_:)`, but its global outer-lip center guard must be refined so eight fields can fail independently.
- Resolver convergence currently allows nine monotonic nose/mouth field removals: six nose plus three mouth. Phase 38 expands the exact bound to fourteen: six nose plus eight mouth.
- `BeautyEngineGeometryDetection.swift` already routes every field named by `BeautyEffectResolver.requiresFaceGeometry(parameters:)`; no facade signature or result-field change is expected.
- Bundled preset JSON remains unedited. Missing keys decoded through `decodeFloatIfPresent` are the compatibility evidence.
- Phase 38 must not edit renderer cases/helpers, generated images, Demo UI, feature ledgers/matrix/branch README, `QUALITY_SCORE.md`, package targets/dependencies, or archived v1.8/v1.9 artifacts.

## File Classification

| Expected New/Modified File | Role | Data Flow | Closest Current Analog | Pattern Quality |
| --- | --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | public value model | host/JSON -> normalized stored parameters | current mouth fields plus Phase 35 nose additions across six seams | exact structural |
| `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` | coarse availability model | Vision region presence -> package-only group set | `.outerLips` enum case and required-group set | exact structural; inner must stay optional |
| `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` | Vision availability adapter | optional Vision regions -> `BeautyFaceLandmarks` | existing `outerLips?.pointCount` insertion | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` | package-internal geometry model | adapter/test fixtures -> provider supports | default-empty `noseRoot` / `noseTip` arrays | exact structural |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` | deterministic geometry adapter | selected observation groups + bounds -> proxy supports | `noseRoot(in:)`, `noseTip(in:)`, `outerLips(in:)` | exact role; new lip layout |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` | effective-value model | resolver -> providers/public aggregate plan | current three mouth geometry fields in `BeautyEffectiveStrengths` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | provisional internal constants | normalized values -> capped strengths | Phase 35 `noseRootNarrowing` / `noseTipLift = 0.25` | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` | geometry provider and eligibility owner | eight effective fields + private supports -> field emissions/control points | current `MouthWarpFieldEmissions`; six-field `NoseWarpFieldEmissions`; nose support validators | exact structural, new vectors |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | planner/orchestrator | public values + optional geometry -> effective strengths/domains/warnings/metrics | current mouth cap/zero/reuse/provider/convergence branches | exact structural; omission-prone |
| `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | combined-safety reducer | geometry strengths -> scaled strengths + aggregate evidence | current signed mouth scale/total/count entries | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | public contract unit tests | defaults/abnormal/mutated/JSON values -> exact model | Phase 35 inventory/legacy JSON/round-trip tests | exact |
| `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | resource compatibility test | unchanged preset files -> decoded zero values | `testNOSE02BundledPresetsDecodeNewNoseFieldsAsZero` | exact |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | availability integration tests | injected/real observations -> usable/partial summaries and groups | missing-required/usable observation tests | exact role |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | adapter and shared fixture owner | observation groups/named geometry variants -> provider inputs | adapter nose support test; `.fixture`, `.missingMouth`, `.reused`, `.stale` | exact role; fixtures only |
| `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | exact cap test | internal constants -> provisional numeric lock | existing nose `0.25` test | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` | provider geometry tests | isolated fields + valid/malformed supports -> vectors/emissions | current mouth direction tests plus `NoseWarpProviderTests` strict support tests | exact structural; new semantics |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | resolver unit/integration tests | isolated public field + fixture -> cap/route/activation/evidence | Phase 35 cap tables, negative no-op, `requiresFaceGeometry` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | degradation/convergence integration | missing/reused/stale/provider-empty supports -> zero/scale/skip/continuation | current mouth freshness tests and Phase 35 provider-empty convergence tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | conflict unit tests | effective strengths -> total/scale/weakened count | existing signed mouth and six-field nose entries | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | representative cross-domain integration | isolated vs combined request -> weakened sign-preserving values | `testMOUTH08EveryMouthGeometryFieldWeakens...` and nose exact-once table | exact structural |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | public-facade integration | SPI detector + isolated scalar -> same-extent redacted result | Phase 35 isolated nose route table | exact |
| `ARCHITECTURE.md`, `DESIGN.md`, `RELIABILITY.md`, `SECURITY.md`, `PRODUCT_SENSE.md` | durable current owners | observed implementation -> boundaries/contracts/non-claims | Phase 35 nose contract sections | exact role |
| `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` | execution/planning ledgers | observed evidence -> traceability and Phase 39 handoff | Phase 35 closeout workflow | exact role |
| `38-VERIFICATION.md`, `38-VALIDATION.md`, `38-REVIEW.md`, `38-SECURITY.md`, plan `SUMMARY.md` files | phase evidence | executed tests/scans/review -> MOUTH-01...08 verdict | archived Phase 35 artifacts | exact role |

Expected **non-edits**: `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`, bundled preset JSON, `BeautyExampleRenderer`, `BeautyDemo`, `BeautySDK/Package.swift`, `QUALITY_SCORE.md`, feature ledgers/matrix/lips README, generated output/gallery files, and archived milestone artifacts. The existing geometry pipeline already concatenates `MouthWarpProvider().makeControlPoints(...)`; new emissions flow through automatically.

## Data-Flow and Dependency Map

```text
BeautyParameters.swift
  -> BeautyEffectPlan.swift + BeautySafetyCaps.swift
  -> BeautyEffectResolver.swift
       -> MouthWarpProvider.swift
       -> GeometryConflictResolver.swift
       -> BeautyGeometryEffectPipeline.swift (unchanged consumer)

VisionFaceDetector.swift
  -> BeautyFaceObservation.swift availableGroups
  -> BeautyFaceGeometryAdapter.swift
  -> WarpControlPoint.swift FaceGeometry supports
  -> MouthWarpProvider.swift

BeautyEffectResolver.requiresFaceGeometry
  -> BeautyEngineGeometryDetection.swift (unchanged facade route)
  -> BeautyEngineGeometryFacadeTests.swift
```

Planning dependency order should follow this graph: public/effective symbols and availability/supports can begin independently, provider work waits for both, and resolver/facade integration waits for provider eligibility.

## Concrete Implementation Patterns

### 1. Add five fields through all six `BeautyParameters` seams

The Phase 35 nose fields are the exact current analog. Add the geometry fields after `smile` and before `lipColor` in the same order everywhere:

```swift
public var mouthYPosition: Float
public var mouthTilt: Float
public var mouthXPosition: Float
public var lipPeakDefinition: Float
public var lipPlump: Float

case mouthYPosition
case mouthTilt
case mouthXPosition
case lipPeakDefinition
case lipPlump
```

Use defaulted labeled arguments and existing clamp families:

```swift
mouthYPosition: Float = 0,
mouthTilt: Float = 0,
mouthXPosition: Float = 0,
lipPeakDefinition: Float = 0,
lipPlump: Float = 0,

self.mouthYPosition = Self.clampSigned(mouthYPosition)
self.mouthTilt = Self.clampSigned(mouthTilt)
self.mouthXPosition = Self.clampSigned(mouthXPosition)
self.lipPeakDefinition = Self.clampUnit(lipPeakDefinition)
self.lipPlump = Self.clampUnit(lipPlump)
```

Follow the existing missing-key and normalized-copy patterns exactly:

```swift
mouthYPosition: try container.decodeFloatIfPresent(.mouthYPosition),
mouthTilt: try container.decodeFloatIfPresent(.mouthTilt),
mouthXPosition: try container.decodeFloatIfPresent(.mouthXPosition),
lipPeakDefinition: try container.decodeFloatIfPresent(.lipPeakDefinition),
lipPlump: try container.decodeFloatIfPresent(.lipPlump),
```

```swift
mouthYPosition: mouthYPosition,
mouthTilt: mouthTilt,
mouthXPosition: mouthXPosition,
lipPeakDefinition: lipPeakDefinition,
lipPlump: lipPlump,
```

Do not write custom `encode(to:)`, a second decoder helper, computed aliases, or field forwarding to shipped mouth storage. `decodeFloatIfPresent` already maps absent keys to zero, and `clampFinite` already maps non-finite input to zero.

Tests should extend the exact Phase 35 shapes:

```swift
XCTAssertEqual(Mirror(reflecting: BeautyParameters()).children.count, 38)
```

- table-drive signed `-2 -> -1`, `2 -> 1`, and all non-finite values -> `0`;
- table-drive positive-only negative -> `0`, overflow -> `1`, and all non-finite values -> `0`;
- mutate all five public vars after initialization and assert `normalized()` returns a corrected copy;
- prove distinct storage/equality with unequal simultaneous values;
- decode a literal complete 33-key v1.9 JSON object with no new keys and assert all five are zero;
- encode/decode unequal nonzero values and assert exactly 38 keys;
- retain labeled initializer calls that jump from shipped mouth/nose arguments to `lipColor`, `filterId`, or `filterIntensity`.

Name new tests with `Phase38` because current tests still contain archived-v1.8-local names such as `testMOUTH05...` and `testMOUTH08...`.

### 2. Preserve preset absence as compatibility evidence

Reuse the current catalog pattern:

```swift
let presets = try BeautyResourceCatalog.bundled().builtInPresets()
for preset in presets {
    XCTAssertEqual(preset.parameters.mouthYPosition, 0, preset.id)
    XCTAssertEqual(preset.parameters.mouthTilt, 0, preset.id)
    XCTAssertEqual(preset.parameters.mouthXPosition, 0, preset.id)
    XCTAssertEqual(preset.parameters.lipPeakDefinition, 0, preset.id)
    XCTAssertEqual(preset.parameters.lipPlump, 0, preset.id)
}
```

Do not insert explicit zero keys into preset JSON. Their absence exercises the compatibility path.

### 3. Add inner availability without changing global usability

The current group enum and required set are deliberately separate:

```swift
package enum BeautyLandmarkGroup: String, CaseIterable, Equatable, Sendable {
    case faceContour
    case leftEye
    case rightEye
    case nose
    case outerLips
}

private static let requiredGeometryGroups: Set<BeautyLandmarkGroup> = [
    .faceContour, .leftEye, .rightEye, .nose, .outerLips
]
```

Add `case innerLips` to the enum only. Keep `requiredGeometryGroups` exactly outer-based. `BeautyFaceLandmarks.complete` already uses `Set(BeautyLandmarkGroup.allCases)`, so complete fixtures gain inner availability automatically.

Mirror the existing Vision mapping block:

```swift
if landmarks.outerLips?.pointCount ?? 0 > 0 {
    groups.insert(.outerLips)
}
if landmarks.innerLips?.pointCount ?? 0 > 0 {
    groups.insert(.innerLips)
}
```

The focused injected test pattern is:

```swift
let groups = Set(BeautyLandmarkGroup.allCases).subtracting([.innerLips])
let landmarks = BeautyFaceLandmarks(availableGroups: groups)
XCTAssertTrue(landmarks.hasRequiredGeometry)
```

Route that observation through `VisionFaceDetector` and assert `.usable`, not `.partial`. This proves optionality without exposing raw Vision data.

### 4. Extend `FaceGeometry` with default-empty explicit supports

The nose support fields are the exact analog:

```swift
let outerLips: [SIMD2<Float>]
let upperLips: [SIMD2<Float>]
let lowerLips: [SIMD2<Float>]
let innerLips: [SIMD2<Float>]

init(
    bounds: FaceBounds,
    faceContour: [SIMD2<Float>],
    // existing arrays...
    outerLips: [SIMD2<Float>] = [],
    upperLips: [SIMD2<Float>] = [],
    lowerLips: [SIMD2<Float>] = [],
    innerLips: [SIMD2<Float>] = [],
    freshness: LandmarkGeometryFreshness = .fresh
)
```

Default arguments preserve direct `FaceGeometry` construction. Keep all four arrays package/internal with no public/SPI wrapper.

In `BeautyFaceGeometryAdapter.makeGeometry`, follow current group-gated builders:

```swift
outerLips: landmarks.contains(.outerLips) ? outerLips(in: bounds) : [],
upperLips: landmarks.contains(.outerLips) ? upperLips(in: bounds) : [],
lowerLips: landmarks.contains(.outerLips) ? lowerLips(in: bounds) : [],
innerLips: landmarks.contains(.innerLips) ? innerLips(in: bounds) : []
```

Use the existing `point(bounds,x:y:)` helper for deterministic normalized proxy points. `upperLips` and `lowerLips` are explicit outer-surface subsets; they should not simply copy the complete `outerLips` array. A stable left-to-right arrangement is the closest fit to current test conventions.

Required adapter invariants:

```text
existing outerLips -> exact coordinates and order unchanged
missing outerLips  -> outer/upper/lower all empty
missing innerLips  -> outer/upper/lower retained, inner empty
complete groups    -> all four finite, bounded, deterministic, distinct supports
```

Extend `.fixture`, `.missingMouth`, `.reused`, and `.stale` by forwarding the new arrays. Add named variants for missing/non-finite/duplicate/insufficient upper, lower, and inner supports without weakening existing nose/eye/outer values.

### 5. Expand effective storage and provisional caps

Follow the current adjacent mouth fields in `BeautyEffectiveStrengths`:

```swift
public var mouthYPosition: Float = 0
public var mouthTilt: Float = 0
public var mouthXPosition: Float = 0
public var lipPeakDefinition: Float = 0
public var lipPlump: Float = 0
```

Follow the current Phase 35 provisional-cap analog:

```swift
static let mouthYPosition: Float = 0.25
static let mouthTilt: Float = 0.25
static let mouthXPosition: Float = 0.25
static let lipPeakDefinition: Float = 0.25
static let lipPlump: Float = 0.25
```

Use provisional wording in tests/docs. Phase 40, not Phase 38, owns final exact-cap lock.

### 6. Expand provider-owned emissions before writing aggregate behavior

The current mouth and nose emission structs establish the pattern:

```swift
struct MouthWarpFieldEmissions: Equatable, Sendable {
    let mouthSize: [WarpControlPoint]
    let mouthWidth: [WarpControlPoint]
    let smile: [WarpControlPoint]

    var points: [WarpControlPoint] { mouthSize + mouthWidth + smile }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.mouthSize != 0, mouthSize.isEmpty { sanitized.mouthSize = 0 }
        // ...
        return sanitized
    }
}
```

Add five arrays in canonical order and enumerate them in both `points` and `sanitizing(_:)`. This struct is the shared eligibility contract used before and after conflict scaling.

Replace the top-level unconditional outer-center guard with the requested-work/emission pattern used by `NoseWarpProvider`:

```swift
let emissions = fieldEmissions(face: face, strengths: strengths)
let requestedWork = abs(strengths.mouthSize) > Float.ulpOfOne ||
    abs(strengths.mouthWidth) > Float.ulpOfOne ||
    strengths.smile > 0 ||
    abs(strengths.mouthYPosition) > Float.ulpOfOne ||
    abs(strengths.mouthTilt) > Float.ulpOfOne ||
    abs(strengths.mouthXPosition) > Float.ulpOfOne ||
    strengths.lipPeakDefinition > 0 ||
    strengths.lipPlump > 0

return WarpControlPointResult(
    points: emissions.points,
    skipReason: requestedWork && emissions.points.isEmpty ? "mouth_inputs_missing" : nil
)
```

Each field helper must validate its own actual support. A valid whole-mouth field must not require inner support; a valid peak must not require lower support; a valid sibling must not hide a zeroed failed field.

### 7. Reuse the nose provider's support-validation discipline

The closest strict analog is `NoseWarpProvider.validatedRootPair`, `validatedTipSupport`, `isValidSupportPoint`, and `hasOnlyDistinctPoints`. Lip validators should follow the same order:

1. strength is finite and above `Float.ulpOfOne`;
2. support has sufficient cardinality;
3. every point is finite, normalized, and within face bounds;
4. points are structurally distinct/nondegenerate and deterministically ordered;
5. center/reference/displacement/target are finite and nonzero;
6. target direction and bounds are correct before `makePoint` clamps.

The shared shape is:

```swift
guard strength.isFinite,
      abs(strength) > Float.ulpOfOne,
      let support = validatedSupport(in: face)
else { return [] }

let displacement = /* conservative bounds-scaled coefficient */
guard displacement.isFinite, displacement > Float.ulpOfOne else { return [] }

let targets = support.map { /* field-specific vector */ }
guard zip(support, targets).allSatisfy({ source, target in
    isValidNormalizedPoint(target) &&
    LandmarkGeometryHelper.distance(source, target) > Float.ulpOfOne
}) else { return [] }
```

Only then call the existing radius/falloff builder:

```swift
WarpControlPoint(
    source: LandmarkGeometryHelper.clamp(source),
    target: LandmarkGeometryHelper.clamp(target),
    radius: min(max(radius, 0.035), 0.20),
    strength: abs(strength),
    falloff: 2
)
```

Clamping is not validation. A `NaN`, degenerate center, or zero displacement must return no emission rather than being made to look bounded.

### 8. Implement whole-mouth translation and rotation as distinct vectors

Use one validated whole-mouth source order and center so comparisons are meaningful.

Vertical translation pattern:

```swift
let deltaY = face.bounds.height * coefficient * strength / BeautySafetyCaps.mouthYPosition
let target = SIMD2<Float>(source.x, source.y + deltaY)
```

Horizontal translation pattern:

```swift
let deltaX = face.bounds.width * coefficient * strength / BeautySafetyCaps.mouthXPosition
let target = SIMD2<Float>(source.x + deltaX, source.y)
```

Center rotation pattern (angle sign must be documented consistently for the repository's top-to-bottom image coordinate convention):

```swift
let vector = source - center
let target = center + SIMD2<Float>(
    vector.x * cosAngle - vector.y * sinAngle,
    vector.x * sinAngle + vector.y * cosAngle
)
```

Omit sources at the center that would emit zero displacement. Tests should assert:

- Y position: unchanged X, uniform nonzero Y sign/magnitude, opposite input reverses Y;
- X position: unchanged Y, uniform nonzero X sign/magnitude, opposite input reverses X;
- tilt: stable radius around center within tolerance and opposite tangential motion for opposite signs;
- all three: deterministic identical source order and complete point arrays that differ from each other.

Non-alias comparisons must include shipped fields:

```swift
XCTAssertNotEqual(xPosition.points.map(\.target), mouthWidth.points.map(\.target))
XCTAssertNotEqual(yPosition.points.map(\.target), smile.points.map(\.target))
XCTAssertNotEqual(tilt.points.map { $0.target - $0.source }, smile.points.map { $0.target - $0.source })
```

Point-count inequality alone is not sufficient.

### 9. Use explicit local support for peak and plump

There is no shipped semantic analog to copy. Use the explicit-support/no-fallback pattern from the new nose helpers and the mouth provider's bounded displacement conventions.

Peak-definition invariants:

- consume explicit upper plus inner support;
- operate on a local cupid-bow subset, not mouth corners;
- preserve symmetric behavior around center for symmetric support;
- make flanking peaks and center relationship visibly/structurally distinct;
- return no peak emission for missing/malformed upper or inner support;
- never substitute `smilePoints`, `sizePoints`, or whole-mouth sources.

Plump invariants:

- consume explicit upper, lower, and inner support;
- derive a finite inner-opening reference (stable center or nearest valid inner anchor);
- move upper surface away from the opening toward the upper exterior and lower surface toward the lower exterior;
- require both upper and lower output groups;
- return no plump emission for any missing/malformed dependency;
- never substitute mouth-size vectors or color behavior.

Test isolated complete arrays and vector classes against `smile`, both signs of `mouthSize`, peak versus plump, and the whole transforms. Exact coefficients/radii remain private/provisional.

### 10. Extend every resolver enumeration together

Resolver assignment uses the existing cap helpers:

```swift
strengths.mouthYPosition = capSigned(
    normalized.mouthYPosition,
    cap: BeautySafetyCaps.mouthYPosition,
    cappedCount: &cappedCount
)
strengths.lipPeakDefinition = capUnit(
    normalized.lipPeakDefinition,
    cap: BeautySafetyCaps.lipPeakDefinition,
    cappedCount: &cappedCount
)
```

Add all five fields to:

- `requiresFaceGeometry(parameters:)`;
- `hasReusableNonEyeGeometryValues`;
- `hadRequestedMouthValues`;
- `hasMouthGeometryValues`;
- `zeroMouthGeometryStrengths(_:)`;
- `scaleReusableNonEyeGeometryStrengths(_:by:)`;
- provider preflight and final sanitization;
- mouth-domain activation/skip and geometry point accounting.

The existing preflight shape should remain provider-owned:

```swift
strengths = mouthProvider
    .fieldEmissions(face: faceGeometry, strengths: strengths)
    .sanitizing(strengths)
```

For reused geometry, all eight eligible mouth geometry values multiply by exact `0.5`; signed values retain sign. `lipColor` remains outside this helper's geometry additions and keeps its existing independent policy.

### 11. Expand bounded convergence from nine to fourteen

The current resolver explicitly documents the monotonic mask loop:

```swift
// Each pass can only remove fields, and there are nine fields.
for _ in 0..<9 {
    let resolution = GeometryConflictResolver().resolve(strengths: retainedBaseline)
    var nextBaseline = noseProvider
        .fieldEmissions(face: faceGeometry, strengths: resolution.strengths)
        .sanitizing(retainedBaseline)
    nextBaseline = mouthProvider
        .fieldEmissions(face: faceGeometry, strengths: resolution.strengths)
        .sanitizing(nextBaseline)
    if nextBaseline == retainedBaseline { return resolution }
    retainedBaseline = nextBaseline
}
```

Change the exact bound/comment to fourteen. Preserve monotonic removal and the final fallback resolution. Do not introduce unbounded iteration.

In `GeometryConflictResolver`, each new field appears exactly once in each category:

```swift
weakened.mouthYPosition *= scale
weakened.mouthTilt *= scale
weakened.mouthXPosition *= scale
weakened.lipPeakDefinition *= scale
weakened.lipPlump *= scale
```

Signed values use `abs` in total/count; positive-only values do not need it:

```swift
abs(strengths.mouthYPosition) +
abs(strengths.mouthTilt) +
abs(strengths.mouthXPosition) +
strengths.lipPeakDefinition +
strengths.lipPlump
```

Final-scale-empty tests should mirror the Phase 35 threshold-crossing cases in `MissingLandmarkDegradationTests`: the removed field becomes exact zero in the retained baseline, disappears from weakened count/total/dispatch, and a valid sibling stays active.

### 12. Public facade evidence uses the existing isolated-route table

Mirror the Phase 35 facade pattern with five cases and a fresh provider/engine per case:

```swift
let cases = [
    BeautyParameters(mouthYPosition: 1),
    BeautyParameters(mouthTilt: 1),
    BeautyParameters(mouthXPosition: 1),
    BeautyParameters(lipPeakDefinition: 1),
    BeautyParameters(lipPlump: 1),
]
```

Assert exactly:

- detector invocation count `1`;
- output extent unchanged;
- `.usable`, face count `1`, used face count `1`;
- `beauty.detection.geometryRequired == 1`;
- `beauty.effects.geometryPointCount > 0`;
- warning/metric/reason text contains no `upperLips`, `lowerLips`, `innerLips`, support, coordinate, landmark, control point, SIMD, bounds, or provider payload.

Do not expose active domains/effective strengths/raw points through `BeautyResult`. Do not compare saved pixels or add renderer/gallery cases; Phase 39 owns that evidence.

## Test Fixture and Assertion Patterns

### Shared `FaceGeometry` forwarding

Every fixture that copies `.fixture` should forward the new arrays unless the fixture deliberately removes one dependency:

```swift
FaceGeometry(
    bounds: fixture.bounds,
    faceContour: fixture.faceContour,
    leftEye: fixture.leftEye,
    rightEye: fixture.rightEye,
    nose: fixture.nose,
    noseRoot: fixture.noseRoot,
    noseTip: fixture.noseTip,
    outerLips: fixture.outerLips,
    upperLips: fixture.upperLips,
    lowerLips: fixture.lowerLips,
    innerLips: fixture.innerLips,
    freshness: fixture.freshness
)
```

This prevents an unrelated eye/nose/mouth test from accidentally losing the new support after the initializer grows.

### Field-local support matrix

Use named fixtures rather than inline arrays so resolver/provider expectations share one source:

| Fixture | Whole transforms/shipped | Peak | Plump |
| --- | --- | --- | --- |
| `.fixture` | eligible | eligible | eligible |
| `.missingMouth` | ineligible | ineligible | ineligible |
| `.missingInnerLips` | eligible | ineligible | ineligible |
| `.missingUpperLips` | whole eligible | ineligible | ineligible |
| `.missingLowerLips` | whole eligible | eligible | ineligible |
| `.nonFiniteInnerLips` / duplicate inner | whole eligible | ineligible | ineligible |
| malformed whole/outer | dependent whole/shipped ineligible | local fields follow explicit dependency contract | local fields follow explicit dependency contract |

For mixed requests, inspect `fieldEmissions` arrays and final effective strengths separately. Nonempty aggregate points cannot prove every requested field emitted.

### Signed and non-alias tables

Use key paths/closures for public cap and conflict tests, but keep provider geometry assertions separate:

```swift
let signedCases: [(String, BeautyParameters, KeyPath<BeautyEffectiveStrengths, Float>)] = [
    ("mouthYPosition positive", BeautyParameters(mouthYPosition: 1), \.mouthYPosition),
    ("mouthYPosition negative", BeautyParameters(mouthYPosition: -1), \.mouthYPosition),
    // tilt and X position...
]
```

Resolver assertions: exact provisional `±0.25`, cap count/warning, `.mouth` active, aggregate points positive, sign preserved. Provider assertions: axis/tangential vector and complete-array non-alias semantics.

Positive-only negative-input tests should expect a silent no-op: public/effective zero, no geometry required if it is the only request, neither active nor skipped mouth, no missing-input warning, and capped count zero.

## Documentation and Evidence Patterns

Follow the Phase 35 two-stage evidence pattern:

1. implementation/focused/full/security evidence remains explicitly non-final while current root contracts are not synchronized;
2. update `ARCHITECTURE.md`, `DESIGN.md`, `RELIABILITY.md`, `SECURITY.md`, `PRODUCT_SENSE.md`, `PLANS.md`, requirements/roadmap/state from observed facts;
3. rerun the full SDK and final boundary/no-promotion scans;
4. only then mark verification/security/validation green and MOUTH-01 through MOUTH-08 complete.

Required current-owner facts:

- exact `38 = 37 numeric + filterId` inventory;
- three signed and two positive-only public contracts;
- provisional `0.25` caps and exact reused `0.5` behavior;
- independent inner availability and package-only default-empty upper/lower/inner supports;
- eight provider-owned geometry fields and fourteen-mask convergence;
- redacted aggregate diagnostics and no public raw geometry;
- Phase 39 output and Phase 40 final-cap/exhaustive-safety/promotion deferrals;
- all five rows and branch-level `嘴唇` remain unpromoted/partial.

Do not update `QUALITY_SCORE.md` or product ledgers/status rows in Phase 38.

## Ordering and Dependency Hazards

1. **Public/effective contract first.** Provider/resolver helpers cannot compile against absent fields; exact 38-field compatibility should be independently green.
2. **Availability/supports can proceed beside the public model.** Add inner group semantics and adapter fixtures before peak/plump helpers depend on them.
3. **Freeze legacy outer points before new support tuning.** Adapter tests should assert old `outerLips` coordinates unchanged before adding upper/lower/inner expectations.
4. **Provider before resolver/facade.** `requiresFaceGeometry` can invoke detection while a missing helper yields zero points; provider field emissions must be trustworthy first.
5. **Remove the global provider guard carefully.** Preserve the established `mouth_inputs_missing` aggregate skip reason when all requested work fails, while allowing valid siblings to emit.
6. **Every manual list moves together.** Omission causes detection without cap, reuse without scaling, stale work surviving, conflict-count drift, or effective/emission disagreement.
7. **Update the loop bound with the emission count.** The correct retained set is exactly six nose plus eight mouth; `lipColor` is excluded.
8. **Validate before clamp.** Non-finite or zero-displacement points can otherwise appear bounded but become renderer-ineligible later.
9. **Do not over-specify aesthetics.** Lock structural vectors and conservative provisional coefficients; Phase 39 decides output calibration and Phase 40 locks final caps.
10. **Docs follow evidence, not intent.** Keep all five rows unpromoted and do not claim renderer/gallery/ROI, exhaustive safety, branch completion, device/commercial, packaging, shipping, or launch readiness.

## Verification Pattern

Run focused suites in dependency order:

```bash
swift test --package-path BeautySDK --filter BeautyParametersTests
swift test --package-path BeautySDK --filter BeautyResourceCatalogTests
swift test --package-path BeautySDK --filter VisionFaceDetectorTests
swift test --package-path BeautySDK --filter FaceShapeWarpProviderTests
swift test --package-path BeautySDK --filter BeautySafetyCapsTests
swift test --package-path BeautySDK --filter MouthWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectResolverTests
swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter GeometryConflictResolverTests
swift test --package-path BeautySDK --filter CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK
```

Then scan the omission and boundary surfaces:

```bash
test "$(rg -n '^    public var ' BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift | wc -l | tr -d ' ')" -eq 38

for field in mouthYPosition mouthTilt mouthXPosition lipPeakDefinition lipPlump; do
  rg -n "$field" BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift \
    BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift \
    BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift \
    BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift \
    BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift \
    BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift || exit 1
done

git diff -- BeautySDK/Sources/BeautyExampleRenderer BeautyDemo BeautySDK/Package.swift
git diff -- QUALITY_SCORE.md docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md \
  docs/meitu-function-blueprint/FEATURE_MATRIX.md \
  docs/meitu-function-blueprint/features/beauty-shaping/lips
git diff --check
```

Classify public/SPI geometry matches manually: internal support declarations are expected, but no new public/SPI `FaceGeometry`, support array, landmark, SIMD, bound, provider, or `WarpControlPoint` exposure may appear. Confirm no new dependency/network/cloud/commercial path, no generated tracked/staged artifact, no archived v1.8/v1.9 change, and no renderer/Demo/ledger promotion drift.

Record actual executed test counts. Phase 38 evidence must map direct unit coverage plus the next integration layer to MOUTH-01 through MOUTH-08 and explicitly hand off renderer/output work to Phase 39 and final safety/promotion to Phase 40.

