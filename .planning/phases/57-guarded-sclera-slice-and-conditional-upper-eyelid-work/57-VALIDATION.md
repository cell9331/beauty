---
phase: 57
slug: guarded-sclera-slice-and-conditional-upper-eyelid-work
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-08-04
security_standard: OWASP ASVS Level 1
block_on: HIGH
---

# Phase 57 — Validation Strategy

> Validate two independent conditional false branches. The immutable Phase 54
> sclera and upper-eyelid rows are closed, so success is exact absence for both
> candidates plus active rejection of every prohibited `去脂` proxy. No per-eye
> algorithm, non-warp effect, safety/effectiveness result, or image review is
> claimed.

## Test Infrastructure

| Property | Value |
| --- | --- |
| Framework | SwiftPM XCTest, Python standard-library structural/live-fixture mutation checker, existing GSD schema/codebase/UI gates, explicit iOS Simulator Xcode regression |
| Config file | `BeautySDK/Package.swift`; no target, dependency, resource, model, network, storage, or package change |
| Focused SDK suite | `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-phase57-clang-module-cache swift test --package-path BeautySDK --filter 'BeautyParametersTests|BeautyResourceCatalogTests|BeautyRendererOutputRegressionTests|BeautyEngineLocalRetouchFoundationTests'` |
| Focused Demo suite | Explicit iPhone 17e/iOS 26.5 `xcodebuild ... -only-testing:BeautyDemoTests/BeautyDemoViewStateTests test` |
| Boundary checker | `python3 .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/check_phase57_eye_gate_boundaries.py --self-test` plus decision/live/per-threat modes |
| Final-only regression | Full SwiftPM plus explicit iPhone 17e/iOS 26.5 Demo build/test in `57-04-01` only |
| Security | OWASP ASVS Level 1, `block_on: HIGH`; every exact T-57 row must be machine-green before task, plan, phase, or evidence promotion |
| Diff hygiene | `git diff --check` in every task and the final gate |

## Sampling Contract

- Wave 0 extends existing exact compatibility/facade/Demo test owners and
  establishes the structural checker/threat inventory before evidence or owner
  promotion.
- There is no planned production RED/GREEN seam. Clean current fixtures must
  pass; every unauthorized feature/proxy/promotion path must fail only after a
  named real-fixture mutation.
- Waves 1 and 2 use focused decision, candidate, proxy, Demo, privacy, ledger,
  compatibility, and evidence modes. They do not run full SwiftPM or complete
  Demo regression.
- `57-04-01` alone owns full SwiftPM, Demo build/test, GSD gates, exact
  requirement/decision/task/threat traceability, finalized evidence, validation
  promotion, requirement dispositions, and root-owner synchronization.
- Later broad regression never backfills an unrun earlier row. Every row records
  its own actual command/result.
- No task selects files, reads ignored portraits, opens a browser reviewer,
  generates before/mask/after output, or requests human visual judgment.

## Planned Per-Task Verification Map

The planner may regroup files, but it must preserve these seven semantic rows
or update this table one-for-one with the final XML task IDs before plan check.

| Planned task ID | Wave | Requirements | Required focused evidence | Status |
| --- | ---: | --- | --- | --- |
| `57-01-01` | 0 | SCLERA-01, SCLERA-06, LID-02, LID-04 | Exact SDK/facade tests: no canonical/synonym field/CodingKey/SPI/saved-output/admission route, literal `.none`, both still entries, exact 59/5/72, unchanged shipped eye/color behavior and pixel-buffer/reset isolation | pending |
| `57-01-02` | 0 | SCLERA-01..06, LID-02..05 | Exact disabled `eyes.redness`/`eyes.fat` Demo rows, future/future/partial ledgers, proxy independence tests, eight-row HIGH inventory, and representative whole-source live mutations | pending |
| `57-02-01` | 1 | SCLERA-01..06, LID-02..05 | Exact identity-selected Phase 54 sclera/eyelid rows, independent reason/count/design semantics, malformed/missing/duplicate/renamed/competing input mutations | pending |
| `57-02-02` | 1 | SCLERA-01..06 | Complete whole-production sclera canonical/synonym/provider/renderer/preset/admission/Demo mutations; SCLERA false-branch/N/A/no-promotion evidence draft | pending |
| `57-03-01` | 2 | LID-02..05 | Complete whole-production upper-eyelid canonical/synonym and neutral-file mutations plus affirmative LID-04 proxy-coupling rejection while shipped eye domains remain intact | pending |
| `57-03-02` | 2 | SCLERA-01..06, LID-02..05 | Complete structural evidence/privacy/Demo/ledger/compatibility/scanner matrix and combined two-row draft projection with no cross-feature borrowing | pending |
| `57-04-01` | 3 | SCLERA-01..06, LID-02..05 | Final focused/checker/full SwiftPM/Demo/schema/UI/codebase/diff/ASVS/traceability/owner gate; finalize evidence and validation only after every row is current green | pending |

Task count target: **7 XML task IDs = 7 validation rows = 2 Wave 0 + 4
focused enforcement tasks + 1 final closeout**.

## Wave 0 Deliverables

- [ ] Existing SDK tests pin both canonical candidate names and context-specific
  synonyms without duplicating the complete 59/5/72 inventories.
- [ ] Facade tests pin literal `.none`, both CIImage entries, no-admission output
  and diagnostics, unrelated shipped effects, recovery, and pixel-buffer/reset
  zero work.
- [ ] Demo tests preserve the exact disabled `eyes.redness` and `eyes.fat` rows,
  order/badges/copy, nil active mappings, and existing shipped eye controls.
- [ ] Tests explicitly preserve independent `eyeHeight`, `upperEyelidLift`,
  brow, smoothing, dark-circle, and eye-bag behavior while rejecting any source,
  label, mapping, or evidence coupling to upper-eyelid fullness/`去脂`.
- [ ] `check_phase57_eye_gate_boundaries.py` uses structural finalized-evidence
  parsing, tri-state scanners, complete production Swift scanning including new
  neutral filenames, stable rule-only output, and real-fixture mutations.
- [ ] `57-THREAT-INVENTORY.json` pins ordered T-57-01..08 identities and
  executable gates; no count-only validation exists.

## Requirement Dispositions

| Requirement | Exact closed-gate disposition |
| --- | --- |
| SCLERA-01 | `false_branch_exact_absence` — no independent public/internal/runtime/saved-output route or alias |
| SCLERA-02 | `not_applicable_closed_gate` — no per-eye support/envelope/scoring/feather/reclip implementation claim |
| SCLERA-03 | `not_applicable_closed_gate` — no iris/pupil/highlight/lash/skin containment result claim |
| SCLERA-04 | `not_applicable_closed_gate` — no redness effectiveness/naturalness claim |
| SCLERA-05 | `not_applicable_closed_gate` — no blink/gaze/eyewear/one-eye classifier or abstention claim |
| SCLERA-06 | `no_promotion` — SDK/evidence/privacy/regression/Demo/ledger owners agree |
| LID-02 | `closed_branch_exact_absence` — no field/provider/renderer/inert route; `去脂` future and `眼睛` partial |
| LID-03 | `not_applicable_closed_gate` — no non-warp effect, geometry/texture/identity preservation claim |
| LID-04 | `proxy_rejection_enforced` — existing eye geometry/color domains remain independent and cannot be substituted or coupled |
| LID-05 | `not_applicable_closed_gate` — no admitted facade/naturalness/privacy/output/promotion claim |

## Exact Absence, Proxy, and Compatibility Matrix

| Group | Required cases |
| --- | --- |
| Authorities | Exact unique `sclera_redness` row with two ordered missing reasons and zeros; exact unique `upper_eyelid_fullness` row with two missing reasons plus `non_warp_design_unqualified` and zeros; no sibling/teeth borrowing |
| Public surface | No canonical/synonym stored field, initializer, CodingKey, encoded/default/reflection key, public/SPI candidate, saved-output helper, provider, transform, renderer, preset, resource, model, dependency, or inert route |
| Sclera aliases | Reject eye/conjunctiva/ocular/bloodshot/red-eye/sclera-whitening candidate routes and aliases to global whitening, brightness, skin color, eye geometry, or teeth |
| Eyelid aliases | Reject lid/eyelid fat/fullness removal routes and aliases to other candidates or generic Testing mechanics |
| LID-04 proxies | Preserve shipped `eyeHeight`, `upperEyelidLift`, brow translation, smoothing, dark-circle, eye-bag, aperture/warp domains; reject any coupling/name/comment/mapping/evidence that represents them as `去脂` |
| Runtime/compatibility | Literal `.none`; exact 59 stored/CodingKey fields, five presets/hashes, 72 renderer cases; both still facades/no-admission behavior unchanged; no realtime/pixel-buffer/reset local work |
| Demo | Exact disabled `eyes.redness` / `祛红血丝` and `eyes.fat` / `去脂` rows and order/badges; no active control/binding/store/processor/reset/availability route |
| Ledgers | Exact `祛红血丝 = future`, `去脂 = future`, branch `眼睛 = partial`; no branch closure or feature/sibling borrowing |
| Evidence | Ten exact dispositions, structural finalized state, fixed IDs/status/reasons/counts only, explicit no-algorithm/safety/effectiveness/naturalness/image/readiness claims |

## ASVS Level 1 HIGH Inventory

| ID | Threat | Required mitigation/evidence |
| --- | --- | --- |
| T-57-01 | Decision authority tampering/cross-feature borrowing | Exact two-row identity/shape/reason/count parser and complete malformed/missing/duplicate/renamed/competing/independence mutations |
| T-57-02 | Sclera public/production activation or alias | Whole-production canonical/synonym scan, neutral-file provider/transform mutations, literal `.none`, saved-output/preset/Demo absence |
| T-57-03 | Upper-eyelid public/production activation or alias | Whole-production lid/fat/fullness scan, neutral-file mutations, no field/provider/renderer/preset/admission/Demo route |
| T-57-04 | Warp/smoothing/eye-feature proxy substitution | Exact shipped-domain allowlist plus coupling mutations for eyeHeight, upperEyelidLift, brow, smoothing, eye-bag, dark-circle, aperture, and warp |
| T-57-05 | Demo activation hidden behind future taxonomy | Exact two disabled rows and mutations for control/binding/store/processor/reset/enabled availability/order/copy drift |
| T-57-06 | Eye-support/evidence privacy disclosure | Fixed allowlist; reject portrait/review/right paths, eye/pupil/iris/landmark/mask/vein/pixel/digest/raw-match/raw-error data |
| T-57-07 | Ledger promotion or sibling/teeth borrowing | Exact future/future/partial rows and product-owner statements; promotion/branch closure/borrow mutations fail |
| T-57-08 | Compatibility/evidence/scanner failure misclassified as green | Exact 59/5/72/facade/test anchors, structural finalized evidence, missing/parse/scanner/unclassified failures, diff/full regression |

Every plan must declare ASVS Level 1 and `block_on: HIGH`. A failed, skipped,
unrun, stale, waived, count-only, or unclassified HIGH result blocks its task,
plan, phase, evidence, and owner promotion.

## Forbidden Source, Claim, and Privacy Surface

The checker must fail closed on:

- canonical or synonym candidate/API/Codable/SPI/admission/provider/support/
  transform/render-plan/renderer/preset/resource/dependency/model/network/
  storage/realtime/pixel-buffer/reset/inert routes in any production Swift file,
  including newly added neutral filenames;
- coupling sclera to global whitening/brightness/skin/eye geometry/teeth or
  coupling upper-eyelid fullness to eyeHeight/upperEyelidLift/brow/warp/
  smoothing/dark-circle/eye-bag behavior;
- deletion/activation of legitimate disabled Demo rows, promotion of either
  future row, closure of `眼睛`, or cross-feature/sibling evidence borrowing;
- public/durable/logged portrait, review, grant, eye/pupil/iris/landmark,
  coordinate, mask, vein-like descriptor, pixel, output digest, raw match/error;
- positive algorithm, containment/safety, effectiveness/naturalness, image,
  device/performance, commercial, packaging, shipping, launch, or release claim;
- weakening exact assertions, lifecycle downgrade/pending/contradictory
  evidence, missing required fixtures, malformed JSON/frontmatter, scanner
  exceptions, or unclassified subprocess outcomes.

## Final-Only Phase Gate

Task `57-04-01` must execute and record:

1. Swift/Python/JSON syntax and test discovery.
2. Complete focused SDK and Demo exact-absence/proxy/compatibility suites.
3. Checker decision, aggregate, live, and every exact T-57 mode.
4. Existing Phase 53 foundation, Phase 55 composition, and Phase 56 absence
   regressions needed to prove no route/alias/proxy was activated.
5. Full `swift test --package-path BeautySDK` in the known-good host context.
6. Explicit iPhone 17e/iOS 26.5 Demo build and full test.
7. GSD schema/UI/decision/post-plan gates; separately accept only the historical
   `PRODUCT_SENSE.md`, `example-images`, `meituxiuxiu` codebase warning.
8. Exact 7 task / 10 requirement / 20 decision / 8 HIGH / compatibility /
   candidate / proxy / Demo / ledger / privacy / owner equality.
9. `git diff --check`.
10. Finalize `57-CLOSED-EYE-GATES-EVIDENCE.md`, promote all validation rows,
    record canonical conditional dispositions, and synchronize root owners only
    after every preceding result is current green.

## Validation Sign-Off

- [ ] Final PLAN XML task count equals seven validation rows.
- [ ] Wave 0 tests/checker accept clean fixtures and reject every named live
  mutation, including neutral-file candidates and semantic proxy coupling.
- [ ] All ten requirements have exact honest conditional dispositions.
- [ ] Every T-57 HIGH identity is individually machine-green with no waiver.
- [ ] Literal `.none`, 59/5/72, both facades, disabled Demo rows, and
  future/future/partial ledgers remain exact.
- [ ] No sensitive support/output, candidate route, human/image review, or
  unsupported product/readiness claim is added.
- [ ] Full SwiftPM and explicit Demo regression pass in the known-good host.
- [ ] Canonical evidence exists with actual results before validation/owner
  promotion.

**Approval:** pending seven task rows, ten requirements, twenty decisions, eight
HIGH mitigations, focused/final regressions, and synchronized owner evidence.
