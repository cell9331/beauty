# Example Image Validation

This is the local visual-output gate for current public-facade renderer evidence.

## Purpose

Use real portrait fixtures from `example-images/input/`, run them through the `BeautySDK` public facade with `BeautyExampleRenderer`, and save visible outputs under `example-images/output/`.

This validates the current skin, color, filter, Phase 27 geometry-output foundation, Phase 28 scoped face-shape renderer path, and Phase 29 existing-eye-parameter renderer path without adding SwiftUI screens, public parameters, product routes, or broader branch completion scope.

## Command

Run one case:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/output \
  --case skinWhitening_0p50
```

Run all built-in cases:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/output
```

Run the Phase 27 geometry-output helper after the all-case renderer command:

```bash
python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output
```

Run the Phase 28 face-shape helper after the all-case renderer command when validating scoped `脸型` rows:

```bash
python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output
```

Run the Phase 29 eye helper after the all-case renderer command when validating existing public `眼睛` parameters:

```bash
python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output
```

## Output Rules

- Output directory: `example-images/output/`.
- Output files are ignored by git.
- File names include source image, parameter name, and parameter strength:
  - `e2__skinWhitening_0p50.png`
  - `e4__filter_warmLight_0p50.png`
- A large bottom watermark is drawn on each image with the parameter and strength.
- The watermark is placed at the bottom to avoid covering the face.
- The output image keeps the same pixel dimensions as the input image.
- Phase 24 command results live in `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md`.
- The Phase 24 helper verifies 45 current outputs for existence, non-empty files, same pixel dimensions, and input/output byte difference.
- Phase 27 command results live in `.planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md` and `.planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md`.
- The Phase 27 helper verifies 66 current outputs for existence, non-empty files, same pixel dimensions, portrait geometry-vs-baseline top-region differences above the watermark band, and no-face geometry output presence.
- Phase 28 command results live in `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-FACE-SHAPE-RENDERER-EVIDENCE.md` and `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-VERIFICATION.md`.
- The Phase 28 helper verifies 102 current outputs for existence, non-empty files, same pixel dimensions, 30/30 portrait face-shape-vs-baseline top-region differences above the watermark band, and no-face face-shape output presence.
- Phase 29 command results are recorded in `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md` and `.planning/phases/29-eye-renderer-output-evidence/29-VERIFICATION.md`.
- The Phase 29 helper verifies 161 current outputs for existence, non-empty files, same pixel dimensions, 36/36 portrait eye-vs-baseline top-region differences above the watermark band, and representative no-face eye output `no-face-gradient__eyeSize_0p35.png` presence.

## Current Built-In Cases

These cases are limited to effects that currently produce visible image output through `BeautyEngine.processResult(image:)`:

`BeautySDK/Sources/BeautyExampleRenderer/main.swift` is the canonical source for this matrix. Keep this table aligned with the executable case IDs.

| Case | Parameter coverage |
| --- | --- |
| `skinSmoothing_0p50` | Basic skin smoothing proxy |
| `skinWhitening_0p50` | Skin whitening |
| `skinRosy_0p40` | Rosy skin |
| `skinSharpen_0p40` | Sharpen/contrast proxy |
| `brightness_plus0p25` | Color brightness |
| `contrast_plus0p25` | Color contrast |
| `filter_softClean_0p50` | Built-in `soft_clean` filter |
| `filter_warmLight_0p50` | Built-in `warm_light` filter |
| `skinCombo_0p50` | Combined basic skin parameters |
| `geometryBaseline_noop` | No-geometry baseline using default parameters |
| `faceShapeCombo_0p35` | Combined face-shape foundation case using `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength` |
| `faceSlim_0p35` | Phase 28 `脸宽` evidence through existing `faceSlim` |
| `faceSmall_0p35` | Phase 28 `小脸` evidence through existing `faceSmall` |
| `chinLength_plus0p30` | Phase 28 `下巴长短` positive-direction evidence through existing `chinLength` |
| `chinLength_minus0p30` | Phase 28 `下巴长短` negative-direction evidence through existing `chinLength` |
| `faceVShape_0p35` | Phase 28 `V脸` evidence through existing `faceVShape` |
| `jawSlim_0p35` | Phase 28 `下颌角` and alias-backed `下颌线` evidence through existing `jawSlim` |
| `eyeSize_0p35` | Phase 29 `大小` renderer evidence through existing `eyeSize` |
| `eyeDistance_plus0p25` | Phase 29 positive-direction `眼距` renderer evidence through existing `eyeDistance` |
| `eyeDistance_minus0p25` | Phase 29 negative-direction `眼距` renderer evidence through existing `eyeDistance` |
| `eyeYPosition_plus0p20` | Phase 29 upward `上下` renderer evidence through existing `eyeYPosition` |
| `eyeYPosition_minus0p20` | Phase 29 downward `上下` renderer evidence through existing `eyeYPosition` |
| `eyeTailLift_0p25` | Phase 29 `眼尾上扬` renderer evidence through existing `eyeTailLift` |

## Phase 30 Eye Safety Closeout Evidence

- The canonical renderer matrix remains 23 cases across 7 fixtures, producing 161/161 validated outputs.
- The unchanged `check_eye_renderer_outputs.py` helper retains 36/36 portrait eye-vs-baseline comparisons and representative no-face output evidence.
- Generated files under `example-images/output/` and `example-images/gallery/` remain ignored local artifacts; no generated baseline is committed.
- Gallery logic was unchanged, so no gallery rerun was required for this closeout.
- Phase 30 safety, degradation, combined-geometry, privacy, and boundary results are recorded in `30-EYE-SAFETY-EVIDENCE.md`; the pre-promotion verdict is recorded in `30-VERIFICATION.md`.
- These facts support exactly four existing-parameter eye subtools while the branch retains future gaps.

## Geometry Status

Face-shape, eye, nose, mouth, eyebrow, and 3D sculpt branches already have internal planning/provider tests. Phase 27 adds the first SDK-only saved-output geometry foundation evidence through the public still-image facade.

Phase 19 strengthens provider, resolver, cap, degradation, and redaction XCTest evidence for current public shaping fields. That evidence remains internal partial evidence only.

Current status boundaries:

- `3D塑颜` remains `blocked-by-geometry-output`.
- `比例`, `脸型`, `眼睛`, `嘴唇`, and `鼻子` remain `partial`.
- `眉毛` and unpromoted branches remain `future`.
- Phase 27 proves only the shared geometry output foundation with `faceShapeCombo_0p35`.
- Phase 28 completes only the scoped `脸型` rows `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`; branch-level `脸型` stays `partial`.
- Phase 29 records public-facade renderer evidence for existing eye parameters only; `眼睛` rows and branch remain `partial` until Phase 30 safety/degradation/status closeout.

Before any geometry-heavy branch or second-level tool is marked visually complete, this public facade validation path must produce same-dimension, watermarked saved outputs from the same `example-images/input` fixtures through `BeautyExampleRenderer`, with tool-specific evidence recorded in the owning phase.

## Verification Commands

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift build --package-path BeautySDK --product BeautyExampleRenderer

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/output

python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output

python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output

python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output

git check-ignore \
  example-images/output/e1__faceShapeCombo_0p35.png \
  example-images/output/e1__geometryBaseline_noop.png \
  example-images/output/no-face-gradient__faceShapeCombo_0p35.png \
  example-images/output/e1__faceSlim_0p35.png \
  example-images/output/e1__chinLength_minus0p30.png \
  example-images/output/e1__jawSlim_0p35.png \
  example-images/output/e1__eyeSize_0p35.png \
  example-images/output/e1__eyeDistance_minus0p25.png \
  example-images/output/no-face-gradient__eyeSize_0p35.png
```

## Phase 24 Evidence Summary

Phase 24 recorded command-backed evidence in `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md`:

- `BeautyRendererOutputRegressionTests` verifies the exact current 9-case renderer matrix and the public-facade import boundary.
- Default `BeautyParameters` preserve `e1.png` through `e5.png` rendered pixels before watermarking with exact equality.
- The all-case renderer command produced 45 ignored PNG outputs.
- `check_renderer_outputs.py` verified those 45 outputs for existence, non-empty files, same pixel dimensions, and input/output byte difference.
- Representative notes record readable bottom watermarks on selected outputs without turning those observations into quality, device, parity, or geometry-completion conclusions.

## Phase 27 Evidence Summary

Phase 27 recorded command-backed evidence in `.planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md` and `.planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md`:

- `BeautyRendererOutputRegressionTests` verifies the current 11-case renderer matrix, 6 input fixtures, public-facade import boundary, Phase 27 face-shape-only case scope, and no-face summary redaction.
- The all-case renderer command produced 66 ignored PNG outputs.
- `check_geometry_renderer_outputs.py` verified those 66 outputs for existence, non-empty files, same pixel dimensions, 5/5 portrait geometry-vs-baseline top-region comparisons, and no-face geometry output presence.
- `BeautyEngineGeometryFacadeTests` proves real fixture detection, selected-face geometry output delta, no-face degradation, and redacted metadata through the public still-image facade.
- Focused missing-landmark, stale/reused, combined-strength, and face-shape conflict tests cover degradation behavior with redacted evidence.
- Generated PNGs remain ignored local artifacts; Markdown evidence records commands, counts, dimensions, helper results, and factual observations only.

## Phase 28 Evidence Summary

Phase 28 recorded command-backed evidence in `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-VERIFICATION.md` and `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-FACE-SHAPE-RENDERER-EVIDENCE.md`:

- `BeautyRendererOutputRegressionTests` verifies the current 17-case renderer matrix, 6 input fixtures, public-facade import boundary, scoped Phase 28 case IDs, and `jawSlim_0p35` alias sharing.
- The all-case renderer command produced 102 ignored PNG outputs.
- `check_face_shape_renderer_outputs.py` verified those 102 outputs for existence, non-empty files, same pixel dimensions, 30/30 portrait face-shape-vs-baseline top-region comparisons, and no-face face-shape output presence.
- Focused provider, combined-safety, and conflict-resolver tests cover caps, missing contour, no-face degradation, signed `chinLength`, combined weakening, redacted warnings/metrics, and alias-backed `下颌线`.
- `SHAPE_FEATURE_LEDGER.md` marks exactly six scoped `脸型` rows implemented: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`.
- Generated PNGs remain ignored local artifacts; Markdown evidence records commands, counts, dimensions, helper results, static-scan results, and factual notes only.
- Phase 28 does not claim Demo UI completion, commercial quality, device parity, broad reference-app parity, new geometry group, launch readiness, or whole-branch `脸型` completion.

## Phase 29 Evidence Summary

Phase 29 records command-backed renderer evidence for existing public eye parameters in `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md` and `.planning/phases/29-eye-renderer-output-evidence/29-VERIFICATION.md`:

- `BeautyRendererOutputRegressionTests` verifies the current 23-case renderer matrix, public-facade import boundary, six Phase 29 eye case IDs, and one-existing-public-eye-field-per-case rule.
- The all-case renderer command produces 161 ignored PNG outputs across seven committed input fixtures and 23 renderer cases.
- `check_eye_renderer_outputs.py` verifies those 161 outputs for existence, non-empty files, same pixel dimensions, 36/36 portrait eye-vs-`geometryBaseline_noop` top-region comparisons, and representative no-face output `no-face-gradient__eyeSize_0p35.png` presence.
- Generated gallery support groups the six Phase 29 case IDs under ignored `example-images/gallery/eyes/{caseId}/{fixtureStem}.png`.
- This is renderer evidence for existing public eye parameters only; `眼睛` rows and branch remain `partial` until Phase 30 records safety, degradation, redaction, and scoped status evidence.
- Phase 29 does not claim Demo UI completion, commercial review, device parity, reference-app parity, launch readiness, new public parameters, generated PNG baselines, or whole-branch eye completion.
