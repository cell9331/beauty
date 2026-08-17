---
phase: 73-public-backend-configuration-and-fail-closed-availability
plan: 01
subsystem: sdk-configuration
tags: [swift, swiftpm, codable, cpu, gpu]

# Dependency graph
requires:
  - phase: 72-metal-feature-passes
    provides: package-only Metal pass execution and CPU-compatible backend contracts
provides:
  - Public BeautyRenderBackend enum with closed .cpu/.gpu values
  - Compatibility-safe BeautyConfiguration.renderBackend field defaulting to CPU
  - Codable, invalid-value, and schema-boundary regression coverage
affects: [73-02 backend routing, 73-03 configuration gate, 74 parity]

# Tech tracking
tech-stack:
  added: []
  patterns: [default missing Codable execution policy to CPU, keep backend policy outside BeautyParameters]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift

key-decisions:
  - "Expose exactly .cpu and .gpu as a public execution-policy enum while keeping algorithms and preset schemas unchanged."
  - "Decode an absent renderBackend key as .cpu but reject unknown raw values."

patterns-established:
  - "Public configuration fields append defaulted initializer arguments to preserve source compatibility."
  - "Backend selection is not serialized into BeautyParameters or effect inventory."

requirements-completed: [CONFIG-01]

# Metrics
duration: 2min
completed: 2026-08-17
---

# Phase 73 Plan 01: Public Backend Configuration Contract Summary

**Closed public CPU/GPU backend selection with CPU-compatible Codable defaults and unchanged parameter schema.**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-08-17T09:39:00+08:00
- **Completed:** 2026-08-17T09:42:00+08:00
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added `BeautyRenderBackend` with exactly `.cpu` and `.gpu`, conforming to `Codable`, `Equatable`, and `Sendable`.
- Added `BeautyConfiguration.renderBackend` as a final, defaulted field; absent legacy keys decode to `.cpu` and unknown values fail decoding.
- Added focused tests covering defaults, explicit GPU round trips, invalid values, sendability, and the unchanged 61-field `BeautyParameters` boundary.

## Task Commits

1. **Task 1: Add the public CPU/GPU configuration contract** - `db9858e` (feat)
2. **Task 2: Lock configuration compatibility and schema boundaries** - `d6f8c4c` (test)

**Plan metadata:** pending phase closeout metadata commit.

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` - Public backend enum and configuration field/default/decode path.
- `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` - Configuration and schema compatibility regressions.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyConfigurationTests` — **9 executed, 0 failures, 0 skips**.
- TDD RED compile gate failed as expected before implementation (`BeautyRenderBackend` and `renderBackend` absent), then GREEN focused suite passed.
- `git diff --check` — pass.

## Decisions Made

- Backend choice is an execution policy on `BeautyConfiguration`, not a beauty parameter, preset field, or renderer case.
- CPU is the compatibility default for both new construction and decoding payloads that predate the field.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The initial schema assertion encoded neutral `BeautyParameters()` and observed 60 keys because the optional `filterId` is omitted when nil. The test was corrected to use the existing non-nil inventory fixture pattern; the model remains unchanged.

## Known Stubs

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 73-02 to route public `.cpu` and `.gpu` configuration through immutable backend policies and typed fail-closed Metal construction.

## Self-Check: PASSED

- Summary file exists.
- Commits `d10ea3f`, `db9858e`, and `d6f8c4c` are present in git history.
- Focused configuration suite passes with nonzero execution and zero failures/skips.

---
*Phase: 73-public-backend-configuration-and-fail-closed-availability*
*Completed: 2026-08-17*
