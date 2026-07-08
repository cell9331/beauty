---
phase: 28-face-shape-slice-completion-and-documentation-closeout
plan: "01"
subsystem: renderer
tags: [example-renderer, face-shape, png-helper, geometry, evidence]
requires:
  - phase: 27-geometry-render-output-and-verification-harness
    provides: public-facade geometry baseline, combined face-shape case, no-face fixture, and top-region helper pattern
provides:
  - Six Phase 28 public-facade renderer cases for scoped face-shape parameters.
  - Renderer regression tests for the 17-case matrix, public-boundary guard, and jawSlim alias evidence.
  - Phase 28 generated-output helper validating 102 ignored PNG outputs and 30/30 per-tool top-region comparisons.
affects: [phase-28, example-image-validation, face-shape-ledger]
tech-stack:
  added: []
  patterns: [renderer per-tool evidence, ignored generated-output helper, top-region baseline comparison]
key-files:
  created:
    - .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py
    - .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-01-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/main.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
key-decisions:
  - "下颌线 remains alias-backed by the existing jawSlim renderer evidence; no separate renderer case or public parameter was added."
  - "Phase 28 helper records relative names, case IDs, dimensions, output counts, and top-region comparison counts without hashes, raw pixels, or raw geometry payloads."
patterns-established:
  - "Scoped face-shape tool completion evidence uses one public-facade renderer case per existing SDK parameter, with signed chinLength covered by positive and negative cases."
  - "Per-tool geometry evidence compares every Phase 28 case against geometryBaseline_noop above the watermark band."
requirements-completed: [FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06]
duration: 16 min
completed: 2026-07-08
---

# Phase 28 Plan 01: Per-Tool Renderer Cases and Helper Summary

**BeautyExampleRenderer now emits per-tool saved-output evidence for the scoped face-shape slice, with a helper proving same-dimension top-region deltas above the watermark band.**

## Performance

- **Duration:** 16 min
- **Started:** 2026-07-08T01:39:00Z
- **Completed:** 2026-07-08T01:55:06Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, and `jawSlim_0p35` to the public-facade renderer matrix.
- Expanded `BeautyRendererOutputRegressionTests` to expect 17 case IDs and guard Phase 28 cases against new public fields, Demo coupling, commercial gating, network/cloud behavior, and internal SDK imports.
- Added `check_face_shape_renderer_outputs.py`, which verified `102/102` generated PNG outputs and `30/30` portrait face-shape-vs-baseline top-region comparisons.
- Confirmed representative Phase 28 generated outputs remain ignored under `example-images/out/`.

## Task Commits

1. **Task 28-01-01: Add Phase 28 per-tool renderer cases and inventory tests** - `4cb9eed` (test)
2. **Task 28-01-02: Create per-tool top-region renderer helper and run output checks** - `2b0bc95` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - Adds six scoped per-tool face-shape renderer cases after `faceShapeCombo_0p35`.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - Updates the expected renderer case inventory and adds Phase 28 public-boundary and jawSlim alias guards.
- `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py` - Validates 17 renderer cases across 6 fixtures and compares Phase 28 cases against `geometryBaseline_noop` above the watermark band.

## Decisions Made

- Kept `下颌线` as status/documentation alias evidence backed by `jawSlim_0p35`; no distinct case, parameter, or algorithm was introduced.
- Optimized the helper's top-region comparison to stream rows and stop at the first pre-watermark pixel difference while preserving the Phase 27 comparison semantics.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first helper implementation decoded full PNGs repeatedly and was too slow for routine verification. It was replaced with a standard-library row-streaming comparison that preserves the same top-region evidence guard and passed the helper check in 2.1 seconds.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 6 tests.
- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 102 ignored PNG outputs.
- `python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out` passed with `102/102 outputs`, `portrait face-shape-vs-baseline top-region comparisons: 30/30`, and no-face `jawSlim_0p35` output presence.
- `git check-ignore example-images/out/e1__faceSlim_0p35.png example-images/out/e1__chinLength_minus0p30.png example-images/out/e1__jawSlim_0p35.png example-images/out/no-face-gradient__jawSlim_0p35.png` confirmed representative generated PNGs are ignored.
- Renderer public-import scan, hidden jawline/public-surface/commercial/network scan, helper-output raw-leak scan, and scoped `git diff --check` passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 28-02 to strengthen focused provider, cap, no-face, combined weakening, signed `chinLength`, and redaction evidence before durable status promotion.

---
*Phase: 28-face-shape-slice-completion-and-documentation-closeout*
*Completed: 2026-07-08*
