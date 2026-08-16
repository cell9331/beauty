---
phase: 71-sdk-owned-metal-runtime
plan: "03"
subsystem: testing
tags: [swiftpm, metal, preflight, sdk-boundary, privacy]

# Dependency graph
requires:
  - phase: 71-sdk-owned-metal-runtime
    provides: package-internal BeautyMetalRuntime resource transaction and BeautyMetalBackend identity executor
  - phase: 70-backend-neutral-contract-and-cpu-reference
    provides: backend-neutral request/result boundary and retained CPU reference
provides:
  - mutation-tested static and focused SwiftPM Metal runtime preflight
  - archive-first no-skip wrapper ordering for internal Metal validation
  - synchronized current and codebase owner contracts for Phase 71 runtime mechanics
affects: [71-04, 72-metal-feature-passes, 73-public-backend-configuration, 74-parity-closeout]

# Tech tracking
tech-stack:
  added: []
  patterns: [bounded temporary preflight logs, explicit metal availability classification, package-target ownership mutation tests]

key-files:
  created:
    - scripts/check-metal-runtime.sh
    - .planning/phases/71-sdk-owned-metal-runtime/71-03-SUMMARY.md
  modified:
    - scripts/run-no-skip-swiftpm.sh
    - ARCHITECTURE.md
    - DESIGN.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - QUALITY_SCORE.md
    - .planning/codebase/ARCHITECTURE.md
    - .planning/codebase/STACK.md
    - .planning/codebase/TESTING.md

key-decisions:
  - "Keep the Metal preflight package-owned and aggregate-only: host availability is reported separately and never treated as GPU success."
  - "Run the preflight once after archive/boundary and Phase-70 authorization, before consumer, CPU-oracle, opt-in, and full-child stages."
  - "Keep public backend selection and feature parity in their Phase 73 and Phase 74 owners while CPU remains the reference."

patterns-established:
  - "Static source ownership checks pair regular-file, target, shader-inventory, schema, dependency, privacy, and cleanup assertions with focused tests."
  - "Mutation self-tests prove that cleanup removal, public schema drift, alternate execution, private diagnostics, and target movement fail closed."

requirements-completed: [METAL-01]

# Metrics
duration: ~40min
completed: 2026-08-16
---

# Phase 71 Plan 03: SDK-Owned Metal Runtime Summary

**Mutation-tested SDK-owned Metal runtime preflight with explicit unavailable-host accounting, archive-first no-skip ordering, and synchronized Phase 71 ownership contracts.**

## Performance

- **Duration:** ~40 min
- **Started:** 2026-08-16T07:44:00Z
- **Completed:** 2026-08-16T08:30:00Z
- **Tasks:** 2
- **Files modified:** 11 (1 created preflight, 1 wrapper, 9 owner documents)

## Accomplishments

- Added `scripts/check-metal-runtime.sh` with regular-file/target ownership checks, authorized `Warp.metal` inventory, bounded dimension/byte/resource checks, cleanup/synchronization markers, schema/dependency/privacy scans, and mutation self-tests.
- Focused runtime/backend plus existing backend contract/CPU routing tests execute 26/0/0 on the available host; live output reports `metal_available=1` and `metal_unavailable=0` as separate aggregate fields.
- Wired the preflight once into `run-no-skip-swiftpm.sh` after archive/boundary and Phase-70 authorization, before consumer, CPU oracle, opt-ins, and the full child.
- Updated architecture, design, security, reliability, product, quality, and codebase maps to describe package-internal ownership, exact resource lifecycle, `.metalUnavailable`, privacy-safe evidence, and Phase 72/73/74 handoffs.

## Task Commits

Each implementation task was committed atomically:

1. **Task 1: Add the mutation-tested Metal runtime preflight and gate wiring** - `41405b1` (feat)
2. **Task 2: Synchronize current owners to the Phase 71 contract** - `ffb0bc2` (docs)
3. **Task verification correction: satisfy Metal owner evidence markers** - `c1d9f9f` (fix)

**Plan metadata:** pending final metadata commit.

## Files Created/Modified

- `scripts/check-metal-runtime.sh` - bounded static/runtime Metal preflight, explicit availability fields, focused accounting, and mutation self-tests.
- `scripts/run-no-skip-swiftpm.sh` - mandatory preflight invocation before later no-skip stages.
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` - current Phase 71 runtime, privacy, reliability, acceptance, and evidence owners.
- `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STACK.md`, `.planning/codebase/TESTING.md` - codebase ownership, framework stack, and focused test/order maps.

## Decisions Made

- Metal availability is an explicit aggregate classification; unavailable hosts never lend success to GPU behavior or parity.
- The runtime remains package-internal and identity-only; no public selector, new algorithm, UI/Demo lifecycle, or device claim is introduced.
- CPU remains the reference; Phase 72 owns feature passes, Phase 73 owns public `.cpu`/`.gpu` configuration, and Phase 74 owns generated parity/no-skip closeout.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected focused-test aggregate parsing and cleanup assertion**
- **Found during:** Task 1 (Add the mutation-tested Metal runtime preflight and gate wiring)
- **Issue:** The initial preflight parser treated the two capture groups as one integer, and its first cleanup threshold did not match the runtime's three explicit paired defers.
- **Fix:** Parse `(executed, failures)` tuples explicitly and assert the runtime's three required paired cleanup markers; retain mutation rejection after each correction.
- **Files modified:** `scripts/check-metal-runtime.sh`
- **Verification:** `bash scripts/check-metal-runtime.sh --self-test` and normal mode pass with 26 tests, zero failures, and zero skips.
- **Committed in:** `41405b1`

---

**2. [Rule 3 - Blocking] Added exact owner evidence markers required by plan artifact validation**
- **Found during:** Post-task artifact verification
- **Issue:** The owner text described the command queue across a line break and used a title-case `Metal Runtime` marker, so the plan's literal artifact checks could not match the intended contract.
- **Fix:** Made the command queue lifecycle phrase contiguous and normalized the quality-owner marker without changing semantics.
- **Files modified:** `RELIABILITY.md`, `QUALITY_SCORE.md`
- **Verification:** `gsd-tools verify artifacts` passes all 11 artifacts; boundary/privacy scans and `git diff --check` pass.
- **Committed in:** `c1d9f9f`

---

**Total deviations:** 2 auto-fixed (1 Rule 1, 1 Rule 3)
**Impact on plan:** The corrections were confined to gate/parser and owner-evidence wording; they strengthened fail-closed accounting and artifact validation without changing architecture, dependency, public API, algorithm, UI, or device scope.

## Issues Encountered

- None requiring user action. The full archive-first no-skip child remains reserved for the Phase 71 closeout plan as specified.

## User Setup Required

None - no external service configuration or package installation required.

## Next Phase Readiness

Plan 71-04 can consume a mutation-tested, archive-authorized runtime preflight and synchronized owner contracts. The implementation remains an internal identity transaction with CPU reference semantics; feature passes, public backend configuration, generated parity, device/performance, commercial, packaging, shipping, launch, and release-readiness claims remain with their owning later plans.

## Known Stubs

None. The retained identity shader is an intentional Phase 71 resource/lifecycle probe; no new placeholder output or empty UI data source was introduced.

## Self-Check: PASSED

- Summary and all listed implementation/owner files exist.
- Task commits `41405b1`, `ffb0bc2`, and `c1d9f9f` are present in Git history.
- Metal self-test/live preflight, wrapper self-test, post-archive boundary, owner privacy scan, and `git diff --check` pass.

---
*Phase: 71-sdk-owned-metal-runtime*
*Completed: 2026-08-16*
