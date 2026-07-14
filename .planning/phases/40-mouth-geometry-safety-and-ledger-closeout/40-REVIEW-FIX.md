---
phase: 40-mouth-geometry-safety-and-ledger-closeout
source_review: .planning/phases/40-mouth-geometry-safety-and-ledger-closeout/40-REVIEW.md
fixed_at: 2026-07-14
status: all_fixed
iteration: 2
fix_scope: critical_warning
findings_in_scope: 3
fixed: 3
partially_fixed: 0
skipped: 0
fix_commits:
  - 7afcba1
  - f4b6fa6
findings_fixed:
  critical: 0
  warning: 3
  info: 0
  total: 3
---

# Phase 40 Review Fix Report

All three Phase 40 boundary-checker warnings are fixed with no skipped finding.

## Findings Fixed

### WR-01: Actual positive and mutation coverage

- Iteration 1 expanded the original minimal self-test and installed typed command/path/artifact negatives.
- Iteration 2 raises the deterministic matrix to 63/63 and invokes the actual boundary functions for isolated promotion rows, all branch owners, all current owners, all Phase 40 traceability rows, multiline lifecycle claims, audit artifacts, tags, archive mutations, worktree mutations, commercial paths, and every artifact state.
- The reported total now corresponds to observed positive or adversarial check results rather than a lifecycle-classifier proxy.

### WR-02: Exact promotion, scoped owners, traceability, and lifecycle

- Ledger, matrix, and parent rows are structurally parsed and unique; exactly five geometry rows promote, `白牙` stays future, and branch `嘴唇` stays partial.
- Matrix, parent, and lips owners each independently carry the required Phase 40 field/nonclaim tokens.
- Root and planning owners require their facts in a bounded v1.10/Phase 40 section; requirement checklist and traceability rows are exact.
- The lifecycle guard uses multiline/DOTALL matching through `check_lifecycle_and_archive` and rejects audit artifacts, v1.10 tags, milestone archive changes, `.worktrees`/`.planning/worktrees` changes, and lifecycle success claims.

### WR-03: Compatibility, raw geometry, diagnostics, privacy, and command behavior

- Compatibility is the exact ordered 38-field public inventory: 37 numeric fields plus `filterId`.
- Search exit `1` remains clean no-match while every Git nonzero exit is blocking.
- Public/SPI raw-geometry scanning covers singular, plural, and compound landmark/support/bounds identifiers across bounded multiline declarations.
- Diagnostic scanning covers bounded multiline quoted warning/metric payloads; privacy-manifest disposition and artifact Git checks remain explicit.
- Targeted mutations prove plural landmarks/supports and multiline diagnostic payloads fail.

## Verification

- PASS: `python3 -m py_compile .../check_mouth_geometry_boundaries.py`.
- PASS: checker self-test, 63/63.
- PASS: live pre-promotion checker, 13/13.
- PASS: review artifact `git diff --check`.

## Status

All scoped warnings are fixed: 3/3 fixed, 0 skipped. The re-review changed only review artifacts; it did not modify the checker, Swift implementation/tests, ledger, current owners, requirement state, or lifecycle state.
