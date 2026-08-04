---
phase: 58
status: validated
nyquist_compliant: true
asvs_level: 1
block_on: HIGH
plans: 4
tasks: 7
human_verification: none
---

# Phase 58 Validation Strategy

## Purpose

Validate the v1.14 zero-admission closeout without inventing feature output.
All three Phase 54 visible-feature gates are closed, so OUT-01 and OUT-02 are
exact not-applicable absence branches. SAFE-01..03, OUT-03, and OUT-04 remain
affirmative automated obligations.

No validation task selects a file, opens a browser, generates comparison
images, requests original-detail inspection, or asks for human judgment.

## Test Infrastructure

| Layer | Command / owner |
| --- | --- |
| Focused SDK | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-phase58-clang swift test --package-path BeautySDK --filter 'BeautyCanonicalStillImageTests|BeautyEngineLocalRetouchFoundationTests|BeautyLocalRetouchCompositionTests|BeautyEngineLocalRetouchCompositionTests|BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|StillImageRequestSupportTests'` |
| Focused Demo | Explicit iPhone 17e/iOS 26.5 `xcodebuild ... -only-testing:BeautyDemoTests/BeautyDemoViewStateTests test` |
| Phase 58 oracle | `check_phase58_milestone_closeout.py --self-test`, live, decision, lifecycle, and per-threat modes |
| Frozen Phase 57 | Current decision/sclera/eyelid modes green; current default exactly fixed `R57-COMPAT`; 519 self-test from verified pre-transition revision `4125b75`; current checker bytes equal the frozen revision |
| Full SwiftPM | Final task only: unfiltered `swift test --package-path BeautySDK` |
| Opt-in Vision | Final task only: `BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 ... swift test --package-path BeautySDK --jobs 1 --filter testIntegration`; require exactly 6 executed, 0 skipped, 0 failed |
| Full Demo | Final task only: explicit iPhone 17e/iOS 26.5 build and full test |

The checker and any subprocess adapter emit only fixed rule IDs, modes, status,
and aggregate counts. They never emit source matches, fixture/image names,
temporary paths, raw stderr, geometry, pixels, or reviewer data.

## Planned Per-Task Verification Map

The planner must preserve exactly these seven semantic rows and synchronize XML
task IDs one-for-one.

| Planned task ID | Wave | Requirements | Required focused evidence | Status |
| --- | ---: | --- | --- | --- |
| `58-01-01` | 0 | SAFE-01..03, OUT-01, OUT-02, OUT-04 | Freeze focused SDK specifications for privacy shape, request-local sequences, cancellation publication discard, deterministic closed-set no-op, exact absence of candidate/pair/output routes, literal `.none`, 59/5/72, and both facades | passed |
| `58-01-02` | 0 | SAFE-01..03, OUT-01..04 | Freeze exact three disabled Demo rows/nil mappings, create ordered T-58-01..08 HIGH inventory, configurable-root checker with representative real-fixture mutations, and draft fixed-ID evidence | passed |
| `58-02-01` | 1 | SAFE-02, SAFE-03 | Complete repeated, valid-invalid-valid, independent parallel, serialized same-harness, no-face, missing/malformed, throw/recovery, unrelated-effect, canceled-publication-discard, and fresh-request lifecycle matrix without TD-013/cooperative-abort claims | passed |
| `58-02-02` | 1 | SAFE-01, SAFE-03, OUT-01, OUT-02, OUT-04 | Complete privacy/no-op/typed-error/canonical/59-5-72/facade/non-still, output/helper/gallery/review absence, Demo/ledger zero-promotion, persistence/network/resource/artifact, and scope-nonclaim matrices | passed |
| `58-03-01` | 2 | SAFE-01..03, OUT-03 | Strict completed-state adapter: freeze Phase 57 checker bytes, three green modes, 519 pre-transition self-test, exact current default R57-COMPAT, and exact current owner/evidence/ledger lifecycle | passed |
| `58-03-02` | 2 | SAFE-01..03, OUT-01..04 | Complete every HIGH live mutation, missing/unreadable/scanner/raw-error case, Phase 58 evidence lifecycle, current owner equality, aggregate/per-threat modes, and draft evidence totals | passed |
| `58-04-01` | 3 | SAFE-01..03, OUT-01..04 | Final-only focused/checker/Phase53-58/full SwiftPM/6-test opt-in Vision/full Demo/privacy/resource/network/artifact/GSD/traceability/diff/ASVS/owner gate; validate evidence, requirements, root owners only after current green | passed |

Task count target: **7 XML tasks = 7 validation rows = 2 Wave 0 + 4
focused enforcement tasks + 1 final closeout task**.

## Wave 0 Deliverables

- [x] XCTest freezes the exact empty admitted-feature set without adding a
  production candidate seam.
- [x] Cancellation is host publication discard around one intact synchronous
  Testing invocation, followed by zero-retention fresh work.
- [x] Existing canonical, request, composition, compatibility, and Demo owners
  gain only Phase 58 boundary assertions; legitimate shipped color/geometry
  behavior remains allowed.
- [x] `58-THREAT-INVENTORY.json` has ordered unique T-58-01..08 identities,
  ASVS Level 1, and `block_on: HIGH`.
- [x] `check_phase58_milestone_closeout.py` supports configurable-root
  real-fixture mutation, tri-state scanning, fixed-rule subprocess output, and
  no count-only success.
- [x] Draft evidence records only fixed identities, dispositions, aggregate
  counts, and explicit nonclaims.

## Requirement Dispositions

| Requirement | Exact Phase 58 disposition |
| --- | --- |
| SAFE-01 | `privacy_boundary_enforced` |
| SAFE-02 | `request_local_nonretention_enforced` |
| SAFE-03 | `closed_set_noop_compatibility_enforced` |
| OUT-01 | `not_applicable_zero_admitted_features_exact_absence` |
| OUT-02 | `not_applicable_zero_admitted_pair_exact_absence` |
| OUT-03 | `full_automated_audit_and_independent_verification` |
| OUT-04 | `zero_row_promotion` |

OUT-03 phase evidence may record the automated gate as green, but phase
transition remains blocked until the separate review/fix workflow and
independent `gsd-verifier` pass. No feature row is promoted before then—or at
all in the zero-admission branch.

## Exact Closeout Matrix

| Group | Required cases |
| --- | --- |
| Admission authority | Exact three Phase 54 rows, ordered reasons, zero counts/weight, no sibling borrowing, literal `.none` |
| Public/production absence | No candidate field/CodingKey/SPI/admission/provider/transform/renderer/preset/resource/model/dependency/saved-output/helper/gallery/review/inert or combined route across all production Swift files |
| Request lifetime | Repeated, valid-invalid-valid, independent parallel, same-harness serialization, no-face, missing/malformed, throw/recovery, unrelated continuation, canceled publication discard, fresh request |
| Privacy | No support/geometry/pupil/mask/pixel/reviewer/path/digest/raw match/error in public/SPI/Codable/persistence/network/log/metric/artifact/evidence surfaces |
| Canonical/no-op | Dimensions, orientation, opaque alpha, sRGB, typed payload-free errors, deterministic no-op bytes, safe-domain continuation |
| Compatibility | Exact 59 stored/CodingKey fields, five presets, 72 renderer cases, both CIImage facades, zero candidate names, pixel-buffer/reset isolation |
| Mechanics | Phase 55 package-/Testing-only feature-neutral composer unchanged; collision/source/reclip/abstention proof receives no feature label or effectiveness credit |
| Demo/ledgers | Exact three disabled rows/nil mappings; `白牙`/`祛红血丝`/`去脂 = future`; `嘴唇`/`眼睛 = partial`; zero promotion |
| Phase 57 lifecycle | Frozen checker unchanged; current green decision/sclera/eyelid; exact current R57-COMPAT; verified 519 pre-transition self-test; completed owners/evidence/ledgers exact |
| Scope | No browser/image/human, realtime retouch, tracked media, TD-013, device/commercial/performance/packaging/shipping/launch/release claim |

## ASVS Level 1 HIGH Inventory

| ID | Threat | Required mitigation/evidence |
| --- | --- | --- |
| T-58-01 | Authority tampering or unauthorized admission | Exact three decisions/zero totals/literal `.none`; missing/duplicate/renamed/nonzero/borrowed/neutral activation mutations |
| T-58-02 | Sensitive support/image/reviewer/path/raw-error disclosure | Public/SPI/Codable/persistence/network/log/metric/evidence/artifact scans and prose/table/subprocess mutations with fixed output |
| T-58-03 | Request-state retention, crossing, or cancellation overclaim | Full SAFE-02 XCTest lifecycle, publication-discard semantics, fresh request, no TD-013/cooperative-abort wording |
| T-58-04 | Canonical/no-op/error/facade/59-5-72/non-still drift | Focused executable owners plus recursive current-source and compatibility mutations |
| T-58-05 | False OUT-01/OUT-02 positive claim or mechanics relabeling | Exact candidate output/pair/helper/gallery/review absence, explicit N/A dispositions, reject feature-named opaque mechanics |
| T-58-06 | Demo or ledger promotion of closed rows/branches | Exact disabled rows/nil mappings/future-future-future/partial-partial/zero-promotion owner mutations |
| T-58-07 | Frozen Phase 57 checker/owner/completed lifecycle weakened | Byte comparison, three green modes, verified 519 fixture, exact current R57-COMPAT, owner deletion/duplication/count/lifecycle mutations |
| T-58-08 | Evidence/scanner/final gate/owner equality fails open | Exact schema, missing/unreadable/unclassified/raw-stderr cases, aggregate/per-threat identities, opt-in Vision six/no-skip, root equality |

Every plan declares OWASP ASVS Level 1 and `block_on: HIGH`. Failed, skipped,
unrun, stale, waived, count-only, or unclassified HIGH evidence blocks its task,
plan, phase, owner promotion, phase verification, and milestone handoff.

## Final-Only Phase Gate

Only `58-04-01` may run or claim:

1. Unfiltered full SwiftPM.
2. Separate opt-in Vision integration with exactly six executed, zero skipped,
   zero failed.
3. Explicit iPhone 17e/iOS 26.5 Demo build and full tests.
4. Complete Phase 53–58 checkers, privacy/resource/network/artifact scans,
   GSD schema/UI/decision/traceability gates, diff hygiene, and root equality.
5. Validated evidence, requirement/root synchronization, and readiness for the
   separate code review/fix plus independent verifier.

The known historical `PRODUCT_SENSE.md`, `example-images`, and `meituxiuxiu`
codebase-map warning remains nonblocking only if its path set is exact and no
new structural drift appears.

## Validation Sign-Off

- [x] Four serial plans contain exactly seven XML tasks and seven validation rows.
- [x] All seven dispositions and all twenty decisions have executable owners.
- [x] All eight HIGH identities are individually machine-green with no waiver.
- [x] Phase 57 completed-state audit is strict without changing the frozen checker.
- [x] Full SwiftPM, six-test opt-in Vision, and full Demo are current green.
- [x] Zero feature rows and zero branches are promoted.
- [x] No sensitive payload, image/human review, or unsupported scope claim exists.
- [x] Canonical evidence and root owners synchronize only after every prior gate.

**Approval:** Automated execution is validated for seven task rows, seven
requirements, twenty decisions, eight HIGH mitigations, full regression, and
owner gates. External review/fix and independent verification are the next
lifecycle gates.
