---
phase: 19-beauty-shaping-core-modules
plan: 02
subsystem: testing
tags: [beauty-shaping, face-shape, eyes, nose, geometry-conflict, xctest]
requires:
  - phase: 19-beauty-shaping-core-modules
    provides: 19-SHAPING-AUDIT.md branch and provider baseline
provides:
  - Stronger face/chin/proportion-adjacent provider assertions
  - Stronger eye and nose provider assertions
  - Redacted combined-geometry weakening metadata assertions
affects: [phase-19, bshape-02, bshape-03, BeautyEffectsTests]
tech-stack:
  added: []
  patterns: [provider-determinism-tests, missing-input-skip-tests, redacted-metadata-tests]
key-files:
  created: []
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift
key-decisions:
  - "Existing provider implementations already satisfied the new Phase 19 assertions, so no production source changes were required."
  - "Face/chin, eye, and nose evidence remains provider/unit evidence for partial branch status only."
patterns-established:
  - "Provider tests assert deterministic Equatable output plus normalized source/target clamping."
  - "Combined weakening tests assert only stable warning codes and metric keys, not geometry payloads."
requirements-completed:
  - BSHAPE-02
  - BSHAPE-03
duration: 4 min
completed: 2026-06-29
---

# Phase 19 Plan 02: Face, Eye, Nose Provider Evidence Summary

**Provider-focused XCTest hardening for face/chin/proportion, eye, nose, and combined geometry weakening without public API or renderer changes**

## Performance

- **Duration:** 4 min
- **Started:** 2026-06-29T06:37:36Z
- **Completed:** 2026-06-29T06:41:01Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added deterministic, clamped face-shape and chin output assertions, including `faceSmall` as proportion-adjacent partial evidence.
- Added a combined geometry weakening metadata test that restricts warnings and metrics to redacted code/key surfaces.
- Added eye and nose deterministic/clamping tests plus explicit `eye_inputs_missing` and `nose_inputs_missing` skip-reason assertions.

## Task Commits

1. **Task 1: Harden face-shape, chin, proportion, and conflict provider evidence** - `1f8bad5` (test)
2. **Task 2: Harden eye and nose provider evidence** - `9fcd805` (test)

**Plan metadata:** committed with this summary.

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` - Added deterministic/clamped face-shape and chin assertions.
- `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` - Added redacted combined-geometry warning/metric assertions covering all current geometry fields.
- `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` - Added deterministic/clamped current-field coverage, signed cap helper behavior, and missing-eye skip assertion.
- `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift` - Added deterministic/clamped current-field coverage, signed nose-tip helper behavior, and missing-nose skip assertion.

## Decisions Made

- No production provider source was changed because the strengthened assertions passed against the existing bounded implementation.
- No new `BeautyParameters` fields, renderer cases, public facade geometry output, 3D sculpt, eyebrow, Demo, or SwiftUI scope was introduced.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Verification

- `swift test --package-path BeautySDK --filter FaceShapeWarpProviderTests` passed with 7 tests and 0 failures.
- `swift test --package-path BeautySDK --filter GeometryConflictResolverTests` passed with 6 tests and 0 failures.
- `swift test --package-path BeautySDK --filter EyeWarpProviderTests` passed with 6 tests and 0 failures.
- `swift test --package-path BeautySDK --filter NoseWarpProviderTests` passed with 6 tests and 0 failures.
- `git diff --check -- BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 19-03 mouth/lip/resolver/degradation hardening. Plan 19-02 leaves branch status honest: face-shape, proportion, eye, and nose remain `partial` until public facade saved-image geometry output exists.

## Self-Check: PASSED

- Focused tests pass after the new assertions.
- `git log --oneline --grep='19-02'` shows task commits.
- No public parameter, renderer, facade, Demo, or UI file was modified.

---
*Phase: 19-beauty-shaping-core-modules*
*Completed: 2026-06-29*
