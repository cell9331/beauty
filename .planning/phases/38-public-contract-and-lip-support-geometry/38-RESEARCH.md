# Phase 38: Public Contract and Lip-Support Geometry - Research

**Researched:** 2026-07-14  
**Domain:** Swift public-model compatibility, Vision lip-region availability, package-internal lip supports, independent mouth warp geometry, provider-eligible conflict convergence, and facade-safe evidence  
**Confidence:** HIGH for the public-model/resolver integration seams; MEDIUM for exact M-lip/plump proxy tuning until Phase 39 output evidence

## Research Question

What must be known to plan Phase 38 well enough to close MOUTH-01 through MOUTH-08 without borrowing shipped `mouthSize`, `mouthWidth`, `smile`, or `lipColor` semantics and without entering Phase 39 output or Phase 40 final-safety/promotion scope?

The phase should be planned as four ordered seams:

1. grow `BeautyParameters` from 33 stored fields (32 numeric plus `filterId`) to 38 stored fields (37 numeric plus `filterId`) while preserving source-rebuild, JSON, and bundled-preset compatibility;
2. record `innerLips` independently from required outer-lip geometry and create deterministic package-only upper/lower/inner supports without changing the shipped `outerLips` proxy;
3. expand provider-owned mouth emissions from three to eight independent geometry fields and prove each vector/subset contract directly;
4. thread the five fields through cap, activation, freshness, per-field sanitization, conflict convergence, public-facade routing, redacted diagnostics, and current contract synchronization.

No renderer case, saved-output helper, gallery, generated PNG, exact final artistic-cap claim, ledger promotion, Demo UI, new dependency, new package target, or public geometry type belongs in this phase.

## Locked Phase Contract

`38-CONTEXT.md`, live `REQUIREMENTS.md`, live `ROADMAP.md`, and `.planning/research/SUMMARY.md` are authoritative. Archived v1.8/v1.9 artifacts are implementation patterns only and cannot prove a v1.10 field.

| Field | Public contract | Provisional effective cap | Geometry contract | Explicit non-alias |
| --- | --- | --- | --- | --- |
| `mouthYPosition` | signed `Float`, normalized `-1...1`, default/non-finite `0` | `±0.25` | uniform bounded vertical translation of validated whole-mouth/outer-lip sources | not `smile`, mouth size, or upper/lower reshaping |
| `mouthTilt` | signed `Float`, normalized `-1...1`, default/non-finite `0` | `±0.25` | bounded rotation of validated whole-mouth sources around a stable mouth center; both signs preserved | not horizontal/vertical translation or corner-only smile motion |
| `mouthXPosition` | signed `Float`, normalized `-1...1`, default/non-finite `0` | `±0.25` | uniform bounded horizontal translation of validated whole-mouth/outer-lip sources | not `mouthWidth`, which moves opposite corners in opposite directions |
| `lipPeakDefinition` | positive-only `Float`, normalized `0...1`, default/non-finite `0` | `0.25` | local upper-lip/cupid-bow shaping from explicit upper plus inner support | not `smile`, `mouthSize`, or a whole-mouth transform |
| `lipPlump` | positive-only `Float`, normalized `0...1`, default/non-finite `0` | `0.25` | local upper/lower thickening away from the inner opening | not `lipColor`, `mouthSize`, or `lipPeakDefinition` |

Compatibility means source clients rebuild against defaulted labeled initializer arguments and old encoded payloads/presets decode missing keys as zero. It does not establish ABI compatibility for already compiled binary clients.

The existing four public mouth/lip fields stay unchanged: signed `mouthSize`, signed `mouthWidth`, positive-only `smile`, and color-domain `lipColor`. The geometry provider's complete set becomes eight fields; `lipColor` remains outside geometry totals and convergence.

## Architectural Responsibility Map

This is a single-client SDK architecture with package target boundaries rather than network tiers.

| Capability | Primary owner | Secondary owner | Rationale |
| --- | --- | --- | --- |
| Public scalar storage and compatibility | `BeautyCore` | `BeautyResources` presets | Public values and Codable behavior belong to the stable model; presets exercise missing-key compatibility |
| Vision lip availability | `BeautyDetection` | `BeautyEffects` adapter | Detection records coarse group availability; it must not export raw region points |
| Deterministic support construction | package-internal `BeautyEffects` | detection availability | `FaceGeometry` and the adapter own render-planning proxy supports behind the facade |
| Independent warp vectors | `MouthWarpProvider` | unified geometry pipeline | The provider owns field prerequisites and points; the existing pipeline consumes one combined point list |
| Caps, degradation, and conflict evidence | resolver/conflict planning | provider emissions | Effective strengths must describe actual provider-eligible work before diagnostics and dispatch |
| Public route and redaction | `BeautySDK` facade | resolver | The facade triggers detection and returns only output, summaries, warnings, and aggregate metrics |

The established data flow remains:

```text
BeautyParameters scalar request
  -> normalized public values
  -> provisional safety caps
  -> Vision coarse group availability
  -> package-only FaceGeometry proxy supports
  -> MouthWarpProvider per-field emissions
  -> provider-eligible retained strengths
  -> bounded geometry conflict convergence
  -> unified local warp
  -> public output + redacted aggregate evidence
```

There is no need for a new pass, target, dependency, facade method, or result field.

## Requirement-to-Evidence Map

| Requirement | Required implementation | Minimum convincing evidence |
| --- | --- | --- |
| MOUTH-01 | five distinct public stored `Float` values using the correct clamp family and defaulted initializer arguments | exact defaults/ranges; finite overflow; `NaN` and both infinities; mutation followed by `normalized()`; independent equality/storage |
| MOUTH-02 | no aliases/computed forwarding to shipped fields | unequal simultaneous values; mutation isolation; coding-key inventory; source scans; direct provider semantics later in the phase |
| MOUTH-03 | all six model enumeration seams plus missing-key decoding and unchanged preset payloads | literal complete 33-key legacy JSON decodes five zeros; 38-key unequal round trip; all bundled presets stay zero; existing labeled initializer calls compile; exact 38-field inventory |
| MOUTH-04 | `.innerLips` availability that is not globally required, plus default-empty explicit upper/lower/inner supports gated by groups | injected detection availability tests; missing-inner face remains usable; adapter exact/deterministic support tests; finite/bounded/distinct ordering; missing outer versus missing inner independence |
| MOUTH-05 | separate Y translation, center rotation, and X translation helpers | both signed directions; axis/tangential vector assertions; same-source comparisons; stable center; non-alias against width/smile/each other; deterministic bounded points |
| MOUTH-06 | local peak helper consuming validated upper+inner support | explicit upper subset; local peak/valley intent; no corner-only smile or radial-size substitution; invalid upper/inner support returns no peak emission while siblings survive |
| MOUTH-07 | local plump helper consuming validated upper+lower+inner support | upper targets move outward from opening on the upper side, lower targets on the lower side; both subsets emit; no color/size/peak substitution; malformed dependency fails closed |
| MOUTH-08 | five effective values/caps and every manual resolver/conflict/provider list; eight-field field emissions; convergence bound `14` | isolated cap/activation/reuse; per-field provider-empty sanitization; final-scale-empty removal; direct total/count/scale tests; representative combined test; each new field independently routes through the facade with redacted aggregate evidence |

## Current Architecture and Exact Integration Seams

### Public Model

`BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` manually enumerates every field in six places:

1. stored properties;
2. `CodingKeys`;
3. the defaulted public initializer signature;
4. initializer assignments and clamp selection;
5. `init(from:)` missing-key forwarding;
6. `normalized()` copy forwarding.

The current exact inventory is 33 stored fields. Add all five values to all six seams. The safest grouping is after `smile` and before `lipColor`, preserving the mouth geometry group while defaulted labels allow existing calls that proceed to `lipColor`, `filterId`, or `filterIntensity` to omit the new arguments. Signed fields use the existing `clampSigned`; positive-only fields use `clampUnit`. Do not add a second clamp implementation or custom decoder.

Public vars remain mutable, so initializer-only tests are insufficient. Each new field must be mutated out of range or to non-finite data and then passed through `normalized()` to prove the resolver receives the correct value. JSON encoders do not normally accept non-finite floats; non-finite evidence therefore belongs to programmatic construction/mutation, while JSON evidence proves missing-key and round-trip behavior.

The compatibility payload for this phase is the complete current 33-field model, including `noseRootNarrowing` and `noseTipLift`, with all five new mouth keys absent. Assert its key count before decode. A new payload should encode exactly 38 keys. Bundled presets should remain textually unchanged: their missing keys are the compatibility behavior, not a defect to patch with explicit zeroes.

`BeautyParametersTests` contains older v1.8 requirement-named tests such as `testMOUTH05...`, and `CombinedEffectSafetyTests` contains `testMOUTH08...`. v1.10 reuses milestone-local MOUTH IDs. New tests should include `Phase38` in their names so current evidence is not confused with archived v1.8 semantics.

### Vision Availability Is Coarse, Not Raw Geometry

Apple documents `VNFaceLandmarks2D.outerLips` as the outside lip outline and optional `innerLips` as the outline of the space between the lips. Vision landmark coordinates are normalized within the face observation bounding box. This confirms that inner and outer regions are separate optional availability sources, but the current repository deliberately does not retain their raw points.

The production seam is `BeautyFaceLandmarks.availableGroups`. `VisionFaceDetector.landmarks(from:)` currently records only `faceContour`, both eyes, nose, and `outerLips`. Add `BeautyLandmarkGroup.innerLips`, and insert it only when `landmarks.innerLips?.pointCount` is positive.

Do **not** add `.innerLips` to `requiredGeometryGroups`. A face with contour, eyes, nose, and outer lips must remain globally usable when inner lips are absent; only peak/plump work should become ineligible. `BeautyFaceLandmarks.complete` uses `Set(allCases)`, so it will automatically make standard complete test observations eligible for the new local fields. Add a focused test that explicitly removes only `.innerLips` and still expects a usable selected observation.

The repository maps observations to deterministic proxy geometry from face bounds and availability; it does not map or persist raw `VNFaceLandmarkRegion2D` points. Plans must preserve that architecture and avoid claiming that the adapter contains actual Vision landmark arrays.

### Internal FaceGeometry and Adapter Supports

`WarpControlPoint.swift` currently stores a stable legacy `outerLips` array. `BeautyFaceGeometryAdapter.outerLips(in:)` returns eight points in deterministic contour order. Existing `mouthSize`, `mouthWidth`, `smile`, and `lipColor` evidence depends on that exact proxy.

Keep `outerLips` unchanged as the whole-mouth support. Add package-internal, default-empty `upperLips`, `lowerLips`, and `innerLips` arrays to `FaceGeometry`. Default arguments are important because many tests construct `FaceGeometry` directly and must remain source-compatible. The adapter should:

- populate `outerLips`, `upperLips`, and `lowerLips` only when `.outerLips` is available;
- populate `innerLips` only when `.innerLips` is independently available;
- return empty upper/lower support when outer lips are unavailable even if inner availability exists;
- return existing whole/upper/lower support when inner lips are unavailable, leaving only peak/plump ineligible;
- produce finite normalized points inside the face bounds, with deterministic order and no duplicate-only support.

Explicit upper/lower proxy arrays should represent local lip surfaces rather than merely aliasing the whole eight-point array. A useful support layout is a stable left-to-right upper subset with distinguishable left peak, center valley, and right peak, plus a stable left-to-right lower subset and an inner opening contour. Exact private coordinates are discretionary, but tests must lock their structural invariants and adapter outputs. Do not modify the legacy `outerLips` coordinates merely to make the new effects easier.

### Provider-Owned Eligibility

`MouthWarpProvider` currently has one global outer-lip center guard and three emissions. It is not sufficient for MOUTH-08 because a missing inner region must not disable whole-mouth work, and a non-empty sibling emission must not hide failure of one requested local field.

Expand `MouthWarpFieldEmissions` to eight arrays and make `points`/`sanitizing(_:)` enumerate all eight. `makeControlPoints` should derive its skip reason from requested work plus the aggregate emissions rather than requiring an outer center before evaluating every field. Each helper must own its actual prerequisites.

Recommended support validators:

| Consumer | Required support | Validation intent |
| --- | --- | --- |
| `mouthSize` | whole `outerLips` + stable center/cardinals | finite, bounded, distinct, enough extrema/cardinals |
| `mouthWidth` | whole `outerLips` + distinct left/right | finite, bounded, nondegenerate horizontal span |
| `smile` | whole `outerLips` + distinct corners | finite, bounded, nondegenerate corners |
| `mouthYPosition` | validated whole `outerLips` | finite, bounded, at least two distinct sources; uniform nonzero Y delta |
| `mouthTilt` | validated whole `outerLips` + center | finite nondegenerate radius from center; omit zero-displacement center sources |
| `mouthXPosition` | validated whole `outerLips` | finite, bounded, at least two distinct sources; uniform nonzero X delta |
| `lipPeakDefinition` | explicit upper + inner | sufficient distinct upper local structure and a finite inner opening reference |
| `lipPlump` | explicit upper + lower + inner | sufficient distinct points on both sides plus a finite nondegenerate inner opening |

Validate support before target clamping. `LandmarkGeometryHelper.clamp` can make an out-of-range calculation look bounded and Swift floating-point min/max behavior is not a substitute for explicit `isFinite` guards. Validate points against both normalized `0...1` space and the face bounds, reject insufficient/degenerate/duplicate-only structures, calculate finite displacement, reject displacement at or below the renderability threshold, and only then create clamped control points.

Per-field sanitization should happen both before conflict accounting and after conflict scaling, following the final v1.9 nose/mouth convergence pattern. A field that cannot emit at its final scaled value becomes zero in effective strengths and contributes nothing to total, weakened count, scale, warning, metrics, or dispatch. A valid sibling remains eligible.

### Whole-Mouth Vector Semantics

The three signed controls should use the same validated whole-mouth source ordering so their differences are geometric, not fixture artifacts:

- `mouthYPosition`: every emitted target has `target.x == source.x`; all nonzero Y deltas have the same sign and magnitude for one request; opposite input reverses only the Y direction.
- `mouthXPosition`: every emitted target has `target.y == source.y`; all nonzero X deltas have the same sign and magnitude; opposite input reverses only the X direction.
- `mouthTilt`: rotate each noncentral source around one stable mouth center with a bounded angle/displacement. Opposite signs produce opposite tangential motion while preserving source radius from the center within tolerance. In the repository's top-to-bottom image-normalized coordinate convention, the planner may choose and document which sign is visually clockwise; tests must lock that convention consistently.

Translations must not mimic `mouthWidth`: width moves left and right corners in opposite X directions, while X position moves every source in the same X direction. Tilt must not mimic smile: smile is corner-only upward Y motion, while tilt produces tangential X/Y components over a broader source set. Compare source sets, complete target arrays, displacement vectors, and signed opposites; point counts alone are not non-alias evidence.

### Peak and Plump Semantics

`lipPeakDefinition` should operate on a local upper/cupid-bow subset, not the mouth corners. The clearest proof uses explicit left-peak, center-valley, and right-peak structure: flanking peak sources gain a symmetric upward component and the center relationship changes in the opposite/local direction, with inner support establishing the opening boundary. The exact number of points and coefficients can remain private, but the output must be symmetric around the mouth center when the support is symmetric and must differ from `smile`, `mouthSize`, and every whole-mouth transform.

`lipPlump` should move explicit upper and lower surface sources away from the inner opening: upper sources move toward the upper exterior, lower sources toward the lower exterior, and both groups must contribute. Deriving direction from the nearest valid inner anchor or the stable inner-opening center is acceptable if degenerate vectors fail closed. This output must differ from radial whole-mouth size, upper-only peak shaping, and color-only `lipColor`.

Do not lock aesthetic claims in Phase 38. The provisional coefficients need only be conservative, finite, nonzero, normalized, bounded, deterministic, and capped. Phase 39 owns visible output/ROI calibration and Phase 40 owns final exact cap lock.

### Resolver, Conflict, and Pipeline Seams

The production hotspots are manual and omission-prone:

- `BeautyEffectPlan.swift`: five `BeautyEffectiveStrengths` properties;
- `BeautySafetyCaps.swift`: five provisional `0.25` symbols;
- `BeautyEffectResolver.requiresFaceGeometry`: all five fields independently trigger detection;
- initial `capSigned`/`capUnit` assignments and `cappedCount`;
- `hasReusableNonEyeGeometryValues`;
- requested-mouth and active-mouth `anyNonZero` lists;
- `zeroMouthGeometryStrengths`;
- `scaleReusableNonEyeGeometryStrengths` exact `0.5` behavior;
- provider preflight and post-conflict sanitization;
- mouth domain activation/skip and aggregate geometry point count;
- `GeometryConflictResolver` scale assignments, absolute/signed-aware `geometryTotal`, and nonzero-field count.

Current bounded convergence allows at most nine nose/mouth field removals: six nose plus three shipped mouth. The complete retained set becomes fourteen: six nose plus eight mouth. Update the loop bound and comment to `14`; do not introduce an unbounded `while`, and do not count `lipColor`.

Signed fields must use absolute magnitude in conflict totals/counts while multiplying the signed value by the scale so direction survives. Positive-only peak/plump use their nonnegative value. Preflight/final provider emissions must be the source of eligibility; a field must not remain nonzero merely because another mouth helper emitted points.

Phase 38 should prove representative reuse and combined convergence, including a final-scale-empty case, because MOUTH-08 explicitly requires effective strengths to equal final emissions. Phase 40 still owns the exhaustive eight-field freshness/support/transition matrix, final exact cap accounting, and cross-domain once-only closeout.

### Public Facade Route

`BeautyEngineGeometryDetection.swift` already asks `BeautyEffectResolver.requiresFaceGeometry(parameters:)`, invokes detection, maps the selected package observation, resolves effects, and returns redacted evidence. No production facade edit should be necessary outside the resolver/adapter path.

Add one table-driven facade test with five isolated parameter cases. Each case must use a fresh `SDKTestingFaceDetectionProvider([.usableFace])` so invocation counts cannot bleed between cases. Assert exactly one detector invocation, unchanged extent, usable face/used-face counts, `beauty.detection.geometryRequired == 1`, positive aggregate geometry point count, and no raw lip/support/coordinate/control-point/provider payload in warnings, metric keys, or detection reasons.

This is route evidence only. Do not compare pixels, add renderer cases, or claim visible naturalness; Phase 39 owns those gates.

## Test Files and Patterns to Extend

| File | Phase 38 purpose |
| --- | --- |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | MOUTH-01/02/03 exact 38 fields, clamp families, mutation normalization, independence, legacy 33-key decode, new round trip, source-style construction |
| `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift` | every bundled preset keeps all five new values neutral without JSON edits |
| `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` | inner availability is recorded independently and is not part of global required geometry |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | adapter and shared `FaceGeometry` fixtures gain deterministic upper/lower/inner support and malformed variants while legacy outer points remain exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | five provisional constants are exactly `0.25` without final-cap wording |
| `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` | eight-field source subset, axis/direction, rotation, peak/plump, non-alias, determinism, bounds, malformed support, field-local emissions |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | geometry-required route, isolated cap/count/activation, signed negative validity, positive-only negative no-op, redaction |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | representative missing inner/upper/lower/outer, reused `0.5`, provider-empty siblings, final-scale-empty convergence |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | scale/total/count includes all five fields with signed magnitudes |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | representative face/eye/nose/mouth weakening preserves all three signed directions and positive local fields; `lipColor` stays excluded |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | five isolated requests trigger the existing detector/adapter/resolver path with aggregate redacted evidence |

Prefer `Phase38MOUTHxx` names because v1.8 already used MOUTH-01 through MOUTH-10 for the shipped mouth slice. Table-driven tests suit public normalization, caps, routing, and support-failure matrices. Separate focused provider tests are better for Y translation, X translation, rotation, peak, and plump because their geometric invariants differ.

## Compatibility and Regression Hazards

1. **Making inner lips globally required.** This would turn otherwise usable faces into `.partial` and disable shipped geometry. Keep `.innerLips` out of `requiredGeometryGroups`.
2. **Changing the legacy outer-lip proxy.** This silently changes shipped mouth size/width/smile/lip-color output with all five new fields at zero. Add supports beside it; do not tune it for new tests.
3. **Treating availability as raw geometry.** The current detector records groups only. Keep deterministic adapter proxies honest and package-internal; do not claim actual Vision points are stored.
4. **Keeping the provider's global outer-center guard.** Missing inner support then cannot degrade locally, or valid explicit local supports can be masked by a whole-mouth failure. Evaluate each emission from its own prerequisites.
5. **Aliasing X position to width or Y position to smile.** Uniform translation and opposing-corner/corner-only motion need complete-vector comparisons.
6. **Aliasing M-lip/plump to size or color.** Upper-local peak structure and upper/lower thickness around the opening require explicit supports and distinct vectors.
7. **Clamping malformed math into apparently valid points.** Require finite support, center, angle/displacement, target, radius, strength, and falloff before clamping.
8. **Leaving the convergence bound at nine.** Fourteen nose/mouth field masks can now be removed; stale comments or loop bounds can return non-emitting effective strengths.
9. **Forgetting signed magnitude.** `mouthYPosition`, `mouthTilt`, and `mouthXPosition` must use `abs` for totals/counts but retain sign when scaled and emitted.
10. **Letting `lipColor` enter geometry convergence.** It stays an independently capped color-domain effect and is not evidence for true plump.
11. **All-or-nothing provider fallback.** A valid shipped sibling must not hide a failed peak/plump request, and a failed local field must not zero valid translations or legacy work.
12. **Requirement-name collision.** Archived v1.8 tests already contain `MOUTH08`; Phase-38-prefixed names and current verification traceability are required.
13. **Premature output or promotion work.** Renderer/helper/gallery/ROI belongs to Phase 39; final caps, exhaustive safety, active-source scans, five-row promotion, and current-owner final closeout belong to Phase 40.

## Documentation Ownership During Phase 38

The code change creates a current public/runtime contract, so the plan should update present owners without promoting product rows:

- `ARCHITECTURE.md`: durable invariant that existing `outerLips` remains the shipped whole-mouth proxy while default-empty upper/lower/inner supports remain package-internal and never cross the facade;
- `DESIGN.md`: exact 38-field inventory, five public ranges/defaults, provisional caps, explicit support dependencies, vector semantics, eight-field provider ownership, and fourteen-removal convergence;
- `RELIABILITY.md`: representative field-local support failure, provider-empty removal, exact reused `0.5`, stale/no-face behavior inherited by the new fields, and final emission/effective-strength agreement, while marking Phase 40 exhaustive work pending;
- `SECURITY.md`: coarse inner availability, finite/bounded support validation, no public raw geometry, redacted diagnostics, and no new dependency/network/commercial path;
- `PRODUCT_SENSE.md`: frozen independent control meanings and Phase 38 acceptance, explicitly keeping all five rows and branch-level `嘴唇` unpromoted until Phases 39/40;
- `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md`: record only observed Phase 38 evidence and route next to Phase 39.

Do not update `QUALITY_SCORE.md`, example validation, feature ledgers, feature matrix, mouth branch README, renderer source, or Demo UI in Phase 38 unless a current statement would otherwise become factually false. Product promotion is explicitly Phase 40-owned.

## Recommended Plan Decomposition

### Plan 38-01: Public Contract, Compatibility, and Effective Storage

- add five values through all six `BeautyParameters` seams;
- add five `BeautyEffectiveStrengths` fields and provisional cap constants;
- lock exact 38-field inventory, signed/positive normalization, mutation normalization, 33-key legacy decode, 38-key round trip, source-style initializer compatibility, and five-preset neutrality;
- keep preset JSON unchanged.

This plan independently closes the storage/compatibility foundation for MOUTH-01 through MOUTH-03 and the effective symbols needed later.

### Plan 38-02: Inner Availability and Explicit Lip Supports

- add `.innerLips` group recording without changing required geometry;
- add default-empty upper/lower/inner arrays while preserving exact legacy outer support;
- build deterministic bounded proxy supports from availability and face bounds;
- add complete, missing-outer, missing-inner, malformed, duplicate, and non-finite fixtures/tests.

This plan should close MOUTH-04 before provider logic relies on the supports.

### Plan 38-03: Eight-Field Provider Geometry

- expand `MouthWarpFieldEmissions` and field-local sanitization to eight fields;
- harden shipped helper prerequisites where necessary without changing valid legacy outputs;
- implement and prove signed Y/tilt/X, upper-local peak, and upper/lower plump helpers;
- test source sets, axis/direction, symmetry/rotation, non-alias, deterministic ordering, bounds, nonzero renderability, malformed support, and sibling continuation.

This plan owns the direct provider evidence for MOUTH-05 through MOUTH-08.

### Plan 38-04: Resolver, Conflict, Facade, Verification, and Contract Synchronization

- enumerate all five fields through cap, activation, requested sets, reuse, zeroing, provider preflight, domain routing, and conflict scale/total/count;
- expand retained-field convergence from nine to fourteen monotonic removals;
- prove representative missing-inner/provider-empty/reuse/final-scale-empty behavior and aggregate redaction;
- add five isolated public-facade route cases;
- run focused/full tests and scope/privacy/dependency/artifact scans;
- synchronize root/planning owners without output claims or row promotion.

This plan should finalize only MOUTH-01 through MOUTH-08 and hand off to Phase 39.

## Validation Architecture

### Validation Layers

| Layer | What it proves | Primary suites |
| --- | --- | --- |
| L1 public contract | exact 38-field inventory, clamp families, non-finite zero, mutable normalization, JSON/source/preset compatibility | `BeautyParametersTests`, `BeautyResourceCatalogTests`, `BeautySafetyCapsTests` |
| L2 availability/support | inner availability is independent; whole/upper/lower/inner supports are finite, bounded, deterministic, distinct, and package-only | `VisionFaceDetectorTests`, `FaceShapeWarpProviderTests` |
| L3 provider vectors | every field has the correct source subset/vector, both signed directions survive, local effects are non-aliases, malformed support fails per field | `MouthWarpProviderTests` |
| L4 resolver/conflict | cap/count, geometry-required route, reuse, zeroing, provider eligibility, fourteen-mask convergence, totals/counts/scales, final emissions agree | `BeautyEffectResolverTests`, `MissingLandmarkDegradationTests`, `GeometryConflictResolverTests`, `CombinedEffectSafetyTests` |
| L5 facade | each new scalar invokes detection and returns only same-extent output plus redacted aggregate evidence | `BeautyEngineGeometryFacadeTests` |
| L6 regression/boundary | existing zero-new-field behavior, full SDK, no public raw geometry, no dependency/Demo/renderer/ledger/artifact expansion | full SwiftPM plus structural/diff scans |

### Nyquist Sampling Requirements

Every production behavior needs a direct narrow assertion and at least one assertion at the next integration layer:

- public field -> parameter normalization test + resolver cap/activation test;
- detection group -> detector availability test + adapter support test;
- support dependency -> adapter/provider test + resolver field-local zeroing test;
- provider vector -> provider invariant test + fresh resolver activation;
- signed direction -> provider opposite-vector test + resolver/combined sign preservation;
- provider-empty/final-scale-empty -> emission sanitization test + conflict/effective-strength integration test;
- geometry-required flag -> resolver test + public facade detector invocation;
- redaction -> resolver metadata scan + facade result scan;
- legacy compatibility -> exact outer-lip/provider zero-new-field test + full SwiftPM regression.

Do not use Phase 39 PNG differences as a substitute for provider-vector proof. Conversely, provider points alone do not prove public-facade routing.

### Focused Commands

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

Use actual suite names emitted by SwiftPM if a module-qualified filter selects zero tests. Record executed counts rather than treating a zero-test command as green.

### Structural and Boundary Checks

```bash
test "$(rg -n '^    public var ' BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift | wc -l | tr -d ' ')" -eq 38

for field in mouthYPosition mouthTilt mouthXPosition lipPeakDefinition lipPlump; do
  rg -n "$field" \
    BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift \
    BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift \
    BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift \
    BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift \
    BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift \
    BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift || exit 1
done

git diff -- BeautySDK/Sources/BeautyExampleRenderer BeautyDemo BeautySDK/Package.swift
git diff -- docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md \
  docs/meitu-function-blueprint/FEATURE_MATRIX.md \
  docs/meitu-function-blueprint/features/beauty-shaping/lips
git diff --check
```

Also classify public/SPI lexical matches for `FaceGeometry`, lip supports, landmarks, `WarpControlPoint`, SIMD, and bounds. The passing condition is no **new public/SPI exposure**, not necessarily zero internal lexical matches. Scan warnings/metric keys for raw geometry terms and scan active source for dependency, network/cloud, and commercial drift. Confirm generated output/gallery PNGs remain ignored/untracked and archived v1.8/v1.9 evidence is untouched.

### Required Validation Matrix

| Scenario | Whole transforms | Peak | Plump | Mouth domain / siblings |
| --- | --- | --- | --- | --- |
| default and positive-only negative/non-finite | zero/no points | zero/no points | zero/no points | inactive; no missing-input warning |
| fresh complete support, isolated | signed distinct nonzero vectors | upper-local nonzero | upper+lower nonzero | active; aggregate points only |
| signed opposite request | exact opposite axis/tangential direction | n/a | n/a | sign preserved through cap/provider |
| missing outer, inner present | zero | zero because upper absent | zero because upper/lower absent | requested dependent fields zero/skip; safe domains continue |
| outer present, inner missing | remain eligible | zero | zero | shipped/whole siblings remain active |
| malformed upper only | whole siblings remain | zero | zero if upper required | lower/whole valid work survives |
| malformed lower only | whole siblings remain | peak may remain | zero | valid peak/whole work survives |
| malformed inner only | whole siblings remain | zero | zero | no raw support diagnostic |
| duplicate/non-finite/degenerate support | only consumers of that support zero | dependency-specific zero | dependency-specific zero | valid independent siblings survive |
| reused representative | exact sign-preserving `0.5` after provisional caps | `0.125` before separate conflict | `0.125` before separate conflict | `geometry_stale_reduced`; active if emitting |
| stale/no-face representative | all eight geometry strengths zero | zero | zero | mouth skipped; safe color/filter continue; `lipColor` follows existing independent policy |
| conflict scale crosses emission threshold | final-scale-empty field removed | same | same | totals/count/scale/warning/final strengths/dispatch use one retained set |
| public facade isolated request | detector exactly once; extent preserved | same | same | usable summary and positive aggregate count; redacted |

Phase 38 needs representative stale/no-face/reuse/conflict coverage to prove propagation, but Phase 40 owns the exhaustive all-eight transition and exact-final-cap matrix.

### Research Baseline

Research-time `swift test --package-path BeautySDK` passed **228/228** tests on 2026-07-14. Relevant current suite inventories before Phase 38 are:

- `BeautyParametersTests`: 14 tests;
- `BeautyResourceCatalogTests`: 7;
- `VisionFaceDetectorTests`: 8;
- `FaceShapeWarpProviderTests`: 9;
- `BeautySafetyCapsTests`: 2;
- `MouthWarpProviderTests`: 6;
- `BeautyEffectResolverTests`: 15;
- `MissingLandmarkDegradationTests`: 30;
- `GeometryConflictResolverTests`: 9;
- `CombinedEffectSafetyTests`: 10;
- `BeautyEngineGeometryFacadeTests`: 11.

These are pre-implementation baselines only. Final Phase 38 verification must report new observed counts and the full-suite result.

## Planning Conclusions

- The public contract is a direct five-field extension of a proven manual model pattern; the main risk is omission from one of the six model seams or one of the resolver/conflict lists.
- Vision already provides distinct optional outer/inner lip regions, but this repository intentionally records availability rather than raw landmark arrays. The correct design is independent inner availability plus deterministic package-only supports, not a public or persisted landmark model.
- The existing outer-lip proxy and valid shipped provider outputs must remain byte-for-byte/point-for-point stable when all five new fields are zero. Upper/lower/inner supports belong beside the legacy proxy.
- A provider-global outer-center guard is no longer adequate. Eight provider-owned field emissions with explicit prerequisites and pre/post-conflict sanitization are the central correctness seam.
- Whole translations/rotation are geometrically straightforward once sign and source ordering are locked. M-lip/plump need direct structural vector proof now and facade-output/ROI calibration in Phase 39 before any naturalness or final-cap claim.
- Completion requires each MOUTH-01 through MOUTH-08 requirement to have direct unit evidence and an appropriate integration layer, while every Phase 39/40 output, final-safety, promotion, and readiness claim remains explicitly deferred.

## Sources

Primary repository sources: `38-CONTEXT.md`, live `REQUIREMENTS.md`, live `ROADMAP.md`, `STATE.md`, `.planning/research/SUMMARY.md`, current root contracts, `BeautyParameters.swift`, `BeautyFaceObservation.swift`, `VisionFaceDetector.swift`, `WarpControlPoint.swift`, `BeautyFaceGeometryAdapter.swift`, `BeautyEffectPlan.swift`, `BeautySafetyCaps.swift`, `BeautyEffectResolver.swift`, `MouthWarpProvider.swift`, `GeometryConflictResolver.swift`, `BeautyGeometryEffectPipeline.swift`, and the focused XCTest files listed above.

Historical pattern sources: archived v1.8 Phase 34 mouth safety artifacts and archived v1.9 Phase 35 public-contract/independent-geometry research, plans, validation, review fixes, and verification. They are patterns, not current requirement evidence.

Official platform source: Apple Vision `VNFaceLandmarks2D`, `outerLips`, and `innerLips` documentation: <https://developer.apple.com/documentation/vision/vnfacelandmarks2d>, <https://developer.apple.com/documentation/vision/vnfacelandmarks2d/outerlips>, <https://developer.apple.com/documentation/vision/vnfacelandmarks2d/innerlips>.

