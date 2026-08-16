---
phase: 71-sdk-owned-metal-runtime
plan: "04"
subsystem: testing
tags: [swiftpm, metal, preflight, traceability, privacy]

# Dependency graph
requires:
  - phase: 71-sdk-owned-metal-runtime
    provides: package-only Metal runtime, internal executor, mutation-tested preflight, and synchronized owner contracts
provides:
  - measured METAL-01 completion and exact four-plan traceability
  - Phase 72 handoff with CPU reference and package-only boundaries preserved
  - aggregate-only runtime availability, cleanup, and no-skip evidence in current ledgers
affects: [72-metal-feature-passes, 73-public-backend-configuration, 74-parity-closeout]

# Tech tracking
tech-stack:
  added: []
  patterns: [archive-first aggregate closeout, explicit Metal availability classification, source-coverage ledger]

key-files:
  created:
    - .planning/phases/71-sdk-owned-metal-runtime/71-04-SUMMARY.md
    - .planning/phases/71-sdk-owned-metal-runtime/deferred-items.md
  modified:
    - PLANS.md
    - .planning/PROJECT.md
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
    - .planning/STATE.md

key-decisions:
  - "Complete METAL-01 only from archive-first executable evidence: focused 26/0/0, full 728/0/0, eight opt-ins exactly once, and separate metal_available=1 / metal_unavailable=0 accounting."
  - "Keep the closeout package-only and aggregate-only; CPU remains the reference while feature passes, public backend configuration, and parity stay with Phases 72–74."
  - "Treat the repository-wide historical privacy-token scan as a pre-existing ledger-baseline issue and record it without rewriting historical evidence."

patterns-established:
  - "Runtime completion records classify availability separately so unavailable execution cannot lend success to GPU parity."
  - "Planning ledgers trace GOAL, METAL-01, absent research, and absent context without persisting runtime payloads."

requirements-completed: [METAL-01]

# Metrics
duration: ~15min
completed: 2026-08-16
status: complete
---

# Phase 71 Plan 04: SDK-Owned Metal Runtime Summary

**METAL-01 is closed from archive-first runtime evidence, with explicit availability accounting and a clean handoff to Phase 72 feature passes.**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-08-16T08:25:00Z
- **Completed:** 2026-08-16T08:39:31Z
- **Tasks:** 2
- **Files modified:** 6 (including the deferred-items ledger)

## Accomplishments

- Ran Metal mutation self-test and live preflight, post-archive SDK-only boundary, no-skip wrapper self-test, and the full archive-first no-skip wrapper.
- Recorded focused `26` tests with zero failures/skips, full `728` tests with zero failures/skips, all eight opt-ins exactly once, and separate `metal_available=1` / `metal_unavailable=0` classifications.
- Synchronized requirements, roadmap, state, project, and plan ledgers with exact four-plan ownership and the Phase 72/73/74 handoff while preserving CPU reference and nonclaims.

## Verification

- `bash scripts/check-metal-runtime.sh --self-test` — passed.
- `bash scripts/check-metal-runtime.sh` — passed; focused `26/0/0`, `metal_available=1`, `metal_unavailable=0`.
- `bash scripts/check-sdk-only-boundary.sh --post-archive` — passed.
- `bash scripts/run-no-skip-swiftpm.sh --self-test` — passed.
- `bash scripts/run-no-skip-swiftpm.sh` — passed; `728/0/0`, `skipped_tests=0`, eight opt-ins exactly once.
- Ledger token scan and `git diff --check` — passed.
- The new Phase 71 closeout blocks pass the scoped privacy/scope scan. A repository-wide historical scan also finds pre-existing literals in older planning records; this is recorded in `deferred-items.md` and no historical text was rewritten.

## Task Commits

Each task was committed atomically:

1. **Task 1: Run final Phase 71 verification and update traceability ledgers** - `8b85c97` (docs)
2. **Task 2: Record aggregate Phase 71 project and plan ledger closeout** - `c252005` (docs)

**Plan metadata:** pending final metadata commit.

## Files Created/Modified

- `PLANS.md` - completed Phase 71 ledger, source audit, measured evidence, and handoff.
- `.planning/PROJECT.md` - current package-only runtime position and nonclaims.
- `.planning/REQUIREMENTS.md` - METAL-01 evidence and exact plan traceability.
- `.planning/ROADMAP.md` - four completed Phase 71 plans and Phase 72 transition.
- `.planning/STATE.md` - completed Phase 71 position, metrics, decisions, and next action.
- `.planning/phases/71-sdk-owned-metal-runtime/deferred-items.md` - pre-existing historical scan baseline note.

## Decisions Made

- METAL-01 completion is authorized by executable aggregate evidence, not source presence alone.
- `metal_available` and `metal_unavailable` remain separate classifications; unavailable execution is never GPU success or parity evidence.
- CPU remains the reference. Phase 72 owns feature passes, Phase 73 owns public `.cpu`/`.gpu` configuration, and Phase 74 owns parity and SDK-only closeout.

## Deviations from Plan

### Deferred Out-of-Scope Issue

**1. Historical privacy-token baseline remains deferred**
- **Found during:** Task 2 ledger/source audit
- **Issue:** The plan's repository-wide privacy-token command also scans historical planning records containing pre-existing path and sensitive-term literals, so it cannot be a clean current-diff baseline.
- **Action:** Added `deferred-items.md`; verified the new Phase 71 entries separately and confirmed no new matching literals.
- **Files modified:** `.planning/phases/71-sdk-owned-metal-runtime/deferred-items.md`
- **Verification:** Scoped closeout scan passes; all executable gates and `git diff --check` pass.

**Impact:** No current Phase 71 runtime or ledger privacy surface was introduced. Historical evidence remains unchanged.

## Issues Encountered

- The documented `gsd-tools` executable was not on `PATH`; the repository-provided Node CLI fallback was used for initialization/state inspection as in prior plan summaries.
- No package installation, external service, or manual setup was required.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 71 is complete and Phase 72 can implement feature passes on the package-only runtime boundary. Public backend configuration remains Phase 73 work; generated parity and SDK-only closeout remain Phase 74 work. No public `.gpu` configuration, feature parity, device/performance, commercial, packaging, shipping, launch, or release-readiness claim follows from this plan.

## Known Stubs

None. The retained identity transaction remains an intentional runtime probe owned by earlier Phase 71 plans; this closeout adds only ledgers and evidence.

## Self-Check: PASSED

- Summary file exists.
- Task commits `8b85c97` and `c252005` are present in Git history.
- Metal preflight, post-archive boundary, archive-first no-skip wrapper, ledger scans, and `git diff --check` pass.
- No runtime payloads, paths, host identifiers, or private fixture details were added to the current Phase 71 closeout records.

---
*Phase: 71-sdk-owned-metal-runtime*
*Completed: 2026-08-16*
