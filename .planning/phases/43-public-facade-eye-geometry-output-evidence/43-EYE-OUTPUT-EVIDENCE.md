# Phase 43 Eye Geometry Output Evidence

**Observed:** 2026-07-16  
**Scope:** public-facade saved PNG evidence for EYE-16 through EYE-18 only

## Frozen Matrix and Decoder

- Renderer inventory: exactly 55 duplicate-free public cases.
- Fixture inventory: exactly seven regular committed inputs (six portraits plus one 64×64 no-face negative).
- Fresh strict matrix: 385/385 regular, non-empty, fully decoded, same-dimension PNG outputs.
- Dimension distribution: 55 outputs at 64×64, 220 at 506×900, 55 at 675×900, and 55 at 1728×2304.
- The standard-library helper rejects missing/extra/stale paths, duplicate IDs or fixture stems, symlinks, non-regular files, invalid PNG CRC/chunks/filters/zlib streams, oversized PNG/JPEG inputs, decompression excess, and descriptor replacement/growth races.

## Frozen Eye-Local Acceptance Inputs

- One stored-row normalized ROI is used for every portrait and every eye family: `x=[0.10,0.90)`, `y=[0.55,0.82)`.
- The ROI is checked against the renderer-derived watermark exclusion on every input dimension.
- Fixed strict floors are 500 changed pixels and 1,000 absolute RGB delta.
- The weakest calibration visibility was automatic gaze correction at 909 changed pixels and 1,732 RGB delta, leaving margins of 409 pixels and 732 RGB delta.
- The weakest semantic-family calibration was pupil size versus legacy eye size at 2,046 changed pixels and 3,670 RGB delta.
- Strict mode consumes these committed values and does not derive or lower thresholds from the matrix it accepts.

## Observed Family Results

| Family | Strict result | Weakest observed margin |
| --- | ---: | ---: |
| Eleven new-case visibility | 66/66 portrait comparisons | 909 changed / 1,732 RGB delta |
| Positive and negative tilt versus baseline | 12/12 | 4,759 changed / 24,841 RGB delta |
| Direct positive-versus-negative tilt | 6/6 | 5,412 changed / 37,128 RGB delta |
| Nearest-neighbor semantic distinctions | 60/60 | 2,046 changed / 3,670 RGB delta |
| No-face watermark-safe no-ops | 11/11 | zero changed across each 2,048-pixel fallback region |

The fixed signed-tilt evidence fixture produced normalized change centroids `+0.25 = 0.656001` and `-0.25 = 0.653069` around the committed `0.654500 ± 0.000500` tangential split. Both cases also differ independently from baseline and from each other; legacy tail-lift or watermark changes cannot satisfy these fixed ROI gates.

Semantic comparisons are fixed rather than dynamically selected: height/length, upper/lower lid, inner/outer corner, pupil/legacy eye size, gaze/pupil size, symmetry/legacy eye distance, height/legacy eye size, length/legacy eye distance, upper lid/legacy eye Y, and corner/legacy tail lift.

## Eligibility and Safe No-Op Inventory

- Complete contour eligibility: 6/6 portraits.
- Valid pupil/gaze eligibility: 6/6 portraits.
- Measured-pair symmetry eligibility: 6/6 portraits.
- Neutral/ineligible portrait pool in the current committed fixture inventory: 0/0; no such portrait is counted as visibility or failure.
- Explicit ineligible no-face pool: 1/1 fixture; all eleven new requests are safe watermark-region no-ops and preserve 64×64 extent.
- On the fixed eligible gaze fixture, the paired-eye deviation score decreased from 10,187,336 to 10,180,972: an observed reduction of 6,364 against a frozen minimum of 500.
- Symmetry is proven only on observed, complete measured pairs; the helper does not fabricate or mirror support.

No raw landmark, contour, pupil coordinate, face bound, side label, or provider payload is emitted by the helper or recorded here.

## Reproduction

```bash
python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py --self-test
python3 -m py_compile .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 .planning/phases/43-public-facade-eye-geometry-output-evidence/check_eye_geometry_renderer_outputs.py --input example-images/input --output example-images/output --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

The accepting run followed a guarded physical-root cleanup and fresh render after the separate measurement run. Generated files remain disposable below ignored `example-images/output/`.

## Conservative Boundary

This is observed public-facade output evidence at provisional `0.25` input values. It does not approve final caps, naturalness, exhaustive degradation/transitions, active-source boundary closeout, ten-row promotion, branch-level `眼睛` completion, Demo UI, device parity, commercial review, optimized performance, packaging, shipping, or launch readiness. Those remain Phase 44 or future work.
