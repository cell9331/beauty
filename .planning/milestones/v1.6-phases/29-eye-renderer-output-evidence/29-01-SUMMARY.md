---
phase: 29-eye-renderer-output-evidence
plan: "01"
subsystem: renderer-output
tags: [BeautyExampleRenderer, eye, output-helper, regression]
requires:
  - phase: 28-face-shape-slice-completion-and-documentation-closeout
    provides: Face-shape renderer case matrix and helper pattern
provides:
  - Six locked public-facade eye renderer cases
  - Phase 29 helper for 161 renderer outputs and 36 eye-vs-baseline comparisons
affects: [phase-29, phase-30, example-images]
tech-stack:
  added: []
  patterns: [standard-library PNG helper, public-facade renderer inventory guard]
key-files:
  created:
    - .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/main.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
key-decisions:
  - "Phase 29 eye evidence uses exactly six single-parameter public-facade renderer cases."
  - "The helper compares eye outputs to geometryBaseline_noop above the watermark band."
patterns-established:
  - "Eye renderer output evidence mirrors the Phase 28 full-matrix helper pattern."
requirements-completed: [EYE-01, EYE-02]
duration: 8 min
completed: 2026-07-09
---

# Phase 29 Plan 01: Eye Renderer Output Helper Summary

**Public-facade eye renderer cases plus a Phase 29 helper proving 161 generated outputs and 36 eye-vs-baseline comparisons**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-09T06:42:00Z
- **Completed:** 2026-07-09T06:50:20Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added exactly six Phase 29 eye renderer cases: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- Updated renderer regression coverage to require the 23-case public-facade matrix and prove each Phase 29 eye case uses one existing public eye field.
- Added `check_eye_renderer_outputs.py`, validating `161/161` generated PNG outputs, `36/36` portrait eye-vs-`geometryBaseline_noop` top-region comparisons, and representative no-face output presence.

## Task Commits

Each task was committed atomically:

1. **Task 29-01-01: Add locked eye renderer cases and inventory guards** - `c1065a6` (feat)
2. **Task 29-01-02: Create the Phase 29 eye output helper** - `b67a808` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - Added the six locked eye `RenderCase` entries after the face-shape cases.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - Extended the expected renderer inventory to 23 IDs and added the Phase 29 eye public-parameter guard.
- `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` - Added the Phase 29 full-matrix and eye-vs-baseline output helper.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 7 tests.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` passed and generated 161 ignored PNG outputs.
- `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` passed with `161/161` outputs and `36/36` comparisons.
- Representative `git check-ignore` checks passed for generated eye outputs.
- Renderer import/scope scans, helper-output raw-leak scan, Python compile, and scoped `git diff --check` passed.

## Decisions Made

- The case matrix follows the locked Phase 29 IDs and strengths from `29-CONTEXT.md`.
- The helper reuses the Phase 28 top-region comparison approach so watermark text cannot satisfy eye-output evidence.

## Deviations from Plan

None - plan executed exactly as written.

**Total deviations:** 0 auto-fixed.
**Impact on plan:** No scope changes.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 29-02 to add generated `eyes/` gallery routing and example-image documentation updates. Phase 29 still does not promote `眼睛` ledger rows; that remains Phase 30 scope.

## Self-Check: PASSED

- All plan tasks are committed.
- Summary exists and records the command-backed helper result.
- Key files listed above exist on disk.
- Requirements completed by this plan are copied from the plan frontmatter.

---
*Phase: 29-eye-renderer-output-evidence*
*Completed: 2026-07-09*
