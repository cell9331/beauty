---
phase: 67-swiftpm-consumer-and-cli-validation-contract
plan: "03"
subsystem: testing-and-tooling
tags: [swiftpm, foundation-process, cli, xctest, privacy]

# Dependency graph
requires:
  - phase: 67-swiftpm-consumer-and-cli-validation-contract
    provides: compiled BeautyExampleRenderer CLI contract, report schema, and executable-local failure seams
provides:
  - real Foundation Process coverage of the compiled BeautyExampleRenderer binary
  - deterministic 74-case, success/reproducibility, invalid-input/output, collision, and failure-seam matrix
  - bounded temporary fixture generation, process output capture, privacy assertions, and cleanup
affects: [phase-67-cli-validation-closeout, phase-68-cpu-algorithm-reference, phase-69-sdk-only-closeout]

# Tech tracking
tech-stack:
  added: [Foundation Process, XCTest, CoreGraphics/ImageIO synthetic fixtures]
  patterns: [compiled-binary-only process assertions, bounded pipe capture, reconciled report validation]

key-files:
  created:
    - BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift
    - .planning/phases/67-swiftpm-consumer-and-cli-validation-contract/67-03-SUMMARY.md
  modified: []

key-decisions:
  - "Build and resolve BeautyExampleRenderer in a unique temporary SwiftPM scratch root so the process test does not contend with the parent SwiftPM test lock or leave build products in the repository." 
  - "Keep all assertions at the executable boundary: tests decode independent report/diagnostic mirrors and never import or reimplement the CLI parser/execution types." 
  - "Drain stdout/stderr concurrently and enforce one-megabyte capture limits so build and renderer failures cannot deadlock the test harness." 

patterns-established:
  - "Generate opaque named-sRGB PNG/JPEG inputs locally, create output roots explicitly, and remove every fixture/build tree in teardown/defer."
  - "Treat report-write failure as a nonzero process result while preserving already credited output evidence and count reconciliation."

requirements-completed: [CLI-03]

# Metrics
duration: 12min
completed: 2026-08-14
---

# Phase 67 Plan 03: Compiled Renderer Process Validation Summary

**Foundation Process tests now prove the real SwiftPM-built BeautyExampleRenderer succeeds reproducibly and fails with typed, privacy-safe reconciled reports across the complete CLI-03 matrix.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-08-14T05:37:00Z
- **Completed:** 2026-08-14T05:49:22Z
- **Tasks:** 1
- **Files modified:** 1 (summary included separately)

## Accomplishments

- Added a Foundation `Process` test suite that builds `BeautyExampleRenderer` through SwiftPM, resolves the reported bin path, requires a regular executable, and invokes only that compiled binary.
- Covered byte-identical `--list-cases` discovery for the ordered 74-case inventory, two fresh-root neutral success runs, same-size non-empty PNGs, byte-identical reports, exact `1/1/0/0` reconciliation, and report/diagnostic privacy bounds.
- Covered unknown/missing/duplicate arguments, unknown and unsupported backends/cases, missing/empty/corrupt/duplicate-stem inputs, missing/file/symlink output roots, destination/report collisions, and exact typed nonzero diagnostics.
- Reached the executable-internal `render` and `encode` environment seams through the normal runner, asserting no PNG, typed stderr JSON, nonzero exit, and `1/0/1/0` reports for each.
- Generated all fixtures in temporary directories, bounded build/render execution to 120/30 seconds, capped each captured stream at 1 MiB, and removed build/fixture roots after the suite or each test.

## Task Commits

Each task was committed atomically:

1. **Task 1: Exercise the actual compiled renderer across success and deterministic failure matrices** - `3f93e45` (test)

## Files Created/Modified

- `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift` - Foundation Process matrix against the real compiled executable, generated image fixtures, report mirrors, timeout/capture bounds, and privacy assertions.

## Decisions Made

- Used an isolated temporary SwiftPM scratch path for the child build because the outer SwiftPM test process owns the package build lock; this preserves the required real build while avoiding lock contention.
- Used independent Codable mirrors for reports and diagnostics, preserving D-12's executable-only observation boundary.
- Drained process output concurrently before waiting for termination, preventing compiler output or child diagnostics from filling a pipe and blocking the bounded process test.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Avoided nested SwiftPM build-lock contention**

- **Found during:** Task 1 process-suite execution
- **Issue:** Invoking `swift build` against the parent test package's default `.build` path blocked while the enclosing SwiftPM test process held its build lock.
- **Fix:** Build and resolve the executable with a unique temporary `--scratch-path`, cache that executable for the class, and remove the scratch tree in class teardown.
- **Files modified:** `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift`
- **Verification:** Focused process suite builds and runs all 5 XCTest methods with 0 failures.
- **Committed in:** `3f93e45`

**2. [Rule 3 - Blocking] Drained child streams concurrently**

- **Found during:** Task 1 process-suite execution
- **Issue:** Waiting for a child before reading its pipes could deadlock a SwiftPM build or renderer that exceeded the pipe buffer.
- **Fix:** Read stdout and stderr on concurrent workers, enforce 1 MiB post-capture limits, and use a termination semaphore with timeout/termination handling.
- **Files modified:** `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift`
- **Verification:** SwiftPM build and all renderer invocations pass under the focused process matrix.
- **Committed in:** `3f93e45`

**3. [Rule 3 - Blocking] Resolved Swift 6 test concurrency diagnostics**

- **Found during:** Task 1 compile verification
- **Issue:** Cached executable/build-root state was rejected as unsynchronized mutable global state, and tuple equality was unavailable under the active Swift compiler mode.
- **Fix:** Isolated the test class to the main actor with lock-protected nonisolated cache state and asserted each report count independently.
- **Files modified:** `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift`
- **Verification:** `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyExampleRendererProcessTests` passed 5/5.
- **Committed in:** `3f93e45`

---

**Total deviations:** 3 auto-fixed (Rule 3: 3 blocking issues)
**Impact on plan:** All fixes were required to execute the real binary safely under SwiftPM/XCTest; no public API, parser, GPU/Metal, UI/Demo, fixture-media, or repository-boundary scope was added.

## Issues Encountered

- The first implementation used a relative `swift` executable URL; the test now resolves tool names through `PATH` before launching Foundation `Process`.
- Report-write collisions legitimately retain prior successful stdout/output evidence; the assertion allows stdout for that case while requiring the typed nonzero report-write diagnostic.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- CLI-03 has direct compiled-process evidence and is ready for Phase 67 Plan 04's current-owner/no-skip closeout.
- The suite does not expose the failure seam through public SDK, flags, help, case-list, reports, or diagnostics; v1.17 Metal/backend work remains untouched.

## Verification

- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyExampleRendererProcessTests` - passed 5/5 with 0 failures and 0 skips.
- Real child `swift build --package-path BeautySDK --product BeautyExampleRenderer` and `--show-bin-path` - passed inside the test's temporary scratch root.
- `git diff --check` - passed.
- Generated input/output/report/build trees were temporary and removed by test defer/class teardown; no tracked media or persistent transcript was created.

## Self-Check: PASSED

- `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift` exists as a regular file.
- Task commit `3f93e45` exists in repository history.
- No generated fixture, PNG, report, or temporary build artifact is tracked under the repository.
- Stub scan found no placeholder/TODO/empty UI data source in the created test or summary.
- Threat scan found no new production trust boundary; the test only exercises the already-planned executable-local seam and validates its redaction.

---
*Phase: 67-swiftpm-consumer-and-cli-validation-contract*
*Completed: 2026-08-14*
