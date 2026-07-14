---
phase: 29-eye-renderer-output-evidence
plan: "02"
subsystem: example-images
tags: [gallery, documentation, eye, generated-output]
requires:
  - phase: 29-eye-renderer-output-evidence
    provides: 29-01 eye renderer cases and helper
provides:
  - Ignored generated eyes gallery grouping
  - Example-image validation documentation for Phase 29 eye evidence
affects: [phase-29, example-images, blueprint-docs]
tech-stack:
  added: []
  patterns: [ignored generated gallery groups, command-backed evidence docs]
key-files:
  created: []
  modified:
    - example-images/generate_gallery.py
    - example-images/README.md
    - docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md
key-decisions:
  - "Phase 29 gallery output uses an ignored eyes group for exactly the six locked eye cases."
  - "Example-image validation docs record renderer evidence while keeping eye status partial until Phase 30."
patterns-established:
  - "Generated gallery grouping follows feature-family directories under example-images/gallery/."
requirements-completed: [EYE-03, EYE-01, EYE-02]
duration: 5 min
completed: 2026-07-09
---

# Phase 29 Plan 02: Eye Gallery and Validation Docs Summary

**Ignored `eyes/` gallery routing and example-image docs for the Phase 29 public-facade eye renderer evidence path**

## Performance

- **Duration:** 5 min
- **Started:** 2026-07-09T06:50:30Z
- **Completed:** 2026-07-09T06:55:30Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added `CASE_GROUPS["eyes"]` with exactly the six locked Phase 29 eye case IDs.
- Updated `example-images/README.md` with the `eyes/` gallery group and Phase 29 helper command.
- Updated `EXAMPLE_IMAGE_VALIDATION.md` to use `example-images/output/`, list the six eye renderer cases, document `161` outputs and `36/36` comparisons, and keep `眼睛` status partial until Phase 30.

## Task Commits

Each task was committed atomically:

1. **Task 29-02-01: Add the ignored eyes gallery group** - `8b9a0fa` (docs)
2. **Task 29-02-02: Update example-image validation docs without eye status promotion** - `41ab3b3` (docs)

## Files Created/Modified

- `example-images/generate_gallery.py` - Added the `eyes` generated gallery group.
- `example-images/README.md` - Documented the `eyes/` group and Phase 29 helper command.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - Updated output path commands, current case matrix, helper expectations, and Phase 29 evidence wording.

## Verification

- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` passed and regenerated 161 ignored PNG outputs.
- `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` passed with `wrote 161 gallery PNGs`.
- Representative `git check-ignore` checks passed for generated `example-images/gallery/eyes/...` files.
- Case ID, helper expectation, `161`, `36/36`, no-face output, and partial-status scans passed for `EXAMPLE_IMAGE_VALIDATION.md`.
- `git diff --exit-code -- docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md docs/meitu-function-blueprint/FEATURE_MATRIX.md` passed; this plan did not change status ledgers.
- No-overclaim scan and scoped `git diff --check` passed.

## Decisions Made

- Kept `geometryBaseline_noop` in `face-shape/`; only the six Phase 29 eye cases were added to `eyes/`.
- Replaced legacy `example-images/out/` command text in the touched validation doc with `example-images/output/`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Replaced over-broad stale-path scan with slash-delimited guard**
- **Found during:** Task 29-02-02 verification
- **Issue:** The planned command `rg -n "example-images/out"` also matches the required canonical string `example-images/output/`.
- **Fix:** Ran `rg -n "example-images/out/" ...; test $? -eq 1` to prove no legacy output directory reference remains while preserving required `example-images/output/` commands.
- **Files modified:** None beyond the planned documentation update.
- **Verification:** Slash-delimited stale-path guard passed; explicit `example-images/output/` scan showed canonical command paths.
- **Committed in:** `41ab3b3`

**Total deviations:** 1 auto-fixed verification-command issue.
**Impact on plan:** No product, code, or documentation scope change.

## Issues Encountered

The `example-images/out` scan was a false positive against `example-images/output`; resolved by using the slash-delimited legacy path.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 29-03 to record command-backed Phase 29 renderer/helper/gallery evidence, verification, and validation artifacts.

## Self-Check: PASSED

- All plan tasks are committed.
- Summary exists and records the verification-command deviation.
- Key files listed above exist on disk.
- Requirements completed by this plan are copied from the plan frontmatter.

---
*Phase: 29-eye-renderer-output-evidence*
*Completed: 2026-07-09*
