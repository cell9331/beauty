---
phase: 64
slug: sclera-output-adversarial-safety-and-independent-closeout
status: promotion_pending_candidate
validation_status: promotion_pending_candidate
nyquist_compliant: false
nyquist_pending: true
candidate_owner: phase64_plan_12
final_transaction_owner: phase64_plan_13
inventory:
  plans: 13
  tasks: 24
  pending_tasks: ["64-12-01", "64-13-01"]
created: 2026-08-07
updated: 2026-08-09
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05]
canonical_verification: gaps_found
---

# Phase 64 - Validation Strategy (13 plans / 24 task IDs)

Phase 64 inventory: **13 plans and 24 ordered task IDs** in deterministic order
spanning the original four-plan closeout chain (Plans 01-04) and the nine-plan
gap-closure replacement chain (Plans 05-13). Completed Plans 64-01 through
64-10 retain their exact execution evidence. Plan 64-11 (this plan) adds two
lifecycle/validation owner tasks. Plans 64-12 and 64-13 are explicitly pending
and own the independent post-promotion candidate and the bounded final
transaction respectively; the twenty-four rows final Nyquist may be written only by Plan
64-13 after a fresh independent Plan 64-12 candidate.

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
| 64-12-01 | 12 | 12 | SCLERA-14, SCLERA-15, SCLERA-18, OUT-05 | Independent post-promotion candidate: fresh verifier, full conjunction rerun, exact 13/24 inventory, 15 final-transaction owners + 9 immutable product/root owners; candidate status `candidate_passed` or `gaps_found` only | `64-POST-PROMOTION-CANDIDATE-VERIFICATION.md` (to be authored) | pending — not-run |
| 64-13-01 | 13 | 13 | SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05 | Bounded final transaction: atomically finalize all 15 owners or fully re-quarantine; final status only after independent Plan 12 candidate passes | `64-VERIFICATION.md` and 15-owner final state (to be authored) | pending — not-run |

Task count target: **24 task IDs = 24 validation rows**.

## Required Final Gates (Awaiting Plan 13)

- Counterexample/sweep (SCLERA-14): right-eye +0.004/-0.006/+0.003 historical tuple + 3x3x3 neighborhood + inclusive contour 27-scenario sweep
- Inclusive contour coverage (SCLERA-14): 11 left + 11 right perturbations + 4 rejected-boundary, bilateral full-resolution truth per family
- Four-state privacy / source freeze (T-64-06): tracked / staged / working / untracked, with `validate_review_source_state` binding
- Distinct helper live child (T-64-02): strict helper self-test and live output use separate child invocations
- Complete fresh test/audit/review conjunction (SCLERA-18 / T-64-05 / T-64-07): focused, private, helper, checker, privacy, full SwiftPM, Demo, fresh code/security/review
- Owner / lifecycle synchronization (T-64-07 / T-64-08): 9 product/root owners + 4 lifecycle owners + 1 validation owner agree

## Source-Backed Coverage

- Counterexample / sweep / inclusive contour: 64-07-01 and 64-07-02 (executed; concrete right-eye tuple and 27-scenario grid documented in 64-07-SUMMARY)
- Bilateral full-resolution protected truth: 64-06-01 and 64-08-01 (executed; 1632 protected pixels across 6 families × 2 eyes, four-state content scan, 23 content-scan rejections)
- Direct proposal / byte identity: 64-06-02 and 64-08-02 (executed; 744 actual proposals, 0 protected intersections, 0 byte mismatches, 0 outside mismatches, source-bound review at tree OID `2fb1c37e`)
- Public output: 64-01-01, 64-02-01, 64-02-02, 64-05-02 (executed; 74-case renderer, 21/21 regression, 148-file gallery, 6/6 private outputs, post-promotion T-64-07 8/8)
- Visual review: 64-03-02 and 64-08-02 (executed; four-item original-detail and source-bound review authority; no post-review tuning)
- Full conjunction: 64-04-01, 64-04-02, 64-09-01, 64-09-02 (executed; full pre-promotion and independent post-promotion rerun with 617/0/8 and 636/0/8 SwiftPM and 121/121 Demo)
- Owner / lifecycle / validation: 64-05-01, 64-05-02, 64-10-01, 64-10-02, 64-11-01, 64-11-02 (executed; four product, five root, four lifecycle, one validation owners agree on promotion-pending state)
- Candidate and final transaction: 64-12-01 and 64-13-01 (pending — not-run; no Plan 12 candidate or Plan 13 final transaction has been written)

## Pending Authority

- **No twenty-four rows final Nyquist may be written before the independent Plan 12 candidate is generated and accepted.**
- **Final validation status is owned only by Plan 64-13 after `candidate_passed` is observed.**
- **SCLERA-18 final closure, canonical `64-VERIFICATION.md: passed`, and Phase 65 unblock remain blocked until the bounded final transaction runs.**
- **DeviceRGB/named-sRGB is owned exclusively by Phase 65 SAFE-06; `眼睛` remains `partial` because `去脂` is future.**

## Final Disposition (Promotion-Pending Candidate)

- 22/24 task rows executed; 2/24 task rows (64-12-01 and 64-13-01) explicitly pending.
- The full conjunction, owner synchronization, and independent pre-promotion eligibility are green; promotion-pending state awaits the independent Plan 12 candidate plus Plan 13 bounded final transaction.
- Canonical `64-VERIFICATION.md` remains `gaps_found`; T-64-08 (`check_phase64_sclera_closeout.py --promotion-pending-verification`) is green; no HIGH or owner/owner/lifecycle disagreement is present.
- Failed, skipped, zero-count, conditional, stale, or missing mandatory gates retain the pending state and prevent any inference of twenty-four rows, final validation status, SCLERA-18 final, or Phase 65 unblock.
