---
phase: 23-performance-and-reliability-gates
status: final
updated: 2026-07-02
requirements:
  - PERF-01
  - PERF-02
  - PERF-03
  - PERF-04
  - PERF-05
---

# Phase 23 Performance and Reliability Evidence

## Scope

This artifact is the final Phase 23 evidence ledger for timing, budget comparison, memory-trend protocol, Demo backpressure, reset/recovery, SDK degradation, safety caps, and redaction status.

Status values:

- `passed`: command or scan ran in this phase and passed.
- `recorded`: current-environment evidence exists but includes a limitation or risk.
- `blocked`: hardware or tooling needed for that evidence is unavailable.
- `not run`: evidence was intentionally left to the documented rerun protocol.

## Non-claims

- Current timing is SwiftPM debug XCTest baseline data, not shipped frame-rate readiness.
- Phase 23 does not assert commercial visual review, real-device parity, screenshot acceptance, or market fitness.
- The short fixture loop does not satisfy the 600-second preview-stability gate in `RELIABILITY.md`.
- Focused Demo pipeline tests passing on a simulator do not replace physical iPhone or long-run preview evidence.
- Performance logging remains optional and off by default; Phase 23 does not introduce per-frame persistent logs.

## Environment

| Item | Value |
| --- | --- |
| Evidence date | `2026-07-02` |
| Local time window | `10:49 +0800` |
| Swift | Apple Swift `6.3.3`, swift-driver `1.148.6` |
| Swift target | `arm64-apple-macosx26.0` |
| Xcode | `26.6`, build `17F113` |
| SDK command runner | SwiftPM XCTest |
| Demo command runner | `xcodebuild` XCTest |
| Demo destination | `platform=iOS Simulator,name=iPhone 17,OS=26.5` |
| SDK input shape | Synthetic BGRA `CVPixelBuffer`, `1280x720`, source `.testFixture`, orientation `.up` |
| SDK entrypoint | `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` |
| SDK configuration | `BeautyConfiguration.default`, render quality `.balanced`, `enablePerformanceLog == false`, `logLevel == .error` |

## Exact Command Results

| Area | Status | Exact command | Result | Requirement |
| --- | --- | --- | --- | --- |
| Swift environment | passed | `swift --version` | Apple Swift `6.3.3`, swift-driver `1.148.6`, target `arm64-apple-macosx26.0`. | PERF-01 |
| Xcode environment | passed | `xcodebuild -version` | Xcode `26.6`, build `17F113`. | PERF-01, PERF-02 |
| Focused SDK evidence tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` | Executed 3 tests, 0 failures, 11.292 seconds. | PERF-01, PERF-04, PERF-05 |
| Full SDK suite | passed | `swift test --package-path BeautySDK` | Executed 148 tests, 0 failures, 15.153 seconds. | PERF-01, PERF-03, PERF-04, PERF-05 |
| Focused Demo camera tests | passed | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` | Xcode reported `TEST SUCCEEDED`; 7 camera pipeline tests passed, including both PERF camera regressions. | PERF-02, PERF-03, PERF-04 |
| Focused Demo camera plus still-image tests | passed | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests -only-testing:BeautyDemoTests/ImageEditorPipelineTests test` | Plan 23-02 executed 7 camera tests and 9 image-editor tests with 0 failures. | PERF-02, PERF-03 |
| Required field scan | passed | `rg -n "PERF-01|PERF-02|PERF-03|PERF-04|PERF-05|Timing matrix|Budget comparison|Memory trend|Backpressure|Quality mode|Reset|Degradation|Redaction scan|Non-claims|Rerun protocol" .planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` | Required evidence headings and requirement IDs are present. | PERF-01, PERF-02, PERF-03, PERF-04, PERF-05 |
| Scoped redaction scan | passed | Plan 23-04 scoped forbidden-token scan over this artifact | No matches after final edits. | PERF-05 |
| Scoped no-overclaim scan | passed | Plan 23-04 scoped no-overclaim scan over this artifact | No matches after final edits. | PERF-05 |

## SDK 720p Timing matrix

Timing values come from the focused SDK evidence command in this plan. Sample and warmup counts are intentionally small so maintainers can rerun the command during normal SwiftPM verification.

| Case | Samples | Warmups | Mean ms | Maximum ms | Resolution | Quality | Budget status | Warning codes | Metric keys |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- | --- | --- |
| `default_noop` | 3 | 1 | 160.340 | 161.518 | `1280x720` | `balanced` | `over_budget_recorded` | none | `beauty.effects.activeCount`, `beauty.effects.cappedCount` |
| `skin_color_filter` | 3 | 1 | 366.483 | 368.224 | `1280x720` | `balanced` | `over_budget_recorded` | none | `beauty.effects.activeCount`, `beauty.effects.cappedCount`, `beauty.effects.filter.softClean` |
| `high_capped` | 3 | 1 | 399.286 | 399.938 | `1280x720` | `balanced` | `over_budget_recorded` | `beauty_strength_capped`, `eye_inputs_missing`, `face_effects_skipped_no_face`, `lip_inputs_missing`, `mouth_inputs_missing`, `nose_inputs_missing` | `beauty.effects.activeCount`, `beauty.effects.cappedCount`, `beauty.effects.filter.warmLight`, `beauty.effects.skippedEyeDomains`, `beauty.effects.skippedFaceDomains`, `beauty.effects.skippedLipDomains`, `beauty.effects.skippedMouthDomains`, `beauty.effects.skippedNoseDomains` |

## Budget comparison

`RELIABILITY.md` defines the first-version render-total reference at 5 to 12 ms per processed frame. Its pass-level references are 2 to 6 ms for skin work, 0.3 to 1.0 ms for color work, and 0.5 to 1.5 ms for LUT/filter work.

All three current 720p SDK cases exceed the first-version render-total reference in SwiftPM debug XCTest. Phase 23 records this as baseline evidence and risk; it does not optimize, loosen budgets, or reclassify the result as a pass.

| Case | Result | Impact | Risk | Next action |
| --- | --- | --- | --- | --- |
| `default_noop` | Mean 160.340 ms exceeds the 5 to 12 ms render-total reference. | Establishes that debug XCTest timing is not a performance pass. | No-op work may include debug/test overhead and allocation cost. | Keep as baseline; rerun in an optimized profiling setup before budget decisions. |
| `skin_color_filter` | Mean 366.483 ms exceeds the render-total reference. | Skin, color, and filter work are measurable in the baseline. | Interactive preview readiness remains unproved. | Profile after evidence closeout; preserve current behavior until an optimization plan exists. |
| `high_capped` | Mean 399.286 ms exceeds the render-total reference while preserving warning and metric codes. | High-parameter timing proves safety caps are not bypassed during evidence collection. | Strong-parameter cases need later profiling before readiness claims. | Keep safety-cap behavior intact and rerun after profiling changes. |

## Over-Budget Classification

| Case | Classification | Reason |
| --- | --- | --- |
| `default_noop` | `over_budget_recorded` | Current mean exceeds the `RELIABILITY.md` render-total reference. |
| `skin_color_filter` | `over_budget_recorded` | Current mean exceeds the render-total reference for combined skin/color/filter work. |
| `high_capped` | `over_budget_recorded` | Current mean exceeds the render-total reference; warning and metric evidence confirms caps still apply. |

## Memory trend

| Field | Evidence |
| --- | --- |
| Command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` |
| Loop type | Synthetic SDK fixture loop through the same `1280x720` buffer and case matrix. |
| Iterations in printed report | 6 |
| Iterations in dedicated memory test | 9 |
| Case mix | `default_noop`, `skin_color_filter`, `high_capped` |
| Memory metric status | `unavailable`; no resident-memory sampler is wired into the test target. |
| Growth trend | `unavailable` |
| Short-run status | `short_baseline_non_claim` |

## Rerun protocol

To attempt the full 600-second gate from `RELIABILITY.md`:

1. Add or enable an allowlisted resident-memory sampler in the test target.
2. Run `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` with the fixture loop sized for 600 seconds.
3. Record start, end, peak, case mix, iteration count, trend status, and non-claims.
4. Keep the artifact limited to aggregate counters, duration summaries, quality mode, warning codes, metric keys, blocker class, impact, next step, and rerun protocol.

## Demo Backpressure and focused xcodebuild status

| Evidence | Status | Result | Requirement |
| --- | --- | --- | --- |
| `CameraBeautyPipelineTests.testPERF02BackpressureStressKeepsLatestFrameWinsAndCountsDroppedFrames` | passed | One in-flight frame, one latest pending frame, three stale pending drops, `lastDropReason == .backpressure`, processed timestamps `1` and `5`, and latest parameter snapshot are verified. | PERF-02 |
| `CameraBeautyPipelineTests.testPERF03ResetClearsPendingWorkDropCountersWarningsAndSnapshots` | passed | Reset clears pending work, latest snapshot, warnings, status copy, in-flight count, dropped-frame count, drop reason, and stale completion handling. | PERF-03 |
| `ImageEditorPipelineTests.testPERF03SelectionFailureCanRecoverWithLatestValidFixture` | passed | Invalid picker data preserves the previous snapshot and later valid fixture input replaces the failure state. | PERF-03 |
| Focused camera xcodebuild command | passed | The iPhone 17 iOS 26.5 simulator command passed in Plan 23-04. | PERF-02, PERF-04 |
| Focused camera plus still-image xcodebuild command | passed | The combined focused command passed in Plan 23-02. | PERF-02, PERF-03 |

The earlier Phase 21 and 22 Metal Toolchain blocker is superseded for these focused build/test commands in this environment only. It is not a screenshot, long-run, or physical-device claim.

## SDK Quality mode, Reset, Degradation, and caps

| Evidence | Status | Result | Requirement |
| --- | --- | --- | --- |
| `BeautyConfigurationTests.testPERF03RenderQualityModesAreStableConfigurationContract` | passed | Quality-mode raw values and default configuration remain stable. | PERF-03 |
| `BeautyEngineTests.testPERF03ResetPreservesConfigurationQualityAndDetectionSummaryContract` | passed | `BeautyEngine.reset()` preserves configuration, caller parameters, reset count, and disabled detection summary behavior. | PERF-03 |
| `CombinedEffectSafetyTests.testPERF03HighCappedTimingParametersPreserveSafetyCapsAndRedactedMetrics` | passed | High timing parameters preserve caps, weakening metadata, warnings, and metrics. | PERF-03, PERF-05 |
| `MissingLandmarkDegradationTests.testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded` | passed | No-face, missing mouth/lip, stale, reused, safe color/filter domains, and redacted warning/metric behavior are covered. | PERF-03, PERF-05 |
| Full SDK suite | passed | 148 SwiftPM tests passed with 0 failures after the Phase 23 regressions were added. | PERF-01, PERF-03, PERF-04, PERF-05 |

## Physical iPhone and Demo Simulator Evidence

| Gate | Status | Evidence | Impact | Next step |
| --- | --- | --- | --- | --- |
| Focused Demo simulator camera regressions | passed | The Plan 23-04 focused xcodebuild camera command passed on the iPhone 17 iOS 26.5 simulator. | Backpressure and reset regressions have current simulator evidence. | Keep the same destination explicit for future reruns. |
| Demo simulator long-run preview | not run | No 600-second simulator preview loop was collected in Phase 23. | Long-run preview memory behavior remains unproved. | Run a dedicated 600-second preview route with aggregate memory/thermal notes and retain non-claims. |
| Demo simulator screenshot capture | not run | Phase 23 did not capture current screenshots. | Visual screenshot acceptance remains outside this evidence. | Build, install, launch the existing routes, capture screenshots, and record only artifact paths plus review status in a visual QA phase. |
| Physical iPhone long-run camera route | blocked | No physical iPhone run exists in the repository evidence. | Device camera/Vision behavior and hardware thermal/memory behavior remain unproved. | When hardware is available, record device class, OS, route, duration, aggregate memory/thermal observations, pass/blocker status, and limitations. |

## Redaction scan

Phase 23 evidence is limited to allowlisted case names, sample counts, warmup counts, duration summaries, resolution bucket, quality mode, warning codes, metric keys, memory status, blocker class, impact, next step, and rerun protocol.

The Plan 23-04 scoped redaction scan over this file returned no matches after final edits. The artifact avoids frame payloads, private local paths, face-coordinate payloads, unredacted preset payloads, user identifiers, token-like data, and diagnostic dumps.

The no-overclaim scan also returned no matches. The conclusions are limited to pass, recorded baseline, blocked, not-run, risk, and rerun status.

## Requirement Coverage

| Requirement | Status | Evidence |
| --- | --- | --- |
| PERF-01 | recorded | Focused SDK evidence command records a `1280x720` timing matrix through `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)`; all current cases are classified as over-budget baseline data against `RELIABILITY.md`. |
| PERF-02 | passed | Demo camera backpressure regression and focused xcodebuild camera command verify latest-frame-wins and dropped-frame accounting. |
| PERF-03 | passed | SDK and Demo regressions cover quality mode, reset, degradation, safety caps, no-face/missing/stale/reused behavior, and recovery after still-image selection failure. |
| PERF-04 | passed-with-blocker-record | SDK fixture-loop evidence exists with a 600-second rerun protocol; focused Demo simulator tests pass; physical iPhone and long-run preview evidence remain blocked or not run. |
| PERF-05 | passed | Performance logs remain optional/off by default, evidence fields are allowlisted, and redaction plus no-overclaim scans pass. |
