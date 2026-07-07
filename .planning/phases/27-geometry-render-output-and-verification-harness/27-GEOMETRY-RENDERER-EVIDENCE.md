---
phase: 27-geometry-render-output-and-verification-harness
status: passed
verified: 2026-07-07
requirements:
  - GEO-03
  - GEO-04
---

# Phase 27 Geometry Renderer Evidence

## Scope

This artifact records SDK-only saved-output evidence for the Phase 27 geometry render foundation.

What is proven:

- `BeautyExampleRenderer` now runs the existing public still-image facade for 6 input fixtures and 11 renderer cases.
- The renderer matrix includes `geometryBaseline_noop` and one combined face-shape case, `faceShapeCombo_0p35`.
- Generated outputs remain local ignored PNGs under `example-images/out/`.
- The helper verifies output existence, non-empty PNG files, same input/output dimensions, and portrait geometry output differences against the no-geometry baseline.
- No-face saved-output evidence uses a committed no-face fixture and remains redacted.

What is not claimed:

- No Demo UI behavior changed.
- No public raw geometry API was added.
- No generated PNG baselines or hashes are committed.
- No eye, nose, mouth, lip, proportion, 3D, or brow saved-output cases are claimed.
- No commercial, parity, device, or launch claim is made.
- Per-tool face-shape ledger promotion remains future work.

## Command Evidence

| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Facade geometry tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | Executed 8 tests, 0 failures. Covered real fixture detection, redacted metadata, selected-face output delta, no-face degradation, disabled tracking, and no-geometry compatibility. | GEO-03, GEO-04 |
| Renderer regression tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Executed 4 tests, 0 failures. Covered the 11-case matrix, 6-fixture inventory, Phase 27 face-shape-only case scope, and no-face summary redaction. | GEO-03, GEO-04 |
| Missing-landmark selected-face degradation | passed | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testSelectedFaceRoutePreservesGroupSpecificDegradation` | Executed 1 test, 0 failures. | GEO-04 |
| No-face, stale, and reused degradation | passed | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded` | Executed 1 test, 0 failures. | GEO-04 |
| Combined-strength safety | passed | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests/testCombinedHighStrengthAllDomainsCapAndWeakenGeometry` | Executed 1 test, 0 failures. | GEO-04 |
| Face-shape conflict cap | passed | `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests/testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum` | Executed 1 test, 0 failures. | GEO-04 |
| Full SDK suite | passed | `swift test --package-path BeautySDK` | Executed 167 tests, 0 failures. | GEO-03, GEO-04 |
| Renderer build | passed | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product `BeautyExampleRenderer` successfully. | GEO-03 |
| Renderer all-case run | passed | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 66 PNG outputs. | GEO-03, GEO-04 |
| Generated-output helper | passed | `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` | Passed with 66/66 outputs, 5/5 portrait geometry-vs-baseline comparisons, and no-face geometry output present. | GEO-03, GEO-04 |
| Ignored-output policy | passed | `git check-ignore example-images/out/e1__faceShapeCombo_0p35.png example-images/out/e1__geometryBaseline_noop.png example-images/out/no-face-gradient__faceShapeCombo_0p35.png` | Representative generated geometry outputs are ignored by git. | GEO-03 |

## Renderer Matrix

The Phase 27 renderer matrix is owned by `BeautySDK/Sources/BeautyExampleRenderer/main.swift`.

| Case ID | Output files | Parameter coverage |
| --- | ---: | --- |
| `skinSmoothing_0p50` | 6 | Existing skin smoothing proxy |
| `skinWhitening_0p50` | 6 | Existing skin whitening |
| `skinRosy_0p40` | 6 | Existing rosy skin |
| `skinSharpen_0p40` | 6 | Existing sharpen/contrast proxy |
| `brightness_plus0p25` | 6 | Existing color brightness |
| `contrast_plus0p25` | 6 | Existing color contrast |
| `filter_softClean_0p50` | 6 | Existing built-in filter |
| `filter_warmLight_0p50` | 6 | Existing built-in filter |
| `skinCombo_0p50` | 6 | Existing combined basic skin parameters |
| `geometryBaseline_noop` | 6 | No-geometry baseline using default parameters |
| `faceShapeCombo_0p35` | 6 | `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength` only |

## Generated-Output Helper Result

The helper output was:

```text
phase 27 geometry renderer output check passed: 66/66 outputs
dimensions 96x96: 11 outputs
dimensions 576x1024: 11 outputs
dimensions 1440x2560: 22 outputs
dimensions 1728x2304: 11 outputs
dimensions 2160x3840: 11 outputs
portrait geometry-vs-baseline comparisons: 5/5
no-face geometry output present: no-face-gradient.png -> no-face-gradient__faceShapeCombo_0p35.png
fixtures: e1.png, e2.png, e3.png, e4.png, e5.png, no-face-gradient.png
cases: skinSmoothing_0p50, skinWhitening_0p50, skinRosy_0p40, skinSharpen_0p40, brightness_plus0p25, contrast_plus0p25, filter_softClean_0p50, filter_warmLight_0p50, skinCombo_0p50, geometryBaseline_noop, faceShapeCombo_0p35
```

## Representative Notes

These notes are factual observations, not quality scores.

| Output | Status | Observation |
| --- | --- | --- |
| `example-images/out/e1__faceShapeCombo_0p35.png` | passed | Output exists, keeps `1728x2304`, and the bottom label `face shape combo 0.35` is readable below the face area. |
| `example-images/out/e1__geometryBaseline_noop.png` | passed | Output exists, keeps `1728x2304`, and is the helper baseline for the `e1.png` geometry comparison. |
| `example-images/out/no-face-gradient__faceShapeCombo_0p35.png` | passed | Output exists, keeps `96x96`, and provides the dedicated no-face saved-output evidence path. |

## Degradation Evidence

| Degradation path | Evidence | Result |
| --- | --- | --- |
| No face | Dedicated `no-face-gradient.png` renderer fixture plus facade no-face test. | Same-dimension generated output exists; summary and warnings remain redacted. |
| Missing landmark groups | `MissingLandmarkDegradationTests/testSelectedFaceRoutePreservesGroupSpecificDegradation`. | Group-specific degradation remains active and redacted. |
| Stale or reused geometry | `MissingLandmarkDegradationTests/testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded`. | Stale and reused cases remain degraded and redacted. |
| Combined strengths | `CombinedEffectSafetyTests/testCombinedHighStrengthAllDomainsCapAndWeakenGeometry` and `GeometryConflictResolverTests/testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum`. | Face-shape strengths are capped or weakened with aggregate evidence only. |

## Evidence Field Allowlist

This artifact is limited to relative paths, fixture names, case IDs, counts, dimensions, command status, warning or metric names, representative factual notes, and rerun commands.

It does not include raw facial measurements, local absolute paths, raw framework diagnostics, raw JSON payloads, image-byte payloads, hashes, or committed PNG baselines.

## Rerun Protocol

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testSelectedFaceRoutePreservesGroupSpecificDegradation
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests/testCombinedHighStrengthAllDomainsCapAndWeakenGeometry
swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests/testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out
python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out
git check-ignore example-images/out/e1__faceShapeCombo_0p35.png example-images/out/e1__geometryBaseline_noop.png example-images/out/no-face-gradient__faceShapeCombo_0p35.png
```

Generated PNGs should remain local ignored artifacts. Markdown evidence and helper commands are the repository evidence.
