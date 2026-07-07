---
phase: 27-geometry-render-output-and-verification-harness
plan: "04"
subsystem: evidence
tags: [verification, ledgers, docs, redaction]
requires:
  - phase: 27-geometry-render-output-and-verification-harness
    provides: 27-03 renderer matrix, helper, and no-face output path
provides:
  - Final command-backed Phase 27 renderer and degradation evidence.
  - GEO-03 and GEO-04 completion in requirements and roadmap ledgers.
  - Root and blueprint documentation synchronized to Phase 27 evidence without per-tool face-shape promotion.
affects: [phase-27, phase-28, geometry-renderer, documentation]
tech-stack:
  added: []
  patterns: [redacted evidence closeout, ignored generated-output evidence, no-promotion ledger guard]
key-files:
  created:
    - .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md
    - .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md
    - .planning/phases/27-geometry-render-output-and-verification-harness/27-04-SUMMARY.md
  modified:
    - .planning/phases/27-geometry-render-output-and-verification-harness/27-VALIDATION.md
    - docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
    - .planning/STATE.md
    - ARCHITECTURE.md
    - DESIGN.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - QUALITY_SCORE.md
    - PLANS.md
key-decisions:
  - "Closed GEO-03/GEO-04 from command-backed Phase 27 evidence, not from generated PNG baselines or hashes."
  - "Kept Phase 28 as the owner for per-tool face-shape completion and ledger promotion."
patterns-established:
  - "Final renderer evidence records counts, dimensions, helper result, no-face evidence, and scan status without raw geometry payloads."
  - "Root docs summarize shipped behavior only and route tool status work forward."
requirements-completed: [GEO-03, GEO-04]
duration: 20 min
completed: 2026-07-07
---

# Phase 27 Plan 04: Final Evidence and Ledger Synchronization Summary

**Phase 27 now has final command-backed evidence and durable docs for saved-output geometry foundation behavior.**

## Performance

- **Duration:** 20 min
- **Started:** 2026-07-07T07:14:05Z
- **Completed:** 2026-07-07T07:40:00Z
- **Tasks:** 2
- **Files modified:** 14

## Accomplishments

- Created `27-GEOMETRY-RENDERER-EVIDENCE.md` with focused test results, renderer build/run evidence, helper output, no-face output evidence, ignored-output policy, representative factual notes, degradation evidence, and rerun protocol.
- Created `27-VERIFICATION.md` with GEO-03/GEO-04 coverage, D-01 through D-17 traceability, scan results, changed-file coverage, and Phase 28 boundary.
- Updated `27-VALIDATION.md` to final `status: passed`.
- Updated `EXAMPLE_IMAGE_VALIDATION.md`, root contracts, requirements, roadmap, state, quality score, and `PLANS.md` from `27-VERIFICATION.md` evidence.

## Task Commits

1. **Task 27-04-01: Record final renderer, degradation, validation, and verification evidence** - `3d8f9e2` (docs)
2. **Task 27-04-02: Synchronize durable docs and planning ledgers without Phase 28 promotion** - `dd1b5cd` (docs)

## Files Created/Modified

- `.planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md` - Records command-backed renderer and degradation evidence.
- `.planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md` - Records final requirement and decision traceability.
- `.planning/phases/27-geometry-render-output-and-verification-harness/27-VALIDATION.md` - Marks validation passed from observed commands.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - Updates the current renderer contract to 11 cases, 6 fixtures, 66 outputs, and the Phase 27 helper.
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` - Mark GEO-03/GEO-04 complete and route Phase 28.
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` - Summarize only the shipped Phase 27 behavior and evidence.

## Decisions Made

- Did not embed self-matching raw-leak regexes in evidence docs; scan results are recorded as passed with scopes and outcomes.
- Kept generated PNGs as local ignored artifacts and recorded Markdown evidence instead.
- Did not edit `SHAPE_FEATURE_LEDGER.md` face-shape rows or promote beauty-shaping README status.

## Deviations from Plan

None - plan executed as written.

## Issues Encountered

- A renderer wrapper attempt used a zsh reserved variable and failed before reporting. The renderer command was rerun with a neutral wrapper variable and passed, writing 66 outputs.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` passed with 8 tests.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 4 tests.
- Focused missing-landmark, no-face/stale/reused, combined-strength, and face-shape conflict-cap tests passed.
- `swift test --package-path BeautySDK` passed with 167 tests.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 66 ignored PNG outputs.
- `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` passed with 66/66 outputs, same dimensions, 5/5 portrait geometry-vs-baseline comparisons, and no-face output presence.
- `git check-ignore` confirmed representative generated geometry outputs are ignored.
- Evidence raw-leak, no-overclaim, public/SPI export, active-source redaction, renderer import/scope, Demo internal-import, face-shape ledger guard, GSD decision coverage, and scoped `git diff --check` scans passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Phase 28 discussion and planning for per-tool face-shape completion, including `下颌线` alias handling and status ledger promotion only where tool-specific evidence exists.

---
*Phase: 27-geometry-render-output-and-verification-harness*
*Completed: 2026-07-07*
