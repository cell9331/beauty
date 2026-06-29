---
phase: 19-beauty-shaping-core-modules
plan: 03
subsystem: testing
tags: [beauty-shaping, mouth, lip-color, resolver, degradation, redaction]
requires:
  - phase: 19-beauty-shaping-core-modules
    provides: 19-SHAPING-AUDIT.md mouth/lip/resolver baseline
provides:
  - Stronger mouth provider assertions for signed size/width, clamping, determinism, and missing inputs
  - Lip-color subtool evidence separated from full mouth geometry completion
  - Resolver/degradation redaction assertions for missing, stale, reused, and public no-geometry paths
affects: [phase-19, bshape-02, bshape-03, BeautyEffectsTests]
tech-stack:
  added: []
  patterns: [signed-mouth-tests, lip-color-boundary-tests, emitted-diagnostic-redaction-tests]
key-files:
  created: []
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/LipColorEffectTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
key-decisions:
  - "Existing mouth provider and resolver production code already satisfied the Phase 19 assertions, so no source implementation change was needed."
  - "Redaction verification is scoped to emitted warning and metric strings; broad source scans can legitimately see internal implementation identifiers such as controlPoints."
patterns-established:
  - "Lip-color visible evidence is asserted as a color subtool without activating the mouth geometry domain."
  - "Resolver redaction tests collect warning codes/messages and metric keys from plan output, then scan only emitted metadata."
requirements-completed:
  - BSHAPE-02
  - BSHAPE-03
duration: 3 min
completed: 2026-06-29
---

# Phase 19 Plan 03: Mouth, Lip, Resolver Evidence Summary

**Mouth/lip/resolver XCTest hardening with emitted diagnostic redaction coverage and no public geometry-output promotion**

## Performance

- **Duration:** 3 min
- **Started:** 2026-06-29T06:41:01Z
- **Completed:** 2026-06-29T06:44:25Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added deterministic/clamped mouth provider assertions plus negative `mouthSize` and `mouthWidth` signed behavior checks.
- Added a `lipColor` test proving visible color evidence does not activate the `.mouth` geometry domain or produce geometry control points.
- Added resolver/degradation redaction assertions over missing eye, missing nose, missing mouth/lip, stale geometry, reused geometry, and public no-face geometry metadata.

## Task Commits

1. **Task 1: Harden mouth-provider and lip-color evidence** - `3a91ff8` (test)
2. **Task 2: Harden resolver degradation and redaction evidence** - `39722d2` (test)

**Plan metadata:** committed with this summary.

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` - Added deterministic/clamped and negative signed mouth geometry assertions.
- `BeautySDK/Tests/BeautyEffectsTests/LipColorEffectTests.swift` - Added lip-color boundary test proving no mouth geometry activation.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Added multi-plan emitted metadata redaction checks.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` - Added public resolver no-face geometry skip and redaction check.

## Decisions Made

- Kept `嘴唇` as `partial`: `lipColor` is visible color evidence, while mouth geometry still lacks public facade saved-image output.
- Used emitted warning/metric string literal and XCTest metadata scans for redaction, matching the accepted planning caveat that broad implementation-source scans should not fail on internal identifiers.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The broad source command `! rg -n 'landmark|control point|controlPoint|bounding|VNFaceObservation|/private/var|image bytes|SIMD|\\[0\\.' BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` reports `BeautyEffectResolver.swift:156` because the implementation calls `.controlPoints(...)`. This is a legitimate internal identifier, not emitted warning/metric metadata. The accepted Phase 19 planning caveat said redaction should inspect emitted warning/metric strings or XCTest assertions instead of all implementation identifiers.

## Verification

- `swift test --package-path BeautySDK --filter MouthWarpProviderTests` passed with 6 tests and 0 failures.
- `swift test --package-path BeautySDK --filter LipColorEffectTests` passed with 5 tests and 0 failures.
- `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` passed with 11 tests and 0 failures.
- `swift test --package-path BeautySDK --filter BeautyEffectResolverTests` passed with 7 tests and 0 failures.
- `swift test --package-path BeautySDK --filter CombinedEffectSafetyTests` passed with 4 tests and 0 failures.
- Scoped emitted string-literal redaction scan over `BeautyEffectResolver.swift` and `BeautyEffectPlan.swift` passed for `landmark`, `control point`, `controlPoint`, `bounding`, `VNFaceObservation`, `/private/var`, `image bytes`, `SIMD`, and `[0.`.
- `git diff --check -- BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift BeautySDK/Tests/BeautyEffectsTests/LipColorEffectTests.swift` passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 19-04 full/focused SwiftPM verification and blueprint/example-image status updates. Mouth/lip/resolver evidence is stronger while public facade geometry saved-image output remains deferred.

## Self-Check: PASSED

- Focused tests pass after the new assertions.
- `git log --oneline --grep='19-03'` shows task commits.
- No public parameter, renderer, facade, Demo, UI, 3D sculpt, or eyebrow work was introduced.

---
*Phase: 19-beauty-shaping-core-modules*
*Completed: 2026-06-29*
