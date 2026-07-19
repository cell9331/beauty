# Phase 44: Eye Geometry Safety and Ledger Closeout - Research

**Researched:** 2026-07-19
**Domain:** Swift package geometry safety, deterministic evidence, fail-closed source boundaries, and documentation promotion
**Confidence:** HIGH for repository seams and closeout patterns; MEDIUM for exact naturalness interpretation (this phase records bounded automated evidence, not subjective approval)

## User Constraints

The following locked decisions are copied from `44-CONTEXT.md` and are binding:

- Final caps are `eyeHeight .35`, `eyeLength .35`, `upperEyelidLift .30`, `pupilSize .25`, `gazeCorrection .25`, `lowerEyelidDrop .30`, `eyeTilt +/- .25`, `innerCornerOpen .25`, `outerCornerOpen .25`, and `eyeSymmetry .25`.
- Public positive-only ranges remain `0...1`, signed `eyeTilt` remains `-1...1`; exact cap is not counted, overflow counts once, non-finite/negative positive-only values become zero, and signed direction survives.
- General neutral work is `<= Float.ulpOfOne`; gaze dead zone is pupil-to-own-center distance `<= .002`; gaze's existing max correction fraction is `.35`; symmetry's span/tilt neutral thresholds are `<= .0001` and its max midpoint blend is `.30`.
- All fourteen eye fields are complete-eye dependent except pupil fields, which are local to validated pupil support. Invalid/missing contours, malformed side order, reused/stale/no-face, provider-empty output, and transitions fail closed without proxy fallback or cached vectors.
- Combined geometry uses one retained provider-eligible baseline: exact fully eligible total `10.70`, count `33`, scale `1/10.70`; at most `28` eye+nose+mouth provider removals (14+6+8), monotonic and exactly once.
- A self-tested Python active-source/security/artifact checker must provide default pre-promotion and `--allow-promotion` modes, classify command errors, reject scope/artifact drift, and guard exact ten-row promotion.
- Promote exactly `眼高`, `长度`, `提肌`, `眼瞳大小`, `眼神矫正`, `眼睑下至`, `倾斜`, `内眼角`, `外眼角`, and `对称`; retain `去脂` and `祛红血丝` as future and branch `眼睛` as partial.
- Do not add Demo/device/commercial/performance/packaging/shipping/launch claims, tracked generated images, new dependencies, public geometry, network/cloud, commercial routes, milestone audit/archive/tag/cleanup, or rewrite archived Phase 30/37/40 evidence.

## Summary

Phase 41-43 already implement the required runtime route and strict public output proof. The remaining work is a proof and ledger closeout, not a geometry redesign. `BeautySafetyCaps.swift`, `BeautyEffectResolver.swift`, `EyeWarpProvider.swift`, and `GeometryConflictResolver.swift` are the runtime owners; `BeautyParameters` normalization and `BeautyEffectPlan` diagnostics are compatibility boundaries. The nearest complete precedents are the Phase 40 mouth and Phase 37 nose safety closeouts: exact cap tables first, exhaustive field-local degradation and exact retained-set convergence second, a self-tested classifier and fresh gates third, then one atomic promotion/documentation patch.

**Primary recommendation:** preserve the existing values and algorithms, strengthen them with requirement-named exact tests and a Phase 40-shaped boundary checker, then edit status owners only after all evidence is green.

## Repository Findings

### Runtime seams to extend, not replace

| Concern | Current owner | Planning consequence |
|---|---|---|
| Exact caps and capped count | `BeautySafetyCaps.swift`, `BeautyEffectResolver.resolve` | Add table-driven exact-value/overflow/non-finite assertions; remove provisional comment only in final safety task. |
| Fourteen named fields | `EyeWarpFieldEmissions` and `sanitizing(_:)` in `EyeWarpProvider.swift` | Assert each field's provider-empty result is zeroed before accounting; pupil absence only zeros two fields. |
| Gaze evidence | `gazeCorrectionEvidence(face:strength:)` in `EyeWarpProvider.swift` | Use post-`6e4704e` aggregate pupil-to-own-center proof; never use the retired RGB mirror score or raw points. |
| Complete-eye and freshness | `BeautyEffectResolver.resolve` | Keep explicit contour/order/reused/stale/no-face skip; preserve safe non-eye domains and redacted warnings. |
| Combined conflict | `resolveGeometryConflict` and `GeometryConflictResolver.swift` | Test exact retained arithmetic and one evolving baseline; bound removals at 28 and assert no re-add/double scale. |
| Public facade | `BeautyEngine.swift` and Phase 43 helper | Regress unchanged 385/385 output and 11/11 no-face behavior; no internal imports or new output media. |

### Exact values and evidence ceilings

Phase 42's caps are currently `0.35/0.35/0.30/0.25/0.25/0.30/0.25/0.25/0.25/0.25`; Phase 43 isolates every new field at public `.25` and records 385 outputs, 66/66 visibility, 6/6 signed tilt, 60/60 semantic distinction, and 11/11 no-face no-op. Those numbers are upstream acceptance evidence. They do not justify dynamic threshold derivation, visual naturalness, device parity, or changing ROI/floors.

### Degradation and transition matrix

- Complete observed contours are required for all contour fields and the measured pair. Missing either contour, invalid side order, duplicate/coincident/inverted points, malformed bounds, or stale/reused eye geometry skips all fourteen eye fields.
- A missing/implausible pupil only removes `pupilSize` and `gazeCorrection`; valid contour siblings continue. Gaze neutral offset `<=.002` is an intentional no-op. Symmetry neutral span/tilt deltas `<=.0001` is an intentional no-op.
- Provider-empty is final field eligibility and must remove work before totals, active domains, warning/metric counts, and dispatch. It must not remove valid siblings.
- Fresh/reused/stale and no-face transitions must be stateless: no prior vectors or strengths may survive. Reused non-eye fields retain the established `.5` behavior; eyes use complete-domain skip.

### Retained-set arithmetic

For a fully eligible synthetic fixture, the exact capped magnitudes are: five face fields `2.35`, fourteen eye fields `4.10`, six nose fields `1.80`, and eight mouth fields `2.45`, for total `10.70` and count `33`; combined scale is `1/10.70`. Removal cases must state their own exact total/count/scale (for example pupil removal subtracts `0.50` and two fields). The test must compare final effective strengths and provider emissions from the same converged mask.

### Boundary/promotion precedent

`check_mouth_geometry_boundaries.py` and `check_nose_safety_boundaries.py` establish the required checker shape: standard-library Python, deterministic `--self-test`, default live pre-promotion mode, `--allow-promotion`, explicit root/scope/artifact checks, subprocess exit-state classification (0 match, 1 clean no-match, >1 error), one-failure-per-owner fixtures, and status-window checks. Phase 44 must substitute the 48-field public inventory, fourteen-eye ownership, ten Chinese row names, future retouch rows, and partial branch condition. Promotion must be impossible before safety/security/review/verification artifacts pass.

## Standard Stack

| Tool | Use | Source |
|---|---|---|
| Swift Package Manager | `swift test --package-path BeautySDK` full and focused suites | Existing repository command in Phase 41-43 artifacts. |
| XCTest | Table-driven resolver/provider/degradation/convergence assertions | Existing `BeautySDK/Tests/BeautyEffectsTests` patterns. |
| Python 3 standard library | Boundary checker and deterministic self-tests | Existing Phase 37/40 checker scripts; no package installation. |
| `rg`, `git diff --check`, `git check-ignore`, `git ls-files` | Active-source, hygiene, and generated-artifact gates | AGENTS.md and prior closeout evidence. |

No new package, target, render pass, or network fetch is allowed. No external documentation lookup is needed; repository source and current ledgers are authoritative.

## Architecture Patterns

1. **Proof before status:** safety tests and helper/security/validation artifacts remain green while row/branch status stays unchanged; final plan performs one atomic documentation patch.
2. **Field-local eligibility:** named provider arrays are the source of truth. `sanitizing(_:)` evolves the retained unscaled baseline, then conflict scaling runs; fields are not inferred from aggregate non-empty output.
3. **Monotonic convergence:** each iteration may remove an emitting-ineligible field but never reintroduce it. The loop has the exact 28-removal upper bound.
4. **Aggregate redaction:** warnings/metrics can expose categories, bounded counts, totals, and scales only. Raw points, side labels, bounds, detector objects, paths, and image bytes are prohibited.
5. **Descriptor-safe disposable media:** rerun Phase 43 helper/gallery only as regression; generated PNGs remain ignored, untracked, and unstaged.

## Common Pitfalls and Controls

- Treating `.25` renderer evidence as a reason to lower/raise caps → freeze current exact cap table and test cap boundaries directly.
- Counting requested fields instead of emitted fields → assert provider-empty removal from total/count/scale/metrics/dispatch.
- Applying reused `.5` to complete-eye geometry → assert reused/stale eye domain skip and non-eye sibling continuation.
- Reusing the pre-`6e4704e` mirror gaze metric → require `gazeCorrectionEvidence` aggregate and adversarial neutral/tilt/color tests.
- Double weakening or stale baseline reintroduction → exact `10.70/33/1÷10.70` fixture plus late-removal and provider-emission equality tests.
- Scanners that treat grep exit 1 as failure or ignore unclassified matches → replicate Phase 40 subprocess classifier and one-failure fixture matrix.
- Promoting a row/branch before all owners agree → default checker must reject promotion; only `--allow-promotion` after evidence can permit it.
- Editing archived artifacts or making setup/commercial claims → include explicit immutable-archive and non-claim assertions in owner docs/checker.

## Validation Architecture

### Automated layers

| Layer | Required evidence | Backstop |
|---|---|---|
| Cap/normalization | exact ten values, caps/counts/warnings, sign and non-finite matrix | `BeautySafetyCapsTests`, `BeautyEffectResolverTests` |
| Provider/degradation | fourteen-field named emissions, contour/pupil/dead-zone/provider-empty and all transitions | `EyeWarpProviderTests`, `MissingLandmarkDegradationTests`, `BeautyEngineGeometryFacadeTests` |
| Convergence | full 33-field total/count/scale; exact removal masks through max 28; final strengths/emission equality | `GeometryConflictResolverTests`, `CombinedEffectSafetyTests` |
| Output regression | unchanged 385/385 strict matrix, 66/66, 6/6, 60/60, 11/11 and gallery containment | Phase 43 helper + gallery self-test/live gate |
| Boundary/security | Python compile/self-test/default live, ASVS L1 HIGH blocking, active-source/import/dependency/network/commercial/compatibility/artifact scans | Phase 44 checker + `44-SECURITY.md` |
| Promotion/docs | allow-promotion fixture, exact ten rows, current owners and non-claims synchronized | checker `--allow-promotion`, `44-VERIFICATION.md`, `44-VALIDATION.md`, `git diff --check` |

### Required command set

At minimum plans should run focused nonzero suites for caps/resolver, eye provider, degradation/facade, combined safety/conflict, then `swift test --package-path BeautySDK`; `python3 -m py_compile` and checker `--self-test`/default live; Phase 43 helper `--self-test` and strict live plus gallery self-test/containment; active-source/artifact scans; and `git diff --check`. Xcode/Demo/device commands are deliberately omitted.

### Test fixtures and boundaries

Use existing semantic fixture constructors with complete left/right contour and pupils, no-face fixture, malformed/missing contour variants, neutral pupils, measured asymmetry, and freshness state variants. All fixtures must assert redacted outcomes rather than exposing support payloads. Boundary self-tests should mutate one contract/status/artifact condition at a time and verify the checker rejects it.

## Resolved Planning Questions

- **Final caps:** retain current Phase 42 constants; no calibration redesign is justified by existing Phase 43 `.25` cases.
- **Gaze proof:** use the aggregate exact provider sample added by `6e4704e`; do not resurrect the unsound mirror metric.
- **Promotion shape:** six plans over six waves: (1) caps/degradation, (2) convergence, (3) boundary/evidence, (4) atomic four-file promotion, (5) example/root owner synchronization, and (6) planning-ledger verification plus an explicit pending independent-audit handoff.
- **Lifecycle:** stop at phase verification and hand off to independent milestone audit; no archive/tag/cleanup in Phase 44.

## Project Constraints (from AGENTS.md)

- Read `AGENTS.md` then `PLANS.md` and route changes to owning root contracts.
- Preserve unrelated local changes; use `apply_patch` for edits and narrow, meaningful verification.
- New public behavior requires `PRODUCT_SENSE.md`; architecture/privacy/reliability changes require their owner docs.
- Do not claim unavailable Xcode/Demo/device verification; explicitly record blockers.
- Use `rg` for discovery and explicit iOS destinations only if an Xcode build is in scope (it is not for Phase 44).

## Sources Consulted

- `.planning/phases/41-public-contract-and-observed-eye-support/41-CONTEXT.md`, `41-RESEARCH.md`, `41-VERIFICATION.md`
- `.planning/phases/42-independent-eye-geometry-and-pipeline-integration/42-CONTEXT.md`, `42-RESEARCH.md`, `42-VERIFICATION.md`
- `.planning/phases/43-public-facade-eye-geometry-output-evidence/43-CONTEXT.md`, `43-RESEARCH.md`, `43-EYE-OUTPUT-EVIDENCE.md`, `43-VERIFICATION.md`, post-`6e4704e` source diff
- `.planning/milestones/v1.10-phases/40-mouth-geometry-safety-and-ledger-closeout/40-CONTEXT.md`, `40-RESEARCH.md`, `40-PATTERNS.md`, `40-MOUTH-SAFETY-EVIDENCE.md`, `40-VERIFICATION.md`, `check_mouth_geometry_boundaries.py`
- `.planning/milestones/v1.9-phases/37-nose-safety-boundary-and-branch-closeout/37-CONTEXT.md`, `37-RESEARCH.md`, `37-NOSE-SAFETY-EVIDENCE.md`, `check_nose_safety_boundaries.py`
- `.planning/milestones/v1.6-phases/30-eye-safety-ledger-and-closeout/30-CONTEXT.md`, `30-EYE-SAFETY-EVIDENCE.md`, `30-VERIFICATION.md`
- Current runtime/test owners listed above.
