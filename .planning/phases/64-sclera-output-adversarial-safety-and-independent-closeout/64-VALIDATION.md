---
phase: 64
slug: sclera-output-adversarial-safety-and-independent-closeout
status: gaps_found
validation_status: gaps_found_requarantined
nyquist_compliant: false
nyquist_pending: true
candidate_owner: phase64_plan_18_candidate_passed
final_transaction_owner: phase64_plan_19_failed_requarantined
expected_plan_count: 19
expected_task_count: 34
accounted_tasks: 34
successful_tasks: 32
pending_tasks: []
historical_failed_tasks: [64-13-01]
current_failed_tasks: [64-19-01]
inventory:
  plans: 19
  tasks: 34
  accounted_tasks: 34
  successful_tasks: 32
  pending_tasks: []
  historical_failed_tasks: [64-13-01]
  current_failed_tasks: [64-19-01]
created: 2026-08-07
updated: 2026-08-10
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05]
canonical_verification: gaps_found_requarantined
---

# Phase 64 - Validation Strategy (19 plans / 34 task IDs)

Phase 64 has exactly **19 serial plans and 34 ordered task IDs**. Plans 01-13
remain immutable executed format-grandfathered inputs whose exact waves,
dependencies, task IDs, summaries, requirements, and evidence are still
required. Plan 12's immutable `gaps_found` candidate and Plan 13's full
re-quarantine remain historical failed/superseded evidence. Plans 14-17 account
for the repair, fresh authority, nine-owner synchronization, and lifecycle
snapshot. Plan 18's distinct candidate passed. Plan 19 executed the mandatory
failure branch: final success failed because the required canonical-owner
transition changes a candidate-frozen input hash, and the complete fifteen-owner
set was re-quarantined. All 34 IDs are accounted, but this is not a successful
all-task closeout and grants no canonical success.

| Task ID | Plan | Wave | Requirements | Focused command / gate | Evidence artifact | Nyquist status |
| --- | --- | ---: | --- | --- | --- | --- |
| 64-01-01 | 01 | 1 | SCLERA-16, SCLERA-17, OUT-05 | RED renderer + strict helper contract; `check_sclera_renderer_outputs.py --self-test` (14/14) | `64-01-SUMMARY.md` — exact renderer/helper RED contract | executed |
| 64-01-02 | 01 | 1 | SCLERA-14, SCLERA-15, SCLERA-18 | Eight-HIGH pre/post promotion checker; `--self-test` 8/8; `--pre-promotion` 8/8 | `64-01-SUMMARY.md` — 5/5 adversarial contracts and 8/8 HIGH checker mutations | executed |
| 64-02-01 | 02 | 2 | SCLERA-17, OUT-05 | Exact 74-case public renderer; 21/21 regression; 148-file gallery self-test | `64-02-SUMMARY.md` — exact 74-case inventory | executed |
| 64-02-02 | 02 | 2 | SCLERA-16, SCLERA-17, OUT-05 | Required private public-facade 6/6 decoded output passes | `64-02-SUMMARY.md` — six private outputs | executed |
| 64-03-01 | 03 | 3 | SCLERA-14, SCLERA-15 | 5/5 geometry/recolor/peer/recovery, 11/11 provider and 9/9 facade | `64-03-SUMMARY.md` — both protected-anatomy oracles | executed |
| 64-03-02 | 03 | 3 | SCLERA-16, SCLERA-18 | Fresh four-item original-detail pass and 8/8 HIGH closed | `64-03-SUMMARY.md` — fresh original-detail review | executed |
| 64-04-01 | 04 | 4 | SCLERA-18 | Full pre-promotion conjunction and exact owner update | `64-04-SUMMARY.md` — full conjunction | executed |
| 64-04-02 | 04 | 4 | SCLERA-14...18, OUT-05 | Independent post-promotion verification (superseded; canonical reverted to `gaps_found`) | `64-04-SUMMARY.md` — post-promotion re-run | executed (subsequently superseded by `gaps_found`) |
| 64-05-01 | 05 | 5 | SCLERA-14, SCLERA-15, SCLERA-18 | Quarantine the stale `祛红血丝` promotion: ledger, matrix, branch detail, branch table row → future/unproven | `64-05-SUMMARY.md` — five `祛红血丝` rows re-quarantined; byte-identical unrelated product lines | executed |
| 64-05-02 | 05 | 5 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Owner equality after quarantine: `--pre-promotion --threat T-64-07` 8/8 HIGH; tracked/staged privacy intact | `64-05-SUMMARY.md` — owner equality passed | executed |
| 64-06-01 | 06 | 6 | SCLERA-14, SCLERA-15 | Full bilateral truth: 6 protected families × 2 eyes, 1632 protected pixels; 23 accepted + 4 rejected scenarios | `64-06-SUMMARY.md` — full bilateral oracle | executed |
| 64-06-02 | 06 | 6 | SCLERA-14, SCLERA-15, OUT-05 | Actual-proposal intersection; 744 actual proposals / 0 protected intersections / 0 byte mismatches / 0 outside mismatches | `64-06-SUMMARY.md` — direct proposal intersection | executed |
| 64-07-01 | 07 | 7 | SCLERA-14, SCLERA-15 | Reinstate the exact right-eye +0.004/-0.006/+0.003 historical leak; 3x3x3 neighborhood sweep accepted/rejected boundary | `64-07-SUMMARY.md` — historical leak counterexample | executed |
| 64-07-02 | 07 | 7 | SCLERA-14, SCLERA-15 | Inclusive contour validity: 27 scenarios (11 left + 11 right perturbations + 4 rejected-boundary); bilateral full-resolution truth | `64-07-SUMMARY.md` — inclusive contour validity | executed |
| 64-08-01 | 08 | 8 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Four-state content scanning: tracked 1465 / staged 1465 / working ≤ committed-by-this-plan / untracked 0; `scan_repository_content` self-test ≥18 | `64-08-SUMMARY.md` — four-state content scan | executed |
| 64-08-02 | 08 | 8 | SCLERA-16, SCLERA-18 | Source-bound review authority: tree OID `2fb1c37e`; manifest re-verified by `validate_review_source_state`; strict helper live child separation | `64-08-SUMMARY.md` — source-bound review and visible strict-helper live | executed |
| 64-09-01 | 09 | 9 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05 | Frozen full conjunction rerun: focused 73/73, private 6/6, strict helper 14/14, full SwiftPM 636, Demo 121/121 | `64-09-SUMMARY.md` and `64-SCLERA-OUTPUT-EVIDENCE.md` — frozen conjunction | executed |
| 64-09-02 | 09 | 9 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Fresh zero-HIGH code review + fresh zero-HIGH ASVS L1 audit; independent non-canonical `eligible_promotion_pending` (D-01..D-18) | `64-PRE-PROMOTION-VERIFICATION.md` — independent eligibility | executed (eligible_promotion_pending) |
| 64-10-01 | 10 | 10 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, OUT-05 | Four exact product owners: `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, `features/beauty-shaping/README.md`, `features/beauty-shaping/eyes/README.md` | `64-10-SUMMARY.md` — product owner synchronization | executed (promotion-pending) |
| 64-10-02 | 10 | 10 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Five exact root contracts: `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`; promotion-pending only | `64-10-SUMMARY.md` — root contract synchronization | executed (promotion-pending) |
| 64-11-01 | 11 | 11 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Four lifecycle owners: `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` agree on 13 plans / 24 task IDs and next edge to Plan 12 candidate + Plan 13 bounded final transaction | `64-11-SUMMARY.md` — lifecycle synchronization | executed (promotion-pending) |
| 64-11-02 | 11 | 11 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Validation inventory rebuilt to exactly 24 ordered task IDs with `validation_status: promotion_pending_candidate`; 64-12-01 / 64-13-01 explicitly pending; no twenty-four rows or final status claimed | `64-11-SUMMARY.md` — validation inventory | executed (promotion-pending) |
| 64-12-01 | 12 | 12 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Independent post-promotion candidate: exact 13/24 inventory, 15 input owners, 9 immutable owners, fresh conjunction | `64-POST-PROMOTION-CANDIDATE-VERIFICATION.md` — checker self-test failed; full SwiftPM had 8 skips | executed — `gaps_found`; requires re-quarantine; no success authority |
| 64-13-01 | 13 | 13 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05 | Bounded final transaction selected mandatory failure branch from immutable candidate | `64-13-SUMMARY.md` plus canonical verification and complete 15-owner failure set | historical failed/superseded evidence — accounted, not a current unresolved task |
| 64-14-01 | 14 | 14 | SCLERA-18 | `node 64-no-skip-swiftpm-runner.js --self-test` → 14 fail-closed mutations pass; live child later records exact 637/0/0/8 | `64-14-SUMMARY.md` — privacy-safe one-child no-skip runner | executed |
| 64-14-02 | 14 | 14 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | `python3 check_phase64_sclera_closeout.py --self-test` → 18 self-tests / 23 content / 28 source / 20 candidate rejections; 19 plans / 34 tasks / 8 threats / 7 states | `64-14-SUMMARY.md` — strict source-bound checker repair | executed |
| 64-15-01 | 15 | 15 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05 | Exact serial conjunction → focused 74/74; helper 14/14; private 6/6 plus four opaque items; full SwiftPM 637/0/0/8; Demo build and 121/0/0; zero-HIGH reviews | `64-15-SUMMARY.md` and six fresh post-repair authority artifacts | executed |
| 64-15-02 | 15 | 15 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | `--pre-promotion` plus isolated T-64-01...T-64-08 pass against distinct `eligible_promotion_pending` | `64-POST-REPAIR-PRE-PROMOTION-VERIFICATION.md` and `64-15-SUMMARY.md` | executed — non-canonical eligibility only |
| 64-16-01 | 16 | 16 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, OUT-05 | Exact product-row scans plus `--promotion-pending-verification --threat T-64-07` pass | `64-16-SUMMARY.md` — four bounded product owners | executed — promotion-pending |
| 64-16-02 | 16 | 16 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Six-artifact/root-boundary scans plus `--promotion-pending-verification --threat T-64-07` pass | `64-16-SUMMARY.md` — five bounded root contracts | executed — promotion-pending |
| 64-17-01 | 17 | 17 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Exact lifecycle scan and independent table parse → 19 plans / 34 unique ordered IDs / two pending; canonical remains gaps | `64-17-SUMMARY.md` — four lifecycle owners | executed/accounted — promotion-pending |
| 64-17-02 | 17 | 17 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05 | Complete `--promotion-pending-verification` and isolated T-64-01...T-64-08 pass against this exact ledger | `64-VALIDATION.md` and `64-17-SUMMARY.md` | executed/accounted — promotion-pending candidate snapshot |
| 64-18-01 | 18 | 18 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05 | Guarded distinct verifier conjunction, `--validate-candidate`, and isolated threats | `64-POST-REPAIR-CANDIDATE-VERIFICATION.md` | executed/accounted — `candidate_passed`; non-canonical |
| 64-19-01 | 19 | 19 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05 | Staged final owner transition rejected by frozen candidate input hash; complete quarantine and all isolated threats required | canonical verification, this ledger, and fifteen-owner transaction | failed / requarantine — final success not achieved |

Task count target: **34 task IDs = 34 validation rows**. Every ID is accounted,
but Plan 64-19's final-success outcome failed and the phase remains incomplete.

## Historical Failed/Superseded Evidence

- Plan 64-12 remains the immutable historical `gaps_found` candidate: its
  checker self-test failed and its bare full SwiftPM command reported eight
  skips. Neither condition is waived or reinterpreted.
- Plan 64-13 remains the historical mandatory full-requarantine transaction.
  Its failed outcome is preserved as evidence, while Plans 64-14 through 64-17
  establish a distinct repair authority chain.
- Current plan-structure validation applies to Plans 14-19. Plans 01-13 remain
  format-grandfathered only; their exact waves, dependencies, ordered task IDs,
  summaries, requirements, evidence, and serial edges remain mandatory.

## Current Source-Backed Coverage

- SCLERA-14 adjacency/empty/ordering: exact 27 scenarios, intended-endpoint-only
  adjacency, 744 proposals, 1,632 protected truth/recolored pixels, both eyes,
  and all six protected families.
- SCLERA-15 boundary/precision: zero protected intersections, protected byte
  mismatches, outside-proposal byte mismatches, proposal-count mismatches, and
  rejected-eye proposals at RGBA-byte precision.
- SCLERA-16 boundary/precision: positive, negative, and no-face rows satisfy
  their distinct frozen channel/luminance/texture/no-op envelopes.
- SCLERA-17 unclassified: all six decoded output roles are explicit and bounded;
  helper self-test and live helper are distinct green child invocations.
- SCLERA-18 adjacency/empty/ordering: focused 74/74, helper 14/14, private 6/6,
  four opaque review items, checker/no-skip self-tests, exact full SwiftPM
  637/0/0 with all eight opt-ins, Demo build, and Demo 121/0/0 form one serial
  conjunction with no missing, zero, failed, conditional, or skipped stage.
- OUT-05 adjacency/empty/ordering/concurrency: public/private paths remain
  non-coupled, six decoded and four opaque outputs are nonempty and fixed-order,
  and request-local work roots recover independently.
- T-64-01 through T-64-08 are zero-HIGH under the exact 19-source freeze and
  fifteen-owner promotion-pending state.

## Failed Final Authority

- `64-18-01` produced the distinct immutable `candidate_passed` artifact; it is
  non-canonical and remains unchanged.
- `64-19-01` selected the mandatory failure/requarantine branch after the
  staged final owner transition invalidated a candidate-frozen input hash.
- Canonical `64-VERIFICATION.md` remains `gaps_found` with
  `promotion_status: unproven`; this document is not `passed`.
- Phase 65 remains blocked with its verification/audit stale. DeviceRGB/named-
  sRGB remains exclusively Phase 65 SAFE-06 scope.

## Re-Quarantine Disposition

- Exactly 34 ordered task IDs are accounted; Plan 19's final-success outcome is
  failed/requarantined and the phase remains incomplete.
- Historical `64-13-01` remains explicit failed/superseded evidence but is not a
  current unresolved task.
- Product/root owners record `祛红血丝` future/unproven, aggregate `眼睛`
  partial, and `去脂` future under the complete fifteen-owner quarantine.
- Failed, skipped, zero-count, conditional, stale, malformed, or missing
  mandatory gates still prevent candidate or final authority.
