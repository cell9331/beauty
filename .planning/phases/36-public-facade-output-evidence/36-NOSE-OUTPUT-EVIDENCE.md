# Phase 36 Remaining-Nose Public-Facade Output Evidence

**Observed:** 2026-07-13  
**Scope:** NOSE-07, NOSE-08, and the output/no-face portion of NOSE-09 only

## Verdict

PASS. A guarded clean regeneration discovered exactly 36 renderer cases and seven recursive fixtures, then wrote and fully decoded exactly 252 public-facade PNGs at their corresponding input dimensions. Fixed nose-local gates separately pass root and lift visibility, root-versus-bridge independence, and lift-versus-both-signed-tip independence.

The renderer cases `noseRootNarrowing_0p25` and `noseTipLift_0p25` remain isolated provisional evidence inputs. This evidence does not promote `山根`, `提升`, or branch-level `鼻子`.

## Commands and Guarded Regeneration

Run from `/Users/yakangwang/codes/beauty`:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift build --package-path BeautySDK --product BeautyExampleRenderer

OUTPUT_ROOT="$(cd example-images/output && pwd -P)"
EXPECTED_ROOT="$(pwd -P)/example-images/output"
test "$OUTPUT_ROOT" = "$EXPECTED_ROOT"
git check-ignore -q example-images/output
find "$OUTPUT_ROOT" -mindepth 1 -type f -delete

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input --output example-images/output

python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift

test "$(find example-images/output -type f -name '*.png' | wc -l | tr -d ' ')" -eq 252
```

The physical-path equality and ignore checks ran before both the measurement cleanup and the final strict cleanup. Each cleanup deleted only files below the exact allow-listed `example-images/output` root. The renderer built successfully before regeneration.

## Discovered Inventories

The helper parses ordered `id:` values from the actual renderer source, recursively discovers regular PNG/JPG/JPEG fixtures, rejects duplicate IDs and flattened stems, computes the product, and only then applies the frozen Phase 36 contract.

- Cases: 36, including each new case exactly once.
- Fixtures: 7 = six portraits plus `negatives/no-face-gradient.png`.
- Computed matrix: 36 × 7 = 252.
- Strict result: 252/252 non-empty, completely decoded PNGs with no missing or unexpected output.
- Fixture order: `negatives/no-face-gradient.png`, `portraits/e1.png`, `portraits/e2.png`, `portraits/e3.png`, `portraits/e4.png`, `portraits/e5.png`, `portraits/e6.jpg`.

| Output dimensions | Output count |
| --- | ---: |
| 64 × 64 | 36 |
| 506 × 900 | 144 |
| 675 × 900 | 36 |
| 1728 × 2304 | 36 |

The self-test rejects duplicate renderer IDs, duplicate fixture stems, missing output, unexpected output, corrupt/incomplete PNG data, and a nose ROI that crosses the watermark boundary. The helper owns its standard-library PNG/JPEG parsing and PNG filter reversal; it imports no sibling phase helper and remains archive-safe.

## Fixed ROI and Non-Circular Thresholds

All portrait comparisons use one top-origin normalized rectangle:

- x = `[0.25 × width, 0.75 × width)`
- y = `[0.20 × height, 0.70 × height)`

For every portrait, the helper asserts the ROI bottom is no lower than the renderer-matched comparable-row boundary:

```text
fontSize = max(34, min(72, width / 30))
padding = max(24, width / 70)
excludedBottomRows = ceil(padding * 2 + fontSize * 1.75)
comparableRows = max(0, height - excludedBottomRows)
```

The measurement render used the committed ROI without applying acceptance floors. Its lowest observed family result was 1,130 changed pixels and 5,125 total absolute RGB delta. Before the final accepting render, the helper was frozen at these global floors:

- changed pixels ≥ 500 (630 below the observed minimum; about 44% of that minimum)
- total absolute RGB delta ≥ 2,000 (3,125 below the observed minimum; about 39% of that minimum)

The strict run performed a second guarded cleanup and regeneration after those constants were fixed. It could not lower or derive its own thresholds.

## Strict Comparison Results

The 64 × 64 no-face fixture is excluded from every portrait family.

| Family | Direct pair | Passed | Minimum changed pixels | Minimum ROI pixels | Minimum absolute RGB delta |
| --- | --- | ---: | ---: | ---: | ---: |
| Root visibility | `noseRootNarrowing_0p25` vs `geometryBaseline_noop` | 6/6 | 1,130 | 113,850 | 5,125 |
| Lift visibility | `noseTipLift_0p25` vs `geometryBaseline_noop` | 6/6 | 1,644 | 113,850 | 26,334 |
| Root independence | `noseRootNarrowing_0p25` vs `noseBridge_0p30` | 6/6 | 1,291 | 113,850 | 5,951 |
| Lift positive independence | `noseTipLift_0p25` vs `noseTipSize_plus0p30` | 6/6 | 1,839 | 113,850 | 20,433 |
| Lift negative independence | `noseTipLift_0p25` vs `noseTipSize_minus0p30` | 6/6 | 2,132 | 113,850 | 34,911 |

Aggregates are exactly 12/12 new-field-versus-baseline visibility comparisons, 6/6 root-versus-bridge comparisons, and 12/12 lift-versus-signed-tip comparisons. The five families remain separately gated so one strong family cannot mask another alias or invisible path.

## No-Face Output

Both new no-face outputs exist, are non-empty, fully decode, and preserve the committed 64 × 64 extent. The renderer-matched full-row exclusion returns zero comparable rows for this deliberately tiny fixture because its minimum 34-point label band is taller than the canvas. The helper therefore uses a fixed conservative fallback: all 2,048 pixels in the right half, outside the observed left-origin label raster. Both new outputs are exactly baseline-identical there (2/2 comparisons, zero changed pixels and zero RGB delta).

The saved pixels complement, but do not replace, Plan 36-01's public-facade XCTest evidence for `.noFace`, `.noFaceDetected`, zero used faces, aggregate-only geometry-required metrics, category warning, and redacted diagnostics. Exhaustive six-field missing/stale/reused/provider-empty behavior remains Phase 37.

## Artifact and Privacy Boundary

- Renderer inputs and outputs remain local; the helper writes only aggregate counts and minima to committed evidence.
- `git check-ignore` succeeds for `example-images/output` and representative new PNGs.
- `git ls-files example-images/output example-images/gallery` is empty.
- No generated output or gallery PNG is staged or tracked; generated PNGs remain disposable evidence inputs.
- No raw landmarks, control points, face geometry, decoded pixels, or fixture content enter this document.

## Explicit Non-Claims

- The `0.25` values are provisional renderer inputs, not final safety caps or commercial calibration.
- `noseRootNarrowing` is not reinterpreted as `noseBridge`; `noseTipLift` is not reinterpreted as either signed `noseTipSize` direction.
- This plan does not prove commercial naturalness, physical-device parity, performance readiness, packaging, shipping, launch readiness, or broad product parity.
- Final caps, exhaustive safety/degradation, exactly-once combined weakening, active-source boundary closeout, gallery/current-owner synchronization, feature promotion, branch completion, and DOC-01 remain later owners.
