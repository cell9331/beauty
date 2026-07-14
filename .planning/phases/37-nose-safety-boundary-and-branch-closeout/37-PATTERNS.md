# Phase 37: Nose Safety, Boundary, and Branch Closeout - Pattern Map

**Mapped:** 2026-07-14  
**Authority:** current source/tests first, then `37-CONTEXT.md` and `37-RESEARCH.md`  
**Shape:** four strictly sequential plans; characterization and convergence before command-backed boundaries, promotion last  
**Expected footprint:** 8 likely test edits, 5 conditional production/fixture edits, 5 required Phase 37 evidence artifacts, 15 current-owner closeout edits, 4 execution summaries

## Planning Conclusions

- Phase 37 is a proof-and-promotion transaction around existing behavior. The current source already contains exact `0.25` caps, six per-field emission arrays, fail-closed sanitization, exact reused `0.5` scaling, all-six stale/no-face zeroing, and a bounded monotonic conflict/emission convergence loop.
- The highest-value code work is table-driven test coverage. Production edits are failure-driven only; do not redesign the public model, add geometry surfaces, add a second conflict pass, or publish a new `geometryStrengthTotal` metric merely to make evidence easier.
- The four plans must remain sequential: `37-01` exact caps/exhaustive degradation -> `37-02` exact convergence -> `37-03` runtime/security/boundary evidence -> `37-04` atomic promotion/current-owner closeout.
- Promotion must be one final transaction. Until Plan 37-03 is fully green and `37-SECURITY.md` says `threats_open: 0`, `提升` stays `future`, `山根` stays `partial`, and branch-level `鼻子` stays `partial`.
- Archived Phase 32 and Phase 34 files are precedent only. They must not be edited, counted as fresh evidence, or used to prove `noseRootNarrowing` / `noseTipLift`.

## Four-Plan File Map

### Plan 37-01 - exact caps and exhaustive six-field safety

| File | Action | Role and data flow | Closest analog |
| --- | --- | --- | --- |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | modify | Table from public input -> normalized public value -> capped effective value -> domains/warnings/aggregate metrics. Own the NOSE-10 zero/exact-cap/overflow/negative/three-non-finite rows for both new fields. | `testPhase35NOSE03ExactCapsRoutingWarningsAndCounts`, `testPhase35NOSE03NegativePositiveOnlyInputsAreSilentNoOps` |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | modify | Main six-field descriptor and transition owner: zero, no-face, missing support, provider-empty, stale, reused, fresh->reused->stale, valid->missing/provider-empty. Compare returned plans independently and compare final per-field emissions. | `testPhase35NOSE03StaleZerosNoseWhileReusedScalesAllFieldsByHalf`, Phase 35 review regressions, `assertConflictThresholdCrossingNoseField` |
| `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` | modify | Provider seam from private field-specific supports + effective strength -> one emission array; prove all six fields are independently eligible and siblings cannot mask emptiness. | Existing `fieldEmissions` and `.sanitizing` tests, including blocked-root/tiny-tip sibling cases |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | modify | Public image facade -> no-face extent + safe-domain continuation + aggregate/redacted result. Expand the legacy-four no-face request to all six or add one all-six case. | `testNoseNoFaceRequestPreservesExtentSafeDomainsAndRedactedMetadata` |
| `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | likely modify only to requirement-name/final-status lock | Exact internal constants -> exact assertions. Keep `0.25`, remove no code constant ambiguity. | Existing exact assertions at lines 29-30 |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | conditional fixture edit | Shared `FaceGeometry.fixture`, missing/support-invalid/reused/stale inputs -> all resolver/provider tests. Add only narrowly missing variants required by the descriptor. | `extension FaceGeometry` at line 209; `.missingNose`, `.onePointNoseRoot`, `.onePointNoseTip`, `.reused`, `.stale` |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | conditional | Public normalization characterization if the cap table cannot cleanly assert normalized public values in resolver tests. Do not re-test the entire Phase 35 compatibility contract. | Phase 35 33-field/default/non-finite tests |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | conditional production fix | Capping -> reuse/stale/no-face -> provider preflight -> domain/warning/metrics -> conflict convergence. Change only when a locked table row fails. | Current `capUnit`, `zeroNoseStrengths`, `scaleReusableNonEyeGeometryStrengths`, `resolveGeometryConflict` |
| `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` | conditional production fix | Six effective fields + private supports -> six emission arrays -> sanitized retained set/final dispatch. | `NoseWarpFieldEmissions` and `fieldEmissions(face:strengths:)` |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-01-SUMMARY.md` | create during execution | Records actual tests/files/counts and keeps promotion explicitly pending. | Phase 35/36 plan summaries |

The descriptor should carry at least: display name, public writable key path or constructor, normalized key path, effective key path, emission key path, exact cap, signed/positive-only policy, valid face, missing/provider-empty face, expected reuse value, and expected domain/warning behavior. `noseTipSize` needs positive and negative rows.

### Plan 37-02 - exactly-once converged combined geometry

| File | Action | Role and data flow | Closest analog |
| --- | --- | --- | --- |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | modify | Direction-complete public requests across face/eye/mouth/nose -> exact final effective values, warning multiplicity, scale/count; replace relational-only assertions for Phase 37 cases with exact arithmetic. | `testPhase35NOSE03EveryNoseFieldWeakensWithFaceEyeMouthAndPreservesDirection` and Phase 34 mouth matrix |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | modify | Lower-level retained strengths -> exact private total semantics, exact `1 / total` scale, exact weakened count, one warning. Keep the total as a test-local mirror, not a new metric. | `strengths(...)`, local `geometryTotal`, `testPhase35NOSE03IndependentNoseFieldsContributeToConflictTotalCountAndScaling` |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | modify | Exact integrated all-six retained/removed fixture -> provider-empty contributes zero times; supported sibling emits; final effective values equal `fieldEmissions(...).sanitizing(...)`. | Phase 35 review threshold-crossing root/lift/signed-tip helpers and exact count/scale assertions |
| `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` | modify if descriptor helper is shared | Direct per-field eligibility/emission equality used by the integrated convergence assertion. | Existing six-array `NoseWarpFieldEmissions` assertions |
| `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` | conditional production fix | Retained unscaled strengths -> total/count -> one scale/warning/metrics result. Preserve signed-absolute total semantics. | Existing lines 16-55 and 58-100 |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | conditional production fix | At most nine monotonic nose/mouth mask removals -> recomputed final conflict evidence. Never add a second external scale. | Existing `resolveGeometryConflict` lines 412-438 |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-02-SUMMARY.md` | create during execution | Records exact totals/counts/scales and any failure-driven source repair. | Phase 35 review-fix summaries |

The integrated case must include all six nose fields, both signed-tip directions across the matrix, representative face/eye/mouth work, at least one removed provider-empty nose field, and an emitting nose sibling. Assert final warning count is exactly one, removed-field emission is empty, all retained emissions are nonempty, `sanitizing(finalStrengths) == finalStrengths`, and count/scale exclude the removed field.

### Plan 37-03 - runtime, output, security, and fail-closed boundaries

| File | Action | Role and data flow | Closest analog |
| --- | --- | --- | --- |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-NOSE-SAFETY-EVIDENCE.md` | create | Command log -> observed focused/full/output/boundary counts -> NOSE-10..13 evidence. This is the central command-backed artifact. | `32-NOSE-SAFETY-EVIDENCE.md`, `34-MOUTH-SAFETY-EVIDENCE.md`, `36-NOSE-OUTPUT-EVIDENCE.md` |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-SECURITY.md` | create | ASVS L1 threat register/classification -> `threats_open: 0`; HIGH findings block promotion. | Rich Phase 35/36 security frontmatter and threat tables; compact Phase 32/34 closeouts |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-REVIEW.md` | create | Fresh scoped code/test/evidence review -> findings or `status: clean`. | `35-REVIEW.md`, `36-REVIEW.md` |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-REVIEW-FIX.md` | conditional create | Only if review findings require remediation; retain finding history and rerun affected/full gates. | `35-REVIEW-FIX.md`, `36-REVIEW-FIX.md` |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/check_nose_safety_boundaries.py` | optional but recommended create | Owned fail-closed wrapper for exact inventory/import/privacy/network/commercial/dependency/artifact/status scans; self-test must prove match/no-match/tool-error handling. | Phase 36 strict helper self-test discipline; Phase 32 comprehensive owner scan. There is no existing Phase 32 boundary script to copy. |
| `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py` | execute, do not edit absent a newly found defect | Frozen 36-case/7-fixture decoder/ROI/no-face boundary. | Phase 36 immutable visible-output contract |
| `example-images/generate_gallery.py` | self-test only; live gallery optional | Regress publication safety/containment. Respect quarantine state; never recursively clean it. | `36-REVIEW-FIX.md` iteration 4 |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-03-SUMMARY.md` | create during execution | Records observed gates and states that promotion has not yet happened. | Phase 36 Plan 03 summary |

The boundary helper is optional only if every shell scan is guarded explicitly. A scan must classify exit `0` as matches, `1` as no matches, and `>1` as blocking error. An unguarded negative `rg` is not acceptable Phase 37 evidence.

### Plan 37-04 - atomic promotion and current-owner synchronization

| File | Action | Role and exact ownership | Closest analog |
| --- | --- | --- | --- |
| `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` | modify | Second-level authority: change only `提升` and `山根` to `implemented`; preserve exactly six deduplicated nose rows. | Phase 32 exact-row guard; Phase 34 exact three-row promotion |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | modify | Whole-branch authority: change `鼻子` from `partial` to SDK-core `implemented`, list all six fields/rows, and preserve no-UI/device/commercial scope. | Phase 34 branch remained partial; Phase 28 branch row wording |
| `docs/meitu-function-blueprint/features/beauty-shaping/nose/README.md` | modify | Nose branch contract: six-field support, all-six degradation/reuse, evidence chain, six mappings, `implemented` SDK-core status. | Current lines 9-19 |
| `docs/meitu-function-blueprint/features/beauty-shaping/README.md` | modify | Parent branch matrix and nose evidence paragraph; no other shaping branch status changes. | Current row 25 and Phase 32 paragraph at line 42 |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | modify | Convert provisional Phase 36 cases into final-cap evidence only after Phase 37 gates; add Phase 37 safety/boundary link and current branch status. Preserve exact 36 x 7 output facts. | Current lines 122-132 and 149-157 |
| `example-images/README.md` | modify | Remove the line-85 provisional/non-promotion statement; retain gallery/ignored/quarantine limitations and record final exact caps + Phase 37 evidence. | Current Phase 36 paragraph at lines 74-85 |
| `ARCHITECTURE.md` | modify | Add durable Phase 37 facade-only/six-field branch-completion boundary; do not duplicate product status detail. | Phase 35 internal-support invariant at line 186 |
| `DESIGN.md` | modify | Change provisional `0.25` to final exact caps and link exact all-six/convergence evidence. | Phase 35 contract lines 111-118 |
| `SECURITY.md` | modify | Add Phase 37 final active-source/ASVS boundary, current artifact count, and `threats_open: 0`; keep Phase 35/36 chronology. | Phase 35/36 security sections |
| `RELIABILITY.md` | modify | Change provisional cap wording, lock all-six provider-empty/transitions/exact convergence behavior and command owner. | Phase 35 reliability lines 170-176 |
| `PRODUCT_SENSE.md` | modify | Add Phase 37 acceptance: exact two row mappings, SDK-core branch completion, evidence counts, and non-claims. Do not rewrite Phase 32/35 historical acceptance. | Sections 7.15/7.16 |
| `QUALITY_SCORE.md` | modify | Add Phase 35-37 v1.9 evidence section; update Nose scorecard from four-row partial to exact six-row SDK-core complete with fresh observed counts. | Phase 31-32 section and Nose row 267 |
| `.planning/PROJECT.md` | modify | Current implementation/verification state, Active -> Validated checklist movement, last-updated line, and v1.9 decision outcome. Keep milestone current until independent audit. | Current lines 19-21, 135-137, 331, 339 |
| `.planning/ROADMAP.md` | modify | Phase 37 status and progress `4/4`; success criteria based on observed evidence. Do not claim milestone audit passed. | Current lines 73-99 |
| `.planning/REQUIREMENTS.md` | modify | Mark NOSE-10..14 and DOC-01 complete with Phase 37 evidence in both checklist and traceability. DOC-01 may say phase owners synchronized; milestone audit remains the next lifecycle gate. | Current lines 28-33 and 68-73 |
| `.planning/STATE.md` | modify | Current position/Phase 37 result/next action `$gsd-audit-milestone`; replace provisional/unpromoted active-state wording without altering archived chronology. | Current lines 26-47 |
| `PLANS.md` | modify | Move Phase 37 execution into Completed and advance the active autonomous record to independent milestone audit. Record observed commands/counts, files, security, promotion, non-claims. | Current active row 29-37 and Phase 35/36 completion records |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-VALIDATION.md` | create/finalize | Nyquist task map, actual counts, `status: passed`, `nyquist_compliant: true`, `wave_0_complete: true`; manual-only section explicitly empty/out-of-scope. | `35-VALIDATION.md` rich task map; `34-VALIDATION.md` compact final state |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-VERIFICATION.md` | create/finalize | Independent 6/6 requirement verdict, fresh counts/gates, exact promotion guards, gaps/non-claims, next audit action. | `35-VERIFICATION.md`, `36-VERIFICATION.md`, archived `32-VERIFICATION.md` |
| `.planning/phases/37-nose-safety-boundary-and-branch-closeout/37-04-SUMMARY.md` | create during execution | Final plan files/commands/outcomes and audit handoff. | Phase 34 Plan 03 summary |

Expected non-edits: `BeautyParameters.swift`, `BeautyEffectPlan.swift`, `BeautySafetyCaps.swift`, `WarpControlPoint.swift`, `BeautyFaceGeometryAdapter.swift`, `BeautyEngine.swift`, `BeautyExampleRenderer/main.swift`, `BeautyRendererOutputRegressionTests.swift`, `Package.swift`, all `BeautyDemo` files, generated PNGs, archived `.planning/milestones/v1.7-phases/` and `v1.8-phases/`, and any milestone-audit/archive/tag/cleanup artifact. They become conditional only if a directly failing Phase 37 gate proves current behavior or inventory wrong.

## Exact Source Seams the Plans Should Cite

### Per-field provider eligibility, never aggregate points

`NoseWarpFieldEmissions` is already the six-field contract:

```swift
struct NoseWarpFieldEmissions: Equatable, Sendable {
    let noseSlim: [WarpControlPoint]
    let noseWingSlim: [WarpControlPoint]
    let noseTipSize: [WarpControlPoint]
    let noseBridge: [WarpControlPoint]
    let noseRootNarrowing: [WarpControlPoint]
    let noseTipLift: [WarpControlPoint]

    func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths
}
```

Source: `NoseWarpProvider.swift:1-40`. `fieldEmissions(face:strengths:)` is at lines 61-86. A requested field whose own array is empty is zeroed independently; `emissions.points` is only the flattened dispatch result and cannot prove sibling-level eligibility.

### Capping, reuse, and all-six zeroing already exist

`BeautyEffectResolver.swift:93-98` uses `capUnit` for both new fields. `:143-146` applies exact reused `0.5`. `:448-478` contains:

```swift
private static func zeroNoseStrengths(_ strengths: inout BeautyEffectiveStrengths) {
    zeroLegacyNoseStrengths(&strengths)
    strengths.noseRootNarrowing = 0
    strengths.noseTipLift = 0
}

private static func scaleReusableNonEyeGeometryStrengths(
    _ strengths: inout BeautyEffectiveStrengths,
    by scale: Float
)
```

The exact expected reused values already proven in `MissingLandmarkDegradationTests.swift:156-164` are `0.175`, `0.175`, signed `+/-0.15`, `0.15`, `0.125`, `0.125`.

### Bounded monotonic convergence is the implementation model

`BeautyEffectResolver.resolveGeometryConflict` at lines 412-438 starts with `var retainedBaseline = strengths`, loops `for _ in 0..<9`, sanitizes provider emissions at the scaled strengths against the unscaled retained baseline, and returns when `nextBaseline == retainedBaseline`. The comment explicitly says each pass only removes fields and there are nine nose/mouth fields. Preserve this algorithm.

### Exact conflict arithmetic is private but testable

`GeometryConflictResolver.resolve` computes:

```swift
let total = geometryTotal(strengths)
let scale = totalThreshold / total
```

It publishes only:

```swift
"beauty.effects.weakenedCount"
"beauty.effects.geometryStrengthScale"
```

and one `combined_geometry_weakened` warning. `geometryTotal` at lines 58-77 uses positive magnitudes and `abs` for signed fields. Tests may mirror this exact sum; Phase 37 should not add a public total metric.

### Closest Phase 35 test signatures

- `BeautyEffectResolverTests.testPhase35NOSE03ExactCapsRoutingWarningsAndCounts()` (`:180`) already covers overflow-to-cap, capped count `1`, aggregate warning, active `.nose`, and redaction.
- `MissingLandmarkDegradationTests.testPhase35NOSE03StaleZerosNoseWhileReusedScalesAllFieldsByHalf()` (`:141`) already proves all-six stale/reused values.
- `MissingLandmarkDegradationTests.assertConflictThresholdCrossingNoseField(parameters:dropped:file:line:)` (`:587`) already proves exact total/scale/count, one warning, sibling emission, and `sanitizing(final) == final`.
- `CombinedEffectSafetyTests.testPhase35NOSE03EveryNoseFieldWeakensWithFaceEyeMouthAndPreservesDirection()` (`:263`) is the seven-row direction matrix, but its Phase 37 successor must add exact total/count/scale rather than only `greaterThan`/`lessThan`.
- `BeautyEngineGeometryFacadeTests.testNoseNoFaceRequestPreservesExtentSafeDomainsAndRedactedMetadata()` (`:285`) currently requests only the legacy four fields at lines 292-299; add both new fields.

## Exact Promotion Replacements

These are the target current-owner lines after and only after Plan 37-03 is green. Exact observed test counts should be inserted where bracketed rather than copied from Phase 35/36.

### `SHAPE_FEATURE_LEDGER.md`

Keep lines 107, 109, 111, and 112 unchanged except optional evidence-link modernization. Replace only the two pending rows:

```markdown
| `鼻子` | 提升 | implemented | Independent public `noseTipLift`; Phase 35 contract/provider evidence, Phase 36 isolated facade output distinct from both signed `noseTipSize` directions, and Phase 37 exact-cap, six-field degradation, combined-safety, and boundary evidence. | Complete for the exact SDK-core nose taxonomy; device/commercial visual review remains separate. |
| `鼻子` | 山根 | implemented | Independent public `noseRootNarrowing`; Phase 35 contract/provider evidence, Phase 36 isolated facade output distinct from `noseBridge`, and Phase 37 exact-cap, six-field degradation, combined-safety, and boundary evidence. | Complete independently; this row does not borrow `noseBridge` / `鼻梁` evidence. |
```

Post-edit guards: exactly six `鼻子` rows; exactly six `implemented`; exactly one each of `大小`, `提升`, `鼻翼`, `山根`, `鼻梁`, `鼻尖`; no nose `partial`/`future` row.

### `FEATURE_MATRIX.md`

Replace row 27 with:

```markdown
| Beauty shaping | 鼻子 | implemented | `BeautyEffects` | `BeautyDetection` nose landmarks, `BeautyRender` unified warp | `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, independent `noseRootNarrowing`, independent `noseTipLift`; implemented subtools: 大小, 提升, 鼻翼, 山根, 鼻梁, 鼻尖. | No unnamed control is implied by this exact six-row SDK-core taxonomy; any future nose capability needs separate design and evidence. | Phases 31-32 cover the four legacy rows; Phases 35-37 independently cover root/tip contract, output, exact caps, exhaustive degradation/convergence, privacy, and boundaries. | SDK-core branch complete only; no Demo UI, device parity, commercial approval, packaging, launch, or broad reference-product parity claim. |
```

### Nose branch README

The current lines 9-19 are stale. Their closeout meaning should be exactly:

```markdown
- Current SDK-core support is exactly six independent fields: `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, `noseRootNarrowing`, and `noseTipLift`.
- Missing/no-face/stale aggregate nose geometry zeros all six; reused eligible non-eye geometry applies exact `0.5`; field-specific missing/provider-empty work is removed independently while supported siblings may continue.
- Status: `implemented` for the exact six-row SDK-core branch.
- Primary owner: `BeautyEffects`.
- Dependencies: package-internal `BeautyDetection` nose/root/tip supports and `BeautyRender` unified warp output; no raw geometry crosses the public facade.
- Evidence: Phases 31-32 prove the four legacy rows; Phase 35 proves independent root/tip contracts and provider paths; Phase 36 proves 252/252 public-facade output with separate baseline/non-alias comparisons; Phase 37 proves final exact `0.25` caps, exhaustive six-field degradation/transitions, exactly-once convergence, redaction, and active-source boundaries.
- Implemented rows: `大小` -> `noseSlim`, `提升` -> `noseTipLift`, `鼻翼` -> `noseWingSlim`, `山根` -> `noseRootNarrowing`, `鼻梁` -> `noseBridge`, `鼻尖` -> signed `noseTipSize`.
- `山根` does not borrow `noseBridge`, and `提升` does not borrow signed `noseTipSize`. Branch completion is SDK-core only and does not claim Demo/device/commercial/packaging/launch readiness.
```

### Beauty-shaping parent README

Replace row 25 with:

```markdown
| `鼻子` | implemented | `BeautyEffects` | `noseSlim`, `noseWingSlim`, signed `noseTipSize`, `noseBridge`, `noseRootNarrowing`, `noseTipLift` | No additional control is implied by the exact six-row taxonomy | Phases 31-32 and 35-37 implement exactly `大小`, `提升`, `鼻翼`, `山根`, `鼻梁`, and `鼻尖`; SDK-core branch complete with UI/device/commercial boundaries preserved. |
```

Replace the current Phase 32-only current-status paragraph at line 42 with a chronological paragraph: Phase 32 implemented four legacy rows and deliberately left two unresolved; Phases 35-37 independently implement `山根` and `提升` and close the exact six-row SDK-core branch without alias borrowing.

### `EXAMPLE_IMAGE_VALIDATION.md`

- Lines 122-123: change “provisional 0.25 input, not final promotion or cap” to “Phase 36 isolated output at the Phase 37-finalized exact `0.25` cap; final promotion requires the Phase 37 safety/boundary evidence.”
- Line 132: replace the provisional/non-promotion paragraph with a final-cap statement and a link to `37-NOSE-SAFETY-EVIDENCE.md`; keep the Phase 36 output counts unchanged.
- Current-status line 152 must no longer list `鼻子` among partial branches. It should read: ``比例`, `脸型`, `眼睛`, and `嘴唇` remain `partial`; exact six-row SDK-core `鼻子` is `implemented`.`
- Add a Phase 37 closeout subsection recording fresh focused/full counts, unchanged `252/252`, `12/12`, `6/6`, `12/12`, `2/2`, `threats_open: 0`, exact row/branch promotion, ignored/untracked artifacts, and all non-claims.
- Preserve Phase 31 and Phase 36 historical statements as chronology; do not rewrite them to pretend they promoted rows at the time.

### Root/current owners

- `DESIGN.md:114` and `RELIABILITY.md:173`: replace “provisional” with final exact `0.25`; add the Phase 37 evidence owner and exact all-six transition/convergence invariant.
- `SECURITY.md`: append Phase 37, do not overwrite Phase 35/36 sections. Record exact 33-field inventory, public/SPI geometry scans, facade-only imports, no network/commercial/dependency drift, ignored/untracked artifacts, and `threats_open: 0`.
- `PRODUCT_SENSE.md`: append Phase 37 acceptance. Keep Phase 32/35 historical non-promotion statements intact.
- `QUALITY_SCORE.md`: add a new Phase 35-37 section; change Nose row 267 to exact six-row SDK-core completion using fresh Phase 37 counts plus unchanged Phase 36 output counts.
- `.planning/PROJECT.md`: lines 19-21 become Phase 37 implementation/verification state; Active lines 135-137 become validated; decision row 331 becomes “Completed in Phase 37; milestone audit pending”; last-updated line changes from Phase 35.
- `.planning/ROADMAP.md`: line 79 -> Complete, line 93 checked, line 99 -> `4/4 | Complete | <observed date>`.
- `.planning/REQUIREMENTS.md`: lines 28-33 and traceability lines 68-73 become complete with specific Phase 37 evidence. Do not say the milestone audit already agrees; the audit is the next action.
- `.planning/STATE.md`: Phase 37 complete, Plan `4/4`, next action `$gsd-audit-milestone`; replace active provisional/unpromoted wording only in current v1.9 state.
- `PLANS.md`: active current step becomes independent v1.9 audit; add one Phase 37 completion record with actual counts and exact promotion.

## Evidence Artifact Patterns

Use the rich Phase 35/36 formats, not only the very short archived stubs:

```yaml
---
phase: 37
status: passed
requirements: [NOSE-10, NOSE-11, NOSE-12, NOSE-13, NOSE-14, DOC-01]
---
```

`37-SECURITY.md` additionally needs `threats_open: 0`. `37-VALIDATION.md` needs `nyquist_compliant: true` and `wave_0_complete: true`. `37-VERIFICATION.md` should score 6/6 requirements and distinguish phase completion from the later milestone audit.

The archived analogs establish useful scope:

- Phase 32 decomposed exact caps, degradation, combined weakening, boundaries, exact-row promotion, owner sync, and final verification into seven tiny plans. Reuse its threat boundaries and exact-row guards, not its four-field counts/status.
- Phase 34 compressed the same lifecycle to safety, combined/boundaries, and docs. Reuse its clean safety/boundary/docs separation, but Phase 37 needs a fourth plan because promotion is explicitly blocked on a separate command-backed/security wave.
- `35-REVIEW-FIX.md` proves the current convergence path survived four review iterations and ends with 79/79 affected and 219/219 full. Those are historical baselines only; Phase 37 must record fresh counts.
- `36-REVIEW-FIX.md` freezes descriptor-safe output/gallery handling and the exact 252-output helper contract. Do not weaken or duplicate that helper.

## Commands Safe for Plans to Cite

Focused suites:

```bash
swift test --package-path BeautySDK --filter BeautySafetyCapsTests
swift test --package-path BeautySDK --filter BeautyEffectResolverTests
swift test --package-path BeautySDK --filter NoseWarpProviderTests
swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter GeometryConflictResolverTests
swift test --package-path BeautySDK --filter BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests
```

If shared resolver/convergence production code changes, also run:

```bash
swift test --package-path BeautySDK --filter MouthWarpProviderTests
```

Full/output gates:

```bash
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --self-test
python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py --input example-images/input --output example-images/output --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
python3 example-images/generate_gallery.py --self-test
git diff --check
```

Required live output result remains exactly 36 cases x 7 fixtures = 252 decoded same-dimension outputs, 12/12 baseline comparisons, 6/6 root/bridge, 12/12 lift/signed-tip, and 2/2 no-face checks unless separately authorized source inventory changes.

Artifact guards should include tracked and staged queries, not only `git ls-files`:

```bash
test -z "$(git ls-files example-images/output example-images/gallery example-images/.gallery-staging example-images/.gallery-quarantine)"
test -z "$(git diff --cached --name-only -- example-images/output example-images/gallery example-images/.gallery-staging example-images/.gallery-quarantine)"
git check-ignore example-images/output/representative.png example-images/gallery/representative.png
```

Exact source boundaries must classify matches rather than assume every match is a failure. At minimum cover:

- public/SPI declarations containing `FaceGeometry`, supports, landmarks, bounds, `SIMD`, `WarpControlPoint`, raw detector objects, or provider types;
- internal-target imports in `BeautyDemo/BeautyDemo`, `BeautyDemo/BeautyDemoTests`, and `BeautySDK/Sources/BeautyExampleRenderer`;
- network/cloud APIs and URLs in active product sources;
- account/payment/VIP/entitlement/StoreKit/commercial execution paths;
- `Package.swift` target/dependency drift and exact public inventory `33 = 32 numeric + filterId`;
- diagnostic values/messages/keys containing coordinates, supports, bounds, paths, bytes, detector objects, provider types, or per-field failure payloads;
- tracked/staged output/gallery/staging/quarantine artifacts.

## Blocking Pitfalls

- Do not promote owners in Plans 37-01 through 37-03.
- Do not use archived Phase 32 output/safety evidence for the two new rows.
- Do not infer a field emits because `emissions.points` is nonempty.
- Do not count a provider-empty field in the final total/count/scale, even if it was requested before preflight.
- Do not assert only `<= 0.25`, nonzero, smaller, or sign-preserved where exact values/counts/scales are locked.
- Do not create a cache/state machine for transition tests; consecutive resolver/facade calls and independent returned results are sufficient.
- Do not let `rg` exit `>1` masquerade as a clean no-match result.
- Do not recursively delete or overwrite gallery quarantine/staging state.
- Do not edit archived milestone evidence, create the v1.9 milestone-audit artifact, archive/tag/clean, or claim device/commercial/packaging/launch readiness inside Phase 37.
