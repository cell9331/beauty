---
phase: 52-eyebrow-safety-and-branch-closeout
reviewed: 2026-07-27T05:38:53Z
depth: standard
files_reviewed: 24
files_reviewed_list:
  - ARCHITECTURE.md
  - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
  - BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift
  - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift
  - BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
  - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
  - DESIGN.md
  - PLANS.md
  - PRODUCT_SENSE.md
  - QUALITY_SCORE.md
  - RELIABILITY.md
  - SECURITY.md
  - docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md
  - docs/meitu-function-blueprint/FEATURE_MATRIX.md
  - docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md
  - docs/meitu-function-blueprint/features/beauty-shaping/README.md
  - docs/meitu-function-blueprint/features/beauty-shaping/eyebrows/README.md
  - example-images/README.md
findings:
  critical: 0
  warning: 3
  info: 0
  total: 3
status: issues_found
---

# Phase 52: Code Review Report

**Reviewed:** 2026-07-27T05:38:53Z
**Depth:** standard
**Files Reviewed:** 24
**Status:** issues_found

## Summary

The final cap/provider implementation and the 44-field resolver/dispatch path are
internally consistent, and no production security or privacy vulnerability was
found. The review found three test-reliability defects: the shared eyebrow
oracle constructs support that contradicts the production canonicalization and
validation contract, the cancellation case exits before any resolver/provider
work begins, and the late-removal test manually reproduces rather than executes
the production convergence loop. These gaps weaken the evidence used to close
SAFE-01 and SAFE-02.

## Narrative Findings (AI reviewer)

### Warnings

#### WR-01: Shared safety fixtures violate the production eyebrow-support contract

**Classification:** WARNING

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift:129-138`

**Issue:** The shared oracle labels the first point as `innerEndpoint`, but its
default left trace runs from x `0.25` to `0.47` and its right trace runs from
`0.75` to `0.53`. That is the opposite of the production mapper's canonical
inner-to-outer order, which sorts the left side from the center outward and the
right side from the center outward. Consequently, length and head-spacing
tests exercise anatomically swapped endpoints while still passing because the
expected values are derived from the same mislabeled fixture. The adjacency
fixtures at lines 188-240 compound the gap: the strength and thickness traces
have a `0.0004` chord even though the production adapter rejects chords below
`0.08`. Direct `FaceGeometry` construction bypasses that trust boundary, so the
tests call these fixtures eligible even though they cannot be produced by the
real observation-to-geometry path.

**Fix:** Build the shared traces through
`BeautyFaceGeometryAdapter.validatedBrowTrace` (or an equivalent production
mapping fixture), use adapter-valid chord/span values, and assert that the
inner endpoint is closer to the face center than the outer endpoint along the
face-right projection. Apply the same canonical fixture to
`EyebrowWarpProviderTests` instead of maintaining its duplicated reversed
trace helper.

#### WR-02: Cancellation test cancels only an artificial sleep, not eyebrow work

**Classification:** WARNING

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift:1297-1308`

**Issue:** The task's first operation is a throwing `Task.sleep`, and the task
is cancelled immediately. `Task.sleep` throws `CancellationError`, so execution
never reaches `BeautyEffectResolver.resolve` at line 1300. The passing test
therefore proves only that a cancelled sleep stops subsequent code; it does not
exercise resolver, provider, facade, warning, metric, or support isolation
during interrupted work, despite the test name and Phase 52 reliability
contract claiming that coverage.

**Fix:** Use a deterministic barrier/continuation to signal that the task has
entered the request path before cancellation, then allow the cancelled request
to finish or discard its result and verify concurrent and subsequent request
identities. If the synchronous resolver is intentionally not cancellable,
state that narrower contract and test cancellation at the actual asynchronous
facade boundary rather than before the resolver call.

#### WR-03: Late provider-empty test bypasses the production convergence loop

**Classification:** WARNING

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift:88-128`

**Issue:** The test that claims every eyebrow row is removed monotonically
never calls `BeautyEffectResolver` or its 44-pass convergence function. It
manually invokes `GeometryConflictResolver`, then manually calls provider
sanitization, then invokes the conflict resolver again. A defect in the real
retained-baseline update, provider order, loop termination, or final resolution
would not fail this test. The numeric assertion is also ineffective:
`providerEmptyThreshold` is half an ULP while the allowed accuracy is one full
ULP, so an incorrect zero scaled strength satisfies the assertion and still
produces the expected empty emission.

**Fix:** Drive each row through the real resolver convergence path using
adapter-valid precision-boundary geometry that emits before the production
scale and becomes empty after it, or expose the convergence helper through a
testable internal seam. Assert that the pre-sanitization scaled value is
strictly nonzero with a tolerance smaller than the expected value, then verify
the final public plan removes the field and that repeated resolution cannot
re-enter it.

## Verification

- Focused BeautyEffects review suites: 134 tests passed, 0 failures.
- `BeautyEngineGeometryFacadeTests`: 20 tests executed, 1 explicit Apple Vision
  integration skip, 0 failures.
- No source files were modified by this review.

---

_Reviewed: 2026-07-27T05:38:53Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
