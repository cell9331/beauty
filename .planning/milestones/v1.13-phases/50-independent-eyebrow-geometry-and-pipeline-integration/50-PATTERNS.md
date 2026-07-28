# Phase 50: Independent Eyebrow Geometry and Pipeline Integration - Pattern Map

**Mapped:** 2026-07-24  
**Files classified:** 22  
**Closest live analogs:** 5 strong analog families  
**Scope:** SwiftPM provider/routing behavior only; no Demo, decoded gallery, final-cap, or promotion work.

## File Classification

| New / Modified File | Role | Data Flow | Closest Analog | Match |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift` (new) | provider/service | transform | `Warp/EyeWarpProvider.swift` | exact role + flow |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` | model | transform | existing eye/nose/mouth strength fields in same file | exact seam |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectDomain.swift` | model/config | transform | `.eyes`, `.nose`, `.mouth` in same file | exact seam |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | config | transform | Phase 44/48 final-cap groups in same file | exact seam |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service | request-response + transform | existing face/eye/nose/mouth resolution in same file | exact seam |
| `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | service | transform | existing 37-field inventory in same file | exact seam |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | service | transform | current five-provider concatenation in same file | exact seam |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` | test utility/provider | request-response | face-contour fixture cases in same file | exact seam |
| `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` (new) | test | transform | `EyeWarpProviderTests.swift` | exact role + flow |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | test | request-response | existing named-domain/cap tests | exact seam |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | test | transform | existing exact 37-field ledger tests | exact seam |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | test | transform | Phase 48 final-mask/dispatch agreement | exact seam |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | test | event-driven lifecycle | face/nose/mouth partial-support cases | role match |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift` | test | transform | current provider-order and no-op cases | exact seam |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | test | request-response | existing deterministic detector/facade cases | exact seam |
| `.planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration/check_eyebrow_geometry_boundaries.py` (recommended new) | test utility | batch/file-I/O | Phase 49 eyebrow boundary checker | role match; preserve historical checker |
| `ARCHITECTURE.md` | documentation | transform | current provider/unified-warp invariants | owner update |
| `DESIGN.md` | documentation | transform | current geometry state/pipeline contract | owner update |
| `SECURITY.md` | documentation | request-response | current biometric-adjacent redaction boundary | owner update |
| `RELIABILITY.md` | documentation | event-driven lifecycle | current freshness/degradation/accounting contract | owner update |
| `PRODUCT_SENSE.md` | documentation | request-response | current row acceptance/nonclaim language | owner update |
| `PLANS.md` | planning ledger | batch | active v1.13 plan record | owner update |

## Pattern Assignments

### `EyebrowWarpProvider.swift` and `EyebrowWarpProviderTests.swift`

**Primary analog:** `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift`

Copy the imports, immutable named-emission carrier, stable concatenation, field-local sanitization, provider result, and private geometry-helper shape. The decisive excerpt is lines 1-44:

```swift
import Foundation
import BeautyDetection

struct EyeWarpFieldEmissions: Equatable, Sendable {
    let eyeSize: [WarpControlPoint]
    // ...one immutable array per public field...

    var points: [WarpControlPoint] {
        eyeSize + eyeDistance + eyeYPosition + eyeTailLift /* ... */
    }

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
        var sanitized = strengths
        if strengths.eyeSize != 0, eyeSize.isEmpty { sanitized.eyeSize = 0 }
        // field-local only
        return sanitized
    }
}
```

Copy the provider entry shape from lines 61-99:

```swift
func makeControlPoints(face: FaceGeometry, strengths: BeautyEffectiveStrengths) -> WarpControlPointResult {
    let emissions = fieldEmissions(face: face, strengths: strengths)
    let requestedWork = [/* named strengths */].contains { abs($0) > Float.ulpOfOne }
    return WarpControlPointResult(
        points: emissions.points,
        skipReason: requestedWork && emissions.points.isEmpty ? "eye_inputs_missing" : nil
    )
}
```

Use `face.observedEyebrowSupport` directly. Unlike the eye provider's compatibility fallback at lines 117-142, the eyebrow provider must **not** construct legacy/synthetic support, re-sort, remap, close, or repair traces. For the six per-side-capable fields, `compactMap`/`flatMap` each independently present semantic trace. Gate only whole spacing on a valid distinct pair. Gate peak only on the stored interior `apexIndex`.

Follow the validation style shown by the eye helpers (for example lines 145-170 and 180-205): validate eligibility and finite/nondegenerate derived values first, return `[]` on failure, and construct bounded `WarpControlPoint`s only after source, target, radius, strength, and displacement are valid. Do not depend on final renderer clamping to legitimize invalid work.

Test shape comes from `EyeWarpProviderTests.swift`: build explicit semantic fixtures, call `fieldEmissions`, assert named arrays rather than only aggregate points, compare positive/negative vectors, then assert `sanitizing` is idempotent. Phase 50 needs asymmetric two-side, left-only, right-only, pair-invalid, nil-apex, degenerate-chord, mirrored/reversed, field-isolation, and sibling-provider byte-equality cases.

**Provider landmines:**

- Thickness must use balanced samples on both normal sides of an unchanged centerline; moving trace points in one direction aliases vertical position.
- Length uses only the outer endpoint neighborhood; head spacing uses only the inner endpoint neighborhood. Their source sets must differ from whole spacing.
- Tilt sign must derive from the canonical inner-to-outer chord so mirrored sides agree in product direction.
- Peak consumes the stored unique apex; never recompute a maximum or synthesize a midpoint.
- Six signed fields use `abs(strength) > ulp`; peak is positive-only.

### Planning model, domain, and caps

**Analogs:** `BeautyEffectPlan.swift`, `BeautyEffectDomain.swift`, `BeautySafetyCaps.swift`

Append seven `Float = 0` members beside eye and before nose in `BeautyEffectiveStrengths` (current contiguous field groups are lines 39-75). Add a distinct `.eyebrows` case beside `.eyes` (domain lines 5-9); do not alias brow activity to `.eyes` or `.faceShape`.

Cap declarations follow the grouped constants in `BeautySafetyCaps.swift` lines 20-52. Phase 50 research recommends seven explicitly provisional `0.25` caps. Keep the comment provisional: Phase 52, not this phase, owns final calibration. Preserve normalized public values until applying these caps once in the resolver.

### `BeautyEffectResolver.swift`

**Primary analog:** existing face/eye/nose/mouth path in the same file.

Extend every existing named seam together:

1. `requiresFaceGeometry(parameters:)` (starts line 9).
2. normalized-to-capped effective-strength construction.
3. requested/reusable-work predicates, reuse/stale/no-face helpers, and exact-once freshness handling.
4. provider preflight sanitization.
5. retained-baseline conflict convergence.
6. final emissions, `.eyebrows` active/skipped domain, fixed warning, aggregate metric, and geometry-point count.

The monotone convergence analog is lines 559-592:

```swift
var retainedBaseline = strengths
// preflight sanitize each provider in stable order
for _ in 0..<37 {
    let resolution = GeometryConflictResolver().resolve(strengths: retainedBaseline)
    var nextBaseline = faceProvider
        .fieldEmissions(face: faceGeometry, strengths: resolution.strengths)
        .sanitizing(retainedBaseline)
    // chin -> eye -> nose -> mouth
    if nextBaseline == retainedBaseline { return resolution }
    retainedBaseline = nextBaseline
}
```

Evolve this to exactly `0..<44` and stable order Face → Chin → Eye → Eyebrow → Nose → Mouth. Providers are evaluated with `resolution.strengths` but sanitize `retainedBaseline`; using scaled values as the next baseline double-scales, while rebuilding from requests revives removed fields.

Eyebrow freshness should follow the locked “reused eligible geometry scales exactly once” rule: apply `0.5` in the resolver once, keep the provider stateless, then apply the shared conflict scale once. Stale/no-face zeros brow fields. Record the recommended dedicated domain and reuse policy explicitly in the first implementation plan because RESEARCH marks both as assumptions.

Final accounting must come from final eyebrow emissions: if any requested eyebrow field survives, insert `.eyebrows` and add exactly `emissions.points.count`; if all requested work is empty, zero only empty fields and emit a fixed aggregate warning such as `eyebrow_inputs_missing` plus `beauty.effects.skippedEyebrowDomains = 1`. Never include side, point, endpoint, center, axis, apex, or displacement details.

### `GeometryConflictResolver.swift` and combined safety tests

**Primary analog:** the three parallel inventories in `GeometryConflictResolver.swift`.

Lines 22-60 scale every retained geometry field; lines 77-117 compute the absolute-value total; lines 120-159 compute the nonzero count. Add all seven eyebrow fields to **all three** lists exactly once. Signed fields use `abs` for totals/counting; peak is nonnegative. Missing one list creates strengths/metric/dispatch drift.

With the recommended provisional caps, update the exact ledger from 37 / `11.70` to 44 / `13.45`: face+chin `3.35`, eye `4.10`, eyebrow `1.75`, nose `1.80`, mouth `2.45`; expected scale `1 / 13.45`, weakened count `44`, final total `1.0`.

Copy `CombinedEffectSafetyTests.swift` lines 86-152: evaluate every final provider emission, sanitize in dispatch order, assert the final plan is unchanged by another sanitization pass, then compare concatenated named emissions directly to `BeautyGeometryEffectPipeline.controlPoints`. Update the static source assertion from one `0..<37` to one `0..<44`; do not loosen it to a vague range.

### `BeautyGeometryEffectPipeline.swift`

**Primary analog:** lines 5-20.

```swift
guard !plan.activeDomains.isDisjoint(with: [.faceShape, .eyes, .nose, .mouth]) else {
    return []
}

return FaceShapeWarpProvider().makeControlPoints(...).points +
    ChinWarpProvider().makeControlPoints(...).points +
    EyeWarpProvider().makeControlPoints(...).points +
    NoseWarpProvider().makeControlPoints(...).points +
    MouthWarpProvider().makeControlPoints(...).points
```

Add `.eyebrows` to the guard and insert `EyebrowWarpProvider` exactly once between eye and nose. Do not add a new renderer, pre-warp, public route, or second scale. Preserve the existing render implementation below line 22 unchanged.

### `BeautyEngineTestingSupport.swift` and facade tests

**Primary analog:** `BeautyEngineTestingSupport.swift` lines 5-33 and 35-101.

Add deterministic finite raw eyebrow arrays near the existing face-contour fixtures, extend fixture cases for usable/missing/malformed brow support, and attach brow support to the same `VisionDetectionObservation` used by `.usableFace`. Preserve the locked detector-count behavior and existing `NSLock`/sequential fixture pattern at lines 46-63 and 132-139.

Facade tests should copy existing `BeautyEngineGeometryFacadeTests` request-response structure: create a testing provider, call one public `BeautyEngine.processResult` route, assert exactly one detection, unchanged extent, brow domain/effective strength/aggregate point evidence, and redacted warnings/metrics. Do not expose raw support through public or SPI results and do not generate Phase 51 image/gallery cases.

### Degradation, pipeline, and resolver tests

- In `BeautyEffectResolverTests`, deliberately replace `testBROW02SevenNonzeroEyebrowFieldsRemainRuntimeInert`; retain explicit-zero neutrality, then add positive cap/routing/domain tests.
- In `MissingLandmarkDegradationTests`, copy the existing field-table pattern (named parameter, effective-strength key path, emission key path). Assert per-side survival for six fields, pair-only spacing failure, apex-only peak failure, no re-entry, sibling/non-brow continuation, reused `0.5`, stale/no-face zero, and no unrelated conflict weakening.
- In `GeometryConflictResolverTests`, keep exact names, totals, counts, signs, and scale; do not assert only “less than one.”
- In `BeautyGeometryEffectPipelineTests`, assert eyebrow-only dispatch is nonempty and the provider appears once in the same order used by resolver accounting.

## Shared Patterns

### Fail-closed validation

Provider helpers return an empty named array for invalid/nonfinite/degenerate work. `sanitizing(_:)` then zeros only that named strength. Final clamping is a rendering defense, not provider validation.

### Monotone final mask

Preflight provider eligibility before the first total; after every shared-scale calculation, re-evaluate all six provider groups against the retained baseline. Removed fields never re-enter, and scaled values never become the next baseline.

### Aggregate-only diagnostics

Copy existing fixed warning codes/messages and numeric counters. Do not log or surface side identity, raw/canonical coordinates, counts per side, endpoints, centers, apex indices, axes, normals, or vectors.

### Exactly-once unified dispatch

Resolver point accounting and pipeline point concatenation must use the same final named emissions in the same provider order. There is one shared scale and one existing geometry warp.

### Boundary checker

Create a Phase 50-local checker only if the plan adopts RESEARCH assumption A7. Model it on the Phase 49 checker but keep the historical checker byte-stable. Its live checks should reject dependency/model/resource/Demo/network/persistence/public-geometry/renderer-gallery drift, raw diagnostic leakage, alternate brow support, wrong loop/provider order, and tracked generated artifacts; include adversarial self-tests.

## No Close Analog

| File / Concern | Reason | Planner Guidance |
|---|---|---|
| `EyebrowWarpProvider.swift` geometry formulas | No existing provider has canonical open brow traces, normal-strip thickness, pair-only spacing, and stored-apex peak in one type. | Use the eye provider's carrier/validation structure, but implement semantics from `50-CONTEXT.md`; treat RESEARCH constants as provisional assumptions. |
| Phase 50 boundary checker | No Phase 50 checker exists. | Copy checker architecture from Phase 49, not its obsolete “runtime inert” assertions. |

## Planning Landmines

- `.eyebrows`, all-seven `0.25` caps, reused `0.5`, exact geometric constants, endpoint-neighborhood sizes, and the new checker are RESEARCH recommendations, not locked code facts; record adoption explicitly.
- The existing eye provider has a legacy fallback. Copying that fallback for eyebrows violates the Phase 49 provenance boundary.
- One malformed side must not erase the valid sibling; only whole spacing is pair-gated.
- Provider-empty brow work must be removed before it enters the shared total, or unrelated domains will be weakened.
- Adding strengths without updating scale, total, count, loop, final emissions, metrics, and dispatch together breaks PIPE-02.
- Phase 50 must not change renderer/gallery inventories, call caps final, or mark any `眉毛` row implemented.
- Owner-document edits belong to implementation plans, but PATTERNS.md is the only file changed by this mapping task.

## Metadata

**Search scope:** `BeautySDK/Sources/BeautyEffects`, `BeautySDK/Sources/BeautySDK`, `BeautySDK/Tests/BeautyEffectsTests`, `BeautySDK/Tests/BeautyCoreTests`, Phase 49/50 planning artifacts, root owner documents.  
**Strong analogs read:** `EyeWarpProvider.swift`, `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, `BeautyGeometryEffectPipeline.swift`, `BeautyEngineTestingSupport.swift`; supporting model/config files and test pattern locations inspected.  
**Pattern extraction date:** 2026-07-24.
