---
phase: 27-geometry-render-output-and-verification-harness
status: passed
reviewed: 2026-07-07
depth: standard-inline
open_findings: 0
fixed_findings: 1
---

# Phase 27 Code Review

## Result

No open findings remain after review and fix.

## Fixed During Review

| Severity | Area | Finding | Fix | Verification |
| --- | --- | --- | --- | --- |
| Warning | `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` | The helper compared full watermarked baseline and geometry PNG bytes. Different bottom labels could make the comparison pass even if the rendered image content above the watermark was unchanged. | Added dependency-free PNG decoding for 8-bit RGB/RGBA files and changed portrait baseline comparisons to compare only the top image region above the watermark band. Updated evidence wording to `top-region comparisons`. | `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` passed with 66/66 outputs and 5/5 portrait geometry-vs-baseline top-region comparisons. |

## Files Reviewed

- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`
- `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`

## Review Notes

- Still-image detection remains package-only and maps Vision observations into redacted public summaries plus internal observations.
- `BeautyEngine.processResult(image:metadata:parameters:)` keeps the public API stable while passing selected-face data only to the internal image render path.
- Geometry output is bounded to a deterministic CIImage proxy and always cropped to the input extent.
- `BeautyExampleRenderer` still imports only `BeautySDK`.
- No Phase 27 source changes add Demo UI behavior, public raw geometry APIs, generated PNG baselines, or broader geometry saved-output cases.

## Verification Reused

- Focused facade, renderer, missing-landmark, no-face/stale/reused, combined-strength, and face-shape conflict tests passed during Phase 27 closeout.
- Full `swift test --package-path BeautySDK` passed with 167 tests.
- Renderer build/run passed and produced 66 ignored PNG outputs.
- Redaction, public/SPI export, renderer scope, Demo import, overclaim, and ledger no-promotion scans passed.
