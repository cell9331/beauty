# Example Image Validation

This is the local visual-output gate for current public-facade renderer evidence.

## Purpose

Use real portrait fixtures from `example-images/input/`, run them through the `BeautySDK` public facade with `BeautyExampleRenderer`, and save visible outputs under `example-images/out/`.

This validates the current skin, color, filter, and Phase 27 geometry-output foundation renderer path without adding SwiftUI screens, public parameters, product routes, or per-tool face-shape completion scope.

## Command

Run one case:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/out \
  --case skinWhitening_0p50
```

Run all built-in cases:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/out
```

Run the Phase 27 geometry-output helper after the all-case renderer command:

```bash
python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/out
```

## Output Rules

- Output directory: `example-images/out/`.
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

## Geometry Status

Face-shape, eye, nose, mouth, eyebrow, and 3D sculpt branches already have internal planning/provider tests. Phase 27 adds the first SDK-only saved-output geometry foundation evidence through the public still-image facade.

Phase 19 strengthens provider, resolver, cap, degradation, and redaction XCTest evidence for current public shaping fields. That evidence remains internal partial evidence only.

Current status boundaries:

- `3D塑颜` remains `blocked-by-geometry-output`.
- `比例`, `脸型`, `眼睛`, `嘴唇`, and `鼻子` remain `partial`.
- `眉毛` and unpromoted branches remain `future`.
- Phase 27 proves only the shared geometry output foundation with `faceShapeCombo_0p35`; Phase 28 owns per-tool `脸型` completion evidence and `SHAPE_FEATURE_LEDGER.md` status promotion.

Before any geometry-heavy branch or second-level tool is marked visually complete, this public facade validation path must produce same-dimension, watermarked saved outputs from the same `example-images/input` fixtures through `BeautyExampleRenderer`, with tool-specific evidence recorded in the owning phase.

## Verification Commands

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift build --package-path BeautySDK --product BeautyExampleRenderer

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/out

python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/out

git check-ignore \
  example-images/out/e1__faceShapeCombo_0p35.png \
  example-images/out/e1__geometryBaseline_noop.png \
  example-images/out/no-face-gradient__faceShapeCombo_0p35.png
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
