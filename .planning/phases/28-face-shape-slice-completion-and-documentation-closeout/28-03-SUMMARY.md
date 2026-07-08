---
phase: 28-face-shape-slice-completion-and-documentation-closeout
plan: "03"
subsystem: evidence
tags: [renderer-evidence, face-shape, redaction, non-claims]
requires:
  - phase: 28-face-shape-slice-completion-and-documentation-closeout
    provides: 28-01 renderer/helper evidence and 28-02 focused safety evidence
provides:
  - Command-backed Phase 28 renderer evidence for all six scoped face-shape rows.
  - Focused XCTest and static-scan evidence for safety, degradation, redaction, and alias sharing.
  - Conservative evidence artifact ready for scoped ledger and documentation promotion.
affects: [phase-28, verification, shape-feature-ledger, example-image-validation]
tech-stack:
  added: []
  patterns: [command-backed evidence, redacted Markdown evidence, pre-promotion non-claims]
key-files:
  created:
    - .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-FACE-SHAPE-RENDERER-EVIDENCE.md
    - .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-03-SUMMARY.md
  modified: []
key-decisions:
  - "Evidence maps the six scoped face-shape rows to exact renderer case IDs before any status promotion."
  - "Focused safety/degradation evidence is recorded as XCTest and static scan results rather than per-tool degradation PNG variants."
patterns-established:
  - "Phase evidence files record commands, counts, dimensions, warnings/metric names, and non-claims without generated PNG baselines or raw geometry payloads."
requirements-completed: [FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-03]
duration: 6 min
completed: 2026-07-08
---

# Phase 28 Plan 03: Renderer and Safety Evidence Summary

**Phase 28 now has durable command-backed evidence for scoped face-shape renderer outputs, safety/degradation tests, raw-leak scans, and conservative non-claims.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-07-08T02:00:45Z
- **Completed:** 2026-07-08T02:06:03Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Created `28-FACE-SHAPE-RENDERER-EVIDENCE.md` with renderer build/run evidence, helper output, output count `102`, dimensions, `30/30` top-region comparisons, and representative ignored-output checks.
- Mapped `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, and `jawSlim_0p35` to the six scoped `脸型` rows.
- Recorded `下颌线` as alias-backed by `jawSlim` and shared with `下颌角`.
- Appended focused XCTest evidence for renderer inventory, provider caps/missing contour, no-face degradation, combined weakening, signed `chinLength`, and redacted metrics.
- Recorded static scan evidence for public raw-geometry exports, hidden jawline/public-surface expansion, helper-output redaction, generated-output policy, and overclaim avoidance.

## Task Commits

1. **Task 28-03-01: Record renderer build, run, helper, and ignored-output evidence** - `841ef5a` (docs)
2. **Task 28-03-02: Record focused XCTest, scan, and non-claim evidence** - `d4c6391` (docs)

## Files Created/Modified

- `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-FACE-SHAPE-RENDERER-EVIDENCE.md` - Records command-backed Phase 28 renderer/helper/test/scan evidence and non-claims.

## Decisions Made

- Did not paste renderer run lines with local absolute output paths into evidence; the evidence records the command, output count, helper output, and representative ignored relative paths.
- Kept the evidence artifact as pre-promotion proof only; `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, and root/planning ledgers remain Plan 28-04 work.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Verification

- `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` wrote 102 PNG outputs.
- `python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out` passed with `102/102 outputs` and `30/30` top-region comparisons.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed with 6 tests.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests` passed with 8 tests.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests` passed with 5 tests.
- `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests` passed with 7 tests.
- Representative `git check-ignore` for Phase 28 generated outputs passed.
- Public/SPI raw-geometry export, hidden public-surface expansion, helper-output raw-leak, evidence raw-leak, no-overclaim, and scoped `git diff --check` scans passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 28-04 to finalize verification, promote exactly the six scoped `脸型` rows, keep branch-level `脸型` partial, and synchronize root/planning ledgers from this evidence.

---
*Phase: 28-face-shape-slice-completion-and-documentation-closeout*
*Completed: 2026-07-08*
