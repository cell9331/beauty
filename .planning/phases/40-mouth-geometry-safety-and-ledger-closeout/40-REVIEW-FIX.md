---
phase: 40-mouth-geometry-safety-and-ledger-closeout
source_review: .planning/phases/40-mouth-geometry-safety-and-ledger-closeout/40-REVIEW.md
fixed_at: 2026-07-14
status: partial
iteration: 1
fix_scope: critical_warning
findings_in_scope: 3
fixed: 0
partially_fixed: 3
skipped: 0
fix_commits:
  - 7afcba1
---

# Phase 40 Review Fix Report — Iteration 1

Commit `7afcba1` materially hardens the boundary checker but does not yet close the three review warnings.

## Fixes Applied

### WR-01: Self-test coverage

- Expanded the former one-line self-test to 29 passing positive/mutation checks.
- Added command, missing-tool, exact inventory, unknown owner, import, raw geometry, network, diagnostic, duplicate promotion, privacy manifest, aggregate closeout, tracked artifact, and escaping-symlink negatives.
- Remaining gap: lifecycle uses a classifier-only assertion rather than the actual check; owner/traceability and several other boundaries are not isolated one-failure-per-boundary fixtures.

### WR-02: Promotion, owners, traceability, and lifecycle

- Added structural unique-row parsing for ledger, matrix, and parent branch rows.
- Required promotion tokens independently in matrix, parent, and lips owners.
- Added exact Phase 40/Complete traceability rows for MOUTH-12 through MOUTH-16 and DOC-01.
- Added audit-file, v1.10-tag, milestone-archive-diff, and lifecycle-claim checks.
- Remaining gap: root/current owner tokens are not co-located in Phase 40 sections, lifecycle claims can cross a Markdown newline and evade the regex, and `.worktrees` is not guarded.

### WR-03: Compatibility, privacy, raw geometry, and command handling

- Replaced count-only compatibility with an exact ordered 38-field inventory.
- Split search and Git command exit handling; Git exit `1` now fails closed.
- Added multiline public-geometry scanning, diagnostic privacy, privacy-manifest disposition, and stricter artifact command handling.
- Remaining gap: plural/compound raw support names and multiline diagnostic payloads evade the current patterns.

## Verification

- PASS: Python compilation.
- PASS as reported by current implementation: checker self-test, 29/29.
- PASS as reported by current implementation: live pre-promotion checker, 13/13.
- FAIL independent adversarial coverage: plural raw-geometry identifiers, multiline diagnostic payload, and multiline lifecycle claim are not detected.
- PASS: `git diff --check` for the review artifacts.

## Status

Partial: 3/3 warnings improved, 0/3 fully closed. No checker, implementation, test, ledger, owner, or promotion file was modified by the re-review.
