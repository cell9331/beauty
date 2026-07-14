---
phase: 27-geometry-render-output-and-verification-harness
plan: "03"
subsystem: renderer
tags: [example-renderer, png-helper, geometry, no-face, evidence]
requires:
  - phase: 27-geometry-render-output-and-verification-harness
    provides: 27-02 selected-face still-image geometry output path
provides:
  - Public-facade renderer matrix with no-op geometry baseline and one combined face-shape case.
  - Dedicated committed no-face input fixture for geometry degradation evidence.
  - Phase 27 generated-output helper validating 66 ignored PNG outputs and 5/5 geometry-vs-baseline portrait comparisons.
affects: [phase-27, phase-28, example-image-validation]
tech-stack:
  added: []
  patterns: [renderer baseline comparison, ignored generated-output helper]
key-files:
  created:
    - example-images/input/no-face-gradient.png
    - .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py
    - .planning/phases/27-geometry-render-output-and-verification-harness/27-03-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/main.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
key-decisions:
  - "Renderer geometry scope stays limited to one combined face-shape case and one no-geometry baseline case."
  - "Phase 27 helper records counts, dimensions, case IDs, fixture names, no-face presence, and baseline comparison counts without hashes or raw payloads."
patterns-established:
  - "Generated geometry PNG evidence remains local under ignored example-images/out/."
  - "Saved-output geometry helper compares faceShapeCombo_0p35 against geometryBaseline_noop for portrait fixtures."
requirements-completed: [GEO-03, GEO-04]
duration: 5 min
completed: 2026-07-07
---

# Phase 27 Plan 03: Renderer Matrix and Geometry Helper Summary

**BeautyExampleRenderer now emits ignored saved-output PNGs for a geometry baseline, one combined face-shape case, and a dedicated no-face fixture.**

## Performance

- **Duration:** 5 min
- **Started:** 2026-07-07T07:08:15Z
- **Completed:** 2026-07-07T07:13:26Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Appended `geometryBaseline_noop` and `faceShapeCombo_0p35` to the public-facade renderer case matrix.
- Added committed input fixture `example-images/input/no-face-gradient.png` for no-face geometry saved-output evidence.
- Expanded `BeautyRendererOutputRegressionTests` to cover 11 renderer case IDs, 6 input fixtures, face-shape-only scope, and no-face summary redaction.
- Added `check_geometry_renderer_outputs.py`, which verified 66/66 generated PNG outputs, 5/5 portrait geometry-vs-baseline top-region comparisons, and no-face geometry output presence.

## Task Commits

1. **Task 27-03-01: Append baseline and combined face-shape cases to the public-facade renderer** - `14ec1f5` (feat)
2. **Task 27-03-02: Create the Phase 27 geometry output helper and run generated-output checks** - `160702a` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - Adds `geometryBaseline_noop` and `faceShapeCombo_0p35`.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - Updates renderer inventory, adds no-face fixture coverage, and checks the geometry case scope.
- `example-images/input/no-face-gradient.png` - Dedicated 96x96 no-face input fixture.
- `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` - Validates Phase 27 generated geometry outputs.

## Decisions Made

- Kept the renderer executable public-facade-only with only `import BeautySDK`.
- Kept the new geometry renderer scope to the five Phase 27 face-shape parameters: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 4 tests.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 66 local PNG outputs.
- `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` passed with `66/66 outputs`, `portrait geometry-vs-baseline top-region comparisons: 5/5`, and no-face output present.
- `git check-ignore example-images/out/e1__faceShapeCombo_0p35.png example-images/out/e1__geometryBaseline_noop.png example-images/out/no-face-gradient__faceShapeCombo_0p35.png` confirmed representative generated PNGs are ignored.
- Renderer public-import scan, geometry-scope scan, helper-output raw-leak scan, and scoped `git diff --check` passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 27-04 to record final evidence, run full SDK and degradation gates, and synchronize durable docs and ledgers without promoting Phase 28 face-shape tool status.

---
*Phase: 27-geometry-render-output-and-verification-harness*
*Completed: 2026-07-07*
