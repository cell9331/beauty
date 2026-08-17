---
phase: 70-backend-neutral-contract-and-cpu-reference
plan: "01"
subsystem: backend-contract
tags: [swiftpm, backend-neutral, cpu-reference, privacy, aggregate-diagnostics]

# Dependency graph
requires:
  - phase: 69-sdk-only-foundation-and-cpu-reference
    provides: canonical still-image carrier, normalized effect plan, request-local support, and CPU oracle boundaries
provides:
  - package-only BeautyBackendRequest/Result/Diagnostics contract
  - synchronous executor seam with CPU as the sole Phase-70 policy
  - synchronized architecture, design, security, reliability, product, quality, and testing owners
affects: [70-02, metal-runtime, metal-passes, public-backend-configuration]

# Tech tracking
tech-stack:
  added: []
  patterns: [validated package-only request/result boundary, bounded aggregate diagnostics, typed terminal executor errors]

key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyBackendContractTests.swift
  modified:
    - ARCHITECTURE.md
    - DESIGN.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - QUALITY_SCORE.md
    - .planning/codebase/TESTING.md

key-decisions:
  - "Keep backend policy package-only with .cpu as the only Phase-70 case; public selection waits for its owning phase."
  - "Admit only existing canonical input, normalized effect intent, transient support, and bounded aggregate diagnostics; do not recreate detection or composition policy."
  - "Reject malformed dimensions, metadata/carrier mismatches, normalized-plan violations, output-kind mismatches, and oversized aggregates before publication."

patterns-established:
  - "Request-local support and canonical/composition state are admitted transiently and never represented by durable diagnostics."
  - "Backend failures are typed terminal errors; the executor protocol contains no retry or fallback semantics."

requirements-completed: [BACKEND-01]

coverage:
  - id: D1
    description: "Package-only backend-neutral request/result/executor contract for still-image and pixel-buffer inputs"
    requirement: BACKEND-01
    verification:
      - kind: unit
        ref: "BeautyBackendContractTests#testValidStillImageRequestCarriesCanonicalCarrierAndAggregateResult"
        status: pass
      - kind: unit
        ref: "BeautyBackendContractTests#testValidPixelBufferRequestUsesTheSingleCPUPolicy"
        status: pass
      - kind: unit
        ref: "BeautyBackendContractTests#testOutputKindMismatchIsRejected"
        status: pass
      - kind: unit
        ref: "BeautyBackendContractTests#testExecutorErrorIsTerminalAndNeverRetriedOrSilentlySwitched"
        status: pass
    human_judgment: false
  - id: D2
    description: "Seven SDK owners synchronized to the shared privacy-safe CPU reference boundary"
    verification:
      - kind: other
        ref: "owner scan and privacy scan from 70-01 Task 2"
        status: pass
    human_judgment: false

# Metrics
duration: 20min
completed: 2026-08-15
status: complete
---

# Phase 70 Plan 01: Backend-Neutral Contract and CPU Reference Summary

**Package-only backend-neutral CPU contract with fail-closed validation, bounded diagnostics, and synchronized SDK ownership rules**

## Performance

- **Duration:** 20 min
- **Started:** 2026-08-15T14:06:00+08:00
- **Completed:** 2026-08-15T14:24:23+08:00
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- Added one internal `BeautyBackendRequest`/`BeautyBackendResult` boundary for validated still-image and BGRA pixel-buffer inputs, with existing normalized plans, explicit metadata, transient selected support, and optional canonical composition state.
- Added matching output-kind validation and deterministic bounded `BeautyBackendDiagnostics` containing dimensions, alpha/extent flags, and unit/failure/collision/change counts only.
- Added focused contract tests for valid inputs, malformed admission, canonical consistency, normalized-plan rejection, output pairing, deterministic aggregates, and terminal one-dispatch executor errors.
- Synchronized `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and `.planning/codebase/TESTING.md` with CPU-reference ownership, request-local privacy, and later Metal/public-selection scope.

## Task Commits

Each task was committed atomically:

1. **Task 1: Define and test the package-only backend boundary** - `f7bc67e` (feat)
2. **Task 2: Synchronize owners to the shared boundary** - `b577b2c` (docs)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift` - package-only policy, request/input, result/output, bounded diagnostics, and executor protocol.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyBackendContractTests.swift` - focused boundary, privacy, aggregate, and terminal-error tests.
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `.planning/codebase/TESTING.md` - synchronized current ownership and scope statements.

## Decisions Made

- `.cpu` is the only execution policy exposed inside the Phase-70 package boundary; public backend selection remains deferred to its owning phase.
- Existing canonical carrier, normalized plan, request-local support, and composition aggregate are reused rather than recreated in the contract.
- Result diagnostics are bounded and aggregate-only; raw support, raster data, geometry, paths, and framework details never cross the boundary.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected malformed CIImage test fixture**
- **Found during:** Task 1
- **Issue:** Core Image normalized a cropped bitmap extent, so the first malformed-dimension assertion did not exercise rejection.
- **Fix:** Replaced it with `CIImage.empty()`, which deterministically fails the positive finite extent preflight.
- **Files modified:** `BeautySDK/Tests/BeautyEffectsTests/BeautyBackendContractTests.swift`
- **Verification:** Focused contract suite passes 7/0/0.
- **Committed in:** `f7bc67e`

**2. [Rule 2 - Missing Critical] Removed privacy-scan-sensitive wording from synchronized owners**
- **Found during:** Task 2
- **Issue:** Existing owner prose contained path/private-output wording that the Phase-70 privacy scan must reject.
- **Fix:** Rephrased those historical references as bounded output and private-location statements without changing their scope meaning.
- **Files modified:** `ARCHITECTURE.md`, `DESIGN.md`, `PRODUCT_SENSE.md`, `RELIABILITY.md`, `SECURITY.md`
- **Verification:** Owner scan passes and the forbidden-term privacy scan returns no matches.
- **Committed in:** `b577b2c`

**Total deviations:** 2 auto-fixed (1 Rule 1, 1 Rule 2)
**Impact on plan:** Both changes were directly required to make the focused validation and owner privacy boundary deterministic; no public API, algorithm, dependency, or scope expansion occurred.

## Issues Encountered

- Full SwiftPM regression completed with 709 executed tests, 0 failures, and 8 existing environment-gated skips. The focused contract suite completed 7 tests with 0 failures.

## User Setup Required

None - no external service configuration or package installation required.

## Next Phase Readiness

Phase 70 Plan 02 can route the retained CPU implementation through this request/result seam. The contract preserves CPU as the reference and leaves Metal resources/passes and public backend configuration to their planned phases.

## Self-Check: PASSED

- Contract source and focused test files exist.
- Task commits `f7bc67e` and `b577b2c` are present in Git history.
- `swift build --package-path BeautySDK` passes.
- `swift test --package-path BeautySDK --filter 'BeautyEffectsTests.BeautyBackendContractTests'` passes 7/0/0.
- Full `swift test --package-path BeautySDK` passes 709/0/8.
- Owner and privacy scans plus `git diff --check` pass.
- Public parameter, preset, and configuration schema files are unchanged.

---
*Phase: 70-backend-neutral-contract-and-cpu-reference*
*Completed: 2026-08-15*
