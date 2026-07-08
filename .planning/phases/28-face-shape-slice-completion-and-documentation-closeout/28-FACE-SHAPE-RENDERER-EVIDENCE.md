---
phase: 28-face-shape-slice-completion-and-documentation-closeout
status: passed
verified: 2026-07-08
requirements:
  - FACE-01
  - FACE-02
  - FACE-03
  - FACE-04
  - FACE-05
  - FACE-06
  - DOC-03
---

# Phase 28 Face-Shape Renderer Evidence

## Scope

This artifact records SDK-only evidence for the v1.5 scoped `脸型` slice after Phase 26 activated still-image geometry through the public facade and Phase 27 proved the shared saved-output geometry foundation.

What is proven:

- `BeautyExampleRenderer` runs the public `BeautySDK` still-image facade for 6 input fixtures and 17 renderer cases.
- Six Phase 28 renderer cases exist for scoped face-shape evidence: `faceSlim_0p35`, `faceSmall_0p35`, `chinLength_plus0p30`, `chinLength_minus0p30`, `faceVShape_0p35`, and `jawSlim_0p35`.
- The Phase 28 helper verifies output existence, non-empty PNG files, same input/output dimensions, and 30/30 portrait top-region differences against `geometryBaseline_noop` above the watermark band.
- `下颌线` is alias-backed by `jawSlim` and shares `下颌角` renderer, provider, safety, and degradation evidence.

What is not claimed:

- No Demo UI behavior changed.
- No new public `BeautyParameters` field was added.
- No distinct `下颌线` renderer case, parameter, or algorithm was added.
- No public raw geometry API was added.
- No generated PNG baselines, hashes, or generated outputs are committed.
- No commercial quality, device parity, broad Meitu parity, new geometry group, release-readiness, or whole-branch `脸型` completion claim is made.

## Requirement Mapping

| Requirement | Tool row | Evidence case or test | Status |
| --- | --- | --- | --- |
| FACE-01 | `脸宽` | `faceSlim_0p35` plus provider/resolver cap and degradation tests | passed |
| FACE-02 | `小脸` | `faceSmall_0p35` plus provider/resolver cap and degradation tests | passed |
| FACE-03 | `下巴长短` | `chinLength_plus0p30`, `chinLength_minus0p30`, and signed `chinLength` provider/resolver tests | passed |
| FACE-04 | `V脸` | `faceVShape_0p35` plus provider/resolver cap and degradation tests | passed |
| FACE-05 | `下颌角` | `jawSlim_0p35` plus `jawSlim` provider/resolver tests | passed |
| FACE-06 | `下颌线` | Alias-backed by `jawSlim_0p35`; shares `jawSlim` evidence with `下颌角` | passed |
| DOC-03 | Evidence and non-claims | This file records command-backed evidence and conservative non-claims before ledger promotion | passed |

## Command Evidence

| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Renderer build | passed | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Built product `BeautyExampleRenderer` successfully. | FACE-01 through FACE-06 |
| Renderer all-case run | passed | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` | Wrote 102 PNG outputs, confirmed by `rg -c '^wrote ' /tmp/phase28-renderer-run.out`. | FACE-01 through FACE-06 |
| Phase 28 helper | passed | `python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out` | Passed with 102/102 outputs and 30/30 portrait face-shape-vs-baseline top-region comparisons. | FACE-01 through FACE-06 |
| Ignored-output policy | passed | `git check-ignore example-images/out/e1__faceSlim_0p35.png example-images/out/e1__chinLength_minus0p30.png example-images/out/e1__jawSlim_0p35.png example-images/out/no-face-gradient__jawSlim_0p35.png` | Representative generated Phase 28 outputs are ignored by git. | DOC-03 |
| Renderer regression tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Executed 6 tests, 0 failures. Covered 17-case inventory, public-facade import boundary, scoped Phase 28 case parameters, and `jawSlim_0p35` alias sharing. | FACE-01 through FACE-06 |
| Provider tests | passed | `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | Executed 8 tests, 0 failures. Covered per-parameter caps, missing contour, signed `chinLength`, and `jawSlim` alias evidence. | FACE-01 through FACE-06 |
| Combined safety tests | passed | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests` | Executed 5 tests, 0 failures. Covered all scoped face-shape parameters in no-face and combined weakening evidence. | FACE-01 through FACE-06 |
| Conflict resolver tests | passed | `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests` | Executed 7 tests, 0 failures. Covered combined weakening, signed `chinLength`, redacted metrics, and scoped face-shape cap evidence. | FACE-01 through FACE-06 |
| Public/SPI raw geometry export scan | passed | `rg` scan over `BeautySDK/Sources/BeautySDK`, `BeautySDK/Sources/BeautyDetection`, and `BeautySDK/Sources/BeautyEffects` | Zero matches for public or SPI exports of internal face geometry or observation payloads. | DOC-03 |
| Hidden public-surface expansion scan | passed | `rg` scan over renderer, public SDK source, and tests | Zero matches for separate jawline renderer/API tokens, entitlement/payment/network/cloud behavior, or localized alias renderer case wording. | FACE-06, DOC-03 |
| Helper-output raw-leak scan | passed | `rg` scan over `/tmp/phase28-face-shape-helper.out` | Zero matches for forbidden local-path, raw diagnostic, raw geometry, or payload tokens. | DOC-03 |
## Renderer Matrix

The Phase 28 renderer matrix is owned by `BeautySDK/Sources/BeautyExampleRenderer/main.swift`.

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
| `faceShapeCombo_0p35` | 6 | Existing combined face-shape foundation case |
| `faceSlim_0p35` | 6 | `faceSlim: 0.35` |
| `faceSmall_0p35` | 6 | `faceSmall: 0.35` |
| `chinLength_plus0p30` | 6 | `chinLength: 0.30` |
| `chinLength_minus0p30` | 6 | `chinLength: -0.30` |
| `faceVShape_0p35` | 6 | `faceVShape: 0.35` |
| `jawSlim_0p35` | 6 | `jawSlim: 0.35`; shared by `下颌角` and alias-backed `下颌线` |

## Generated-Output Helper Result

The helper output was:

```text
phase 28 face shape renderer output check passed: 102/102 outputs
dimensions 96x96: 17 outputs
dimensions 576x1024: 17 outputs
dimensions 1440x2560: 34 outputs
dimensions 1728x2304: 17 outputs
dimensions 2160x3840: 17 outputs
portrait face-shape-vs-baseline top-region comparisons: 30/30
no-face face-shape output present: no-face-gradient.png -> no-face-gradient__jawSlim_0p35.png
fixtures: e1.png, e2.png, e3.png, e4.png, e5.png, no-face-gradient.png
cases: skinSmoothing_0p50, skinWhitening_0p50, skinRosy_0p40, skinSharpen_0p40, brightness_plus0p25, contrast_plus0p25, filter_softClean_0p50, filter_warmLight_0p50, skinCombo_0p50, geometryBaseline_noop, faceShapeCombo_0p35, faceSlim_0p35, faceSmall_0p35, chinLength_plus0p30, chinLength_minus0p30, faceVShape_0p35, jawSlim_0p35
phase 28 cases: faceSlim_0p35, faceSmall_0p35, chinLength_plus0p30, chinLength_minus0p30, faceVShape_0p35, jawSlim_0p35
```

## Focused Safety Evidence

| Evidence path | Command | Result |
| --- | --- | --- |
| Provider caps and contour degradation | `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests` | Passed with 8 tests. Covers `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, signed `chinLength`, caps, deterministic output, and `missing_face_contour`. |
| No-face degradation and combined weakening | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests` | Passed with 5 tests. Covers no-face skip behavior, safe color/filter continuation, capped counts, weakened counts, geometry strength scale, and redacted warning/metric metadata. |
| Conflict resolution and signed chin | `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests` | Passed with 7 tests. Covers high face-shape strengths, positive and negative `chinLength`, cap metrics, and `combined_geometry_weakened`. |

## Static Scan Evidence

| Gate | Scope | Result |
| --- | --- | --- |
| Public raw geometry export guard | `BeautySDK/Sources/BeautySDK`, `BeautySDK/Sources/BeautyDetection`, `BeautySDK/Sources/BeautyEffects` | Passed with zero matches. |
| Renderer public import guard | `BeautyExampleRenderer/main.swift` and `BeautyRendererOutputRegressionTests.swift` | Passed with zero internal SDK target imports. |
| Hidden jawline/API behavior guard | Renderer, public SDK source, and tests | Passed with zero separate jawline renderer/API tokens, entitlement/payment/network/cloud tokens, or localized alias renderer case wording. |
| Generated-output policy | Representative `git check-ignore` command | Passed; generated outputs remain local ignored artifacts. |
| Helper output redaction | `/tmp/phase28-face-shape-helper.out` | Passed with zero forbidden raw payload tokens. |

## Evidence Field Allowlist

This artifact is limited to relative paths, fixture names, case IDs, counts, dimensions, command status, warning or metric names, requirement IDs, and factual evidence notes.

It does not include raw facial measurements, local absolute paths, raw framework diagnostics, raw preset payloads, image payload dumps, hashes, or committed PNG baselines.

## Rerun Protocol

```bash
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out
python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests
git check-ignore example-images/out/e1__faceSlim_0p35.png example-images/out/e1__chinLength_minus0p30.png example-images/out/e1__jawSlim_0p35.png example-images/out/no-face-gradient__jawSlim_0p35.png
```

Generated PNGs should remain local ignored artifacts. Markdown evidence, XCTest results, helper output, and scan results are the repository evidence.
