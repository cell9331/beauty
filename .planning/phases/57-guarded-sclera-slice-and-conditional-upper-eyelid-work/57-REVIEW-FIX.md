---
phase: 57
fixed_at: 2026-08-04T03:50:25Z
review_path: .planning/phases/57-guarded-sclera-slice-and-conditional-upper-eyelid-work/57-REVIEW.md
iteration: 1
findings_in_scope: 7
fixed: 7
skipped: 0
status: all_fixed
verification_status: pending_independent_verifier
---

# Phase 57: Code Review Fix Report

**Fixed at:** 2026-08-04T03:50:25Z  
**Source review:** `57-REVIEW.md`  
**Iteration:** 1

**Summary:**

- Findings in scope: 7
- Fixed: 7
- Skipped: 0
- Phase lifecycle: still awaiting independent verification; no transition was performed

## Fixed Issues

### CR-01: Direct candidate aliases bypass the complete-production scan

**Files modified:** checker plus the Phase 57 parameter, resource, renderer, and Demo boundary tests  
**Commit:** `487c64d`  
**Applied fix:** Added normalized unsuffixed sclera and upper-eyelid token families, neutral-file mutations, and matching Swift negative-name inventories.

### CR-02: New Demo files can activate both disabled rows without detection

**Files modified:** `check_phase57_eye_gate_boundaries.py`  
**Commit:** `123e78f`  
**Applied fix:** Recursively scans every production Demo Swift file and removes only the two exact disabled taxonomy declarations from the candidate scan before rejecting IDs, titles, bindings, and English routes.

### CR-03: LID-04 does not reject the actual 去脂-to-proxy relationship

**Files modified:** `check_phase57_eye_gate_boundaries.py`  
**Commit:** `8bb940e`  
**Applied fix:** Treats `去脂` and `eyes.fat` as owned candidate identities and tests assignment, forwarding, comment, mapping, route, and evidence forms against all prohibited proxies. Logic change is covered by 199 executable mutations and remains subject to the independent verifier.

### CR-04: Finalized evidence accepts contradictory open/active claims

**Files modified:** `check_phase57_eye_gate_boundaries.py`  
**Commit:** `8ad2660`  
**Applied fix:** Parses exact unique decision, disposition, task, and HIGH tables and rejects active, enabled, available, open, implementation, and promotion contradictions. Logic change is mutation-tested and remains subject to the independent verifier.

### CR-05: The evidence privacy gate allows sensitive support in prose and tables

**Files modified:** `check_phase57_eye_gate_boundaries.py`  
**Commit:** `b59b889`  
**Applied fix:** Makes finalized evidence an exact aggregate-only allowlist and adds prose, bullet, quote, and Markdown-table mutations across pupil, iris, landmark, mask, pixel, reviewer, raw-scanner, path, digest, and vein families.

### CR-06: Unreadable fixtures leak raw traceback and filesystem paths

**Files modified:** `check_phase57_eye_gate_boundaries.py`  
**Commit:** `648ce7d`  
**Applied fix:** Moves the second evidence read into the guarded lifecycle read and wraps every CLI mode in a fixed-rule exception classifier; subprocess tests require exit 1, exact stdout, and empty stderr for unreadable directories.

### CR-07: Owner equality is not checked, and ROADMAP is inconsistent

**Files modified:** checker, ROADMAP, STATE, evidence, validation, PLANS, SECURITY, RELIABILITY, and QUALITY_SCORE  
**Commit:** `c32dd07`  
**Applied fix:** Adds exact unique anchors for every Phase 57 owner, owner deletion/duplication/contradiction mutations, repairs both stale ROADMAP boxes, and synchronizes the initial 490-case post-review evidence.

## Skipped Issues

None.

## Verification

- Python syntax: passed.
- Checker live: `mode=live status=passed rules=none`.
- Checker self-test after the independent verification-gap fix: 519/519; exact
  per-threat totals `65 / 68 / 90 / 143 / 23 / 81 / 7 / 42`.
- The completed identity inventory now contains 44 sclera and 74 upper-eyelid
  camelCase, snake_case, dotted Demo-ID, and owned Chinese identities. Every
  identity is exercised in a neutral production file and a proxy relation;
  only the exact two disabled Demo taxonomy declarations are allowlisted.
- Focused Swift Phase 57 tests: 5/5 passed.
- Focused Demo Phase 57 test on iPhone 17e / iOS 26.5: 1/1 passed.
- The broader 101-test Swift filter had eight failures caused by missing ignored `example-images` fixtures in the isolated worktree; every Phase 57 test in that run passed. Canonical full regression remains owned by the independent verifier from the primary workspace.
- Diff hygiene: passed.

---

_Fixed: 2026-08-04T03:50:25Z_  
_Fixer: the agent (gsd-code-fixer)_  
_Iteration: 1_
