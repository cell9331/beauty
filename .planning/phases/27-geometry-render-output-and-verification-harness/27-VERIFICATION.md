---
phase: 27-geometry-render-output-and-verification-harness
status: passed
verified: 2026-07-07
requirements:
  - GEO-03
  - GEO-04
summaries:
  - 27-01-SUMMARY.md
  - 27-02-SUMMARY.md
  - 27-03-SUMMARY.md
---

# Phase 27 Verification - Geometry Render Output and Verification Harness

## Result

Phase 27 passes automated verification for the SDK-only geometry render output foundation.

What is proven:

- `GEO-03`: saved-output geometry evidence exists through `BeautyExampleRenderer`, the public `BeautySDK` still-image facade, a no-geometry baseline, one combined face-shape case, and helper-checked same-dimension generated outputs.
- `GEO-04`: no-face, missing-landmark, stale/reused, and combined-strength degradation paths are covered by a dedicated no-face renderer fixture plus focused redacted test evidence.
- The renderer executable remains public-facade-only.
- Generated PNGs remain ignored local artifacts.
- Evidence uses commands, counts, dimensions, helper summaries, warning names, and aggregate metrics only.

What is not claimed:

- No Demo UI work.
- No public raw geometry API.
- No committed generated PNG baselines or hashes.
- No broad geometry-domain saved-output matrix beyond the single Phase 27 face-shape combo.
- No commercial, parity, device, or launch claim.
- No face-shape ledger implemented-status promotion.

## Requirement Evidence

| Requirement | Evidence | Status |
| --- | --- | --- |
| GEO-03 | `BeautyExampleRenderer` builds and writes 66 generated outputs from 6 fixtures and 11 cases. The Phase 27 helper passes with 66/66 outputs, same dimensions, 5/5 portrait geometry-vs-baseline comparisons, and no-face output present. `BeautyRendererOutputRegressionTests` verifies the matrix and scope. | passed |
| GEO-04 | Dedicated no-face output exists; focused missing-landmark, no-face/stale/reused, combined-strength, and face-shape conflict-cap tests pass. Public evidence stays redacted and aggregate-only. | passed |

## Command Evidence

| Gate | Command | Result |
| --- | --- | --- |
| Facade geometry suite | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | Passed: 8 tests, 0 failures. |
| Renderer regression suite | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Passed: 4 tests, 0 failures. |
| Missing-landmark selected-face gate | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testSelectedFaceRoutePreservesGroupSpecificDegradation` | Passed: 1 test, 0 failures. |
| No-face/stale/reused gate | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded` | Passed: 1 test, 0 failures. |
| Combined-strength gate | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests/testCombinedHighStrengthAllDomainsCapAndWeakenGeometry` | Passed: 1 test, 0 failures. |
| Face-shape conflict gate | `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests/testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum` | Passed: 1 test, 0 failures. |
| Full SDK suite | `swift test --package-path BeautySDK` | Passed: 167 tests, 0 failures. |
| Renderer build | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product successfully. |
| Renderer run | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 66 PNG outputs. |
| Phase 27 helper | `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` | Passed: 66/66 outputs, 5/5 portrait geometry-vs-baseline comparisons, no-face output present. |
| Ignored output policy | `git check-ignore example-images/out/e1__faceShapeCombo_0p35.png example-images/out/e1__geometryBaseline_noop.png example-images/out/no-face-gradient__faceShapeCombo_0p35.png` | Passed: representative generated geometry outputs are ignored. |

## Static Scans

| Gate | Scope | Result |
| --- | --- | --- |
| Public/SPI raw geometry export scan | `BeautySDK/Sources/BeautySDK`, `BeautySDK/Sources/BeautyDetection`, `BeautySDK/Sources/BeautyEffects` | Passed with zero matches for public or SPI exports of internal face observations, internal geometry types, raw landmarks, bounds, or point payloads. |
| Active-source redaction scan | Public/Core SDK and active Demo surfaces, plus internal Detection/Effects redaction tokens | Passed with zero matches for forbidden public raw geometry, local path, raw framework diagnostic, raw preset, or image payload leakage. |
| Renderer public-import scan | `BeautyRendererOutputRegressionTests.swift` and `BeautyExampleRenderer/main.swift` | Passed with zero internal SDK target imports. |
| Renderer scope scan | `BeautyExampleRenderer/main.swift` | Passed with zero eye, nose, mouth, lip, proportion, 3D, or brow renderer cases. |
| Shape ledger promotion guard | `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` and beauty-shaping README | Passed with zero implemented-status promotion for face-shape rows. |
| Demo internal-import scan | Active Demo source and tests | Passed with zero internal SDK target imports. |
| GSD decision coverage | `27-CONTEXT.md` against Phase 27 plans | Passed: 17/17 decisions covered. |

## Decision Traceability

| Decision | Verification |
| --- | --- |
| D-01 | Used `BeautyExampleRenderer` as the primary proof path; no fallback verifier was needed. |
| D-02 | Appended geometry cases to the existing renderer matrix and kept one ignored output directory. |
| D-03 | Public facade tests and renderer runs use existing portrait fixtures before helper checks. |
| D-04 | Real fixture detection was reliable enough for the renderer proof; fallback path stayed unused. |
| D-05 | Saved-output scope stays face-shape first. |
| D-06 | Added one combined face-shape renderer case with `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`. |
| D-07 | Scope scan proves no eye, nose, mouth, lip, proportion, 3D, or brow saved-output cases were added. |
| D-08 | Shape ledger promotion guard passes; per-tool face-shape status remains future work. |
| D-09 | Helper verifies same dimensions and geometry output non-identity against baseline without hashes. |
| D-10 | Helper compares `faceShapeCombo_0p35` against `geometryBaseline_noop` for portrait fixtures. |
| D-11 | `git check-ignore` verifies generated PNGs stay ignored; Markdown evidence records counts and dimensions. |
| D-12 | Evidence wording is limited to factual notes and scan-guarded non-claims. |
| D-13 | No-face, missing-landmark, stale/reused, and combined-strength degradation gates pass. |
| D-14 | Renderer PNG evidence covers happy and no-face paths; focused tests cover the other degradation paths. |
| D-15 | Dedicated committed `no-face-gradient.png` fixture covers the no-face saved-output path. |
| D-16 | Missing-landmark, stale/reused, and combined-strength evidence uses focused XCTest plus redacted summaries. |
| D-17 | Redaction scans and evidence-doc guards pass; docs avoid raw geometry payloads and overclaim wording. |

## Changed Files Covered

- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`
- `example-images/input/no-face-gradient.png`
- `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py`
- `.planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md`

## Release Boundary

Phase 27 is complete for saved-output geometry foundation evidence. Phase 28 remains the owner for per-tool face-shape saved-output completion, ledger promotion, and any broader visual review.
