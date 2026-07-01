---
phase: 22-automated-demo-qa-and-screenshot-evidence
plan: 01
subsystem: qa
tags: [xcodebuild, simctl, swiftui, evidence, metal-toolchain]
requires:
  - phase: 21-baseline-audit-and-quality-ledger-refresh
    provides: Current Demo build/test blocker and v1.4 QA debt routing
provides:
  - Current v1.4 Demo build prerequisite evidence for iPhone 17 iOS 26.5
  - Focused Demo view-state test blocker status
  - Static route/model disabled-honesty evidence for QA-04
  - Rerun protocol for Metal Toolchain repair and Plan 22-02 capture
affects: [phase-22, demo-qa, visual-evidence]
tech-stack:
  added: []
  patterns: [blocker-honest evidence ledger, exact-command QA record]
key-files:
  created: [.planning/evidence/v1.4/VISUAL-EVIDENCE.md]
  modified: []
key-decisions:
  - "Current v1.4 screenshot evidence remains blocked until the local Metal Toolchain is installed."
  - "Static route/model scans are recorded as QA-04 fallback evidence while focused XCTest is blocked by the same build prerequisite."
patterns-established:
  - "Evidence claims must include exact command, destination, environment, impact, and next step."
  - "Archived v1.1/v1.2 screenshots are background comparison only, not current v1.4 pass evidence."
requirements-completed: [QA-01, QA-03, QA-04]
duration: 4min
completed: 2026-07-01
---

# Phase 22: Plan 01 Summary

**Current Demo build/test evidence records the iPhone 17 Metal Toolchain blocker and preserves route/model disabled-honesty proof without false screenshot claims**

## Performance

- **Duration:** 4 min
- **Started:** 2026-07-01T06:40:45Z
- **Completed:** 2026-07-01T06:44:34Z
- **Tasks:** 3
- **Files modified:** 1

## Accomplishments

- Reproduced the explicit Demo simulator build blocker on `platform=iOS Simulator,name=iPhone 17,OS=26.5`.
- Recorded focused `BeautyDemoViewStateTests` as blocked by the same Metal Toolchain prerequisite, not as a source/test failure.
- Added static route/model disabled-honesty evidence for existing launch routes, disabled Home routes, unsupported editor tools, and future category tests.
- Preserved non-claims, archived-evidence limits, physical iPhone blocker protocol, and Metal Toolchain rerun steps.

## Task Commits

Each task was committed atomically:

1. **Task 1: Reproduce or clear the Demo build prerequisite** - `020a923`
2. **Task 2: Record route and disabled-honesty checks** - `eac5430`
3. **Task 3: Gate evidence completeness and non-claims** - `ca8df13`

## Files Created/Modified

- `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` - Current v1.4 Demo QA evidence ledger with build/test blocker status, static route/model evidence, non-claims, and rerun protocol.

## Decisions Made

- No screenshots were created because the Demo build still fails before an app can be installed or launched.
- Plan 22-02 should follow the blocker branch unless `Demo simulator build: passed` replaces the current marker after Metal Toolchain installation.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- `xcodebuild ... build` exited `65` while compiling `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`; Xcode reported missing Metal Toolchain and recommended `xcodebuild -downloadComponent MetalToolchain`.
- `xcodebuild ... test -only-testing:BeautyDemoTests/BeautyDemoViewStateTests` exited `65` for the same Metal Toolchain prerequisite.

## User Setup Required

Run `xcodebuild -downloadComponent MetalToolchain` before rerunning Demo build/test and attempting current simulator screenshot capture.

## Next Phase Readiness

Plan 22-02 can proceed on the documented blocker path now. If the Metal Toolchain is installed first, rerun the exact build/test commands and then use the `simctl` capture protocol recorded in the plan.

## Self-Check: PASSED

- `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` exists.
- `Demo simulator build: blocked` and `Demo focused view-state test: blocked` are explicit.
- No current v1.4 screenshot PNGs were created.
- Non-claim and archived-only scans passed.

---
*Phase: 22-automated-demo-qa-and-screenshot-evidence*
*Completed: 2026-07-01*
