---
phase: 44-eye-geometry-safety-and-ledger-closeout
requirements: [EYE-19, EYE-20, EYE-21, EYE-22]
captured: 2026-07-19
status: passed-pre-promotion
---

# Phase 44 Eye Safety Evidence

## Runtime and exact safety

- `BeautySafetyCapsTests` passed 4/4 and `BeautyEffectResolverTests` passed 19/19 for exact cap, normalization, warning, metric, and redaction behavior.
- `EyeWarpProviderTests` passed 16/16 for all fourteen fields, exact gaze `0.002` and symmetry `0.0001` neutral boundaries, fixed correction/blend ceilings, pupil-local eligibility, and idempotent sanitization.
- `MissingLandmarkDegradationTests` passed 40/40 and `BeautyEngineGeometryFacadeTests` passed 13/13 for no-face, missing, malformed, fresh/reused/stale, extent, safe sibling, and redaction behavior.
- `GeometryConflictResolverTests` passed 12/12 and `CombinedEffectSafetyTests` passed 13/13. The complete retained fixture is exactly total `10.70`, count `33`, and scale `1/10.70`; all 28 possible eye/nose/mouth provider removals are monotonic and field-local.
- Fresh full `swift test --package-path BeautySDK` passed 314/314 with zero failures. The authoritative package-internal pupil-to-own-center gaze aggregate proves two eligible eyes reduce baseline offset; neutral/asymmetric contour fixtures cannot manufacture that scalar.

## Public output and artifacts

- The unchanged Phase 43 helper compiled and its adversarial self-test passed.
- Strict live evaluation of existing ignored output completed at 55 cases × 7 fixtures = 385/385 decoded same-dimension PNGs.
- Exact comparisons passed: visibility 66/66, direct signed tilt 6/6, semantic distinctions 60/60, aggregate portrait comparisons 132/132, and no-face watermark-safe no-ops 11/11.
- Fixed ROI and acceptance floors were unchanged. Image-only dark-core gaze inference remains rejected; the package aggregate is authoritative.
- `example-images/generate_gallery.py --self-test` passed. Output/gallery/staging/quarantine roots remain ignored, untracked, and unstaged; no media is committed.

## Boundary and promotion authorization

- `python3 -m py_compile .../check_eye_geometry_boundaries.py` passed.
- Boundary adversarial self-test passed 57/57, covering command exit classification, canonical paths, persistence/privacy/import/network/commercial/dependency/public compatibility, exact source ownership, every promotion row, named owners, pending-audit, lifecycle, and artifacts.
- Default live pre-promotion gate passed 13/13: the exact 48-field scalar inventory and eight active-source owners are classified, all ten target rows remain future, `去脂`/`祛红血丝` remain future, branch `眼睛` remains partial, and generated artifacts remain contained.
- `git diff --check` passed. `BeautyDemo`, package/dependency graph, public field inventory/ranges, renderer matrix, helper thresholds, and generated media were not changed.

## Scope limits

This is automated SDK/saved-output evidence, not subjective naturalness, physical-device parity, commercial visual approval, optimized performance, packaging, shipping, launch readiness, or milestone-audit evidence. Exact row promotion remains Plan 44-04 and the independent milestone audit remains separate.
