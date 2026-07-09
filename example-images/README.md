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

## Verify Outputs

Run the relevant helper against the same output directory, for example:

```bash
python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/output
```
