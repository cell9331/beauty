---
phase: 43-public-facade-eye-geometry-output-evidence
verified: 2026-07-19T22:00:00Z
status: passed
score: 3/3 must-haves verified
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 3/3
  gaps_closed:
    - "The unsound RGB mirror gaze score was replaced by package-internal aggregate pupil-to-own-center evidence."
  gaps_remaining: []
  regressions: []
---

# Phase 43 Verification

**Phase:** Public-Facade Eye Geometry Output Evidence  
**Verified:** 2026-07-16  
**Re-verified:** 2026-07-19 after `6e4704e`
**Status:** `passed` (post-fix re-verification)

## Requirements

| Requirement | Result | Evidence |
| --- | --- | --- |
| EYE-16 | PASS | 55 duplicate-free renderer cases; 385 fresh outputs; one-field public-facade tests |
| EYE-17 | PASS | Bounded helper; 385/385 strict decode; 66/66 visibility; 6/6 signed tilt; 60/60 semantic families |
| EYE-18 | PASS | Eligibility inventory; package-internal aggregate pupil-to-own-center reduction with two eligible eyes and adversarial neutral/no-op/asymmetry tests; 11/11 no-face no-ops; 385-file ignored gallery bijection |

## Gate Results

- Post-fix focused `EyeWarpProviderTests.testPhase42TiltSignsAndPupilGazeAreBoundedAndMonotonic`: 1/1 passed; two eligible eyes strictly reduce aggregate pupil-to-own-center offset, neutral pupils no-op, and contour tilt/asymmetry cannot alter the scalar.
- Post-fix full `swift test --package-path BeautySDK`: 305/305 passed.
- Helper self-test: passed all malformed, bounds, race, symlink, duplicate, stale, ROI, and no-face negative paths.
- Helper self-test: additionally passed dark-core toward-neutral reduction, unrelated bright/color invariance, and one-sided asymmetry rejection. This image-only metric is explicitly not used as a fixture gate.
- Helper compile: `python3 -m py_compile` passed.
- Fresh output inventory: exactly 385 PNG outputs from the clean renderer run.
- Independent post-fix strict helper: exit 0 with 385/385 decoded same-dimension outputs, 66/66 new-case visibility, 6/6 direct signed-tilt distinctions, 60/60 semantic-family distinctions, 132/132 aggregate portrait comparisons, and 11/11 no-face no-ops.
- Gallery self-test: passed; output/gallery inventories contain exactly 385 regular PNGs each with the exact renderer/gallery bijection retained.
- Containment: separate `git check-ignore` checks pass for representative output and gallery paths; tracked=0, staged=0, non-ignored-untracked=0.
- Scope scans: `BeautySDK/Package.swift` and `BeautyDemo` unchanged; renderer has only the public `BeautySDK` import; no new network/cloud/commercial/dependency paths.
- `git diff --check`: passed.

The previous RGB mirror-asymmetry gaze score is not acceptance evidence. The
authoritative EYE-18 correction proof is the redacted package-internal aggregate
derived from the same validated pupil/center sample and target used by the gaze
provider. No human-only verification gaps remain for EYE-16 through EYE-18.

## Boundary

The verdict records observed provisional public-facade output evidence only. It does not claim final natural caps, exhaustive safety/degradation/transition coverage, 28-field convergence, active-source security-boundary closeout, ten-row promotion, DOC-01 synchronization, Demo/device/commercial/packaging/shipping/launch readiness, or branch-level `眼睛` completion. Those remain Phase 44 or future scope.
