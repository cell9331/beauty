---
phase: 06-core-beauty-effects
plan: 06-04
subsystem: effects
tags: [beauty-effects, mouth-controls, lip-color, warp-control-points, landmark-degradation]
requires:
  - phase: 06-core-beauty-effects
    provides: 06-03 internal FaceGeometry freshness, targeted landmark skips, and provider-backed geometry pipeline.
provides:
  - Internal mouth warp provider with deterministic fixture evidence.
  - Lip-color mouth-region output for pixel-buffer and CI image paths.
  - Targeted missing-mouth, missing-lip, reused-landmark, stale-landmark, cap, and combined-weakening metadata evidence.
affects: [combined-effect-safety, rich-demo-qa-surface]
tech-stack:
  added: []
  patterns: [internal mouth warp provider, mouth-region lip mask, targeted mouth and lip skips, row-stride-safe pixel fixtures]
key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/LipColorEffectTests.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
    - BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift
    - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
key-decisions:
  - "Mouth geometry stays internal to BeautyEffects and reuses FaceGeometry.outerLips instead of widening public BeautySDK contracts."
  - "Lip color uses an internal mouth-region mask from outer lips, with public overloads preserving existing no-face behavior and test-only internal overloads accepting FaceGeometry."
  - "Missing mouth landmarks skip only mouth geometry and lip color while preserving safe skin, color, filter, eye, and nose domains."
patterns-established:
  - "Mouth size, mouth width, and smile participate in the same combined geometry weakening path as face, eye, and nose controls."
  - "Pixel-buffer fixture helpers must write rows using CVPixelBufferGetBytesPerRow rather than assuming contiguous row packing."
requirements-completed: ["EFFECT-07"]
duration: 20 min
completed: 2026-06-22
---

# Phase 06: Plan 06-04 Summary

**Mouth and lip MVP controls now have capped provider output, mouth-region lip color output, and targeted missing-mouth degradation evidence.**

## Performance

- **Duration:** 20 min
- **Started:** 2026-06-22T08:00:10Z
- **Completed:** 2026-06-22T08:20:36Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments

- Added `MouthWarpProvider` for mouth size, mouth width, and smile with capped deterministic control points.
- Extended geometry conflict resolution and geometry pipeline routing so mouth controls participate in combined face, eye, nose, and mouth weakening.
- Added resolver metadata for missing mouth landmarks, reused mouth geometry reduction, stale mouth geometry skips, and missing lip color inputs.
- Added lip-color output in `BeautyColorEffectPipeline` for both BGRA pixel buffers and CI images using an internal mouth-region mask.
- Preserved public facade boundaries: mouth/lip geometry, landmark points, and bounding data remain internal.

## Task Commits

1. **Task 1 RED: Mouth provider tests** - `e101273` (test)
2. **Task 1 GREEN: Mouth warp provider** - `0f4eed3` (feat)
3. **Task 1 RED: Mouth degradation tests** - `9f04d88` (test)
4. **Task 1 GREEN: Mouth resolver routing** - `76c85ca` (feat)
5. **Task 2 RED: Lip color tests** - `08ec581` (test)
6. **Task 2 fixture correction: Pixel-buffer stride** - `a0553b0` (test)
7. **Task 2 GREEN: Lip color output** - `b208586` (feat)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` - Mouth size, width, and smile control point generation.
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` - `FaceGeometry.outerLips` support for mouth and lip fixtures.
- `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` - Mouth strengths participate in combined geometry weakening.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` - Geometry pipeline collects mouth provider points.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` - Mouth-region lip color transform for pixel-buffer and image paths.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Mouth/lip activation, skip metadata, stale/reused handling, and metrics.
- `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` - Provider direction and cap coverage for mouth fields.
- `BeautySDK/Tests/BeautyEffectsTests/LipColorEffectTests.swift` - Resolver cap, no-op, pixel-buffer subset, and CI image output coverage.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Missing-mouth, reused, stale, and lip skip coverage.
- `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` - Combined geometry weakening now includes mouth.
- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` - Shared outer-lip fixtures for mouth/lip tests.

## Requirements Addressed

- `EFFECT-07` is complete for mouth size, mouth width, smile, and lip color SDK-backed behavior.
- `EFFECT-09` is partially addressed for mouth/lip no-op defaults, caps, missing-mouth skips, reused reductions, stale skips, combined weakening, and redacted metadata. It remains globally pending until Plan 06-05 closes combined safety, no-face behavior, presets, Demo smoke, and final verification.

## Decisions Made

- Kept lip-color face geometry injection internal to `BeautyEffects` tests instead of adding public face or landmark parameters to `BeautyEngine`.
- Used an ellipse-style mouth-region mask from `outerLips` for MVP lip color. This is deterministic and conservative, while leaving full lipstick masking for later phases.
- Treated the plan's broad public lip scan as noisy because `BeautyParameters.lipColor` is an intentional v1 public parameter; the refined boundary scan targets providers, landmarks, bounds, and FaceGeometry exposure.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed lip color pixel-buffer fixture row copying**

- **Found during:** Task 2 (lip color pixel-buffer output verification)
- **Issue:** The new test helper copied BGRA bytes as one contiguous block, but `CVPixelBuffer` rows can have padding. This created false output deltas outside the mouth region.
- **Fix:** Updated the test helper to copy each row using `CVPixelBufferGetBytesPerRow`, matching existing package fixture helpers.
- **Files modified:** `BeautySDK/Tests/BeautyEffectsTests/LipColorEffectTests.swift`
- **Verification:** `swift test --package-path BeautySDK --filter LipColorEffectTests` passed.
- **Committed in:** `a0553b0`

---

**Total deviations:** 1 auto-fixed (1 blocking test-fixture correction)
**Impact on plan:** The fix made the planned pixel-buffer assertions valid. No product or public API scope was added.

## Issues Encountered

- The plan's `read_first` path `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` no longer exists; the current engine file is `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, which was read instead.
- The plan-level public boundary scan `public .*lip` matches the intentional public `BeautyParameters.lipColor` field. A refined raw-geometry scan for public providers, landmarks, bounds, `outerLips`, `FaceGeometry`, and `WarpControlPoint` returned no matches.

## User Setup Required

None - no external service configuration required.

## Verification

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter MouthWarpProviderTests` passed with 4 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter LipColorEffectTests` passed with 4 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` passed with 10 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineTests` passed with 9 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` passed with 41 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 115 XCTest cases.
- Static coverage scans for mouth/lip fields and degradation codes returned expected source and test matches.
- Refined public API boundary scan for public mouth providers, landmarks, bounds, `outerLips`, `FaceGeometry`, and `WarpControlPoint` returned no matches.
- `git diff --check -- BeautySDK/Sources/BeautyEffects BeautySDK/Tests/BeautyEffectsTests` exited 0.

## Next Phase Readiness

Plan 06-05 can close cross-domain no-face/stale behavior, conservative preset evidence, Demo status/smoke coverage, root docs, and final Phase 6 verification. `EFFECT-09` remains intentionally open for that final safety pass.

---
*Phase: 06-core-beauty-effects*
*Completed: 2026-06-22*
