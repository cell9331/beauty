---
phase: 70-backend-neutral-contract-and-cpu-reference
plan: "02"
subsystem: backend-contract
tags: [swiftpm, cpu-reference, backend-routing, static-gates, no-skip]

# Dependency graph
requires:
  - phase: 70-backend-neutral-contract-and-cpu-reference
    plan: "01"
    provides: package-only BeautyBackendRequest/Result/Diagnostics and executor contract
provides:
  - stateless BeautyCPUBackend implementation for the retained CPU renderer
  - one-dispatch BeautyEngine routing for still-image and pixel-buffer processResult families
  - mutation-tested backend-neutral contract preflight integrated into the archive-first gate
  - measured BACKEND-02 closeout and synchronized Phase 70 planning ledgers
affects: [71-metal-runtime, 72-metal-passes, 73-public-backend-configuration, 74-parity-closeout]

# Tech tracking
tech-stack:
  added: []
  patterns: [injected package executor seam, one terminal backend dispatch, mutation-tested static boundary]

key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Backend/BeautyCPUBackend.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyCPUBackendTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift
    - scripts/check-backend-neutral-contract.sh
  modified:
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - scripts/run-no-skip-swiftpm.sh
    - PLANS.md
    - .planning/PROJECT.md
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
    - .planning/STATE.md

key-decisions:
  - "Keep CPU as the sole package executor in Phase 70; public GPU selection and Metal behavior remain with their owning phases."
  - "Route both public processResult families through one injected/default executor call while retaining validation, canonicalization, detection, support, composition, and diagnostics ownership in BeautyEngine."
  - "Make the backend preflight fail closed on public schema, direct-dispatch, fallback, raw-diagnostic, dependency, or out-of-scope framework drift."

requirements-completed: [BACKEND-02]

# Metrics
duration: ~40min
completed: 2026-08-15
status: complete
---

# Phase 70 Plan 02: Backend-Neutral Contract and CPU Reference Summary

**Retained CPU rendering now executes through the package-only backend contract with one-dispatch routing and an archive-first mutation-tested validation gate.**

## Performance

- **Duration:** ~40 min
- **Started:** 2026-08-15T14:24:23+08:00
- **Completed:** 2026-08-15T14:43:08+08:00
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments

- Added stateless `BeautyCPUBackend` execution for canonical still-image and pixel-buffer requests, delegating final CPU rendering to the retained color pipeline and returning bounded aggregate diagnostics.
- Routed both `BeautyEngine.processResult` overload families through the shared request/result boundary exactly once, with a package-only executor injection seam for terminal-error and dispatch-count tests.
- Preserved engine-owned validation, canonicalization, detection/mapping, request-local support, composition ordering, alpha/extent/metadata behavior, and typed terminal failures without fallback.
- Added direct CPU backend and facade routing tests; the focused contract/CPU/routing aggregate executes 11 tests with zero failures.
- Added `check-backend-neutral-contract.sh` static and mutation self-tests for backend scope, public schema/preset/configuration stability, diagnostics privacy, direct pipeline dispatch, fallback, and dependency/UI/Metal drift.
- Bound the preflight into `run-no-skip-swiftpm.sh` after archive/boundary authorization and before consumer/oracle/opt-in/child stages.
- Updated project, requirements, roadmap, state, and plan ledgers with aggregate-only Phase 70 evidence; BACKEND-02 is now complete.

## Verification

- `bash scripts/check-backend-neutral-contract.sh --self-test` — pass.
- `bash scripts/check-backend-neutral-contract.sh` — pass; focused 11 tests and generated CPU preflight 41 tests, zero failures/skips.
- `bash scripts/run-no-skip-swiftpm.sh --self-test` — `NO-SKIP TRANSCRIPT SELF-TEST PASSED`.
- `bash scripts/run-no-skip-swiftpm.sh` — archive-first wrapper pass with all 8 opt-ins, zero skips, and zero failures.
- Full normal `swift test --package-path BeautySDK` — 713 executed, 0 failures, 8 environment-gated skips.
- `swift build --package-path BeautySDK` — pass.
- `rg` facade scan confirms no direct `BeautyColorEffectPipeline.apply` remains in `BeautySDK/Sources/BeautySDK`.
- `git diff --check` — pass.
- The plan's broad historical-ledger forbidden-term grep still finds pre-existing archived records in `PLANS.md` and older project history; the new Phase 70 ledger entry and all modified current-state fields contain no such terms, and no historical evidence was rewritten.

## Task Commits

Each implementation task was committed atomically:

1. **Task 1: Implement CPU execution and route the facade once** — `5e7c932` (feat)
2. **Task 2: Bind the fail-closed gate and record measured closeout** — `6d35396` (feat)

The planning summary and final state/roadmap/requirements metadata are committed separately after self-check.

## Compatibility and Scope

- `BeautyParameters`, public `BeautyConfiguration`, preset IDs, and algorithm inventory remain unchanged.
- The static gate confirms the existing 61 parameter fields, five preset IDs, and 74 renderer cases.
- Phase 70 adds no UI/Demo, device, network/model, dependency, public GPU selector, Metal implementation, or new algorithm behavior.
- Durable evidence is limited to bounded aggregate status and fixed identifiers; no raw image data, support, or private fixture details are recorded.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Narrowed diagnostics privacy scanning to the diagnostics declaration**
- **Found during:** Task 2
- **Issue:** The first static scan treated the legitimate aggregate `changedPixelCount` field as a raw-pixel diagnostic.
- **Fix:** Restrict the forbidden-field check to the `BeautyBackendDiagnostics` declaration and retain rejection of raw/mask/landmark/path/fixture fields.
- **Files modified:** `scripts/check-backend-neutral-contract.sh`
- **Verification:** Static live mode and mutation self-test pass.
- **Committed in:** `6d35396`

**2. [Rule 3 - Blocking] Corrected the mutation self-test edit target**
- **Found during:** Task 2
- **Issue:** The privacy mutation initially targeted a non-existent declaration spelling and did not exercise the intended contract rejection.
- **Fix:** Mutate the actual package aggregate field and assert that the static boundary rejects it.
- **Files modified:** `scripts/check-backend-neutral-contract.sh`
- **Verification:** `--self-test` passes all baseline and mutation cases.
- **Committed in:** `6d35396`

No architectural changes, package installs, or scope expansion were required.

## Known Stubs

None. The CPU executor delegates to the retained implementation and does not introduce placeholder output or empty data sources.

## Self-Check: PASSED

- Created source, test, gate, wrapper, and summary files exist.
- Task commits `5e7c932` and `6d35396` are present in Git history.
- Focused, generated, build, archive-first no-skip, self-test, and diff checks pass.
- Planning ledgers report BACKEND-01/BACKEND-02 without changing later Metal phase ownership.

---
*Phase: 70-backend-neutral-contract-and-cpu-reference*
*Completed: 2026-08-15*
