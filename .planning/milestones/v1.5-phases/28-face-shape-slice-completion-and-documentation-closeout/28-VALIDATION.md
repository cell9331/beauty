---
phase: 28
slug: face-shape-slice-completion-and-documentation-closeout
status: passed
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-07
verified: 2026-07-08
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
| 28-01-01 | 01 | 1 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06 | T-28-01 | Renderer cases use only existing public `BeautyParameters` fields and keep `下颌线` alias-backed by `jawSlim`. | XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`; renderer public-import and public-parameter scans | Renderer/test files updated; 6 tests passed and public-facade/import scans passed | passed |
| 28-01-02 | 01 | 1 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05 | T-28-02 | Helper proves same dimensions and top-region geometry-vs-`geometryBaseline_noop` deltas without committed PNG baselines. | helper/integration | renderer build/run plus `python3 .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py --input example-images/input --output example-images/out` | Helper exists and passed with 102/102 outputs and 30/30 top-region comparisons | passed |
| 28-02-01 | 02 | 1 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06 | T-28-02 | Provider tests prove per-parameter caps, signed `chinLength`, missing-contour degradation, and alias-shared `jawSlim` evidence. | XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests`; jawline/API-expansion scans | 8 tests passed; hidden surface scans passed | passed |
| 28-02-02 | 02 | 1 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06 | T-28-02 | Resolver/conflict tests prove no-face degradation, combined weakening, redacted metrics, caps, and no raw geometry leakage. | XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests`; `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests`; raw-leak scans | 5 combined-safety tests and 7 conflict-resolver tests passed; redaction scans passed | passed |
| 28-03-01 | 03 | 2 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-03 | T-28-03 | Evidence capture records renderer build/run, helper output, output counts, top-region comparisons, and ignored-output proof before documentation promotion. | renderer/helper/doc scan | renderer build/run, Phase 28 helper, representative `git check-ignore`, evidence raw-leak scan | `28-FACE-SHAPE-RENDERER-EVIDENCE.md` records renderer/helper evidence and scans | passed |
| 28-03-02 | 03 | 2 | FACE-01, FACE-02, FACE-03, FACE-04, FACE-05, FACE-06, DOC-03 | T-28-03 | Evidence capture records focused XCTest, static scans, redaction proof, alias sharing, and non-claims without changing ledgers. | XCTest/doc scan | focused renderer/provider/combined/conflict tests, public/SPI raw-geometry scans, hidden API expansion scan, no-overclaim scan | `28-FACE-SHAPE-RENDERER-EVIDENCE.md` records focused tests, scans, alias sharing, and non-claims | passed |
| 28-04-01 | 04 | 3 | DOC-01, DOC-02, DOC-03, FACE-06 | T-28-04 | Final promotion updates verification, validation, and blueprint docs only after evidence passes; six scoped rows become implemented and branch-level `脸型` stays partial. | doc/static scan/GSD coverage | full SDK suite, renderer build/run/helper, ledger guard, branch partial guard, raw-leak scans, no-overclaim scans, scoped `git diff --check` | `28-VERIFICATION.md` and blueprint docs updated from observed evidence; guards passed during closeout | passed |
| 28-04-02 | 04 | 3 | DOC-03 | T-28-04 | Final closeout synchronizes root docs and planning ledgers from observed evidence without UI/commercial/device parity, broad Meitu parity, or release-readiness claims. | doc/static scan/GSD coverage | requirements/roadmap/state/doc scans, `check.decision-coverage-plan`, post-planning gap analysis, scoped `git diff --check` | Root/planning ledgers synchronized from `28-VERIFICATION.md`; decision coverage passed | passed |

## Wave 0 Requirements

- [x] `BeautySDK/Sources/BeautyExampleRenderer/main.swift` contains one renderer case each for `faceSlim`, `faceSmall`, `faceVShape`, and `jawSlim`, plus positive and negative `chinLength`.
- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` expects every Phase 28 renderer case ID and preserves the public-facade import boundary.
- [x] `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py` verifies expected outputs, non-empty PNGs, same dimensions, and top-region per-tool deltas against `geometryBaseline_noop`.
- [x] Focused XCTest or scans cover caps, signed `chinLength`, missing contour/no-face degradation, combined weakening, redaction, and raw-geometry leak prevention.
- [x] Phase 28 evidence and verification Markdown files exist only after command-backed evidence exists.

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

**Approval:** Final validation strategy passed for Phase 28 closeout. Pending rows were replaced with observed test, renderer, helper, scan, and ledger evidence on 2026-07-08.
