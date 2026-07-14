---
phase: 18-skin-retouch-core-modules
plan: 18-02
subsystem: effects
tags: [basic-skin, BeautyEffects, BeautyColorEffectPipeline, redacted-metadata]
requires:
  - phase: 18-skin-retouch-core-modules
    provides: 18-01 Basic skin contract audit and future-branch negative-scan baseline
provides:
  - Conservative Basic skin formula updates in the existing CIImage and BGRA color paths
  - Focused Basic skin formula regression coverage
  - Public resolver and facade no-detection Basic skin coverage
  - Redacted missing-input warning code names on public effect metadata
affects: [phase-18, phase-19, BeautyEffects, BeautySDK]
tech-stack:
  added: []
  patterns: [focused-xctest-regression, public-facade-no-detection-test, redacted-warning-code]
key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift
    - .planning/phases/18-skin-retouch-core-modules/18-02-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift
    - BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift
    - BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift
key-decisions:
  - "CIImage Basic skin smoothing is implemented as a conservative saturation reduction inside the existing color path."
  - "BGRA Basic skin smoothing uses bounded luminance blending inside the existing pixel transform."
  - "Public facade no-detection Basic skin remains active, while explicit internal no-face resolver contexts may skip skin."
  - "Public missing-input warning codes avoid the forbidden landmark term."
patterns-established:
  - "SkinBasicEffectTests covers CIImage and pixel-buffer Basic skin behavior with channel-level assertions."
  - "Facade-visible Basic skin behavior is protected from the host-facing BeautySDK target."
requirements-completed: [SKIN-02, SKIN-03]
duration: 117 min
completed: 2026-06-27
---

# Phase 18 Plan 18-02: Basic Skin Formula and Facade Coverage Summary

**Conservative Basic skin smoothing now affects both CIImage and BGRA paths, with focused tests proving public no-detection output and redacted resolver metadata.**

## Performance

- **Duration:** 117 min
- **Started:** 2026-06-27T10:55:17Z
- **Completed:** 2026-06-27T12:52:00Z
- **Tasks:** 3
- **Files modified:** 10

## Accomplishments

- Added `SkinBasicEffectTests` covering no-op preservation, whitening luminance lift, rosy red bias, sharpen contrast direction, smoothing channel-spread reduction, and capped medium-strength combo output.
- Improved `BeautyColorEffectPipeline` only inside the existing CIImage and BGRA color paths: CI smoothing now uses conservative saturation reduction, and BGRA smoothing uses stronger bounded luminance blending.
- Added resolver tests for public `resolve(parameters:)` Basic skin activation without face geometry and explicit internal `resolve(parameters:faceGeometry:nil)` skin skipping with redacted warnings.
- Added public `BeautySDK` facade tests proving no-detection Basic skin produces visible same-extent image output and returns redacted metadata.
- Renamed public missing-input warning codes from `*_landmarks_missing` to `*_inputs_missing` so resolver/engine metadata scans do not expose landmark terms.

## Task Commits

1. **Task 1 RED: Implement conservative Basic skin formula regressions** - `c4c8a02`
2. **Task 1 GREEN: Improve Basic skin smoothing formula** - `6545f81`
3. **Task 2: Verify resolver layering and public facade no-detection output** - `4d5d36c`

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift` - New focused Basic skin formula regression tests.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` - Localized CIImage and BGRA Basic skin smoothing formula updates.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Redacted missing-input warning code names.
- `BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift` - Aligned internal missing-input skip reason.
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` - Aligned internal missing-input skip reason.
- `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` - Aligned internal missing-input skip reason.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` - Added public/internal no-face Basic skin resolver tests.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Updated expected redacted warning codes.
- `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift` - Updated expected redacted skip reason.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` - Added public facade no-detection Basic skin output and metadata tests.

## Decisions Made

- Kept public `BeautyParameters` unchanged.
- Kept Basic skin implementation inside the existing `BeautyColorEffectPipeline` instead of adding a new target, pass, renderer case, or production `SkinPass`.
- Treated the existing `landmark` warning-code term as a public metadata redaction mismatch and renamed it to `inputs` while preserving degradation semantics.

## Verification

- RED evidence: `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter SkinBasicEffectTests` initially compiled and failed only `testSkinSmoothingMovesChannelsTowardLuminanceWithoutFlatteningTextureProxy`, proving the CI path did not yet reduce channel spread for `skinSmoothing`.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter SkinBasicEffectTests` passed at 2026-06-27T12:51:22Z with 6 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectResolverTests` passed at 2026-06-27T12:51:29Z with 6 tests.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEngineTests` passed at 2026-06-27T12:51:35Z with 11 tests.
- Additional regression evidence: `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` passed with 53 selected tests after the warning-code rename.
- `! rg -n "blemish|pore|texture|skinRepair|teeth|hairline" BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` passed.
- `! rg -n "skinRepair|repair|teeth|hairline|blemish|pore" BeautySDK/Sources/BeautyExampleRenderer/main.swift` passed.
- `! rg -n "skinRepair|blemish|pore|inpainting|teeth whitening|hairline adjustment|segmentation" BeautySDK/Sources/BeautyEffects BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyResources` passed.
- `! rg -n "landmark|boundingBox|VNFaceObservation|/private/var|NSError|rawPresetJson|image bytes" BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift BeautySDK/Sources/BeautySDK/BeautyEngine.swift` passed after redacted warning-code rename.
- `git diff --check -- BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift .planning/phases/18-skin-retouch-core-modules/18-02-SUMMARY.md` passed.

Full `swift test --package-path BeautySDK` was not run; Phase 18 D-17 fixes the required implementation gate as the focused tests plus renderer evidence and negative scans.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Public warning codes used the forbidden landmark term**
- **Found during:** Task 2 static redaction scan.
- **Issue:** Existing resolver warning codes `eye_landmarks_missing`, `nose_landmarks_missing`, `mouth_landmarks_missing`, and `lip_landmarks_missing` caused the public metadata scan to fail.
- **Fix:** Renamed public warning codes and aligned internal skip reasons to `eye_inputs_missing`, `nose_inputs_missing`, `mouth_inputs_missing`, and `lip_inputs_missing`; updated tests.
- **Files modified:** `BeautyEffectResolver.swift`, `EyeWarpProvider.swift`, `NoseWarpProvider.swift`, `MouthWarpProvider.swift`, `MissingLandmarkDegradationTests.swift`, `MouthWarpProviderTests.swift`.
- **Verification:** `BeautyEffectsTests`, `BeautyEngineTests`, and the redaction scan passed.
- **Committed in:** `4d5d36c`

---

**Total deviations:** 1 auto-fixed missing-critical metadata issue.
**Impact on plan:** The fix preserves existing degradation semantics while satisfying Phase 18 redaction and no-leakage constraints.

## Issues Encountered

- SwiftPM package tests failed inside the managed filesystem sandbox with `sandbox_apply: Operation not permitted`; focused tests were rerun with approved outside-sandbox execution and `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 18-03 can build and run `BeautyExampleRenderer` against all five current Basic skin cases, inspect representative outputs, and close SKIN traceability only after renderer, dimension, visual-observation, import, and future-branch scans pass.

---
*Phase: 18-skin-retouch-core-modules*
*Completed: 2026-06-27*
