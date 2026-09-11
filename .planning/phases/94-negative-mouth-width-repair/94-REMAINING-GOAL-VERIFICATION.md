---
phase: 94-negative-mouth-width-repair
verified: 2026-09-11
status: passed
score: 28/28 audit truths verified
behavior_unverified: 0
overrides_applied: 0
human_verification: []
covered_files:
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
  - .planning/phases/94-negative-mouth-width-repair/94-01-PLAN.md
  - .planning/phases/94-negative-mouth-width-repair/94-01-SUMMARY.md
  - .planning/phases/94-negative-mouth-width-repair/94-02-PLAN.md
  - .planning/phases/94-negative-mouth-width-repair/94-02-SUMMARY.md
  - .planning/phases/94-negative-mouth-width-repair/94-03-PLAN.md
  - .planning/phases/94-negative-mouth-width-repair/94-03-SUMMARY.md
  - .planning/phases/94-negative-mouth-width-repair/94-04-PLAN.md
  - .planning/phases/94-negative-mouth-width-repair/94-04-SUMMARY.md
  - .planning/phases/94-negative-mouth-width-repair/94-05-PLAN.md
  - .planning/phases/94-negative-mouth-width-repair/94-05-SUMMARY.md
  - .planning/phases/94-negative-mouth-width-repair/94-06-PLAN.md
  - .planning/phases/94-negative-mouth-width-repair/94-06-SUMMARY.md
  - BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthLifecycleTests.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthNegativeTests.swift
  - BeautySDK/Tests/BeautyCoreTests/MouthNegativeOracleTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/MouthNegativeFieldTests.swift
  - DESIGN.md
  - PLANS.md
  - PRODUCT_SENSE.md
  - QUALITY_SCORE.md
  - RELIABILITY.md
  - SECURITY.md
  - docs/SDK_EFFECT_TAXONOMY.md
  - scripts/check-phase94-remaining.py
covered_digest: "v1:sha256:c5b9ef42bff2edc1a43ecd36342c8236c3bfa7cc9932daf43df6c382920f3d27"
---

# Phase94 94-06 Task2 — Independent goal-backward verification

```json
{
  "schema": "phase94.goal-review.1",
  "reviewer_role": "independent-parent",
  "verdict": "PASS",
  "unresolved_blockers": 0,
  "checks_sha256": "fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4",
  "provider_sha256": "7c3218d0586704cb078b4c7e2004805e182341c37b371567f204094be59153c8",
  "inputs": {
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthLifecycleTests.swift": "30e6dc39fe1ec3ac7d88c5b33880e1a0bfd7e179e2fcf7f2026573dcf8ff3ef9",
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthNegativeTests.swift": "f6bf8d3c9ce59ce25ac09c9e0b4147a61e5e54d9e397abfd6ee35c2b4e4cc65a",
    "BeautySDK/Tests/BeautyCoreTests/MouthNegativeOracleTests.swift": "5f76e3c6587bc68c0b3fcbaf2eee0f7a488bdbb4d303a154529a77141a418109",
    "BeautySDK/Tests/BeautyEffectsTests/MouthNegativeFieldTests.swift": "9037d41956edba99dc4fb0cf9c11ba64138960aaca975c2e49be35d2e6552a00",
    "scripts/check-phase94-remaining.py": "d7ddb91e59548f752422c62f91f632d8312a6cc57712d626300ef74ae370c45d"
  },
  "owners": {
    "DESIGN.md": "96ec10010c0f7f4e4985b21a52e2e421082624b639d0b68093d9d18e0e5367f5",
    "PLANS.md": "8b02dcee6fe6433a1f4b1a4a900374cb0ec911dd481786f5ae3678d33321b3f0",
    "PRODUCT_SENSE.md": "bf1fd7a7d2c1c3664f64aef5a8b384f4a11e9bf4594147d79a8832e94a14e135",
    "QUALITY_SCORE.md": "258e746d2d1690dd030302e6a3ae340db99b33d9e14575265428a52c7d1e90dd",
    "RELIABILITY.md": "b0d36e3d082d15be27b527b300b8b55bc3f66a8ac05ea5eb6098e34131d37f9e",
    "SECURITY.md": "194eebe86026a8fac0e3a7e30a07a180b97d67fe9a1bcca457e23953228fa029",
    "docs/SDK_EFFECT_TAXONOMY.md": "02f348db8a3fc636f56e84de01a9391ae7493195a533d3d7921fc2e3964aa4a6"
  },
  "owner_event_sha256": "fd206821154b798865e71c1d36e4e1a5888b0749c031519b0c6841f4fba872b1",
  "implementation_review_sha256": "1a8ace6b1b122b63ebae884408630b18036ef6227b8b4615404bffa295e43aa4",
  "all_truths": true,
  "phase_complete": true
}
```

**Goal verdict: PASS, zero unresolved blockers or warnings.** The owner can contract mouth width through the existing signed control without disturbing the working expansion direction or mouth height, within the registered generated-source CPU contract. This header is the independent goal verdict required for parent admission. Its `phase_complete: true` does not assert that the completion receipt has already been published. At verification, CHECKS and read-only status still report incomplete and `94-REMAINING-COMPLETE.json` is absent. Parent must separately finalize the exclusive atomic receipt against these exact bytes. Administrative MOUTH-01/ROADMAP/STATE promotion remains parent-owned; no PLANS or owner edit is authorized after sealing.

## Evidence basis and identity

This is the same independent verification continued from its safe checkpoint, not a new research or implementation pass. Previously verified evidence was retained; the final continuation completed only the six retained degradation bodies, positive/golden bodies, frozen comparator comparison and current identity/report checks. No previous goal report or override existed.

Behavioral evidence comes from the actual existing, hash-bound named-test receipts and their source assertions, as explicitly requested; this verifier did not rerun Swift/native tests. CHECKS contains 41 distinct methods, each with one start/end/execution/pass, no unknown completion, failure, skip or unexecuted method. Its accepted provider, five frozen inputs and historical receipt match current files. This is stronger than a script exit or SUMMARY claim: the real pixel/lifecycle assertions, strict child-result parsing, method reconciliation and receipt publication prerequisites were inspected.

The earlier part of this verification independently checked all 169 event links, six published receipt byte/content bindings, 179 current and 32 historical pinned file hashes. Original seed and reviewed runner-authoring disposition remain intact. Final continuation reused the new runner's read-only `status` and `scope`: both returned `scope_pass`, policy B; status returned `phase_complete: false`. Current CHECKS/provider/input hashes and all seven full owner hashes were independently recomputed again. Latest qualification is event169; its canonical sorted compact JSON SHA256 is the header's `owner_event_sha256`. The latest qualification, not the earlier behavior event, owns final owner identity. The documented intervening EOF blank-line trim in 94-05-SUMMARY does not alter that final binding.

The generic covered-files fingerprint above was copied from `gsd-tools query verification.fingerprint`; it is supplementary planning coverage. The strict JSON binds completion admission to current CHECKS, implementation review and qualification owner bytes. A later administrative summary change is not permission to change sealed owners.

## Observable truths — complete remaining-audit coverage

Rows follow all 28 GOAL/REQ/RESEARCH/CONTEXT entries in `94-REMAINING-PLANNING-AUDIT.md`. VERIFIED means implementation plus the relevant bound behavioral evidence; no row is credited merely because it was planned.

Evidence abbreviations: **P** = `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthNegativeTests.swift:testNegativeWidthAllFiveComparisons`; **O1–O3** = the three named methods in `MouthNegativeOracleTests.swift`; **F1–F4** = the four named methods in `BeautySDK/Tests/BeautyEffectsTests/MouthNegativeFieldTests.swift`; **L1–L4** = the four named methods in `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthLifecycleTests.swift`. Names and method order are exactly the frozen `94-REMAINING-VALIDATION.md` manifest. Every cited method is present as a passing execution record in current CHECKS.

| # | Truth source and obligation | Status | Actual evidence |
|---|---|---|---|
| 1 | GOAL: signed contraction with expansion and height intact | VERIFIED | P actual returned pixels, retained positive public tests, both-sign lifecycle and complete protections below. |
| 2 | GOAL SC1: measurable negative contraction | VERIFIED | P source and neutral each 520 changed /73743 RGB /−24 Q16; frozen minima 500/2000/16 all satisfied. |
| 3 | GOAL SC2: positive expansion retained; both signs distinct from mouthSize | VERIFIED | Negative sibling margins 200/181/37 Q16. `BeautyEngineMouthBaselineTests:testPositiveExpansionAndProtectionBaseline` and `testRetainedMouthRowsHaveDeterministicDigests` pass; original positive +176 Q16, size margins19/237 retained with exact output identity. |
| 4 | GOAL SC3: both signs protect height/face/background | VERIFIED | P all negative maxima0/0; positive public conjunction passes, with unchanged positive output. Positive historical outside RGB90 is within512; other positive protected maxima0/0. |
| 5 | REQ MOUTH-01: all clauses | VERIFIED | SC1–SC3 plus registered source, existing signed±0.35 API, no size alias or sign inversion. Requirement administrative checkbox intentionally remains pending parent receipt. |
| 6 | RESEARCH A1: independent registered source prerequisite | VERIFIED | `MouthRepairFixture.source` has no provider/oracle input; three `MouthFixtureRegistrationTests` exercise actual detector/adapter/raster registration and rejected controls. Original9/9 receipt and current repeated methods bind immutable source/SPI. |
| 7 | RESEARCH: frozen integer metric and five-comparison conjunction | VERIFIED | O/P and retained `MouthBaselineOracle`; direct comparator/manifest cross-check below. Both references and each sibling are independently necessary. |
| 8 | RESEARCH: adversarial arrays/predicates/foreign anatomy | VERIFIED | O1 literal integer/tolerance/overflow cases; O2 each bound independently violated; O3 measured inward/identity/outward/alias/height/leak arrays. Registration rejects shifted/reflected/disconnected/canonical and missing-support controls. |
| 9 | RESEARCH: positive/sibling signatures and efficacy | VERIFIED | Public positive method measures expansion; retained-row method renders14 rows through both wrappers twice. Runner compares source+14 hashes exactly to pinned METADATA receipt before publishing current lane. P also checks its four retained rows. |
| 10 | RESEARCH A2: negative-only correction only after prerequisites | VERIFIED | Baselines precede select/event71 and begin1/event72; original protection and actual F3 defects recorded. B succeeds only after the declared A failure/rollback branch. |
| 11 | RESEARCH: actual sampler cutoff/scaling/reconstruction | VERIFIED | Provider final Float pair checked against actual2D displacement bound; F1 quarter/half/cap/overflow and cutoff-adjacent values. Compared with retained sampler L1/radius cutoff and quadratic inverse field. |
| 12 | RESEARCH: whole-field/disjoint/overlap/mixed proof limits | VERIFIED | F3 actual fixture+narrow support crossing/reversal/grid/derivative checks; F4 sums contributing overlapping fields. Inconclusive sufficient bounds do not authorize failure.0.8 applies only to the repaired negative pair. |
| 13 | RESEARCH: malformed/missing support and sibling isolation | VERIFIED | F2/F4 plus six retained degradation bodies below; actual resolver/provider calls, zeros, retained strengths/emissions, domains and warnings asserted. |
| 14 | RESEARCH: neutral/caps/extent/color/alpha/determinism | VERIFIED | L1 actual source/neutral identity, nonfinite normalization, signed cap equality, translated extent; P/L extraction and repeated wrapper bytes/metadata. |
| 15 | RESEARCH: eight encodings and separate mirror policies | VERIFIED | L2 eight lossless encoding/inverse pairs, raw-wrapper equality; L3 real CoordinateMapper point/rect/presentation expectations and repeat output. Canonical semantic scope remains .up. |
| 16 | RESEARCH: typed reset/recovery and privacy | VERIFIED | L4 valid/reset/rejected/reset/valid sequence asserts source-safe rejection, recovered bytes/metrics, reasons and invocation/reset counts; fixed redacted diagnostics only. |
| 17 | RESEARCH: finite children, exact selection/build/cleanup | VERIFIED | Runner `method_timeout`, `measure_lane`, `classify`, `guarded_child`; pinned capture helper enforces8MiB combined memory capture, deadline, own process group and unconditional kill/reap/pipe close. Exact41 records prove selection. |
| 18 | RESEARCH: source/gate/test freeze and attempt history | VERIFIED | Frozen oracle event5 and safety event27 precede begin72; exact review/input bindings. Two counted begin events, one rollback; no reset/third attempt. |
| 19 | RESEARCH: architecture responsibility and existing stack | VERIFIED | Actual facade→detection/mapping→adapter→resolver/provider→CPU sampler→returned image chain; production exception strips back to original provider. Other pinned sources/package remain exact. |
| 20 | RESEARCH: independent review/goal/seven owners | VERIFIED | Fresh implementation/security report has strict PASS/0 blockers/0 high findings at current identity; current review hash and event169 owner map match. This report supplies independent goal verdict before parent finalize. |
| 21 | CONTEXT D-01: signed cap, positive and siblings, no alias | VERIFIED | Unchanged positive/shared code; P sibling distinctions, L1 caps, retained golden/provider and14-row evidence. |
| 22 | CONTEXT D-02: frozen actual-pixel contract | VERIFIED | Actual facade pixels flow into O; all five comparisons, literal regions and predicates preserved, including comparator-clipped and extra full protection. |
| 23 | CONTEXT D-03: registration/source/baseline freeze | VERIFIED | Source-first recipe and real registration; source/SPI/original receipt hashes immutable before both attempts; no candidate-dependent anatomy edits. |
| 24 | CONTEXT D-04: metadata/lifecycle/effective field safety | VERIFIED | F1–F4/L1–L4 and retained degradation execution records paired with source assertions; raw Device RGB and named-sRGB measurement distinction retained. |
| 25 | CONTEXT D-05: private negative production scope | VERIFIED | Removing exact marked dispatch/helper reproduces original SHA d8f306e3643aca367451a3dbd3bc97c2208e0abfa9b4ab80fdfb3c4390fcc6b3. B equals committed A with only gap/8→gap/7. No API, adapter, renderer, shader, sibling, inventory or package change. |
| 26 | CONTEXT D-06: one research/set, max2 attempts, preserve failures | VERIFIED | Research1/checked set1; A41/40/1 retained, rollback119 restores original, begin120 records B attempt2. Both compile/review/seal chains and original failures preserved. Budget exhausted; no automatic third attempt. |
| 27 | CONTEXT D-07: independent review/owners/privacy/finite checks | VERIFIED | Strict review headers and same-identity admission; seven final full hashes; bounded structured receipts, finite native envelopes and cleanup. No raw durable outputs introduced. |
| 28 | CONTEXT D-08: separate Phase95 and excluded directions | VERIFIED | Seven owners consistently limit this to generated-source CPU evidence; Phase95 private portraits/final65/full no-skip, FACE-01, optional device and distribution remain separate. |

## Data flow and assertion quality

`MouthRepairFixture.source/image` → Testing observation provider → `BeautyEngine.processResult` / legacy `process` → `legacyStillImageResult` → `resolveStillImageGeometry` → `VisionFaceDetector`/`CoordinateMapper` → `BeautyFaceGeometryAdapter` → `BeautyEffectResolver`/`MouthWarpProvider` → CPU color/geometry pipeline → `result.output` → named-sRGB RGBA8 extraction → integer oracle → all predicates. This is wired substantive code, not a static output or provider-coordinate proxy. The observation is intentionally the declared generated-source fixture; it is not evidence of observed individual lip anatomy or population accuracy.

The sampler uses target-centered quadratic inverse displacement from actual target−source vectors, merges contributions and bilinearly reads the original buffer. Provider strength metadata alone cannot establish motion. Renderer radius/L1 admission remains strictly >0.0001. The repaired helper preserves Y and bounds reconstructed Float points, with at most one rescaling. Field tests are unit field proofs; P supplies separate rendered-pixel proof.

| Test evidence | Assertion strength and provenance | Assessment |
|---|---|---|
| P and positive baseline | Actual returned pixels; independent fixed integer metric, source/neutral/sibling/protection conjunction | Sufficient for frozen generated-source semantics |
| Retained14-row method | Actual56 outputs; wrapper/repeat equality and immutable legacy hashes compared by runner before lane publication | Exact compatibility, not an independent efficacy oracle; positive semantic test supplies efficacy |
| O1–O3 | Hand-authored array expectations, typed rejection, single-predicate boundary mutations | Independent metric mechanics; not claimed as facade efficacy |
| F1–F4 | Actual provider/resolver output and independent sampler-equivalent calculation | Fixed-support safety/scaling; no universal mixed-field theorem |
| L1–L4 | Multi-request reset/recovery, source/recovered byte equality, metadata and mapping assertions | Behavioral evidence, not symbol presence |

No disabled/skipped required method, empty handler, circular replacement baseline, or unreferenced TBD/FIXME/XXX marker was found in the reviewed changed implementation/tests/runner. Deliberate empty field returns are fail-closed support rejection with tested paths. Golden arrays use1e−6 scalar tolerance and exact count/falloff assertions; the claim of exact public preservation rests on pixel digests and byte-identical retained code, not on pretending these tolerant golden assertions are bitwise checks.

## Final targeted retained-method closure

All following method bodies were inspected and are passing named records in current CHECKS; no new execution was performed.

| File and method | Concrete assertions |
|---|---|
| `MissingLandmarkDegradationTests.swift:1609` `testPhase35ReviewConflictThresholdCrossingSignedMouthFieldsAreSkippedAndExcluded` | Both width/size signs emit before conflict, then final dropped strengths/emissions are zero; eye/nose survive, mouth skipped, exact scale/count/warnings and redaction. |
| Same file:1675 `testPhase35ReviewConflictThresholdCrossingSignedMouthFieldsKeepSupportedSibling` | Dropped field zero while sibling cap×conflict scale remains and emits; sanitation equality, domains, counts and warnings. |
| Same file:2053 `testMissingMouthSkipsOnlyMouthAndKeepsEyeNoseAndSafeDomainsActive` | Missing-mouth request zeros mouth geometry while eye/nose/color/filter remain active. |
| Same file:2078 `testReusedLandmarksReduceMouthGeometry` | Effective size−0.175, width0.175, smile0.25, lipColor0.50 and stale-reduced warning. |
| Same file:2124 `testPhase38MOUTH08ReusedStaleMissingOuterAndNoFaceApplyPerMouthGeometry` | Reused per-field halves; stale/missing outer/no face zero all five additional mouth fields and skip the domain. |
| Same file:2275 `testStaleLandmarksSkipStrongMouthGeometry` | Size/width/smile zero; color/lipColor retained, stale warning and mouth skip. |
| `MouthWarpProviderTests.swift:44` `testMouthWidthMovesCornersOutwardWithCappedStrength` | Actual source/target outward ordering and cap limits. |
| Same file:111 `testPhase38LegacyMouthEmissionArraysRemainExact` | Literal size/width/smile arrays, radius/strength/falloff; `assertPoints`:515 checks every component/count. |
| `BeautyEngineMouthBaselineTests.swift:29,51` positive/retained methods | Real facade expansion/protection, exact14 rows and source,56 outputs, neutral identity and signed-size distinctions; no static placeholder. |

## Frozen comparator/oracle cross-check

Compared `scripts/compare-face-feature-batches.swift` at `checkedScale/rasterize`:306–328, watermark/clipping/darkness/centroid:557–636, `mouthWidthContraction`:747, `regionSignal`:780 and `semanticMeasurement`:815–940 directly with the previously inspected `MouthBaselineOracle` and `MouthNegativeOracle`. Also compared the literal manifest mouth contract at `scripts/face-feature-batch-manifest.json:221`.

| Rule | Result |
|---|---|
| Raster | Nonnegative checked PPM×extent/1000000 gives floor on both bounds; maxima exclusive. Oracle literal nonintegral tests agree. |
| Span | Weight max(0,65280−77R−150G−29B); moment weight×(2x+1); Q16 centroid divides by weight×2×width; sort two centers then subtract. Positive denominator and checked arithmetic retained. |
| Signal | Max RGB delta>2 counts changed; sum includes all RGB deltas, including≤2. |
| References and sign | Source and neutral checked separately; both margins≤−16. Checking each is equivalent to comparator max(sourceMargin,neutralMargin)≤−16. |
| Siblings | Each of three absolute differences≥16; equivalent to comparator minimum sibling margin. All five comparison names/order remain strict. |
| Numeric/region contract | Exact manifest keys, two targets, four protected groups and thresholds500/2000/16, outside128/512, height/face64/256, background/watermark0/0 match. |
| Clipping | At640px, excluded rows108; oracle rational ceil matches retained formula. Target cannot vanish. Clipped-empty protected region contributes zero; additional full-region pass detects unwatermarked leakage and only strengthens protection. |
| Complete conjunction | Componentwise protection maxima cover both references; no early semantic assertion suppresses another predicate. P emits all17 outcomes before asserting them. |

## History, reviews, owners and finite boundaries

Original prerequisite9/9 remains at its original provider. Negative baseline13/12/1 records height/outside leakage; full original41/39/2 additionally records actual crossing/interior reversal. A41/40/1 fails only source/neutral signal at392<500, while protections and field/lifecycle pass. B follows owned rollback119 and begin120, compile122, seal123, then fresh acceptance166. It measures520/73743/−24 for both references, all siblings distinct and all negative protections0/0. No failure is relabeled as success, and baseline/source/oracle thresholds are not tuned.

The runner's strict schema/duplicate-key handling, hash-linked transition replay, review identity, before/after-child identity, no-repeat measurement, compile-before-seal and B eligibility were inspected. Both freeze reviews and both candidate reviews are strict independent-parent PASS at their bound inputs. Implementation review matches actual report hash in the header with0 blockers/high-security findings. Review role is a local parent-controlled workflow assertion, not a cryptographic human signature.

Native bounds are finite: build/list each600s, named tests60/120/180/360/420s according to manifest; negative lane2490s and full lane4890s with cleanup allowance. Capture is8MiB in memory; helper kills/reaps its owned group and closes pipes on all exit paths. Historical helper code is used for pinned capture/parsing, not replayed as current candidate authority. Existing16/16 runner/72-attack evidence is retained from reviewed authoring; this verification did not rerun self-tests or manufacture new runtime claims.

All seven final owner sections were read and their full hashes checked. DESIGN explains policyB and proof limits; SECURITY binds current versus historical admission and redaction; RELIABILITY records failure/recovery and raw metadata; PRODUCT_SENSE limits owner use to generated CPU evidence; QUALITY_SCORE gives exact counts/history; taxonomy retains existing inventory; PLANS remains `verifying (snapshot before independent goal decision)` with receipt-dependent completion. Historical prerequisite statements remain historical evidence, not overwritten current verdicts.

## Handoff and limits

No required truth remains FAILED or UNCERTAIN in this declared contract. No override, waived predicate or extra human acceptance is needed. No UI or real-device gate is invented. This establishes the frozen owner-local registered generated-source CPU behavior only: not private-portrait/population quality, universal anatomical fidelity, all-orientation semantic contraction, mixed-field/GPU injectivity, device performance, commercial quality or distribution readiness. Phase95 private portraits/final65/full no-skip remain separate and are not claimed complete; FACE-01 remains deferred.

Only this report was written. No source/test/evidence ledger/owner/PLANS/administrative file was edited; no native, old gate, new self-test, research, install or commit was run. No raw pixels, geometry arrays, private locators or child transcripts are included. Serena and dedicated Read/Write tools were unavailable; read-only shell access and the available file patch tool were used. Parent may now run its authorized finalize command; it must validate current report/owner hashes and atomically publish COMPLETE without editing sealed owners. A missing/stale/interrupted completion receipt remains incomplete even with this goal PASS.
