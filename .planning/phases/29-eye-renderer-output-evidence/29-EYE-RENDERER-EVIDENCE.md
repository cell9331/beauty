---
phase: 29-eye-renderer-output-evidence
status: passed
verified: 2026-07-09
requirements:
  - EYE-01
  - EYE-02
  - EYE-03
---

# Phase 29 Eye Renderer Evidence

## Scope

This artifact records SDK-only public-facade renderer evidence for the v1.6 existing public `眼睛` parameter slice.

What is proven:

- `BeautyExampleRenderer` runs the public `BeautySDK` still-image facade for 7 input fixtures and 23 renderer cases.
- Six Phase 29 eye renderer cases exist: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- The Phase 29 helper verifies output existence, non-empty PNG files, same input/output dimensions, and 36/36 portrait eye-vs-`geometryBaseline_noop` top-region differences above the watermark band.
- Generated output and gallery artifacts stay under ignored `example-images/output/` and `example-images/gallery/` paths.

What is not claimed:

- No Demo UI behavior changed.
- No new public `BeautyParameters` field was added.
- No public raw geometry API was added.
- No generated PNG baselines, hashes, or generated outputs are committed.
- No commercial review, device parity, broad Meitu parity, launch readiness, or whole-branch eye completion claim is made.
- `眼睛` rows and branch remain `partial` until Phase 30 records safety, degradation, redaction, and scoped status evidence.

## Requirement Mapping

| Requirement | Scope | Evidence case or check | Status |
| --- | --- | --- | --- |
| EYE-01 | Public-facade saved-output cases | Six eye `RenderCase` entries in `BeautyExampleRenderer` and renderer inventory tests | passed |
| EYE-02 | Eye helper output validation | `check_eye_renderer_outputs.py` passed with 161/161 outputs and 36/36 eye-vs-baseline comparisons | passed |
| EYE-03 | Ignored output/gallery artifacts | `git check-ignore`, gallery generation, and `git ls-files` generated-artifact scan | passed |

## Command Evidence

| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Renderer regression tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Executed 7 tests with 0 failures. Covered the 23-case renderer inventory, public-facade import boundary, and six Phase 29 eye case IDs. | EYE-01 |
| Eye provider tests | passed | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` | Executed 6 tests with 0 failures. Covered current eye fields, caps, deterministic output, and missing-eye skip behavior. | EYE-01 |
| Full SDK tests | passed | `swift test --package-path BeautySDK` | Executed 173 tests with 0 failures. | EYE-01 through EYE-03 |
| Renderer build | passed | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product `BeautyExampleRenderer` successfully. | EYE-01 |
| Renderer all-case run | passed | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` | Wrote 161 PNG outputs, confirmed by `rg -c '^wrote '`. | EYE-01, EYE-02 |
| Phase 29 helper | passed | `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` | Passed with 161/161 outputs and 36/36 portrait eye-vs-baseline top-region comparisons. | EYE-02 |
| Gallery generation | passed | `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` | Wrote 161 gallery PNGs under `example-images/gallery`. | EYE-03 |
| Ignored-output policy | passed | `git check-ignore example-images/output/e1__eyeSize_0p35.png example-images/output/e1__eyeDistance_minus0p25.png example-images/output/no-face-gradient__eyeSize_0p35.png example-images/gallery/eyes/eyeSize_0p35/e1.png example-images/gallery/eyes/eyeTailLift_0p25/no-face-gradient.png` | Representative generated output and gallery files are ignored by git. | EYE-03 |
| Generated artifact staging scan | passed | `git ls-files example-images/output example-images/gallery \| wc -l \| tr -d ' '` | Returned `0`; no generated output or gallery files are tracked. | EYE-03 |

## Renderer Matrix

The Phase 29 renderer matrix is owned by `BeautySDK/Sources/BeautyExampleRenderer/main.swift`.

| Case ID | Output files | Parameter coverage |
| --- | ---: | --- |
| `skinSmoothing_0p50` | 7 | Existing skin smoothing proxy |
| `skinWhitening_0p50` | 7 | Existing skin whitening |
| `skinRosy_0p40` | 7 | Existing rosy skin |
| `skinSharpen_0p40` | 7 | Existing sharpen/contrast proxy |
| `brightness_plus0p25` | 7 | Existing color brightness |
| `contrast_plus0p25` | 7 | Existing color contrast |
| `filter_softClean_0p50` | 7 | Existing built-in filter |
| `filter_warmLight_0p50` | 7 | Existing built-in filter |
| `skinCombo_0p50` | 7 | Existing combined basic skin parameters |
| `geometryBaseline_noop` | 7 | No-geometry baseline using default parameters |
| `faceShapeCombo_0p35` | 7 | Existing combined face-shape foundation case |
| `faceSlim_0p35` | 7 | Existing `faceSlim` |
| `faceSmall_0p35` | 7 | Existing `faceSmall` |
| `chinLength_plus0p30` | 7 | Existing positive `chinLength` |
| `chinLength_minus0p30` | 7 | Existing negative `chinLength` |
| `faceVShape_0p35` | 7 | Existing `faceVShape` |
| `jawSlim_0p35` | 7 | Existing `jawSlim` |
| `eyeSize_0p35` | 7 | `eyeSize: 0.35` |
| `eyeDistance_plus0p25` | 7 | `eyeDistance: 0.25` |
| `eyeDistance_minus0p25` | 7 | `eyeDistance: -0.25` |
| `eyeYPosition_plus0p20` | 7 | `eyeYPosition: 0.20` |
| `eyeYPosition_minus0p20` | 7 | `eyeYPosition: -0.20` |
| `eyeTailLift_0p25` | 7 | `eyeTailLift: 0.25` |

## Eye Parameter Mapping

| Public field | Evidence case IDs | Notes |
| --- | --- | --- |
| `eyeSize` | `eyeSize_0p35` | Single moderate-strength size case. |
| `eyeDistance` | `eyeDistance_plus0p25`, `eyeDistance_minus0p25` | Both signed directions are covered. |
| `eyeYPosition` | `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20` | Both signed vertical directions are covered. |
| `eyeTailLift` | `eyeTailLift_0p25` | Positive-only renderer evidence; signed/cap safety belongs to Phase 30. |

## Generated-Output Helper Result

The helper output was:

```text
phase 29 eye renderer output check passed: 161/161 outputs
dimensions 64x64: 23 outputs
dimensions 506x900: 92 outputs
dimensions 675x900: 23 outputs
dimensions 1728x2304: 23 outputs
portrait eye-vs-baseline top-region comparisons: 36/36
no-face eye output present: negatives/no-face-gradient.png -> no-face-gradient__eyeSize_0p35.png
fixtures: portraits/e1.png, portraits/e2.png, portraits/e3.png, portraits/e4.png, portraits/e5.png, portraits/e6.jpg, negatives/no-face-gradient.png
cases: skinSmoothing_0p50, skinWhitening_0p50, skinRosy_0p40, skinSharpen_0p40, brightness_plus0p25, contrast_plus0p25, filter_softClean_0p50, filter_warmLight_0p50, skinCombo_0p50, geometryBaseline_noop, faceShapeCombo_0p35, faceSlim_0p35, faceSmall_0p35, chinLength_plus0p30, chinLength_minus0p30, faceVShape_0p35, jawSlim_0p35, eyeSize_0p35, eyeDistance_plus0p25, eyeDistance_minus0p25, eyeYPosition_plus0p20, eyeYPosition_minus0p20, eyeTailLift_0p25
phase 29 cases: eyeSize_0p35, eyeDistance_plus0p25, eyeDistance_minus0p25, eyeYPosition_plus0p20, eyeYPosition_minus0p20, eyeTailLift_0p25
```

## Static Scan Evidence

| Gate | Scope | Result |
| --- | --- | --- |
| Public raw geometry export guard | `BeautySDK/Sources/BeautySDK`, `BeautySDK/Sources/BeautyDetection`, `BeautySDK/Sources/BeautyEffects` | Passed with zero matches. |
| Demo and renderer internal-import guard | `BeautyDemo/BeautyDemo`, `BeautyDemo/BeautyDemoTests`, and `BeautyExampleRenderer/main.swift` | Passed with zero internal SDK target imports. |
| Helper output redaction | Phase 29 helper output | Passed with zero forbidden raw payload tokens. |
| No-overclaim wording | Phase 29 summaries and example-image validation doc | Passed with zero prohibited quality, parity, readiness, or eye completion claims. |
| Legacy output path guard | Touched active docs | Passed with zero `example-images/out/` references. |

## Evidence Field Allowlist

This artifact is limited to relative paths, fixture names, case IDs, counts, dimensions, command status, requirement IDs, and factual evidence notes.

It does not include raw facial measurements, raw eye geometry, local absolute paths, raw framework diagnostics, raw preset payloads, image payload dumps, hashes, or committed PNG baselines.

## Rerun Protocol

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output
python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery
git check-ignore example-images/output/e1__eyeSize_0p35.png example-images/output/e1__eyeDistance_minus0p25.png example-images/output/no-face-gradient__eyeSize_0p35.png example-images/gallery/eyes/eyeSize_0p35/e1.png example-images/gallery/eyes/eyeTailLift_0p25/no-face-gradient.png
```

Generated PNGs should remain local ignored artifacts. Markdown evidence, XCTest results, helper output, gallery output, and scan results are the repository evidence.
