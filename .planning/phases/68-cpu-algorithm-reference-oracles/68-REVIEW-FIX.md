---
phase: 68-cpu-algorithm-reference-oracles
fixed_at: 2026-08-14T08:37:54Z
review_path: .planning/phases/68-cpu-algorithm-reference-oracles/68-REVIEW.md
iteration: 2
findings_in_scope: 7
fixed: 7
skipped: 0
status: all_fixed
---

# Phase 68: Code Review Fix Report

**Fixed at:** 2026-08-14T08:37:54Z  
**Source review:** `.planning/phases/68-cpu-algorithm-reference-oracles/68-REVIEW.md`  
**Iteration:** 2

**Summary:**
- Findings in scope: 7
- Fixed: 7
- Skipped: 0

## Fixed Issues

### CR-01: Generated preflight permits file-backed image reads and unclassified absolute locators

**Files modified:** `scripts/check-cpu-reference-oracles.sh`  
**Commit:** `6136ee5`  
**Applied fix:** Expanded the generated-source scanner to reject file-backed Core Image/ImageIO/URL/FileManager forms, absolute/private locators, and media/path tokens. Added mutation probes for `CIImage(contentsOf:)`, `/tmp`, `/private`, and representative scope symbols/imports.

### WR-01: Metal and UI/Demo scope forms bypass the static boundary

**Files modified:** `scripts/check-cpu-reference-oracles.sh`  
**Commit:** `6136ee5`  
**Applied fix:** Added fail-closed identifier/module checks for Metal, MTL, GPUImage/GPU, UIKit, SwiftUI, view/image/application/Demo symbols, with separate `MTLDevice`, `MetalKit`, `UIKit`, and Demo/application mutation coverage.

### WR-02: Plan 68-01 fixture contract artifacts still fail their declared minimum size

**Files modified:** `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureTests.swift`, `BeautySDK/Tests/BeautyCoreTests/CPUReferenceFacadeFixtureTests.swift`  
**Commit:** `f8c3449`  
**Applied fix:** Added substantive extent, byte-count, region-partition, support-boundary, gradient, metadata, and alpha assertions. The files now contain 118 and 84 lines, exceeding the declared 80/60 minimums without padding.

### WR-03: Local-retouch changed-pixel helper still indexes malformed output unsafely

**Files modified:** `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceLocalRetouchOracleTests.swift`  
**Commit:** `f8c3449`  
**Applied fix:** Replaced the duplicate helper with throwing `CPUReferenceMetrics.changedIndices` and added short-carrier and non-RGBA8 regression assertions.

### WR-04: Generated sclera oracle does not assert hard-envelope containment

**Files modified:** `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceLocalRetouchOracleTests.swift`  
**Commit:** `f8c3449`  
**Applied fix:** Generated per-eye ellipse hard-envelope union and outside set are retained transiently; the oracle now requires changed pixels to stay in the union and verifies every outside sentinel remains byte-identical, independently of protected-anatomy checks.

### WR-05: Repeatability test compares bytes but not aggregate metrics

**Files modified:** `BeautySDK/Tests/BeautyCoreTests/CPUReferenceDeterminismTests.swift`  
**Commit:** `f8c3449`  
**Applied fix:** Captured and compared provider, sclera-provider, and composition aggregate observations for repeated and fresh harness invocations while retaining byte and ownership assertions.

### WR-06: Color metadata assertion still accepts missing output metadata

**Files modified:** `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceColorOracleTests.swift`, `BeautySDK/Tests/BeautyCoreTests/CPUReferenceFacadeFixtureFactory.swift`  
**Commit:** `f8c3449`  
**Applied fix:** Replaced optional-pass metadata logic with an explicit contract: the current Core Image filter intermediate is intentionally untagged (`XCTAssertNil`), while the generated input and canonical/software render carrier are explicitly named sRGB. Removed the unused ImageIO import so generated sources remain in-memory/CPU-only.

## Verification

- `swift test --package-path BeautySDK --filter 'CPUReferenceFixtureTests|CPUReferenceFacadeFixtureTests|CPUReferenceLocalRetouchOracleTests|CPUReferenceDeterminismTests|CPUReferenceColorOracleTests.testColorImagePathKeepsNamedSRGBExtentAndFiniteRGBA'` — 32/32 passed.
- `bash scripts/check-cpu-reference-oracles.sh --self-test` — passed, including file/path and Metal/UI/Demo mutation failures.
- `bash scripts/check-cpu-reference-oracles.sh` — passed with exact `fixture_tests=15 geometry_color_tests=10 local_determinism_tests=16`.
- `bash -n scripts/check-cpu-reference-oracles.sh` — passed.
- `git diff --check` — passed.
- `bash scripts/run-no-skip-swiftpm.sh` — passed in the main worktree: archive, SDK-only boundary, consumer, CPU preflight, all eight opt-ins, and `Executed 699 tests, with 0 failures` / zero skips.

---

_Fixed: 2026-08-14T08:37:54Z_  
_Fixer: the agent (gsd-code-fixer)_  
_Iteration: 2_
