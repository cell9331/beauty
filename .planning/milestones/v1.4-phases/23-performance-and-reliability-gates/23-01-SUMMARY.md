---
phase: 23-performance-and-reliability-gates
plan: 01
subsystem: testing
tags: [swiftpm, xctest, performance, reliability, redaction]
requires:
  - phase: 21-baseline-audit-and-quality-ledger-refresh
    provides: Current SDK SwiftPM baseline and Demo Metal Toolchain blocker protocol.
  - phase: 23-performance-and-reliability-gates
    provides: Phase 23 context, research, validation, and pattern map.
provides:
  - SDK 1280x720 timing matrix through BeautyEngine.processResult(pixelBuffer:metadata:parameters:).
  - Short fixture-loop memory baseline with explicit 600-second rerun protocol.
  - Initial redacted Phase 23 performance evidence ledger.
affects: [Phase 23 Wave 2 evidence consolidation, QUALITY_SCORE reliability scorecard, PERF-01, PERF-04, PERF-05]
tech-stack:
  added: []
  patterns: [SwiftPM XCTest performance evidence helper, redacted Markdown evidence ledger]
key-files:
  created:
    - BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift
    - .planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md
  modified: []
key-decisions:
  - "Performance evidence records current SwiftPM debug XCTest timings as over-budget baseline data, not as an optimization gate."
  - "The memory trend helper reports metric-unavailable status until an allowlisted resident-memory sampler is wired into the test target."
patterns-established:
  - "Performance evidence reports table-like allowlisted fields rather than raw logs or serialized payloads."
requirements-completed: [PERF-01, PERF-04, PERF-05]
duration: 6 min
completed: 2026-07-02
---

# Phase 23 Plan 01: SDK Performance Evidence Summary

**SwiftPM XCTest timing matrix and redacted evidence ledger for SDK 720p performance baselining**

## Performance

- **Duration:** 6 min
- **Started:** 2026-07-02T02:30:33Z
- **Completed:** 2026-07-02T02:36:00Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added `BeautyPerformanceEvidenceTests` with three focused PERF tests covering SDK 720p timing, fixture-loop memory status, and allowlisted report fields.
- Recorded `23-PERFORMANCE-EVIDENCE.md` with exact Swift/Xcode environment, command output, timing matrix, budget comparison, over-budget classifications, memory non-claim, and rerun protocol.
- Preserved Phase 23 scope: no public API, Demo UI, renderer strategy, dependency, image-file output, or per-frame logging expansion.

## Task Commits

Each task was committed atomically:

1. **Task 1: Create SDK timing and fixture-loop memory evidence tests** - `b4fa168` (`test`)
2. **Task 2: Record initial timing and memory evidence artifact** - `385d4fa` (`docs`)

**Plan metadata:** pending metadata commit.

## Files Created/Modified

- `BeautySDK/Tests/BeautyCoreTests/BeautyPerformanceEvidenceTests.swift` - Adds the synthetic `1280x720` BGRA timing matrix, short fixture loop, and redacted report allowlist tests.
- `.planning/phases/23-performance-and-reliability-gates/23-PERFORMANCE-EVIDENCE.md` - Records the initial Phase 23 timing, memory, redaction, blocker, and non-claim evidence.

## Decisions Made

- Used small sample and warmup counts so the focused SwiftPM command remains cheap enough for normal verification.
- Printed one allowlisted report from the timing test so future agents can capture exact case-level values without enabling SDK logging.
- Classified all measured cases as `over_budget_recorded` because the current SwiftPM debug XCTest run is above the `RELIABILITY.md` 5 to 12 ms render-total reference.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- SwiftPM returns exit 0 with a warning when the pre-creation RED filter matches zero tests. The summary records this as RED nuance rather than a source failure.
- The memory trend helper currently reports `unavailable` because no resident-memory sampler is wired into the test target. The evidence artifact records this limitation and the 600-second rerun protocol.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyPerformanceEvidenceTests` passed with 3 tests and 0 failures.
- Required-field scan over `23-PERFORMANCE-EVIDENCE.md` found PERF IDs, `1280x720`, all three case names, budget, memory, non-claim, and rerun terms.
- Forbidden-token scan over `23-PERFORMANCE-EVIDENCE.md` returned no matches.
- No-overclaim scan over `23-PERFORMANCE-EVIDENCE.md` returned no matches.
- `git diff --check` passed for both touched files.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plans 23-02 and 23-03 can add Demo and SDK reliability regressions. Plan 23-04 should consolidate this artifact with their summaries and keep the Demo Metal Toolchain and physical-device blockers explicit.

---
*Phase: 23-performance-and-reliability-gates*
*Completed: 2026-07-02*
