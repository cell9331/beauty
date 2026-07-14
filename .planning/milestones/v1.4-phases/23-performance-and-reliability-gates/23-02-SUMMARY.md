---
phase: 23-performance-and-reliability-gates
plan: 02
subsystem: testing
tags: [xcodebuild, xctest, demo, backpressure, reset, recovery]
requires:
  - phase: 23-performance-and-reliability-gates
    provides: Phase 23 context and Demo blocker-honesty protocol.
provides:
  - Demo camera backpressure stress regression for latest-frame-wins behavior.
  - Demo camera reset regression for pending work, counters, warnings, and stale completion handling.
  - Still-image selection-failure recovery regression.
affects: [Phase 23 Wave 2 evidence consolidation, PERF-02, PERF-03, PERF-04, PERF-05]
tech-stack:
  added: []
  patterns: [MainActor XCTest pipeline regression, explicit iPhone 17 xcodebuild evidence]
key-files:
  created: []
  modified:
    - BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift
    - BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift
key-decisions:
  - "Current local Demo focused test commands pass on iPhone 17 iOS 26.5; this supersedes the earlier blocker for these focused commands only."
  - "Reset evidence remains scoped to app-side queue/counter/status state and does not claim GPU cache behavior."
patterns-established:
  - "Backpressure tests block the first frame, enqueue a burst, then assert only the latest pending work is processed."
requirements-completed: [PERF-02, PERF-03, PERF-04, PERF-05]
duration: 5 min
completed: 2026-07-02
---

# Phase 23 Plan 02: Demo Pipeline Reliability Summary

**Demo camera and still-image pipeline regressions for backpressure, reset, and recovery behavior**

## Performance

- **Duration:** 5 min
- **Started:** 2026-07-02T02:39:07Z
- **Completed:** 2026-07-02T02:44:00Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added `testPERF02BackpressureStressKeepsLatestFrameWinsAndCountsDroppedFrames`, covering one in-flight frame, one latest pending frame, three stale pending drops, `lastDropReason == .backpressure`, processed timestamps `[1, 5]`, and latest parameter snapshot.
- Added `testPERF03ResetClearsPendingWorkDropCountersWarningsAndSnapshots`, covering pending work, latest snapshot, warning/status copy, in-flight count, dropped-frame count, drop reason, idle state, and old in-flight completion after reset.
- Added `testPERF03SelectionFailureCanRecoverWithLatestValidFixture`, covering invalid picker data preserving the previous snapshot and a later valid fixture replacing the failure state.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add a narrow backpressure stress regression** - `d3c9690` (`test`, also includes the camera reset regression because both belong to `CameraBeautyPipelineTests.swift`)
2. **Task 2: Add Demo reset and still-image recovery regressions** - `25e72e9` (`test`, still-image recovery regression)

**Plan metadata:** pending metadata commit.

## Files Created/Modified

- `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift` - Adds PERF-02 backpressure stress and PERF-03 reset regressions.
- `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` - Adds PERF-03 still-image selection-failure recovery regression.

## Decisions Made

- Kept implementation test-only; no changes to `CameraBeautyPipeline`, `ImageEditorPipeline`, Demo routes, UI copy, or public SDK surface were needed.
- Recorded the current focused Demo command as passed because the local Metal Toolchain prerequisite is now available in this environment.

## Deviations from Plan

None - plan executed within the planned files and behavior.

## Issues Encountered

- Earlier Phase 21/22 evidence recorded a missing Metal Toolchain blocker. In this run, `Warp.metal` compiled and the explicit focused Demo commands passed, so this plan records pass evidence for the focused test scope only.

## Verification

- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests test` passed. New PERF camera tests passed on the iPhone 17 simulator clone.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' -only-testing:BeautyDemoTests/CameraBeautyPipelineTests -only-testing:BeautyDemoTests/ImageEditorPipelineTests test` passed. The run included 7 camera tests and 9 image-editor tests.
- Source scans found the three new PERF test names, `reset()`, `photosPickerData(Data())`, `latest valid`, dropped-frame count, drop reason, backpressure, and `[1, 5]` assertions.
- `git diff --check` passed for both touched test files.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 23-04 can consolidate this summary as current focused Demo pass evidence. Physical iPhone and broader Demo long-run evidence remain separate from these focused pipeline regressions unless a later plan records actual device evidence.

---
*Phase: 23-performance-and-reliability-gates*
*Completed: 2026-07-02*
