---
phase: 23
slug: performance-and-reliability-gates
status: final
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-02
updated: 2026-07-02
---

# Phase 23 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | SwiftPM XCTest, Xcode/xcodebuild, shell static scans, GSD validators |
| **Config file** | `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `.planning/config.json` |
| **Quick run command** | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` plus scoped redaction scan for any new Phase 23 artifact |
| **Full suite command** | `swift test --package-path BeautySDK` plus focused Demo `xcodebuild` camera pipeline test on the explicit iPhone 17 simulator destination |
| **Estimated runtime** | 5 to 20 minutes for SDK suite, Demo focused tests, and evidence scans; physical-device and 600-second long-run checks require separate manual setup |

## Sampling Rate

- **After every task commit:** Run the focused test or static scan for the task and `git diff --check` over touched Phase 23 artifacts.
- **After every plan wave:** Run `swift test --package-path BeautySDK`; run the focused Demo `xcodebuild` command when the simulator destination is available; otherwise record the blocker.
- **Before `$gsd-verify-work`:** SDK tests, timing/long-run evidence, blocker/pass status, and redaction scans must be recorded without readiness overclaims.
- **Max feedback latency:** 20 minutes for automated SDK and focused Demo checks; manual long-run or hardware checks use the documented rerun protocols.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 23-01-01 | 01 | 1 | PERF-01, PERF-04 | T-23-01-01 | Synthetic 720p timing/long-run evidence uses redacted fields and does not persist frame payloads, coordinate payloads, paths, or diagnostic dumps. | performance/unit evidence | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` | yes | passed |
| 23-01-02 | 01 | 1 | PERF-01, PERF-04, PERF-05 | T-23-01-02 | Evidence artifact records exact command, environment, case table, memory trend, budget comparison, non-claims, and rerun protocol with allowlisted fields only. | artifact scan | `rg -n "PERF-01|PERF-04|1280x720|mean|maximum|memory|budget|non-claim|rerun" .planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` | yes | passed |
| 23-02-01 | 02 | 1 | PERF-02 | T-23-02-01 | Backpressure/latest-frame-wins evidence records pass or blocker honestly and preserves dropped-frame accounting. | focused XCTest | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` | yes | passed |
| 23-02-02 | 03 | 1 | PERF-03 | T-23-02-02 | Quality, reset, degradation, and safety-cap checks do not bypass caps, no-face behavior, stale/reused geometry handling, missing-landmark degradation, or recovery rules. | focused SDK tests | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineTests` and focused `BeautyEffectsTests` filters | yes | passed |
| 23-02-03 | 01, 03, 04 | 1-2 | PERF-05 | T-23-02-03 | Logs remain optional/off by default and Phase 23 artifacts exclude sensitive payloads and overclaim wording. | unit/static scan | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyConfigurationTests/testSDK02DefaultConfigurationIsSafeForRelease` plus scoped artifact scans | yes | passed |

## Wave 0 Requirements

Wave 0 references are complete:

- `BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift` exists and covers PERF-01, PERF-04, and PERF-05.
- `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` exists with exact command results, environment, case table, duration summary, memory trend, budget comparison, non-claims, and rerun protocol.
- PERF-03 is scoped to configuration-contract, reset, safety-cap, degradation, and Demo recovery evidence without public API, Demo UI, product-route, or broad strategy expansion.

Existing infrastructure confirmed:

- `BeautySDK/Package.swift` exists.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` exists.
- `.planning/REQUIREMENTS.md` maps `PERF-01` through `PERF-05` to Phase 23.
- `23-CONTEXT.md`, `23-RESEARCH.md`, and `23-PATTERNS.md` exist.

## Manual-Only Verifications

| Behavior | Requirement | Current Status | Why Manual | Test Instructions |
|----------|-------------|----------------|------------|-------------------|
| Physical iPhone long-run camera route | PERF-04 | blocked | Hardware is not available in current repository evidence and Phase 23 context makes device evidence secondary. | If a physical iPhone is available, run the Demo camera long-run protocol and record device class, OS, route, duration, aggregate memory/thermal observations, and non-claims. If unavailable, keep the hardware blocker and rerun protocol. |
| Demo simulator 600-second preview loop | PERF-02, PERF-04 | not run | Focused simulator pipeline tests passed, but no long-run preview route was collected in Phase 23. | Run the exact focused xcodebuild command first, then a dedicated 600-second preview route with aggregate memory/thermal notes; do not use the focused unit test as long-run evidence. |
| Demo screenshot acceptance | PERF-04 | not run | Phase 23 is a performance/reliability phase and did not collect screenshot artifacts. | Build, install, launch the existing routes, capture screenshots, and record only artifact paths plus review status in a visual QA phase. |
| Release-like frame-rate and real-device parity | PERF-01, PERF-04 | future | Phase 23 establishes current-environment evidence, not multi-device readiness. | Do not mark as passed unless actual optimized and device-backed evidence exists. Otherwise record as out of scope or future work. |

## Validation Sign-Off

- [x] All planned requirements have automated verify, focused blocker-recording criteria, or explicit manual-only rationale.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify or blocker-recording criteria.
- [x] Wave 0 references required for PERF-01, PERF-04, and PERF-05 evidence exist.
- [x] No watch-mode flags.
- [x] Feedback latency target is below 20 minutes for automated SDK and focused Demo checks.
- [x] `nyquist_compliant: true` set in frontmatter.

**Approval:** Phase 23 automated validation evidence is complete with manual blockers and rerun protocols preserved.
