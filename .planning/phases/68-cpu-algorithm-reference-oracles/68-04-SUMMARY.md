---
phase: 68-cpu-algorithm-reference-oracles
plan: 04
subsystem: testing
tags: [swiftpm, cpu, xctest, generated-fixtures, privacy, no-skip]

# Dependency graph
requires:
  - phase: 68-cpu-algorithm-reference-oracles
    provides: Generated fixture, geometry/color, local-retouch, and determinism oracle suites from Plans 68-01 through 68-03.
provides:
  - Fail-closed generated-only CPU oracle preflight and mandatory gate ordering.
  - Synchronized SDK-only privacy, reliability, architecture, quality, testing, project, roadmap, state, and plan ledgers.
  - Aggregate Phase 68 evidence: 10 fixture/facade, 10 geometry/color, and 15 local-retouch/determinism tests after review hardening; the full no-skip count remains a main-worktree closeout gate because this isolated fixer worktree has no ignored private bundles.
affects: [phase-69, v1.17-metal-planning, cpu-reference-oracles]

# Tech tracking
tech-stack:
  added: []
  patterns: [bounded aggregate-only shell preflight, generated-source static boundary, archive-boundary-consumer-oracle ordering]

key-files:
  created:
    - scripts/check-cpu-reference-oracles.sh
  modified:
    - scripts/run-no-skip-swiftpm.sh
    - BeautySDK/Tests/BeautyEffectsTests/CPUReferenceLocalRetouchOracleTests.swift
    - ARCHITECTURE.md
    - SECURITY.md
    - RELIABILITY.md
    - QUALITY_SCORE.md
    - .planning/codebase/TESTING.md
    - PLANS.md
    - .planning/PROJECT.md
    - .planning/ROADMAP.md
    - .planning/STATE.md

key-decisions:
  - "Run generated CPU oracle filters after the public consumer and before private/native-Vision opt-ins and the single full SwiftPM child."
  - "Keep optional portrait/native-Vision evidence explicitly environment-gated and non-authoritative for generated CPU success."
  - "Persist only aggregate test counts and CPU-only/non-release boundaries; raw fixture bytes, support, paths, masks, and transcripts remain transient."

patterns-established:
  - "Static preflight requires nine regular CPUReference Swift sources under BeautySDK test targets and rejects media reads, output writes, locators, raw printing, and GPU/backend drift."
  - "Bounded focused child logs are temporary and reduced to nonzero execution counts with zero failures/skips."

requirements-completed: [CPU-05]

# Metrics
duration: 20min
completed: 2026-08-14
---

# Phase 68 Plan 04: Generated CPU Oracle Preflight and Owner Closeout Summary

**A fail-closed generated CPU oracle preflight now protects the mandatory SwiftPM gate and synchronizes the measured SDK-only reference boundary.**

## Performance

- **Duration:** 20 minutes
- **Started:** 2026-08-14T07:30:00Z (approximate)
- **Completed:** 2026-08-14T07:50:35Z
- **Tasks:** 3
- **Files modified:** 12 (1 created, 11 modified)

## Accomplishments

- Added `check-cpu-reference-oracles.sh` with static generated-source/privacy/CPU-only checks, explicit native fixture guard checks, bounded focused execution, a mutation self-test, and aggregate-only markers.
- Wired the preflight into `run-no-skip-swiftpm.sh` after archive/boundary/consumer checks and before private opt-ins and the one-child SwiftPM run.
- Review remediation measured the generated focused totals at 10/10/15. The prior implementation closeout recorded 691/0/0; the full 693-test post-fix count must be rerun from the main worktree where ignored private bundles are available.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add generated-only CPU oracle preflight to the mandatory gate** - `466add4` (test)
2. **Task 2: Synchronize CPU oracle owner and testing contracts** - `d046df7` (docs)
3. **Task 3: Record Phase 68 aggregate ledger and state transition evidence** - `c5ee3db` (docs)

Additional rule-driven fix: `40ae082` (fix) keeps the generated sibling-isolation assertion aggregate-only so the existing private proposal-exposure inventory remains exact.

## Files Created/Modified

- `scripts/check-cpu-reference-oracles.sh` - Static boundary, optional-guard, bounded focused-suite, and mutation self-test gate.
- `scripts/run-no-skip-swiftpm.sh` - Mandatory generated CPU preflight ordering.
- `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceLocalRetouchOracleTests.swift` - Aggregate-only sibling assertion after existing privacy scanner collision.
- `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, `QUALITY_SCORE.md` - Current CPU reference, trust, ordering, privacy, and measured quality contracts.
- `.planning/codebase/TESTING.md` - Generated suite inventory and optional-fixture separation.
- `PLANS.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` - Phase 68 aggregate ledger and independent-verification handoff.

## Decisions Made

- Generated evidence is the mandatory CPU reference; private/native-Vision evidence is optional and cannot satisfy generated requirements through skips.
- Preflight output is bounded and aggregate-only, while all raw SwiftPM output and fixture data remain transient.
- The current CPU/Core Image behavior remains the sole reference and no Metal/GPU/backend, UI/Demo, device, packaging, shipping, launch, or release-readiness scope is introduced.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed a private proposal-field reference from the generated oracle**
- **Found during:** Task 1 full mandatory no-skip verification
- **Issue:** The existing adversarial privacy test maintains an exact source inventory for the internal proposal field; the new generated local-retouch test referenced that field and caused the 691-test child to fail despite the focused oracle tests passing.
- **Fix:** Replaced the direct field assertion with an aggregate accepted-eye count assertion; sibling isolation remains covered without expanding durable/private exposure inventory.
- **Files modified:** `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceLocalRetouchOracleTests.swift`
- **Verification:** Focused adversarial/local-retouch run passed 13/13; final `scripts/run-no-skip-swiftpm.sh` passed 691/691 with zero failures/skips.
- **Committed in:** `40ae082`

**2. [Review remediation] Closed fail-open CPU oracle coverage and rendering guards**
- **Found during:** Phase 68 deep code review
- **Issue:** The preflight accepted partial focused suites, cross-file native fixture guards, and implicit Core Image rendering; malformed geometry, signed colors, malformed RGBA carriers, and output color-space metadata also lacked strict assertions.
- **Fix:** Require exact parsed aggregate counts and suite identities with mutation self-tests, validate each native fixture independently, force software Core Image contexts, require malformed support to abstain with unchanged bytes, test both signed directions, throw on malformed metric carriers, and inspect output color-space metadata.
- **Verification:** CPU fixture/facade 10/10, geometry/color 10/10, local/determinism 15/15, preflight self-test and normal mode pass.
- **Committed in:** `2e326e9`, `9d24a1f`, `41444a1`, `106d385`, `ef3d14d`, `bf3e4c1`

---

**Total deviations:** 2 auto-fixed (one plan bug, one review remediation)
**Impact on plan:** Necessary compatibility correction directly caused by the generated test; no production behavior or scope expansion.

## Issues Encountered

- The first full no-skip run exposed the exact proposal-source inventory collision described above; it was fixed and the complete gate was rerun successfully.
- One pre-existing unused-local Swift warning remains outside this plan's scope; it does not affect the zero-failure gate.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 68 implementation is ready for independent verification against CPU-01..CPU-05. Phase 69 may proceed only after that verifier/lifecycle step confirms the generated-only boundary. v1.17 Metal/GPU backend work, UI/Demo, device, performance, packaging, shipping, and release readiness remain deferred.

---
*Phase: 68-cpu-algorithm-reference-oracles*
*Completed: 2026-08-14*

## Self-Check: PASSED

- Summary file exists at the planned path.
- Task commits `466add4`, `d046df7`, and `c5ee3db` plus deviation fix `40ae082` are present in git history.
- `bash scripts/check-cpu-reference-oracles.sh --self-test` and normal focused preflight pass with exact `10/10/15` counts.
- Focused CPU reference suites pass `24/24`; archive, boundary, consumer, full no-skip (`693` expected after the two added tests), and `git diff --check` are the remaining closeout gates.
