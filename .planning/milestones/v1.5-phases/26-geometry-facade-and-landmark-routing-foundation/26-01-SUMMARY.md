---
phase: 26-geometry-facade-and-landmark-routing-foundation
plan: "01"
subsystem: sdk-effects-geometry-routing
tags: [swift, beautyeffects, beautydetection, geometry-routing, redaction]
requires: []
provides:
  - Package-internal selected-face observation to internal FaceGeometry routing
  - Geometry-trigger classifier for downstream facade detection gating
  - Selected-face resolver entry with group-specific degradation tests
affects: [BeautyDetection, BeautyEffects, Phase 26 Plan 02]
tech-stack:
  added: []
  patterns:
    - package access across internal SwiftPM targets without public raw geometry exports
    - deterministic bounds-relative synthetic geometry adapter for routing evidence
key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
  modified:
    - BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift
    - BeautySDK/Sources/BeautyDetection/CoordinateSpace.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
key-decisions:
  - "Kept FaceGeometry and control points module-internal; the package-visible boundary is the resolver entry that returns public-safe BeautyEffectPlan."
  - "Retained beauty.effects.geometryPointCount as an aggregate numeric metric because focused redaction tests and active-source scans classify it as non-coordinate evidence."
patterns-established:
  - "Detection observations cross into effects through package access, while public API scans guard against raw geometry exports."
  - "Availability-only landmark groups synthesize internal provider-ready geometry for routing tests without exposing raw landmark payloads."
requirements-completed: [GEO-02]
duration: 18 min
completed: 2026-07-06
---

# Phase 26 Plan 01: Selected-Face Geometry Resolver Route Summary

**Package-internal selected-face observations now route into the existing internal geometry resolver path with redacted aggregate evidence.**

## Performance

- **Duration:** 18 min
- **Started:** 2026-07-06T03:49:00Z
- **Completed:** 2026-07-06T04:07:34Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Added `BeautyFaceGeometryAdapter`, which converts one package-visible `BeautyFaceObservation` into internal `FaceGeometry` using bounds-relative synthetic points for available landmark groups.
- Added `BeautyEffectResolver.requiresFaceGeometry(parameters:)` and `resolve(parameters:selectedFaceObservation:)` for downstream facade routing.
- Promoted only the required detection observation, landmark, and coordinate members to `package` access; no public raw geometry symbols were added.
- Extended effects tests for geometry trigger classification, selected-face activation, missing-group degradation, nil selected-face no-face behavior, and redacted warning/metric strings.

## Task Commits

1. **Task 26-01-01: Add the package-only selected-face geometry adapter** - `82ef988` (`feat(26-01): add selected-face geometry resolver route`)
2. **Task 26-01-02: Preserve degradation and redacted aggregate evidence through the selected-face route** - `04c033b` (`test(26-01): cover selected-face degradation routing`)

## Verification

- `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` passed with 10 tests.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` passed with 14 tests.
- `rg -n "public .*BeautyFaceObservation|public .*BeautyFaceLandmarks|public .*BeautyLandmarkGroup|public .*FaceGeometry|public .*WarpControlPoint" BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects BeautySDK/Sources/BeautySDK; test $? -eq 1` passed with zero matches.
- `rg -n "VNFaceObservation|boundingBox|/private/var|NSError|AVError|rawPresetJson|raw JSON|image bytes" BeautySDK/Sources/BeautyEffects/Planning; test $? -eq 1` passed with zero matches.
- `git diff --check` passed for the Wave 1 source and test files.

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` - Bounds-relative selected-face adapter into internal `FaceGeometry`.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` - Package access for the narrow observation and landmark availability model.
- `BeautySDK/Sources/BeautyDetection/CoordinateSpace.swift` - Package access for `CoordinateRect` required by selected-face bounds routing.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Geometry trigger classifier and selected-face resolver entry.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` - Trigger, activation, fallback-bounds, and redaction coverage.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Selected-face missing-group and nil-face degradation coverage.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Swift rejected a `package` adapter method returning module-internal `FaceGeometry`; the adapter was kept internal and the package boundary was placed on the resolver method returning `BeautyEffectPlan`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 26-02 can now call `BeautyEffectResolver.requiresFaceGeometry(parameters:)` to gate still-image detection and `BeautyEffectResolver.resolve(parameters:selectedFaceObservation:)` to route one selected detection observation into effect planning.

---
*Phase: 26-geometry-facade-and-landmark-routing-foundation*
*Completed: 2026-07-06*
