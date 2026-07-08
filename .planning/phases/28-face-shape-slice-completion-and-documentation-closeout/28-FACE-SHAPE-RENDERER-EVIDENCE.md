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

## Evidence Field Allowlist

This artifact is limited to relative paths, fixture names, case IDs, counts, dimensions, command status, warning or metric names, requirement IDs, and factual evidence notes.

It does not include raw facial measurements, local absolute paths, raw framework diagnostics, raw preset payloads, image payload dumps, hashes, or committed PNG baselines.

## Rerun Protocol

```bash
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out
python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out
git check-ignore example-images/out/e1__faceSlim_0p35.png example-images/out/e1__chinLength_minus0p30.png example-images/out/e1__jawSlim_0p35.png example-images/out/no-face-gradient__jawSlim_0p35.png
```

Generated PNGs should remain local ignored artifacts. Markdown evidence, XCTest results, helper output, and scan results are the repository evidence.
