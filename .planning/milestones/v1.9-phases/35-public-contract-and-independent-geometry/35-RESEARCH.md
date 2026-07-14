# Phase 35: Public Contract and Independent Geometry - Research

**Researched:** 2026-07-13  
**Domain:** Swift public-model compatibility, geometry routing, nose-provider semantics, fail-closed internal geometry, and facade-safe evidence  
**Confidence:** HIGH for public-model/resolver integration; MEDIUM for the upper-root anchor design until the implementation proves a valid symmetric pair

## Research Question

What must be known to plan Phase 35 well enough to close NOSE-01 through NOSE-06 without borrowing the existing `noseBridge` or signed `noseTipSize` behavior?

The phase should be planned as three implementation/evidence seams, followed by contract synchronization:

1. grow `BeautyParameters` from 31 stored fields (30 numeric plus `filterId`) to 33 stored fields (32 numeric plus `filterId`) while preserving source-rebuild and JSON compatibility;
2. add both fields to every manually enumerated effective-strength, activation, freshness, zeroing, reuse, and conflict path;
3. implement and prove two new provider paths with distinct source subsets and motion axes;
4. update the current owners of the changed public/reliability/security contracts, while leaving renderer evidence and row/branch promotion to Phases 36 and 37.

No new package target, render pass, external dependency, public geometry type, Demo UI, renderer case, gallery, or generated PNG belongs in this phase.

## Locked Phase Contract

The planner must treat `35-CONTEXT.md`, live `REQUIREMENTS.md`, and the reconciled `.planning/research/SUMMARY.md` as authoritative over conflicting historical research and `docs/` background material.

| Field | Public contract | Provisional effective cap | Geometry contract | Explicit non-claim |
| --- | --- | --- | --- | --- |
| `noseRootNarrowing` | Positive-only `Float`, normalized to `0...1`, default `0`, non-finite -> `0` | `0.25` | A deterministic upper-root pair contracts horizontally toward a stable nose centerline with equal/opposite inward motion; source and target Y are equal | Not physical height/depth, lighting, `noseBridge`, or a bridge alias |
| `noseTipLift` | Positive-only `Float`, normalized to `0...1`, default `0`, non-finite -> `0` | `0.25` | A deterministic lower-tip subset moves upward only; source and target X are equal | Not whole-nose translation, downward motion, signed resizing, or `noseTipSize` |

Compatibility means source clients rebuild against defaulted initializer arguments and old JSON/presets decode with both fields at zero. It does not mean ABI compatibility for already compiled binaries.

## Requirement-to-Evidence Map

| Requirement | Required implementation | Minimum convincing evidence |
| --- | --- | --- |
| NOSE-01 | Two distinct public stored fields, `clampUnit` initialization, defaulted arguments, no legacy storage reuse | Defaults, negative/overflow, `NaN`/both infinities, mutation followed by `normalized()`, distinct storage/equality, exact 33-field inventory |
| NOSE-02 | Coding keys, missing-key decoding, encode/decode, normalized-copy forwarding; presets remain absent/neutral | Decode a representative encoded 31-field payload, round-trip nonzero new values, load every bundled preset and assert both new values are zero, compile existing source-style calls |
| NOSE-03 | Effective strengths, caps, geometry-required detection, activation, metrics, freshness/reuse/zeroing, conflict totals/counts/scaling, provider dispatch, facade route | Each field alone triggers `requiresFaceGeometry`; fresh complete geometry activates `.nose` with nonzero aggregate point count; public engine invokes detection and returns only redacted summaries/metrics; focused freshness/conflict assertions cover both fields |
| NOSE-04 | Independent root helper/path and sufficient private root anchors | Horizontal-only, inward, equal/opposite displacement on an upper-root pair; deterministic order, nonzero bounded points; point sequence/source subset/targets differ from `noseBridge` |
| NOSE-05 | Independent lower-tip lift helper/path | Vertical-only upward displacement on lower-tip sources; deterministic nonzero bounded points; targets differ from both positive and negative signed `noseTipSize` for the same source region |
| NOSE-06 | Per-feature subset guards and provider fail-closed behavior | Empty/malformed/insufficient root and tip fixtures yield no points for the affected new field and never emit bridge/tip-size points; valid outputs are finite, clamped, bounded, deterministic, and non-empty |

## Current Architecture and Exact Integration Seams

### Public Model

`BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` is the sole public parameter owner. It manually enumerates every field in six places:

1. stored properties;
2. `CodingKeys`;
3. the defaulted public initializer signature;
4. initializer assignments and clamp family;
5. `init(from:)` missing-key decode forwarding;
6. `normalized()` copy forwarding.

Both new fields must be added to all six places, adjacent to the existing four nose fields. Use the existing `clampUnit`; do not add a second normalization implementation. JSON cannot normally encode non-finite numbers, so non-finite evidence is programmatic initializer/mutation plus `normalized()` evidence, while missing-key JSON evidence proves old payload compatibility.

`BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` is the primary contract suite. The current `testSDK03DefaultsAreZeroEffectAndExpose31StoredFields` must become an exact 33-field lock. Preserve the historical meaning in archived milestone artifacts; only current source/tests/docs change.

There are 177 current `BeautyParameters(` call sites. Defaulted trailing arguments make most call sites source-compatible. The safest placement is after `noseBridge` and before mouth fields so old labeled calls continue compiling and the nose group remains contiguous. Swift labeled default arguments mean this is source-rebuild compatible; it is not ABI evidence.

Bundled preset JSON files live under `BeautySDK/Sources/BeautyResources/Resources/Presets/`. They currently contain only the four legacy nose keys. Do not mechanically add zero keys merely to make the files look current: absence is the compatibility behavior to test. Load all bundled presets through the resource catalog and assert both new fields decode to zero.

### Effective Strength and Safety Planning

The manually enumerated production hotspots are:

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift`
  - `BeautyEffectiveStrengths`: add two stored effective values.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift`
  - add provisional `noseRootNarrowing = 0.25` and `noseTipLift = 0.25`.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`
  - `requiresFaceGeometry(parameters:)` list;
  - initial `capUnit` assignments and `cappedCount`;
  - `hasReusableNonEyeGeometryValues`;
  - nose-domain `anyNonZero` activation;
  - `zeroNoseStrengths`;
  - `scaleReusableNonEyeGeometryStrengths` exact `0.5` reuse behavior;
  - provider invocation and provider-empty fallback;
  - warning/metric behavior must remain aggregate/category-only.
- `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift`
  - scaling assignments;
  - `geometryTotal` using positive values for both fields;
  - `nonZeroFaceShapeFieldCount` / weakened-count list.

These lists are the largest omission risk. A field that is missing from any one of them can appear public yet fail detection, escape caps, remain nonzero after missing/stale inputs, avoid reuse reduction, or escape combined weakening.

The current resolver invokes `GeometryConflictResolver` in the face-shape block and again in the mouth block, while the standalone nose block does not invoke it. Phase 35 is explicitly allowed to preserve that placement unless correctness requires a refactor; Phase 37 owns exhaustive once-only weakening. Therefore Phase 35 should add both values to the resolver's total/count/scale lists and prove they participate when an established conflict-triggering face/mouth combination is present. Do not broaden this phase into a full resolver-call-placement rewrite.

### Geometry Provider and Internal Face Geometry

`BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` currently contains four independent helpers:

- `slimPoints`: extreme nose X anchors move horizontally inward;
- `wingPoints`: all points at or below the arithmetic nose center move horizontally inward;
- `tipPoints`: that same lower subset moves toward/away from the arithmetic center according to signed `noseTipSize`;
- `bridgePoints`: every point at or above the arithmetic center snaps horizontally toward the center X.

The new effects need their own helper branches. Reusing `bridgePoints`, `tipPoints`, `lowerNosePoints`, or their returned control points unchanged would fail NOSE-04/05 even if pixels changed.

`BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` owns package-internal `FaceGeometry`. `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` converts the selected public-facade observation into deterministic package-only proxy geometry. The adapter currently creates four nose proxy points when the `.nose` group is available:

```text
(0.46, 0.43), (0.50, 0.55), (0.40, 0.64), (0.60, 0.64)
```

relative to face bounds. The shared test fixture similarly has:

```text
(0.48, 0.45), (0.50, 0.52), (0.46, 0.58), (0.54, 0.58)
```

The lower pair is adequate for a vertical-only lift. The current upper points are not an adequate symmetric root pair: they differ in Y and one lies on/near the centerline, so selecting `nose.filter { $0.y <= center.y }` cannot prove equal/opposite nonzero contraction. This is the principal planning hazard discovered by source inspection.

### Recommended Root-Anchor Resolution

Plan an early fail-fast task that locks the private root-anchor representation before writing the provider behavior. The safest compatibility-preserving approach is:

1. keep the existing `FaceGeometry.nose` proxy unchanged so all four shipped nose fields retain their zero-new-field behavior and archived evidence remains meaningful;
2. add package-internal, non-public root/tip support arrays (for example `noseRoot` and `noseTip`) with default-empty initializer arguments, or an equivalently explicit private support type;
3. have `BeautyFaceGeometryAdapter` populate a symmetric upper-root pair and a lower-tip subset only when `.nose` is available;
4. have only the two new provider helpers consume those supports;
5. make empty, one-point, non-finite, non-paired, or degenerate supports return no points without falling back to `face.nose`, `bridgePoints`, or `tipPoints`.

This small internal refinement is justified by the NOSE-F03 condition: inspection shows the current four-point proxy cannot honestly satisfy the frozen symmetric-root contract. It must remain package-internal and redacted. If the executor instead derives root anchors from `face.nose`, tests must prove the derived sources are a genuine symmetric upper-root pair and must prove legacy `noseBridge` points are not substituted. Synthesizing an untracked arbitrary mirrored source inside `NoseWarpProvider` is less auditable and should be avoided.

### Motion and Bounds Semantics

Use a stable centerline (prefer the explicit support-pair midpoint or face/nose centerline chosen by the anchor contract) and calculate displacement from face bounds and the new cap, following existing provider scale conventions. Exact tuning is planner discretion, but the plan should lock these invariants:

- root: exactly paired source anchors, same source Y within a small epsilon, left target X increases, right target X decreases, absolute X displacement is equal within epsilon, targets cannot cross the centerline, target Y equals source Y;
- tip lift: all target X equal source X, all target Y are strictly less than source Y in the repository's normalized top-to-bottom coordinate convention, and the subset is lower than the root subset;
- both: positive strength only, no zero-displacement points, finite source/target/radius/strength/falloff, normalized coordinates in `0...1`, radius clamped to the existing `0.03...0.20`, deterministic source ordering, and strength no greater than the provisional cap;
- non-alias: compare complete point arrays, source arrays, target arrays, and displacement vectors—not only point counts.

Because `LandmarkGeometryHelper.clamp` can hide invalid calculations by converting out-of-range coordinates into apparently bounded output, tests must assert finiteness and nonzero/intended direction before relying on post-clamp bounds.

### Public Facade Route

`BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` already gates detection through `BeautyEffectResolver.requiresFaceGeometry(parameters:)`. No facade signature change is needed. Add two isolated cases to `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`, each using the existing SPI testing detector fixture:

- detector invoked exactly once;
- output extent unchanged;
- detection summary usable and one face selected;
- `beauty.detection.geometryRequired == 1`;
- `.nose` becomes active through resolver evidence;
- aggregate `beauty.effects.geometryPointCount > 0`;
- warning and metric metadata remain redacted.

Do not expose raw provider points through `BeautyResult` to make these tests easier. Provider vector semantics belong in `NoseWarpProviderTests`; the facade test proves routing and redacted observability only.

## Test Files and Patterns to Extend

| File | Phase 35 purpose |
| --- | --- |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | NOSE-01/02 exact defaults, 33 fields, normalization/non-finite behavior, old payload, new round trip, `Sendable` |
| `BeautySDK/Tests/BeautyResourcesTests/*Preset*Tests.swift` or the existing catalog suite | all bundled presets keep both new fields neutral without editing preset JSON |
| `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | provisional exact `0.25` constants |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | isolated caps/counts, negative silent no-op, independent geometry-required detection, fresh activation, redaction |
| `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` | subset/axis/direction/symmetry/non-alias/determinism/bounds/insufficient-input evidence |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | both fields included in missing/stale zeroing, reused `0.5`, provider-empty fallback; Phase 37 later expands the exhaustive six-field matrix |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | total, scaling, and weakened count include both new fields |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | representative combined case proves both values weaken and stay positive/nonzero |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | each field alone triggers the existing public facade detector/geometry route with redacted aggregate evidence |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | shared `FaceGeometry` fixtures; add valid/insufficient root/tip variants without weakening existing fixtures |

Prefer requirement-named or clearly Phase-35-named tests. Tests should report the field and failure dimension. Table-driven tests are appropriate for public normalization/caps/routing; separate focused tests are better for geometric semantics because root and tip invariants differ.

## Compatibility and Regression Hazards

1. **Changing the existing `nose` proxy to make root tests pass.** This silently changes `noseSlim`, `noseWingSlim`, `noseTipSize`, and `noseBridge` outputs even when both new fields are zero. Keep legacy proxy inputs stable.
2. **Treating point-count inequality as non-alias proof.** Same sources/vectors with a different count or radius still aliases the semantic path. Compare subsets and vectors.
3. **Using arithmetic center as the symmetric root centerline without checking support geometry.** The current point average is not a reliable paired-root centerline.
4. **Letting one valid legacy nose point rescue an insufficient new subset.** NOSE-06 requires field-specific fail-closed behavior, not whole-nose presence only.
5. **All-or-nothing provider fallback masking a failed requested field.** If legacy and new nose fields are combined, provider output can be non-empty even when one new helper failed. Isolated new-field tests and per-helper tests are mandatory.
6. **Forgetting mutable-value normalization.** Public vars can be changed after initialization; resolver calls `normalized()`, so the normalized-copy path must include both fields.
7. **Stale manual enumerations.** Resolver, conflict resolver, helpers, tests, and documentation all name fields manually. Use `rg` before closeout to enumerate every four-field nose list and make six-field intent explicit.
8. **Counting `filterId` as numeric.** Current inventory is 31 stored = 30 numeric + `filterId`; Phase 35 is 33 stored = 32 numeric + `filterId`.
9. **Updating archived v1.7 files or claiming their evidence.** Archived four-field nose evidence remains immutable and cannot validate the new fields.
10. **Premature output/status work.** Phase 36 owns renderer/helper/gallery/ROI evidence; Phase 37 owns exact final cap lock, exhaustive once-only weakening, active-source boundary scans, ledger row promotion, and SDK-core branch completion.

## Documentation Ownership During Phase 35

The code change creates a current public and runtime contract, so the plan should update current owners in the same phase without promoting product status:

- `DESIGN.md`: current 33-field inventory, six nose fields, positive-only semantics, provisional `0.25` caps, distinct root/tip vector contracts, fail-closed supports;
- `RELIABILITY.md`: missing/stale zeroing and reused `0.5` language must name all six nose strengths once the code does;
- `SECURITY.md`: current public inventory statement must become 33 fields while retaining the no-public-raw-geometry boundary;
- `PRODUCT_SENSE.md`: replace the unresolved alias decision with the frozen independent contracts, but explicitly keep `山根`, `提升`, and branch-level `鼻子` unpromoted pending Phases 36/37;
- `PLANS.md`: record Phase 35 progress and verification evidence as required by repository workflow;
- `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, and `.planning/STATE.md`: update status only from executed evidence, following the phase plan/summary workflow.

`ARCHITECTURE.md` needs an update only if the implementation adds an internal geometry-support boundary worth preserving as an invariant. `FRONTEND.md` should not change because no Demo/UI behavior is in scope. `QUALITY_SCORE.md`, feature ledgers, branch READMEs, and final owner synchronization belong to Phase 37 unless the planner finds a current statement that would otherwise become factually false during Phase 35.

## Recommended Plan Decomposition

### Plan 35-01: Public Contract and Compatibility

- update `BeautyParameters` in all six enumeration points;
- add two effective fields and provisional safety caps;
- add exact defaults/33-field/normalization/non-finite/old-payload/new-round-trip/preset-neutral tests;
- update the primary public contract owner (`DESIGN.md`) if plans are kept atomic by contract.

This plan should not touch provider geometry. It gives NOSE-01/02 an independently verifiable checkpoint.

### Plan 35-02: Internal Supports and Independent Provider Geometry

- establish valid private root/tip support representation without changing legacy nose proxy points;
- add new provider branches and feature-specific fail-closed guards;
- extend fixtures for valid, degenerate, missing, and insufficient supports;
- prove symmetry/axis/direction/nonzero/determinism/finiteness/bounds/non-alias behavior.

This is the highest-risk plan. It should fail before routing work if a valid symmetric root pair cannot be represented honestly.

### Plan 35-03: Resolver, Conflict, and Facade Routing

- add both fields to every resolver and conflict manual list;
- prove independent activation, caps/counts, missing/stale/reused behavior, representative combined weakening, provider-empty fallback, and redacted facade routing;
- avoid the Phase-37 once-only conflict refactor unless a failing correctness test forces it.

### Plan 35-04: Current Contract Synchronization and Phase Verification

- synchronize reliability/security/product/current planning owners without status promotion;
- run focused and full tests;
- scan for stale four-field nose lists, public raw geometry, forbidden new dependencies/imports, renderer changes, and accidental row/branch promotion;
- write Phase 35 verification/validation artifacts mapped exactly to NOSE-01 through NOSE-06.

Plans 35-01 and 35-02 can be designed independently but both touch shared models if private supports live in `FaceGeometry`; execute them sequentially to avoid conflicting fixture/contract edits. 35-03 depends on both. 35-04 is last.

## Validation Architecture

### Validation Layers

| Layer | What it proves | Primary suites |
| --- | --- | --- |
| L1 public value contract | exact field inventory, defaults, ranges, non-finite fallback, equality/storage independence | `BeautyParametersTests` |
| L2 serialization/resource compatibility | old missing keys remain zero, new values round-trip, bundled presets stay neutral | `BeautyParametersTests`, resource catalog/preset tests |
| L3 provider semantics | exact region, paired symmetry, motion axes/directions, non-aliasing, fail-closed subsets, finite deterministic bounds | `NoseWarpProviderTests` plus explicit geometry fixtures |
| L4 resolver/safety integration | caps/counts, effective propagation, domain activation, missing/stale/reused behavior, conflict totals/counts/scaling | `BeautySafetyCapsTests`, `BeautyEffectResolverTests`, `MissingLandmarkDegradationTests`, `GeometryConflictResolverTests`, `CombinedEffectSafetyTests` |
| L5 public facade | each field alone triggers detection and the established redacted geometry route without raw geometry exposure | `BeautyEngineGeometryFacadeTests` |
| L6 regression/boundary | existing behavior passes with both fields zero; no dependency/target/Demo/renderer/status expansion | full SwiftPM suite plus focused source/diff scans |

### Nyquist Sampling Requirements

Every production behavior must have a direct automated assertion at the narrowest layer and at least one integration assertion at the next layer:

- public field -> parameter test + resolver test;
- provider vector -> provider test + fresh resolver activation;
- geometry-required flag -> resolver test + facade detector invocation;
- fail-closed subset -> provider test + resolver zero/skip test;
- reuse/conflict propagation -> resolver/conflict test + representative combined test;
- redaction -> resolver warning/metric scan + facade result scan.

Do not use Phase 36 PNG differences as a substitute for Phase 35 provider-vector proof. Conversely, provider tests alone do not prove facade routing.

### Focused Commands

```bash
swift test --package-path BeautySDK --filter BeautyParametersTests
swift test --package-path BeautySDK --filter BeautyResourcesTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautySafetyCapsTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.NoseWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK
```

Use actual suite names returned by SwiftPM if the resource filter is too broad; record executed test counts rather than assuming them.

### Structural and Boundary Checks

```bash
rg -n "noseSlim|noseWingSlim|noseTipSize|noseBridge|noseRootNarrowing|noseTipLift" \
  BeautySDK/Sources/BeautyEffects BeautySDK/Tests/BeautyEffectsTests

rg -n "public|@_spi" BeautySDK/Sources | \
  rg "FaceGeometry|WarpControlPoint|VisionDetectionObservation|BeautyFaceObservation|landmark|control.?point"

git diff -- BeautySDK/Sources/BeautyExampleRenderer BeautyDemo
git diff -- docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md \
  docs/meitu-function-blueprint/FEATURE_MATRIX.md
git diff --check
```

Interpret the raw-geometry scan manually/classify expected internal declarations; the passing condition is no new public/SPI export, not necessarily zero lexical matches across all source.

### Required Validation Matrix

| Scenario | Root expected | Tip expected | Nose domain | Safe-domain continuation |
| --- | --- | --- | --- | --- |
| default/negative/non-finite | zero/no points | zero/no points | inactive | unchanged |
| fresh valid supports, isolated | paired horizontal nonzero | vertical-up nonzero | active | unchanged |
| missing nose group | zero | zero | skipped | color/filter continue |
| insufficient root only | zero, no bridge fallback | tip unaffected if requested/valid | active only if another valid nose field emits points; isolated root skips | continue |
| insufficient tip only | root unaffected if requested/valid | zero, no tip-size fallback | same rule | continue |
| stale geometry | zero | zero | skipped | safe domains continue |
| reused geometry | exact cap × `0.5` | exact cap × `0.5` | active when valid | safe domains continue |
| representative geometry conflict | positive, nonzero, weakened | positive, nonzero, weakened | active | unchanged |
| public facade isolated request | detector invoked; aggregate points > 0 | detector invoked; aggregate points > 0 | active | extent preserved |

For combined requests, test each new helper in isolation as well: a non-empty legacy result must not hide failure of a requested new path.

### Baseline Observed During Research

Environment: Apple Swift 6.3.3; package tools version 6.0; no external dependencies.

Research-time focused baseline passed:

- `BeautyParametersTests`: 9/9;
- `NoseWarpProviderTests`: 7/7;
- `BeautyEffectResolverTests`: 14/14;
- `BeautyEngineGeometryFacadeTests`: 10/10.

These counts are pre-Phase-35 baselines only. Final verification must report the post-change focused counts and the full SwiftPM count.

## Planning Conclusions

- The public and resolver work follows established repository patterns and is low ambiguity once every manual enumeration is listed.
- The upper-root geometry is not a routine extension of `bridgePoints`: current proxy data lacks a valid symmetric pair. The phase plan must explicitly create a package-internal root support representation while preserving the legacy `nose` proxy, or stop rather than alias.
- The lower-tip lift can use a dedicated lower-tip support subset, but it still needs vertical-only targets and pairwise proof against both signed `noseTipSize` directions.
- Phase 35 can and should prove representative reuse/conflict propagation, but it must leave final cap calibration, exhaustive once-only six-field weakening, renderer evidence, and ledger/branch promotion to the later phases.
- Completion requires all six requirements to have both direct unit evidence and an appropriate integration layer; fields or changed pixels alone are insufficient.

## Sources

Primary current sources: `35-CONTEXT.md`, live `REQUIREMENTS.md`, live `ROADMAP.md`, `STATE.md`, `.planning/research/SUMMARY.md`, `BeautyParameters.swift`, `BeautyEffectPlan.swift`, `BeautySafetyCaps.swift`, `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, `NoseWarpProvider.swift`, `WarpControlPoint.swift`, `BeautyFaceGeometryAdapter.swift`, the focused XCTest files listed above, and current root contracts.

Historical `docs/` parameter suggestions and unreconciled research names/ranges are background only. Archived v1.7 renderer/safety artifacts establish patterns but are not evidence for the two new fields.
