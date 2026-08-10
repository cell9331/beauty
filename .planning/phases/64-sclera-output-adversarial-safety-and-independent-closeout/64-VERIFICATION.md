---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
verification_stage: post_repair_final
independent: true
verified: 2026-08-10T15:00:00+08:00
status: gaps_found
promotion_status: unproven
requires_requarantine: true
phase_65_authorized: false
candidate_artifact: 64-POST-REPAIR-CANDIDATE-VERIFICATION.md
candidate_sha256: 3fdaab4bf64d724e0c697f351a1a07b64894ca7b015c09b71b0cb023206c9e0b
candidate_status: candidate_passed
transaction_result: failed_requarantined
expected_plan_count: 19
expected_task_count: 34
owner_count: 15
immutable_owner_count: 9
relevant_source_count: 19
authority_count: 6
requirements: [SCLERA-14, SCLERA-15, SCLERA-16, SCLERA-17, SCLERA-18, OUT-05]
---

# Phase 64 Final Verification — Gaps Found / Re-Quarantined

## Canonical Verdict

Phase 64 remains `gaps_found`; product promotion is `unproven`, and Phase 65
is blocked. Plan 64-18 produced an independently guarded `candidate_passed`
artifact from the unchanged promotion-pending snapshot, but Plan 64-19 could
not legally produce the required final canonical state.

The complete fifteen-owner failure branch is applied. No product/root/lifecycle
owner retains candidate-only promotion authority.

## Exact Final Blocker

The current checker imposes two mutually incompatible final predicates:

1. Plan 64-19 must change six candidate input owners, including this canonical
   file, from promotion-pending to final state.
2. `--final` calls `validate_post_repair_candidate()`, which requires every one
   of the same fifteen live input-owner hashes to remain equal to the candidate
   pre/post hashes.

The candidate froze this file at SHA-256
`3ca1c2fcdf2e0cbbaf91e119cc148d6dd1eda40031f36debb61fe2df465cd7f3`.
In the external staging root, the minimal required transition to
`verification_stage: post_repair_final` and `status: passed` changed that hash
to `f5130871efbd469ead3791e295a7cd13f645680a4c1d1701014c63773aeed3cf`.
The staged `--final --threat T-64-07` invocation then exited nonzero with the
fixed fail-closed result `phase64_closeout_failed`.

This is not evidence drift and cannot be repaired inside Plan 64-19: changing
the checker would change the frozen relevant-source manifest and invalidate the
candidate and review authority. A new repair plan and new candidate are needed.

## Preserved Candidate and Fresh Evidence

- Candidate schema/status: `phase64-post-repair-candidate-v1` /
  `candidate_passed`; guard nonce `5be706778f1419cb06dcc85ca50761d0`.
- Candidate SHA-256:
  `3fdaab4bf64d724e0c697f351a1a07b64894ca7b015c09b71b0cb023206c9e0b`.
- Candidate inventory: 19 plans, 34 task IDs, 15 input owners, nine immutable
  owners, 19 relevant sources, and six authority artifacts.
- Fresh conjunction: 637 executed, zero failed, zero skipped, all eight exact
  opt-ins; focused 74/74, helper 14/14, private 6/6 plus four opaque review
  items, Demo build and 121/0/0.
- Fresh code review/security: zero unresolved HIGH; T-64-01 through T-64-08
  closed against the exact source-bound snapshot.

These facts remain implementation evidence. They cannot override the failed
mandatory final transaction and grant no current product authority.

## Fifteen-Owner Re-Quarantine

The selected failure transaction covers all exact owners:

- canonical: `64-VERIFICATION.md` and `64-VALIDATION.md`;
- product: `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, shaping README, and
  eyes README;
- root contracts: `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`,
  `PRODUCT_SENSE.md`, and `QUALITY_SCORE.md`;
- lifecycle: `PLANS.md`, `.planning/REQUIREMENTS.md`,
  `.planning/ROADMAP.md`, and `.planning/STATE.md`.

The immutable Plan 64-12 and Plan 64-18 candidates and all fresh post-repair
evidence/review/audit artifacts remain unchanged.

## Requirement and Product Disposition

| Requirement | Current disposition |
| --- | --- |
| SCLERA-14 | implementation evidence retained; canonical/product authority open |
| SCLERA-15 | implementation evidence retained; canonical/product authority open |
| SCLERA-16 | implementation evidence retained; canonical/product authority open |
| SCLERA-17 | implementation evidence retained; canonical/product authority open |
| SCLERA-18 | failed final-authority conjunction; open |
| OUT-05 | implementation evidence retained; canonical/product authority open |

- Product-facing `祛红血丝`: future / unproven.
- Aggregate `眼睛`: partial.
- `去脂`: future; no proxy, provider, renderer, Demo mapping, or public field.
- Demo local-retouch rows: disabled and nil-mapped.
- Phase 65: blocked; its verification/audit remain stale and SAFE-06 remains
  open. DeviceRGB/named-sRGB receives no Phase 64 credit.

## Required Next Action

Add a gap-repair plan that separates immutable candidate evidence from mutable
final output owners, or otherwise validates the pre-transition hashes without
requiring post-transition byte equality. Rebuild the source-bound authority and
a distinct candidate after that repair, then rerun the bounded final
transaction. Do not edit either immutable historical candidate.

No API, Demo activation, realtime/pixel-buffer, model, network, dependency,
population, device/performance, commercial, packaging, shipping, launch,
archive, tag, or release-readiness authority is added.

---

_Canonical status: gaps_found_
_Promotion status: unproven_
_Transaction: complete fifteen-owner re-quarantine_
