---
phase: 24-renderer-output-regression-hardening
plan: "01"
subsystem: testing
tags: [swiftpm, xctest, renderer, public-facade, no-op]
requires:
  - phase: 21-baseline-audit-and-quality-ledger-refresh
    provides: Current renderer fixture and 45-output baseline
provides:
  - Focused `BeautyExampleRenderer` case inventory regression
  - Pre-watermark no-op fixture regression for `e1.png` through `e5.png`
  - Public-facade renderer boundary check for the executable source
affects: [renderer-output-regression, example-image-validation, v1.4]
tech-stack:
  added: []
  patterns: [SwiftPM XCTest source inventory scan, fixed DeviceRGB RGBA8 fixture comparison]
key-files:
  created: [BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]
  modified: []
key-decisions:
  - "Kept `BeautyExampleRenderer/main.swift` as the code-owned renderer matrix source."
  - "Used exact rendered RGBA byte equality for all five current fixtures; no tolerance fallback was needed."
patterns-established:
  - "Renderer matrix drift is checked by parsing `RenderCase` IDs in declaration order."
  - "Default `BeautyParameters` fixture checks call `BeautyEngine.processResult(image:metadata:parameters:)` before watermarking."
requirements-completed: [RENDER-01, RENDER-02]
duration: 4 min
completed: 2026-07-02
---

# Phase 24 Plan 01: Renderer Matrix and No-Op Regression Summary

**Public-facade renderer matrix and all-five-fixture no-op output are now covered by focused SwiftPM regression tests.**

## Performance

- **Duration:** 4 min
- **Started:** 2026-07-02T08:56:00Z
- **Completed:** 2026-07-02T09:00:04Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments

- Added `BeautyRendererOutputRegressionTests` in `BeautyCoreTests`.
- Protected the current 9-case `BeautyExampleRenderer` matrix and public `BeautySDK` facade boundary.
- Verified default `BeautyParameters` preserves `e1.png` through `e5.png` rendered pixels before watermarking with exact RGBA equality.

## Task Commits

Each task was committed atomically:

1. **Task 24-01-01: Add the code-owned renderer case inventory regression** - `459dc05` (test)
2. **Task 24-01-02: Add pre-watermark no-op fixture pixel regression** - `7b748f8` (test)

## Files Created/Modified

- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - Focused renderer matrix, facade-boundary, and pre-watermark no-op fixture regression tests.

## Decisions Made

- Exact rendered RGBA byte equality passed for all five fixtures with a fixed DeviceRGB `CIContext`, so no color-management tolerance was introduced.
- The test reads `BeautyExampleRenderer/main.swift` as the canonical matrix and does not add renderer cases or public parameters.

## Deviations from Plan

None - plan executed exactly as written.

**Total deviations:** 0 auto-fixed.
**Impact on plan:** None.

## Issues Encountered

None.

## Verification

Passed:

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests/testRendererCaseInventoryMatchesCurrentPublicFacadeMatrix` - 1 test, 0 failures.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` - 2 tests, 0 failures.
- `swift test --package-path BeautySDK` - 150 tests, 0 failures.
- `! rg -n 'import Beauty(Core|Detection|Effects|Render|Resources)' BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift BeautySDK/Sources/BeautyExampleRenderer/main.swift`.
- `! rg -n 'id: "(face|eye|nose|mouth|lip|chin|jaw|proportion|3d|brow)|BeautyParameters\([^)]*(faceSlim|faceSmall|faceVShape|jawSlim|chinLength|eyeSize|eyeDistance|eyeYPosition|eyeTailLift|noseSlim|noseWingSlim|noseTipSize|noseBridge|mouthSize|mouthWidth|smile|lipColor)' BeautySDK/Sources/BeautyExampleRenderer/main.swift`.
- `git diff --check -- BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan `24-02`: renderer build/run evidence, generated-output invariant helper, and durable example-image validation doc synchronization.

## Self-Check: PASSED

---
*Phase: 24-renderer-output-regression-hardening*
*Completed: 2026-07-02*
