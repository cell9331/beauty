---
phase: 89-semantic-validation-baseline
fixed_at: 2026-08-26T04:48:54Z
review_path: .planning/phases/89-semantic-validation-baseline/89-REVIEW.md
iteration: 3
findings_in_scope: 3
fixed: 3
skipped: 0
status: all_fixed
---

# Phase 89: Code Review Fix Report

**Fixed at:** 2026-08-26T04:48:54Z
**Source review:** `.planning/phases/89-semantic-validation-baseline/89-REVIEW.md`
**Iteration:** 3

**Summary:**

- Findings in scope: 3
- Fixed: 3
- Skipped: 0

## Fixed Issues

### WR-01: Admitted custom paths can prevent failure publication and preserve stale semantic evidence

**Status:** fixed: requires human verification
**Files modified:** `scripts/face-feature-path-helper.py`, `scripts/run-face-feature-batches.sh`, `scripts/test-face-feature-batch-boundaries.py`
**Commit:** 0056472
**Applied fix:** Replaced the helper's ASCII/120-character component grammar with descriptor-relative POSIX component validation bounded by filesystem `NAME_MAX`, used a fixed bounded atomic temporary name, and made report/full admission invoke the same descriptor helper before marking paths admitted. Boundary probes now require current failure envelopes for spaces, Unicode, and 120/121/255-byte components and reject a 256-byte component.

### WR-02: Preflight inventory faults can return undocumented exit 1

**Status:** fixed: requires human verification
**Files modified:** `scripts/run-face-feature-batches.sh`, `scripts/test-face-feature-batch-boundaries.py`
**Commit:** d81d909
**Applied fix:** Wrapped inventory validation so every comparator, manifest, or renderer inventory failure exits 2 during preflight. Three fault probes assert exit 2 and byte-for-byte unchanged output/report state.

### WR-03: Phase closeout records conflicting self-test counts

**Status:** fixed
**Files modified:** `PLANS.md`
**Commit:** d5264cd
**Applied fix:** Replaced the stale 542-mutation closeout count with 554 and recorded the path-helper/cleanup, stale/alias, component-boundary, and preflight-infrastructure probes.

## Verification

- Comparator self-test: 554 mutations passed.
- Path-helper and cleanup/parent-swap self-tests passed.
- Stale/alias/path-component/preflight-fault boundary self-test passed.
- Swift comparator typecheck, Python syntax checks, and runner shell syntax passed.
- Live generated-fixture preflight passed exact `75/65/8` without output/report mutation.
- `swift build --package-path BeautySDK` passed.
- `swift test --package-path BeautySDK` passed.
- `git diff --check` and committed-worktree hygiene passed.

---

_Fixed: 2026-08-26T04:48:54Z_
_Fixer: the agent (gsd-code-fixer)_
_Iteration: 3_
