# Phase 47 Face Output Evidence

**Accepted:** 2026-07-24
**Scope:** public-facade saved-image evidence for `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`

## Result

PASS. An independent clean render produced and the bounded strict helper accepted exactly 59 renderer cases × 7 committed fixtures = 413 regular, non-empty, fully decoded, same-dimension PNG outputs.

The helper consumes saved public-facade pixels only. It imports no SDK internals, infers no landmark coordinates, selects no dynamic comparator, and exposes no raw geometry.

## Reproduction

Measurement and strict acceptance were separate clean renders. The physical output root was resolved before each clean, required to equal the repository allow-list, and required to be ignored.

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build \
  --package-path BeautySDK --product BeautyExampleRenderer

OUTPUT_ROOT="$(cd example-images/output && pwd -P)"
test "$OUTPUT_ROOT" = "$(pwd -P)/example-images/output"
git check-ignore -q example-images/output
find "$OUTPUT_ROOT" -mindepth 1 -delete

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run \
  --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input --output example-images/output

python3 .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift \
  --measure
```

After constants were frozen, the same guarded clean and render were repeated, followed by strict mode without `--measure`.

```bash
python3 .planning/phases/47-public-facade-face-output-evidence/check_face_geometry_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

## Exact Matrix

| Input dimensions | Fixtures | Outputs |
| --- | ---: | ---: |
| 64 × 64 | 1 | 59 |
| 506 × 900 | 4 | 236 |
| 675 × 900 | 1 | 59 |
| 1728 × 2304 | 1 | 59 |
| **Total** | **7** | **413** |

The strict matrix rejects missing, extra, stale, empty, symlinked, malformed, dimension-changing, or duplicate-name evidence.

## Frozen Regions, Floors, and Eligibility

Coordinates are normalized, top-origin, shared across fixtures, and wholly above the renderer watermark.

| Case | Region `(left,right,top,bottom)` | Eligible portraits | Visibility floor `(changed, RGB)` | Measured minimum `(changed, RGB)` | Intended share / outside |
| --- | --- | ---: | --- | --- | --- |
| `faceContourSmooth_0p25` | `(0.10,0.92,0.28,0.82)` | 5/6 | `5000 / 15000` | `6689 / 23583` | `1.000000 / 0` |
| `templeFullness_0p25` | `(0.10,0.92,0.32,0.80)` | 5/6 | `4000 / 18000` | `5376 / 26808` | `1.000000 / 0` |
| `cheekboneSlim_0p25` | `(0.20,0.82,0.24,0.65)` | 4/6 | `3500 / 20000` | `4558 / 29824` | `1.000000 / 0` |
| `chinTaper_0p25` | `(0.33,0.70,0.24,0.62)` | 4/6 | `1000 / 3000` | `1850 / 5360` | `1.000000 / 0` |

Strict locality requires at least `0.99` of absolute RGB signal inside the fixed intended region and permits zero changed pixels or RGB delta elsewhere in the watermark-safe image. All 18/18 eligible visibility/locality comparisons passed.

The frozen eligibility partition is:

- contour smooth and temple fullness: `e2`, `e3`, `e4`, `e5`, `e6`;
- cheekbone slim and chin taper: `e2`, `e3`, `e5`, `e6`.

The six excluded portrait/field pairs were required to be exact watermark-safe baseline no-ops and passed 6/6. They were not counted as weak visibility passes.

## Fixed-Neighbor Independence

| Candidate | Fixed comparator | Comparisons | Fixed family floor `(changed, RGB)` | Measured minimum `(changed, RGB)` |
| --- | --- | ---: | --- | --- |
| contour smooth | face small | 5/5 | `8000 / 80000` | `16034 / 190983` |
| contour smooth | face slim | 5/5 | `8000 / 80000` | `12036 / 121868` |
| temple fullness | face small | 5/5 | `6000 / 35000` | `16151 / 212662` |
| temple fullness | face slim | 5/5 | `6000 / 35000` | `11626 / 146135` |
| temple fullness | cheekbone slim | 5/5 | `6000 / 35000` | `8587 / 53186` |
| cheekbone slim | face slim | 4/4 | `6000 / 35000` | `12229 / 121475` |
| cheekbone slim | jaw slim | 4/4 | `6000 / 35000` | `10202 / 92768` |
| cheekbone slim | temple fullness | 4/4 | `6000 / 35000` | `8580 / 53178` |
| chin taper | chin length plus | 4/4 | `2500 / 18000` | `4030 / 29243` |
| chin taper | chin length minus | 4/4 | `2500 / 18000` | `3855 / 32871` |
| chin taper | V shape | 4/4 | `2500 / 18000` | `8037 / 94675` |

All 49/49 fixed-neighbor comparisons passed. Comparator families are declared constants and cannot be selected from the accepting matrix.

## Safe No-Ops and Boundary

- No-face fixture: all four new cases were exact no-ops in the fixed 2,048-pixel watermark-safe fallback, 4/4.
- Public route: the renderer retains exactly one `BeautyEngine.processResult` call and imports only system frameworks plus `BeautySDK`.
- Bounded decoder: 16 MiB compressed PNG/JPEG limit, 4096 × 4096 dimension limit, 64 MiB decoded limit, descriptor/no-follow identity checks, strict PNG CRC/chunk/zlib/filter validation.
- Helper self-test: duplicate IDs/stems, missing/extra outputs, CRC/zlib/filter/dimension/budget failures, descriptor replacement/growth, watermark overlap, zero floors, wrong comparator families, eligibility drift, outside-only change, raw disclosure, and no-face fallback all fail closed as intended.

## Artifact Containment

The 413 PNGs remain ignored and untracked under `example-images/output/`. This phase commits the helper and aggregate evidence only; generated bytes are not staged or committed.

## Nonclaims

This evidence accepts the provisional output strength `0.25` and proves public saved-image visibility, locality, independence, and representative safe no-ops. It does not establish final safety caps, exhaustive fresh/reused/stale transitions, product-row promotion, branch completion, or milestone readiness. Those remain Phase 48 responsibilities.
