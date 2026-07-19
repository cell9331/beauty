---
phase: 43-public-facade-eye-geometry-output-evidence
review: post-phase-gaze-evidence-fix
status: fixed
severity: blocker
requirements: [EYE-18]
---

# Phase 43 Review Fix — Gaze Evidence

## Finding

The original `paired_eye_deviation` helper compared a left ROI against a
mirrored right ROI. That scalar measured RGB asymmetry, not pupil-to-neutral
center displacement. An unrelated color or contour asymmetry could therefore
reduce the score and falsely satisfy EYE-18.

## Fix

- Added package-internal `GazeCorrectionAggregateEvidence` and
  `EyeWarpProvider.gazeCorrectionEvidence(face:strength:)`.
- The aggregate is derived from the same validated pupil/center sample and
  target used to emit gaze control points. It records only eligible-eye count,
  baseline offset, and corrected offset; no points, side labels, or payloads
  leave the package target.
- Added provider tests proving two eligible eyes reduce their aggregate offset,
  neutral pupils no-op, and contour tilt/asymmetry cannot alter the scalar.
- Removed the RGB mirror score from strict fixture acceptance. The helper now
  keeps a fixed per-eye dark-core centroid experiment solely for adversarial
  self-tests: a synthetic toward-neutral shift reduces deviation, an unrelated
  bright/color patch is invariant, and one-sided asymmetry cannot pass.
- Updated committed evidence, validation, summaries, example docs, and the
  phase review record to retire the unsound score and identify the package
  aggregate as the authoritative gaze-reduction gate.

## Verification

- `swift test --package-path BeautySDK --filter EyeWarpProviderTests.testPhase42TiltSignsAndPupilGazeAreBoundedAndMonotonic` — pass.
- `python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py --self-test` — pass, including dark-core reduction/color/asymmetry adversarial cases.
- `python3 -m py_compile .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py` — pass.
- `git diff --check` — pending final parent verification after this atomic commit.

The public-facade 385-output visibility evidence remains independent; this fix
does not claim that current PNG bytes expose a stable pupil displacement.
