---
phase: 06-core-beauty-effects
plan: 06-03
subsystem: effects
tags: [beauty-effects, eye-controls, nose-controls, warp-control-points, landmark-degradation]
requires:
  - phase: 06-core-beauty-effects
    provides: 06-02 internal FaceGeometry, provider control points, geometry pipeline, and compound weakening.
provides:
  - Internal eye and nose warp providers with deterministic fixture evidence.
  - Eye and nose safety-cap resolver integration and active-domain evidence.
  - Targeted missing-eye, missing-nose, reused-landmark, and stale-landmark degradation metadata.
affects: [mouth-lip-effects, combined-effect-safety, rich-demo-qa-surface]
tech-stack:
  added: []
  patterns: [internal feature warp providers, targeted landmark skips, reused geometry scale, stale geometry skips]
key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift
    - BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
    - BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift
    - BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
key-decisions:
  - "Eye and nose providers stay internal to BeautyEffects and consume the narrow FaceGeometry adapter rather than widening BeautyDetection or BeautySDK public contracts."
  - "Reused landmarks reduce effective face, eye, and nose geometry strengths through resolver metadata; stale landmarks skip strong geometry domains while preserving safe non-geometry domains."
patterns-established:
  - "Missing eye landmarks skip only the eyes domain; missing nose landmarks skip only the nose domain."
  - "Stale geometry warnings are stable, redacted codes and are de-duplicated when multiple geometry domains skip."
requirements-completed: ["EFFECT-05", "EFFECT-06"]
duration: 15 min
completed: 2026-06-22
---

# Phase 06: Plan 06-03 Summary

**Eye and nose MVP controls now have capped provider output, targeted missing-landmark skips, and stale/reused degradation evidence.**

## Performance

- **Duration:** 15 min
- **Started:** 2026-06-22T01:39:00Z
- **Completed:** 2026-06-22T01:53:07Z
- **Tasks:** 2
- **Files modified:** 10

## Accomplishments

- Added `EyeWarpProvider` for eye size, eye distance, eye vertical position, and eye tail lift with capped deterministic control points.
- Added `NoseWarpProvider` for nose slim, nose wing slim, nose tip size, and nose bridge with capped deterministic control points.
- Extended `BeautyGeometryEffectPipeline` and `GeometryConflictResolver` so face, eye, and nose geometry participate in one provider-backed output path and combined weakening.
- Added resolver active-domain, skipped-domain, warning, and metric behavior for eye/nose activation, targeted missing landmarks, reused landmark reduction, and stale landmark skipping.
- Added internal `LandmarkGeometryFreshness` on `FaceGeometry` without exposing raw landmarks or freshness state through the public facade.

## Task Commits

1. **Task 1 RED: Eye provider tests** - `370ebee` (test)
2. **Task 1 GREEN: Eye warp provider** - `0ae51a3` (feat)
3. **Task 2 RED: Nose provider tests** - `fbdd43b` (test)
4. **Task 2 GREEN: Nose warp provider** - `669a085` (feat)
5. **Cross-cutting RED: Stale landmark degradation tests** - `c6a0484` (test)
6. **Cross-cutting GREEN: Stale geometry degradation** - `f0f3e95` (feat)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` - Eye size, distance, vertical, and tail-lift control point generation.
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` - Nose slim, wing slim, tip, and bridge control point generation.
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` - Internal geometry freshness marker on `FaceGeometry`.
- `BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift` - Eye and nose strengths participate in combined geometry weakening.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` - Geometry pipeline collects face, eye, and nose provider points.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Eye/nose domain activation, skip metadata, reused scaling, and stale skip behavior.
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` - Provider direction and cap coverage for all eye fields.
- `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` - Provider direction and cap coverage for all nose fields.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Targeted skip, redaction, fixture proxy, reused, and stale degradation tests.
- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` - Shared geometry fixtures for full, missing, reused, and stale face geometry.

## Requirements Addressed

- `EFFECT-05` is complete for eye size, eye distance, eye vertical position, and eye tail lift provider-backed SDK behavior.
- `EFFECT-06` is complete for nose slim, nose wing slim, nose tip size, and nose bridge provider-backed SDK behavior.
- `EFFECT-09` is partially addressed for eye/nose caps, combined geometry weakening, missing-landmark skips, reused reductions, stale skips, and redacted metadata. It remains globally pending until Plan 06-05 completes combined degradation across all face-dependent domains.

## Decisions Made

- Kept reused/stale state internal to `BeautyEffects` fixture geometry for this MVP slice. Public detection summaries already carry user-facing degraded-state information without exposing raw landmarks.
- Used resolver-level reused scaling so effective strengths and metrics remain visible before providers generate points.
- Used resolver-level stale skipping so stale face, eye, and nose requests degrade consistently while safe color/filter domains remain active.

## Deviations from Plan

None - the plan allowed deterministic provider evidence before production warp quality and required stale/reused metadata evidence.

## Issues Encountered

- Stale/reused tests were added after initial eye/nose provider work because the plan's D-11 success criterion needed explicit evidence beyond missing-landmark skips.

## User Setup Required

None - no external service configuration required.

## Verification

- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` passed with 6 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter EyeWarpProviderTests` passed with 4 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter NoseWarpProviderTests` passed with 4 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineTests` passed with 9 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` passed with 29 XCTest cases.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 103 XCTest cases.
- Static coverage scan for eye/nose fields and degradation codes returned expected matches.
- Public API boundary scan for public eye/nose providers, landmarks, and bounding exposure returned no matches.
- `git diff --check -- BeautySDK/Sources/BeautyEffects BeautySDK/Tests/BeautyEffectsTests` exited 0.

## Next Phase Readiness

Plan 06-04 can reuse the provider/result patterns, resolver skip metadata, and freshness handling for mouth and lip behavior. `EFFECT-09` remains intentionally open for final combined safety and Demo-facing degradation evidence in Plan 06-05.

---
*Phase: 06-core-beauty-effects*
*Completed: 2026-06-22*
