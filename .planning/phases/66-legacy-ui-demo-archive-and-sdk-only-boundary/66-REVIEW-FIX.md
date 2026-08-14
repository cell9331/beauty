---
phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary
fixed_at: 2026-08-14T03:36:54Z
review_path: .planning/phases/66-legacy-ui-demo-archive-and-sdk-only-boundary/66-REVIEW.md
iteration: 2
findings_in_scope: 2
fixed: 2
skipped: 0
status: all_fixed
---

# Phase 66: Code Review Fix Report

**Fixed at:** 2026-08-14T03:36:54Z
**Source review:** `.planning/phases/66-legacy-ui-demo-archive-and-sdk-only-boundary/66-REVIEW.md`
**Iteration:** 2

**Summary:**

- Findings in scope: 2
- Fixed: 2
- Skipped: 0

## Fixed Issues

### F2-01: Rollback collision could delete quarantined originals

**Files modified:** `scripts/archive-legacy-ui.py`
**Commit:** `76ba3f3`
**Applied fix:** Preflighted every rollback destination before restoring any root,
preserved the complete quarantine with a reported recovery path on collision,
and retained any not-yet-restored root if restoration itself fails. Added a
deterministic post-quarantine recreation test that requires failure and proves
the replacement plus both original trees remain unchanged and recoverable.

### F2-02: Post-archive symlink scan rejected ignored SwiftPM build links

**Files modified:** `scripts/check-sdk-only-boundary.sh`
**Commit:** `8d4fe9b`
**Applied fix:** Pruned only real directories named exactly `.build` after a
successful `git check-ignore --no-index` decision. Added passing ignored-build
symlink fixtures under `.codex` and `.planning`, while retaining failing active
source directory and file symlink fixtures.

## Verification

- Python compilation and shell syntax checks passed.
- Archive self-test, canonical verify, and artifact-only reproduce passed.
- Boundary self-test and post-archive scan passed.
- No-skip transcript self-test passed.
- Full no-skip SwiftPM gate passed: 650 tests, zero failures, zero skips,
  all eight required opt-ins observed.
- `git diff --check` passed.

---

_Fixed: 2026-08-14T03:36:54Z_
_Fixer: the agent (gsd-code-fixer)_
_Iteration: 2_
