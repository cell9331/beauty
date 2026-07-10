---
phase: 29-eye-renderer-output-evidence
status: passed
verified: 2026-07-10
requirements:
  - EYE-01
  - EYE-02
  - EYE-03
---

# Phase 29 Verification

## Verdict

Phase 29 passed automated verification for public-facade eye renderer output evidence.

The phase proves renderer evidence for existing public eye parameters only. `眼睛` rows and branch remain `partial` until Phase 30 records safety, degradation, redaction, and scoped status evidence.

## Requirement Coverage

| Requirement | Evidence | Status |
| --- | --- | --- |
| EYE-01 | `BeautyExampleRenderer` includes six public-facade eye cases, imports only `BeautySDK`, emits filename-only renderer output labels, and renderer regression tests passed with the 23-case matrix. | passed |
| EYE-02 | `check_eye_renderer_outputs.py` passed with 161/161 full-decode PNG outputs, 36/36 portrait eye-vs-`geometryBaseline_noop` top-region comparisons, and representative no-face output `no-face-gradient__eyeSize_0p35.png`. | passed |
| EYE-03 | Gallery generation wrote 161 ignored gallery PNGs, unsafe gallery-root deletion was rejected before deletion, representative output/gallery `git check-ignore` passed, and `git ls-files example-images/output example-images/gallery` returned `0`. | passed |

## Decision Traceability

| Decision | Verification result |
| --- | --- |
| D-01 | No eye combo case was added; the renderer has one case per scoped existing eye behavior. |
| D-02 | The six locked IDs are present: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`. |
| D-03 | Positive and negative `eyeDistance` and `eyeYPosition` cases are present. |
| D-04 | Only positive `eyeTailLift_0p25` renderer evidence is present. |
| D-05 | Representative no-face output `no-face-gradient__eyeSize_0p35.png` is present and checked. |
| D-06 | The helper validates the full 23-case by 7-fixture matrix. |
| D-07 | The helper decodes each generated PNG output and compares each Phase 29 eye case against `geometryBaseline_noop` above the watermark band. |
| D-08 | Required portrait evidence is 36/36 comparisons. |
| D-09 | Verification would fail below 36/36; observed result is 36/36. |
| D-10 | Active touched docs and commands use `example-images/output/`. |
| D-11 | `example-images/generate_gallery.py` includes an ignored `eyes/` gallery group. |
| D-12 | Phase 29 updated renderer evidence docs only and did not edit `SHAPE_FEATURE_LEDGER.md` or `FEATURE_MATRIX.md`. |
| D-13 | `29-EYE-RENDERER-EVIDENCE.md` records exact commands, counts, dimensions, helper result, ignore checks, and limitations. |
| D-14 | Evidence and docs state renderer evidence exists while `眼睛` status remains partial until Phase 30. |

## Automated Checks

| Gate | Command | Observed result |
| --- | --- | --- |
| Renderer regression tests | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Passed, 7 tests. |
| Eye provider tests | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` | Passed, 6 tests. |
| Full SDK suite | `swift test --package-path BeautySDK` | Passed, 173 tests. |
| Renderer build | `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Passed. |
| Renderer all-case run | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` | Passed, 161 generated PNG outputs. |
| Phase 29 helper | `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` | Passed, 161/161 outputs and 36/36 comparisons. |
| Gallery generation | `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` | Passed, wrote 161 gallery PNGs. |
| Unsafe gallery guard | `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/input` | Failed safely before deletion with the expected gallery-root guard. |
| Absolute-path renderer redaction | `swift run --package-path BeautySDK BeautyExampleRenderer --input <repo>/example-images/input --output <tmp>/phase29-renderer-redaction --case eyeSize_0p35` | Passed outside the managed sandbox and emitted filename-only output labels. |
| Ignored artifacts | `git check-ignore` representative output/gallery paths | Passed for eye output and gallery paths. |
| Generated artifact staging | `git ls-files example-images/output example-images/gallery` | Passed with zero tracked generated files. |
| Legacy output path guard | Slash-delimited legacy path scan over touched active docs | Passed with zero legacy generated-output path references. |
| Public raw geometry guard | `rg` public/SPI raw geometry scan over SDK source | Passed with zero matches. |
| Demo/renderer internal import guard | `rg` internal SDK import scan over Demo and renderer | Passed with zero matches. |
| Helper/evidence redaction | `rg` raw-payload scan over evidence and helper output | Passed with zero matches. |
| No-overclaim wording | `rg` quality/parity/readiness/eye-completion scan | Passed with zero matches. |
| Code review | `29-REVIEW.md` | Passed with `status: clean` after resolving gallery deletion, renderer path-label, and helper PNG-decode findings. |
| Decision coverage | `check.decision-coverage-plan` | Passed with 14/14 decisions covered. |

## Static Boundary Results

- `BeautyExampleRenderer` remains public-facade-only.
- `BeautyExampleRenderer` success output and renderer-local errors avoid absolute local path labels.
- `check_eye_renderer_outputs.py` decodes every generated output PNG and requires `IEND` plus exact decoded scanline length.
- `example-images/generate_gallery.py` refuses gallery paths outside `example-images/gallery/` and refuses input/output overlap before deleting any generated gallery directory.
- `BeautyDemo` was not changed by Phase 29.
- `SHAPE_FEATURE_LEDGER.md` and `FEATURE_MATRIX.md` were not changed in Plan 29-02 or Plan 29-03.
- No generated PNG output or gallery file is tracked by git.
- Evidence artifacts contain counts, dimensions, relative paths, case IDs, commands, and factual limitations only.

## Non-Claims

Phase 29 does not claim Demo UI completion, new public parameters, public raw geometry APIs, commercial review, device parity, reference-app parity, launch readiness, generated PNG baselines, or whole-branch eye completion.

## Human Verification

No manual-only verification is required for Phase 29. Human visual quality review, device parity, and commercial review remain outside this phase.

## Result

Phase 29 EYE-01, EYE-02, and EYE-03 are verified as passed.
