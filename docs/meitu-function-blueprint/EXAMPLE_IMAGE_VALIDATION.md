# Example Image Validation

This is the local visual-output gate for current public-facade renderer evidence.

## Purpose

Use real portrait fixtures from `example-images/input/`, run them through the `BeautySDK` public facade with `BeautyExampleRenderer`, and save visible outputs under `example-images/output/`.

This validates the current skin, color, filter, Phase 27 geometry-output foundation, Phase 28 scoped face-shape renderer path, Phase 29 existing-eye-parameter path, Phase 43 remaining-eye path, Phase 47 remaining-face path, and Phase 51 eyebrow public-facade output path without adding SwiftUI screens, product routes, or broader branch completion scope.

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

Run the Phase 43 remaining-eye helper after the all-case renderer command:

```bash
python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Run the Phase 47 remaining-face helper after the all-case renderer command:

```bash
python3 .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Run the Phase 51 eyebrow helper after a guarded clean all-case renderer command:

```bash
python3 .planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py \
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
- Phase 43 command results are recorded in `.planning/phases/43-public-facade-eye-geometry-output-evidence/43-EYE-OUTPUT-EVIDENCE.md`.
- The Phase 43 helper verifies the discovered 55 × 7 = 385 matrix, 66/66 new-case visibility, 6/6 signed-tilt direct comparisons, 60/60 fixed semantic distinctions, complete aggregate eligibility inventory, and eleven 64 × 64 no-face no-ops. Gaze reduction is owned by the package-internal aggregate pupil-to-own-center evidence test; the helper's dark-core centroid experiment is adversarially self-tested but not accepted as fixture proof.
- Phase 47 command results are recorded in `.planning/phases/47-public-facade-face-output-evidence/47-FACE-OUTPUT-EVIDENCE.md`.
- The Phase 47 helper verifies the exact 59 × 7 = 413 matrix, 18/18 eligible visibility/locality comparisons, 49/49 fixed-neighbor distinctions, 6/6 ineligible portrait no-ops, and four 64 × 64 no-face no-ops. The exact 413-file gallery remains ignored and untracked.
- Phase 51 command results and the fourteen-file original-detail review are recorded in `.planning/phases/51-public-facade-eyebrow-output-evidence/51-EYEBROW-OUTPUT-EVIDENCE.md`.
- The Phase 51 helper verifies exactly 72 e6 portrait outputs, thirteen separate no-face comparisons, 13/13 visibility/locality, 6/6 signed direction, 21/21 family distinction, and 40/40 portrait direct comparisons. The complete output and gallery inventories are each exactly 144 ignored, untracked, unstaged, disposable PNGs.

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
| `faceContourSmooth_0p25` | Phase 47 isolated public-facade contour-smoothing output at provisional `0.25` |
| `templeFullness_0p25` | Phase 47 isolated public-facade temple-fullness output at provisional `0.25` |
| `cheekboneSlim_0p25` | Phase 47 isolated public-facade cheekbone-slim output at provisional `0.25` |
| `chinTaper_0p25` | Phase 47 isolated public-facade chin-taper output at provisional `0.25` |
| `eyeSize_0p35` | Phase 29 `大小` renderer evidence through existing `eyeSize` |
| `eyeDistance_plus0p25` | Phase 29 positive-direction `眼距` renderer evidence through existing `eyeDistance` |
| `eyeDistance_minus0p25` | Phase 29 negative-direction `眼距` renderer evidence through existing `eyeDistance` |
| `eyeYPosition_plus0p20` | Phase 29 upward `上下` renderer evidence through existing `eyeYPosition` |
| `eyeYPosition_minus0p20` | Phase 29 downward `上下` renderer evidence through existing `eyeYPosition` |
| `eyeTailLift_0p25` | Phase 29 `眼尾上扬` renderer evidence through existing `eyeTailLift` |
| `eyeHeight_0p25` | Phase 43 observed public-facade `eyeHeight` output at provisional `0.25` |
| `eyeLength_0p25` | Phase 43 observed public-facade `eyeLength` output at provisional `0.25` |
| `upperEyelidLift_0p25` | Phase 43 observed public-facade `upperEyelidLift` output at provisional `0.25` |
| `pupilSize_0p25` | Phase 43 observed pupil-eligible public-facade `pupilSize` output at provisional `0.25` |
| `gazeCorrection_0p25` | Phase 43 observed pupil-eligible automatic `gazeCorrection` output at provisional `0.25` |
| `lowerEyelidDrop_0p25` | Phase 43 observed public-facade `lowerEyelidDrop` output at provisional `0.25` |
| `eyeTilt_plus0p25` | Phase 43 positive signed `eyeTilt` output at provisional `0.25` |
| `eyeTilt_minus0p25` | Phase 43 negative signed `eyeTilt` output at provisional `-0.25` |
| `innerCornerOpen_0p25` | Phase 43 observed public-facade `innerCornerOpen` output at provisional `0.25` |
| `outerCornerOpen_0p25` | Phase 43 observed public-facade `outerCornerOpen` output at provisional `0.25` |
| `eyeSymmetry_0p25` | Phase 43 observed measured-pair `eyeSymmetry` output at provisional `0.25` |
| `eyebrowYPosition_plus0p25` | Phase 51 positive image-Y eyebrow-position output at provisional `0.25` |
| `eyebrowYPosition_minus0p25` | Phase 51 negative image-Y eyebrow-position output at provisional `-0.25` |
| `eyebrowThickness_plus0p25` | Phase 51 positive eyebrow-strip thickness output at provisional `0.25` |
| `eyebrowThickness_minus0p25` | Phase 51 negative eyebrow-strip thickness output at provisional `-0.25` |
| `eyebrowLength_plus0p25` | Phase 51 positive outer-end eyebrow-length output at provisional `0.25` |
| `eyebrowLength_minus0p25` | Phase 51 negative outer-end eyebrow-length output at provisional `-0.25` |
| `eyebrowSpacing_plus0p25` | Phase 51 positive whole-brow spacing output at provisional `0.25` |
| `eyebrowSpacing_minus0p25` | Phase 51 negative whole-brow spacing output at provisional `-0.25` |
| `eyebrowHeadSpacing_plus0p25` | Phase 51 positive inner-head spacing output at provisional `0.25` |
| `eyebrowHeadSpacing_minus0p25` | Phase 51 negative inner-head spacing output at provisional `-0.25` |
| `eyebrowTilt_plus0p25` | Phase 51 positive canonical outer-tail lift output at provisional `0.25` |
| `eyebrowTilt_minus0p25` | Phase 51 negative canonical outer-tail lift output at provisional `-0.25` |
| `eyebrowPeakDefinition_0p25` | Phase 51 positive apex-neighborhood definition output at provisional `0.25` |
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
| `mouthYPosition_plus0p25` | Phase 39 positive vertical-position output at the Phase 40-finalized exact cap |
| `mouthYPosition_minus0p25` | Phase 39 negative vertical-position output at the Phase 40-finalized exact cap |
| `mouthTilt_plus0p25` | Phase 39 positive tilt output at the Phase 40-finalized exact cap |
| `mouthTilt_minus0p25` | Phase 39 negative tilt output at the Phase 40-finalized exact cap |
| `mouthXPosition_plus0p25` | Phase 39 positive horizontal-position output at the Phase 40-finalized exact cap |
| `mouthXPosition_minus0p25` | Phase 39 negative horizontal-position output at the Phase 40-finalized exact cap |
| `lipPeakDefinition_0p25` | Phase 39 M-lip peak output at the Phase 40-finalized exact cap |
| `lipPlump_0p25` | Phase 39 true plump-geometry output at the Phase 40-finalized exact cap |

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
- The `0.25` mouth strengths are the Phase 40-finalized exact caps. Phase 40 adds exhaustive eight-field degradation/conflict behavior and promotes exactly `上下`, `倾斜`, `左右`, `M唇`, and true `丰唇`; branch-level `嘴唇` remains partial because `白牙` is future.

## Phase 43 Remaining-Eye Output Evidence Summary

- The helper discovers exactly 55 live renderer cases and seven recursive fixtures before fully decoding the 385/385 same-dimension matrix.
- Six eligible portraits pass 66/66 new-case visibility, 6/6 direct positive-versus-negative tilt, and 60/60 fixed nearest-neighbor semantic comparisons in one stored-row eye ROI `x=.10-.90/y=.55-.82`.
- Fixed floors are 500 changed pixels and 1,000 absolute RGB delta; the weakest accepted visibility remains 909/1,732 and the weakest semantic family remains 2,046/3,670.
- The package-internal `gazeCorrectionEvidence(face:strength:)` aggregate reports two eligible eyes with corrected pupil-to-own-center offset strictly below baseline, while neutral pupils no-op and contour tilt/asymmetry cannot alter the scalar. Contour, pupil/gaze, and measured-pair symmetry eligibility are each 6/6 portraits; the one explicit no-face fixture is excluded from those denominators and passes all eleven safe no-ops. The previous paired-eye RGB mirror score is retired because unrelated asymmetry could satisfy it.
- The ignored gallery is an exact duplicate-free 55-case × seven-fixture bijection. No output or gallery PNG is tracked or staged.
- These are observed public-facade output facts at provisional `0.25` inputs. Phase 44 retains final caps, exhaustive transitions/safety, active-source boundary closeout, exact ten-row promotion, and owner-ledger synchronization.

## Phase 47 Remaining-Face Output Evidence Summary

- The helper discovers exactly 59 live public renderer cases and seven recursive fixtures before fully decoding 413/413 regular same-dimension PNGs.
- Four shared, watermark-safe top-origin regions are fixed across all fixtures: contour `(0.10,0.92,0.28,0.82)`, temple `(0.10,0.92,0.32,0.80)`, cheekbone `(0.20,0.82,0.24,0.65)`, and chin `(0.33,0.70,0.24,0.62)`.
- Fixed visibility floors `(changed pixels / absolute RGB delta)` are `5000/15000`, `4000/18000`, `3500/20000`, and `1000/3000` respectively. All 18/18 eligible comparisons pass at a minimum 0.99 intended-region share with zero permitted outside signal.
- Eligibility is fixed at `e2`-`e6` for contour/temple and `e2,e3,e5,e6` for cheekbone/chin. The six excluded portrait/field pairs are exact baseline no-ops rather than weak visibility passes.
- Eleven constant comparator families pass 49/49 intended-region distinctions; all four new no-face outputs are exact no-ops in the fixed 2,048-pixel fallback.
- Gallery publication enforces duplicate-free renderer set equality and produced exactly 413 ignored, untracked, unstaged review PNGs. Generated bytes remain disposable.
- This closes saved-output evidence only. Phase 48 retains final caps, exhaustive degradation/transitions, exact four-row promotion, root owner synchronization, branch `脸型`, and all release-quality claims.

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
- Exact seven-row SDK-core `眉毛` is `implemented`; all other unpromoted branches remain `future`. This scoped branch status does not alter the current v1.13 milestone-audit `tech_debt`/blocked closeout state and implies no SwiftUI/Demo UI, device, commercial-naturalness, performance, packaging, shipping, launch, archive, tag, or cleanup completion.
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

## Phase 44 Eye Geometry Closeout

- The unchanged public-facade matrix has exactly 55 cases × 7 fixtures = 385 ignored, untracked outputs. Strict evidence passes 385/385 decode/dimensions, 66/66 visibility, 6/6 direct tilt, 60/60 semantic distinctions, 132/132 portrait comparisons, and 11/11 no-face no-ops.
- The authoritative post-`6e4704e` gaze proof is the package-internal aggregate pupil-to-own-center reduction; the helper's image-only mirror/dark-core inference remains rejected.
- Exactly ten remaining geometry rows are promoted. `去脂` and `祛红血丝` remain future and branch `眼睛` remains `partial`.
- Output/gallery files remain ignored and untracked. This automated evidence does not establish subjective naturalness, physical-device parity, commercial approval, packaging, shipping, or launch readiness.

## Phase 48 Face Safety and Promotion Evidence

- The unchanged public renderer has exactly 59 cases × 7 fixtures = 413 outputs. Fresh strict evidence passes 413/413 decode/dimensions, 18/18 visibility/locality, 49/49 fixed-neighbor distinctions, 6/6 ineligible portrait no-ops, and 4/4 no-face no-ops.
- Phase 48 finalizes the four exact `0.25` caps and promotes exactly `面部流畅`, `太阳穴`, `颧骨`, and `尖下巴` after exhaustive nine-field safety, exact 37-field convergence, clean review, and fail-closed privacy/status gates.
- `去双下巴`, `去双下巴 Pro`, and `发际线` remain future; branch `脸型` remains `partial`.
- The 413 output PNGs and exact 413-file gallery remain ignored, untracked, unstaged, and disposable. No new case or threshold was added in Phase 48.
- This evidence does not establish subjective naturalness, physical-device parity, commercial approval, optimized performance, packaging, shipping, launch readiness, or milestone lifecycle completion.

## Phase 51 Eyebrow Public-Facade Output Evidence

- Active fixture discovery is fail-closed at the sole portrait `e6.jpg` plus the separate `no-face-gradient.png` negative; retired `e1.png` through `e5.png` remain parked and cannot enter output or gallery acceptance.
- Thirteen isolated public cases expand the current renderer to exactly 72 while retaining one shared `BeautyEngine.processResult`/unified warp route.
- A measurement-only guarded render selected fixed brow/protected-region and semantic thresholds. A later independently cleaned strict render accepts 72/72 decoded e6 portrait outputs, 13/13 visibility/locality, 6/6 signed directions, 21/21 positive-family distinctions, 40/40 total portrait comparisons, and 13/13 separately reported no-face no-ops.
- The baseline plus all thirteen actual e6 eyebrow outputs were opened individually at original detail. The recorded visual verdict confirms visible opposite directions, brow-locality, protected eyes/forehead-hair/background, whole-spacing versus head-spacing separation, and thickness versus peak separation.
- One descriptor-safe publication produced the exact 72-case × two-fixture = 144-file ignored gallery with thirteen `eyebrows` case directories and an exact duplicate-free renderer bijection. Generated bytes remain disposable and are neither tracked nor staged.
- This closes Phase 51 saved-output evidence only. Phase 52 retains final caps, exhaustive lifecycle/convergence and safety, exact seven-row promotion, branch `眉毛`, and all device/commercial naturalness/performance/packaging/shipping/release claims.

## Phase 52 Final Eyebrow Example-Image Acceptance

- Phase 52 keeps the Phase 51 renderer, fixtures, frozen strict thresholds, helper, and gallery generator unchanged. Guarded clean reruns still use the commands above against the sole active portrait `e6.jpg` and the separate no-face negative.
- The final-cap rerun accepts exactly 72 decoded `e6` portrait outputs and reports thirteen no-face comparisons separately. The output inventory and its descriptor-safe gallery bijection each contain exactly 144 disposable two-fixture PNGs.
- Frozen checks pass 13/13 visibility/locality, 6/6 signed direction, 21/21 family distinction, and 40/40 direct portrait comparisons. The baseline plus thirteen eyebrow cases — fourteen actual files — were reopened at original detail and retain the recorded PASS for direction, locality, protected-region stability, and semantic distinction.
- Final exact `0.25` caps and exhaustive safety evidence authorize exactly seven implemented SDK-core rows: `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`, and `眉峰`, together with SDK-core branch `眉毛`. This status changes no example case or calibration.
- Output, gallery, staging, and quarantine artifacts remain ignored, untracked, unstaged, and disposable. This acceptance does not establish UI or Demo completion, physical-device parity, commercial naturalness, optimized performance, packaging, shipping, launch or release readiness, independent milestone audit, archive, tag, or cleanup.
