---
phase: 53
fixed_at: 2026-07-31T08:05:52Z
review_path: .planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/53-REVIEW.md
iteration: 2
findings_in_scope: 4
fixed: 4
skipped: 0
status: all_fixed
---

# Phase 53: Code Review Fix Report

**Fixed at:** 2026-07-31T08:05:52Z
**Source review:** `.planning/phases/53-canonical-still-image-contract-and-private-request-foundatio/53-REVIEW.md`
**Iteration:** 2

**Summary:**

- Findings in scope: 4
- Fixed: 4
- Skipped: 0

## Fixed Issues

### CR-01: RGBA8 quantization admits slightly transparent input as opaque

**Files modified:** `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift`
**Commits:** `523dfe7`, `b6c2d56`
**Applied fix:** Added a floating-point minimum-alpha reduction before the lossy RGBA8 render, retained the carrier byte scan as defense in depth, and proved `0.999`, `Float(1).nextDown`, and mixed near-opaque input fail at the admitted facade before detector, mapped support, request context, or render work.

### CR-02: The local-support path discards valid region support behind the legacy geometry gate

**Status:** fixed; requires human verification
**Files modified:** `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift`
**Commits:** `0c36e70`, `6c31ccf`
**Applied fix:** Added explicit geometry, local-support, and combined detection purposes. Local-only requests preserve valid lip support when unrelated geometry is absent; combined requests preserve that support while reporting aggregate `.partial` / `missingLandmarks` degradation instead of a false usable result.

### WR-01: The engine recreates the canonicalizer and its CIContext for every admitted request

**Files modified:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift`
**Commits:** `bbd655c`, `a64e0fc`, `ddb09d7`
**Applied fix:** Reused one engine-owned canonicalizer and CIContext across admitted requests, kept construction lazy so exact-empty admission, legacy CIImage work, pixel-buffer processing, and reset construct no canonicalizer/context, and exposed only opaque aggregate testing observations accepted by the live boundary checker.

### WR-02: Lip mapping and lifecycle tests report synthesized counters instead of observing production work

**Files modified:** `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift`, `BeautySDK/Tests/BeautyDetectionTests/StillImageRequestSupportTests.swift`
**Commits:** `aa6fff8`, `8ab569c`
**Applied fix:** Reused one detector across fixture sequences, counted actual production mapping-boundary callbacks and mapped-point totals, observed lifecycle reset through valid-invalid-valid facade requests, and replaced synthesized carrier-consumer identities with detector-view and renderer-backing observations. Diagnostics remain aggregate-only.

## Verification

- Named Phase 53 foundation/compatibility gate: 88 tests passed, 0 failures.
- Renderer regression gate: 18 tests passed, 0 failures after linking the isolated worktree to the repository's ignored local fixtures.
- Phase 53 checker self-test: 6 cases passed with exact `16 = 13 automated + 3 flagged`.
- Phase 53 live boundary checker: passed.
- `git diff --check`: passed before report creation.

---

_Fixed: 2026-07-31T08:05:52Z_
_Fixer: the agent (gsd-code-fixer)_
_Iteration: 2_
