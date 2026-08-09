---
phase: 64
slug: sclera-output-adversarial-safety-and-independent-closeout
status: gaps_found
validation_status: incomplete
nyquist_compliant: false
nyquist_pending: true
candidate_owner: phase64_plan_12
final_transaction_owner: phase64_plan_13
inventory:
  plans: 13
  tasks: 24
  executed_tasks: 23
  failed_tasks: ["64-13-01"]
created: 2026-08-07
updated: 2026-08-09
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05]
canonical_verification: gaps_found
---

# Phase 64 - Validation Strategy (13 plans / 24 task IDs)

Phase 64 inventory remains **13 plans and 24 ordered task IDs** in deterministic order
spanning the original four-plan closeout chain (Plans 01-04) and the nine-plan
gap-closure replacement chain (Plans 05-13). Plans 64-01 through 64-11 retain
their exact execution evidence. Plan 64-12 produced an immutable `gaps_found`
candidate. Plan 64-13 selected the mandatory failure branch and re-quarantined
all fifteen owners; its task row is failed/requarantined, so validation is
incomplete and no final Nyquist or product authorization exists.

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
| 64-13-01 | 13 | 13 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05 | Bounded final transaction selected mandatory failure branch from immutable candidate | `64-VERIFICATION.md` plus complete 15-owner failure set | **failed / requarantined** — validation remains incomplete |

Task count target: **24 task IDs = 24 validation rows**.

## Failed Final Gates

- Counterexample/sweep (SCLERA-14): right-eye +0.004/-0.006/+0.003 historical tuple + 3x3x3 neighborhood + inclusive contour 27-scenario sweep
- Inclusive contour coverage (SCLERA-14): 11 left + 11 right perturbations + 4 rejected-boundary, bilateral full-resolution truth per family
- Four-state privacy / source freeze (T-64-06): tracked / staged / working / untracked, with `validate_review_source_state` binding
- Distinct helper live child (T-64-02): strict helper self-test and live output use separate child invocations
- Complete fresh test/audit/review conjunction (SCLERA-18 / T-64-05 / T-64-07): checker self-test failed and the mandatory full SwiftPM command reported 8 skips; either condition blocks finality
- Owner / lifecycle synchronization (T-64-07 / T-64-08): 9 product/root owners + 4 lifecycle owners + 1 validation owner agree

## Source-Backed Coverage

- Counterexample / sweep / inclusive contour: 64-07-01 and 64-07-02 (executed; concrete right-eye tuple and 27-scenario grid documented in 64-07-SUMMARY)
- Bilateral full-resolution protected truth: 64-06-01 and 64-08-01 (executed; 1632 protected pixels across 6 families × 2 eyes, four-state content scan, 23 content-scan rejections)
- Direct proposal / byte identity: 64-06-02 and 64-08-02 (executed; 744 actual proposals, 0 protected intersections, 0 byte mismatches, 0 outside mismatches, source-bound review at tree OID `2fb1c37e`)
- Public output: 64-01-01, 64-02-01, 64-02-02, 64-05-02 (executed; 74-case renderer, 21/21 regression, 148-file gallery, 6/6 private outputs, post-promotion T-64-07 8/8)
- Visual review: 64-03-02 and 64-08-02 (executed; four-item original-detail and source-bound review authority; no post-review tuning)
- Full conjunction: 64-04-01, 64-04-02, 64-09-01, 64-09-02 (executed; full pre-promotion and independent post-promotion rerun with 617/0/8 and 636/0/8 SwiftPM and 121/121 Demo)
- Owner / lifecycle / validation: 64-05-01, 64-05-02, 64-10-01, 64-10-02, 64-11-01, 64-11-02 (executed; four product, five root, four lifecycle, one validation owners agree on promotion-pending state)
- Candidate and final transaction: 64-12-01 produced immutable `gaps_found`; 64-13-01 applied the complete failure owner set and remains failed/requarantined

## Pending Authority

- **The immutable Plan 64-12 candidate is not accepted for success; it remains `gaps_found`.**
- **Final validation requires a future fresh `candidate_passed`; this ledger remains incomplete.**
- **SCLERA-18, canonical success, product authorization, and Phase 65 remain blocked.**
- **DeviceRGB/named-sRGB is owned exclusively by Phase 65 SAFE-06; `眼睛` remains `partial` because `去脂` is future.**

## Final Disposition (Failure / Re-Quarantine)

- 23 of 24 task rows retain execution evidence; 64-13-01 is explicitly
  failed/requarantined.
- SCLERA-16, SCLERA-17, and OUT-05 implementation facts remain recorded, while
  SCLERA-18 and product authorization remain open.
- Canonical `64-VERIFICATION.md` is `gaps_found` with
  `promotion_status: unproven`; all fifteen owners are re-quarantined and Phase
  65 is blocked.
- Failed, skipped, zero-count, conditional, stale, or missing mandatory gates
  prevent final validation or promotion inference.
