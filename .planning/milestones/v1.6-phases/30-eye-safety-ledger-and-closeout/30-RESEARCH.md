# Phase 30: Eye Safety, Ledger, and Closeout - Research

**Researched:** 2026-07-10 [VERIFIED: environment_context]  
**Domain:** SwiftPM eye-parameter normalization, eye-specific geometry degradation, combined-geometry safety evidence, active-source boundary enforcement, and scoped documentation promotion [CITED: .planning/phases/30-eye-safety-ledger-and-closeout/30-CONTEXT.md]  
**Confidence:** HIGH [VERIFIED: current source/tests/docs; VERIFIED: focused local XCTest run]

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

The planner and executor must preserve all Phase 30 decisions D-01 through D-21 from `30-CONTEXT.md`. The implementation-relevant invariants are:

- `eyeSize` and `eyeTailLift` are positive-only. Negative finite input normalizes to zero and must not create `eye_inputs_missing` or an equivalent missing-eye warning. [CITED: D-01, D-02]
- `eyeDistance` and `eyeYPosition` remain signed and must retain positive and negative direction through normalization, caps, and combined weakening. [CITED: D-03, D-04]
- Exact caps remain `eyeSize = 0.45`, `eyeDistance = 0.30`, `eyeYPosition = 0.25`, and `eyeTailLift = 0.30`. Cap evidence must include exact effective values, stable cap warning, and exact aggregate cap count. [CITED: D-04, D-05; VERIFIED: BeautySafetyCaps.swift]
- Every eye field needs finite overflow plus `NaN`, positive infinity, and negative infinity coverage. Non-finite input normalizes to zero. [CITED: D-06]
- Eye geometry is skipped completely for both `.reused` and `.stale`: `.eyes` is not active, all four eye effective strengths are zero, and no eye control points are generated. [CITED: D-07, D-08]
- The stricter `.reused` policy is eye-only. Face shape, nose, and mouth retain their current reduced-strength reuse behavior. [CITED: D-09]
- Missing either eye group skips the whole eye domain. Other usable geometry domains and safe color/filter domains continue. [CITED: D-10]
- Missing-eye, reused-eye, and stale-eye skips have distinct stable redacted reasons. Only state categories and aggregate counts may cross the result boundary. [CITED: D-11]
- EYE-05 is layered: the public facade proves no-face dimensions/redaction/safe-domain continuation; resolver/provider tests prove missing-eye/reused/stale zeroing and absence of eye control points. [CITED: D-12]
- EYE-06 needs six per-behavior cases—size, signed distance in both directions, signed vertical position in both directions, and tail lift—plus one all-eye multi-domain case. [CITED: D-13, D-14]
- Existing focused tests should be extended when their assertions remain exact, and final verification must map EYE-04, EYE-05, and EYE-06 to exact test names. [CITED: D-15]
- Phase 29's `161/161` output and `36/36` comparison helper result is a hard regression gate. Gallery generation is conditional on gallery logic changing. [CITED: D-16]
- Active EYE-07 violations block all row promotion. The four rows promote together or all remain `partial`; branch-level `眼睛` remains `partial`. [CITED: D-17 through D-20]
- Documentation synchronization is broad but ownership-based. `ARCHITECTURE.md` and `FRONTEND.md` change only if their contracts change. [CITED: D-21]

### Planner Discretion

The planner may choose warning code names, exact test-file organization, table-driven helper structure, scan regexes, evidence artifact names, and whether to extend existing tests or add focused files. [CITED: `30-CONTEXT.md`]

Recommended stable warning codes in this research are examples, not new locked decisions:

- Keep `eye_inputs_missing` for missing either eye group.
- Add a reused-specific code such as `eye_geometry_reused_skipped`.
- Add a stale-specific code such as `eye_geometry_stale_skipped`.

Whichever names the plan selects must be asserted exactly in tests and recorded consistently in `DESIGN.md`, `RELIABILITY.md`, Phase 30 evidence, and verification.

### Deferred / Out of Scope

- Negative visible shrinking for `eyeSize`.
- Negative downward tail motion for `eyeTailLift`.
- Stricter `.reused` behavior for face shape, nose, or mouth.
- New public eye parameters, Demo UI, or unscoped eye tools.
- Network/cloud, account, VIP/payment/entitlement, committed generated PNG baselines, device parity, commercial visual quality, broad reference-app parity, launch readiness, or whole-branch `眼睛` completion. [CITED: `30-CONTEXT.md`; VERIFIED: `.planning/REQUIREMENTS.md`]

</user_constraints>

## Phase Requirements

| ID | Planning meaning | Required evidence |
| --- | --- | --- |
| EYE-04 | Lock public eye normalization, exact caps/directions, abnormal-input behavior, cap warning, and cap metric. | `BeautyParameters` tests plus resolver tests against fresh complete geometry. |
| EYE-05 | Prove no-face facade behavior and missing/reused/stale eye-specific degradation. | Public `BeautyEngineGeometryFacadeTests`, resolver degradation tests, provider tests, and redaction assertions. |
| EYE-06 | Prove each visible eye behavior is additionally weakened in representative combined geometry. | Six table-driven normal-vs-combined cases plus one all-eye multi-domain case. |
| EYE-07 | Prove no raw public/SPI geometry, internal imports, network/cloud paths, commercial entitlement paths, or new public fields. | Active-source scans, exact parameter inventory test, and classified broader lexical matches. |
| EYE-08 | Promote exactly `大小`, `上下`, `眼距`, and `眼尾上扬`. | Hard pre-promotion gate plus exact ledger row guards. |
| DOC-01 | Synchronize owning docs and planning ledgers while branch-level `眼睛` stays partial. | Contract-specific document updates, branch guard, requirement traceability, evidence, and no-overclaim scans. |

## Executive Summary

Phase 30 should be planned as a small behavior correction followed by a large evidence and ledger gate. No new rendering algorithm, renderer case, package, target, public field, or Demo surface is needed. [VERIFIED: current code and Phase 29 evidence]

The two real implementation seams are:

1. `BeautyParameters` currently normalizes all four eye fields with `clampSigned`. Change only `eyeSize` and `eyeTailLift` to the existing `clampUnit`; keep distance and vertical position signed. [VERIFIED: `BeautyParameters.swift`]
2. `BeautyEffectResolver` currently applies one global `0.5` reuse scale to every geometry strength, including eyes, and uses the generic stale warning for stale eye geometry. Refactor that path so eyes are remembered as requested but zeroed/skipped for reused and stale geometry, while non-eye geometry continues using the existing reuse scale. Missing-eye provider failure must also zero all four eye effective strengths. [VERIFIED: `BeautyEffectResolver.swift`; VERIFIED: `MissingLandmarkDegradationTests.swift`]

The safest revised plan structure is seven sequential waves. The first three behavior/evidence waves remain unchanged; the former 18-file closeout is split at contract/ledger ownership boundaries so no executor owns the atomic promotion and every global hotspot at once:

1. Public eye normalization and exact cap/abnormal-input evidence.
2. Eye-specific missing/reused/stale degradation plus combined-weakening evidence.
3. Command-backed tests, Phase 29 renderer regression, active-source scans, review/security, and Phase 30 evidence/verification.
4. Atomic four-row promotion plus its five blueprint owners only after Wave 3 passes.
5. Design, security, reliability, and product contracts plus the Phase 30 security promotion audit.
6. Quality snapshot and milestone project contract.
7. Requirements, roadmap, state, work ledger, final verification, and validation.

Sequential waves avoid overlapping edits to `BeautyEffectResolver.swift` and make the atomic promotion gate auditable.

## Current-State Findings

### What Already Works

- `BeautySafetyCaps` already declares the required four exact cap constants. No cap constant change is indicated. [VERIFIED: `BeautySafetyCaps.swift`]
- `EyeWarpProvider` already requires both eye centers before producing any point. A missing left eye currently returns no points and `eye_inputs_missing`. [VERIFIED: `EyeWarpProvider.swift`; VERIFIED: `EyeWarpProviderTests.swift`]
- `EyeWarpProvider` already implements positive output only for size/tail and signed directional output for distance/vertical position. [VERIFIED: `EyeWarpProvider.swift`]
- `GeometryConflictResolver` already includes all four eye strengths in its total, scales them together with other geometry when total strength exceeds `1.0`, and emits `combined_geometry_weakened`, `beauty.effects.weakenedCount`, and `beauty.effects.geometryStrengthScale`. [VERIFIED: `GeometryConflictResolver.swift`]
- `BeautyEngineGeometryFacadeTests` already has deterministic public-facade detection fixtures, no-face dimension checks, safe-domain continuation patterns, and reusable redaction assertions. [VERIFIED: `BeautyEngineGeometryFacadeTests.swift`]
- Phase 29 already owns the exact six visible eye cases and the `161/161`, `36/36` helper. No new renderer or helper implementation is needed. [VERIFIED: `29-VERIFICATION.md`; VERIFIED: `check_eye_renderer_outputs.py`]
- The current public parameter inventory is exactly 31 stored fields, with a test that will catch public-field expansion. [VERIFIED: `BeautyParametersTests.testSDK03DefaultsAreZeroEffectAndExpose31StoredFields`]
- Research-time focused baseline passed: 49 tests across `BeautyParametersTests`, `BeautyEffectResolverTests`, `EyeWarpProviderTests`, `MissingLandmarkDegradationTests`, `CombinedEffectSafetyTests`, and `BeautyEngineGeometryFacadeTests` completed with zero failures. [VERIFIED: local command, 2026-07-10]

### What Is Incorrect or Incomplete for Phase 30

- `eyeSize` and `eyeTailLift` are currently initialized with `clampSigned`, so negative values remain negative in `BeautyParameters` even though the provider silently produces no visible points. This is the contract mismatch D-01/D-02 resolve. [VERIFIED: `BeautyParameters.swift`; VERIFIED: `EyeWarpProvider.swift`]
- The resolver currently caps `eyeSize` and `eyeTailLift` with `capSigned`; the correct Phase 30 intent is `capUnit`. [VERIFIED: `BeautyEffectResolver.swift`]
- Existing abnormal-input coverage includes only `eyeSize: .nan`; it does not cover all four fields, both infinities, or finite overflow. [VERIFIED: `BeautyParametersTests.swift`]
- Existing eye cap assertions are mostly relational (`<= cap`) and provider-helper-driven. They do not prove exact resolver effective values, signed directions, warning code, and exact capped count per parameter. [VERIFIED: `EyeWarpProviderTests.swift`]
- Reused geometry currently leaves `.eyes` active and scales eye strengths by `0.5`; two existing tests assert that now-obsolete behavior and must be deliberately rewritten. [VERIFIED: `MissingLandmarkDegradationTests.testReusedLandmarksReduceEyeAndNoseGeometry`; VERIFIED: `testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded`]
- Stale geometry currently skips `.eyes` but leaves the capped eye effective strengths nonzero and emits only the generic `geometry_stale_skipped` warning. [VERIFIED: `BeautyEffectResolver.swift`]
- Missing-eye resolver behavior skips `.eyes` but currently leaves the capped eye effective strengths nonzero. [VERIFIED: `BeautyEffectResolver.swift`]
- Provider coverage checks only a missing left eye, not a missing right eye. The shared `FaceGeometry` fixtures have no `missingRightEye` case. [VERIFIED: `EyeWarpProviderTests.swift`; VERIFIED: `FaceShapeWarpProviderTests.swift`]
- No existing test executes the six required normal-vs-combined eye behavior comparisons. Existing combined tests assert only a subset of eye strengths. [VERIFIED: `CombinedEffectSafetyTests.swift`; VERIFIED: `GeometryConflictResolverTests.swift`]
- No Phase 30 evidence, verification, validation, review, or security artifact exists yet. [VERIFIED: phase directory listing]

## Architectural Responsibility Map

| Concern | Owner | Phase 30 action |
| --- | --- | --- |
| Public value normalization | `BeautyCore/Models/BeautyParameters.swift` | Make only size/tail positive-only; preserve signed distance/Y. |
| Effective cap and degradation planning | `BeautyEffects/Planning/BeautyEffectResolver.swift` | Use correct cap family, remember requested eye intent, zero/skip eyes by reason, preserve non-eye reuse reduction. |
| Eye point generation | `BeautyEffects/Warp/EyeWarpProvider.swift` | Likely no production change; extend tests for either missing eye group. |
| Combined conflict safety | `BeautyEffects/Warp/GeometryConflictResolver.swift` | Likely no production change; exercise existing scale with six eye cases and one aggregate case. |
| Public no-face result | `BeautySDK/BeautyEngine.swift` and detection route | Likely no production change; add eye-specific facade evidence. |
| Visible output regression | `BeautyExampleRenderer` plus Phase 29 helper | Rerun unchanged matrix; do not add cases. |
| Privacy/boundaries | `SECURITY.md`, active-source scans | Prove raw geometry and scope expansion remain absent. |
| Reliability behavior | `DESIGN.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md` | Record positive-only semantics and the eye-only reused/stale skip exception. |
| Second-level status | `SHAPE_FEATURE_LEDGER.md` | Promote four rows in one gated edit. |
| Branch status | `FEATURE_MATRIX.md`, eyes/beauty-shaping READMEs | Record four implemented subtools while keeping branch `partial`. |
| Planning/quality state | `.planning/*`, `QUALITY_SCORE.md`, `PLANS.md` | Close six requirements from observed evidence only. |

## Recommended Implementation Architecture

### 1. Normalize Positive-Only Fields at the Existing Public Boundary

Use the already-established clamp helpers; do not add a second normalization layer or a new public type.

```swift
self.eyeSize = Self.clampUnit(eyeSize)
self.eyeDistance = Self.clampSigned(eyeDistance)
self.eyeYPosition = Self.clampSigned(eyeYPosition)
self.eyeTailLift = Self.clampUnit(eyeTailLift)
```

`normalized()` reconstructs `BeautyParameters`, so this also protects values mutated after initialization before they reach resources/resolver/render. [VERIFIED: `BeautyParameters.swift`; VERIFIED: `BeautySDKResources.validate(parameters:)`]

Resolver cap selection should mirror public semantics:

```swift
strengths.eyeSize = capUnit(normalized.eyeSize, cap: BeautySafetyCaps.eyeSize, cappedCount: &cappedCount)
strengths.eyeDistance = capSigned(normalized.eyeDistance, cap: BeautySafetyCaps.eyeDistance, cappedCount: &cappedCount)
strengths.eyeYPosition = capSigned(normalized.eyeYPosition, cap: BeautySafetyCaps.eyeYPosition, cappedCount: &cappedCount)
strengths.eyeTailLift = capUnit(normalized.eyeTailLift, cap: BeautySafetyCaps.eyeTailLift, cappedCount: &cappedCount)
```

Do not change the four cap constants or public field count.

### 2. Separate Requested Eye Intent From Final Eye Effective Strength

The main resolver pitfall is zeroing eye strengths before the resolver knows it must record `.eyes` as skipped. Capture the request boolean after normalization/capping and before any freshness zeroing:

```swift
let hasRequestedEyeValues = anyNonZero(
    strengths.eyeSize,
    strengths.eyeDistance,
    strengths.eyeYPosition,
    strengths.eyeTailLift
)
```

Then make freshness policy explicit:

```text
fresh + both eye groups     -> provider points, eyes active
fresh + either eye missing  -> zero eye strengths, eyes skipped, missing reason
reused                      -> zero eye strengths, eyes skipped, reused reason
stale                       -> zero eye strengths, eyes skipped, stale reason
no face                     -> existing no-face facade degradation path
```

The eye block should branch on `hasRequestedEyeValues`, not on already-zeroed final strengths.

### 3. Split Reuse Scaling Into Eye and Non-Eye Policy

The current `scaleGeometryStrengths` helper scales every geometry field. Phase 30 should either:

- replace it with a helper that scales only face shape, nose, and mouth fields; or
- zero eyes first and then call a renamed non-eye geometry scaler.

Recommended logic:

```text
if freshness == reused:
    if any non-eye geometry is requested:
        scale face-shape/nose/mouth by 0.5
        preserve geometry_stale_reduced and reusedGeometryScale = 0.5
    if any eye geometry is requested:
        zero all four eye strengths
        record eyes skipped and reused-eye reason
```

This preserves D-09 and avoids emitting the generic “reduced” reason for an eye-only request that was actually skipped. If reused eye and reused non-eye geometry are both requested, both the eye-specific skip reason and existing generic non-eye reduction reason are valid and should be deterministic.

### 4. Zero Eye Strengths on All Eye-Specific Skip Paths

Add one private helper to prevent partial zeroing:

```swift
private static func zeroEyeStrengths(_ strengths: inout BeautyEffectiveStrengths) {
    strengths.eyeSize = 0
    strengths.eyeDistance = 0
    strengths.eyeYPosition = 0
    strengths.eyeTailLift = 0
}
```

Call it for:

- reused eye geometry;
- stale eye geometry;
- missing left or right eye after `EyeWarpProvider` returns no points.

For no-face facade behavior, the locked evidence requires dimensions, redaction, and safe-domain continuation. It does not require broadening this internal zeroing rule to every no-face domain; do not change unrelated no-face effective-strength semantics unless a failing locked test demonstrates the need. [CITED: D-12]

### 5. Keep Warning and Metric Payloads Aggregate-Only

Stable reason codes are part of the evidence contract. Messages should identify only the category, for example:

```text
eye_inputs_missing
eye_geometry_reused_skipped
eye_geometry_stale_skipped
```

The existing aggregate `beauty.effects.skippedEyeDomains = 1` can remain the common count. A new per-reason metric is optional, but if added it must be an aggregate count and asserted exactly. Do not include landmark names, coordinates, bounds, control points, paths, image bytes, raw detector/framework errors, or detector objects. [CITED: D-11; VERIFIED: `SECURITY.md`]

### 6. Exercise Combined Weakening Through the Existing Face-Shape Seam

`GeometryConflictResolver` is currently invoked by the face-shape and mouth resolver branches, not by a standalone eye-only branch. A combined test pairing only `eyeDistance` with `faceSlim` will not always exceed the `1.0` threshold (`0.30 + 0.60 = 0.90`). [VERIFIED: `GeometryConflictResolver.swift`; VERIFIED: caps]

Use representative `faceSlim: 1` plus `faceSmall: 1` in every per-behavior combined case. Their capped total is `1.05` before the eye field, so each of the six eye directions necessarily enters the weakening path.

For each case:

1. Resolve the eye parameter alone with `.fixture` and record its normal exact capped strength.
2. Resolve the same eye parameter with representative face shape.
3. Assert `.eyes` and `.faceShape` are active.
4. Assert sign is preserved for signed fields.
5. Assert combined absolute eye strength is greater than zero and strictly less than normal capped absolute strength.
6. Assert `combined_geometry_weakened`, `weakenedCount > 0`, and `geometryStrengthScale < 1`.

The all-eye multi-domain case can use all four eye fields plus `faceSlim` and `noseSlim`, which exercises eyes + face shape + nose without requiring a new provider or renderer case. Assert the chosen exact `weakenedCount` based on the nonzero field inventory, stable warning presence, scale below one, and all signed directions.

## Focused Test Design

### EYE-04: Input and Cap Matrix

Prefer table-driven tests, but make failures identify the parameter/direction clearly.

| Field | Public normalization | Resolver cap cases | Non-finite cases |
| --- | --- | --- | --- |
| `eyeSize` | negative -> `0`; positive finite overflow -> `1` | `+1 -> +0.45`; negative -> `0` with no missing warning | `NaN`, `+∞`, `-∞` -> `0` |
| `eyeDistance` | finite overflow -> signed `±1` | `+1 -> +0.30`; `-1 -> -0.30` | `NaN`, `+∞`, `-∞` -> `0` |
| `eyeYPosition` | finite overflow -> signed `±1` | `+1 -> +0.25`; `-1 -> -0.25` | `NaN`, `+∞`, `-∞` -> `0` |
| `eyeTailLift` | negative -> `0`; positive finite overflow -> `1` | `+1 -> +0.30`; negative -> `0` with no missing warning | `NaN`, `+∞`, `-∞` -> `0` |

For each independent cap case, assert:

- exact effective value with a small numeric accuracy;
- `.eyes` active on complete fresh geometry;
- `beauty_strength_capped` exists;
- `beauty.effects.cappedCount == 1`;
- no combined-weakening warning when only one eye field is active.

For negative positive-only and every non-finite case, assert:

- normalized public value and effective value are exactly zero;
- `.eyes` is neither active nor spuriously skipped;
- `eye_inputs_missing` is absent;
- cap warning is absent and capped count remains zero.

### EYE-05: Layered Degradation Matrix

| Layer | Case | Required assertions |
| --- | --- | --- |
| Public facade | no face + eye + brightness/filter | detector runs once; extent preserved; `.noFace`; safe active count remains; geometry point count absent; generic no-face warning; metadata redacted. |
| Provider | missing left eye | no points; `eye_inputs_missing`. |
| Provider | missing right eye | no points; same stable missing reason. |
| Resolver | missing either eye with all eye fields + nose/color/filter | `.eyes` skipped/not active; nose/color/filter continue; all four eye strengths zero; aggregate skip count `1`; missing reason only. |
| Resolver | reused with all eye fields | `.eyes` skipped/not active; all four eye strengths zero; no eye control points; reused-eye reason. |
| Resolver | reused with non-eye geometry | face shape/nose/mouth remain active at established `0.5` reuse scale; generic reduction warning remains. |
| Resolver | stale with all eye fields | `.eyes` skipped/not active; all four eye strengths zero; no eye control points; stale-eye reason. |
| Redaction | missing/reused/stale plans | warning messages and metric keys exclude raw payload terms. |

Update the two existing reused-eye assertions rather than leaving contradictory legacy tests beside the new policy.

### EYE-06: Seven Combined Cases

The exact behavior inventory must mirror Phase 29:

1. `eyeSize` positive.
2. `eyeDistance` positive.
3. `eyeDistance` negative.
4. `eyeYPosition` positive.
5. `eyeYPosition` negative.
6. `eyeTailLift` positive.
7. All four eye parameters with at least two geometry domains in addition to eyes.

Do not substitute one generic “all high strengths” assertion for the six direction-specific cases; D-13 explicitly requires per-behavior evidence.

## Recommended File and Plan Structure

### Plan 30-01 — Public Semantics and Caps

Likely files:

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift`
- a focused resolver test surface, either `BeautyEffectResolverTests.swift` or a new `EyeSafetyTests.swift`

Deliver positive-only normalization, signed preservation, the four-field finite/non-finite matrix, exact caps, warning, and capped metric.

### Plan 30-02 — Eye Degradation and Combined Weakening

Depends on 30-01. Likely files:

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift`
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`
- `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`
- shared test fixture declaration in `FaceShapeWarpProviderTests.swift` only if the existing shared extension remains the preferred location

Deliver distinct missing/reused/stale reasons, zero strengths/control points, non-eye reuse preservation, public no-face evidence, six combined cases, and one all-eye multi-domain case.

### Plan 30-03 — Evidence and Boundary Gate

Depends on 30-02. Likely artifacts:

- `30-EYE-SAFETY-EVIDENCE.md` (name discretionary)
- `30-VERIFICATION.md`
- in-progress `30-VALIDATION.md` with executed rows passed and downstream closeout rows pending
- `30-REVIEW.md` because code review is enabled
- `30-SECURITY.md` because security enforcement is enabled

Run all focused/full tests, Phase 29 renderer regression, active-source scans, generated-artifact guards, requirement/decision coverage, and wording scans. Do not promote the ledger in this plan.

### Plan 30-04 — Atomic Promotion and Blueprint Synchronization

Depends on a fully passing 30-03. Update the four ledger rows in one task/edit and immediately run exact row/branch guards. Keep the five blueprint owners together so the atomic status transition, branch-partial wording, and unchanged renderer-validation contract remain one auditable unit.

### Plan 30-05 — Root Contract Synchronization

Depends on 30-04. Update `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and the Phase 30 security audit with independent per-file invariant, evidence-link, privacy, and no-overclaim gates.

### Plan 30-06 — Quality and Project Synchronization

Depends on 30-05. Update `QUALITY_SCORE.md` and `.planning/PROJECT.md` from observed evidence only, leaving final requirement/workflow status to the last consistency owner.

### Plan 30-07 — Final GSD and Work-Ledger Closeout

Depends on 30-06. Update requirements, roadmap, state, `PLANS.md`, final verification, and validation with independent per-file checks. This ordering is essential: evidence documents are inputs to promotion, and final `passed`/Nyquist status follows every required document rather than preceding it.

## Boundary Scan Architecture

### Active Source Sets

Use explicit source roots so build outputs, ignored worktrees, generated images, and historical evidence are not accidentally treated as shipping source:

- `BeautySDK/Sources/BeautySDK`
- `BeautySDK/Sources/BeautyCore`
- `BeautySDK/Sources/BeautyDetection`
- `BeautySDK/Sources/BeautyEffects`
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautyDemo/BeautyDemo`

Tests may be scanned for import/inventory behavior, but broad forbidden-token scans must classify guard literals instead of treating their presence as a leak. [CITED: D-17]

### Public/SPI Raw Geometry Guard

The existing Phase 29 pattern remains valid:

```bash
rg -n "public .*FaceGeometry|public .*BeautyFaceObservation|public .*[Ll]andmark|public .*bounding|@_spi.*FaceGeometry|@_spi.*BeautyFaceObservation" \
  BeautySDK/Sources/BeautySDK \
  BeautySDK/Sources/BeautyDetection \
  BeautySDK/Sources/BeautyEffects
```

Expected result: no real matches. Current raw face observation and landmark types are package-only. [VERIFIED: current declarations]

These and the following regexes define scan scope only. Phase 30 execution must redirect each scan to a file and branch explicitly on ripgrep status: `0` means matches to reject/classify, `1` means a clean no-match, and any larger status is a hard read/regex error. Do not mask status or use a negative two-branch form that treats status `2` as clean.

### Demo and Renderer Import Guards

```bash
rg -n "^import Beauty(Core|Detection|Effects|Render|Resources)$" \
  BeautyDemo/BeautyDemo \
  BeautyDemo/BeautyDemoTests \
  BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Expected result: no matches. `BeautyExampleRenderer` continues to import only `BeautySDK`. [VERIFIED: current source]

### Network/Cloud and Commercial Behavior Guards

Use API/path-shaped patterns rather than only lexical words:

- network: `URLSession`, `NWConnection`, `import Network`, upload/download request construction, remote endpoint literals;
- commercial: `import StoreKit`, `Product.products`, `Transaction`, purchase/subscription/receipt/paywall/entitlement execution paths.

A broader lexical scan will find the pre-existing static `vipChip` in Demo Home. Record it as an existing static reference UI token, not as an entitlement path, unless code inspection finds executable commercial behavior. [VERIFIED: current source; CITED: D-17]

Any new real behavior match in active source is a hard blocker under D-18.

### Public Parameter Inventory Guard

Keep and run the existing 31-field `Mirror` test. Also scan the Phase 30 diff or final source inventory for new eye field declarations. Do not rely only on a regex for field count because `CodingKeys`, initializer parameters, stored fields, and tests all repeat the names.

### Ledger Atomicity Guards

After promotion, the following facts must all be true:

- exactly four `眼睛` rows are `implemented`;
- those rows are exactly `大小`, `上下`, `眼距`, and `眼尾上扬`;
- no other `眼睛` row is `implemented`;
- no scoped row remains `partial`;
- `FEATURE_MATRIX.md` still contains `Beauty shaping | 眼睛 | partial`;
- the eyes README and beauty-shaping README state “four implemented subtools, branch partial,” not whole-branch completion.

If any fact fails, revert the attempted status edit before closeout and keep all four scoped rows partial per D-19.

## Documentation Promotion Map

### Always Update After Evidence Passes

| File | Required Phase 30 content |
| --- | --- |
| `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` | Promote only four rows; cite Phase 29 visible output plus Phase 30 safety/degradation/boundary evidence; retain future gaps. |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | Keep branch `partial`; update current evidence wording for the four implemented rows. |
| `docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md` | Record exact public semantics, dependencies, missing/reused/stale policy, four-row evidence, privacy boundary, and future tools. |
| `docs/meitu-function-blueprint/features/beauty-shaping/README.md` | Record scoped eye evidence while branch remains partial. |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | Add Phase 30 regression/closeout evidence while preserving the 23-case, 161-output, 36-comparison path. |
| `DESIGN.md` | Change eye range from generic mixed to explicit size/tail unit and distance/Y signed; record eye freshness/missing policy and testable contract. |
| `SECURITY.md` | Record Phase 30 redaction and active-source boundary evidence. |
| `RELIABILITY.md` | Replace the global “reused geometry reduces” wording with the eye-only skip exception; record distinct reason/metric evidence. |
| `PRODUCT_SENSE.md` | Add Phase 30 acceptance and non-claims for the scoped four rows. |
| `QUALITY_SCORE.md` | Record observed focused/full test counts, renderer regression, boundary scans, and remaining branch limitations. |
| `.planning/PROJECT.md` | Reflect completed existing-parameter eye slice without launch/commercial claims. |
| `.planning/REQUIREMENTS.md` | Mark EYE-04 through EYE-08 and DOC-01 complete only with Phase 30 evidence links. |
| `.planning/ROADMAP.md` | Mark Phase 30 plans/criteria complete from observed evidence. |
| `.planning/STATE.md` | Record Phase 30 completion/progress and next workflow state. |
| `PLANS.md` | Add completed execution ledger with exact commands, results, files, rationale, and non-claims. |
| Phase 30 artifacts | Map every requirement and D-01 through D-21 to exact tests/scans/docs. |

### Update Only If Their Owned Contract Changes

- `ARCHITECTURE.md`: no change is expected because target ownership, dependency direction, facade shape, and raw-geometry boundary remain unchanged.
- `FRONTEND.md`: no change is expected because no Demo UI/state behavior is in scope.
- `example-images/README.md`: no change is required unless the renderer/helper command or directory contract changes.
- `example-images/generate_gallery.py`: no change and no gallery rerun are required unless gallery logic changes.

## Common Pitfalls

### Pitfall 1: Zeroing Eyes Before Remembering They Were Requested

If the resolver zeros strengths and then uses `anyNonZero` to decide whether to enter the eye block, `.eyes` will disappear rather than being recorded as skipped. Preserve a pre-zero request boolean.

### Pitfall 2: Keeping the Global Reuse Scaler

Calling the current `scaleGeometryStrengths` unchanged violates D-07. Replacing global scaling with global skipping violates D-09. The policy must be domain-specific.

### Pitfall 3: Stale or Missing Eyes Remain Nonzero in the Plan

An inactive domain is not sufficient. D-07/D-08/D-12 require zero effective strengths and no points. Assert all four fields, not only `eyeSize`.

### Pitfall 4: Combined Cases Do Not Cross the Conflict Threshold

`faceSlim + eyeDistance` can total only `0.90` after caps, so no weakening occurs. Use a face-shape combination whose capped total guarantees the threshold is exceeded.

### Pitfall 5: Relational Cap Assertions Hide Wrong Direction

`abs(value) <= cap` passes for zero and for wrong-sign values. Assert exact signed values, warning code, and exact cap count.

### Pitfall 6: Negative Positive-Only Input Produces a Missing-Eye Warning

Once negative size/tail normalize to zero, they are no-op input—not a landmark failure. Tests must assert absence of missing-eye warning and geometry detection need.

### Pitfall 7: Broad `VIP` Scan Treats Static Reference UI as a New Path

The repository already contains `vipChip`. Classify it, and separately scan executable StoreKit/entitlement/purchase paths. Do not waive a real new path because a benign pre-existing token exists.

### Pitfall 8: Promotion Happens Before Renderer Regression

Phase 29 output evidence is a required Phase 30 gate. The four rows must remain partial until `161/161`, `36/36`, full tests, and EYE-07 scans pass in the Phase 30 execution state.

### Pitfall 9: Documentation Says the Branch Is Implemented

Second-level rows can be implemented while `FEATURE_MATRIX.md` remains branch-level `partial`. Scan for whole-branch completion wording in every touched root/blueprint/planning artifact.

### Pitfall 10: Exact Full-Suite Count Is Planned Instead of Observed

Phase 29 passed with 173 tests, but Phase 30 adds tests. Plans should require a passing full suite and record the observed final count; they should not guess a new number.

## Do Not Hand-Roll

- Do not create a new clamp helper; use `clampUnit`, `clampSigned`, `capUnit`, and `capSigned`.
- Do not create a new freshness model; use `FaceGeometry.freshness` and existing `.fresh`, `.reused`, `.stale` states.
- Do not create a new combined-strength resolver; exercise `GeometryConflictResolver`.
- Do not create a second eye provider or split eyes into a package.
- Do not add Phase 30 renderer cases or a second output helper; rerun Phase 29's canonical helper.
- Do not commit generated images, hashes, pixel arrays, or raw geometry evidence.
- Do not add a public degradation enum or raw geometry field merely to distinguish warnings; stable redacted warning codes and aggregate metrics are already the established contract.

## Environment Availability

| Dependency | Available | Version / fact | Planning implication |
| --- | --- | --- | --- |
| Swift / SwiftPM | yes | Apple Swift 6.3.3 | Existing package and tests are sufficient. |
| Xcode | yes | Xcode 26.6, build 17F113 | No Demo build is required if Demo source stays untouched; explicit simulator destination remains required if that changes. |
| Python 3 | yes | 3.9.6 | Existing Phase 29 standard-library helper is runnable. |
| ripgrep | yes | 15.1.0 | Use explicit active-source scans. |
| Git | yes | 2.50.1 | Use ignored-artifact, tracked-file, diff hygiene, and atomic-promotion checks. |
| Additional package | not needed | No new dependency is indicated. | Package-manager installs would be scope expansion. |

## Validation Architecture

### Test Infrastructure

| Property | Value |
| --- | --- |
| Framework | SwiftPM XCTest, unchanged `BeautyExampleRenderer`, Phase 29 Python helper, `rg` active-source scans, git artifact/ledger guards, GSD decision coverage. |
| Config | `BeautySDK/Package.swift`, `.planning/config.json`. |
| Research baseline | Focused six-suite regex run passed 49 tests in about 3.3 seconds. |
| Fast feedback target | Under 5 minutes for changed focused suites and static scans. |
| Full phase target | Under 30 minutes for focused tests, full SDK suite, renderer build/run, helper, security/review, scans, and closeout guards. |

### Recommended Focused Commands

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
```

If a new `EyeSafetyTests` class is created, add its exact focused command to every plan and validation row that depends on it.

### Phase Requirements to Test Map

| Requirement | Behavior | Automated evidence | Existing / gap |
| --- | --- | --- | --- |
| EYE-04 | Positive-only size/tail; signed distance/Y; finite and non-finite input. | `BeautyParametersTests` exact table. | Existing normalization test is partial; Phase 30 assertions required. |
| EYE-04 | Exact caps/directions, cap warning, exact capped count. | Resolver test against `.fixture`; `BeautySafetyCapsTests`. | Constants exist; exact per-field resolver matrix is missing. |
| EYE-05 | Public no-face dimensions, safe domains, detection summary, redaction. | `BeautyEngineGeometryFacadeTests` eye-specific test. | Pattern exists; eye-specific case missing. |
| EYE-05 | Either eye group missing skips whole eye domain. | `EyeWarpProviderTests` plus resolver tests. | Left-eye provider case exists; right-eye and zero-strength assertions missing. |
| EYE-05 | Reused eye skipped/zero/no points; non-eye reuse reduction unchanged. | `MissingLandmarkDegradationTests`. | Current eye assertion contradicts D-07 and must change. |
| EYE-05 | Stale eye skipped/zero/no points with distinct reason. | `MissingLandmarkDegradationTests`. | Skip exists; zero strengths/distinct reason missing. |
| EYE-05 | Missing/reused/stale reasons redacted. | Shared redaction assertion plus active warning/metric scan. | Reusable assertion exists; new reason coverage required. |
| EYE-06 | Six per-behavior normal-vs-combined weakening cases. | Table-driven `CombinedEffectSafetyTests` or focused equivalent. | Missing. |
| EYE-06 | All-eye multi-domain warning and aggregate metrics. | `CombinedEffectSafetyTests` exact warning/metric assertions. | Generic all-domain test exists but is not the required exact eye gate. |
| EYE-07 | No raw public/SPI geometry, internal imports, network/cloud, commercial paths, or fields. | Active-source scans plus 31-field inventory test. | Patterns exist; Phase 30 must rerun/classify. |
| EYE-08 | Exactly four rows implemented atomically. | Exact ledger row count/name guards. | Rows currently partial; execute only after all previous gates. |
| DOC-01 | Owning docs synchronized; branch partial; no overclaim. | Required-file scans, requirement/decision coverage, branch/wording guards. | Phase 30 artifacts and updates missing. |

### Full Phase Gate

Run in this order and stop before promotion on any failure:

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output
git ls-files example-images/output example-images/gallery
```

Required renderer/helper observations remain:

- exactly 23 renderer cases and 7 committed fixtures;
- `161/161` generated outputs;
- `36/36` portrait eye-vs-baseline comparisons;
- representative no-face eye output presence;
- no tracked generated output/gallery files.

Run gallery generation only if gallery logic changes. [CITED: D-16]

Then run:

- public/SPI raw geometry scan;
- Demo and renderer internal-import scan;
- network/cloud behavior scan;
- commercial entitlement behavior scan with `vipChip` classification;
- public parameter inventory test/scan;
- warning/metric and durable evidence redaction scan;
- no-overclaim scan;
- exact ledger and branch guards;
- D-01 through D-21 decision coverage;
- EYE-04 through EYE-08 and DOC-01 traceability scan;
- scoped `git diff --check`.

### Sampling Rate

- After normalization/cap task: run `BeautyParametersTests`, the focused resolver safety tests, and diff hygiene.
- After degradation task: run provider, missing-landmark, combined-safety, and facade tests plus redaction scans.
- After every wave: run every touched focused suite and active-source scans relevant to that wave.
- Before evidence is marked passed: run the full phase gate including Phase 29 helper.
- Before ledger edit: verify `30-VERIFICATION.md`, `30-VALIDATION.md`, `30-REVIEW.md`, and `30-SECURITY.md` are passing/clean/verified as applicable.
- After documentation promotion: rerun exact four-row/branch guards, requirement/decision coverage, no-overclaim scan, and `git diff --check`.

### Wave 0 Gaps for Nyquist VALIDATION.md

- [ ] Exact four-field public normalization and finite/non-finite matrix.
- [ ] Exact per-field cap/direction/warning/capped-count resolver matrix.
- [ ] Negative size/tail no-warning/no-detection evidence.
- [ ] Missing-right-eye provider fixture/test.
- [ ] Missing-eye resolver zero-all-strengths and unaffected-domain continuation assertions.
- [ ] Reused-eye skip/zero/no-point assertions replacing current reduction expectations.
- [ ] Non-eye reuse regression proving D-09.
- [ ] Stale-eye distinct reason and zero-all-strengths assertions.
- [ ] Eye-specific public facade no-face test.
- [ ] Six per-behavior combined-weakening cases.
- [ ] One all-eye multi-domain warning/metric case.
- [ ] Phase 30 evidence, validation, review, security, and verification artifacts.
- [ ] Active-source EYE-07 scan results and classified pre-existing lexical matches.
- [ ] Atomic four-row promotion guard and branch-partial guard.

### Manual-Only Verification

No manual visual-quality, device-parity, or commercial review is required or allowed as a Phase 30 completion claim. A final wording review is appropriate to ensure documentation does not imply those claims or whole-branch completion; automated no-overclaim scans should accompany it.

## Security Domain

Security enforcement is enabled at ASVS level 1 and blocks high findings. [VERIFIED: `.planning/config.json`]

### Applicable Security Categories

| Category | Applies | Phase 30 control |
| --- | --- | --- |
| Input validation | yes | Positive-only/signed normalization, finite overflow, non-finite zeroing, exact caps. |
| Error handling/logging | yes | Stable distinct warning codes and aggregate metrics only. |
| Privacy/data protection | yes | No raw eye/face geometry, paths, pixels, hashes, framework errors, or detector objects in public/durable evidence. |
| Access control/auth/session | no | No account or protected service is in scope. |
| Network/remote processing | boundary only | Active source must remain local-only. |
| Commercial entitlement | boundary only | No StoreKit, payment, VIP execution, subscription, or entitlement path. |

### Threats the Plans Must Carry

| Threat | Failure mode | Required mitigation |
| --- | --- | --- |
| Invalid input survives normalization | NaN/∞ or wrong-sign values reach rendering. | Exact four-field matrix and resolver assertions. |
| Reused eye geometry is applied | Privacy/safety decision D-07 is violated. | Domain-specific reuse policy and zero/no-point test. |
| One-eye warp is applied | Asymmetric visible geometry. | Both-eye provider guard and left/right tests. |
| Skip reason leaks geometry | Public warning/metric contains sensitive payload. | Stable category codes, aggregate counts, redaction tests/scans. |
| Hidden scope expansion | Raw API, internal import, network, commercial, or new public field appears. | EYE-07 active-source hard gates. |
| False promotion | Rows become implemented before all evidence passes. | Separate evidence and promotion plans; exact atomic guard. |
| Status overclaim | Four rows are described as full branch/product readiness. | Branch-partial and no-overclaim guards. |
| Generated artifact leak | Local output/gallery PNG enters git. | `git check-ignore` representatives and `git ls-files` zero-result gate. |

`30-SECURITY.md` should contain a threat register, dispositions, accepted-risks log, audit trail, and `threats_open: 0` before promotion, mirroring Phase 29's final security artifact.

## Assumptions Log

| # | Assumption | Confidence | Planning consequence |
| --- | --- | --- | --- |
| A1 | No production change is needed in `EyeWarpProvider`; resolver zeroing plus existing both-eye guard is sufficient. | High | Plan provider test changes first; change provider only if focused tests expose a real gap. |
| A2 | `GeometryConflictResolver` already implements EYE-06 behavior correctly. | High | Add per-behavior evidence before changing resolver math. |
| A3 | Phase 29 renderer/helper counts remain 161/161 and 36/36 because Phase 30 adds no cases or fixtures. | High | Treat any regression as a blocker, not a planned count change. |
| A4 | Exact warning names remain discretionary. | High | Planner must choose once and use the same codes in code/tests/docs. |
| A5 | No Demo build is needed if no Demo source changes. | High | Run facade/import scans; use explicit simulator build only on unexpected Demo edits. |
| A6 | Milestone/phase completion is not a launch-readiness claim. | High | Planning docs may record requirement completion while preserving all release/device/commercial non-claims. |

## Open Questions (Resolved for Planning)

1. **Should negative size/tail produce an opposite visual direction?** No. They normalize to zero; opposite directions are deferred. [CITED: D-01, D-02; deferred section]
2. **Should all reused geometry now skip?** No. Only eyes skip; face shape, nose, and mouth retain reuse reduction. [CITED: D-07 through D-09]
3. **Is one generic stale warning enough?** No for eye evidence. Missing, reused, and stale eye skips need distinct stable reasons. [CITED: D-11]
4. **Are existing all-domain combined tests enough?** No. Six per-behavior eye cases plus one all-eye multi-domain case are required. [CITED: D-13, D-14]
5. **Must Phase 30 add renderer cases or gallery logic?** No. It reruns Phase 29 evidence; gallery reruns only if gallery logic changes. [CITED: D-16]
6. **Can rows promote independently?** No. All four promote atomically after every gate, or all stay partial. [CITED: D-18, D-19]

## Primary Sources

- `AGENTS.md`, `PLANS.md` — repository workflow, verification, and record policy. [VERIFIED: local reads]
- `.planning/phases/30-eye-safety-ledger-and-closeout/30-CONTEXT.md` — authoritative Phase 30 user decisions. [CITED]
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `.planning/PROJECT.md` — milestone scope and traceability. [VERIFIED: local reads]
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` — current owning contracts. [VERIFIED: local reads]
- `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, eyes README, beauty-shaping README, and shared implementation principles — current status/evidence rules. [VERIFIED: local reads]
- Phase 29 context/evidence/verification/security/validation and helper — renderer regression contract. [VERIFIED: local reads]
- Phase 28 context/research/validation/verification/plans — precedent for evidence-before-promotion and branch-partial closeout. [VERIFIED: local reads]
- Current `BeautyParameters`, caps, resolver, conflict resolver, eye provider, geometry pipeline, engine route, and focused tests. [VERIFIED: current source]

No external facts or web sources are needed for this phase; repository code, tests, contracts, and evidence fully determine the plan.

## Metadata

**Confidence breakdown:**

- Public normalization and cap seam: HIGH — exact helpers and constants are present and directly tested.
- Degradation architecture: HIGH — current global reuse seam and required eye exception are explicit in code/context.
- Combined weakening: HIGH — current total/scale math and invocation seam are inspectable; test inputs can deterministically exceed threshold.
- Boundary/document promotion: HIGH — Phase 28/29 precedents and current ledger rows are explicit.
- Environment: HIGH — focused baseline tests and tool versions were verified locally.

**Valid until:** the Phase 30 implementation changes the cited resolver/test/document surfaces or Phase 29 renderer matrix/fixtures change.

## RESEARCH COMPLETE
