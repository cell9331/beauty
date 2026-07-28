# Phase 51 Eyebrow Output Evidence

**Accepted:** 2026-07-27  
**Active portrait:** `example-images/input/portraits/e6.jpg`  
**Separate negative:** `example-images/input/negatives/no-face-gradient.png`

## Scope and Count Vocabulary

- Renderer inventory: exactly 72 public-facade cases, including thirteen isolated Phase 51 eyebrow cases.
- Portrait matrix: exactly 72 decoded `e6` PNG outputs at 1728×2304.
- Negative safety set: thirteen eyebrow candidates compared with the no-face baseline at 64×64.
- Disposable output inventory: exactly 72 cases × two fixtures = 144 ignored regular PNGs. This is not 144 portrait outputs.
- Retired portrait stems `e1` through `e5` were absent from the active input and accepting output roots.
- Each eyebrow case sets one same-named public `BeautyParameters` field at the provisional `±0.25` or `0.25` value and uses the existing `BeautyEngine.processResult`/unified warp route. Phase 52 retains final cap, exhaustive safety, row-promotion, and branch-status ownership.

## Guarded Render Chronology

The output root was physically resolved to the repository allow-list, required to be ignored, and cleaned only through that resolved directory before each render.

1. The one-time measurement render was built and run from a clean output root. The helper was invoked with `--measure`; it reported candidate metrics and explicitly did not close OUT-02.
2. The calibration below was committed as immutable positive floors/ceilings. Strict mode neither derives nor mutates it.
3. The same allow-listed root was cleaned again and rendered independently.
4. Default strict mode decoded the fresh matrix and exited zero with `STRICT ACCEPTANCE: frozen calibration satisfied`.

Reproduction:

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
python3 .planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Measurement used the final command with `--measure` after its own earlier guarded clean render. Measurement output is calibration input, not acceptance evidence.

## Frozen Pixel Contract

The fixed brow ROI is normalized `(0.24, 0.76, 0.24, 0.43)` in canonical top-left image coordinates. Fixed protected families cover the eyes, forehead/hair, side background, and watermark. The label band cannot satisfy a brow gate.

| Gate | Weakest / maximum measured value | Frozen floor / ceiling | Positive margin |
| --- | ---: | ---: | ---: |
| Visibility changed pixels | 30,603 | ≥25,000 | 5,603 |
| Visibility absolute RGB delta | 212,143 | ≥175,000 | 37,143 |
| Signed/family changed pixels | 42,320 | ≥35,000 | 7,320 |
| Signed/family absolute RGB delta | 515,707 | ≥450,000 | 65,707 |
| Protected eyes changed pixels | 477 | ≤750 | 273 |
| Protected eyes absolute RGB delta | 976 | ≤1,500 | 524 |
| Forehead/hair changed pixels / delta | 0 / 0 | ≤32 / 64 | 32 / 64 |
| Background changed pixels / delta | 0 / 0 | ≤32 / 64 | 32 / 64 |
| Watermark changed pixels / delta | 0 / 0 | ≤32 / 64 | 32 / 64 |

The signed direction metrics are fixed semantic predicates, not generic changed-pixel centroids. Thickness and length use robust 5%–95% deformation extents so their signs reflect vertical strip expansion and outer-end horizontal expansion respectively.

| Signed predicate | Measured margin | Frozen floor | Positive margin |
| --- | ---: | ---: | ---: |
| Y position | 0.00029789 | 0.00020000 | 0.00009789 |
| Thickness | 0.00347222 | 0.00250000 | 0.00097222 |
| Length | 0.06250000 | 0.05000000 | 0.01250000 |
| Whole spacing | 0.00331567 | 0.00250000 | 0.00081567 |
| Head spacing | 0.00512488 | 0.00400000 | 0.00112488 |
| Tilt | 0.00301597 | 0.00250000 | 0.00051597 |

## Independent Strict Result

The independent clean strict pass reported:

- 144/144 regular, nonempty, fully decoded, same-dimension outputs.
- 72/72 e6 portrait outputs; 72 outputs at 1728×2304.
- 72 outputs for the separate 64×64 no-face fixture.
- 13/13 eyebrow visibility/locality comparisons.
- 6/6 direct signed-direction comparisons.
- 21/21 positive-family semantic distinctions.
- 40/40 total portrait direct comparisons.
- 13/13 no-face watermark-safe exact no-op comparisons.
- Protected maxima: eyes 477 changed pixels / 976 absolute RGB delta; forehead-hair, background, and watermark 0 / 0.
- Zero accepting `e1`–`e5` output names.

## Root-Cause Corrections Exposed by Actual e6

The actual-image route exposed two pre-output defects that synthetic provider fixtures did not reveal. Commit `77e9228` aligned CPU bitmap sampling with the SDK's canonical top-left/downward image Y and stably ordered exactly-once mapped live Vision eyebrow samples on the mapper-derived face-right axis. This preserved one detector request, actual Vision left/right provenance, independent side failure, request-local support, aggregate-only diagnostics, the unified warp, and provisional caps.

The strict helper was also bounded to one decoded-matrix cache (`a0febc8`) and its immutable calibration shape/reversed-direction/protected-spill contract was locked before acceptance (`b3858d8`). No threshold was lowered to admit a visual defect.

## Visual Review

Each file below was opened individually from the accepted output root with original image detail. Review checked the brows against the baseline and signed sibling while also inspecting the protected eyes, forehead/hair, background, and watermark.

| Actual file opened | Original-detail observation |
| --- | --- |
| `e6__geometryBaseline_noop.png` | Neutral reference retained the original brow placement, thickness, length, spacing, tilt, and soft apex; protected regions provided the comparison baseline. |
| `e6__eyebrowYPosition_plus0p25.png` | Clearly displaced in the positive image-Y direction relative to the negative case; deformation stayed on the two brow strips and did not move the eyes or hairline. |
| `e6__eyebrowYPosition_minus0p25.png` | Clearly displaced opposite the positive case; both brows remained visible and the surrounding protected regions remained visually stable. |
| `e6__eyebrowThickness_plus0p25.png` | Brow strips visibly expanded in thickness without becoming a peak-only edit; eye detail and background were unchanged. |
| `e6__eyebrowThickness_minus0p25.png` | Brow strips visibly contracted relative to the positive and baseline cases; the change remained brow-local. |
| `e6__eyebrowLength_plus0p25.png` | Outer ends extended horizontally and remained distinct from whole-spacing movement; no visible spill reached the eyes or hair. |
| `e6__eyebrowLength_minus0p25.png` | Outer ends contracted relative to the positive case while inner placement stayed recognizably different from head-spacing. |
| `e6__eyebrowSpacing_plus0p25.png` | Both complete brows separated outward, including their bodies and tails; this was visibly broader than an inner-head-only edit. |
| `e6__eyebrowSpacing_minus0p25.png` | Both complete brows moved inward opposite the positive case; protected regions remained stable. |
| `e6__eyebrowHeadSpacing_plus0p25.png` | Inner heads separated while the outer brow bodies stayed substantially anchored, distinguishing it from whole spacing. |
| `e6__eyebrowHeadSpacing_minus0p25.png` | Inner heads moved inward opposite the positive case without collapsing into whole-brow translation. |
| `e6__eyebrowTilt_plus0p25.png` | Canonical outer tails lifted relative to the inner heads and to the negative case; the effect stayed brow-local. |
| `e6__eyebrowTilt_minus0p25.png` | Canonical outer tails moved in the opposite tilt direction; eyes, forehead/hair, and background remained visually protected. |
| `e6__eyebrowPeakDefinition_0p25.png` | Apex neighborhoods became more defined while endpoints and overall strip thickness remained distinct from the thickness edit. |

Visual review verdict: PASS

The accepted result establishes visibility, direction, locality, seven-family distinction, representative no-face safety, and disposable public-facade output evidence only. It does not establish final caps, naturalness/commercial quality, exhaustive lifecycle safety, product-row promotion, branch `眉毛` completion, Demo/device/performance/packaging/shipping, or release readiness.
