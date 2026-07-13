# Example Images

`example-images` stores committed renderer fixtures, flat machine outputs, and a generated review gallery.

## Directories

- `input/`: committed source fixtures used by SDK tests and `BeautyExampleRenderer`.
  - `input/portraits/`: portrait fixtures such as `e1.png` through `e6.jpg`.
  - `input/negatives/`: negative fixtures such as `no-face-gradient.png`.
- `output/`: ignored flat generated renderer PNGs, named `{fixtureStem}__{caseId}.png`.
- `gallery/`: ignored generated human-review view, grouped as `{featureFamily}/{caseId}/{fixtureStem}.png`.

Generated `output/` and `gallery/` contents are local artifacts. Recreate them instead of committing PNGs.
Committed `input/` fixtures should stay below 1 MB each; the current PNG portrait fixtures use a 900 px maximum edge, `e6.jpg` is a committed JPEG portrait fixture, and the no-face negative fixture is 64 px.

## Generate Output

```bash
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
```

## Generate Gallery

```bash
python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery
```

The gallery groups current cases under:

- `skin/`: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, `skinCombo_0p50`
- `color/`: `brightness_plus0p25`, `contrast_plus0p25`
- `filter/`: `filter_softClean_0p50`, `filter_warmLight_0p50`
- `face-shape/`: `geometryBaseline_noop`, `faceShapeCombo_0p35`, `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, `jawSlim_0p35`
- `eyes/`: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, `eyeTailLift_0p25`
- `nose/`: `noseSlim_0p35`, `noseWingSlim_0p35`, `noseTipSize_plus0p30`, `noseTipSize_minus0p30`, `noseBridge_0p30`, `noseRootNarrowing_0p25`, `noseTipLift_0p25`
- `mouth/`: `mouthSize_plus0p35`, `mouthSize_minus0p35`, `mouthWidth_plus0p35`, `mouthWidth_minus0p35`, `smile_0p50`, `lipColor_0p50`

## Verify Outputs

Run the relevant helper against the same output directory, for example:

```bash
python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output
```

Phase 29 eye output evidence uses:

```bash
python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output
```

Phase 31 nose output evidence uses:

```bash
python3 .planning/milestones/v1.7-phases/31-nose-renderer-output-evidence/check_nose_renderer_outputs.py --input example-images/input --output example-images/output
```

The Phase 31 helper requires 196/196 decoded same-dimension outputs, 30/30 portrait nose-vs-baseline comparisons, 6/6 positive-vs-negative `noseTipSize` comparisons, and representative no-face nose output presence.

Phase 33 mouth/lip output evidence uses:

```bash
python3 .planning/phases/33-mouth-renderer-output-evidence/check_mouth_renderer_outputs.py --input example-images/input --output example-images/output
```

The Phase 33 helper requires 238/238 decoded same-dimension outputs, 30/30 mouth-geometry ROI comparisons, 12/12 signed-pair comparisons, 6/6 separate lip-color containment checks, and representative no-face extent.

Phase 36 remaining-nose output evidence uses:

```bash
python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper discovers the live renderer and fixture inventories before requiring the current 36 × 7 = 252 matrix. It fully decodes 252/252 same-dimension outputs and separately gates 12/12 new-field-to-baseline portrait comparisons, 6/6 root-to-bridge comparisons, and 12/12 lift-to-both-signed-tip comparisons in the fixed nose ROI (x 25%-75%, y 20%-70%) at the frozen floors of 500 changed pixels and 2,000 absolute RGB delta. Both new no-face outputs preserve the 64 × 64 extent and are baseline-identical in the watermark-safe fallback region.

The values `0.25` in `noseRootNarrowing_0p25` and `noseTipLift_0p25` are provisional output-evidence inputs, not final caps or commercial calibration. Gallery generation first requires a duplicate-free exact bijection between `CASE_GROUPS` and the renderer's discovered case IDs, then writes 252 ignored, untracked local PNGs. This evidence does not promote `山根`, `提升`, or branch-level `鼻子`; final caps, exhaustive safety and active-source boundary closeout remain Phase 37 work.
