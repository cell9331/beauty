# Phase 43: Public-Facade Eye Geometry Output Evidence — Research

**Researched:** 2026-07-16  
**Domain:** Swift public-facade renderer, decoded PNG evidence, eye-local ROI comparisons, ignored gallery containment  
**Confidence:** HIGH for repository seams and validation patterns; MEDIUM for visual ROI/floor constants until calibration

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

Phase 43 owns deterministic saved-output evidence for the ten Phase 42 eye geometry controls through the public `BeautySDK` facade. It must add exactly eleven renderer cases: one positive case for each positive-only field, and positive/negative cases for signed `eyeTilt`. The live seven-fixture inventory and existing cases remain unchanged, so the current frozen expectation is 55 cases × 7 fixtures = 385 PNGs. The renderer remains public-facade-only and must not import internal targets or expose raw geometry.

Every expected PNG must be regular, non-empty, fully decoded, and exactly the input dimensions. Evidence must use one fixed eye-local ROI above the watermark, direct positive/negative tilt comparisons, and separate semantic-family comparisons. Thresholds are calibrated once, frozen, and applied to a fresh clean accepting render; strict mode may not derive its own thresholds.

Eligibility must be explicit: contour-dependent fields require complete observed eye support; pupil size and gaze correction require valid pupil support; symmetry requires a plausible measured pair. The helper must prove visibility only on eligible portrait fixtures, record neutral/ineligible safe no-ops separately, and prove automatic gaze correction reduces measured deviation on at least one eligible fixture. No-face output must preserve extent and be a baseline no-op in a watermark-safe region.

Generated output and gallery files are disposable local artifacts under the existing ignored paths. Gallery publication must be a duplicate-free exact bijection with renderer cases, and tracked/staged generated files must remain zero. Phase 43 closes only EYE-16 through EYE-18; final caps, exhaustive safety/degradation, boundary gates, promotion, and owner-ledger synchronization remain Phase 44.

### the agent's Discretion

Choose private helper names, the deterministic normalized eye ROI, decoder organization, comparator grouping, and fixed changed-pixel/RGB-delta floors by following the archived strict mouth/nose/eye helper patterns. Any visual constants are provisional evidence inputs and must be documented with measured minima and margins before strict acceptance.

### Deferred Ideas (OUT OF SCOPE)

Final natural caps, exhaustive missing/malformed/reused/stale/provider-empty transitions, combined 28-field convergence, active-source security boundary, exact ten-row promotion, root contract synchronization, Demo UI, device/commercial quality, packaging, shipping, and launch-readiness evidence are Phase 44 or future scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| EYE-16 | Renderer has ten positive-only cases plus positive/negative `eyeTilt`, exactly 55 cases and 385 outputs for seven fixtures. | Current `main.swift` has 44 ordered cases and one shared public `processResult` call; eleven new IDs are enumerated below. |
| EYE-17 | Strict bounded helper decodes same-dimension outputs and proves eye-local visibility, signed tilt, and semantic distinction. | Archived Phase 36/39 helpers provide bounded inventory, PNG/JPEG dimension parsing, CRC/zlib decode, fixed ROI, frozen-floor, and comparator-family patterns; Phase 42 provider tests define nearest-neighbor distinctions. |
| EYE-18 | Eligibility/no-op evidence, no-face extent preservation, and ignored duplicate-free gallery containment. | `BeautyRendererOutputRegressionTests`, `generate_gallery.py`, seven committed fixtures, and existing ignored output/gallery policy provide the required seams. |
</phase_requirements>

## Summary

Phase 43 is an evidence-only extension of the existing `BeautyExampleRenderer` and `BeautyRendererOutputRegressionTests`; production eye geometry is complete for this phase in Phase 42 and must not be changed. The renderer currently contains 44 ordered cases, seven recursively discovered fixtures, a single `BeautyEngine.processResult` call, and a `BeautySDK`-only import boundary. Adding eleven isolated cases yields the frozen 55 × 7 = 385 matrix: `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `innerCornerOpen`, `outerCornerOpen`, `eyeSymmetry` at provisional `0.25`, plus `eyeTilt` at `+0.25` and `-0.25`. [VERIFIED: codebase grep]

The strict helper should be self-contained in this phase directory and should copy the newest archived decoder/inventory pattern rather than import an archived phase helper. It must discover the live renderer IDs and fixture paths, reject duplicate IDs/stems and stale/unexpected PNGs, fully decode each expected PNG under bounded budgets, enforce exact dimensions, compare eligible portrait outputs inside one fixed eye ROI above the watermark, and report visibility, signed tilt, lid/corner, pupil, gaze, and symmetry families independently. Thresholds and ROI are provisional until a measurement render, then frozen for a clean accepting rerun. [VERIFIED: archived Phase 39 helper and current repository files; ASSUMED: exact eye ROI/floors before calibration]

### Primary recommendation

Add the eleven public-facade cases and no-face loop first; then build a phase-owned strict helper by adapting the archived Phase 39 decoder and Phase 29 eye comparator shape; calibrate one eye ROI/floor set once; rerender cleanly; publish the exact gallery only after strict evidence passes. Keep all raw geometry, pixel payloads, and eligibility details out of committed evidence and diagnostics. [VERIFIED: repository patterns]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Public renderer case matrix | Example renderer / public facade | BeautySDK engine | Renderer owns IDs and public `BeautyParameters`; engine remains the only processing entry point. [VERIFIED: `BeautyExampleRenderer/main.swift`] |
| PNG decode, ROI comparisons, calibration/strict gates | Phase evidence tooling | XCTest | Python stdlib helper owns untrusted file bounds and aggregate comparisons; XCTest owns source/no-face contract. [VERIFIED: archived helpers/tests] |
| Eye eligibility semantics | BeautySDK effects/detection (already Phase 42) | Phase helper | Helper classifies fixture/result behavior from output; it must not reimplement Vision or provider geometry. [VERIFIED: Phase 42 summaries] |
| Gallery publication and artifact containment | Repository tooling | Git ignore policy | `generate_gallery.py` owns descriptor-anchored publication and exact case bijection. [VERIFIED: current script/README] |

## Standard Stack

| Component | Version | Purpose | Why Standard |
|---|---|---|---|
| Swift Package Manager / XCTest | Swift tools 6.0; local Swift 6.3.3 | Renderer build and regression tests | Existing `BeautySDK/Package.swift` target and all prior phase gates use it. [VERIFIED: `Package.swift`, `swift --version`] |
| Core Image / ImageIO / AppKit | Platform SDK | Renderer image loading, raster output, PNG encoding | Already used by `BeautyExampleRenderer`; no new target or dependency is required. [VERIFIED: `main.swift`] |
| Python standard library | Python 3.9.6 | Strict bounded PNG/JPEG decoder, ROI metrics, helper self-tests | Archived Phase 39 helper is stdlib-only and avoids installing packages. [VERIFIED: `python3 --version`, archived helper] |
| Existing `example-images/generate_gallery.py` | Repository script | Duplicate-free ignored gallery publication | Existing script validates renderer bijection, staging/quarantine, no-follow paths, and bounded copies. [VERIFIED: current script/README] |

No external package installation is needed. [VERIFIED: current package and phase boundaries]

## Architecture Patterns

### Matrix and evidence flow

```text
BeautyParameters cases (public facade)
        -> BeautyEngine.processResult (one shared route)
        -> PNG output matrix (55 cases × discovered 7 fixtures)
        -> bounded decoder + exact dimensions
        -> eligibility partition (6 portraits / neutral or ineligible / no-face)
        -> fixed eye ROI families (visibility, tilt, lid/corner, pupil/gaze, symmetry)
        -> aggregate evidence + ignored gallery bijection
```

This is a data-flow boundary, not a second rendering path. The helper must consume saved output, never call internal providers or inspect raw landmarks. [VERIFIED: current renderer and Phase 42 boundary]

### Pattern 1: Exact live inventory before frozen count

Parse `id: "..."` from the renderer source, reject duplicates, recursively discover regular PNG/JPEG fixtures, reject duplicate stems, compute `case_count × fixture_count`, then enforce 55 × 7 = 385. Construct every expected `<fixtureStem>__<caseID>.png`, reject missing and unexpected files, and reject symlinks/non-regular files. [VERIFIED: archived Phase 39 helper]

### Pattern 2: Strict bounded decoding

Reuse the archived helper's bounded regular-file reads, PNG signature/IHDR/IDAT/IEND/CRC checks, 8-bit RGB/RGBA non-interlaced support, all five scanline filters, zlib expansion limits, JPEG SOF dimension parsing, and output/input dimension equality. Do not use whole-image or watermark differences as acceptance. [VERIFIED: archived Phase 39 helper]

### Pattern 3: Frozen calibration then clean strict rerun

Use `--measure` (or equivalent) to record per-family changed-pixel and absolute-RGB minima from one clean calibration matrix. Choose fixed floors below the weakest passing observations with explicit margins, commit the constants and ROI, delete/regenerate only the allow-listed ignored output root, and run strict mode against a fresh matrix. Strict mode must never derive or lower its own thresholds. [VERIFIED: archived Phase 39 context/research; ASSUMED: eye-specific numeric floors]

### Pattern 4: Eligibility-aware family comparisons

Maintain separate fixture inventories: contour-eligible portraits for height/length/lid/tilt/corner/symmetry, pupil-eligible portraits for pupil size and gaze, and neutral/ineligible fixtures for safe no-op assertions. A no-op is evidence only when the helper has recorded why the fixture is ineligible; it must not count as visibility. Compare positive/negative tilt directly, and compare nearest semantic neighbors (`eyeHeight` vs `eyeSize`, `eyeLength` vs `eyeDistance`, lids vs `eyeYPosition`/tail lift, corners vs tail lift, pupil/gaze vs baseline, symmetry vs eye-size/distance) in the same ROI. [VERIFIED: Phase 42 `EyeWarpProviderTests` and requirements; ASSUMED: exact fixture eligibility inventory until rendered]

### Pattern 5: Gallery exact bijection

Append the eleven eye IDs to `CASE_GROUPS["eyes"]`, run one safe publication after strict output validation, and verify exactly 55 × 7 = 385 regular gallery PNGs, duplicate-free case IDs, `git check-ignore` success, and zero tracked/staged generated files. Respect `.gallery-staging`/`.gallery-quarantine/previous` blocking behavior instead of weakening the generator. [VERIFIED: current `generate_gallery.py` and README]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---|---|---|---|
| Public processing route | Direct provider/adapter calls from helper or renderer | Existing `BeautyEngine.processResult` facade | Preserves public-route evidence and privacy boundary. [VERIFIED: renderer and Phase 42] |
| Image decoding | Unbounded `read_bytes`/generic image parser | Copy bounded stdlib decoder from archived Phase 39 | Prevents oversized/truncated/race-sensitive output from passing evidence. [VERIFIED: archived helper] |
| Gallery publication | Ad-hoc copy or recursive old-gallery traversal | Existing descriptor-anchored `generate_gallery.py` | Existing exact bijection and staging/quarantine safeguards. [VERIFIED: current script] |
| Eligibility semantics | Recompute Vision landmarks or infer pupil coordinates in Python | Record eligibility through existing engine/provider tests and output families | Keeps raw geometry private and avoids a second geometry implementation. [VERIFIED: Phase 42 boundary]

## Common Pitfalls

1. **Watermark false positives.** The renderer adds a bottom watermark; ROI must be top-origin and assert its bottom stays above excluded rows. Whole-image or watermark-only deltas are invalid. [VERIFIED: renderer and archived helpers]
2. **Symmetric fixtures hiding semantic aliases.** A centered portrait may make inner/outer or signed tilt look identical; direct neighbor comparisons and at least one measured asymmetric/pupil-eligible portrait are required. [VERIFIED: Phase 42 test guidance]
3. **Counting ineligible no-ops as visibility.** Pupil/gaze and symmetry can legitimately emit nothing; maintain eligibility counts and report no-ops separately. [VERIFIED: Phase 42 provider tests]
4. **Stale output inflation.** Old files can make 385 appear complete; clean the ignored output root and reject unexpected PNGs before accepting exact counts. [VERIFIED: archived Phase 39 helper]
5. **Gallery quarantine blocking reruns.** The generator intentionally blocks while staging/quarantine exists; operator cleanup must be explicit and allow-listed. [VERIFIED: `example-images/README.md`]
6. **Premature promotion.** Provisional `0.25` renderer strengths prove visibility only; final caps, safety, promotion, and branch status are Phase 44. [VERIFIED: Phase 43 boundary]

## Code Examples

### Renderer case shape

```swift
RenderCase(
    id: "eyeTilt_plus0p25",
    displayName: "eyeTilt +0.25",
    parameters: BeautyParameters(eyeTilt: 0.25)
)
```

The negative case uses `eyeTilt: -0.25`; the nine positive-only fields use one `0.25` case each. [VERIFIED: existing renderer naming conventions; ASSUMED: provisional strength choice locked by context]

### Public route

```swift
let result = try engine.processResult(
    image: inputImage,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: renderCase.parameters
)
```

This exact single call is the current renderer contract. [VERIFIED: `main.swift`]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest via SwiftPM; Python 3 stdlib helper |
| Config | `BeautySDK/Package.swift` |
| Quick source/no-face run | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` |
| Helper self-test | `python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py --self-test` |
| Full suite | `swift test --package-path BeautySDK` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| EYE-16 | Exact 55-case inventory, one-field construction, facade-only imports | XCTest contract | focused renderer regression command | Existing test; extend in Wave 1 |
| EYE-17 | 385/385 strict decode/dimensions; eligible eye-local visibility, signed tilt, semantic families | Helper/self-test + end-to-end | helper `--self-test`, clean renderer build/run, strict helper | New phase helper required |
| EYE-18 | Pupil/gaze eligibility, neutral/ineligible no-ops, no-face extent, ignored gallery bijection | XCTest + helper + gallery scans | focused renderer test; helper strict; `generate_gallery.py`; git checks | Existing gallery script/tests; extend docs/evidence |

### Sampling Rate

- Per source/test task: focused XCTest and `git diff --check`.
- Per helper task: helper `--self-test` and `py_compile`.
- Per matrix wave: clean renderer build/run followed by strict helper.
- Phase gate: fresh strict 385/385 matrix, gallery containment, full SwiftPM suite, and scope scans.

### Wave 0 Gaps

- New phase-owned strict helper and self-tests — required before output calibration.
- New renderer case inventory/no-face assertions — extend existing `BeautyRendererOutputRegressionTests`.
- Eye eligibility fixture inventory — derive during calibration and record aggregate counts only; do not add biometric payloads.

## Security Domain

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | Local fixture tooling only. |
| V3 Session Management | no | No sessions or services. |
| V4 Access Control | no | Existing local path allow-list in gallery generator. |
| V5 Input Validation | yes | Bounded no-follow file reads, strict PNG/JPEG validation, duplicate/stale-path rejection. |
| V6 Cryptography | no | No cryptographic behavior added. |

Raw eye contours, pupils, coordinates, and face bounds must not be written to committed evidence, diagnostics, gallery metadata, or public APIs. [VERIFIED: AGENTS.md, SECURITY.md, Phase 42 boundary]

## Environment Availability

This phase has no external service or package dependency. [VERIFIED: project package and phase boundary]

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| Swift/XCTest | Source and full-suite gates | ✓ | Swift 6.3.3; tools 6.0 | — |
| Python | Helper and gallery | ✓ | 3.9.6 | — |
| Xcode/AppKit | `BeautyExampleRenderer` build/run | ✓ in prior phase artifacts; verify before execution | local installation | Record reproducible build blocker if unavailable |

## State of the Art

The current repository approach is a strict, standard-library decoder with frozen thresholds and descriptor-safe gallery publication; older Phase 29 eye evidence only checked a broad top region and did not distinguish new semantic families. Phase 43 should retain the newer Phase 39 bounded decoder and add eligibility-aware, eye-local families rather than revive the older helper. [VERIFIED: archived Phase 29/39 artifacts]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|
| A1 | `0.25` is sufficient as a provisional renderer evidence strength for all eleven new cases. | Summary / Code Examples | A case may be invisible and require a different evidence input while preserving provisional/no-promotion scope. |
| A2 | One normalized eye ROI and global floors can pass all eligible portraits after calibration. | Patterns / Validation | Requires a second calibration strategy or justified family-specific floors. |
| A3 | Current portrait fixtures provide at least one complete contour and one valid pupil per required family. | Eligibility pattern | Helper must report unavailable families and phase cannot claim EYE-17 without a suitable committed fixture. |
| A4 | Existing gallery case-group contract can absorb eleven IDs without script redesign. | Gallery pattern | A bijection or ordering constraint may require a focused script update. |

## Open Questions

1. **Which committed portraits are contour/pupil/symmetry eligible for Phase 42 support?** The provider contract defines eligibility, but eligibility is not exposed publicly. Recommendation: derive an aggregate fixture inventory during calibration using engine results and existing package tests; record only fixture names/counts, never raw landmarks. [VERIFIED: Phase 42 contract; unresolved until render]
2. **Can one eye ROI/floor pair distinguish all semantic families?** Recommendation: start with one normalized ROI centered on the upper-middle face, exclude the watermark, measure each family independently, and freeze one global pair only if the weakest family remains meaningfully above floor. [ASSUMED]
3. **How should neutral/ineligible no-op outputs be separated from failed visibility?** Recommendation: require an explicit eligibility table and count no-op families outside visibility denominators; a missing pupil must not be interpreted as successful `pupilSize`/`gazeCorrection` visibility. [VERIFIED: requirement EYE-18 and Phase 42 provider tests]

## Sources

### Primary (HIGH confidence)

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — current 44-case public-facade matrix and output naming.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — source inventory and no-face facade contracts.
- `.planning/phases/42-independent-eye-geometry-and-pipeline-integration/42-CONTEXT.md`, `42-RESEARCH.md`, `42-VERIFICATION.md` — ten-field semantics, eligibility, and provider evidence.
- `.planning/milestones/v1.10-phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py` and `39-RESEARCH.md` — current strict decoder/calibration/gallery pattern.
- `example-images/generate_gallery.py`, `example-images/README.md` — exact gallery bijection and artifact containment.
- `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md` — EYE-16..18 acceptance boundaries.

### Secondary (MEDIUM confidence)

- `.planning/milestones/v1.6-phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` and `29-EYE-RENDERER-EVIDENCE.md` — historical eye ROI/output evidence pattern; superseded for strictness by Phase 39.

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — existing package, renderer, XCTest, and stdlib helpers are directly verified.
- Architecture: HIGH — public-facade route and gallery ownership are explicit in source/scripts.
- Eye ROI/floors: MEDIUM — exact constants require a calibration run on the current Phase 42 output.

**Research date:** 2026-07-16  
**Valid until:** 2026-08-15 for repository-stable seams; remeasure ROI/floors after any renderer or fixture change.
