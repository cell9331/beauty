---
phase: 26
slug: geometry-facade-and-landmark-routing-foundation
status: final
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-06
completed: 2026-07-06
---

# Phase 26 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, focused active-source `rg` scans, and GSD traceability checks |
| **Config file** | `BeautySDK/Package.swift`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineTests` plus the focused detector/effects filter for the touched surface |
| **Full suite command** | `swift test --package-path BeautySDK` plus Phase 26 raw-leak and overclaim scans |
| **Estimated runtime** | 10 to 20 minutes for focused SDK tests, full SDK tests, source scans, and traceability checks |

## Sampling Rate

- **After every task commit:** Run the narrowest changed-area XCTest filter and `git diff --check` over touched Phase 26 artifacts and source files.
- **After every plan wave:** Run the facade geometry tests, detector/selection tests, effects resolver/degradation tests touched by the wave, and active-source redaction scans.
- **Before `$gsd-verify-work`:** Run full `swift test --package-path BeautySDK`, requirement/decision coverage checks, raw-leak scans, no-renderer-case/no-ledger-implemented scans, and root/planning ledger consistency checks.
- **Max feedback latency:** 20 minutes for automated SDK tests and scans; unavailable optional Demo checks must be recorded with exact blocker and rerun protocol.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 26-01-01 | 01 | 1 | GEO-02 | T-26-01-01 | Package-only selected-face observation routing activates internal resolver geometry planning without public raw geometry exports. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests`; public raw geometry export scan | `BeautyFaceGeometryAdapter.swift`, resolver tests | passed |
| 26-01-02 | 01 | 1 | GEO-02 | T-26-01-02 | Selected-face routing preserves missing eye/nose/mouth/lip, no-face, stale, reused, and redacted aggregate metadata behavior. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests`; active planning raw-leak scan | existing effects tests | passed |
| 26-02-01 | 02 | 2 | GEO-01, GEO-02 | T-26-02-01 | SPI-only facade detector fixtures simulate usable, no-face, low-confidence, missing-landmark, unavailable, and timeout states without public/SPI raw geometry exposure. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests`; `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests`; public/SPI export scan | `BeautyEngineGeometryFacadeTests.swift` | passed |
| 26-02-02 | 02 | 2 | GEO-01, GEO-02 | T-26-02-02 | `BeautyEngine.processResult(image:metadata:parameters:)` runs detection only for geometry-triggering still-image parameters, preserves `.notRun`/`.disabled` compatibility, and degrades with redacted summaries/warnings/metrics. | focused XCTest/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests`; `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineMetadataCompatibilityTests`; active-source raw-leak scan | facade helper and tests | passed |
| 26-03-01 | 03 | 3 | GEO-01, GEO-02 | T-26-03-01 | Verification and validation artifacts record actual command evidence, D-01 through D-16 traceability, and explicit non-claims for saved-output geometry, PNG evidence, Demo UI, public raw geometry API, and `SHAPE_FEATURE_LEDGER.md` implementation completion. | doc/traceability scan | `for d in D-01 D-02 D-03 D-04 D-05 D-06 D-07 D-08 D-09 D-10 D-11 D-12 D-13 D-14 D-15 D-16; do rg -n "$d" .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VALIDATION.md >/dev/null || exit 1; done` | evidence docs | passed |
| 26-04-01 | 04 | 4 | GEO-01, GEO-02 | T-26-04-01 | Root docs and planning ledgers record only facade routing evidence, preserve no-UI/local-first boundaries, and do not claim saved-output geometry or `SHAPE_FEATURE_LEDGER.md` implementation completion. | doc/traceability scan | `rg -n "GEO-01|GEO-02|26-VERIFICATION|BeautyEngineGeometryFacadeTests|geometry routing|redacted" .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md ARCHITECTURE.md DESIGN.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md` | existing docs | pending |

## Wave 0 Requirements

- [x] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` proves public-facade geometry activation and degradation through `BeautyEngine.processResult(...)`.
- [x] A narrow package/SPI-only detector seam exists for deterministic facade tests without adding public raw geometry, landmark, provider, or Vision types.
- [x] A minimal internal adapter path exists from the selected usable detection result to internal `FaceGeometry`, sufficient for existing geometry resolver/provider tests.
- [x] Scan commands classify active source separately from tests/docs when checking raw leak literals.

## Decision Coverage

D-01 through D-16 are covered by `26-VERIFICATION.md`, this final validation file, and the plan summaries:

- D-01, D-02, D-03, D-04, D-05, D-06, D-07, D-08, D-09 are covered by focused facade, detector, resolver, and degradation tests.
- D-10 and D-12 are covered by renderer-case exclusion and `SHAPE_FEATURE_LEDGER.md` implemented-status scans.
- D-11 is covered by public facade tests plus existing detector/effects tests.
- D-13, D-14, D-15, and D-16 are covered by redaction assertions, numeric aggregate metrics, active-source scans, and the decision to keep `beauty.effects.geometryPointCount` as aggregate non-coordinate evidence.

## Manual-Only Verifications

| Behavior | Requirement | Current Status | Why Manual | Test Instructions |
|----------|-------------|----------------|------------|-------------------|
| Optional Demo import/privacy check | GEO-02 | not required unless Demo files change | Phase 26 is SDK-core with no UI/Demo behavior change, but Demo surfaces are active-source leak boundaries if touched. | If Demo files change, run the focused Demo import/privacy xcodebuild command with an explicit available iOS simulator and record exact pass or blocker evidence. |
| Saved-output geometry visual evidence | GEO-01 | deferred | Phase 26 intentionally proves routing intent, not rendered geometry PNG output. | Do not run or claim Phase 27 renderer output evidence during Phase 26; preserve the renderer matrix until Phase 27 plans execute. |
| `SHAPE_FEATURE_LEDGER.md` implemented status | GEO-01, GEO-02 | deferred | Phase 26 does not complete second-level `脸型` implementation status. | Verify scans show Phase 26 does not mark `脸型` rows as `implemented`; leave implementation completion for Phase 28 saved-output evidence. |

## Validation Sign-Off

- [x] All planned Phase 26 requirements have automated verify, static scan, artifact verify, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify, artifact/static scan, or blocker-recording criteria.
- [x] Wave 0 records all missing Phase 26 validation references before execution.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 20 minutes for automated SDK tests and active-source scans.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Final. See `26-VERIFICATION.md` for exact command output and non-claim boundaries.
