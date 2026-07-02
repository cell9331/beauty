---
phase: 24
slug: renderer-output-regression-hardening
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-07-02
---

# Phase 24 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, SwiftPM executable build/run, Python or shell PNG invariant checks, static scans |
| **Config file** | `BeautySDK/Package.swift`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` after the focused test file exists |
| **Full suite command** | `swift test --package-path BeautySDK` plus `swift build --package-path BeautySDK --product BeautyExampleRenderer`, all-case renderer run, PNG invariant check, and scoped no-overclaim scans |
| **Estimated runtime** | 5 to 15 minutes for SwiftPM tests, renderer build/run, generated-output checks, and static scans |

## Sampling Rate

- **After every task commit:** Run the focused test or static scan for the touched behavior plus `git diff --check` over touched Phase 24 artifacts.
- **After every plan wave:** Run `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, and the scoped renderer/evidence scans introduced by that wave.
- **Before `$gsd-verify-work`:** Run full `swift test --package-path BeautySDK`, the all-case `BeautyExampleRenderer` command, generated PNG invariant checks, facade-only import scans, geometry status scans, forbidden-wording scans, and scoped `git diff --check`.
- **Max feedback latency:** 15 minutes for automated SDK, renderer, artifact, and static checks.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 24-01-01 | 01 | 1 | RENDER-01 | T-24-01-01 | Renderer matrix checks use relative repository files and public facade boundaries without committing generated images. | unit/static | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests/testRendererCaseInventoryMatchesCurrentPublicFacadeMatrix` | no, Wave 0 gap | pending |
| 24-01-02 | 01 | 1 | RENDER-02 | T-24-01-02 | No-op checks compare pre-watermark facade output and do not leak fixture bytes, absolute paths, or face geometry payloads. | unit/fixture | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests/testDefaultParametersPreserveCurrentFixturePixelsBeforeWatermark` | no, Wave 0 gap | pending |
| 24-02-01 | 02 | 1 | RENDER-03 | T-24-02-01 | Generated-output evidence records only relative paths, counts, dimensions, case IDs, command status, and factual notes. | CLI/artifact | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` plus generated PNG invariant check | no, Wave 0 gap | pending |
| 24-02-02 | 02 | 1 | RENDER-03, RENDER-04 | T-24-02-02 | Evidence and docs avoid quality, release-readiness, device-parity, Meitu-parity, and geometry-completion overclaims. | static/artifact scan | `rg -n "commercial quality|production naturalness|release readiness|all-device parity|Meitu parity|3D塑颜.*implemented|比例.*implemented|脸型.*implemented|眼睛.*implemented|嘴唇.*implemented|鼻子.*implemented|眉毛.*implemented" docs/meitu-function-blueprint .planning/phases/24-renderer-output-regression-hardening` | no, Wave 0 gap | pending |
| 24-03-01 | 03 | 2 | RENDER-01, RENDER-02, RENDER-03, RENDER-04 | T-24-03-01 | Closeout ledgers preserve factual evidence and route deferred geometry/output-baseline work without widening public API or product scope. | ledger scan | `rg -n "RENDER-01|RENDER-02|RENDER-03|RENDER-04|no-op|45|geometry|non-claim" .planning/REQUIREMENTS.md .planning/ROADMAP.md QUALITY_SCORE.md PLANS.md .planning/phases/24-renderer-output-regression-hardening` | no, Wave 0 gap | pending |

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - focused public-facade renderer case inventory and no-op fixture regression tests for RENDER-01 and RENDER-02.
- [ ] `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` - exact commands, output count, invariant results, representative watermark notes, non-claims, and rerun protocol for RENDER-03 and RENDER-04.
- [ ] Generated-output invariant command or helper - verifies 5 current fixtures times 9 current cases, non-empty PNGs, same input dimensions, and a visible-case change signal without committing PNGs.
- [ ] Static scans - verify public facade import boundary, renderer case inventory, geometry-case exclusion, branch-status honesty, and forbidden quality/parity wording.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Representative watermark readability | RENDER-03 | The phase explicitly rejects OCR and brittle pixel heuristics. | After the all-case renderer command passes, inspect representative generated PNGs from `example-images/out/` and record factual notes in `24-RENDERER-EVIDENCE.md`: watermark text is readable at the bottom and does not cover the face. Do not claim commercial quality, naturalness, release readiness, all-device parity, or Meitu parity. |
| Geometry saved-output completion | RENDER-04 | Phase 24 guards status only; public facade geometry rendering is out of scope. | Confirm `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, Phase 24 evidence, and touched ledgers keep geometry-heavy branches `partial`, `blocked-by-geometry-output`, or `future` unless a future phase produces public-facade same-dimension watermarked saved outputs. |

## Validation Sign-Off

- [x] All planned requirements have automated verify, artifact verify, static scan, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify or artifact/static scan criteria.
- [x] Wave 0 records all missing Phase 24 validation references.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 15 minutes for automated SDK, renderer, artifact, and static checks.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Pending Phase 24 execution.
