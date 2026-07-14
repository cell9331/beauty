# Phase 39 Remaining-Mouth Public-Facade Output Evidence

**Observed:** 2026-07-14  
**Scope:** MOUTH-09, MOUTH-10, and the output/no-face portion of MOUTH-11 only

## Verdict

PASS. A guarded clean regeneration discovered exactly 44 renderer cases and seven recursive fixtures, then wrote and completely decoded exactly 308 public-facade PNGs at their corresponding input dimensions. Sixteen fixed mouth-local comparison families separately pass visibility, signed-direction, peak-independence, and plump-independence gates. All eight new no-face outputs preserve 64 × 64 and are baseline-identical in the fixed label-safe fallback.

The eight new renderer cases use provisional `0.25` evidence values. This evidence does not finalize safety caps or promote any remaining mouth row or the branch.

## Commands and Non-Circular Regeneration

Run from `/Users/yakangwang/codes/beauty`:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift build --package-path BeautySDK --product BeautyExampleRenderer

OUTPUT_ROOT="$(cd example-images/output && pwd -P)"
test "$OUTPUT_ROOT" = "$(pwd -P)/example-images/output"
git check-ignore -q example-images/output
find "$OUTPUT_ROOT" -mindepth 1 -delete

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input --output example-images/output

python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift \
  --measure
```

The measurement run used the already-fixed ROI and reported values without applying acceptance floors. Its weakest family minima were 1,921 changed pixels and 16,651 total absolute RGB delta. The helper was then committed with fixed global floors of 1,000 and 10,000, leaving measurement margins of 921 pixels and 6,651 delta. Only after that commit did the accepting run perform a second guarded cleanup, regenerate all output, and invoke the same helper without `--measure`:

```bash
OUTPUT_ROOT="$(cd example-images/output && pwd -P)"
test "$OUTPUT_ROOT" = "$(pwd -P)/example-images/output"
git check-ignore -q example-images/output
find "$OUTPUT_ROOT" -mindepth 1 -delete

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input --output example-images/output

python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift

test "$(find example-images/output -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')" -eq 308
```

Both cleanups first resolved the physical output root, required exact equality with the repository allow-list, and required the root to be ignored. They deleted only descendants of that exact generated-output directory.

## Discovered Inventories

The helper discovers ordered `id:` values from the live renderer and recursively discovers regular PNG/JPG/JPEG fixtures. It rejects duplicate case IDs and flattened fixture stems, computes the product, and only then enforces the frozen Phase 39 contract.

- Cases: 44, with each of the eight new IDs present exactly once.
- Fixtures: 7 = six portraits plus exactly `negatives/no-face-gradient.png`.
- Computed matrix: 44 × 7 = 308.
- Strict result: 308/308 non-empty, completely decoded, same-dimension PNGs; no missing, unexpected, symbolic-link, or nonregular output.
- Fixture order: `negatives/no-face-gradient.png`, `portraits/e1.png`, `portraits/e2.png`, `portraits/e3.png`, `portraits/e4.png`, `portraits/e5.png`, `portraits/e6.jpg`.

| Output dimensions | Output count |
| --- | ---: |
| 64 × 64 | 44 |
| 506 × 900 | 176 |
| 675 × 900 | 44 |
| 1728 × 2304 | 44 |

The archive-safe helper uses only the Python standard library. Its deterministic self-tests reject duplicate IDs/stems, missing/extra/corrupt/symlink output, oversized dimensions, bounded-decode expansion, trailing compressed streams, single-descriptor replacement and growth races, an ROI crossing the watermark boundary, and a malformed no-face fallback.

## Fixed ROI and Watermark Boundary

Every portrait pair uses one top-origin normalized mouth rectangle:

- x = `[0.10 × width, 0.90 × width)`
- y = `[0.40 × height, 0.82 × height)`

Before comparing pixels, the helper requires the ROI bottom to be no lower than the renderer-matched comparable-row boundary:

```text
fontSize = max(34, min(72, width / 30))
padding = max(24, width / 70)
excludedBottomRows = ceil(padding * 2 + fontSize * 1.75)
comparableRows = max(0, height - excludedBottomRows)
```

The frozen strict floors are changed pixels ≥ 1,000 and total absolute RGB delta ≥ 10,000. Strict mode neither derives nor lowers them.

## Strict Comparison Results

The no-face fixture is excluded from all portrait totals. Each row contains six successful portrait comparisons.

| Group | Family | Direct pair | Passed | Min changed | Min ROI pixels | Min RGB delta |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| Visibility | Mouth Y plus | `mouthYPosition_plus0p25` vs baseline | 6/6 | 4,278 | 153,090 | 59,640 |
| Visibility | Mouth Y minus | `mouthYPosition_minus0p25` vs baseline | 6/6 | 4,759 | 153,090 | 69,903 |
| Visibility | Mouth tilt plus | `mouthTilt_plus0p25` vs baseline | 6/6 | 4,347 | 153,090 | 55,024 |
| Visibility | Mouth tilt minus | `mouthTilt_minus0p25` vs baseline | 6/6 | 4,198 | 153,090 | 48,013 |
| Visibility | Mouth X plus | `mouthXPosition_plus0p25` vs baseline | 6/6 | 4,668 | 153,090 | 40,928 |
| Visibility | Mouth X minus | `mouthXPosition_minus0p25` vs baseline | 6/6 | 4,174 | 153,090 | 29,307 |
| Visibility | Lip peak | `lipPeakDefinition_0p25` vs baseline | 6/6 | 1,921 | 153,090 | 16,651 |
| Visibility | Lip plump | `lipPlump_0p25` vs baseline | 6/6 | 2,994 | 153,090 | 20,584 |
| Signed direction | Mouth Y | plus vs minus | 6/6 | 5,164 | 153,090 | 98,853 |
| Signed direction | Mouth tilt | plus vs minus | 6/6 | 4,915 | 153,090 | 85,163 |
| Signed direction | Mouth X | plus vs minus | 6/6 | 5,113 | 153,090 | 56,121 |
| Peak independence | Smile | lip peak vs `smile_0p50` | 6/6 | 3,315 | 153,090 | 37,186 |
| Peak independence | Mouth size | lip peak vs `mouthSize_plus0p35` | 6/6 | 5,227 | 153,090 | 63,525 |
| Plump independence | Mouth size | lip plump vs `mouthSize_plus0p35` | 6/6 | 5,248 | 153,090 | 55,448 |
| Plump independence | Lip color | lip plump vs `lipColor_0p50` | 6/6 | 5,217 | 153,090 | 50,972 |
| Plump independence | Lip peak | lip plump vs lip peak | 6/6 | 2,854 | 153,090 | 19,171 |

Aggregates are exactly 48/48 visibility, 18/18 signed-direction, 12/12 peak-independence, and 18/18 plump-independence comparisons: 96/96 direct portrait pairs. The sixteen families remain separate gates so a strong effect cannot conceal an invisible or aliased path. `lipColor_0p50` is a nearest non-alias comparator only; it does not by itself prove physical plumping.

## No-Face and Artifact Boundary

All eight new no-face outputs exist, fully decode, remain non-empty, and preserve 64 × 64. The renderer-matched full-row exclusion yields no rows for the deliberately tiny fixture because the minimum label band consumes the canvas. The fixed fallback therefore compares all 2,048 pixels in the right half, outside the observed left-origin label raster. Every new case is exactly baseline-identical there: 8/8, zero changed pixels and zero RGB delta.

- Renderer input and output bytes remain local; committed evidence contains aggregate counts and minima only.
- `git check-ignore` succeeds for `example-images/output` and representative new outputs.
- `git ls-files example-images/output example-images/gallery` is empty.
- No raw landmarks, control points, face geometry, decoded pixels, or fixture content enters this report.

## Explicit Non-Claims

- The `0.25` values are provisional evidence inputs, not final safety caps or commercial calibration.
- Visible direct-pair differences prove distinguishable saved output inside the fixed ROI, not subjective naturalness.
- This phase does not prove physical-device parity, optimized performance, packaging, shipping, launch readiness, or broad product parity.
- Final caps, exhaustive missing/stale/reused/provider-empty behavior, combined weakening, active-source boundary closeout, current-owner documentation synchronization, feature promotion, and branch completion remain Phase 40 responsibilities.
