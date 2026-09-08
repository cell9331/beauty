---
phase: 92-signed-eyebrow-head-spacing
verified: 2026-09-08T06:46:12Z
status: passed
score: 10/10 must-haves verified
overrides_applied: 0
accepted_implementation: 470ae0d
verified_head: b248f6e
repair_cycle: 1
implementation_attempt: 7
---

# Phase 92: Signed Eyebrow-Head Spacing Verification

**Goal:** The owner can move only the inner eyebrow heads in both documented directions while keeping whole-brow geometry stable.
**Status:** passed at generated owner-local package-host scope.
**Re-verification:** No previous VERIFICATION.md existed; initial final verification.

The three ROADMAP success criteria are retained verbatim below. Additional truths merge the current 92-06/03/04 contracts and continuing safety requirements of 92-01/02/05. The explicitly superseded candidate formulas are historical hypotheses, not newly passing requirements. Original failed attempts remain failed. No verification override was used.

## Goal Achievement

| # | Observable truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Positive and negative `eyebrowHeadSpacing` move the two inner eyebrow heads in opposite documented directions with measurable signed displacement. | VERIFIED | Independent execution of the frozen public-facade test reproduced +48/-22 Q16 against both source and neutral; target changes 699/720 and RGB delta 61174/45676 exceed unchanged 500/2000 gates. Provider own-axis tests establish both eligible sides' signs. |
| 2 | Both directions keep the outer eyebrow anchors and non-brow protected regions within their established tolerances. | VERIFIED | Public test asserts outside 128/512, outer/eyes 64/256, background/watermark 0/0 against source and neutral. Independently observed maxima are 0/0 for every group. |
| 3 | The signed inner-head behavior remains measurably distinct from whole-brow `eyebrowSpacing` rather than reproducing its output. | VERIFIED | Independently observed opposite-sign difference 70 Q16 and four whole-brow differences 26/35/96/35, each above frozen 16. Sibling provider emissions remain byte-identical in direct tests. |
| 4 | Observation registration identifies the actual generated inner marker before output scoring. | VERIFIED | `BeautyEyebrowFixtureRegistrationTests.swift:86` derives expected raster columns independently and passes the actual Testing SPI observation through `VisionFaceDetector`; bilateral and unilateral cases pass before rendering. |
| 5 | Eligible sides survive invalid/missing peers without borrowing; dead zone, cap and local fail-closed admission remain. | VERIFIED | Provider `fieldEmissions` independently flatMaps semantic traces; `headSpacingPoints` rejects invalid geometry atomically per side. Exact 0/±ulp and cap-adjacent tests pass. Registration suite renders both signs with either missing peer and requires exact peer bytes plus nonzero own-side work. Resolver still zeros stale/unusable support before provider use. |
| 6 | Inner-half taper, actual source/target clearance, 4.5% radius ceiling and dense same-side safety hold. | VERIFIED | Provider lines 163–291 retain cumulative p<0.5 taper, fixed sign-independent centers, finite/unit/clearance checks, 0.81r reconstruction bound and final Double-measured sum <=0.9. Dense regression independently evaluates the consumer's summed linear inverse field for 4/5/16 samples, both sides/signs and low/half/cap strengths. All pass. |
| 7 | Neutral/provider-empty identity, recovery, deterministic pixels, metadata and redaction remain. | VERIFIED | Public suite independently passed neutral/source equality, invalid/no-face source safety, valid-invalid-valid byte recovery, extent, explicit sRGB, opaque alpha, detection metadata and diagnostics assertions. No generic orientation/profile or portrait claim is inferred from this fixture. |
| 8 | Accepted R5 bytes and review bind current evidence without relabeling historical failures. | VERIFIED | Seven current Git blobs match the accepted identities listed below. 92-01/02/05 summaries are byte-unchanged versus c14719b. Review metadata now names 470ae0d; CR-01 is closed with retained RED commit 4a92373 and R5 regression. 92-06 records owner reopening and cumulative attempt 7. |
| 9 | Focused execution, frozen semantic/runner authority and bounded compatibility remain valid. | VERIFIED | Verifier independently ran all 23 focused tests with zero failures/skips, comparator 576 mutations, runner boundary/cleanup6 and preflight75/65/8. Current frozen scripts, parameter model, renderer, geometry consumer, Warp.metal and architecture/security owners have no phase-base drift. Parent executed the bounded compatibility/freshness217/0/2 and backend/archive/SDK-only gates; these broader results are corroborating evidence, not a claimed verifier rerun. |
| 10 | Six current owners agree with R5 behavior and preserve the Phase 95 boundary. | VERIFIED | Inspected Phase 92 sections of DESIGN, PRODUCT_SENSE, RELIABILITY, QUALITY_SCORE, taxonomy and PLANS: same constants, per-side budget, measured aggregates, clean R5 review, original failed history, unchanged 62/5/75/facade/backend surface, and explicit Phase 95 portrait/full-closeout ownership. |

**Score: 10/10.** No failed or uncertain Phase 92 must-have remains.

## Required Artifacts and Key Links

| Artifact / link | Existence, substance and wiring | Status |
| --- | --- | --- |
| `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift` | Non-stub signed per-side field construction; resolver calls and sanitizes field emissions; `BeautyGeometryEffectPipeline` consumes generated points. | VERIFIED |
| `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` → `BeautyDetection/VisionFaceDetector.swift` | Phase 92 observations travel through the real coordinate mapping; independently checked against generated input rather than expected provider targets. | VERIFIED |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineEyebrowHeadSpacingRepairTests.swift` → `BeautyEngine.processResult` | Three discovered/executed methods render final RGBA8 pixels and calculate independent integer-region and darkness-centroid results. Frozen oracle bytes retained. | VERIFIED |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEyebrowFixtureRegistrationTests.swift` | Two discovered/executed methods cover pre-render registration and both-sign exact missing-peer pixels. | VERIFIED |
| `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` → provider and consumer semantics | Eighteen executed methods, including four BROW methods, sparse/dense independent sampling, cap/dead zone and sibling/recovery coverage. Combined inventory contains nine unique BROW methods. | VERIFIED |
| `scripts/face-feature-batch-manifest.json` → comparator → batch runner | Unchanged case IDs, metrics, thresholds and cleanup path; actual self-test/boundary/preflight execution passes. | VERIFIED |
| 92-06 accepted identity → 92-03 evidence → 92-04 owners | Current source/test hashes, reconciled plans and owner sections agree. Review/security/validation records reflect R5. | VERIFIED |

### Accepted identity checks

| Artifact | Verified current Git blob |
| --- | --- |
| Provider | `7aa6f74bc70457d63e69cb003e9ffe8c939b018c` |
| Provider tests | `25ed3479e469ed4fff1ffca516123740ff3cd0fb` |
| Testing SPI | `ba5270907ff7136eef1de8187c8932eb98116bf9` |
| Registration tests | `103c78bb38e96bb84e6f81dcc34e4d10b75a2b71` |
| Frozen public-pixel oracle | `101a3ff34e8e746bf4fe6e99232ea5f02b5b45a0` |
| Frozen manifest | `8cfa6673a0d8647db79355b36dfa1d48be7024e1` |
| Frozen comparator | `a2924de0100f4d32fbf7b5decd981b3decef7316` |

## Data-Flow Trace

There is no dynamic UI in this SDK-only phase. Equivalent output-flow verification follows input pixels/observations → Vision mapping → resolver admission → eyebrow points → CPU additive inverse sampling → public result → independent RGBA8 metric. The consumer subtracts actual displacement weighted around each target, then interpolates source pixels; evidence is not a provider-reported success flag. Filtering drops work and radius flooring cannot increase the per-side norm/radius budget. No arbitrary cross-side or combined-effect injectivity guarantee is asserted.

## Behavioral Spot-Checks and Probe Execution

All commands below were run independently by this verifier at repository root; no live portrait input was accessed and no server was started.

| Command | Result | Status |
| --- | --- | --- |
| `swift test --package-path BeautySDK --skip-build --filter 'EyebrowWarpProviderTests\|BeautyEngineEyebrowHeadSpacingRepairTests\|BeautyEyebrowFixtureRegistrationTests'` | 18+3+2=23 tests, zero failures/skips; test execution 3.774s; exact aggregates reproduced. Existing current build used. | PASS |
| `swift scripts/compare-face-feature-batches.swift --self-test` | `semantic_validation_self_test=PASS mutations=576 inventories=5/65/8` | PASS |
| `python3 scripts/test-face-feature-batch-boundaries.py` | Boundary PASS; stale success/failure, aliases, symlink parents, invalid reports, spaces/Unicode and cleanup6 covered. | PASS |
| `bash scripts/run-face-feature-batches.sh --preflight-only` | `preflight=PASS live=75 selected=65 semantic=8` | PASS |
| Git accepted-blob / historical-summary / phase-base boundary comparisons | Seven blobs exact; historical summaries unchanged; scripts, public parameter model, renderer, geometry consumer, shader and architecture/security owners unchanged. | PASS |
| `git diff --check` | Exit 0. | PASS |

No conventional `probe-*.sh` was declared by these plans. The phase-declared semantic and runner probes above were executed directly, not credited from SUMMARY narration. Broader parent-run compatibility evidence is 217 discovered/0 failures/2 existing portrait opt-in skips (required compatibility120/0/0); backend24+41, archive hashes and SDK-only boundary passed. Those skips receive no Phase 92 pass credit and do not affect the independently executed 23-test gate.

## Requirements Coverage

| Requirement | Source plans | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| BROW-01 | 92-01/02/05 historical; 92-06 repair; 92-03/04 closeout | Both inner-head directions, protected outer/non-brow regions and distinction from whole-brow spacing. | SATISFIED | Truths 1–7 and independently rerun frozen public outputs. |

No orphaned Phase 92 requirement exists. ROADMAP and REQUIREMENTS completion checkboxes remain for the orchestrator to advance after this report; they are not source-behavior failures. Earlier coefficient/radius hypotheses were explicitly superseded by the authorized repair and retain their failed evidence rather than being retroactively marked GREEN.

## Anti-Patterns and Disconfirmation

No implementation stub, disconnected field, weakened frozen assertion, or unresolved debt-marker comment was found in changed source/test or Phase 92 owner sections. PLANS' historical text quoting past placeholder-scan search terms is not an unresolved debt comment. No raw images, geometry, private locators or transcripts are included in this report.

Three plausible false-pass paths were checked: a geometry-only sign pass with no image effect (falsified by frozen final pixels), sparse safety hiding dense summation failure (falsified by R5 budget and dense regression), and missing-peer contamination hidden by bilateral tests (falsified by both-sign unilateral byte tests). Generic device/orientation/population claims would exceed these tests; current owners expressly restrict the evidence. No uncovered error path requiring a Phase 92 blocker was identified; invalid reconstruction fails closed and is not credited as effective output.

## Human Verification Required

None for the current Phase 92 automated contract. Phase 95 explicitly owns authorized portrait evaluation, final 65-output evidence and complete no-skip closeout; optional physical-device feedback is not a Phase 92 gate. This report grants no portrait-naturalness, device, commercial-quality or distribution qualification.

## Gaps Summary

No blocking gaps. BROW-01 is achieved within the declared owner-local package-host scope. Phase 93 may proceed after orchestrator state synchronization. No source/owner/state files were changed by this verifier and no commit was made.
