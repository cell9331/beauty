# Phase 91: Independent Gaze Correction - Pattern Map

**Mapped:** 2026-09-04
**Files analyzed:** 21 likely new/modified files
**Analogs found:** 21 / 21

This map is intentionally a seam map, not authorization to touch every listed file. The planner should choose the smallest set that can bind per-eye production support, final post-conflict aggregate evidence, generated actual-pixel proof, and temporary renderer/comparator admission. Public parameter, preset, renderer-case, backend, and retained `Warp.metal` inventories stay unchanged.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` | model | transform | `BeautyEyeSemanticSupport` in the same file | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` | adapter | transform | its current independent validation followed by paired clearing | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` | provider | transform | its current gaze sample/emission/evidence path | exact |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | service/resolver | request-response | final emissions and retained-mask reconciliation in the same file | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | service/resolver | transform | current 44-field conflict scaling | role-match; avoid unless aggregate ownership cannot stay in `BeautyEffectResolver` |
| `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` | service | request-response | current plan-metric merge | exact |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` | test fixture provider | request-response | existing deterministic observed-eye fixture matrix | exact |
| `BeautySDK/Sources/BeautyExampleRenderer/RendererCLIContract.swift` | model/config | file-I/O | `RendererOutputUnit` / `RendererReport` | exact |
| `BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift` | service | file-I/O | successful `processResult` unit recording and atomic sorted report | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift` | test | transform | current pupil cardinality, pair-ratio, and invalid-peer tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` | test | transform | current dead-zone, monotonicity, and aggregate tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | test | transform | exact 44-field inventory/conflict tests | role-match |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGazeCorrectionRepairTests.swift` (new) | test | request-response + generated pixel I/O | `BeautyEngineChinTaperRepairTests.swift` | role-match |
| `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift` | test | process/file-I/O | current deterministic report and privacy tests | exact |
| `scripts/compare-face-feature-batches.swift` | utility/validator | batch + file-I/O | existing semantic admission, mutations, stable payload | exact |
| `scripts/run-face-feature-batches.sh` | utility/orchestrator | batch + file-I/O | current two-attempt temporary lifecycle | exact |
| `scripts/test-face-feature-batch-boundaries.py` | test | process/file-I/O | current stale/path/symlink/cleanup mutations | exact |
| `PLANS.md` | config/ledger | batch | Phase 90 completed record and Phase 91 handoff | exact |
| `DESIGN.md`, `ARCHITECTURE.md`, `PRODUCT_SENSE.md` | config/owner docs | request-response | Phase 90 owner-contract sections | role-match |
| `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md` | config/owner docs | batch/file-I-O | Phase 89/90 trust, execution, and evidence sections | exact |
| `docs/SDK_EFFECT_TAXONOMY.md` | config/taxonomy | transform | Phase 90 status explanation and current gaze row | exact |

## Pattern Assignments

### Per-eye support model and adapter

**Targets:** `WarpControlPoint.swift`, `BeautyFaceGeometryAdapter.swift`

**Analog:** `BeautyEyeSemanticSupport` keeps biometric-adjacent support target-internal and non-Codable (`WarpControlPoint.swift:11-34`):

```swift
/// Validated, request-scoped semantic evidence for one observed eye.
/// This type deliberately remains target-internal: observed biometric-adjacent
/// coordinates must never become part of the public or Codable surface.
struct BeautyEyeSemanticSupport: Equatable, Sendable {
    let side: BeautyObservedEyeSide
    let contour: [SIMD2<Float>]
    let center: SIMD2<Float>
    let pupil: SIMD2<Float>?

    var pupilSizeEligible: Bool { pupilEligible }
    var gazeCorrectionEligible: Bool { pupilEligible }
}
```

**Core ownership pattern:** mapping and local validation occur before the peer decision (`BeautyFaceGeometryAdapter.swift:92-114`):

```swift
let leftObserved = supportsBySide?[.left].flatMap {
    validatedSupport($0, bounds: bounds)
}
let rightObserved = supportsBySide?[.right].flatMap {
    validatedSupport($0, bounds: bounds)
}
let paired = validatePairedPupils(left: leftObserved, right: rightObserved)
let leftSupport = leftObserved.map { support in
    support.withPupil(paired.left)
}
```

Phase 91 should split the stored semantics here: retain the locally validated pupil for gaze, while preserving the existing paired result for `pupilSize`. Do not globally reinterpret `pupilEligible`, because existing compatibility tests currently encode pair clearing.

**Validation/fail-closed pattern** (`BeautyFaceGeometryAdapter.swift:296-327`): require exactly one finite normalized pupil, bounded containment, and ellipse plausibility; return `nil`, never synthesize or borrow.

**Existing defect to mutate:** `validatePairedPupils` returns `(nil, nil)` on a peer width/height-ratio failure (`BeautyFaceGeometryAdapter.swift:277-293`). Phase 91 tests must prove this can still clear paired pupil-size eligibility without clearing independent gaze eligibility.

### Gaze-only provider and anatomy-bounded influence

**Target:** `EyeWarpProvider.swift`

**Analog:** preserve the common selector for unrelated controls and add a gaze-only selector. The current coupling is explicit (`EyeWarpProvider.swift:76-98,117-127`):

```swift
let supports = semanticSupports(in: face)
// ... all existing fields use supports ...
gazeCorrection: strengths.gazeCorrection > 0
    ? supports.flatMap { gazePoints(support: $0, face: face, strength: strengths.gazeCorrection) }
    : []

private func semanticSupports(in face: FaceGeometry) -> [BeautyEyeSemanticSupport] {
    if let left = face.leftEyeSupport, let right = face.rightEyeSupport {
        return [left, right]
    }
    // legacy both-eye compatibility path follows
}
```

Use a private `gazeSupports`-style selector that returns zero, one, or two independently eligible observed sides. An explicit observed payload must never fall back to `legacySupport`; only the existing nil-observation compatibility path may use it.

**Frozen vector pattern** (`EyeWarpProvider.swift:180-195`):

```swift
guard let pupil = support.pupil, support.contourEligible else { return nil }
let delta = support.center - pupil
let length = sqrt(delta.x * delta.x + delta.y * delta.y)
guard length.isFinite, length > 0.002, strength.isFinite, strength > 0 else { return nil }
let blend = min(0.35, 0.35 * strength / BeautySafetyCaps.gazeCorrection)
let target = pupil + delta * blend
```

Keep the `0.002` dead zone, `0.25` cap, and `35%` maximum exactly. Replace only the fixed `face.bounds.width * 0.05` radius with a finite positive radius bounded by minimum source/target clearance to the closed eye-contour segments. A degenerate/self-intersecting contour, outside source/target, or nonpositive clearance rejects that eye only.

**Aggregate correction:** the current aggregate sums both offsets (`EyeWarpProvider.swift:101-114`), which can hide one worsening eye. Reuse the sample path, but compute in memory per eligible eye and retain only counts, `allReduced`/`abstained`, and minimum bounded Q16 reduction—never side labels or values.

### Final post-conflict aggregate ownership

**Preferred target:** `BeautyEffectResolver.swift`; **secondary analog:** `GeometryConflictResolver.swift`

The final-state seam already exists after iterative scale-and-sanitize convergence (`BeautyEffectResolver.swift:665-715`):

```swift
let resolution = GeometryConflictResolver().resolve(strengths: retainedBaseline)
var nextBaseline = faceProvider
    .fieldEmissions(face: faceGeometry, strengths: resolution.strengths)
    .sanitizing(retainedBaseline)
// ...
nextBaseline = eyeProvider
    .fieldEmissions(face: faceGeometry, strengths: resolution.strengths)
    .sanitizing(nextBaseline)
if nextBaseline == retainedBaseline {
    return resolution
}
```

After this converges, the resolver recomputes `finalEyeEmissions` from final strengths (`BeautyEffectResolver.swift:443-506`). Attach gaze aggregates only from that final admitted gaze field and its same-request eligible samples. Do not attach evidence to pre-conflict intent or to `EyeWarpProvider.gazeCorrectionEvidence` before reconciliation.

Merge fixed aggregate metrics alongside existing final metrics (`BeautyEffectResolver.swift:612-615`):

```swift
metrics["beauty.effects.activeCount"] = Double(activeDomains.count)
metrics["beauty.effects.cappedCount"] = Double(cappedCount)
if geometryPointCount > 0 {
    metrics["beauty.effects.geometryPointCount"] = Double(geometryPointCount)
}
```

Use a compile-time allowlist such as eligible/corrected/rejected counts, all-reduced, abstained, and minimum-reduction-Q16. Values are integral `Double`s with strict ranges. No raw/per-side coordinate, contour, pupil, vector, radius, mask, or pixel metric is permitted.

`GeometryConflictResolver.swift:16-80` is the analog for deterministic fixed-field scale plus aggregate metrics, but it should remain generic unless a final-state aggregate cannot be expressed in `BeautyEffectResolver`; putting gaze anatomy there would blur ownership.

### SDK metric propagation and deterministic testing fixture

**Targets:** `BeautyEngineGeometryDetection.swift`, optionally `BeautyEngineTestingSupport.swift`

The SDK already copies plan metrics and adds detection aggregates without exposing geometry (`BeautyEngineGeometryDetection.swift:80-95`):

```swift
var metrics = plan.metrics
metrics["beauty.detection.geometryRequired"] = geometryRequired ? 1 : 0
metrics["beauty.detection.faceCount"] = Double(summary.faceCount)
metrics["beauty.detection.usedFaceCount"] = Double(summary.usedFaceCount)
return BeautyEffectPlan(
    activeDomains: plan.activeDomains,
    skippedDomains: plan.skippedDomains,
    warnings: plan.warnings,
    metrics: metrics,
    effectiveStrengths: plan.effectiveStrengths
)
```

Prefer this unchanged transport. If the existing Testing SPI cannot express the independent matrix, extend its enum/provider pattern, not production public APIs. Existing helpers build deterministic 16-point contours and explicit pupils (`BeautyEngineTestingSupport.swift:62-110`); add only fixed cases needed for valid-left/invalid-right, invalid-left/valid-right, both valid, centered, malformed, and request-sequence recovery.

### Generated public-facade actual-pixel oracle

**New target:** `BeautyEngineGazeCorrectionRepairTests.swift`

**Analog:** `BeautyEngineChinTaperRepairTests.swift:17-64,93-155,212-227`.

```swift
let width = 512
let height = 512
let source = Self.fixtureBytes(width: width, height: height)
let image = Self.image(bytes: source, width: width, height: height)
let active = try process(image: image, fixture: .usableFace,
                         parameters: .init(chinTaper: 0.25))
let repeated = try process(image: image, fixture: .usableFace,
                           parameters: .init(chinTaper: 0.25))
let neutral = try process(image: image, fixture: .usableFace, parameters: .init())

XCTAssertEqual(active.result.output.extent, image.extent)
XCTAssertEqual(neutral.bytes, source)
XCTAssertEqual(active.bytes, repeated.bytes)
XCTAssertTrue(stride(from: 3, to: active.bytes.count, by: 4)
    .allSatisfy { active.bytes[$0] == 255 })
```

Copy the structure, not the chin darkness metric. Generate a 512×512 explicit-sRGB RGBA8 image in memory with independently declared left/right apertures, contour rings, distinct chromatic/textured pupil markers, brows, protected face/background, and alpha. Determine output pupil centroids only from fixture-owned marker identity, not darkness. Assert each eligible marker moves closer to its own declared center, the invalid peer is source-exact, target change floors pass, protected regions remain within frozen bounds, extent/metadata/alpha are preserved, repetition is byte-stable, and valid→invalid→valid requests recover without retained support.

Reuse the redaction scan shape (`BeautyEngineChinTaperRepairTests.swift:212-227`) and expand it for Phase 91 forbidden terms, including side labels in durable aggregate keys if the locked contract disallows them.

### Renderer report aggregation and exact unit binding

**Targets:** `RendererCLIContract.swift`, `RendererExecution.swift`, `BeautyExampleRendererProcessTests.swift`

The report's identity and deterministic-count contract is already per output (`RendererCLIContract.swift:66-101`):

```swift
struct RendererOutputUnit: Codable {
    let inputID: String
    let caseID: String
    let outputID: String
    let status: String
    let failureCode: RendererDiagnosticCode?
}

var countsReconcile: Bool {
    requested == succeeded + failed + skipped
}
```

Add one optional nested aggregate only on the exact successful output unit. Populate it from the `BeautyResult` produced immediately before that output is encoded (`RendererExecution.swift:333-369`). Copy only fixed allowlisted keys with integral/range validation; a failed/skipped unit has no successful aggregate.

Keep the existing sorted, atomic report write (`RendererExecution.swift:424-445`):

```swift
let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys]
try encoder.encode(report).write(to: reportURL, options: .atomic)
```

Extend the compiled-process test pattern: run twice, compare PNG/report bytes, decode and reconcile, and privacy-scan stdout/stderr/report (`BeautyExampleRendererProcessTests.swift:46-81`). Add missing/extra/fractional/out-of-range aggregate cases and verify no aggregate appears for sibling or failed units.

### Comparator admission, gaze branch, and mutation self-tests

**Target:** `scripts/compare-face-feature-batches.swift`

The current `.pupilToOwnEyeCenter` branch deliberately throws `unsupported_metric` rather than infer anatomy from darkness (`compare-face-feature-batches.swift:751-768`). Replace only this direction with exact renderer-aggregate admission; leave all other semantic metrics unchanged.

Retain the frozen actual-pixel gates from `semanticMeasurement` (`compare-face-feature-batches.swift:806-893`): source/neutral target signal, outside locality, protected regions, and sibling distinctness. For gaze, direction and signed Q16 reduction come from the admitted same-unit aggregate; sibling distinction still requires real candidate-versus-sibling target pixel signal and absence of a successful gaze aggregate on siblings. Do not call `semanticMetricValue` for gaze source/neutral/sibling images.

Use existing filesystem admission (`compare-face-feature-batches.swift:1129-1151`): canonical non-symlink directories and regular bounded files beneath the attempt root. Require exactly one successful renderer unit whose `inputID + caseID + outputID`, backend, schema, and reconciled counts match the candidate image.

Use existing stable payload/privacy machinery (`compare-face-feature-batches.swift:1466-1575`): sorted canonical JSON, fixed inventory, privacy scan, SHA-256 digest, and atomic output. The aggregate is an admission input; persist only approved aggregate results already represented in the semantic direction row.

Extend the self-test beside the current gaze adversaries (`compare-face-feature-batches.swift:1803-1842`). Required mutations include lash/shadow darkness, foreign dark patches, centered/off-center proxy images without aggregate, replayed report, wrong input/case/output ID, wrong backend/schema/counts, missing/extra keys, fractional/negative/out-of-range values, inconsistent all-reduced/abstained/count relationships, sibling aggregate spoofing, stale/symlink report, and one-eye-improves/one-eye-worsens hidden by a total sum.

### Runner temporary report lifecycle

**Targets:** `run-face-feature-batches.sh`, `test-face-feature-batch-boundaries.py`

The runner already creates one retained and one repeat attempt plus temporary comparator reports (`run-face-feature-batches.sh:615-632`) and reconciles canonical payload bytes/digests before publication (`run-face-feature-batches.sh:734-787`). Keep that two-attempt pattern.

Current `render_one` deletes the renderer report immediately (`run-face-feature-batches.sh:646-673`):

```bash
if "$renderer" ... --output "$case_root" --case "$case_id" --backend cpu; then
  rendered_units=$((rendered_units + 1))
else
  render_failures=$((render_failures + 1))
fi
safe_remove_temporary_file "${case_root}/beauty-example-renderer-report.json"
```

For Phase 91, retain each admitted renderer report under its protected attempt/case root until comparator consumption. Then remove every renderer report before durable publication/retention and verify absence. Cleanup failure is infrastructure failure, never semantic failure or stale evidence.

Extend the Python boundary style, which invokes subprocesses with captured output and checks exact envelopes (`test-face-feature-batch-boundaries.py:20-97`) inside a `tempfile.mkdtemp` root with unconditional helper cleanup (`test-face-feature-batch-boundaries.py:122-139,226-232`). Add stale/replay, report symlink, path escape, candidate/report mismatch, cleanup-fault, and leftover-report assertions while persisting only aggregate pass/fail counts.

### Frozen manifest contract

**Target:** normally no change to `scripts/face-feature-batch-manifest.json`; if touched, only bind admission without weakening values.

The gaze row already freezes the exact case, sibling set, target regions, pixel floors, locality ceiling, and protected regions (`face-feature-batch-manifest.json:138-152`). Do not change those thresholds after observing output. A separate report-schema identifier may be added only if the comparator cannot bind it without altering frozen semantic thresholds.

### Owner-document synchronization

**Targets:** `PLANS.md`, `DESIGN.md`, `ARCHITECTURE.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, `docs/SDK_EFFECT_TAXONOMY.md`

Copy the Phase 90 append-only owner pattern: one phase-named section per owner, with scope, exact behavior/evidence, failure and privacy boundaries, verification commands/results, and explicit nonclaims. Useful analog locations are `DESIGN.md:1467+`, `PRODUCT_SENSE.md:391+`, `QUALITY_SCORE.md:94+`, `SECURITY.md:522+`, `RELIABILITY.md:576+`, and `docs/SDK_EFFECT_TAXONOMY.md:179+`.

Synchronize only after the implementation outcome is known:

- `DESIGN.md`: per-eye support split, frozen dead zone/cap/fraction, aperture containment, final aggregate semantics.
- `ARCHITECTURE.md`: exact request-local adapter→provider→final resolver→SDK metric→renderer report→temporary comparator path.
- `PRODUCT_SENSE.md`: owner-local still-image behavior, per-eye failure isolation, no new public method/control.
- `SECURITY.md`: request-local anatomy, fixed aggregate allowlist, renderer binding, report cleanup, prohibited persistent terms.
- `RELIABILITY.md`: deterministic fail-closed admission, stale/replay rejection, recovery, cleanup/infrastructure classification.
- `QUALITY_SCORE.md`: generated actual-pixel mechanics evidence plus comparator mutations; no real-media/device/commercial claims.
- `docs/SDK_EFFECT_TAXONOMY.md`: revise the existing gaze row/status explanation only if the verified Phase 91 outcome warrants it.
- `PLANS.md`: record the one research pass, independently checked plan, attempt count (maximum two), commits, exact fresh gates, and either completed or honest repair/defer/stop outcome.

## Shared Patterns

### Authentication

Not applicable. Phase 91 adds no network, server, account, or authorization surface.

### Validation and failure isolation

Apply adapter validation before provider selection; reject only the invalid eye; never borrow the peer, legacy proxy, output darkness, stale request data, or inferred symmetry. Pair-level checks remain for genuinely bilateral consumers such as the existing paired pupil-size compatibility path.

### Error handling

Production geometry failures are typed/fixed-reason fail-closed no-ops. Renderer/comparator report admission or cleanup faults are infrastructure failures. A measured output that passes admission but misses frozen semantic/protection thresholds is a semantic failure. Never convert missing anatomy evidence into an effectiveness failure row.

### Privacy and persistence

Raw pupil/contour coordinates, per-side values, masks, pixels, fixture paths, private locators, and child transcripts stay request-local or temporary. Durable JSON uses sorted fixed schemas and aggregate counts/Q16 only, then passes the existing sensitive-key/value scan.

### Testing

Use generated in-memory pixels for mechanics, XCTest for adapter/provider/resolver/public facade/compiled renderer, comparator self-test for admission/mutations, Python boundary tests for lifecycle/path faults, and runner preflight for exact 75 live / 65 selected / 8 semantic inventories. Phase 91 does not own the Phase 95 clean authorized-portrait rerun or full no-skip milestone closeout.

## No Analog Found

No file lacks a usable repository analog. The only new file, `BeautyEngineGazeCorrectionRepairTests.swift`, should copy the public-facade structure and privacy contract from `BeautyEngineChinTaperRepairTests.swift` while replacing the inadmissible darkness semantic with fixture-owned chromatic/texture marker centroid math.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `scripts`, root owner documents, `docs/SDK_EFFECT_TAXONOMY.md`

**Strong analogs read:** `BeautyFaceGeometryAdapter.swift`, `WarpControlPoint.swift`, `EyeWarpProvider.swift`, `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, `BeautyEngineGeometryDetection.swift`, `BeautyEngineTestingSupport.swift`, renderer contract/execution, adapter/provider/resolver/core/process tests, comparator, runner, boundary tests, manifest, and Phase 89/90 owner sections.

**Pattern extraction date:** 2026-09-04

## PATTERN MAPPING COMPLETE
