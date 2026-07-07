---
phase: 28
slug: face-shape-slice-completion-and-documentation-closeout
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-07-07
---

# Phase 28 - Validation Strategy

> Per-phase validation contract for face-shape saved-output evidence, focused SDK safety coverage, privacy scans, and documentation closeout.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, `BeautyExampleRenderer`, Python 3 standard-library PNG helper, focused `rg` scans, GSD coverage checks, and git ignored-output checks |
| **Config file** | `BeautySDK/Package.swift`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` plus the narrow touched `BeautyEffectsTests` filter |
| **Full suite command** | `swift test --package-path BeautySDK`; `swift build --package-path BeautySDK --product BeautyExampleRenderer`; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out`; `python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out` |
| **Estimated runtime** | Under 30 minutes for focused SDK tests, full SDK suite, renderer build/run, helper checks, static scans, and GSD coverage checks |

## Sampling Rate

- **After every task commit:** Run the narrowest changed-surface XCTest filter, relevant helper/static scan, and scoped `git diff --check`.
- **After every plan wave:** Run the renderer inventory test, relevant face-shape provider/resolver/degradation tests, helper checks if renderer outputs changed, raw-leak scans, no-overclaim scans, and ledger guards for touched artifacts.
- **Before `$gsd-verify-work`:** Run the full SDK suite, renderer build/run, Phase 28 helper, ignored-output checks, raw-leak scans, no-overclaim scans, ledger guard, requirements/decision coverage checks, and scoped `git diff --check`.
- **Max feedback latency:** 30 minutes for automated SDK tests, renderer execution, helpers, scans, and coverage checks.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 28-01-01 | 01 | 1 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06 | T-28-01 | Renderer cases use only existing public `BeautyParameters` fields and keep `下颌线` alias-backed by `jawSlim`. | XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`; renderer public-import and public-parameter scans | Partial: renderer/test files exist; Phase 28 case updates pending | pending |
| 28-01-02 | 01 | 1 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05 | T-28-02 | Helper proves same dimensions and top-region geometry-vs-`geometryBaseline_noop` deltas without committed PNG baselines. | helper/integration | renderer build/run plus `python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out` | Missing: Phase 28 helper pending | pending |
| 28-02-01 | 02 | 2 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05 | T-28-03 | Focused SDK tests prove caps, signed `chinLength`, missing contour/no-face degradation, combined weakening, and redacted summaries. | XCTest/static scan | changed `BeautyEffectsTests` and `BeautyCoreTests` filters selected by touched files | Partial: existing tests cover most behavior; Phase 28 evidence gaps pending | pending |
| 28-03-01 | 03 | 3 | DOC-01, DOC-02, FACE-06 | T-28-04 | Ledgers promote only six scoped rows and explicitly label `下颌线` as `jawSlim` alias-backed while keeping branch-level `脸型` partial. | doc/static scan | ledger guard plus targeted `rg` scans over `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, face-shape README, and `EXAMPLE_IMAGE_VALIDATION.md` | Docs exist; updates pending evidence | pending |
| 28-04-01 | 04 | 4 | DOC-03 | T-28-05 | Final verification records exact command evidence without raw geometry leakage, committed generated PNGs, UI/commercial/device parity, broad Meitu parity, or release-readiness claims. | doc/static scan/GSD coverage | full SDK suite, renderer build/run/helper, raw-leak scans, no-overclaim scans, `git check-ignore`, `check.decision-coverage-plan`, post-planning gap analysis, scoped `git diff --check` | Missing: `28-VERIFICATION.md` pending execution | pending |

## Wave 0 Requirements

- [ ] `BeautySDK/Sources/BeautyExampleRenderer/main.swift` contains one renderer case each for `faceSlim`, `faceSmall`, `faceVShape`, and `jawSlim`, plus positive and negative `chinLength`.
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` expects every Phase 28 renderer case ID and preserves the public-facade import boundary.
- [ ] `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py` verifies expected outputs, non-empty PNGs, same dimensions, and top-region per-tool deltas against `geometryBaseline_noop`.
- [ ] Focused XCTest or scans cover caps, signed `chinLength`, missing contour/no-face degradation, combined weakening, redaction, and raw-geometry leak prevention.
- [ ] Phase 28 evidence and verification Markdown files exist only after command-backed evidence exists.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Evidence wording review | DOC-03 | Human wording review is required to prevent overclaiming scoped evidence as Demo UI, commercial quality, device parity, broad Meitu parity, or release readiness. | Review touched docs and Phase 28 evidence after automated scans pass; record only factual case IDs, commands, counts, dimensions, helper results, and blockers. |
| Demo UI build/test | FACE-01 through DOC-03 | Phase 28 is SDK-only unless an executor unexpectedly changes Demo files. | If Demo files remain untouched, record no Demo build required and run Demo internal-import scan; if Demo files change, run the explicit simulator build from `AGENTS.md`. |

## Validation Sign-Off

- [x] All phase requirements have automated verify, helper/static scan, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks may proceed without automated verify, artifact/static scan, or blocker-recording criteria.
- [x] Wave 0 lists all missing Phase 28 validation references before execution.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 30 minutes.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Draft validation strategy ready for Phase 28 planning. Execution must replace pending rows with observed evidence before verification closeout.
