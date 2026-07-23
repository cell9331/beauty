---
phase: 45-public-contract-and-observed-face-support
fixed_at: 2026-07-23T06:47:34Z
review_path: .planning/phases/45-public-contract-and-observed-face-support/45-REVIEW.md
iteration: 2
findings_in_scope: 3
fixed: 3
skipped: 0
status: all_fixed
---

# Phase 45: Code Review Fix Report

**Fixed at:** 2026-07-23T06:47:34Z
**Source review:** `.planning/phases/45-public-contract-and-observed-face-support/45-REVIEW.md`
**Iteration:** 2

**Summary:**

- Findings in scope: 3
- Fixed: 3
- Skipped: 0

## Fixed Issues

### CR-01: Self-intersecting median paths can still become centerline-eligible

**Status:** fixed: requires human verification
**Files modified:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift`
**Commit:** 0d81ffc
**Applied fix:** Reused the bounded non-adjacent segment-intersection guard for median validation and added a red-first regression proving a crossing median degrades to contour-only eligibility.

### CR-02: Reflection still exposes raw support coordinates despite redacted descriptions

**Status:** fixed
**Files modified:** `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`, `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`
**Commit:** 49ff737
**Applied fix:** Added aggregate-only `CustomReflectable` mirrors for all three sensitive carriers and expanded the privacy regression to cover `Mirror` labels plus `dump` output for coordinates, bounds, stable IDs, confidence, and carrier value types.

### WR-01: Authoritative closeout evidence still reports pre-fix verification counts

**Status:** fixed
**Files modified:** `PLANS.md`, `SECURITY.md`
**Commit:** 1c269a8
**Applied fix:** Replaced the stale non-diagnostic wording with the approved aggregate-only diagnostic contract, documented self-intersection rejection, and synchronized the final 36/36 checker, 31-test adapter, 20-test detector, 50-test detection, and 353-test full-suite evidence with opt-in integration skips.

## Verification

- `BeautyFaceGeometryAdapterTests`: 31 executed, 1 opt-in integration skip, 0 failures.
- `VisionFaceDetectorTests`: 20 executed, 2 opt-in integration skips, 0 failures.
- All `BeautyDetectionTests`: 50 executed, 2 opt-in integration skips, 0 failures.
- Full SwiftPM suite: 353 executed, 3 opt-in integration skips, 0 failures.
- Face-support boundary checker: 36/36 self-tests and 13/13 live checks passed.
- `git diff --check`: passed.

---

_Fixed: 2026-07-23T06:47:34Z_
_Fixer: the agent (gsd-code-fixer)_
_Iteration: 2_
