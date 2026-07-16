---
phase: 43-public-facade-eye-geometry-output-evidence
plan: "02"
subsystem: renderer-output-evidence
tags: [python, png, decoder, eye-roi, eligibility]
requires: [43-01-exact-renderer-matrix, phase-42-eye-pipeline]
provides: [strict-385-output-gate, frozen-eye-roi, tilt-gaze-semantic-evidence]
affects: [43-03, phase-44]
tech-stack:
  added: []
  patterns: [bounded-descriptor-decoding, frozen-threshold-rerun, eligibility-aware-output-evidence]
key-files:
  created:
    - .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py
    - .planning/phases/43-public-facade-eye-geometry-output-evidence/43-EYE-OUTPUT-EVIDENCE.md
  modified: []
key-decisions:
  - "Use one stored-row ROI x=.10-.90/y=.55-.82 with fixed 500/1000 visibility floors."
  - "Use fixed e1 tilt polarity and e6 paired-eye gaze-reduction evidence without exposing raw geometry."
requirements-completed: [EYE-16, EYE-17, EYE-18]
coverage:
  - deliverable: "Bounded strict 385-output same-dimension decoder and matrix gate"
    verification:
      - kind: command
        ref: "check_eye_geometry_renderer_outputs.py --self-test and strict mode"
        status: pass
    human_judgment: false
  - deliverable: "Fixed eye-local visibility, tilt, semantics, gaze, symmetry, and no-face evidence"
    verification:
      - kind: command
        ref: "fresh clean strict renderer/helper run: 66/66 visibility, 6/6 tilt, 60/60 semantics, 11/11 no-face"
        status: pass
    human_judgment: false
duration: 48 min
completed: 2026-07-16
status: complete
---

# Phase 43 Plan 02: Strict Eye Output Evidence Summary

A bounded standard-library decoder now accepts exactly 385 fresh public-facade PNG outputs through one frozen eye-local ROI, independent semantic-family gates, signed tilt polarity, eligibility-aware gaze reduction, and no-face containment.

## Accomplishments

- Adapted the hardened descriptor-safe PNG/JPEG acquisition and full PNG CRC/chunk/zlib/filter decoder with 16 MiB file, 4096×4096 dimension, and 64 MiB decoded ceilings.
- Froze the 55×7 inventory, `x=.10-.90/y=.55-.82` ROI, 500 changed-pixel floor, and 1,000 RGB-delta floor after a separate clean measurement.
- Fresh strict acceptance passed 385/385 outputs, 66/66 new-field visibility comparisons, 6/6 direct signed-tilt comparisons, 60/60 semantic distinctions, and 11/11 no-face no-ops.
- Recorded complete contour/pupil/symmetry eligibility on all six portraits, a fixed paired-eye gaze-deviation reduction of 6,364, and aggregate-only evidence without raw support data.

## Task Commits

- `a798110` — `feat(43-02): add bounded eye output evidence gate`
- `4825871` — `docs(43-02): record strict eye output evidence`

## Verification

- Helper `--self-test` — passed all duplicate, malformed, stale, symlink, bounds, race, decompression, ROI, and no-face negative paths.
- `python3 -m py_compile .../check_eye_geometry_renderer_outputs.py` — passed.
- Fresh clean renderer output — exactly 385 PNGs.
- Strict helper — 385/385 fully decoded same-dimension outputs; exit 0.
- `git diff --check` — passed.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected the ROI for stored PNG row orientation**

- **Found during:** Task 43-02-02 measurement.
- **Issue:** The first top-origin visual estimate selected `y=.10-.52`, while decoded renderer rows place the observed eye deformation at `y=.55-.82`; all measured deltas were zero.
- **Fix:** Measured the decoded-row bounds, froze the single corrected ROI, then performed an independent clean accepting render.
- **Files modified:** `check_eye_geometry_renderer_outputs.py`
- **Verification:** All required visibility and semantic families are nonzero with explicit margins.
- **Commit:** `a798110`

**Total deviations:** 1 auto-fixed bug. **Impact:** Evidence now targets the actual eye deformation region while retaining one fixed watermark-safe ROI for every portrait.

## Security and Scope

- No external dependency, network access, raw geometry output, internal renderer import, or generated binary entered git.
- Final caps, exhaustive safety/degradation, boundary closeout, promotion, and branch status remain Phase 44.

## Self-Check: PASSED

- Both created artifacts and both task commits exist.
- Ready for 43-03 gallery publication and final tracking gates.
