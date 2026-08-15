---
phase: 67-swiftpm-consumer-and-cli-validation-contract
plan: "02"
subsystem: testing-and-tooling
tags: [swiftpm, cli, renderer, json-report, privacy]

# Dependency graph
requires:
  - phase: 67-swiftpm-consumer-and-cli-validation-contract
    provides: independent public BeautySDK SwiftPM consumer and SDK-only validation boundary
provides:
  - strict CPU-only BeautyExampleRenderer argument and discovery contract
  - complete persisted PNG matrix with reopen/dimension validation and reconciled report
  - executable-internal render/encode failure injection seams for process validation
affects: [phase-67-cli-process-tests, phase-68-cpu-algorithm-reference, phase-69-sdk-only-closeout]

# Tech tracking
tech-stack:
  added: [Foundation JSONEncoder, ImageIO persisted-output validation]
  patterns: [sorted-key versioned envelopes, typed aggregate diagnostics, atomic output/report writes]

key-files:
  created:
    - BeautySDK/Sources/BeautyExampleRenderer/RendererCLIContract.swift
    - BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift
    - .planning/phases/67-swiftpm-consumer-and-cli-validation-contract/67-02-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautyExampleRenderer/main.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift

key-decisions:
  - "The renderer accepts only the internal CPU CLI token and does not add a public BeautySDK backend type or Metal path."
  - "Reports contain only sorted bounded input/case/output identities and aggregate status counts; diagnostics are fixed JSON codes without framework errors or paths."
  - "Output roots must already be regular non-symlink directories; every credited PNG is atomically written, reopened, decoded, and dimension checked before success."

patterns-established:
  - "Keep the exact 74-case catalog in main.swift while routing all execution through the real executable runner."
  - "Use process-local executable-only seams for nondeterministic render/encode failures without exposing them through flags, reports, or BeautySDK."

requirements-completed: [CLI-01, CLI-02]

# Metrics
duration: 12min
completed: 2026-08-14
---

# Phase 67 Plan 02: SwiftPM Consumer and CLI Validation Contract Summary

**BeautyExampleRenderer now provides a strict CPU-only 74-case CLI with explicit output validation, deterministic JSON discovery/reporting, and reconciled persisted-result semantics.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-08-14T05:24:00Z
- **Completed:** 2026-08-14T05:36:26Z
- **Tasks:** 2
- **Files modified:** 5 (2 created, 2 modified, summary included separately)

## Accomplishments

- Preserved the exact ordered 74-case public-facade catalog while replacing the old permissive top-level argument handling with strict `--input`, `--output`, `--case`, `--backend cpu`, `--no-watermark`, `--list-cases`, and `--help` handling. Repeated scalar flags, unknown flags/cases, missing values, and unsupported backends produce stable typed JSON diagnostics.
- Added versioned sorted-key case-list, diagnostic, and aggregate report contracts. Reports reconcile requested/succeeded/failed/skipped units and expose only normalized relative input labels, existing case IDs, and output basenames.
- Factored matrix execution into the executable target: recursive supported-image discovery, duplicate-stem preflight, one public `BeautyEngine.processResult` loop, named-sRGB rendering, optional watermarking, atomic PNG writes, ImageIO reopen/dimension checks, and atomic report persistence. Explicit output roots are never created implicitly and symlink/file roots fail closed.
- Added an undocumented, exact-valued executable-local environment seam that drives the real post-process render and pre-write encode failure branches, with the same report/count/diagnostic path and no public SDK or Metal/backend API changes.
- Updated renderer regression coverage to inspect all executable-target Swift sources, retain the 74-case and named-sRGB contracts, enforce duplicate-stem ordering/no implicit output creation, and verify the failure seam stays outside public `BeautySDK` and help/report surfaces.

## Task Commits

Each task was committed atomically:

1. **Task 1: Define deterministic CLI, diagnostic, and report contracts** - `0e9d40e` (feat)
2. **Task 2: Execute, persist, re-open, and reconcile the requested matrix** - `6b8909b` (feat)

## Files Created/Modified

- `BeautySDK/Sources/BeautyExampleRenderer/RendererCLIContract.swift` - strict command parser, typed diagnostics, case-list and report Codable envelopes.
- `BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift` - public-facade matrix execution, atomic writes, output reopening, report finalization, and internal failure seam.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - unchanged 74 `RenderCase` values with a thin executable entry point.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - all-target-source contract loading and renderer boundary regressions.

## Decisions Made

- Kept backend selection as an executable-only string contract (`cpu`) so v1.16 establishes CLI compatibility without adding `BeautyConfiguration.renderBackend`, `BeautyRenderBackend`, Metal code, or GPU fallback behavior.
- Used fixed schema versions and JSONEncoder sorted keys for deterministic case discovery, diagnostics, and reports; no timestamps, durations, framework text, geometry, pixel data, masks, landmarks, or private fixture metadata are persisted.
- Counted a unit as succeeded only after its output is regular, non-empty, decodable, and exactly input-sized; failed and skipped units remain explicit so report counts always reconcile.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Corrected compile blockers while factoring the executable**
- **Found during:** Task 1 and Task 2 build verification
- **Issue:** The first factored implementation had an incomplete diagnostic getter and a non-exiting guard around matrix finalization.
- **Fix:** Made the diagnostic enum exhaustive and changed finalization bookkeeping to an explicit conditional.
- **Files modified:** `BeautySDK/Sources/BeautyExampleRenderer/RendererCLIContract.swift`, `BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift`
- **Verification:** `swift build --package-path BeautySDK --product BeautyExampleRenderer` passed.
- **Committed in:** `0e9d40e`, `6b8909b`

**2. [Rule 1 - Bug] Preserved typed render failures from public-facade exceptions**
- **Found during:** Task 2 execution-path review
- **Issue:** An organic `BeautyEngine.processResult` throw would have fallen through the generic write-error handler and been reported as `output_write_failed`.
- **Fix:** Scoped the public process call and mapped its failure to `render_failed` before output creation.
- **Files modified:** `BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift`
- **Verification:** focused regression suite, renderer build, and injected render/encode process smoke checks passed.
- **Committed in:** `6b8909b`

**3. [Rule 2 - Missing Critical] Distinguished existing file output roots from nonexistent roots**
- **Found during:** Task 2 output-boundary review
- **Issue:** A regular file passed through the same non-directory branch as a missing path, violating the required `output_directory_invalid` distinction.
- **Fix:** Existing non-directory paths now return `output_directory_invalid`; only absent paths return `output_directory_missing`.
- **Files modified:** `BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift`
- **Verification:** explicit file and symlink output-root probes returned nonzero `output_directory_invalid`; nonexistent roots returned `output_directory_missing` and were not created.
- **Committed in:** `6b8909b`

---

**Total deviations:** 3 auto-fixed (Rule 1: 1 bug; Rule 2: 1 missing critical distinction; Rule 3: 1 blocking compile issue).
**Impact on plan:** All fixes were directly required for the stated typed-failure and build contracts; no public API, UI/Demo, Metal/GPU, or package boundary scope was added.

## Issues Encountered

- `gsd-tools` was not on PATH; the repository-installed Node shim at `/Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs` was used for planning-state inspection. No state mutation was attempted through the unavailable shell alias.
- No authentication gate, package installation, external service, UI/Demo, simulator/device, or Metal/GPU work was required.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The compiled executable is ready for Plan 67-03 Foundation `Process` tests to cover reproducibility, invalid matrices, duplicate scalar arguments, report collisions, and the internal render/encode seams.
- The runner remains SDK-only and uses only the public `BeautySDK` product; generated output/report files are caller-owned under explicit roots and no tracked fixture was added.

## Verification

- `swift build --package-path BeautySDK --product BeautyExampleRenderer` - passed.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` - passed, 24/24.
- Real binary `--list-cases` JSON - passed exact `beauty.example-renderer.cases.v1`, ordered unique 74 IDs, first `skinSmoothing_0p50`, last `scleraRednessReduction_1p00`.
- Real binary neutral temporary input/output smoke - passed versioned report with `1/1/0/0`, decodable same-size PNG, and bounded identities.
- Real binary injected `render` and `encode` temporary smoke - passed typed stderr codes, nonzero exits, no requested PNG, and reconciled `1/0/1/0` reports.
- Explicit nonexistent/file/symlink output-root probes - passed typed nonzero diagnostics without implicit directory creation.
- `git diff --check` - passed.

## Self-Check: PASSED

- All planned source/test files exist as regular files.
- Task commits `0e9d40e` and `6b8909b` exist in repository history.
- No generated input, PNG, report, or temporary fixture artifact was created under the repository source/test tree.

---
*Phase: 67-swiftpm-consumer-and-cli-validation-contract*
*Completed: 2026-08-14*
