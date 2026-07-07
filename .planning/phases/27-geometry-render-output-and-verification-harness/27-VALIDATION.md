---
phase: 27
slug: geometry-render-output-and-verification-harness
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-07-07
---

# Phase 27 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, `BeautyExampleRenderer`, Python 3 standard-library PNG helper, focused `rg` scans, and GSD traceability checks |
| **Config file** | `BeautySDK/Package.swift`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` plus the narrow changed-surface filter |
| **Full suite command** | `swift test --package-path BeautySDK`; `swift build --package-path BeautySDK --product BeautyExampleRenderer`; `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out`; `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` |
| **Estimated runtime** | 15 to 30 minutes for focused SDK tests, full SDK tests, renderer execution, helper checks, static scans, and traceability checks |

## Sampling Rate

- **After every task commit:** Run the narrowest changed-area XCTest filter, the relevant helper/static scan, and `git diff --check` over touched Phase 27 artifacts and source files.
- **After every plan wave:** Run `BeautyEngineGeometryFacadeTests`, `BeautyRendererOutputRegressionTests`, `MissingLandmarkDegradationTests`, the new geometry renderer helper when available, and raw-leak/no-overclaim scans for touched evidence.
- **Before `$gsd-verify-work`:** Run full `swift test --package-path BeautySDK`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, the renderer command, the Phase 27 geometry helper, `git check-ignore` for generated geometry PNGs, raw-geometry leak scans, no-overclaim scans, ledger-status guard, requirement/decision coverage checks, and scoped `git diff --check`.
- **Max feedback latency:** 30 minutes for automated SDK tests, renderer execution, helpers, and scans; unavailable optional Demo checks must be recorded with exact blocker and rerun protocol.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 27-01-01 | 01 | 1 | GEO-03 | T-27-01-01 | `BeautyExampleRenderer` adds exactly one combined face-shape case through public `BeautySDK` only and preserves the ignored output directory contract. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`; renderer public-import scan; `git check-ignore example-images/out/<geometry-output>.png` | renderer test exists; geometry case update pending | pending |
| 27-01-02 | 01 | 1 | GEO-03 | T-27-01-02 | Still-image facade render consumes selected-face geometry internally and produces a same-dimension geometry output that differs from a no-geometry baseline without exposing raw geometry. | focused XCTest | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` plus any new geometry-output test filter | facade tests exist; output-delta assertion pending | pending |
| 27-01-03 | 01 | 1 | GEO-03 | T-27-01-03 | Geometry output helper verifies expected PNGs, non-empty files, input/output dimensions, geometry-vs-baseline non-identity, and relative-only evidence facts. | helper/integration | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out`; `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out` | helper missing; Wave 0 gap | pending |
| 27-02-01 | 02 | 2 | GEO-04 | T-27-02-01 | No-face saved-output evidence uses a dedicated no-face fixture or narrow fallback verifier and records only redacted warnings/metrics plus same-dimension output facts. | fixture/fallback helper and scan | renderer/fallback command selected by plan; Phase 27 helper; no-face evidence redaction scan | no dedicated helper yet; Wave 0 gap | pending |
| 27-02-02 | 02 | 2 | GEO-04 | T-27-02-02 | Missing-landmark degradation remains group-specific and redacted when selected-face routing is present. | focused XCTest | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testSelectedFaceRoutePreservesGroupSpecificDegradation` | existing test file | pending |
| 27-02-03 | 02 | 2 | GEO-04 | T-27-02-03 | Stale/reused-landmark degradation remains deterministic and redacted, with no coordinates, landmarks, bounding boxes, control points, local paths, raw JSON, or image bytes in public evidence. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded`; active-source and evidence raw-leak scans | existing test file | pending |
| 27-02-04 | 02 | 2 | GEO-04 | T-27-02-04 | Combined-strength face-shape geometry is capped/weakened and records aggregate redacted metrics only. | focused XCTest | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests/testCombinedHighStrengthAllDomainsCapAndWeakenGeometry`; `swift test --package-path BeautySDK --filter BeautyEffectsTests.GeometryConflictResolverTests/testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum` | existing test files | pending |
| 27-03-01 | 03 | 3 | GEO-03, GEO-04 | T-27-03-01 | Evidence documents record actual commands, output counts, dimensions, helper results, representative factual notes, and explicit non-claims without committing generated PNG baselines. | doc/traceability/static scan | `rg -n "GEO-03|GEO-04|D-01|D-02|D-03|D-04|D-05|D-06|D-07|D-08|D-09|D-10|D-11|D-12|D-13|D-14|D-15|D-16|D-17" .planning/phases/27-geometry-render-output-and-verification-harness`; no-overclaim and raw-leak scans | evidence docs pending | pending |
| 27-03-02 | 03 | 3 | GEO-03, GEO-04 | T-27-03-02 | Root docs and planning ledgers describe only Phase 27 foundation evidence, preserve no-UI/local-first/public-facade boundaries, and do not promote `SHAPE_FEATURE_LEDGER.md` implemented status. | doc/traceability/static scan | root/planning evidence scan; Demo internal-import scan if Demo files change; `SHAPE_FEATURE_LEDGER.md` implemented-status guard; scoped `git diff --check` | root docs exist; updates pending after evidence | pending |

## Wave 0 Requirements

- [ ] `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` verifies geometry output count, non-empty PNGs, input/output dimensions, and geometry-vs-baseline differences using Python 3 standard library only.
- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` includes the new combined face-shape renderer case in the expected public-facade case inventory.
- [ ] A focused facade/output-delta assertion proves selected-face geometry changes rendered image bytes before watermarking or records the exact blocker and fallback verifier scope.
- [ ] No-face saved-output evidence path is chosen and documented as either a dedicated no-face input fixture or a narrow fallback verifier using existing SPI testing support.

## Decision Coverage

Phase 27 plans must cover all trackable `27-CONTEXT.md` decisions:

- D-01 through D-04: renderer-first hybrid, existing executable matrix, real public-facade fixtures first, and narrow fallback only if required.
- D-05 through D-08: face-shape-first scope, one combined case using `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`, no eye/nose/mouth/lip saved-output expansion, and no Phase 28 ledger promotion.
- D-09 through D-12: same dimensions, geometry-vs-baseline non-identity, ignored PNG outputs plus Markdown evidence, and factual non-quality wording only.
- D-13 through D-17: no-face, missing-landmark, stale/reused, combined-strength degradation coverage; renderer PNG evidence for happy/no-face paths; focused tests/helper summaries for other degradation paths; and no raw geometry or overclaim leakage.

## Manual-Only Verifications

| Behavior | Requirement | Current Status | Why Manual | Test Instructions |
|----------|-------------|----------------|------------|-------------------|
| Representative visual notes | GEO-03 | allowed but not required | Human wording review may be needed to keep notes factual and non-qualitative. | Check evidence notes only mention dimensions, output existence, non-identity against baseline, and factual readability; reject naturalness, commercial quality, release readiness, device parity, or Meitu parity claims. |
| Demo UI build/test | GEO-03, GEO-04 | not required unless Demo files change | Phase 27 is SDK-only and explicitly excludes Demo UI behavior. | If Demo files change, run the focused Demo build/test command with an explicit available iOS simulator and record exact pass or blocker evidence. |
| Per-tool `脸型` ledger promotion | GEO-03, GEO-04 | deferred | Phase 28 owns per-tool saved-output completion and `SHAPE_FEATURE_LEDGER.md` implementation-status promotion. | Verify Phase 27 scans show no `SHAPE_FEATURE_LEDGER.md` `implemented` promotion for `脸型` rows. |

## Validation Sign-Off

- [x] All planned Phase 27 requirements have automated verify, static scan, artifact verify, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify, artifact/static scan, or blocker-recording criteria.
- [x] Wave 0 records all missing Phase 27 validation references before execution.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 30 minutes for automated SDK tests, renderer execution, helpers, and scans.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Draft validation strategy for planning. Final pass/fail evidence belongs in `27-VERIFICATION.md` after execution.
