---
phase: 73-public-backend-configuration-and-fail-closed-availability
plan: 02
subsystem: sdk-backend-routing
tags: [swift, swiftpm, metal, cpu, fail-closed]

# Dependency graph
requires:
  - phase: 73-public-backend-configuration-and-fail-closed-availability
    provides: public BeautyConfiguration.renderBackend .cpu/.gpu contract
provides:
  - Package-only BeautyBackendFactory mapping configuration to one executor and immutable policy
  - Public BeautyEngine routing for CPU/GPU with typed terminal Metal construction errors
  - Request policy propagation across pixel-buffer, still-image, and legacy still-image routes
affects: [73-03 configuration gate, 73-04 owner docs, 74 parity]

# Tech tracking
tech-stack:
  added: []
  patterns: [closed configuration switch, package-only throwing Metal factory seam, explicit request policy]

key-files:
  created:
    - BeautySDK/Sources/BeautySDK/BeautyBackendFactory.swift
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift

key-decisions:
  - "GPU construction errors propagate unchanged; factory selection never retries or substitutes the CPU executor."
  - "The package-only injected executor seam remains test-only and derives request policy from the configured public backend."

patterns-established:
  - "BeautyEngine stores one backend executor and one immutable execution policy for its lifetime."
  - "Every backend request constructor receives the engine policy explicitly."

requirements-completed: [CONFIG-02]

# Metrics
duration: 3min
completed: 2026-08-17
---

# Phase 73 Plan 02: Fail-Closed Backend Routing Summary

**Public engine construction now selects CPU or Metal explicitly and propagates unavailable GPU construction without CPU fallback.**

## Performance

- **Duration:** ~3 min
- **Started:** 2026-08-17T09:42:00+08:00
- **Completed:** 2026-08-17T09:45:00+08:00
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added package-only `BeautyBackendFactory` with a closed `.cpu`/`.gpu` switch and a throwing Metal-construction seam for deterministic tests.
- Updated the public `BeautyEngine` initializer to construct the selected backend, retain an immutable policy, and propagate policy on all three request routes.
- Added routing, unavailable-host, public GPU integration, terminal-error, pixel-buffer, and interleaved request-isolation coverage.

## Task Commits

1. **Task 1: Implement immutable configuration-to-backend selection** - `6d0f202` (feat)
2. **Task 2: Prove routing, unavailable Metal, and request isolation** - `15c2766` (test)

**Plan metadata:** pending phase closeout metadata commit.

## Files Created/Modified

- `BeautySDK/Sources/BeautySDK/BeautyBackendFactory.swift` - Package-only executor/policy selection.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Public selection and explicit request policy propagation.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift` - Aggregate-only routing and fail-closed regressions.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineBackendRoutingTests` — **7 executed, 0 failures, 0 skips**.
- `swift build --package-path BeautySDK` — pass as part of focused test build.
- The live public GPU integration either rendered successfully or would accept only `.metalUnavailable`; this host rendered successfully.
- `git diff --check` — pass.

## Decisions Made

- The factory owns the only configuration-to-executor mapping and does not catch, translate, retry, or fall back after Metal construction errors.
- Injected executors remain package-only test seams; they cannot expand the public API or change the configured policy.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Made test factory counters Sendable-safe**
- **Found during:** Task 2 (routing tests)
- **Issue:** Swift 6 rejected mutation of a captured local counter in the package-only `@Sendable` Metal factory closure.
- **Fix:** Added an aggregate-only locked `@unchecked Sendable` counter helper for deterministic invocation assertions.
- **Files modified:** `BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift`
- **Verification:** Focused routing suite passed 7/0/0.
- **Committed in:** `15c2766`

**Total deviations:** 1 auto-fixed (Rule 3: 1).
**Impact on plan:** Required only for Swift 6 test correctness; no production scope expansion.

## Issues Encountered

None after the Sendable test fix.

## Known Stubs

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Ready for Plan 73-03 to mutation-test the public selector/default/no-fallback policy and integrate it into the archive-first no-skip wrapper.

## Self-Check: PASSED

- Summary file exists.
- Commits `a07dce6`, `6d0f202`, and `15c2766` are present in git history.
- Focused routing suite passes with nonzero execution and zero failures/skips.

---
*Phase: 73-public-backend-configuration-and-fail-closed-availability*
*Completed: 2026-08-17*
