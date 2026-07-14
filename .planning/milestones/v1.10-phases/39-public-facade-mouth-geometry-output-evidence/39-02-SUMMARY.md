---
phase: 39-public-facade-mouth-geometry-output-evidence
plan: "02"
subsystem: generated-output-evidence
tags: [python, png-decoder, mouth-roi, public-facade, no-face]
requires:
  - phase: 39-01
    provides: exact 44-case renderer and eight new mouth cases
provides:
  - archive-safe strict 44-by-7 output matrix validator
  - frozen mouth ROI and non-circular global evidence floors
  - strict visibility, direction, independence, and no-face output evidence
affects: [39-03, phase-40]
tech-stack:
  added: []
  patterns: [bounded no-follow PNG acquisition, discovered inventory before frozen assertion, measurement then fresh strict render]
key-files:
  created:
    - .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py
    - .planning/phases/39-public-facade-mouth-geometry-output-evidence/39-MOUTH-OUTPUT-EVIDENCE.md
  modified: []
key-decisions:
  - "Use one top-origin normalized mouth ROI x 0.10-0.90 and y 0.40-0.82 for all portrait pairs."
  - "Freeze global floors at 1000 changed pixels and 10000 absolute RGB delta after measuring minima of 1921 and 16651."
patterns-established:
  - "Generated evidence discovers live inventories, validates every byte and dimension, then separately freezes the expected matrix."
  - "Semantic evidence uses direct pair families; no strong family can mask a weak or aliased path."
requirements-completed: [MOUTH-09, MOUTH-10, MOUTH-11]
duration: 9 min
completed: 2026-07-14
---

# Phase 39 Plan 02: Strict Mouth Output Evidence Summary

**A self-contained bounded decoder accepted a fresh 308-output public-facade matrix with all sixteen mouth visibility, direction, and independence families plus eight exact no-face no-ops.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-07-14T08:28:00Z
- **Completed:** 2026-07-14T08:37:00Z
- **Tasks:** 2
- **Files created:** 2

## Accomplishments

- Re-owned the hardened standard-library PNG/JPEG evidence boundary with no-follow bounded reads, full PNG decode, race checks, inventory discovery, and deterministic negative self-tests.
- Measured one fixed mouth ROI, froze non-circular floors below the weakest observed family, then performed a separate guarded clean accepting render.
- Strictly accepted 308/308 decoded same-dimension PNGs with exact aggregate totals of 48 visibility, 18 signed-direction, 12 peak-independence, and 18 plump-independence comparisons.
- Proved all eight new 64 × 64 no-face outputs are baseline-identical across the fixed 2,048-pixel right-half fallback.
- Full SwiftPM passed 260/260 tests with zero failures.

## Task Commits

1. **Task 39-02-01: Self-contained decoder and evidence gate** — `8258c2e` (test)
2. **Task 39-02-02: Freeze non-circular thresholds** — `e9ea8a6` (test)
3. **Task 39-02-02: Record strict output evidence** — `f093a18` (docs)

## Files Created

- `.planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py` — archive-safe strict matrix, ROI, family, and no-face validator.
- `.planning/phases/39-public-facade-mouth-geometry-output-evidence/39-MOUTH-OUTPUT-EVIDENCE.md` — observed inventories, commands, thresholds, minima, margins, and non-claims.

## Decisions Made

- Froze the ROI at x `[0.10,0.90)` and y `[0.40,0.82)` after verifying it stays above the renderer-matched watermark boundary for every portrait.
- Chose floors of 1,000 changed pixels and 10,000 RGB delta against measured minima of 1,921 and 16,651, leaving explicit margins of 921 and 6,651.
- Kept `lipColor_0p50` as a nearest non-alias comparator only; no physical-plumping claim is derived from it.

## Deviations from Plan

None.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 39-03 can publish the exact ignored 308-file gallery and synchronize current evidence owners.
- Final caps, exhaustive degradation/conflict behavior, promotion, and branch closeout remain Phase 40 work.

## Self-Check: PASSED

- Helper self-tests and Python compilation pass.
- Fresh strict render passed 44 × 7 = 308 outputs and all 96 portrait plus eight no-face comparisons.
- Full SwiftPM passed 260/260; generated outputs are ignored and untracked; `git diff --check` passed.

---
*Phase: 39-public-facade-mouth-geometry-output-evidence*
*Completed: 2026-07-14*
