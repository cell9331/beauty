---
phase: 36-public-facade-output-evidence
plan: "02"
subsystem: renderer-output-evidence
tags: [python, png-decoder, roi, public-facade, nose-geometry]

requires:
  - phase: 36-public-facade-output-evidence
    plan: "01"
    provides: exact 36-case renderer inventory and isolated public nose cases
provides:
  - archive-safe discovered-inventory PNG decoder and malformed-output self-tests
  - clean 36-by-7 public-facade matrix with exact 252 decoded same-dimension outputs
  - fixed-threshold nose visibility and direct legacy non-alias evidence
affects: [36-03-gallery-closeout, 37-nose-safety-boundary]

tech-stack:
  added: []
  patterns: [discovered inventory before frozen assertion, measurement then fixed-threshold clean strict rerun]

key-files:
  created:
    - .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py
    - .planning/phases/36-public-facade-output-evidence/36-NOSE-OUTPUT-EVIDENCE.md
  modified: []

key-decisions:
  - "Use one top-origin normalized x=25%-75%, y=20%-70% nose ROI and fixed global floors of 500 changed pixels plus 2,000 absolute RGB delta."
  - "Discover renderer cases and recursive fixtures before independently requiring the frozen 36 x 7 = 252 Phase 36 inventory."
  - "For the 64 x 64 no-face fixture, use a fixed right-half watermark-safe fallback because the renderer's minimum label band leaves zero complete rows above it."

patterns-established:
  - "Generated evidence acceptance requires guarded clean regeneration, full PNG decode, exact extent, and unexpected-output rejection."
  - "Visibility and independence remain five separately reported six-portrait families; aggregate success cannot mask one field or signed legacy comparison."

requirements-completed: [NOSE-07, NOSE-08, NOSE-09]

duration: 10 min
completed: 2026-07-13
---

# Phase 36 Plan 02: Remaining-Nose Public-Facade Output Evidence Summary

**A self-contained decoder validates a clean 252-PNG public-facade matrix and proves both remaining nose fields visible and distinct from their nearest legacy paths under fixed nose-local thresholds.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-07-13T09:12:20Z
- **Completed:** 2026-07-13T09:21:24Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added an archive-safe, standard-library-only helper that discovers 36 renderer cases and seven recursive fixtures, rejects duplicate IDs/stems and malformed matrices, fully decodes PNGs, and requires the independently frozen 252-output contract.
- Calibrated one global nose ROI from a clean measurement render, froze floors at 500 changed pixels and 2,000 absolute RGB delta below the observed 1,130/5,125 minima, then performed a second guarded clean strict render.
- Passed five separately gated six-portrait families: 12/12 new-field visibility, 6/6 root-versus-bridge independence, and 12/12 lift-versus-both-signed-tip independence.
- Preserved the 64 × 64 no-face extent and baseline-identical watermark-safe region for both new outputs, while keeping all 252 generated PNGs ignored and untracked.

## Task Commits

Each task was committed atomically:

1. **Task 36-02-01: Build the self-contained discovered-inventory decoder and ROI gate** - `bc9b597` (feat)
2. **Task 36-02-02: Generate, calibrate, freeze, rerun, and document the 252-output evidence** - `9ffd132` (test)

## Files Created/Modified

- `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py` - Discovers inventories, fully decodes the exact matrix, gates ROI families/no-face pixels, and self-tests negative paths.
- `.planning/phases/36-public-facade-output-evidence/36-NOSE-OUTPUT-EVIDENCE.md` - Records guarded commands, inventories, dimensions, fixed thresholds, observed minima, containment, and conservative non-claims.

## Verification

- Helper self-test passed duplicate renderer IDs, duplicate fixture stems, missing output, unexpected output, corrupt PNG, and ROI/watermark rejection cases; `py_compile` passed.
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- Both measurement and strict runs first resolved `example-images/output` to the exact repository allow-list, required `git check-ignore`, and deleted files only below that root.
- Final clean strict render/helper passed 36 cases × 7 fixtures = 252/252 non-empty, completely decoded, same-dimension PNGs with no unexpected output.
- Strict minima were root/baseline 1,130/5,125, lift/baseline 1,644/26,334, root/bridge 1,291/5,951, lift/positive-tip 1,839/20,433, and lift/negative-tip 2,132/34,911 for changed pixels/absolute RGB delta.
- No-face checks passed 2/2 at exact 64 × 64 with zero differences across 2,048 fixed watermark-safe pixels per comparison.
- Exact PNG count, representative ignore checks, empty tracked/staged generated routes, and `git diff --check` passed.
- ASVS L1 evidence-integrity review found no unresolved HIGH threat: clean allow-list deletion, duplicate rejection, CRC/full-stream decode, fixed pre-acceptance floors, watermark exclusion, aggregate-only evidence, and ignored artifacts cover the plan's stated threats.

## Decisions Made

- Fixed the ROI at x `[0.25, 0.75)` and y `[0.20, 0.70)` for every portrait; fixture-specific crops are not permitted.
- Fixed global floors at 500 changed pixels and 2,000 absolute RGB delta before the accepting render, leaving substantial margin below every observed family minimum without allowing an accepting run to tune itself.
- Classified the 64 × 64 fixture separately from portraits and excluded it from all 30 visibility/independence comparisons.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Replaced an impossible full-row no-face watermark comparison with a fixed watermark-safe fallback**

- **Found during:** Task 36-02-02 measurement validation
- **Issue:** The renderer's minimum 34-point label plus padding leaves zero complete rows above the watermark on the 64 × 64 negative fixture. Treating the plan's “above watermark” language literally would compare zero pixels; approximating the rounded band alone also allowed label overflow pixels.
- **Fix:** When the renderer-matched comparable-row count is zero, compare the fixed right half of the fixture (2,048 pixels), outside the observed left-origin label raster. Both new outputs must be exactly baseline-identical there.
- **Files modified:** `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py`, `.planning/phases/36-public-facade-output-evidence/36-NOSE-OUTPUT-EVIDENCE.md`
- **Verification:** The strict clean run passed both no-face cases with zero changed pixels and zero RGB delta; Plan 36-01 remains the diagnostic owner.
- **Committed in:** `9ffd132`

---

**Total deviations:** 1 auto-fixed bug. **Impact on plan:** The fallback prevents a vacuous zero-pixel pass and preserves the intended pre-watermark/no-label evidence without changing production behavior or expanding scope.

## Issues Encountered

- Full standard-library decoding of all 252 large PNGs is intentionally slower than header-only inspection; it completed successfully and provides the required corruption and pixel evidence.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Ready for `36-03-PLAN.md` to own gallery synchronization, current evidence indexes, containment closeout, and Phase 36 verification.
- This plan does not mark Phase 36 complete and does not promote requirements or product ledgers.
- Final caps, exhaustive six-field degradation/provider-empty coverage, exactly-once weakening, active-source boundaries, feature promotion, branch completion, and DOC-01 remain Phase 37.

## Self-Check: PASSED

---
*Phase: 36-public-facade-output-evidence*
*Completed: 2026-07-13*
