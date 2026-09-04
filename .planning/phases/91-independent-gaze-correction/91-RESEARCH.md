# Phase 91: Independent Gaze Correction - Research

**Researched:** 2026-09-04
**Domain:** request-local per-eye geometry, CPU still-image warping, semantic validation, and privacy-safe aggregate evidence
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** The only admissible production anatomy source is the existing
  request-local Apple Vision eye contour and pupil support after exactly-once
  coordinate mapping and current plausibility validation. Output darkness,
  lashes, shadows, foreign patches, symmetric proxies, inferred peer geometry,
  and new model/data paths cannot establish pupil or own-eye-center semantics.
- **D-02:** Eligibility and failure are per eye. One valid contour-plus-pupil
  side must remain active when the peer side is missing or implausible; the
  rejected side is preserved source-safe and contributes no borrowed,
  synthesized, mirrored, or stale support.
- **D-03:** Pair-level checks may remain only where a genuinely bilateral field
  needs them. They must not suppress an otherwise valid `gazeCorrection` side
  or make one eye's eligibility depend on the peer eye.
- **D-04:** Preserve the Phase 44 exact behavior contract: a normalized
  pupil-to-own-center offset at or below `0.002` is neutral, the public strength
  cap remains `0.25`, and the maximum centerward correction at that cap remains
  `35%`. The frozen Phase 89 thresholds are evidence boundaries and cannot be
  weakened after observing results.
- **D-05:** Use the narrowest pupil-local, anatomy-bounded influence that moves
  admitted pupil pixels while keeping eye aperture/contour, eyebrows, face,
  background, alpha, extent, and metadata inside existing exact or frozen
  tolerances. CPU remains the semantic oracle; the retained `Warp.metal`, public
  backend API, and CPU/GPU selection contract are unchanged.
- **D-06:** Neutral, no-face, reused/stale support, non-finite input, malformed
  contour/pupil, centered pupil, and rejected-side behavior remain deterministic
  and fail closed. A later valid request must recover without retained support.
- **D-07:** Phase 91 completion requires two linked proof layers: deterministic
  generated in-memory actual input/output pixel oracles whose pupil and eye
  anatomy are independently declared, and production-path request-local
  aggregate anatomy facts proving every eligible eye moved closer to its own
  center. Aggregate control-point evidence alone and image-darkness centroids
  alone are both insufficient.
- **D-08:** The Phase 89 gaze metric may become creditable only by consuming an
  allowlisted aggregate anatomy contract tied to the same request/output, while
  still enforcing its frozen actual-pixel target, locality, sibling, and
  protected-region gates. Phase 95 retains the final clean two-attempt,
  65-output, seven-effective-plus-one-deferred publication gate.
- **D-09:** Durable reports and diagnostics may contain only aggregate eligible,
  corrected, rejected, and protection counts; all-eyes-reduced/abstained state;
  bounded reduction statistics; and fixed reason codes. Raw or per-side
  coordinates, contour/pupil values, masks, pixels, fixture paths, private
  locators, and child transcripts remain request-local or temporary.

### Agent's Discretion

- Choose the narrowest existing internal seam for carrying the aggregate
  anatomy fact from `BeautyEffects` through the SDK-owned renderer/comparator,
  provided public facade signatures, parameter/preset/case inventories, and
  privacy boundaries remain unchanged.
- Choose exact private type names, generated fixture layout, integer/Q16
  representation, and focused test-file organization. The evidence must bind to
  actual rendered pixels and must mutation-test unsupported/proxy admission.

### Deferred Ideas (OUT OF SCOPE)

- Phase 95 owns the clean authorized-portrait rerun and final 65-output stable
  publication across all seven active repair directions plus deferred/partial
  `faceContourSmooth`.
- Phases 92–94 retain eyebrow-head, nose, and mouth-width repairs.
- New pupil models, datasets, weights, realtime/video support, physical-device
  qualification, population/naturalness claims, commercial approval, packaging,
  shipping, launch, release readiness, and external distribution remain outside
  Phase 91.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| EYE-01 | Positive `gazeCorrection` measurably reduces each supported pupil displacement from its own eye center without borrowing the other eye, while preserving aperture/contour/eyebrows/background; missing or implausible support fails closed per eye. | Separate gaze eligibility from the existing paired-pupil compatibility field, emit one anatomy-bounded control point per independently eligible eye, prove the public output with generated actual-pixel anatomy, and transport only same-request aggregate proof to the frozen Phase 89 comparator. [VERIFIED: `.planning/REQUIREMENTS.md` EYE-01; `91-CONTEXT.md` D-01 through D-09] |
</phase_requirements>

## Summary

The narrow repair is to split **gaze eligibility** from the existing paired-pupil compatibility decision, not to relax all eye semantics. `BeautyFaceGeometryAdapter` already validates each observed contour and pupil independently, but then `validatePairedPupils` clears both pupils when peer contour ratios fall outside `0.50...2.00`; `EyeWarpProvider.semanticSupports` subsequently requires both observed sides before any eye field, including gaze, can emit. Those are the two concrete couplings that violate per-eye EYE-01. [VERIFIED: `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift:72-114,277-328`; `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift:76-127`]

Preserve the paired pupil result for `pupilSize` and existing compatibility behavior, while retaining a second internal, request-local independently validated pupil value for gaze only. Add a gaze-only support selector that compact-maps the valid observed sides; never use the legacy synthetic support path for positive gaze because that path has no observed pupil. The existing sample formula already obeys the locked dead zone and correction law, but its fixed `face.bounds.width * 0.05` radius must be replaced by a finite radius bounded by the source pupil's and destination's clearance from the closed eye aperture. [VERIFIED: `WarpControlPoint.swift:11-42`; `EyeWarpProvider.swift:117-141,180-196`; `91-CONTEXT.md` D-01 through D-05]

Completion needs both proof layers. A focused public-facade SwiftPM test must render generated RGBA pixels whose two eye apertures, pupil markers, contours, brows, protected face/background, and alpha are declared independently of production geometry, then assert each eligible pupil marker's output centroid moved toward its own declared center. Separately, `BeautyResult.metrics` should carry a fixed integer/Q16 gaze aggregate into an optional per-output renderer report member; the runner retains that report only until the comparator binds it to exact case/input/output identities. The comparator may use the admitted aggregate for centerward direction only, while continuing to enforce the frozen actual-pixel target, sibling, outside, and protection gates. [VERIFIED: `BeautyEngineChinTaperRepairTests.swift:17-136`; `RendererCLIContract.swift:66-102`; `RendererExecution.swift:333-369`; `compare-face-feature-batches.swift:806-893`; `run-face-feature-batches.sh:646-708`; `91-CONTEXT.md` D-07 through D-09]

**Primary recommendation:** implement a field-local gaze seam—independent validated gaze pupil, aperture-bounded one-point warp, final-plan aggregate metrics, optional renderer-unit aggregate, and a gaze-specific comparator admission branch—without changing public signatures, inventories, sibling eye fields, the manifest thresholds, or `Warp.metal`. [VERIFIED: `91-CONTEXT.md`; repository seam inspection]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Observe and map eye contour/pupil once | Detection / planning adapter | — | `VisionFaceDetector` produces request-local observed support and `BeautyFaceGeometryAdapter` owns validation/mapping. [VERIFIED: `ARCHITECTURE.md`; `BeautyFaceGeometryAdapter.swift:72-130`] |
| Decide per-eye gaze eligibility | Effects domain model | Detection / planning adapter | The adapter must retain independently validated gaze evidence; `EyeWarpProvider` must consume only eligible sides for the gaze field. [VERIFIED: `WarpControlPoint.swift:11-42`; `EyeWarpProvider.swift:76-127`] |
| Generate pupil-local centerward warp | Effects | CPU render pipeline | Effects owns source/target/radius; existing CPU geometry rendering remains the semantic execution path. [VERIFIED: `ARCHITECTURE.md`; `EyeWarpProvider.swift:180-196`; `91-CONTEXT.md` D-05] |
| Produce same-request aggregate proof | Effects resolver / SDK result | Public facade diagnostics | The proof derives from final admitted gaze work and travels through the existing aggregate `BeautyResult.metrics` dictionary without raw anatomy. [VERIFIED: `BeautyEngineGeometryDetection.swift:65-95`; `PRODUCT_SENSE.md:149-175`; `91-CONTEXT.md` D-07/D-09] |
| Bind aggregate to rendered output | SDK-owned renderer | Runner temporary workspace | The renderer sees both the public result and exact input/case/output identities; its report is the narrow binding point. [VERIFIED: `RendererExecution.swift:333-369`; `RendererCLIContract.swift:66-102`] |
| Apply frozen semantic/protection verdict | SDK-owned comparator | Runner | The comparator already owns canonical pixel decode, target/locality/sibling/protection gates and stable report construction. [VERIFIED: `compare-face-feature-batches.swift:771-893,1554-1668`; Phase 89 verification] |
| Final 65-output/two-attempt publication | Phase 95 runner flow | Phase 91 bridge | Phase 91 makes gaze creditable and mutation-tested; Phase 95 owns the authorized full portrait rerun. [VERIFIED: `91-CONTEXT.md` D-08 and Deferred Ideas; Phase 89 verification] |

## Project Constraints (from AGENTS.md)

- Keep the repository SDK-only: no application source, UI behavior, application lifecycle, UI automation, or restoration of legacy UI into the repository. [VERIFIED: `AGENTS.md` §§1,5]
- Treat code/tests as highest authority, then `PLANS.md`, root owner documents, and historical `docs/`; use `docs/SDK_EFFECT_TAXONOMY.md` as the current effect/control status authority. [VERIFIED: `AGENTS.md` §§2,4]
- Preserve owner-local use and non-distribution; no third-party package, binary SDK, model/weight, App Store, customer, monetization, shipping, launch, or release-readiness claim. [VERIFIED: `AGENTS.md` §5]
- Do not modify retained `Warp.metal`, add a Metal/GPU API or backend, or introduce a new algorithm/model/data path for this milestone. [VERIFIED: `AGENTS.md` §5; `91-CONTEXT.md` D-05]
- Keep raw pixels, masks, landmarks, pupil positions, private fixture locators, paths, and child transcripts out of persistent evidence. [VERIFIED: `AGENTS.md` §§5-6; `SECURITY.md`; spike skill]
- Use repeatable SwiftPM and SDK-owned script evidence. Image-effect tests must inspect actual input/output pixels and metadata, including applicable extent, orientation/mirroring, color space, alpha, neutral identity, target change, protected regions, tolerance, determinism, and typed failure. [VERIFIED: `AGENTS.md` §6]
- Prefer generated, in-memory, deterministic mandatory fixtures. Rights-approved local portraits remain owner-local and are not required for Phase 91 planning or completion; Phase 95 owns the authorized portrait rerun. [VERIFIED: `AGENTS.md` §6; `91-CONTEXT.md` D-08; spike skill]
- Real-device feedback is optional and non-blocking; without it, make no device performance, heat, energy, long-run, commercial quality, packaging, shipping, launch, or release claims. [VERIFIED: `AGENTS.md` §6]
- Preserve unrelated local changes and archived milestone evidence; do not broaden Phase 91 into other eye controls or future phases. [VERIFIED: `AGENTS.md` §§7-8; `91-CONTEXT.md` Deferred Ideas]
- Any owner-local Swift-public behavior change would require `PRODUCT_SENSE.md`; this research recommends no public signature or new public behavior beyond repairing the existing gaze contract. [VERIFIED: `AGENTS.md` §8; `PROJECT.md` v1.22]

## Standard Stack

### Core

| Technology | Version / Contract | Purpose | Why Standard |
|---|---|---|---|
| Swift Package Manager / Swift | tools 6.0; host Swift 6.3.3 | Build library, executable renderer, and XCTest targets | Already owns all active code and evidence targets; no package migration is authorized. [VERIFIED: `BeautySDK/Package.swift:1-49`; local `swift --version`] |
| Apple Vision-backed `BeautyDetection` | repository implementation; iOS 17 / macOS 14 package floor | Request-local contour and pupil observation | It is the locked production anatomy source and already maps one selected observation. [VERIFIED: `BeautySDK/Package.swift:7-10,16-18`; `91-CONTEXT.md` D-01] |
| `BeautyEffects` geometry pipeline | repository implementation | Independent gaze validation, point generation, and final aggregate | It owns the current `EyeWarpProvider`, semantic support, and conflict-resolution seam. [VERIFIED: `BeautySDK/Package.swift:28-34`; `EyeWarpProvider.swift`] |
| CPU Core Image renderer | existing repository route | Permanent semantic output oracle | D-05 explicitly freezes CPU as the oracle and forbids shader/backend changes. [VERIFIED: `91-CONTEXT.md` D-05; `ARCHITECTURE.md`] |
| XCTest | toolchain bundled | Adapter/provider/resolver/public-facade/renderer tests | Existing focused tests already exercise these layers and actual generated pixels. [VERIFIED: `BeautySDK/Package.swift:40-48`; `BeautyEngineChinTaperRepairTests.swift`] |
| Swift comparator + Bash runner | repository scripts | Pixel gates, report admission, two-attempt workflow | Phase 89 established these exact SDK-owned validation boundaries. [VERIFIED: `scripts/compare-face-feature-batches.swift`; `scripts/run-face-feature-batches.sh`; Phase 89 verification] |

### Supporting

| Technology | Version | Purpose | When to Use |
|---|---|---|---|
| Python 3 | host 3.9.6 | Existing runner boundary tests and path helper | Use only for existing script-boundary tests; do not move anatomy evaluation into Python. [VERIFIED: local `python3 --version`; `scripts/test-face-feature-batch-boundaries.py`] |
| `jq` | host 1.7.1 | Read-only manifest/inventory inspection | Useful for validation commands; not part of production. [VERIFIED: local `jq --version`; manifest inspection] |
| Fixed-point Q16 integers | existing comparator convention | Portable bounded reduction statistic | Use for renderer-to-comparator aggregate values so JSON numbers are integral and deterministic. [VERIFIED: `compare-face-feature-batches.swift` semantic Q16 fields and checked arithmetic] |

### Alternatives Considered

| Instead of | Rejected Alternative | Reason |
|---|---|---|
| Independent observed pupil support | Darkness centroid, lash/shadow/foreign-patch detection | Explicitly revoked and mutation-proved non-anatomical. [VERIFIED: `compare-face-feature-batches.swift:759-764,1803-1842`; Phase 89 verification; D-01] |
| Per-eye gaze field | Globally relaxing `semanticSupports` for all eye controls | Would change unrelated bilateral/compatibility behavior and exceed field-local scope. [VERIFIED: `EyeWarpProvider.swift:76-98,117-127`; D-03] |
| Existing CPU warp | New shader/backend/model | Forbidden by locked scope and unnecessary for the one-point local correction. [VERIFIED: D-05; `AGENTS.md` §5] |
| Per-output aggregate report member | Raw geometry sidecar or public API | Raw/per-side anatomy cannot cross the durable boundary; the renderer report already binds request identities. [VERIFIED: D-09; `RendererCLIContract.swift:66-102`] |

**Installation:** none. Phase 91 needs no external package, service, model, or data dependency. [VERIFIED: repository and locked scope]

## Package Legitimacy Audit

Not applicable: no external package installation is recommended, so the package-legitimacy gate has no subjects. [VERIFIED: Standard Stack and D-01/D-05]

## Architecture Patterns

### System Architecture Diagram

```text
CIImage + metadata + positive gazeCorrection
                  |
                  v
      VisionFaceDetector (one request)
                  |
       one mapped observation only
                  v
 BeautyFaceGeometryAdapter
   | independently validate each contour/pupil
   | keep paired pupil result for legacy pupilSize
   ` keep independent gaze pupil per valid side
                  |
                  v
 EyeWarpProvider.gaze-only selector
   | missing/malformed/centered side -> no emission
   | valid side -> own pupil -> own eye center
   ` aperture-bounded source/target radius
                  |
                  v
 final sanitizer + conflict resolver
   | rejected final point -> aggregate abstention/rejection
   ` admitted point -> CPU geometry render
                  |
          +-------+-------+
          |               |
          v               v
 actual output pixels   final aggregate metrics
          |               |
          |       BeautyResult.metrics allowlist
          |               v
          |       BeautyExampleRenderer report unit
          |       (inputID/caseID/outputID binding)
          |               |
          +-------+-------+
                  v
 temporary Phase 89 comparator admission
   | aggregate proves every eligible eye reduced
   | pixels prove frozen target/sibling/locality/protection
   ` no aggregate or mismatch -> infrastructure failure
                  |
                  v
 Phase 91 focused proof; Phase 95 owns final clean publication
```

This flow keeps anatomy request-local until it becomes fixed aggregate counts/statistics, and keeps rendered pixels—not control points—as the observable effect proof. [VERIFIED: D-07 through D-09; repository flow inspection]

### Recommended Project Structure

```text
BeautySDK/Sources/BeautyEffects/
├── Planning/
│   ├── BeautyFaceGeometryAdapter.swift            # preserve independent gaze pupil beside paired result
│   └── BeautyEffectResolver.swift                 # selected post-conflict aggregate attachment seam
└── Warp/
    ├── WarpControlPoint.swift                     # internal semantic-support representation
    └── EyeWarpProvider.swift                      # gaze-only support, bounded radius, aggregate helper
BeautySDK/Sources/BeautySDK/
├── BeautyEngineGeometryDetection.swift            # existing aggregate merge path
└── BeautyEngineTestingSupport.swift               # selected minimal deterministic gaze fixture seam
BeautySDK/Sources/BeautyExampleRenderer/
├── RendererCLIContract.swift                      # optional allowlisted per-unit aggregate
└── RendererExecution.swift                        # copy only fixed aggregate from exact BeautyResult
BeautySDK/Tests/
├── BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift
├── BeautyEffectsTests/EyeWarpProviderTests.swift
├── BeautyEffectsTests/BeautyEffectResolverTests.swift
├── BeautyEffectsTests/GeometryConflictResolverTests.swift # unchanged regression coverage
├── BeautyCoreTests/BeautyEngineGazeCorrectionRepairTests.swift
└── BeautyCoreTests/BeautyExampleRendererProcessTests.swift
scripts/
├── compare-face-feature-batches.swift              # anatomy aggregate admission + frozen pixel gates
├── run-face-feature-batches.sh                     # temporary report lifecycle
└── test-face-feature-batch-boundaries.py           # binding/tamper/cleanup mutations
```

This is a seam map for the planner, not authorization to touch every file: prefer the smallest subset that can express tests and final aggregate binding. [VERIFIED: actual target layout; Agent's Discretion]

### Pattern 1: Split field-specific validation without weakening compatibility

**What:** retain the individually validated pupil before pair-level compatibility clearing, store it as gaze-only request-local support, and retain today's paired pupil as the value consumed by `pupilSize`. [VERIFIED: `BeautyFaceGeometryAdapter.swift:102-114,277-328`; `WarpControlPoint.swift:24,31-34`]

**When to use:** only when `gazeCorrection > 0`; all unrelated eye fields continue through their present support rules. [VERIFIED: D-03; `EyeWarpProvider.swift:76-98`]

**Example:**

```swift
// Source pattern: BeautyFaceGeometryAdapter.swift:102-114,277-328
// Private names are discretionary; this illustrates ownership, not final syntax.
let independent = validatePupil(observed.pupil, support: provisional)
let paired = validatePairedPupils(left: leftObserved, right: rightObserved)

let leftSupport = leftObserved.map {
    $0.semanticSupport(
        pairedPupil: paired.left,          // current pupilSize contract
        independentGazePupil: $0.pupil    // per-eye gaze contract
    )
}
```

The key invariant is that a peer ratio failure may clear `pairedPupil` but must not clear a locally valid `independentGazePupil`. [VERIFIED: D-02/D-03; current peer clearing at adapter lines 286-293]

### Pattern 2: Gaze-only support selection

**What:** add a selector that returns zero, one, or two observed eye supports by independent gaze eligibility. Do not change the current all-eye selector used by the other fields. [VERIFIED: current common selector at `EyeWarpProvider.swift:76-127`; EYE-01]

**Example:**

```swift
// Source pattern: EyeWarpProvider.swift:76-127
private func gazeSupports(in face: FaceGeometry) -> [BeautyEyeSemanticSupport] {
    [face.leftEyeSupport, face.rightEyeSupport]
        .compactMap { $0 }
        .filter(\.gazeCorrectionEligible)
}
```

Observed-but-invalid support must never fall back to `legacySupport`, and a nil legacy payload cannot become gaze-eligible because it has no pupil. [VERIFIED: `EyeWarpProvider.swift:121-141`; D-01]

### Pattern 3: Aperture-bounded inverse-warp support

**What:** require a finite, non-self-intersecting closed eye contour; require source pupil and target strictly inside; calculate the minimum point-to-segment clearance for both; select a positive radius no greater than the smaller clearance and the existing face-relative cap. [VERIFIED: D-05; current fixed radius at `EyeWarpProvider.swift:193-196`; first-principles containment of a circular influence]

**When to use:** after the existing `0.002` dead zone and `35%` target calculation, before creating the gaze point. A missing/degenerate clearance fails that eye closed. [VERIFIED: `EyeWarpProvider.swift:180-190`; D-04/D-06]

**Prescriptive formula:**

```swift
// Derived from the existing source/target and circular-radius representation.
let apertureClearance = min(
    minimumDistance(from: pupil, toSegmentsOf: contour),
    minimumDistance(from: target, toSegmentsOf: contour)
)
let radius = min(face.bounds.width * 0.05, apertureClearance * 0.5)
guard radius.isFinite, radius > 0 else { return [] }
```

The `0.5` factor is a conservative planning choice that leaves a margin for raster/interpolation behavior; it must be frozen before observing Phase 91 output and may only become stricter if the pre-output containment tests reject it. [ASSUMED]

### Pattern 4: Final-state aggregate, not pre-conflict intent

**What:** derive the evidence from the exact eligible samples and the final admitted gaze field after sanitization/conflict resolution. An aggregate must not claim correction when the final rendered plan contains no corresponding gaze work. [VERIFIED: D-07/D-08; provider emissions are pre-sanitized and conflict-resolved in `GeometryConflictResolver.swift`]

Recommended fixed allowlist:

| Key | Meaning | Constraint |
|---|---|---|
| `beauty.effects.gazeEligibleCount` | independently valid, non-neutral gaze sides for this request | integer `0...2` [VERIFIED: EYE-01 supports at most two observed eye sides] |
| `beauty.effects.gazeCorrectedCount` | eligible sides whose final target has strictly smaller own-center displacement | integer `0...eligible` [VERIFIED: D-07/D-09] |
| `beauty.effects.gazeRejectedCount` | expected sides not admitted because support or final emission failed | integer `0...2`; never side-labelled [VERIFIED: D-09] |
| `beauty.effects.gazeAllReduced` | every eligible side corrected and at least one eligible | exactly `0` or `1` [VERIFIED: D-07/D-09] |
| `beauty.effects.gazeAbstained` | no creditable correction for the request | exactly `0` or `1`, consistent with counts [VERIFIED: D-09] |
| `beauty.effects.gazeMinimumReductionQ16` | minimum per-eligible-side normalized offset reduction | bounded nonnegative integer; no per-side value [VERIFIED: D-09; comparator Q16 convention] |

Do not put `pupil`, `contour`, `left`, `right`, coordinate, radius, vector, mask, or pixel values in metric keys or report members. [VERIFIED: D-09; existing redaction tests at `BeautyEngineChinTaperRepairTests.swift:212-227`]

### Pattern 5: Exact renderer-unit binding and temporary admission

**What:** add one optional nested aggregate to `RendererOutputUnit`, populated only from a successful public `processResult` and copied only from a compile-time allowlist. The comparator admits it only when report schema/backend/counts and exact `inputID + caseID + outputID` match the candidate image. [VERIFIED: `RendererCLIContract.swift:66-102`; `RendererExecution.swift:333-369`; D-08/D-09]

The runner currently deletes `beauty-example-renderer-report.json` immediately after each case; Phase 91 must retain admitted reports inside the already temporary attempt workspace until comparison, then verify their removal before publication/retention. [VERIFIED: `run-face-feature-batches.sh:646-708`; Phase 89 cleanup contract]

### Pattern 6: Hybrid gaze semantic measurement

For `.pupilToOwnEyeCenter`, use the candidate renderer aggregate only for direction admission and signed Q16 reduction. Continue using canonical image bytes for the frozen source/neutral target signal, sibling distinctness, outside locality, and protected-region ceilings. [VERIFIED: D-08; `compare-face-feature-batches.swift:806-893`; manifest gaze contract]

The current generic sibling branch computes a semantic image metric for every sibling, which is impossible for gaze without reviving darkness inference. The gaze branch should instead require actual candidate-versus-each-sibling target-region change at the frozen signal floors, verify the sibling carries no successful gaze aggregate, and use the candidate's admitted minimum reduction Q16 as the bounded semantic separation value only after that actual-pixel check passes. [VERIFIED: D-01/D-08; `compare-face-feature-batches.swift:832-837`; manifest sibling set]

### Anti-Patterns to Avoid

- **Clearing both gaze pupils on a peer ratio failure:** preserves the exact current defect. Keep pair-level clearing only for fields that actually require it. [VERIFIED: `BeautyFaceGeometryAdapter.swift:277-294`; D-02/D-03]
- **Changing the common `semanticSupports` behavior for every field:** can silently alter eye height, length, lids, corners, tilt, or symmetry. Use a gaze-only selector. [VERIFIED: `EyeWarpProvider.swift:76-98,117-127`]
- **Using the current summed reduction as proof:** one eye can improve enough to hide a worsening peer. Require `correctedCount == eligibleCount` plus the minimum per-eye reduction. [VERIFIED: current sum at `EyeWarpProvider.swift:101-114`; D-07]
- **Keeping the face-width radius without an aperture proof:** its influence can extend beyond a small eye. Bound it by contour clearance. [VERIFIED: current radius at `EyeWarpProvider.swift:193-196`; D-05]
- **Computing anatomy from rendered darkness:** lashes, shadow, foreign patches, and other eye controls can spoof it. Retain those Phase 89 adversaries as rejection tests. [VERIFIED: `compare-face-feature-batches.swift:1803-1842`; D-01]
- **Publishing raw renderer metrics blindly:** copy a fixed allowlist, validate integral bounds, and reject unknown/missing/inconsistent members. [VERIFIED: D-09; Phase 89 report admission pattern]
- **Deleting renderer reports before comparator admission:** breaks same-request/output binding. Retain only in the protected temporary attempt workspace, then remove before durable publication. [VERIFIED: current deletion at `run-face-feature-batches.sh:672`; D-08/D-09]
- **Weakening Phase 89 thresholds after output:** forbidden. Repair must pass the current target/locality/sibling/protection contract or fail honestly. [VERIFIED: D-04/D-08; manifest contract]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| Eye/pupil detection | Darkness classifier, symmetry estimator, peer inference | Existing Vision observation and adapter | Production anatomy ownership is locked and already request-local. [VERIFIED: D-01; adapter/detector] |
| New warp backend | New Metal shader, GPU kernel, transform stack | Existing `WarpControlPoint` + CPU geometry pipeline | Backend/shader contract is frozen and the existing one-point path is sufficient. [VERIFIED: D-05; `EyeWarpProvider.swift`] |
| New public diagnostics API | Public geometry struct or callback | Existing aggregate `BeautyResult.metrics` + renderer report | The public facade already carries aggregate diagnostics; raw anatomy is forbidden. [VERIFIED: `PRODUCT_SENSE.md:149-175`; D-09] |
| New batch validator | Separate image harness | Existing Phase 89 comparator/runner | They already own inventory, canonical decode, frozen gates, two-attempt reconciliation, cleanup, and stable payload. [VERIFIED: Phase 89 verification] |
| Real-image fixture storage | Checked-in portraits or recovered legacy assets | Generated in-memory fixture for mechanics; Phase 95 owner-local authorized media for final rerun | Generated data proves mechanics without licensing/privacy leakage; Phase 91 does not own the portrait batch. [VERIFIED: spike skill; D-08] |
| Custom hashing/crypto | New digest algorithm | Existing comparator SHA-256 stable-payload machinery | No new cryptographic requirement exists. [VERIFIED: `compare-face-feature-batches.swift:1554-1575`; Phase 89 verification] |

**Key insight:** the hard problem is ownership and binding, not the centerward vector. The existing vector math is already bounded; trustworthy completion depends on preserving independent per-eye anatomy, proving pixels moved, and ensuring an aggregate cannot be detached from the exact rendered request. [VERIFIED: `EyeWarpProvider.swift:180-190`; D-07/D-08]

## Common Pitfalls

### Pitfall 1: Fixing only `semanticSupports`

**What goes wrong:** a one-sided support array becomes possible, but the adapter may already have cleared the locally valid pupil because its peer's contour ratio failed. [VERIFIED: adapter lines 277-294; provider lines 117-127]

**How to avoid:** mutation-test missing peer, malformed peer, and ratio-implausible peer at the adapter boundary; assert the valid side remains gaze-eligible while paired `pupilSize` eligibility remains unchanged. [VERIFIED: D-02/D-03]

### Pitfall 2: Evidence computed before final resolution

**What goes wrong:** a sample proves a mathematical reduction even if sanitization/conflict resolution removes the control point, so the aggregate claims pixels should move when the renderer receives no gaze field. [VERIFIED: provider evidence at `EyeWarpProvider.swift:101-114`; conflict-resolution architecture]

**How to avoid:** attach evidence only after final field resolution or explicitly reconcile eligible samples with final admitted gaze emissions before metrics are returned. [VERIFIED: D-07/D-08]

### Pitfall 3: Radius is locally centered but not anatomy-bounded

**What goes wrong:** a pupil-local center can still have an influence disk crossing the eye contour, changing aperture, surrounding skin, or brow pixels. [VERIFIED: current fixed radius at provider lines 193-196; D-05]

**How to avoid:** prove contour simplicity, inside membership, source/target clearance, positive finite radius, and hard protected-region pixel ceilings. [VERIFIED: D-05/D-07]

### Pitfall 4: Aggregate sum hides an eye regression

**What goes wrong:** total corrected displacement can be smaller even if one eligible eye moved away from its center. [VERIFIED: current aggregate sums at provider lines 101-114]

**How to avoid:** compute per-eye comparison in memory, persist only `correctedCount`, `eligibleCount`, `allReduced`, and the minimum nonnegative reduction Q16. [VERIFIED: D-07/D-09]

### Pitfall 5: Renderer report is not tied to image identity

**What goes wrong:** a valid gaze aggregate from one fixture/case can be replayed beside another candidate PNG. [VERIFIED: renderer report and run-root are separate current artifacts; D-08]

**How to avoid:** require exact report schema/backend/count reconciliation; one unique successful unit matching input/case/output ID; regular non-symlink report under the attempt root; integral bounded fields; and no extra aggregate keys. Mutate each binding independently. [VERIFIED: Phase 89 admission/path patterns]

### Pitfall 6: Gaze branch silently revives a pixel proxy for siblings

**What goes wrong:** replacing only source/candidate direction with aggregate while leaving sibling measurement on `semanticMetricValue` either remains unsupported or tempts a darkness fallback. [VERIFIED: comparator lines 823-837]

**How to avoid:** make the entire gaze semantic branch explicit: aggregate direction plus actual candidate-versus-sibling target signal, then the unchanged outside/protection gates. [VERIFIED: D-01/D-08]

### Pitfall 7: Testing geometry but not rendered pupil identity

**What goes wrong:** control points can move while the output target pixels are unchanged, aliased, or displaced in the wrong direction. [VERIFIED: D-07; project automation policy]

**How to avoid:** identify pupil pixels from a fixture-declared chromatic/texture marker independent of production support, render through the public facade, and compare input/output marker centroids to fixture-declared own-eye centers. [VERIFIED: D-07; generated actual-pixel owner pattern]

### Pitfall 8: Persistent evidence leaks anatomy through names or failure payloads

**What goes wrong:** even without values, raw side labels, coordinates, private paths, or framework errors can cross the boundary. [VERIFIED: D-09; `SECURITY.md`; existing redaction scan]

**How to avoid:** fixed neutral aggregate names, fixed reason codes, numeric bounds, privacy scans of metrics/reports/stable payload, and cleanup assertions for temporary reports. [VERIFIED: D-09; Phase 89 verification]

## Code Examples

### Independent per-eye aggregate construction

```swift
// Source pattern: EyeWarpProvider.swift:101-115,180-190
// The final implementation must reconcile these samples with final admitted emissions.
let samples = gazeSupports(in: face).compactMap {
    gazeSample(support: $0, strength: finalStrength)
}
let reductions = samples.map { $0.baselineOffset - $0.correctedOffset }
let correctedCount = reductions.filter { $0.isFinite && $0 > 0 }.count
let allReduced = !samples.isEmpty && correctedCount == samples.count
let minimumReductionQ16 = allReduced
    ? reductions.map(toBoundedQ16).min()!
    : 0
```

This performs per-eye comparison in memory but emits only aggregate values. [VERIFIED: D-07/D-09]

### Public-facade rendered-pixel oracle

```swift
// Source pattern: BeautyEngineChinTaperRepairTests.swift:17-64
let source = generatedEyeFixtureRGBA(width: 512, height: 512)
let result = try engine.processResult(
    image: image(source),
    metadata: .init(orientation: .up, source: .testFixture),
    parameters: .init(gazeCorrection: 0.25)
)
let output = rgbaBytes(result.output)

for eye in fixtureDeclaredEyes where eye.isEligible {
    let before = centroid(ofDeclaredMarker: eye.marker, in: source)
    let after = centroid(ofDeclaredMarker: eye.marker, in: output)
    XCTAssertLessThan(distance(after, eye.center), distance(before, eye.center))
}
assertFrozenTargetAndProtectionSignals(source: source, candidate: output)
```

The test declaration must not call production support to discover marker pixels or centers; otherwise the proof is circular. [VERIFIED: D-07]

### Renderer aggregate allowlist

```swift
// Source pattern: RendererExecution.swift:333-369
let allowed = [
    "beauty.effects.gazeEligibleCount",
    "beauty.effects.gazeCorrectedCount",
    "beauty.effects.gazeRejectedCount",
    "beauty.effects.gazeAllReduced",
    "beauty.effects.gazeAbstained",
    "beauty.effects.gazeMinimumReductionQ16",
]
let gazeAggregate = renderCase.id == "gazeCorrection_0p25"
    ? GazeAggregate(validating: result.metrics, allowlist: allowed)
    : nil
```

Validation must reject non-finite, fractional, negative, out-of-range, contradictory, or unknown fields rather than coercing them. [VERIFIED: D-08/D-09; Phase 89 fail-closed style]

### Comparator gaze branch

```swift
// Source pattern: compare-face-feature-batches.swift:806-893
guard candidateAggregate.eligibleCount > 0,
      candidateAggregate.correctedCount == candidateAggregate.eligibleCount,
      candidateAggregate.allReduced,
      candidateAggregate.minimumReductionQ16 >= contract.thresholds.minimumSignedMarginQ16
else { throw SemanticContractError.admission }

let sourceTarget = try regionSignal(source, candidate, include: target, watermarkRows: rows)
let neutralTarget = try regionSignal(neutral, candidate, include: target, watermarkRows: rows)
for sibling in siblings {
    try requireFrozenTargetSignal(between: sibling.image, and: candidate)
    try requireNoSuccessfulGazeAggregate(sibling.aggregate)
}
try enforceExistingOutsideAndProtectedGates(...)
```

Missing or contradictory anatomy aggregate is infrastructure/admission failure, not a semantic failure with partial eight-direction publication. [VERIFIED: Phase 89 status contract; D-08]

## State of the Art

| Old / Current Internal Approach | Phase 91 Approach | Impact |
|---|---|---|
| Pair-ratio validation can clear both pupil values. [VERIFIED: adapter lines 277-294] | Preserve paired pupil for paired consumers; retain separately validated gaze pupil per side. [VERIFIED: D-02/D-03] | A malformed peer no longer disables a valid gaze side without changing pupil-size compatibility. |
| One shared support selector requires both observed sides. [VERIFIED: provider lines 117-127] | Gaze-only compact-map selector; unrelated eye fields keep current selector. [VERIFIED: field-local recommendation] | Minimum blast radius. |
| Gaze radius is `5%` of face width. [VERIFIED: provider lines 193-196] | Cap radius by source and target clearance inside own eye aperture. [VERIFIED: D-05] | Protects contour/brow/face pixels by construction plus pixel gates. |
| Evidence sums both-eye offsets. [VERIFIED: provider lines 101-114] | Count every eligible/corrected side and persist minimum Q16 reduction with all-reduced state. [VERIFIED: D-07/D-09] | One improved side cannot hide peer failure. |
| Comparator throws `unsupportedMetric` for gaze. [VERIFIED: comparator lines 751-764] | Admit only exact renderer-bound aggregate for direction; preserve frozen pixel gates. [VERIFIED: D-08] | Gaze becomes creditable without darkness inference. |
| Runner deletes renderer reports before compare. [VERIFIED: runner line 672] | Retain them only until exact comparator admission, then cleanup. [VERIFIED: D-08/D-09] | Establishes same-request/output binding without durable anatomy. |

**Deprecated/outdated:** the pre-review dark-pixel gaze centroid is permanently non-creditable; do not restore it in production, tests, sibling logic, or fallback paths. [VERIFIED: Phase 89 verification; D-01]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | A radius multiplier of `0.5` on minimum source/target contour clearance is conservative enough for the existing CPU raster while still producing the frozen target signal. | Architecture Pattern 3 | If too small, the repair safely abstains or fails target-signal tests; if raster behavior still touches contour pixels, pre-output containment/protection tests must reject the plan before an attempt. The locked upper bound remains the contour clearance. |

All other implementation claims in this research were traced to the repository, locked context, or first-principles constraints. A1 is not a user-facing or compatibility decision and must be frozen by the independently checked plan before output is observed. [VERIFIED: Phase 91 timebox; D-04/D-05]

## Open Questions (RESOLVED)

1. **Which exact post-conflict function should attach the final aggregate?**
   - What we know: the provider can calculate samples, the resolver owns final field admission, and `BeautyEffectPlan.metrics` already reaches `BeautyResult`. [VERIFIED: `EyeWarpProvider.swift:101-115`; `BeautyEngineGeometryDetection.swift:65-95`; resolver inspection]
   - Resolution: attach the aggregate in the post-conflict `BeautyEffectResolver.resolve` seam after convergence, effective-strength sanitization, and `finalEyeEmissions` recomputation. The resolver calls the package-internal provider helper with the exact final gaze strength and admitted gaze points, then merges only the six fixed fields into `BeautyEffectPlan.metrics`; generic provider protocols, `GeometryConflictResolver`, and public types remain unchanged. [VERIFIED: `BeautyEffectResolver.swift:443-506,612-615,665-715`; D-07/D-08]

2. **Can existing testing SPI express independently valid/invalid left and right eye support?**
   - What we know: current public-facade tests use `SDKTestingFaceDetectionFixture`, while existing generic `.usableFace` does not expose the Phase 91 per-eye matrix. [VERIFIED: `BeautyEngineTestingSupport.swift`; `BeautyEngineChinTaperRepairTests.swift:93-135`]
   - Resolution: extend the existing package-internal `SDKTestingFaceDetectionFixture` / `BeautyEngineTestingSupport` seam with the minimum fixed gaze-only fixture cases needed by the generated public-facade oracle. The fixture coordinates remain target-internal, non-Codable, in-memory, and inaccessible from the product-public facade; no separate facade helper or production return type is added. [VERIFIED: `BeautyEngineTestingSupport.swift`; D-07/D-09]

Both Agent's Discretion choices are now frozen for the independently checked Phase 91 plan and must be used consistently by Plans 91-02 and 91-03. [VERIFIED: `91-CONTEXT.md` Agent's Discretion]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---:|---|---|
| Swift toolchain | package, XCTest, comparator | ✓ | Swift 6.3.3; package tools 6.0 | none needed [VERIFIED: local probe; `BeautySDK/Package.swift:1`] |
| Apple platform frameworks | Vision/Core Image package build | ✓ via current macOS toolchain | package floor macOS 14 / iOS 17 | generated CPU tests on host [VERIFIED: `BeautySDK/Package.swift:7-10`; current repository builds these targets] |
| Python 3 | existing boundary suite | ✓ | 3.9.6 | none needed [VERIFIED: local probe] |
| Node.js | optional GSD graph/tooling only | ✓ | 26.0.0 | not required for implementation [VERIFIED: local probe] |
| `jq` | manifest inspection | ✓ | 1.7.1 | Swift/Python decoding already exists [VERIFIED: local probe] |
| Authorized portrait set | Phase 95 final batch only | not required in Phase 91 | owner-local | generated in-memory mechanics fixtures [VERIFIED: D-08; spike skill] |

**Missing dependencies with no fallback:** none for Phase 91 implementation or focused validation. [VERIFIED: environment audit]

**Missing dependencies with fallback:** authorized real portraits are intentionally deferred; generated fixtures prove mechanics now and Phase 95 owns final owner-local portrait execution. [VERIFIED: D-08; Deferred Ideas]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest from Swift toolchain plus repository Swift/Bash/Python SDK-owned scripts [VERIFIED: `BeautySDK/Package.swift:40-48`; scripts] |
| Config file | `BeautySDK/Package.swift`; `scripts/face-feature-batch-manifest.json` for frozen batch semantics [VERIFIED: repository] |
| Quick run command | `swift test --package-path BeautySDK --filter 'BeautyFaceGeometryAdapterTests|EyeWarpProviderTests|BeautyEffectResolverTests|GeometryConflictResolverTests|BeautyEngineGazeCorrectionRepairTests|BeautyExampleRendererProcessTests'` [VERIFIED: existing target/test naming pattern; one proposed test file is a Wave 0 gap] |
| Comparator mutation command | `swift scripts/compare-face-feature-batches.swift --self-test` [VERIFIED: Phase 89 verification] |
| Script-boundary command | `python3 scripts/test-face-feature-batch-boundaries.py` [VERIFIED: Phase 89 verification] |
| Inventory/preflight command | `bash scripts/run-face-feature-batches.sh --preflight-only` [VERIFIED: Phase 89 verification] |
| Compatibility command | `swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineMetadataCompatibilityTests|BeautyBackendContractTests|BeautyBackendSelectionConcurrencyTests'` [VERIFIED: Phase 89/90 verification pattern] |
| Full suite command | `swift test --package-path BeautySDK` [VERIFIED: `AGENTS.md` basic commands] |

### Validation Layers

| Layer | Owner | Required proof | Failure meaning |
|---|---|---|---|
| Pure validation | `BeautyFaceGeometryAdapterTests` | Valid side survives missing/malformed/ratio-invalid peer for gaze; paired pupil behavior remains unchanged; nonfinite/outside/ellipse-invalid side fails alone. [VERIFIED: D-02/D-03/D-06] | Code defect before render. |
| Provider geometry | `EyeWarpProviderTests` | One/two-side emissions, own-center vector, dead zone `0.002`, cap `0.25`, max `35%`, no borrowing, radius inside both source/target clearances, deterministic order. [VERIFIED: D-04/D-05] | Code defect before public facade. |
| Final resolver/metrics | `BeautyEffectResolverTests` plus unchanged `GeometryConflictResolverTests` regression coverage | Aggregate attaches at the selected post-conflict `BeautyEffectResolver.resolve` seam, is based on final admitted work, and keeps `eligible`, `corrected`, `rejected`, `allReduced`, `abstained`, and min Q16 internally consistent; invalid-valid recovery has no stale state. [VERIFIED: resolved Open Questions; D-06 through D-09] | Admission/diagnostic defect. |
| Public actual pixels | proposed `BeautyEngineGazeCorrectionRepairTests` | Generated independent anatomy; each eligible marker centroid closer to own center; rejected side source-exact; target signal, sibling difference, aperture/contour/brows/background, alpha/extent/metadata, neutral identity, determinism. [VERIFIED: D-05/D-07; project image policy] | EYE-01 not complete even if geometry tests pass. |
| Renderer transport | `BeautyExampleRendererProcessTests` | Exact successful unit carries only allowlisted bounded aggregate for matching gaze case; neutral/sibling/failure units cannot claim correction; schema remains compatible. [VERIFIED: D-08/D-09] | Same-request binding incomplete. |
| Comparator mutation | comparator self-test | Missing, duplicate, reordered, fractional, nonfinite, negative, overflowed, contradictory, wrong-case/output/input, replayed, proxy-only, or sibling-gaze aggregate fails admission. Lash/shadow/foreign-patch/centered proxy images remain non-creditable. [VERIFIED: D-01/D-08/D-09; existing adversaries] | Infrastructure failure; never semantic pass/fail publication. |
| Runner boundary | Python boundary suite | Reports remain temporary, regular/non-symlink, under admitted roots; comparator consumes them before verified cleanup; stale reports cannot earn credit. [VERIFIED: Phase 89 path/cleanup contract] | Infrastructure failure with sanitized envelope. |
| Compatibility | existing suites | Exact 62 parameters, five presets, 75 renderer cases, public facade and CPU/GPU contract unchanged. [VERIFIED: Phase 89 verification; `AGENTS.md`] | Scope/compatibility regression. |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| EYE-01 | Independent valid side survives invalid peer without borrowing | unit | `swift test --package-path BeautySDK --filter BeautyFaceGeometryAdapterTests` | ✅ extend existing [VERIFIED: repository] |
| EYE-01 | Gaze vector obeys dead zone/cap/35% and aperture radius | unit | `swift test --package-path BeautySDK --filter EyeWarpProviderTests` | ✅ extend existing [VERIFIED: repository] |
| EYE-01 | Final aggregate proves every eligible side reduced | unit/integration | `swift test --package-path BeautySDK --filter 'BeautyEffectResolverTests|GeometryConflictResolverTests'` | ✅ extend existing [VERIFIED: repository; resolved Open Questions] |
| EYE-01 | Public pixels move each declared pupil toward own center and preserve protected regions | integration | `swift test --package-path BeautySDK --filter BeautyEngineGazeCorrectionRepairTests` | ❌ Wave 0 [VERIFIED: no current file] |
| EYE-01 | Renderer binds aggregate to exact output without anatomy leakage | integration | `swift test --package-path BeautySDK --filter BeautyExampleRendererProcessTests` | ✅ extend existing [VERIFIED: repository] |
| EYE-01 | Comparator admits aggregate and rejects proxies/tampering | mutation | `swift scripts/compare-face-feature-batches.swift --self-test` | ✅ extend existing [VERIFIED: repository] |
| EYE-01 | Temporary report lifecycle and stale/symlink/path faults fail closed | boundary | `python3 scripts/test-face-feature-batch-boundaries.py` | ✅ extend existing [VERIFIED: repository] |
| Compatibility | 62/5/75, facade, backend unchanged | regression | focused compatibility command above | ✅ [VERIFIED: Phase 89 verification] |

### Generated Fixture Contract

The Wave 0 public fixture should be a deterministic in-memory `512 x 512` explicit-sRGB RGBA8 image, following the existing public-facade oracle size/pattern. Each eye should have a separately declared closed aperture, a unique chromatic/textured pupil marker offset from its own declared center, a contour ring, an eyebrow region, and surrounding protected pixels; use distinct left/right marker identities so the test cannot accidentally swap or borrow sides. [VERIFIED: existing 512 RGBA pattern at `BeautyEngineChinTaperRepairTests.swift:17-25`; D-02/D-07]

The minimum fixture matrix is: bilateral valid; left-only valid; right-only valid; valid side plus missing peer; valid side plus malformed peer; valid side plus peer-ratio implausibility; centered side beside off-center valid side; no face; nonfinite/outside/ellipse-invalid pupil; reused/stale support; and valid-invalid-valid recovery. Run neutral, cap, exact dead-zone boundary, just-above-dead-zone, repeated cap, and frozen sibling controls. [VERIFIED: D-02/D-04/D-06; EYE-01]

The actual-pixel semantic oracle should threshold only the fixture's unique chromatic marker definition—not general darkness—then compute its input/output centroid and compare each to that eye's independently declared center. It must additionally enforce the exact manifest target/protection integers: target regions `300000...480000` and `520000...700000` by `550000...700000`; changed pixels `>=256`; RGB delta `>=768`; signed Q16 `>=16`; outside `<=128/512`; eye contours `<=64/256`; eyebrows `<=32/128`; background and watermark `0/0`. [VERIFIED: `scripts/face-feature-batch-manifest.json` gaze contract; D-04/D-07]

### Mutation Matrix

| Mutation | Expected result |
|---|---|
| Delete one observed side | Remaining valid gaze side renders; missing side source-safe. [VERIFIED: D-02] |
| Make peer contour ratio exceed `2.00` or below `0.50` | Valid local gaze side remains; paired pupil consumer remains suppressed as before. [VERIFIED: adapter current thresholds; D-03] |
| Swap side labels or reflect peer pupil | Admission failure; no borrowed correction. [VERIFIED: D-01/D-02] |
| Set offset to exactly `0.002` | Neutral/no point/no correction credit. [VERIFIED: D-04] |
| Set strength above `0.25` through public input | Existing cap produces at most `35%` centerward target. [VERIFIED: D-04] |
| Make contour self-intersect, target outside, or clearance zero | That side fails closed. [VERIFIED: D-05/D-06] |
| Drop a final point after pre-sample evidence | Aggregate must abstain/reject, never claim all-reduced. [VERIFIED: D-07/D-08] |
| Sum improvement positive while one side regresses | Aggregate rejected because corrected count/all-reduced/min reduction disagree. [VERIFIED: D-07] |
| Copy aggregate from different input/case/output | Comparator admission failure. [VERIFIED: D-08] |
| Fractional/NaN/negative/overflow count or Q16 | Renderer/comparator admission failure. [VERIFIED: D-09; checked-arithmetic pattern] |
| Lash/shadow or foreign dark patch changed | No anatomy credit; proxy remains rejected. [VERIFIED: existing comparator adversaries] |
| Candidate aliases a sibling | Frozen actual target sibling gate fails even if aggregate is present. [VERIFIED: D-08] |
| Temporary report is symlink/stale/outside root | Runner/comparator infrastructure failure and sanitized replacement. [VERIFIED: Phase 89 path contract] |
| Valid-invalid-valid sequence | Third output and aggregate exactly match first; no stale support. [VERIFIED: D-06] |

### Sampling Rate

- **Per task commit:** run the narrow owner test filter for the edited seam, then `git diff --check`. [VERIFIED: project workflow]
- **Per implementation wave:** run the quick combined Swift filter, comparator self-test, renderer process tests, and boundary suite. [VERIFIED: Validation Layers]
- **Phase gate:** run focused tests, full `swift test --package-path BeautySDK`, comparator self-test, boundary suite, runner `--preflight-only`, compatibility filter, archive verification, and post-archive SDK-only boundary. Do not run or claim the final authorized portrait batch; Phase 95 owns it. [VERIFIED: D-08; project commands]

### Wave 0 Gaps

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGazeCorrectionRepairTests.swift` — generated in-memory, independently declared actual-pixel anatomy and metadata oracle for EYE-01. [VERIFIED: missing today; D-07]
- [ ] Minimally extend the existing `SDKTestingFaceDetectionFixture` / `BeautyEngineTestingSupport` seam with deterministic testing-only per-eye fixtures; keep coordinates target-internal, non-Codable, and absent from the product facade. [VERIFIED: resolved Open Questions; D-09]
- [ ] Renderer aggregate decoding/binding test fixtures for success, neutral, sibling, malformed, and replay cases. [VERIFIED: current renderer report has no metrics]
- [ ] Comparator aggregate self-test builders and mutations; preserve all existing 554 probes and add new ones rather than replacing adversaries. [VERIFIED: Phase 89 verification; comparator self-test]
- [ ] Runner boundary cases for retained-until-compare reports and verified cleanup. [VERIFIED: current runner deletes reports before compare]

No test framework installation is required. [VERIFIED: `BeautySDK/Package.swift`]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | Owner-local CLI/library has no remote identity boundary in Phase 91. [VERIFIED: project boundary] |
| V3 Session Management | no | No session or network state is introduced. [VERIFIED: D-01/D-05] |
| V4 Access Control | yes, package/trust boundary | Keep anatomy target-internal/request-local; renderer receives only public aggregate metrics and copies a fixed allowlist. [VERIFIED: D-09; package target boundaries] |
| V5 Input Validation | yes | Existing contour/pupil finite/bounds/ellipse checks plus per-eye aperture/aggregate/report schema and integer-bound admission. [VERIFIED: adapter lines 296-328; recommended bridge] |
| V6 Cryptography | yes, existing digest only | Reuse current SHA-256 stable-payload digest; do not invent cryptography. [VERIFIED: comparator lines 1554-1575] |
| V7 Error/Logging | yes | Fixed payload-free reason codes and aggregate counts; no child output/framework/anatomy in logs. [VERIFIED: D-09; Phase 89 contract] |
| V8 Data Protection | yes | Raw eye support and pixels stay in memory/temporary workspace; durable evidence is bounded aggregate only. [VERIFIED: D-09; `SECURITY.md`] |
| V12 File and Resource | yes | Exact regular/non-symlink report admission, descriptor-safe roots, freshness/binding checks, verified cleanup. [VERIFIED: Phase 89 runner/path contract] |
| V14 Configuration | yes | Freeze manifest thresholds, 62/5/75 inventory, renderer backend/case IDs, and aggregate allowlist. [VERIFIED: D-04/D-08; Phase 89 verification] |

### Known Threat Patterns for This Stack

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| Peer anatomy borrowed or mirrored into valid side | Spoofing / Tampering | Side-owned observed support only; no fallback; independent-side mutations. [VERIFIED: D-01/D-02] |
| Pre-conflict aggregate claims removed work | Tampering | Derive/reconcile aggregate after final field resolution. [VERIFIED: D-07/D-08] |
| Valid aggregate replayed beside another PNG | Spoofing | Exact unique input/case/output binding and candidate report admission. [VERIFIED: D-08] |
| Raw anatomy leaks in report/metric/error | Information Disclosure | Compile-time allowlist, neutral keys, bounded counts/Q16, privacy scans, temporary cleanup. [VERIFIED: D-09] |
| Symlink/stale report escapes workspace | Tampering / Information Disclosure | Reuse Phase 89 no-follow/direct-child/freshness checks and reject aliases. [VERIFIED: Phase 89 verification] |
| Malformed counts or Q16 overflow comparator | Denial of Service / Tampering | Integral range checks and existing checked arithmetic; no coercion. [VERIFIED: comparator checked arithmetic; D-09] |
| Proxy image earns anatomy credit | Elevation of Privilege | Require same-request renderer aggregate; retain darkness adversaries as non-creditable. [VERIFIED: D-01; comparator self-test] |
| Stale detector state affects next request | Tampering | Request-local immutable support and valid-invalid-valid recovery tests. [VERIFIED: D-06; architecture contract] |
| Radius crosses eye aperture | Tampering of protected output | Source/target contour clearance plus frozen actual-pixel protection gates. [VERIFIED: D-05/D-08] |

## Sources

### Primary (HIGH confidence)

- `AGENTS.md`, `PLANS.md`, `.planning/ROADMAP.md` Phase 91, `.planning/REQUIREMENTS.md` EYE-01, `.planning/PROJECT.md` v1.22, `.planning/STATE.md`, and `91-CONTEXT.md` — locked scope, timebox, compatibility, ownership, and nonclaims. [VERIFIED: repository documents]
- `.planning/phases/89-semantic-validation-baseline/89-VERIFICATION.md` — current unsupported gaze handoff, 554-mutation baseline, frozen runner/comparator behavior, and Phase 95 ownership. [VERIFIED: repository verification]
- `DESIGN.md`, `ARCHITECTURE.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md`, and `docs/SDK_EFFECT_TAXONOMY.md` — eye validation, layer ownership, public acceptance, privacy, fail-closed execution, and current control status. [VERIFIED: repository owner documents]
- `BeautyFaceGeometryAdapter.swift`, `WarpControlPoint.swift`, `EyeWarpProvider.swift`, `GeometryConflictResolver.swift`, `BeautyEngineGeometryDetection.swift`, `RendererCLIContract.swift`, and `RendererExecution.swift` — live production seams. [VERIFIED: source inspection]
- `BeautyFaceGeometryAdapterTests.swift`, `EyeWarpProviderTests.swift`, `GeometryConflictResolverTests.swift`, `BeautyEngineChinTaperRepairTests.swift`, `BeautyExampleRendererProcessTests.swift`, and CPU oracle tests — current mutation and actual-pixel patterns. [VERIFIED: test inspection]
- `scripts/face-feature-batch-manifest.json`, `scripts/compare-face-feature-batches.swift`, `scripts/run-face-feature-batches.sh`, and `scripts/test-face-feature-batch-boundaries.py` — frozen gaze thresholds, unsupported proxy, report lifecycle, and path/cleanup gates. [VERIFIED: script inspection]
- `.codex/skills/spike-findings-beauty/SKILL.md` plus `references/still-image-integration.md` and `references/licensed-fixture-evaluation.md` — request-local support, original-pixel evidence, generated-fixture limits, and privacy persistence rules. [VERIFIED: project skill]

### Secondary (MEDIUM confidence)

None. No web or community source was needed because the required behavior is repository-specific and the locked implementation uses existing platform APIs. [VERIFIED: research scope]

### Tertiary (LOW confidence)

- A fixed `0.5` contour-clearance radius multiplier is a conservative implementation hypothesis pending the pre-output generated raster tests. [ASSUMED]

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — no new dependency; versions and target boundaries were read from the package and local toolchain. [VERIFIED: `BeautySDK/Package.swift`; environment probes]
- Architecture: HIGH — both per-eye coupling defects, final plan path, renderer report, and comparator branch were inspected directly. [VERIFIED: source inspection]
- Validation: HIGH — the frozen manifest integers, actual-pixel owner test, 554-mutation comparator, and runner cleanup behavior are concrete repository artifacts. [VERIFIED: Phase 89 verification; test/script inspection]
- Aperture radius coefficient: MEDIUM — contour-clearance ownership is mandatory, while the exact conservative factor must be proved before implementation output. [ASSUMED]

**Research date:** 2026-09-04
**Valid until:** the first change to the Phase 41/44 eye-support contract, the Phase 89 gaze manifest thresholds, renderer report schema, or Phase 91 locked context
