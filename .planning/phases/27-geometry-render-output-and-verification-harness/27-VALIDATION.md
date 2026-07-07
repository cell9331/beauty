---
phase: 27
slug: geometry-render-output-and-verification-harness
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-07
verified: 2026-07-07
---

# Phase 27 - Validation Strategy

> Final validation contract and observed pass/fail evidence for Phase 27 execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, `BeautyExampleRenderer`, Python 3 standard-library PNG helper, focused `rg` scans, and GSD traceability checks |
| **Config file** | `BeautySDK/Package.swift`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` plus the narrow changed-surface filter |
| **Full suite command** | `swift test --package-path BeautySDK`; `swift build --package-path BeautySDK --product BeautyExampleRenderer`; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out`; `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` |
| **Observed runtime** | Focused SDK tests, full SDK tests, renderer execution, helper checks, static scans, and traceability checks completed within the planned 30-minute feedback target. |

## Sampling Rate

- **After every task commit:** Ran the narrowest changed-area XCTest filter, relevant helper/static scan, and `git diff --check` over touched Phase 27 artifacts and source files.
- **After every plan wave:** Ran the relevant facade, renderer, degradation, helper, raw-leak, no-overclaim, and scoped diff checks for touched artifacts.
- **Before closeout:** Ran full `swift test --package-path BeautySDK`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, the renderer command, the Phase 27 geometry helper, ignored-output checks, raw-leak scans, no-overclaim scans, ledger-status guard, requirement/decision coverage checks, and scoped `git diff --check`.
- **Max feedback latency:** Met for automated SDK tests, renderer execution, helpers, and scans.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 27-01-01 | 01 | 1 | GEO-03 | T-27-01-01 | Package-only still-image Vision input seam preserves public facade and redaction boundaries. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests`; public/SPI export scan | yes | passed |
| 27-01-02 | 01 | 1 | GEO-03 | T-27-01-02 | Public facade tries real fixtures and records only redacted detection summaries. | focused XCTest | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | yes | passed |
| 27-02-01 | 02 | 2 | GEO-03 | T-27-02-01 | Selected-face geometry stays internal while still-image output can change through the public facade. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests`; public/SPI export scan | yes | passed |
| 27-02-02 | 02 | 2 | GEO-03, GEO-04 | T-27-02-02 | Deterministic CIImage geometry proxy preserves extent and degrades when no face is available. | focused XCTest | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | yes | passed |
| 27-03-01 | 03 | 3 | GEO-03 | T-27-03-01 | Renderer adds only one combined face-shape case and one no-geometry baseline through public `BeautySDK`. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`; renderer public-import and scope scans | yes | passed |
| 27-03-02 | 03 | 3 | GEO-03, GEO-04 | T-27-03-02 | Helper verifies ignored generated outputs, same dimensions, geometry-vs-baseline differences, and no-face output presence without hashes. | helper/integration | renderer run; `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` | yes | passed |
| 27-04-01 | 04 | 4 | GEO-03, GEO-04 | T-27-04-01 | Final evidence records command-backed facts without raw geometry leakage or overclaim wording. | doc/static scan | final focused tests, full SDK suite, renderer build/run/helper, raw-leak and no-overclaim scans | yes | passed |
| 27-04-02 | 04 | 4 | GEO-03, GEO-04 | T-27-04-02 | Durable docs and ledgers describe Phase 27 foundation evidence without promoting face-shape per-tool status. | doc/static scan | root/planning evidence scan; Demo internal-import scan; shape-ledger guard; GSD decision coverage | yes | passed |

## Wave 0 Requirements

- [x] `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` verifies geometry output count, non-empty PNGs, input/output dimensions, and geometry-vs-baseline differences using Python 3 standard library only.
- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` includes the combined face-shape renderer case in the expected public-facade case inventory.
- [x] A focused facade/output-delta assertion proves selected-face geometry changes rendered image bytes before watermarking.
- [x] No-face saved-output evidence uses the dedicated `example-images/input/no-face-gradient.png` fixture.

## Decision Coverage

All trackable Phase 27 decisions are covered by plans and verification:

- D-01 through D-04: renderer-first hybrid, existing executable matrix, real public-facade fixtures first, and no fallback needed.
- D-05 through D-08: face-shape-first scope, one combined case, no eye/nose/mouth/lip saved-output expansion, and no Phase 28 ledger promotion.
- D-09 through D-12: same dimensions, geometry-vs-baseline non-identity, ignored PNG outputs plus Markdown evidence, and factual non-quality wording only.
- D-13 through D-17: no-face, missing-landmark, stale/reused, combined-strength degradation coverage, renderer PNG evidence for happy/no-face paths, focused tests/helper summaries for other degradation paths, and no raw geometry or overclaim leakage.

The GSD decision coverage query passed with `17/17` decisions covered.

## Manual-Only Verifications

| Behavior | Requirement | Current Status | Why Manual | Result |
|----------|-------------|----------------|------------|--------|
| Representative visual notes | GEO-03 | passed | Human wording review is needed to keep notes factual and non-qualitative. | `e1__faceShapeCombo_0p35.png` label is readable below the face area; no-face fixture evidence records existence and dimensions only. |
| Demo UI build/test | GEO-03, GEO-04 | not required | Phase 27 is SDK-only and no Demo files changed. | Demo internal-import scan passed; no Demo build was required. |
| Per-tool face-shape ledger promotion | GEO-03, GEO-04 | deferred | Phase 28 owns per-tool saved-output completion and ledger implementation-status promotion. | Implemented-status guard passed with zero matches. |

## Validation Sign-Off

- [x] All planned Phase 27 requirements have automated verify, static scan, artifact verify, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify, artifact/static scan, or blocker-recording criteria.
- [x] Wave 0 records all missing Phase 27 validation references before execution.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 30 minutes for automated SDK tests, renderer execution, helpers, and scans.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Phase 27 validation passed. Final command evidence is recorded in `27-VERIFICATION.md` and `27-GEOMETRY-RENDERER-EVIDENCE.md`.
