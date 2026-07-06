---
phase: 26
slug: geometry-facade-and-landmark-routing-foundation
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-07-06
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
| 26-01-01 | 01 | 1 | GEO-01, GEO-02 | T-26-01-01 | Public facade tests can inject deterministic usable-face, no-face, low-confidence, missing-landmark, and detector-failure states without exposing raw geometry types publicly. | focused XCTest | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` | Wave 0 | pending |
| 26-01-02 | 01 | 1 | GEO-01 | T-26-01-02 | `BeautyEngine.processResult(...)` runs detection only for geometry-triggering parameters and preserves `.notRun` or `.disabled` for no-op/color/filter/basic-skin paths. | focused XCTest | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` plus `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineMetadataCompatibilityTests` | Wave 0/existing | pending |
| 26-02-01 | 02 | 1 | GEO-01, GEO-02 | T-26-02-01 | One selected usable face routes into internal `FaceGeometry` and activates existing resolver geometry intent while missing groups degrade only their own domains. | focused XCTest | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` plus `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` | existing | pending |
| 26-02-02 | 02 | 1 | GEO-02 | T-26-02-02 | Public result evidence stays limited to `BeautyDetectionSummary`, warnings, and aggregate numeric metrics; no coordinates, bounds, landmarks, control points, paths, raw framework errors, image bytes, or raw JSON leak. | focused XCTest/static scan | `sh -c 'rg -n -e VNFaceObservation -e boundingBox -e controlPoint -e /private/var -e NSError -e AVError -e rawPresetJson -e "raw JSON" -e "image bytes" -e landmarks= -e landmarkCoordinates -e rawLandmark BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo; public_status=$?; rg -n -e /private/var -e NSError -e AVError -e rawPresetJson -e "raw JSON" -e "image bytes" BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects; internal_status=$?; if [ "$public_status" -eq 1 ]; then if [ "$internal_status" -eq 1 ]; then exit 0; fi; fi; exit 1'` | existing active-source scan surface | pending |
| 26-03-01 | 03 | 2 | GEO-01, GEO-02 | T-26-03-01 | Root docs and planning ledgers record only facade routing evidence, preserve no-UI/local-first boundaries, and do not claim saved-output geometry or `SHAPE_FEATURE_LEDGER.md` implementation completion. | doc/traceability scan | `rg -n "Phase 26|GEO-01|GEO-02|geometry routing|saved-output|SHAPE_FEATURE_LEDGER" ARCHITECTURE.md DESIGN.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md .planning/ROADMAP.md .planning/STATE.md` | existing docs | pending |

## Wave 0 Requirements

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` or an equivalent focused extension to `BeautyEngineTests.swift` proves public-facade geometry activation and degradation through `BeautyEngine.processResult(...)`.
- [ ] A narrow internal or SPI-only detector seam exists for deterministic facade tests without adding public raw geometry, landmark, provider, or Vision types.
- [ ] A minimal internal adapter path exists from the selected usable detection result to internal `FaceGeometry`, sufficient for existing geometry resolver/provider tests.
- [ ] Scan commands classify active source separately from tests/docs when checking raw leak literals.

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

**Approval:** Pending execution evidence.
