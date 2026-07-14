# Phase 35: Public Contract and Independent Geometry - Pattern Map

**Mapped:** 2026-07-13  
**Authority:** current source and tests, then `35-CONTEXT.md` / `35-RESEARCH.md`  
**Expected implementation/test/doc files classified:** 24 direct or likely edits, 1 conditional contract edit  
**Primary new seam:** package-internal root/tip support geometry; there is no honest symmetric-root analog in the current four-point `nose` proxy

## Authoritative Current-State Notes

- `BeautyParameters` has 31 stored fields today: 30 numeric fields plus `filterId`. Phase 35 adds two numeric stored fields and locks 33 total; archived v1.7 evidence remains unchanged.
- All four shipped nose behaviors consume `FaceGeometry.nose`. The public-facade adapter's four points and the shared test fixture's four points are current regression inputs and must not be reshaped to make the new root contract easier.
- The current upper `nose` points are not a symmetric pair: they differ in Y and one is on/near the centerline. `bridgePoints` therefore is not a valid analog for symmetric root narrowing.
- The current lower points can illustrate region selection, but `noseTipLift` still needs its own explicit support/path and vertical-only vector contract; it must not return `tipPoints` or `lowerNosePoints` unchanged.
- `BeautyEngineGeometryDetection.swift` already routes any parameter listed by `BeautyEffectResolver.requiresFaceGeometry(parameters:)`. No facade production edit or signature change is expected.
- Preset JSON must remain absent of the two new keys. Loading absence through `BeautyResourceCatalog.bundled()` is the compatibility test.
- Conflict resolution is currently invoked from the face-shape and mouth blocks, not the isolated nose block. Phase 35 extends the total/scale/count lists and tests a representative cross-domain conflict; Phase 37 owns any exhaustive once-only refactor.
- Phase 35 must not modify renderer cases/helpers, generated images, feature ledgers, branch READMEs, Demo UI, or status promotion.

## File Classification

| Expected New/Modified File | Role | Data Flow | Closest Existing Analog | Pattern Quality |
| --- | --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | public value model | caller/JSON -> normalized stored parameters | six current manual enumeration points; positive-only `eyeSize` / `noseSlim` | exact structural |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` | effective plan model | resolver -> providers/public aggregate plan | four existing nose fields in `BeautyEffectiveStrengths` | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | internal safety constants | normalized values -> capped strengths | current nose constants | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | planner/orchestrator | public values + optional geometry -> effective strengths/domains/warnings/metrics | existing four-field nose activation, zeroing, reuse, and provider branch | exact structural; omission-prone |
| `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | combined-safety reducer | all geometry strengths -> scaled strengths + aggregate metadata | existing nose scale/total/count entries | exact structural |
| `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` | package-internal geometry model | adapter/test fixtures -> provider inputs | defaulted `FaceGeometry` landmark arrays | structural; new support fields |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` | package-internal adapter | selected redacted observation/group availability -> deterministic proxy geometry | current `nose(in:)` plus eye/lip support builders | exact role; new root/tip builders |
| `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` | geometry provider | effective six-field nose strengths + private supports -> control points | `slimPoints`, `wingPoints`, `tipPoints`, `bridgePoints`, `makePoint` | structural; new vector semantics |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | public contract unit tests | defaults/abnormal/mutated/JSON values -> exact model state | inventory, normalization, Codable, Sendable tests in same file | exact |
| `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | resource compatibility test | bundled preset files -> decoded parameters | `builtInPresets()` completeness test | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | cap constant test | internal constants -> exact numeric lock | current canonical constant assertions | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | resolver unit/integration tests | isolated public fields + fixture -> cap, route, activation, aggregate evidence | eye/nose cap tables, negative no-op, `requiresFaceGeometry`, selected observation | exact |
| `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` | provider vector tests | valid/invalid private supports + one effective field -> exact control-point semantics | existing nose direction/determinism/missing tests; face-slim symmetry assertion | structural; new strict assertions |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | shared fixture owner | named `FaceGeometry` variants -> provider/resolver test inputs | `.fixture`, `.missingNose`, `.reused`, `.stale` | exact role; fixtures only |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | degradation integration tests | missing/stale/reused/insufficient geometry -> zero/scale/skip/continuation | `testNOSE05StaleZerosNoseWhileReusedScalesAllFieldsByHalf`, `assertNoseStrengthsAreZero` | exact structural |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | conflict unit tests | effective strengths -> total, scale, weakened count | existing all-field helper and metadata test | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | representative conflict integration | isolated vs combined request -> positive nonzero weakened values | `testNOSE06EveryNoseFieldWeakens...` | exact structural |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | public-facade integration | SPI detector fixture + isolated public request -> same-extent redacted result | `testGeometryTriggeredStillImageRunsDetectionAndRoutesSelectedFace` | exact |
| `DESIGN.md` | owning public/design contract | implemented model/provider semantics -> durable invariant | `4.2 BeautyParameters`, Phase 32 nose safety contract | exact role |
| `RELIABILITY.md` | owning degradation contract | freshness/insufficient geometry -> fail-closed behavior | Phase 32 nose freshness contract | exact role |
| `SECURITY.md` | owning trust-boundary contract | inventory/private supports/redacted diagnostics -> allowed surface | Phase 32 nose boundary evidence | exact role |
| `PRODUCT_SENSE.md` | current acceptance/non-claim contract | frozen independent semantics -> pending product rows | Phase 32 nose slice acceptance | exact role |
| `PLANS.md` | repository execution ledger | observed edits/verification -> traceable status | current active v1.9 plan and prior phase completion entries | exact role |
| `.planning/phases/35-public-contract-and-independent-geometry/35-VERIFICATION.md`, `35-VALIDATION.md`, `35-REVIEW.md`, `35-SECURITY.md`, `35-SUMMARY.md` | phase evidence artifacts | executed tests/scans/review -> NOSE-01...06 verdict and handoff | Phase 30/34 artifacts | exact role |
| `ARCHITECTURE.md` (conditional) | internal boundary invariant | new private support model -> dependency/privacy rule | existing `FaceGeometry`/`WarpControlPoint` private-boundary rule | update only if support boundary merits a durable invariant |

Expected **non-edits**: `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`, bundled preset JSON, `BeautyExampleRenderer`, `BeautyDemo`, `QUALITY_SCORE.md`, `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, branch READMEs, and generated output/gallery files. Planning workflow may update `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, and `.planning/STATE.md` only from executed evidence.

## Concrete Implementation Patterns

### 1. Add the public fields through all six `BeautyParameters` seams

Place both fields after `noseBridge` and before mouth fields in every manual list:

```swift
public var noseRootNarrowing: Float
public var noseTipLift: Float

case noseRootNarrowing
case noseTipLift
```

Use defaulted labeled initializer arguments and the existing positive-only clamp family:

```swift
noseRootNarrowing: Float = 0,
noseTipLift: Float = 0,

self.noseRootNarrowing = Self.clampUnit(noseRootNarrowing)
self.noseTipLift = Self.clampUnit(noseTipLift)
```

Follow the exact existing missing-key and normalized-copy patterns:

```swift
noseRootNarrowing: try container.decodeFloatIfPresent(.noseRootNarrowing),
noseTipLift: try container.decodeFloatIfPresent(.noseTipLift),
```

```swift
noseRootNarrowing: noseRootNarrowing,
noseTipLift: noseTipLift,
```

`decodeFloatIfPresent` already maps absent keys to `0`; `clampFinite` already maps all non-finite values to `0`. Do not add custom decoding, an alternate normalization layer, or hand-written encoding.

Tests should extend, not replace, these exact patterns:

```swift
XCTAssertEqual(Mirror(reflecting: BeautyParameters()).children.count, 33)
```

- defaults and distinct stored/equality behavior;
- negative -> `0`, overflow -> `1`, `.nan`/both infinities -> `0` for both fields;
- mutate public vars after initialization, call `normalized()`, and assert re-normalization;
- decode representative old JSON with no new keys -> both `0`;
- encode/decode nonzero new values -> exact equality;
- retain the compile-time `Sendable` assertion.

### 2. Preserve preset absence as the compatibility behavior

Use the existing catalog seam:

```swift
let presets = try BeautyResourceCatalog.bundled().builtInPresets()
for preset in presets {
    XCTAssertEqual(preset.parameters.noseRootNarrowing, 0, preset.id)
    XCTAssertEqual(preset.parameters.noseTipLift, 0, preset.id)
}
```

Do not add explicit zero-valued keys to the five preset JSON files. Their absence directly exercises the old-payload decoding path.

### 3. Extend every effective-strength and cap enumeration

`BeautyEffectiveStrengths` follows the adjacent stored-var pattern:

```swift
public var noseRootNarrowing: Float = 0
public var noseTipLift: Float = 0
```

`BeautySafetyCaps` locks the provisional values:

```swift
static let noseRootNarrowing: Float = 0.25
static let noseTipLift: Float = 0.25
```

Resolver assignment uses `capUnit`, matching the public positive-only range:

```swift
strengths.noseRootNarrowing = capUnit(
    normalized.noseRootNarrowing,
    cap: BeautySafetyCaps.noseRootNarrowing,
    cappedCount: &cappedCount
)
strengths.noseTipLift = capUnit(
    normalized.noseTipLift,
    cap: BeautySafetyCaps.noseTipLift,
    cappedCount: &cappedCount
)
```

Add both fields to all of these current symbols/lists:

- `requiresFaceGeometry(parameters:)`;
- `hasReusableNonEyeGeometryValues`;
- the nose-domain `anyNonZero(...)` guard;
- `zeroNoseStrengths(_:)`;
- `scaleReusableNonEyeGeometryStrengths(_:by:)`;
- `GeometryConflictResolver.resolve` scale assignments;
- `geometryTotal(_:)` as positive values;
- `nonZeroFaceShapeFieldCount(_:)`.

The cap-table analog in `BeautyEffectResolverTests` should assert for each isolated field: exact `0.25`, `.nose` active on valid supports, capped count `1`, cap warning present, no conflict warning. The negative-no-op analog should assert public/effective zero, `requiresFaceGeometry == false`, neither active nor skipped `.nose`, and capped count `0`.

### 4. Refine private geometry without changing `FaceGeometry.nose`

The closest safe pattern is the existing defaulted landmark arrays in `FaceGeometry.init`. Add explicit package-internal supports with default-empty arguments, for example:

```swift
let noseRoot: [SIMD2<Float>]
let noseTip: [SIMD2<Float>]

init(
    bounds: FaceBounds,
    faceContour: [SIMD2<Float>],
    leftEye: [SIMD2<Float>] = [],
    rightEye: [SIMD2<Float>] = [],
    nose: [SIMD2<Float>] = [],
    noseRoot: [SIMD2<Float>] = [],
    noseTip: [SIMD2<Float>] = [],
    outerLips: [SIMD2<Float>] = [],
    freshness: LandmarkGeometryFreshness = .fresh
)
```

The exact names are discretionary, but the data must be explicit and auditable. In `BeautyFaceGeometryAdapter.makeGeometry(from:)`, populate them only when `.nose` is available. Follow the existing `point(bounds,x:y:)` builder so all proxy inputs are deterministic and normalized.

Required adapter invariant:

```text
legacy nose proxy -> byte-for-byte/source-point unchanged
root support      -> exactly paired, same Y, left/right of stable centerline
tip support       -> deterministic lower subset
missing .nose     -> nose, root support, and tip support all empty
```

Do not synthesize arbitrary mirrored sources inside `NoseWarpProvider`; support provenance should remain visible in the adapter/fixture.

### 5. Add two independent provider branches with per-feature guards

Follow the current branch shape in `NoseWarpProvider.makeControlPoints`:

```swift
if strengths.noseRootNarrowing > 0 {
    points.append(contentsOf: rootNarrowingPoints(face: face, strength: strengths.noseRootNarrowing))
}
if strengths.noseTipLift > 0 {
    points.append(contentsOf: tipLiftPoints(face: face, strength: strengths.noseTipLift))
}
```

Keep the existing top-level legacy `face.nose` center guard only if it cannot prevent valid explicit new supports from working and cannot let legacy nose data rescue invalid new supports. The safer implementation may need to distinguish requested legacy paths from requested new paths rather than returning globally on one missing input.

Root helper invariants:

- require exactly a valid left/right pair (or deterministically select a pair from explicitly valid support);
- every coordinate finite; same source Y within epsilon; left X < centerline < right X;
- horizontal displacement only: target Y == source Y;
- equal absolute inward X displacement; target X cannot cross the centerline;
- nonzero displacement and deterministic left-to-right ordering;
- empty/one-point/non-finite/same-side/degenerate/crossed support -> no root points.

Tip helper invariants:

- require a nonempty, finite, lower-tip support subset of the expected minimum size;
- vertical displacement only: target X == source X;
- normalized top-to-bottom coordinates mean lift requires target Y < source Y;
- deterministic ordering and nonzero displacement;
- empty/insufficient/non-finite/degenerate support -> no tip-lift points.

Reuse `makePoint` only after pre-clamp validation. Its current shape is the exact bounds/radius analog:

```swift
WarpControlPoint(
    source: LandmarkGeometryHelper.clamp(source),
    target: LandmarkGeometryHelper.clamp(target),
    radius: min(max(radius, 0.03), 0.20),
    strength: strength,
    falloff: 2
)
```

Because clamping can conceal invalid calculations, guard/assert finiteness, intended direction, and nonzero displacement before accepting bounded output.

### 6. Prove non-aliasing by complete vectors, not counts

Use isolated provider requests on the same valid fixture:

```swift
let root = provider.makeControlPoints(face: .fixture, strengths: strengths(noseRootNarrowing: 1))
let bridge = provider.makeControlPoints(face: .fixture, strengths: strengths(noseBridge: 1))

XCTAssertNotEqual(root.points, bridge.points)
XCTAssertNotEqual(root.points.map(\.source), bridge.points.map(\.source))
XCTAssertNotEqual(root.points.map(\.target), bridge.points.map(\.target))
```

For lift, compare against both positive and negative `noseTipSize`. Also compare displacement vectors (`target - source`) so equal sources with different motion are classified correctly. Point-count inequality alone is insufficient.

Add named fixtures beside the shared `FaceGeometry.fixture` owner for valid, missing, one-point, non-finite, and degenerate root/tip supports. Preserve all legacy fields of `.fixture`, `.missingNose`, `.reused`, and `.stale`; extend them with supports rather than changing their current `nose` arrays.

### 7. Degradation must zero/scale both new effective strengths

Extend `assertNoseStrengthsAreZero(_:)` and the existing Phase 32 freshness test:

```swift
XCTAssertEqual(plan.effectiveStrengths.noseRootNarrowing, 0)
XCTAssertEqual(plan.effectiveStrengths.noseTipLift, 0)
```

For reused valid geometry, the existing non-eye contract gives exact cap times `0.5`:

```swift
XCTAssertEqual(plan.effectiveStrengths.noseRootNarrowing, 0.125, accuracy: 0.0001)
XCTAssertEqual(plan.effectiveStrengths.noseTipLift, 0.125, accuracy: 0.0001)
XCTAssertEqual(plan.metrics["beauty.effects.reusedGeometryScale"], 0.5)
```

Required isolated provider-empty cases must show the affected new request does not become active and does not borrow a legacy bridge/tip point. When a mixed request includes another valid nose field, test the new helper separately so nonempty aggregate provider output cannot mask its failure. Safe color/filter domains must continue and all warnings/metrics remain category-level/redacted.

### 8. Conflict tests must cross the existing invocation seam

Add both fields to the `GeometryConflictResolverTests.strengths(...)` helper and its local `geometryTotal` mirror. For direct resolver evidence, include both new values in the all-field metadata case and assert the exact chosen weakened count.

For integration evidence, reuse the existing isolated-vs-combined pattern:

```swift
let normal = BeautyEffectResolver.resolve(parameters: newNoseOnly, faceGeometry: .fixture)
var combinedParameters = newNoseOnly
combinedParameters.faceSlim = 1
combinedParameters.eyeSize = 1
combinedParameters.mouthSize = 1
let combined = BeautyEffectResolver.resolve(parameters: combinedParameters, faceGeometry: .fixture)

XCTAssertGreaterThan(combinedValue, 0)
XCTAssertLessThan(combinedValue, normalValue)
XCTAssertTrue(combined.warnings.contains { $0.code == "combined_geometry_weakened" })
```

Do not infer that an isolated nose-only request must produce a conflict warning; current call placement does not do that. Do not refactor to a single conflict pass unless a Phase-35 correctness test requires it.

### 9. Public facade evidence stays aggregate and uses the existing SPI fixture

Table-drive the two isolated public requests through the exact current test seam:

```swift
let cases = [
    BeautyParameters(noseRootNarrowing: 1),
    BeautyParameters(noseTipLift: 1),
]
```

Create a fresh `SDKTestingFaceDetectionProvider([.usableFace])` and engine for each case (or otherwise reset invocation accounting). Assert invocation count `1`, unchanged extent, `.usable`, face count/used face count `1`, `beauty.detection.geometryRequired == 1`, and `beauty.effects.geometryPointCount > 0`; reuse `assertRedacted(result)`.

Do not expose active domains, supports, landmarks, or control points through `BeautyResult`. Provider vector semantics remain in `NoseWarpProviderTests`; facade evidence remains summaries and numeric aggregate metrics.

## Ordering and Dependency Hazards

1. **Public model first.** Add all six `BeautyParameters` seams plus focused compatibility tests before resolver/provider call sites use the new fields.
2. **Private support representation before provider behavior.** Freeze valid/invalid root and tip fixtures, keep legacy `nose` unchanged, then write helpers. If a symmetric root pair cannot be represented honestly, fail the geometry task rather than aliasing `noseBridge`.
3. **Effective model/caps before resolver.** `BeautyEffectiveStrengths` and cap constants must exist before resolver/provider/test helpers compile.
4. **Provider before facade integration.** `requiresFaceGeometry` alone can invoke detection while yielding zero geometry points; provider tests must pass before facade `geometryPointCount > 0` can be trusted.
5. **Every manual enumeration moves together.** Missing one resolver/conflict list creates partial behavior: detection without activation, cap without zeroing, reuse without scaling, or weakening-count drift.
6. **Avoid global fallback masking.** The provider currently has one top-level `face.nose` center guard and one aggregate result. Field-specific support failure must not be rescued by legacy nose points or hidden by another requested field's output.
7. **Conflict placement is order-sensitive.** Current resolver can resolve conflict in face-shape and again in mouth. Preserve current behavior in Phase 35 and use representative assertions; do not hard-code a desired single-pass value that belongs to Phase 37.
8. **Docs follow observed implementation.** Update current contract owners after the public/runtime contract passes focused tests; keep `山根`, `提升`, and branch-level `鼻子` unpromoted.
9. **Full regression last.** Existing nose proxy/provider tests and full SwiftPM tests are the guard that both new zero values leave shipped face/eye/nose/mouth/color/filter behavior unchanged.

## Verification Pattern

Focused suites should run in dependency order:

```bash
swift test --package-path BeautySDK --filter BeautyParametersTests
swift test --package-path BeautySDK --filter BeautyResourceCatalogTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautySafetyCapsTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.NoseWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK
```

Then scan the omission and boundary surfaces:

```bash
rg -n "noseSlim|noseWingSlim|noseTipSize|noseBridge|noseRootNarrowing|noseTipLift" \
  BeautySDK/Sources/BeautyEffects BeautySDK/Tests/BeautyEffectsTests

rg -n "public|@_spi" BeautySDK/Sources | \
  rg "FaceGeometry|WarpControlPoint|BeautyFaceObservation|landmark|control.?point"

git diff -- BeautySDK/Sources/BeautyExampleRenderer BeautyDemo
git diff -- docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md \
  docs/meitu-function-blueprint/FEATURE_MATRIX.md
git diff --check
```

Classify raw-geometry matches manually: the requirement is no new public/SPI exposure, not zero internal declarations. Record actual post-change test counts. Phase 35 evidence must map direct unit coverage plus the next integration layer to NOSE-01 through NOSE-06, while explicitly deferring renderer/gallery evidence, final cap calibration, exhaustive once-only weakening, active-source closeout scans, ledger promotion, and branch completion.
