---
phase: 69-public-concurrency-repair-and-sdk-only-closeout
plan: 01
subsystem: testing
tags: [swiftpm, swift6, sendable, concurrency, xctest]

# Dependency graph
requires:
  - phase: 68-cpu-algorithm-reference-oracles
    provides: SDK-only SwiftPM validation boundary and aggregate-only test conventions
provides:
  - Conditional public Sendable conformance for BeautyResult payloads
  - Public compile-time and runtime concurrency coverage
affects: [69-02, 69-03, 69-04, sdk-boundary, closeout]

# Tech tracking
tech-stack:
  added: []
  patterns: [conditional generic Sendable conformance, detached task transfer assertions]

key-files:
  created:
    - BeautySDK/Tests/BeautySDKTests/BeautyResultConcurrencyTests.swift
  modified:
    - BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift

key-decisions:
  - "Use an equivalent conditional conformance extension so non-Sendable framework-backed result specializations remain source-compatible."
  - "Keep the negative non-Sendable case in a passing public test and reserve compile-failing mutation evidence for the boundary gate."

patterns-established:
  - "Only BeautyResult values whose Output is Sendable satisfy generic Sendable requirements."
  - "Concurrency evidence asserts fixed payload values and aggregate public fields without durable raw data."

requirements-completed: [CONC-01, CONC-02]

# Metrics
duration: 6m
completed: 2026-08-14
---

# Phase 69 Plan 01: Conditional BeautyResult Sendability Summary

**Conditional `BeautyResult` sendability with lossless public task-hop coverage and unchanged ordinary construction.**

## Performance

- **Duration:** 6 minutes (approximate)
- **Started:** 2026-08-14T09:04:00Z (approximate)
- **Completed:** 2026-08-14T09:10:04Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Removed the unconditional arbitrary-payload `@unchecked Sendable` promise and added `Sendable` only when `Output: Sendable`.
- Preserved four public result fields, initializer labels/defaults, and non-Sendable framework-backed result specializations.
- Added public-only XCTest coverage for generic Sendable compilation, detached task transfer, every result field, string source compatibility, and a deliberately non-Sendable payload.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace unconditional generic sendability with the conditional public contract** - `0ba5996` (fix)
2. **Task 2: Add public compile-time and runtime concurrency coverage** - `4fd5efb` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` - Public generic result with conditional `Sendable` conformance.
- `BeautySDK/Tests/BeautySDKTests/BeautyResultConcurrencyTests.swift` - Public compile-time and async runtime concurrency contract tests.

## Decisions Made

- Used a conditional conformance extension rather than constraining the primary generic declaration, because Swift 6 otherwise rejects existing `BeautyResult<CIImage>` and `BeautyResult<CVPixelBuffer>` API specializations even though those results are intentionally not Sendable.
- Kept the non-Sendable negative as a compile-contract observation; the later boundary mutation test owns the intentionally rejected source variant.

## Deviations from Plan

None - the extension form is the equivalent conditional declaration permitted by the plan and preserves the existing public API surface.

## Issues Encountered

- A first build with a constrained primary declaration surfaced Swift 6 errors for existing Core Image/Core Video result APIs. Switching to an equivalent constrained extension resolved the issue without changing production API shape.

## Verification

- `swift build --package-path BeautySDK` — passed.
- `swift test --package-path BeautySDK --filter 'BeautySDKTests.BeautyResultConcurrencyTests'` — 3 passed, 0 failures.
- `swift test --package-path BeautySDK --filter 'BeautySDKTests.BeautySDKFacadeTests|BeautyCoreTests.BeautyResultDetectionSummaryTests'` — 9 passed, 0 failures.
- Source guard rejects unconditional generic `@unchecked Sendable` — passed.
- `git diff --check` — passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 69-02 can add the mutation-tested static negative guard and closeout ordering. No UI/Demo, Metal/GPU, device, or release scope was introduced.

---
*Phase: 69-public-concurrency-repair-and-sdk-only-closeout*
*Completed: 2026-08-14*

## Self-Check: PASSED

- Summary file exists at the planned path.
- Task commits `0ba5996` and `4fd5efb` are present in git history.
- Build, focused compatibility/concurrency tests, source guard, and `git diff --check` passed.
