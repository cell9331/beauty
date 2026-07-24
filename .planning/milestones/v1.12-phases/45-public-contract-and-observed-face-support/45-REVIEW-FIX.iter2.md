---
phase: 45-public-contract-and-observed-face-support
fixed_at: 2026-07-23T14:23:25+08:00
review_path: .planning/phases/45-public-contract-and-observed-face-support/45-REVIEW.md
iteration: 1
findings_in_scope: 5
fixed: 5
skipped: 0
status: all_fixed
---

# Phase 45: Code Review Fix Report

**Fixed at:** 2026-07-23T14:23:25+08:00
**Source review:** `.planning/phases/45-public-contract-and-observed-face-support/45-REVIEW.md`
**Iteration:** 1

**Summary:**

- Findings in scope: 5
- Fixed: 5
- Skipped: 0

## Fixed Issues

### CR-01: Small real faces are validated against inflated synthetic bounds

**Status:** fixed: requires human verification
**Files modified:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift`
**Commit:** dc6b663
**Applied fix:** Split observed-support validation onto exact finite positive image bounds while retaining the clamped bounds exclusively for the shipped synthetic proxy, with a sub-0.05 face regression test that also locks the seven-point proxy behavior.

### CR-02: Adapter direction checks accept reversed noncanonical paths

**Status:** fixed: requires human verification
**Files modified:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift`
**Commit:** c016c89
**Applied fix:** Replaced absolute projections with signed right/down checks at the adapter trust boundary and changed the reversed-path regression from acceptance to fail-closed rejection while preserving canonical adjacency.

### CR-03: Envelope checks accept self-intersecting face contours as eligible

**Status:** fixed: requires human verification
**Files modified:** `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift`
**Commit:** b7ba5e0
**Applied fix:** Added bounded non-adjacent open-segment intersection rejection and adversarial bow-tie/zigzag fixtures while retaining valid canonical contours.

### CR-04: Raw support coordinates remain printable through Swift reflection

**Status:** fixed
**Files modified:** `.planning/phases/45-public-contract-and-observed-face-support/check_face_support_boundaries.py`, `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`, `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`
**Commit:** 136c1d9
**Applied fix:** Added explicit redacted string/debug descriptions for the support and enclosing observation carriers, locked interpolation/reflection output to aggregate counts and availability, and extended the fail-closed checker with carrier interpolation/logging mutations.

### WR-01: Required regression tests depend on live Vision behavior and repository-local fixture layout

**Status:** fixed
**Files modified:** `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift`
**Commit:** 386b453
**Applied fix:** Replaced the required aggregate gate with deterministic six-fixture injected tests across the four-orientation by two-input-mirror matrix, and made live Vision/portrait smoke tests opt-in through `BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1`.

## Verification

- `BeautyFaceGeometryAdapterTests`: 30 tests, 1 opt-in integration skip, 0 failures.
- `VisionFaceDetectorTests`: 20 tests, 2 opt-in integration skips, 0 failures.
- Full `BeautySDK` SwiftPM suite: 352 tests, 3 opt-in integration skips, 0 failures.
- Face-support boundary checker: 36/36 self-tests and 13/13 live checks.
- `git diff --check`: passed.

---

_Fixed: 2026-07-23T14:23:25+08:00_
_Fixer: the agent (gsd-code-fixer)_
_Iteration: 1_
