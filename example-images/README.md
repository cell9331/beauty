# Example Images

`example-images` stores committed renderer fixtures, flat machine outputs, and a generated review gallery.

## Directories

- `input/`: committed source fixtures used by SDK tests and `BeautyExampleRenderer`.
  - `input/portraits/`: portrait fixtures such as `e1.png` through `e6.jpg`.
  - `input/negatives/`: negative fixtures such as `no-face-gradient.png`.
- `output/`: ignored flat generated renderer PNGs, named `{fixtureStem}__{caseId}.png`.
- `gallery/`: ignored generated human-review view, grouped as `{featureFamily}/{caseId}/{fixtureStem}.png`.
- `.gallery-staging/`: ignored fail-closed publication slot. A leftover means a prior run did not publish and blocks another run.
- `.gallery-quarantine/previous/`: ignored single-slot preservation of the prior gallery. The generator never traverses or deletes it.

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

Gallery generation opens the repository, `example-images`, input, output, and every staging directory through no-follow descriptors, with immediate close ownership for every acquired descriptor. It rejects a source above 16 MiB before creating its destination, performs bounded descriptor-relative copying into exclusive destinations, and rejects identity, size, modification-time, or change-time drift before publication. It then revalidates the staging snapshots and publishes the complete tree with an atomic descriptor-relative rename. If `gallery/` already exists, it is moved intact into `.gallery-quarantine/previous/`; no old-gallery entry is enumerated or deleted, so nested mount points and links are never crossed.

The quarantine is intentionally bounded to one slot. A later run fails closed while `.gallery-quarantine/` or `.gallery-staging/` exists and does not claim cleanup. After reviewing the preserved prior gallery, an operator may remove these ignored slots using an explicitly chosen out-of-band procedure and rerun the generator.

The gallery groups current cases under:

- `skin/`: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, `skinCombo_0p50`
- `color/`: `brightness_plus0p25`, `contrast_plus0p25`
- `filter/`: `filter_softClean_0p50`, `filter_warmLight_0p50`
- `face-shape/`: `geometryBaseline_noop`, `faceShapeCombo_0p35`, `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, `jawSlim_0p35`, `faceContourSmooth_0p25`, `templeFullness_0p25`, `cheekboneSlim_0p25`, `chinTaper_0p25`
- `eyes/`: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, `eyeTailLift_0p25`
- `eyes/` Phase 43 additions: `eyeHeight_0p25`, `eyeLength_0p25`, `upperEyelidLift_0p25`, `pupilSize_0p25`, `gazeCorrection_0p25`, `lowerEyelidDrop_0p25`, `eyeTilt_plus0p25`, `eyeTilt_minus0p25`, `innerCornerOpen_0p25`, `outerCornerOpen_0p25`, `eyeSymmetry_0p25`
- `nose/`: `noseSlim_0p35`, `noseWingSlim_0p35`, `noseTipSize_plus0p30`, `noseTipSize_minus0p30`, `noseBridge_0p30`, `noseRootNarrowing_0p25`, `noseTipLift_0p25`
- `mouth/`: `mouthSize_plus0p35`, `mouthSize_minus0p35`, `mouthWidth_plus0p35`, `mouthWidth_minus0p35`, `smile_0p50`, `lipColor_0p50`
- `mouth/` Phase 39 additions: `mouthYPosition_plus0p25`, `mouthYPosition_minus0p25`, `mouthTilt_plus0p25`, `mouthTilt_minus0p25`, `mouthXPosition_plus0p25`, `mouthXPosition_minus0p25`, `lipPeakDefinition_0p25`, `lipPlump_0p25`

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

Phase 43 remaining-eye output evidence uses:

```bash
python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper discovers the live inventory before freezing exactly 55 cases × seven fixtures = 385 decoded same-dimension outputs. It gates eleven new cases in one fixed eye-local ROI at committed floors, proves positive/negative tilt polarity and nearest-neighbor family distinction, records six contour/pupil/symmetry-eligible portraits plus the explicit no-face safe-no-op pool, and keeps a self-tested dark-core centroid experiment separate from strict fixture acceptance. Automatic-gaze reduction is proven by the package-internal aggregate pupil-to-own-center evidence path; the retired RGB mirror score is not treated as gaze proof. Generated output and the exact 385-file gallery remain ignored and untracked. These are provisional public-facade output facts; Phase 44 owns final caps, exhaustive safety, boundary closeout, and exact promotion.

Phase 47 remaining-face output evidence uses:

```bash
python3 .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper freezes exactly 59 cases × seven fixtures = 413 decoded same-dimension outputs. Four shared top-origin face regions use field-specific positive floors: contour `(0.10,0.92,0.28,0.82)` at `5000/15000`, temple `(0.10,0.92,0.32,0.80)` at `4000/18000`, cheekbone `(0.20,0.82,0.24,0.65)` at `3500/20000`, and chin `(0.33,0.70,0.24,0.62)` at `1000/3000` changed pixels / absolute RGB delta. Strict evidence passes 18/18 eligible visibility/locality comparisons, 49/49 fixed-neighbor distinctions, 6/6 ineligible portrait no-ops, and 4/4 no-face no-ops. The descriptor-safe gallery is an exact duplicate-free 413-file bijection; output and gallery remain ignored, untracked, and unstaged.

These are provisional public-facade saved-output facts only. Phase 48 owns final caps, exhaustive safety/transitions, exact four-row promotion, owner synchronization, and branch closeout.

Phase 36 remaining-nose output evidence uses:

```bash
python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper discovers the live renderer and fixture inventories before requiring the current 36 × 7 = 252 matrix. It fully decodes 252/252 same-dimension outputs and separately gates 12/12 new-field-to-baseline portrait comparisons, 6/6 root-to-bridge comparisons, and 12/12 lift-to-both-signed-tip comparisons in the fixed nose ROI (x 25%-75%, y 20%-70%) at the frozen floors of 500 changed pixels and 2,000 absolute RGB delta. Both new no-face outputs preserve the 64 × 64 extent and are baseline-identical in the watermark-safe fallback region.

The values `0.25` in `noseRootNarrowing_0p25` and `noseTipLift_0p25` are the Phase 37-finalized exact SDK safety caps, not commercial calibration. Phase 36 owns the isolated public-facade output chronology; `37-NOSE-SAFETY-EVIDENCE.md` adds final exact-cap, exhaustive six-field degradation/transitions, exactly-once convergence, redaction, and active-source boundary evidence before the exact two-row and SDK-core branch promotion. That historical Phase 36 matrix contained 252 files. No Demo UI, device parity, subjective/commercial naturalness, optimized performance, packaging, shipping, launch readiness, broad parity, milestone-audit, archive, tag, or cleanup result is claimed.

Phase 39 remaining-mouth output evidence uses:

```bash
python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The helper discovers the current 44-case renderer and seven fixtures before requiring the exact 44 × 7 = 308 matrix. It fully decodes 308/308 same-dimension PNGs and applies one fixed mouth ROI (x 10%-90%, y 40%-82%) with frozen floors of 1,000 changed pixels and 10,000 absolute RGB delta. Strict evidence passes 48/48 visibility, 18/18 signed-direction, 12/12 peak-independence, and 18/18 plump-independence portrait comparisons. All eight new no-face outputs preserve 64 × 64 and are baseline-identical across the fixed 2,048-pixel label-safe fallback.

The current gallery inventory is a duplicate-free exact bijection with all 44 renderer cases and publishes exactly 308 ignored, untracked regular PNGs. Phase 40 finalizes the new `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, and `lipPlump` values at exact `0.25` caps, adds exhaustive safety evidence, and promotes exactly five geometry rows. `白牙` remains future and branch-level `嘴唇` remains partial. This evidence does not claim Demo/device/commercial quality, performance certification, packaging, shipping, or launch readiness. Preserved quarantine/staging slots remain ignored and untracked.

## Phase 44 Eye Geometry Closeout

The unchanged renderer now has exactly 55 cases × 7 fixtures = 385 outputs. Strict live evidence passes 385/385 same-dimension decode, 66/66 visibility, 6/6 direct signed tilt, 60/60 semantic distinctions, 132/132 portrait comparisons, and 11/11 no-face no-ops. The post-`6e4704e` package aggregate proves pupil-to-own-center gaze reduction; image-only mirror evidence remains rejected.

Output, gallery, staging, and quarantine artifacts remain ignored and untracked. Exactly ten remaining eye geometry rows are promoted; `去脂` and `祛红血丝` remain future and branch `眼睛` stays `partial`. These automated outputs do not establish subjective naturalness, physical-device parity, commercial approval, optimized performance, packaging, shipping, or launch readiness.

## Phase 47 Remaining-Face Output Evidence

- The public renderer contains exactly 59 cases and one shared `BeautyEngine.processResult` call; four isolated cases use provisional `0.25`.
- A bounded strict helper accepts 413/413 regular, fully decoded, same-dimension PNGs with 16 MiB compressed, 4096 × 4096 dimension, and 64 MiB decoded budgets.
- Eligibility is fixed at 5/6 portraits for contour/temple and 4/6 for cheekbone/chin. Accepted signal is entirely inside the fixed watermark-safe face regions; excluded pairs are exact no-ops.
- All 18 visibility/locality, 49 fixed-neighbor, six ineligible-portrait, and four no-face checks pass.
- One descriptor-safe publication produced exactly 413 ignored, untracked gallery PNGs with an exact renderer/gallery bijection.
- The full aggregate record is `.planning/phases/47-public-facade-face-output-evidence/47-FACE-OUTPUT-EVIDENCE.md`. Final caps, exhaustive safety, promotion, root owners, branch `脸型`, and release-quality claims remain Phase 48 or future work.
