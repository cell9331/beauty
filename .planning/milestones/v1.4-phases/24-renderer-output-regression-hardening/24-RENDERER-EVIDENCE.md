---
phase: 24-renderer-output-regression-hardening
status: draft
updated: 2026-07-02
requirements:
  - RENDER-01
  - RENDER-02
  - RENDER-03
  - RENDER-04
---

# Phase 24 Renderer Evidence

## Scope

This artifact records the Phase 24 renderer-output regression evidence for the current public-facade `BeautyExampleRenderer` path.

Status values:

- `passed`: command, helper, scan, or representative inspection ran in this phase and passed.
- `recorded`: evidence exists with an explicit limitation.
- `blocked`: tooling or future implementation is required before the evidence can exist.
- `not run`: evidence is intentionally left to a documented rerun protocol.

## Non-Claims

- Phase 24 evidence covers current skin, color, and filter renderer outputs only.
- Phase 24 does not assert market visual quality, naturalness, device coverage, reference-app parity, or shipping readiness.
- Phase 24 does not implement geometry saved-output and does not mark geometry-heavy branches visually complete.
- Generated PNGs remain local ignored artifacts under `example-images/out/`; Markdown evidence and helper commands are the repository evidence.

## Exact Command Results

| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Focused renderer regression tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Executed 2 tests, 0 failures. Exact no-op RGBA equality passed for `e1.png` through `e5.png`; no tolerance fallback was introduced. | RENDER-01, RENDER-02 |
| Full SDK suite | passed | `swift test --package-path BeautySDK` | Executed 150 tests, 0 failures. | RENDER-01, RENDER-02 |
| Renderer build | passed | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product `BeautyExampleRenderer` successfully. | RENDER-01, RENDER-03 |
| Renderer all-case run | passed | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 45 PNG outputs: 5 fixtures times 9 current renderer cases. | RENDER-03 |
| Generated-output invariant helper | passed | `python3 .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py --input example-images/input --output example-images/out` | `45/45` outputs passed existence, non-empty, same-dimension, and input-difference checks. | RENDER-03 |
| Ignored-output policy | passed | `git check-ignore example-images/out/e1__skinSmoothing_0p50.png example-images/out/e2__skinWhitening_0p50.png example-images/out/e5__skinCombo_0p50.png` | Representative generated PNG outputs are ignored by git. | RENDER-03 |
| Output count | passed | `find example-images/out -maxdepth 1 -type f -name '*.png' \| wc -l` | Counted 45 generated PNG outputs. | RENDER-03 |
| Public facade import scan | passed | `! rg -n 'import Beauty(Core\|Detection\|Effects\|Render\|Resources)' BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift BeautySDK/Sources/BeautyExampleRenderer/main.swift` | No internal SDK target imports in the focused regression test or renderer executable. | RENDER-01 |
| Renderer geometry-case exclusion scan | passed | `! rg -n 'id: "(face\|eye\|nose\|mouth\|lip\|chin\|jaw\|proportion\|3d\|brow)\|BeautyParameters\([^)]*(faceSlim\|faceSmall\|faceVShape\|jawSlim\|chinLength\|eyeSize\|eyeDistance\|eyeYPosition\|eyeTailLift\|noseSlim\|noseWingSlim\|noseTipSize\|noseBridge\|mouthSize\|mouthWidth\|smile\|lipColor)' BeautySDK/Sources/BeautyExampleRenderer/main.swift` | No geometry saved-output renderer cases. | RENDER-04 |

## Current Renderer Matrix

`BeautySDK/Sources/BeautyExampleRenderer/main.swift` remains the code-owned source of truth. Phase 24 verified these current case IDs in declaration order:

| Case ID | Output files | Parameter coverage |
| --- | ---: | --- |
| `skinSmoothing_0p50` | 5 | Basic skin smoothing proxy |
| `skinWhitening_0p50` | 5 | Skin whitening |
| `skinRosy_0p40` | 5 | Rosy skin |
| `skinSharpen_0p40` | 5 | Sharpen/contrast proxy |
| `brightness_plus0p25` | 5 | Color brightness |
| `contrast_plus0p25` | 5 | Color contrast |
| `filter_softClean_0p50` | 5 | Built-in `soft_clean` filter |
| `filter_warmLight_0p50` | 5 | Built-in `warm_light` filter |
| `skinCombo_0p50` | 5 | Combined basic skin parameters |

## Generated-Output Invariants

The helper validated exactly the current `5 x 9` expected output matrix:

| Input dimensions | Output count | Fixtures |
| --- | ---: | --- |
| `576x1024` | 9 | `e2.png` |
| `1440x2560` | 18 | `e4.png`, `e5.png` |
| `1728x2304` | 9 | `e1.png` |
| `2160x3840` | 9 | `e3.png` |

Every expected output existed, was non-empty, matched the source fixture dimensions, and differed byte-for-byte from the source fixture file.

## Representative Watermark Notes

These notes are factual representative observations only; they are not quality scores.

| Output | Status | Observation |
| --- | --- | --- |
| `example-images/out/e1__skinSmoothing_0p50.png` | passed | Bottom label `skinSmoothing 0.50` is readable in the dark band and does not cover the face. |
| `example-images/out/e2__skinWhitening_0p50.png` | passed | Bottom label `skinWhitening 0.50` is readable and sits below the face area. |
| `example-images/out/e5__skinCombo_0p50.png` | passed | Bottom label `skin combo 0.50` is readable and does not cover the face. |

## No-Op Tolerance Status

Plan `24-01` added `BeautyRendererOutputRegressionTests.testDefaultParametersPreserveCurrentFixturePixelsBeforeWatermark`.

The test loads `example-images/input/e1.png` through `e5.png`, calls `BeautyEngine.processResult(image:metadata:parameters:)` with default `BeautyParameters`, renders input and output with the same fixed DeviceRGB `CIContext` and RGBA8 format, and compares the bytes before renderer watermarking.

Result: exact equality passed for all five current fixtures. No platform color-management fallback tolerance was needed.

## Evidence Field Allowlist

This artifact is limited to relative paths, fixture names, case IDs, counts, dimensions, command status, file-size/change status, factual watermark notes, blocker class, impact, next step, and rerun protocol.

It does not include raw pixel payloads, machine-local absolute paths, facial measurement payloads, unredacted framework diagnostics, service-transfer claims, or committed PNG baselines.

## Geometry Boundary

Phase 24 guards status only. Current renderer evidence does not add face, eye, nose, mouth, lip, chin, jaw, proportion, 3D sculpt, or brow cases to `BeautyExampleRenderer`.

Geometry-heavy branches remain limited by `docs/meitu-function-blueprint/FEATURE_MATRIX.md`: `3D塑颜` stays `blocked-by-geometry-output`; `比例`, `脸型`, `眼睛`, `嘴唇`, and `鼻子` stay `partial`; `眉毛` stays `future` unless future public-facade detection plus geometry rendering produces same-dimension watermarked outputs through `BeautyExampleRenderer`.

## Rerun Protocol

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out
python3 .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py --input example-images/input --output example-images/out
git check-ignore example-images/out/e1__skinSmoothing_0p50.png example-images/out/e2__skinWhitening_0p50.png example-images/out/e5__skinCombo_0p50.png
```

Generated PNGs should remain under ignored `example-images/out/`. Record command status and representative factual notes in Markdown instead of committing generated PNG baselines.

## Requirement Coverage

| Requirement | Status | Evidence |
| --- | --- | --- |
| RENDER-01 | passed | `BeautyRendererOutputRegressionTests` verifies the exact current 9-case renderer matrix and public-facade import boundary. |
| RENDER-02 | passed | Default `BeautyParameters` preserve `e1.png` through `e5.png` rendered pixels before watermarking with exact equality. |
| RENDER-03 | passed | The renderer build/run and helper verify 45 current generated PNG outputs for existence, non-empty files, same dimensions, and byte-difference from source fixtures; representative watermark notes are recorded. |
| RENDER-04 | recorded | Phase 24 verifies no renderer geometry cases were added and records the existing geometry status boundary; geometry saved-output remains future work. |
