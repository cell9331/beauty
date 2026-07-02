---
phase: 23-performance-and-reliability-gates
status: draft
updated: 2026-07-02
requirements:
  - PERF-01
  - PERF-04
  - PERF-05
---

# Phase 23 Performance Evidence

## Scope

This artifact records the initial SDK-side Phase 23 timing, memory-baseline, budget-comparison, and redaction evidence created by Plan 23-01.

Status values:

- `passed`: command or scan ran now and passed.
- `recorded`: evidence was captured as a current-environment baseline and may include risks.
- `blocked`: command could not produce meaningful evidence because local tooling or hardware is unavailable.
- `not attempted`: intentionally not run in this plan.
- `future`: routed to a later v1.4 phase or manual protocol.

## Explicit non-claims

- This is current-environment baseline evidence, not shipped frame-rate readiness.
- This does not assert commercial visual review, real-device parity, screenshot acceptance, or market fitness.
- The short fixture loop does not satisfy the 600-second preview-stability gate in `RELIABILITY.md`.
- Demo simulator and physical iPhone checks remain secondary until the documented tooling or hardware prerequisites are available.

## Environment

| Item | Value |
| --- | --- |
| Evidence run date | `2026-07-02` |
| Swift | Apple Swift `6.3.3`, swift-driver `1.148.6` |
| Swift target | `arm64-apple-macosx26.0` |
| Xcode | `26.6`, build `17F113` |
| SDK command runner | SwiftPM XCTest |
| Input shape | Synthetic BGRA `CVPixelBuffer`, `1280x720`, source `.testFixture`, orientation `.up` |
| SDK entrypoint | `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` |
| Configuration | `BeautyConfiguration.default`, render quality `.balanced`, `enablePerformanceLog == false`, `logLevel == .error` |

## Exact commands

| Area | Status | Exact command | Evidence summary | Requirement |
| --- | --- | --- | --- | --- |
| Swift version | passed | `swift --version` | Apple Swift `6.3.3`, target `arm64-apple-macosx26.0`. | PERF-01 |
| Xcode version | passed | `xcodebuild -version` | Xcode `26.6`, build `17F113`. | PERF-01 |
| Focused SDK evidence tests | passed | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` | Built `BeautyCoreTests` and executed 3 `BeautyPerformanceEvidenceTests` cases with 0 failures in 11.410 seconds. | PERF-01, PERF-04, PERF-05 |
| Redaction guard test | passed | Same focused SwiftPM command above | `testPERF05PerformanceEvidenceReportUsesOnlyAllowlistedFields` verified the report contains only allowlisted field names and excludes sensitive payload terms. | PERF-05 |

## SDK 720p Timing Matrix

The focused test prints the allowlisted timing report below. Sample and warmup counts are intentionally small so the command stays cheap enough for normal SwiftPM verification.

| Case | Samples | Warmups | Mean ms | Maximum ms | Resolution | Quality | Budget status | Warning codes | Metric keys |
| --- | ---: | ---: | ---: | ---: | --- | --- | --- | --- | --- |
| `default_noop` | 3 | 1 | 159.818 | 162.058 | `1280x720` | `balanced` | `over_budget_recorded` | none | `beauty.effects.activeCount`, `beauty.effects.cappedCount` |
| `skin_color_filter` | 3 | 1 | 367.118 | 367.949 | `1280x720` | `balanced` | `over_budget_recorded` | none | `beauty.effects.activeCount`, `beauty.effects.cappedCount`, `beauty.effects.filter.softClean` |
| `high_capped` | 3 | 1 | 410.448 | 411.044 | `1280x720` | `balanced` | `over_budget_recorded` | `beauty_strength_capped`, `eye_inputs_missing`, `face_effects_skipped_no_face`, `lip_inputs_missing`, `mouth_inputs_missing`, `nose_inputs_missing` | `beauty.effects.activeCount`, `beauty.effects.cappedCount`, `beauty.effects.filter.warmLight`, `beauty.effects.skippedEyeDomains`, `beauty.effects.skippedFaceDomains`, `beauty.effects.skippedLipDomains`, `beauty.effects.skippedMouthDomains`, `beauty.effects.skippedNoseDomains` |

## Budget comparison

`RELIABILITY.md` sets the first-version render-total reference at 5 to 12 ms per processed frame, with pass-level references of 2 to 6 ms for skin, 0.3 to 1.0 ms for color, and 0.5 to 1.5 ms for LUT/filter work.

All three 720p SDK cases are currently above the first-version render-total reference. Per Phase 23 decision D-03, this plan records and classifies the result instead of optimizing or changing behavior in the timing evidence task.

| Case | Environment | Result | Impact | Risk | Next action |
| --- | --- | --- | --- | --- | --- |
| `default_noop` | SwiftPM debug XCTest on Apple Swift 6.3.3, macOS target | Mean 159.818 ms exceeds the 5 to 12 ms reference. | Establishes that debug XCTest timing is not a performance pass. | No-op path may include debug/test overhead and allocation cost that requires later profiling. | Keep as baseline; compare against future optimized or release-like runs before changing budgets. |
| `skin_color_filter` | Same current SwiftPM debug environment | Mean 367.118 ms exceeds the reference. | Skin/color/filter processing is measurable and slow in this local baseline. | Interactive preview targets remain unproved. | Route optimization or release-mode profiling only after evidence is consolidated. |
| `high_capped` | Same current SwiftPM debug environment | Mean 410.448 ms exceeds the reference while preserving warning and metric codes. | High capped case proves caps are not bypassed for timing. | Strong-parameter cases require later profiling before readiness claims. | Keep safety-cap behavior intact; Phase 23 closeout records risk and rerun protocol. |

## Fixture-loop memory trend

| Field | Evidence |
| --- | --- |
| Command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` |
| Loop type | Synthetic SDK fixture loop through the same `1280x720` buffer and case matrix. |
| Iterations in printed report | 6 |
| Iterations in dedicated memory test | 9 |
| Case mix | `default_noop`, `skin_color_filter`, `high_capped` |
| Memory metric status | `unavailable` in the current helper because no resident-memory sampler is wired into the test target. |
| Growth trend | `unavailable` |
| Short-run status | `short_baseline_non_claim` |
| Rerun protocol | Run the same focused SwiftPM filter after adding or enabling an allowlisted resident-memory sampler, with `loopIterations` sized for 600 seconds, then record start, end, peak, case mix, and trend. |

## Redaction policy

Committed Phase 23 performance evidence may include only case name, sample counts, warmup counts, duration summary, resolution bucket, quality mode, warning codes, metric keys, memory status, blocker class, impact, next step, and rerun protocol.

The focused test keeps SDK logs optional and off by default. It does not enable per-frame logging and does not persist frames, selected files, face-coordinate payloads, private framework objects, unredacted preset payloads, user identifiers, token-like data, or diagnostic dumps.

## Initial blockers and routed work

| Gate | Status | Evidence | Impact | Next step |
| --- | --- | --- | --- | --- |
| 600-second preview stability | future | Current automated loop is intentionally short and labeled as a non-claim. | PERF-04 gets a repeatable baseline but not the full long-run gate. | Rerun with a longer fixture loop and memory sampler when cheap enough. |
| Demo simulator evidence | blocked | Phase 21 and Phase 22 record the missing local Metal Toolchain prerequisite for the explicit iPhone 17 simulator build/test path. | Phase 23 cannot claim current Demo simulator pass evidence yet. | Run `xcodebuild -downloadComponent MetalToolchain`, then rerun focused Demo commands. |
| Physical iPhone evidence | blocked | No hardware run exists in the current repository evidence. | Real-device stability and parity remain unproved. | Record device, route, duration, memory/thermal observations, and limitations when hardware is available. |

## Requirement coverage so far

| Requirement | Current Plan 23-01 status | Evidence |
| --- | --- | --- |
| PERF-01 | recorded | `BeautyPerformanceEvidenceTests` runs a `1280x720` SDK timing matrix through `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)`, with exact command and over-budget classification. |
| PERF-04 | recorded | The bounded fixture loop records case mix, iteration count, unavailable memory metric status, short-run non-claim, and 600-second rerun protocol. |
| PERF-05 | passed | The report allowlist test and this artifact avoid sensitive payload fields and keep performance logging off by default. |
