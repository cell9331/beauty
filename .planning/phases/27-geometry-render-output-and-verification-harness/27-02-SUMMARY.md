---
phase: 27-geometry-render-output-and-verification-harness
plan: "02"
subsystem: render
tags: [geometry, still-image, ciimage, facade, redaction]
requires:
  - phase: 27-geometry-render-output-and-verification-harness
    provides: 27-01 real still-image detection input seam and public-facade fixture probe
provides:
  - Internal selected-face observation route from BeautySDK still-image facade into BeautyEffects rendering.
  - Deterministic CIImage geometry MVP proxy driven by internal geometry control points.
  - Focused facade tests proving same-dimension geometry output differs from a no-geometry baseline.
affects: [phase-27, geometry-renderer, example-image-validation]
tech-stack:
  added: []
  patterns: [package-only selected-face render handoff, control-point-driven CIImage proxy]
key-files:
  created:
    - .planning/phases/27-geometry-render-output-and-verification-harness/27-02-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift
key-decisions:
  - "Kept selected-face render data internal/package-only by adapting BeautyFaceObservation to FaceGeometry inside BeautyEffects."
  - "Implemented Phase 27 CIImage geometry evidence as a bounded MVP proxy driven by geometry control-point count, not as a quality or parity claim."
patterns-established:
  - "Still-image geometry output tests compare against a BeautyParameters() no-geometry baseline before watermarking."
  - "No-face geometry requests preserve extent and report only redacted summary/warning/metric evidence."
requirements-completed: [GEO-03, GEO-04]
duration: 5 min
completed: 2026-07-07
---

# Phase 27 Plan 02: Selected-Face Geometry Render Output Summary

**Selected-face geometry now reaches still-image rendering and creates deterministic same-dimension output deltas against a no-geometry baseline.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-07-07T07:03:42Z
- **Completed:** 2026-07-07T07:08:15Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Added `BeautyEngineGeometryRoute.selectedFaceObservation` as an internal/package-only handoff from detection to rendering.
- Added a package-only `BeautyColorEffectPipeline.apply(... selectedFaceObservation:)` entry that adapts observations to internal `FaceGeometry` inside `BeautyEffects`.
- Added a deterministic CIImage `BeautyGeometryEffectPipeline.applyMVPProxy(...)` that runs only when internal geometry control points exist and always crops to the input extent.
- Added facade tests proving selected-face geometry changes rendered bytes before watermarking compared with `BeautyParameters()` baseline, remains deterministic, and no-face requests degrade safely.

## Task Commits

1. **Task 27-02-01: Carry selected-face geometry from facade routing into image rendering** - `3a3e0fd` (feat)
2. **Task 27-02-02: Add deterministic CIImage geometry proxy output inside the render tier** - `21639fd` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Uses the geometry-aware image render entry for still-image results.
- `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift` - Carries the selected package-only face observation in the internal route.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` - Adapts selected observations to `FaceGeometry` and invokes geometry proxy rendering after color/lip work.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` - Adds deterministic CIImage geometry MVP proxy output.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` - Adds output-delta, deterministic repeat, and no-face degradation tests.

## Decisions Made

- Kept the public `BeautyColorEffectPipeline.apply(to:plan:)` and `BeautyEngine.processResult(...)` signatures stable.
- Committed the CIImage proxy together with the render handoff so every intermediate commit remains buildable.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 8 tests.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests` passed with 6 tests.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests/testCombinedHighStrengthAllDomainsCapAndWeakenGeometry` passed.
- Public/SPI raw geometry export scan over `BeautySDK/Sources/BeautySDK` and `BeautySDK/Sources/BeautyEffects` returned no matches.
- `git diff --check` passed for Plan 27-02 source and test files.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 27-03 to append the renderer baseline and combined face-shape case, generate ignored PNGs, and run the Phase 27 geometry output helper.

---
*Phase: 27-geometry-render-output-and-verification-harness*
*Completed: 2026-07-07*
