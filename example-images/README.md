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
- `nose/`: `noseSlim_0p35`, `noseWingSlim_0p35`, `noseTipSize_plus0p30`, `noseTipSize_minus0p30`, `noseBridge_0p30`

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
python3 .planning/phases/31-nose-renderer-output-evidence/check_nose_renderer_outputs.py --input example-images/input --output example-images/output
```

The Phase 31 helper requires 196/196 decoded same-dimension outputs, 30/30 portrait nose-vs-baseline comparisons, 6/6 positive-vs-negative `noseTipSize` comparisons, and representative no-face nose output presence.
