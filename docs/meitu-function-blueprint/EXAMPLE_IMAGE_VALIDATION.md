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

Run the Phase 36 remaining-nose helper after the all-case renderer command:

```bash
python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Run the Phase 39 remaining-mouth helper after the all-case renderer command:

```bash
python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
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
- Phase 31 command results are recorded in `.planning/phases/31-nose-renderer-output-evidence/31-NOSE-RENDERER-EVIDENCE.md` and `31-VERIFICATION.md`.
- The Phase 31 helper verifies 196 current outputs, 30/30 portrait nose-vs-baseline central-face differences above the watermark band, 6/6 positive-vs-negative `noseTipSize` differences, and representative no-face nose output `no-face-gradient__noseSlim_0p35.png` presence.
- Phase 39 command results are recorded in `.planning/phases/39-public-facade-mouth-geometry-output-evidence/39-MOUTH-OUTPUT-EVIDENCE.md`.
- The Phase 39 helper verifies the discovered 44 × 7 = 308 matrix, 48/48 visibility, 18/18 signed-direction, 12/12 peak-independence, 18/18 plump-independence comparisons, and eight 64 × 64 no-face no-ops.

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
| `noseSlim_0p35` | Phase 31 `大小` renderer evidence through existing `noseSlim` |
| `noseWingSlim_0p35` | Phase 31 `鼻翼` renderer evidence through existing `noseWingSlim` |
| `noseTipSize_plus0p30` | Phase 31 positive-direction `鼻尖` renderer evidence through existing signed `noseTipSize` |
| `noseTipSize_minus0p30` | Phase 31 negative-direction `鼻尖` renderer evidence through existing signed `noseTipSize` |
| `noseBridge_0p30` | Phase 31 `鼻梁` renderer evidence through existing `noseBridge`; this is not `山根` alias evidence |
| `noseRootNarrowing_0p25` | Phase 36 isolated public-facade output for `noseRootNarrowing` at the Phase 37-finalized exact `0.25` cap; final promotion additionally requires the Phase 37 safety/boundary evidence |
| `noseTipLift_0p25` | Phase 36 isolated public-facade output for `noseTipLift` at the Phase 37-finalized exact `0.25` cap; final promotion additionally requires the Phase 37 safety/boundary evidence |
| `mouthSize_plus0p35` | Existing positive signed mouth-size evidence |
| `mouthSize_minus0p35` | Existing negative signed mouth-size evidence |
| `mouthWidth_plus0p35` | Existing positive signed mouth-width evidence |
| `mouthWidth_minus0p35` | Existing negative signed mouth-width evidence |
| `smile_0p50` | Existing smile evidence |
| `lipColor_0p50` | Existing color-only lip evidence; not true plump geometry |
| `mouthYPosition_plus0p25` | Phase 39 provisional positive vertical-position output evidence |
| `mouthYPosition_minus0p25` | Phase 39 provisional negative vertical-position output evidence |
| `mouthTilt_plus0p25` | Phase 39 provisional positive tilt output evidence |
| `mouthTilt_minus0p25` | Phase 39 provisional negative tilt output evidence |
| `mouthXPosition_plus0p25` | Phase 39 provisional positive horizontal-position output evidence |
| `mouthXPosition_minus0p25` | Phase 39 provisional negative horizontal-position output evidence |
| `lipPeakDefinition_0p25` | Phase 39 provisional M-lip peak output evidence |
| `lipPlump_0p25` | Phase 39 provisional true plump-geometry output evidence |

## Phase 36 Remaining-Nose Output Evidence Summary

- The helper discovers the actual 36 renderer cases and seven recursive fixtures before requiring and fully decoding the exact 36 × 7 = 252 same-dimension matrix.
- Six portrait fixtures pass 12/12 new-field-to-`geometryBaseline_noop` comparisons, 6/6 `noseRootNarrowing_0p25`-to-`noseBridge_0p30` comparisons, and 12/12 `noseTipLift_0p25`-to-both-signed-`noseTipSize` comparisons.
- All five comparison families use the fixed top-origin nose ROI x = 25%-75%, y = 20%-70%, wholly above the watermark boundary, with frozen global floors of 500 changed pixels and 2,000 absolute RGB delta.
- The two new no-face outputs preserve 64 × 64 extent and are exact no-ops in the helper's fixed watermark-safe region; XCTest separately records `.noFace`, `.noFaceDetected`, zero used faces, aggregate-only metrics, and redacted diagnostics.
- `generate_gallery.py` requires a duplicate-free exact bijection between its flattened groups and discovered renderer case IDs, then creates 252 ignored, untracked review PNGs. Outputs and gallery files remain disposable local evidence and are never committed.
- The Phase 36 `0.25` strengths are output evidence at the Phase 37-finalized exact caps. Phase 36 did not promote product status at the time; Phase 37 subsequently supplied exhaustive six-field degradation/provider-empty, exactly-once weakening, redaction, active-source boundary, and atomic promotion evidence in `37-NOSE-SAFETY-EVIDENCE.md`.

## Phase 37 Nose Safety and Branch Closeout

- Fresh focused evidence passed 103/103 and the full SwiftPM suite passed 228/228 with zero failures.
- The unchanged Phase 36 renderer/helper result remains exactly 36 cases × 7 fixtures = 252/252 decoded same-dimension outputs, with 12/12 new-field-to-baseline, 6/6 root-to-bridge, 12/12 lift-to-signed-tip, and 2/2 representative no-face comparisons.
- Phase 37 finalized exact `0.25` caps, all-six zero/no-face/missing/provider-empty/stale/reused/transitions, exactly-once combined convergence, redacted diagnostics, and active-source boundaries; `37-SECURITY.md` records `threats_open: 0`.
- Exactly `提升` → `noseTipLift` and `山根` → `noseRootNarrowing` were promoted after their independent evidence passed; the exact six-row SDK-core `鼻子` branch is now `implemented` without alias borrowing or unnamed controls.
- Renderer output and gallery remain disposable, ignored, untracked, and unstaged local artifacts. No Demo UI, physical-device parity, subjective/commercial naturalness, optimized performance, packaging, shipping, launch readiness, broad product parity, milestone-audit, archive, tag, or cleanup result is claimed.

## Phase 39 Remaining-Mouth Output Evidence Summary

- The helper discovers 44 live renderer cases and seven recursive fixtures before requiring and fully decoding the exact 44 × 7 = 308 same-dimension matrix.
- Six portrait fixtures pass 48/48 new-case visibility, 18/18 signed-direction, 12/12 peak-independence, and 18/18 plump-independence direct comparisons.
- All sixteen families use the fixed top-origin mouth ROI x = 10%-90%, y = 40%-82%, wholly above the watermark boundary, with frozen global floors of 1,000 changed pixels and 10,000 absolute RGB delta.
- All eight new no-face outputs preserve 64 × 64 and are exact baseline no-ops across the helper's fixed 2,048-pixel right-half fallback.
- `generate_gallery.py` enforces a duplicate-free exact renderer bijection and one safe publication produced 308 ignored, untracked regular review PNGs.
- The `0.25` mouth strengths are provisional output-evidence inputs. Final caps, exhaustive degradation/conflict behavior, current-owner promotion, and branch closeout remain Phase 40; `嘴唇` and all five new rows remain unpromoted here.

## Phase 30 Eye Safety Closeout Evidence

- At Phase 30 close, the renderer matrix was 23 cases across 7 fixtures and produced 161/161 validated eye-slice outputs; the current Phase 31+ matrix is 28 × 7 = 196.
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
- `比例`, `脸型`, `眼睛`, and `嘴唇` remain `partial`; exact six-row SDK-core `鼻子` is `implemented`.
- `眉毛` and unpromoted branches remain `future`.
- Phase 27 proves only the shared geometry output foundation with `faceShapeCombo_0p35`.
- Phase 28 completes only the scoped `脸型` rows `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`; branch-level `脸型` stays `partial`.
- Phases 29 and 30 complete the existing-public-parameter eye slice: exactly `大小`, `上下`, `眼距`, and `眼尾上扬` are implemented, while branch-level `眼睛` remains `partial` because the remaining eye tools are future work.
- Phase 31 adds renderer evidence for the four existing public nose parameters. Nose rows and branch remain `partial` until Phase 32 safety, degradation, boundary, and ledger closeout passes.

## Phase 31 Nose Renderer Evidence Summary

- `BeautyRendererOutputRegressionTests` verifies the 28-case renderer matrix, public-facade-only import boundary, the five locked nose IDs, and one-existing-public-nose-field-per-case behavior.
- The all-case renderer writes 196 ignored PNG outputs across seven fixtures; `check_nose_renderer_outputs.py` verifies 196/196 full decodes and dimensions.
- Six portrait fixtures across five cases produce 30/30 nose-vs-`geometryBaseline_noop` differences above the watermark band; signed tip outputs also differ in 6/6 direct comparisons.
- Generated review files route to ignored `example-images/gallery/nose/{caseId}/{fixtureStem}.png`, and representative no-face output preserves dimensions.
- This is output evidence only. It does not promote `大小`, `鼻翼`, `鼻梁`, or `鼻尖`; Phase 32 owns safety and exact four-row promotion. `山根`, `提升`, and branch-level `鼻子` remain partial/future.
- No Demo UI, public field, dependency, network/cloud, commercial path, tracked PNG baseline, device parity, commercial approval, broad parity, packaging, launch, or whole-branch claim is added.

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

python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift

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
- This is renderer evidence for existing public eye parameters only; Phase 30 supplies the safety, degradation, redaction, boundary, and scoped status evidence required for the four-row promotion.
- Phase 29 does not claim Demo UI completion, commercial review, device parity, reference-app parity, launch readiness, new public parameters, generated PNG baselines, or whole-branch eye completion.

## Phase 30 Evidence Summary

Phase 30 closes the safety and status gates for the existing-public-parameter eye slice in `.planning/phases/30-eye-safety-ledger-and-closeout/30-EYE-SAFETY-EVIDENCE.md` and `.planning/phases/30-eye-safety-ledger-and-closeout/30-VERIFICATION.md`:

- The full SDK suite passed with 178 tests; focused coverage proves positive-only size/tail semantics, signed distance/Y semantics, exact conservative caps, and abnormal-input no-ops.
- Missing either eye, reused eye geometry, and stale eye geometry skip and zero the eye domain while safe unrelated domains continue; warnings and metrics remain category-only and aggregate.
- Combined-geometry tests prove weakening for all six visible eye directions and the all-eye multi-domain case while preserving signed directions.
- Active-source boundary checks found no public/SPI raw geometry, forbidden Demo or renderer imports, network/cloud execution path, commercial entitlement path, or tracked generated image artifact.
- Exactly `大小`, `上下`, `眼距`, and `眼尾上扬` are implemented. Branch-level `眼睛` remains `partial`; future eye tools, device evidence, commercial visual review, broad parity, packaging, and release readiness remain out of scope.

## Phase 33 Mouth Renderer Evidence Summary

- `BeautyRendererOutputRegressionTests` verifies the 34-case public-facade matrix and six isolated existing mouth/lip cases.
- The renderer produces 238 ignored PNGs across seven fixtures; the Phase 33 helper fully decodes 238/238 with matching dimensions.
- Five geometry cases pass 30/30 portrait mouth-ROI comparisons and both signed pairs pass 12/12 direct comparisons above the watermark.
- `lipColor` passes 6/6 separate lower-central mouth-region containment checks and is not geometry or true `丰唇` evidence.
- Generated review paths are ignored under `example-images/gallery/mouth/`; no output/gallery PNG is tracked.
- Phase 34 adds exact cap/freshness/combined-safety evidence and promotes only `大小`, `宽度`, and `微笑`; branch-level `嘴唇` remains partial and `lipColor` remains color-only.
- Phase 34 owns safety, degradation, ledger promotion, and whole-slice closeout.
