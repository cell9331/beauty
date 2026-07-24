---
phase: 45-public-contract-and-observed-face-support
fixed_at: 2026-07-23T07:14:39Z
review_path: .planning/phases/45-public-contract-and-observed-face-support/45-REVIEW.md
iteration: 3
findings_in_scope: 2
fixed: 2
skipped: 0
status: all_fixed
---

# Phase 45: Code Review Fix Report

**Fixed at:** 2026-07-23T07:14:39Z
**Source review:** `.planning/phases/45-public-contract-and-observed-face-support/45-REVIEW.md`
**Iteration:** 3

**Summary:**

- Findings in scope: 2
- Fixed: 2
- Skipped: 0

## Fixed Issues

### CR-01: Effects-layer semantic carriers reopen raw-coordinate reflection

**Files modified:** `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift`, `.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py`
**Commit:** bc3e8b1
**Applied fix:** Added fixed aggregate-only textual and structural representations for `BeautyFaceSemanticSupport` and `FaceGeometry` without changing their internal coordinate access, storage, equality, or sendability. Added a red-first sentinel regression covering descriptions, reflection, mirrors, and dumps, and taught the fail-closed boundary checker to classify only the new approved aggregate fields.

### WR-01: Authoritative design and reliability records still contradict the final implementation

**Files modified:** `DESIGN.md`, `RELIABILITY.md`, `PLANS.md`
**Commit:** bc90c65
**Applied fix:** Updated the current `BeautyParameters` inventory to 52 stored fields and listed the four Phase 45 face-shape scalars. Synchronized post-review evidence to 36/36 checker self-tests, 13/13 live checks, 32 adapter tests with 1 opt-in skip, 20 detector tests with 2 opt-in skips, 50 complete detection tests with 2 opt-in skips, and 354 full SwiftPM tests with 3 opt-in skips, all with zero failures.

## Verification

- `BeautyFaceGeometryAdapterTests`: 32 executed, 1 opt-in integration skip, 0 failures.
- `VisionFaceDetectorTests`: 20 executed, 2 opt-in integration skips, 0 failures.
- Face-support boundary checker: 36/36 self-tests and 13/13 live checks.
- Full BeautySDK SwiftPM suite: 354 executed, 3 opt-in integration skips, 0 failures.
- `git diff --check`: passed.

---

_Fixed: 2026-07-23T07:14:39Z_
_Fixer: the agent (gsd-code-fixer)_
_Iteration: 3_
