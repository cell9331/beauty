---
phase: 24-renderer-output-regression-hardening
status: passed
updated: 2026-07-02
requirements:
  - RENDER-01
  - RENDER-02
  - RENDER-03
  - RENDER-04
score: 4/4
---

# Phase 24 Verification

Phase 24 verifies the current public-facade `BeautyExampleRenderer` output path for the existing skin, color, and filter matrix. It also records guardrails so this renderer evidence is not mistaken for geometry saved-output completion or product-readiness evidence.

## Requirement Results

| Requirement | Status | Evidence |
| --- | --- | --- |
| RENDER-01 | passed | `BeautyRendererOutputRegressionTests.testRendererCaseInventoryMatchesCurrentPublicFacadeMatrix` locks the current 9-case renderer matrix and verifies `BeautyExampleRenderer/main.swift` imports the public `BeautySDK` facade. |
| RENDER-02 | passed | `BeautyRendererOutputRegressionTests.testDefaultParametersPreserveCurrentFixturePixelsBeforeWatermark` verifies default `BeautyParameters` preserve `e1.png` through `e5.png` rendered pixels before renderer watermarking with exact RGBA equality. |
| RENDER-03 | passed | `24-RENDERER-EVIDENCE.md` and `check_renderer_outputs.py` verify the current `5 x 9` generated PNG inventory for existence, non-empty files, same dimensions, input/output byte difference, ignored-output policy, and representative watermark readability notes. |
| RENDER-04 | recorded | Phase 24 keeps geometry saved-output deferred, verifies no geometry renderer cases were added, and preserves the strict branch statuses from `docs/meitu-function-blueprint/FEATURE_MATRIX.md`. |

## Command Results

| Gate | Status | Exact command | Result |
| --- | --- | --- | --- |
| Focused renderer regression tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Executed 2 tests, 0 failures. |
| Full SwiftPM suite | passed | `swift test --package-path BeautySDK` | Executed 150 tests, 0 failures. |
| Renderer executable build | passed | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product `BeautyExampleRenderer` successfully. |
| Renderer all-case run | passed | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 45 PNG outputs, covering 5 fixtures times 9 current renderer cases. |
| Generated-output helper | passed | `python3 .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py --input example-images/input --output example-images/out` | `45/45` outputs passed; dimensions were `576x1024: 9`, `1440x2560: 18`, `1728x2304: 9`, and `2160x3840: 9`. |
| Ignored-output policy | passed | `git check-ignore example-images/out/e1__skinSmoothing_0p50.png example-images/out/e3__filter_warmLight_0p50.png example-images/out/e5__skinCombo_0p50.png` | Representative generated outputs are ignored by git. |
| Public facade import scan | passed | `! rg -n 'import Beauty(Core\|Detection\|Effects\|Render\|Resources)' BeautySDK/Sources/BeautyExampleRenderer/main.swift BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | No internal SDK target imports found. |
| Renderer geometry-case exclusion scan | passed | `! rg -n 'id: "(face\|eye\|nose\|mouth\|lip\|chin\|jaw\|proportion\|3d\|brow)\|BeautyParameters\([^)]*(faceSlim\|faceSmall\|faceVShape\|jawSlim\|chinLength\|eyeSize\|eyeDistance\|eyeYPosition\|eyeTailLift\|noseSlim\|noseWingSlim\|noseTipSize\|noseBridge\|mouthSize\|mouthWidth\|smile\|lipColor)' BeautySDK/Sources/BeautyExampleRenderer/main.swift` | No geometry saved-output renderer cases found. |
| Geometry status scan | passed | Scoped `rg` negative scan from Plan 24-03 over blueprint docs, `24-RENDERER-EVIDENCE.md`, and this verification file. | No locked geometry branch is stated as complete in the scoped artifacts. |
| No-overclaim scan | passed | Scoped `rg` negative scan from Plan 24-03 over `EXAMPLE_IMAGE_VALIDATION.md`, `24-RENDERER-EVIDENCE.md`, and this verification file. | No forbidden wording found in the scoped evidence docs. |
| Decision coverage | passed | `node /Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs query check.decision-coverage-plan .planning/phases/24-renderer-output-regression-hardening .planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md` | 16 of 16 tracked decisions covered by plans. |

## Geometry Status Guard

Phase 24 does not add public-facade geometry saved-output evidence.

Locked branch statuses remain:

| Branch | Status after Phase 24 | Required future evidence before visual completion |
| --- | --- | --- |
| `3D塑颜` | `blocked-by-geometry-output` | Public facade detection plus geometry rendering must produce same-dimension watermarked saved outputs. |
| `比例` | `partial` | Public facade detection plus geometry rendering must produce same-dimension watermarked saved outputs. |
| `脸型` | `partial` | Public facade detection plus geometry rendering must produce same-dimension watermarked saved outputs. |
| `眼睛` | `partial` | Public facade detection plus geometry rendering must produce same-dimension watermarked saved outputs. |
| `嘴唇` | `partial` | Public facade detection plus geometry rendering must produce same-dimension watermarked saved outputs. |
| `鼻子` | `partial` | Public facade detection plus geometry rendering must produce same-dimension watermarked saved outputs. |
| `眉毛` | `future` | Future parameter design and evidence must exist before branch promotion. |

## Evidence Boundaries

Phase 24 evidence is limited to relative paths, fixture names, case IDs, output counts, dimensions, command status, invariant status, representative watermark observations, and explicit next steps.

The phase does not add public parameters, Demo UI, product routes, service-transfer behavior, committed PNG baselines, raw pixel payloads, facial measurement payloads, unredacted framework diagnostics, reference-app parity evidence, or market visual-quality evidence.

## Final Status

Phase 24 verification passed for RENDER-01 through RENDER-04. Geometry saved-output remains future work, and generated PNGs remain ignored local artifacts under `example-images/out/`.
