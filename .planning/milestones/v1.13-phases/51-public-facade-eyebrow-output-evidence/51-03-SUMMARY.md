---
phase: 51-public-facade-eyebrow-output-evidence
plan: "03"
subsystem: public-facade-output-validation
tags: [eyebrow, renderer, pixels, visual-review]
requires:
  - phase: 51-02
    provides: Bounded e6-only output helper and adversarial self-tests
provides:
  - Frozen e6 brow-local, protected-region, signed-direction, and family-distinction contract
  - Accepted 72-portrait/13-negative/144-total public-facade render evidence
  - Original-detail review record for the baseline and all thirteen eyebrow outputs
affects: [51-04-gallery-publication, 51-05-owner-closeout, 52-safety-promotion]
tech-stack:
  added: []
  patterns:
    - Measurement and strict acceptance use separate guarded clean renders
    - Fixed visual predicates are paired with mandatory actual-image review
key-files:
  created:
    - .planning/phases/51-public-facade-eyebrow-output-evidence/51-EYEBROW-OUTPUT-EVIDENCE.md
  modified:
    - .planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py
    - BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
key-decisions:
  - "Freeze positive e6 thresholds only after measurement and require strict mode to consume an immutable calibration object."
  - "Treat actual-image contradictions as implementation defects; preserve Phase 52 ownership of final caps and product promotion."
patterns-established:
  - "Exact output vocabulary: 72 e6 portrait outputs, thirteen separate no-face comparisons, 144 total disposable files."
  - "Review every actual eyebrow output at original detail before recording a passing visual verdict."
requirements-completed: [OUT-02, OUT-03]
duration: "interrupted run; exact active duration unavailable"
completed: 2026-07-27
---

# Phase 51 Plan 03: Frozen Eyebrow Output Acceptance Summary

**Frozen decoded-pixel gates and fourteen-file original-detail review accept the exact e6 public-facade eyebrow matrix without promoting final caps or product status.**

## Performance

- **Completed:** 2026-07-27T01:16:00Z
- **Tasks:** 2/2
- **Durable output:** one strict helper and one aggregate evidence record
- **Interruption:** execution resumed after a transient 504; prior active duration was not recoverable

## Accomplishments

- Accepted 72/72 decoded 1728×2304 e6 portrait outputs while reporting thirteen no-face no-ops separately inside the exact 144-file inventory.
- Passed 13/13 visibility/locality, 6/6 signed-direction, 21/21 family-distinction, 40/40 total portrait comparison, and 13/13 no-face gates with fixed positive margins.
- Opened the baseline and all thirteen actual eyebrow files individually at original detail; the visual review confirmed direction, brow locality, protected-region stability, and separation of whole/head spacing and thickness/peak.
- Corrected the actual Vision sample ordering and top-left image-Y bitmap route exposed by the e6 render without raising provisional caps, synthesizing support, or broadening public scope.

## Task Commits

1. **Root-cause correction: align live eyebrow image geometry** — `77e9228` (fix)
2. **Bound the strict helper decoded-matrix cache** — `a0febc8` (perf)
3. **Lock the immutable calibration contract before acceptance** — `b3858d8` (test)
4. **Freeze accepted strict metrics and actual-image evidence** — `bdd3df2` (test)

## Files Created/Modified

- `.planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py` — Fixed ROI/protected rectangles, immutable floors/ceilings, semantic signed predicates, strict reporting, and adversarial calibration tests.
- `.planning/phases/51-public-facade-eyebrow-output-evidence/51-EYEBROW-OUTPUT-EVIDENCE.md` — Guarded chronology, exact counts, thresholds/margins, strict results, corrections, and fourteen-row visual review.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` — Stable live eyebrow sample ordering on the mapper-derived face-right axis.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` — Preserved canonical mapped ordering at adapter validation.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` — Canonical top-left/downward image-Y bitmap sampling.
- Focused detector, adapter, pipeline, and facade tests — Locked actual e6 correction behavior and unchanged privacy/lifecycle boundaries.

## Decisions Made

- Kept the renderer case strengths at provisional `±0.25`/`0.25`; visible extremity and commercial naturalness remain Phase 52 calibration concerns.
- Used robust 5%–95% deformation extents for thickness and length direction so the strict predicate measures vertical strip expansion and horizontal outer-end expansion rather than a generic change centroid.
- Recorded aggregate metrics and generated filenames only; raw Vision/framework regions, mapped points, pixels, and support payloads remain absent from durable evidence.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected actual live eyebrow orientation and bitmap Y**

- **Found during:** Task 51-03-01 measurement render
- **Issue:** Synthetic provider fixtures hid an inverted CPU bitmap image-Y route and live Vision outlines whose adjacent raw endpoints could begin at the same anatomical end.
- **Fix:** Aligned sampling with canonical top-left image coordinates and ordered the exactly-once mapped Vision sample multiset on the mapper-derived face-right axis.
- **Files modified:** Detection, adapter, render pipeline, focused tests, and routed owner notes.
- **Verification:** Fresh e6 render, strict pixel gates, actual-image review, focused provider suite, and full plan closeout gates.
- **Commit:** `77e9228`

**2. [Rule 2 - Critical] Bounded strict helper decode retention**

- **Found during:** Task 51-03-01 strict calibration
- **Issue:** Retaining unbounded repeated decoded matrices increased resource use during the exact 144-file gate.
- **Fix:** Kept one bounded decoded-matrix cache for the run.
- **Files modified:** Phase 51 strict helper.
- **Verification:** Helper self-test and full strict pass.
- **Commit:** `a0febc8`

**Total deviations:** 2 auto-fixed (one correctness bug, one critical bounded-resource correction). **Impact:** The planned public-facade evidence became honest on the actual e6 route; scope, dependencies, provisional caps, and promotion ownership were unchanged.

## Verification

- `check_eyebrow_renderer_outputs.py --self-test`: passed.
- Python bytecode compilation: passed.
- `BeautyEffectsTests.EyebrowWarpProviderTests`: 12/12 passed.
- Independent/final strict helper: passed with 72/72 portrait, 13/13 visibility, 6/6 directions, 21/21 distinctions, 40/40 portrait comparisons, and 13/13 no-face no-ops.
- Visual review evidence rows: 14/14; verdict `PASS`.
- `git diff --check`: passed.

## Known Stubs

None.

## Threat Flags

None. The corrected request-local detection/bitmap path stays within the existing Phase 49/50 trust boundaries; no endpoint, auth path, persistent file access, network behavior, schema, or public raw-geometry surface was added.

## Next Phase Readiness

Plan 51-04 can publish the exact descriptor-safe 144-file gallery from the accepted output matrix. Phase 52 still owns final caps, exhaustive transition/convergence evidence, seven-row promotion, branch `眉毛`, and broader safety/nonclaim closeout.

## Self-Check: PASSED

- Evidence and helper exist.
- Commits `77e9228`, `a0febc8`, `b3858d8`, and `bdd3df2` exist in history.
- The fourteen-row visual-review check, focused provider suite, strict helper, and diff hygiene passed.
