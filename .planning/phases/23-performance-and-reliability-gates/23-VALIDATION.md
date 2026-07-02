---
phase: 23
slug: performance-and-reliability-gates
status: draft
nyquist_compliant: true
wave_0_complete: false
created: 2026-07-02
---

# Phase 23 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, Xcode/xcodebuild, shell static scans, GSD validators |
| **Config file** | `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyConfigurationTests/testSDK02DefaultConfigurationIsSafeForRelease` plus scoped redaction scan for any new Phase 23 artifact |
| **Full suite command** | `swift test --package-path BeautySDK` plus Demo focused `xcodebuild` blocker/pass record if the local Metal Toolchain is available |
| **Estimated runtime** | 5 to 20 minutes for SDK suite and evidence scans; Demo focused tests remain blocker-dependent |

## Sampling Rate

- **After every task commit:** Run the focused test or static scan for the task and `git diff --check` over touched Phase 23 artifacts.
- **After every plan wave:** Run `swift test --package-path BeautySDK`; run Demo focused `xcodebuild` tests only if the Metal Toolchain is installed, otherwise record the reproducible blocker.
- **Before `$gsd-verify-work`:** SDK tests, timing/long-run evidence, blocker/pass status, and redaction scans must be recorded without release-grade overclaims.
- **Max feedback latency:** 20 minutes for automated SDK checks; Demo checks may exit early with a documented blocker.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 23-01-01 | 01 | 1 | PERF-01, PERF-04 | T-23-01-01 | Synthetic 720p timing/long-run evidence uses redacted fields and does not persist raw frames, face geometry, paths, or raw diagnostics. | performance/unit evidence | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` | no until Wave 1 creates it | pending |
| 23-01-02 | 01 | 1 | PERF-01, PERF-04, PERF-05 | T-23-01-02 | Evidence artifact records exact command, environment, case table, memory trend, budget comparison, non-claims, and rerun protocol with allowlisted fields only. | artifact scan | `rg -n "PERF-01|PERF-04|1280x720|mean|maximum|memory|budget|non-claim|rerun" .planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` | no until Wave 1 creates it | pending |
| 23-02-01 | 02 | 2 | PERF-02 | T-23-02-01 | Backpressure/latest-frame-wins evidence records pass or blocker honestly and preserves dropped-frame accounting. | focused XCTest or blocker record | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` | yes, but current Demo command is Metal Toolchain-blocked | pending |
| 23-02-02 | 02 | 2 | PERF-03 | T-23-02-02 | Quality, reset, degradation, and safety-cap checks do not bypass caps, no-face behavior, stale/reused geometry, missing-landmark degradation, or recovery rules. | focused SDK tests | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineTests` and `swift test --package-path BeautySDK --filter BeautyEffectsTests` | partial; quality-mode behavior may need minimal internal/test evidence | pending |
| 23-02-03 | 02 | 2 | PERF-05 | T-23-02-03 | Logs remain optional/off by default and Phase 23 artifacts exclude forbidden sensitive payloads. | unit/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyConfigurationTests/testSDK02DefaultConfigurationIsSafeForRelease` plus scoped `rg` forbidden-token scan | partial until new artifact exists | pending |

## Wave 0 Requirements

Wave 1 must create or confirm these missing references before Phase 23 can claim complete evidence:

- `BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift` or an equivalent SDK-side helper/test that covers PERF-01 and PERF-04.
- `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` with exact command, environment, case table, duration summary, memory trend, budget comparison, non-claims, and rerun protocol.
- A quality-mode decision check that either limits PERF-03 to current configuration-contract evidence or adds minimal internal/test-focused behavior without public API, Demo UI, product-route, or broad strategy expansion.

Existing infrastructure already present:

- `BeautySDK/Package.swift` exists.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` exists.
- `.planning/REQUIREMENTS.md` maps `PERF-01` through `PERF-05` to Phase 23.
- `23-CONTEXT.md` and `23-RESEARCH.md` exist.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Physical iPhone long-run stability | PERF-04 | Hardware may not be available and Phase 23 context makes device evidence secondary. | If a physical iPhone is available, run the Demo/camera long-run protocol and record duration, device, route, memory/thermal observations, and non-claims. If unavailable, record a hardware blocker and rerun protocol. |
| Demo simulator long-run or focused backpressure test | PERF-02, PERF-04 | The current local Demo build/test path is blocked by missing Metal Toolchain while compiling `Warp.metal`. | Run the exact `xcodebuild` focused command only after the Metal Toolchain is installed. Until then, record exit status, blocker class, impact, next step, and do not claim Demo pass evidence. |
| Release-grade 30 fps / all-device parity | PERF-01, PERF-04 | Phase 23 establishes current-environment evidence, not release-grade device parity. | Do not mark as passed unless actual release-like multi-device evidence exists. Otherwise record as out of scope or future work. |

## Validation Sign-Off

- [x] All planned requirements have automated verify, focused blocker-recording criteria, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify or blocker-recording criteria.
- [x] Wave 0 identifies all missing references required for PERF-01, PERF-04, and PERF-05 evidence.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 20 minutes for automated SDK checks.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** pending execution evidence
