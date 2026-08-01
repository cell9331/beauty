---
phase: 54-rights-approved-evidence-and-eligibility-decisions
reviewed: 2026-08-01T13:47:32Z
depth: standard
files_reviewed: 6
files_reviewed_list:
  - .gitignore
  - PLANS.md
  - PRODUCT_SENSE.md
  - QUALITY_SCORE.md
  - RELIABILITY.md
  - SECURITY.md
findings:
  critical: 3
  warning: 2
  info: 0
  total: 5
status: issues_found
---

# Phase 54: Code Review Report

**Reviewed:** 2026-08-01T13:47:32Z
**Depth:** standard
**Files Reviewed:** 6
**Status:** issues_found

## Summary

The six changed contract files were reviewed against the Phase 54 core, browser controller, schema, tests, checker, decision ledger, and execution artifacts. Existing automated gates pass, but they encode rather than detect several unsafe assumptions. The most serious issues are that an untrusted manifest can self-assert the provenance that opens a feature gate, image bounds are enforced only after browser decoding has already begun, and the durable teeth decision suppresses a missing-negative gap despite recording zero eligible or reviewed evidence.

Verification rerun during review:

- `node --test .../54-evidence-core.test.js .../54-review.contract.test.js` — 66/66 passed.
- `python3 .../check_phase54_evidence_boundaries.py` — reported `pass`, `ASVS HIGH 6/6`.
- A direct Node reproduction using an invented rights record produced `status: open` with two accepted rows.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: Bundle-controlled provenance can authorize its own product gate

**Classification:** BLOCKER

**File:** `/Users/yakangwang/codes/beauty/SECURITY.md:174`

**Issue:** The contract says the selected manifest, declared role, and local media are untrusted while also claiming that the rights/evidence allowlist establishes genuine rights-approved evidence. The implementation only checks that `rights_status` equals `approved_internal_evaluation`, `evidence_role` equals `genuine_candidate`, and `rights_record_id` matches an opaque-ID regex (`54-evidence-core.js:183-198,255-267`). All three values come from the same untrusted manifest; no trusted authorization inventory is consulted and the ID is not bound to the fixture, feature, polarity, or permitted use. A direct reproduction with `rights_record_id: "invented_rights"` yielded a ready snapshot and an open teeth gate after structurally valid reviews. Therefore the EVID-01 claim in `PRODUCT_SENSE.md:521`, the T-54-01 claim in `SECURITY.md:177`, and the evidence credit in `QUALITY_SCORE.md:586` are not established.

**Fix:** Make provenance an independent trusted input. Resolve every manifest row against a locally controlled authorization registry or signed record, and bind the grant to at least fixture ID, feature, permitted use, and evidence classification. Treat bundle `rights_status` and `evidence_role` as assertions to cross-check, not authority. Add mutations proving invented IDs, mismatched fixtures/features, reused grants, and self-promoted synthetic rows remain closed; then rerun the HIGH gate before restoring the owner-document claims.

### CR-02: Dimension limits run after potentially hostile image decoding

**Classification:** BLOCKER

**File:** `/Users/yakangwang/codes/beauty/SECURITY.md:174`

**Issue:** The security contract claims bounded media dimensions and a passed denial-of-service boundary, but `54-review-controller.js:342-359` creates an `Image`, assigns the untrusted blob URL, and waits for `load` before checking `naturalWidth`/`naturalHeight <= 4096`. A small compressed PNG/JPEG can declare extremely large dimensions and force decoder allocation or resource exhaustion before the bound is evaluated. The 16 MiB compressed-file limit does not bound decoded memory. Consequently T-54-05 is not mitigated even though `QUALITY_SCORE.md:589` and the Phase 54 evaluation report it green.

**Fix:** Parse bounded PNG/JPEG headers from `File.slice(...)` before creating any image/object URL, reject dimensions and checked `width * height` pixel counts outside policy, and only then invoke browser decoding. Add adversarial header fixtures whose compressed bytes are within 16 MiB but dimensions/pixel counts exceed the ceiling, with instrumentation proving no `Image` or object URL is created for rejected inputs.

### CR-03: The teeth ledger silently treats an unreviewed negative prerequisite as satisfied

**Classification:** BLOCKER

**File:** `/Users/yakangwang/codes/beauty/PRODUCT_SENSE.md:522`

**Issue:** The owner documents call the teeth reasons exactly `[missing_genuine_positive]` while simultaneously recording `eligible_count == 0`, `reviewed_count == 0`, and no durable reviews (`PLANS.md:52`, `QUALITY_SCORE.md:587`, `RELIABILITY.md:264`). Phase decision D-04 says the authorized portrait may count as a teeth negative only after a complete teeth-specific original/mask/after triple and a frozen review pass. Neither exists in the ledger. The inconsistency is introduced by the hard-coded `BASE_CLOSED_REASONS`/`createClosedSnapshot` path (`54-evidence-core.js:84-88,311-321`), which reports zero positive and zero negative product counts but omits `missing_genuine_negative`. This makes the durable decision non-derived and can mislead downstream phases into treating the negative prerequisite as already discharged.

**Fix:** Derive all current decisions from an explicit validated inventory rather than feature-specific baseline constants. With the current zero-eligible/zero-review inventory, teeth must include both `missing_genuine_positive` and `missing_genuine_negative`. Alternatively, if the portrait is meant to satisfy the negative prerequisite, add its complete approved triple and frozen accepted review so the nonzero counts and durable review substantiate that result. Update the checker and all four owner documents from the regenerated ledger.

## Warnings

### WR-01: The claimed `6/6` HIGH inventory omits declared HIGH threats

**Classification:** WARNING

**File:** `/Users/yakangwang/codes/beauty/SECURITY.md:177`

**Issue:** The security owner says only T-54-01 through T-54-06 are HIGH and `QUALITY_SCORE.md:586,589`/`PLANS.md:50,53` attest `6/6`. Phase 54's own final plan declares T-54-07 HIGH (`54-05-PLAN.md:98-104`), and Plan 54-04 separately declares T-54-08 HIGH (`54-04-PLAN.md:135-140`). The checker hard-codes `highMitigations: 6` and `asvsHigh: "6/6"` (`check_phase54_evidence_boundaries.py:651-652,704`) instead of deriving the inventory. The evidence evaluation even lists T-54-07 as PASS while retaining the contradictory `6/6` count. This makes the block-on-HIGH attestation non-auditable and can hide future threat-model drift.

**Fix:** Establish one canonical Phase 54 threat inventory, explicitly map any merged/retired IDs, and derive checker totals from it. Include every active HIGH ID in final sign-off (including the Plan 54-04 owner/privacy threat or a documented mapping), add a mutation for missing/extra IDs, and correct the counts in SECURITY, QUALITY_SCORE, and PLANS.

### WR-02: SECURITY understates the durable export's contents

**Classification:** WARNING

**File:** `/Users/yakangwang/codes/beauty/SECURITY.md:176`

**Issue:** The contract says durable output is constructed from aggregate decision/count fields only. For a ready bundle, `buildDurableExport` also emits per-fixture opaque ID, feature, polarity, and seven structured review judgments (`54-evidence-core.js:560-575`), as permitted by PRODUCT_SENSE and the Phase 54 UI contract. The current repository ledger happens to have an empty `reviews` array, but that does not make the serializer aggregate-only. The inaccurate security description can lead reviewers to approve storage or sharing under a stricter privacy assumption than the implementation provides.

**Fix:** State the actual allowlist: feature decisions, permitted per-fixture structured reviews, and aggregates, with all forbidden media/path/rights/freeform fields excluded. If aggregate-only persistence is the intended security boundary, remove durable review rows from the serializer and update the product/UI contract and tests accordingly.

---

_Reviewed: 2026-08-01T13:47:32Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
