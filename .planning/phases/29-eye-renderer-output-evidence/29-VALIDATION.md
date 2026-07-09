---
phase: 29
slug: eye-renderer-output-evidence
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-09
updated: 2026-07-09
---

# Phase 29 - Validation Results

> Final validation record for public-facade eye renderer output evidence, helper checks, generated gallery routing, and scoped documentation.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, `BeautyExampleRenderer`, Python 3 standard-library PNG helper, focused `rg` scans, GSD coverage checks, and git ignored-output checks |
| **Config file** | `BeautySDK/Package.swift`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`; `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` |
| **Full suite command** | `swift test --package-path BeautySDK`; `swift build --package-path BeautySDK --product BeautyExampleRenderer`; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output`; `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` |
| **Estimated runtime** | Under 30 minutes for focused SDK tests, full SDK suite, renderer build/run, helper checks, static scans, gallery generation, and GSD coverage checks |

## Sampling Rate

- **After every task commit:** Run the narrowest changed-surface XCTest filter, relevant helper/static scan, and scoped `git diff --check`.
- **After every plan wave:** Run renderer inventory tests, eye provider tests, renderer build/run if output logic changed, Phase 29 helper if output or helper logic changed, representative `git check-ignore`, and no-overclaim scans for touched docs.
- **Before `$gsd-verify-work`:** Run the full SDK suite, renderer build/run, Phase 29 helper, generated gallery command, representative output/gallery ignore checks, generated-PNG staging scan, stale generated-output path scan over touched active docs, no-overclaim scan, requirements/decision coverage checks, and scoped `git diff --check`.
- **Max feedback latency:** 30 minutes for automated SDK tests, renderer execution, helpers, scans, and coverage checks.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 29-01-01 | 01 | 1 | EYE-01 | T-29-01 | Renderer cases use only existing public `BeautyParameters` eye fields and keep `BeautyExampleRenderer` public-facade-only. | XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`; renderer import and public-parameter scans | Passed with 7 renderer regression tests and zero internal import/scope scan hits. | passed |
| 29-01-02 | 01 | 1 | EYE-02 | T-29-02 | Helper proves expected outputs exist, are non-empty, preserve fixture dimensions, and differ from `geometryBaseline_noop` above the watermark band. | helper/integration | renderer build/run plus `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` | Passed with 161/161 outputs, 36/36 comparisons, and representative no-face output presence. | passed |
| 29-02-01 | 02 | 2 | EYE-03 | T-29-03 | Generated output and gallery artifacts remain ignored and no generated PNG baseline is committed. | git/static scan | `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery`; representative `git check-ignore` for output and gallery PNGs; generated-PNG staging scan | Passed with 161 generated gallery PNGs, representative ignored gallery paths, and zero tracked generated files. | passed |
| 29-02-02 | 02 | 2 | EYE-01, EYE-02, EYE-03 | T-29-04 | Evidence records only command-backed counts, dimensions, comparison totals, representative no-face output presence, ignore checks, and factual limitations. | doc/static scan/GSD coverage | renderer/helper commands, focused tests, no-overclaim scans, raw-geometry leak scans, `check.decision-coverage-plan`, post-planning gap analysis, scoped `git diff --check` | Passed with final evidence, verification, no-overclaim, redaction, and 14/14 decision coverage. | passed |

## Wave 0 Requirements

- [x] `BeautySDK/Sources/BeautyExampleRenderer/main.swift` contains exactly the six Phase 29 eye renderer case IDs: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` expects the 23-case renderer matrix and preserves the public-facade import boundary.
- [x] `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` verifies 161 full-matrix outputs, 36/36 portrait eye-vs-`geometryBaseline_noop` top-region comparisons, and representative `no-face-gradient__eyeSize_0p35.png` presence.
- [x] `example-images/generate_gallery.py` routes the six Phase 29 case IDs into an ignored generated `eyes/` gallery group.
- [x] `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md` exists only after command-backed renderer/helper/gallery/ignore evidence exists.

## Final Command Results

| Command | Result |
| --- | --- |
| `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | Passed, 7 tests. |
| `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` | Passed, 6 tests. |
| `swift test --package-path BeautySDK` | Passed, 173 tests. |
| `swift build --package-path BeautySDK --product BeautyExampleRenderer` | Passed. |
| `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` | Passed, 161 generated PNG outputs. |
| `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output` | Passed, 161/161 outputs and 36/36 comparisons. |
| `python3 example-images/generate_gallery.py --input example-images/input --output example-images/output --gallery example-images/gallery` | Passed, wrote 161 gallery PNGs. |
| Representative `git check-ignore` checks | Passed for generated eye output and gallery paths. |
| Generated artifact staging scan | Passed with zero tracked generated output or gallery files. |
| Raw-leak, public-boundary, internal-import, no-overclaim, and legacy output-path scans | Passed. |
| GSD decision coverage | Passed with 14/14 decisions covered. |

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Evidence wording review | EYE-01, EYE-02, EYE-03 | Human wording review is required to prevent overclaiming renderer evidence as Demo UI, commercial quality, device parity, broad eye parity, row promotion, or release readiness. | Review touched docs and Phase 29 evidence after automated scans pass; record only factual case IDs, commands, counts, dimensions, helper results, ignored-output proof, and limitations. |
| Demo UI build/test | EYE-01, EYE-02, EYE-03 | Phase 29 is SDK renderer/helper evidence only unless an executor unexpectedly changes Demo files. | If Demo files remain untouched, record no Demo build required and run Demo internal-import scan; if Demo files change, run the explicit simulator build from `AGENTS.md`. |

## Validation Sign-Off

- [x] All phase requirements have automated verify, helper/static scan, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks may proceed without automated verify, artifact/static scan, or blocker-recording criteria.
- [x] Wave 0 lists all missing Phase 29 validation references before execution.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 30 minutes.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Phase 29 validation passed with observed test, renderer, helper, gallery, scan, and decision-coverage evidence. The phase records renderer evidence only; `眼睛` status remains partial until Phase 30 closeout.
