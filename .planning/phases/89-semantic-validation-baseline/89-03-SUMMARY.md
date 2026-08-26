---
phase: 89-semantic-validation-baseline
plan: "03"
subsystem: testing
tags: [bash, swift, semantic-validation, deterministic-reconciliation, privacy]

requires:
  - phase: 89-02-semantic-metrics
    provides: "Exact 5/65/8 aggregate-only semantic payloads with stable digests and distinct semantic/infrastructure statuses"
provides:
  - "One preflighted owner-local command for the exact live 75-case renderer and selected 65-case/eight-direction semantic inventory"
  - "Two independent public-facade CPU render/compare attempts reconciled by completion class, canonical payload bytes, and stable digest"
  - "Atomic semantic or sanitized infrastructure reports with one retained watermarked attempt and no child transcript persistence"
affects: [89-04-validation-documentation, phases-90-94-repairs, phase-95-closeout]

tech-stack:
  added: []
  patterns: [fail-closed-path-admission, unique-two-attempt-reconciliation, atomic-aggregate-publication]

key-files:
  created: []
  modified:
    - scripts/run-face-feature-batches.sh

key-decisions:
  - "The runner maps a complete comparator semantic failure to its dedicated public exit 3 while reserving exit 2 for infrastructure failure and replacing stale reports with a sanitized envelope."
  - "Only canonical stable payload bytes and digests are reconciled; attempt IDs, timestamps, child output, source paths, and private media never enter the published aggregate."
  - "Each renderer unit targets the admitted portrait subroot and removes its temporary renderer report, leaving only parameter-watermarked PNGs in the retained attempt."

patterns-established:
  - "Preflight admits non-overlapping non-symlinked paths, ignored in-repository destinations, exact renderer/manifest inventories, and comparator self-tests before output or report work."
  - "Fresh mktemp identities own every attempt, report, and workspace; traps delete only validated current-invocation roots and never reuse or remove prior owner output."

requirements-completed: [VAL-01, VAL-02]

coverage:
  - id: D1
    description: "One command renders the exact selected public-facade CPU matrix twice and retains only the first complete watermarked attempt."
    requirement: VAL-01
    verification:
      - kind: integration
        ref: "scripts/run-face-feature-batches.sh live two-attempt execution"
        status: pass
    human_judgment: false
  - id: D2
    description: "Stable semantic payload/status reconciliation is deterministic, aggregate-only, atomic, and fail-closed for infrastructure faults."
    requirement: VAL-02
    verification:
      - kind: integration
        ref: "live semantic report plus forced renderer-failure envelope probe"
        status: pass
    human_judgment: false

duration: 21min
completed: 2026-08-26
status: complete
---

# Phase 89 Plan 03: Semantic Validation Baseline Summary

**Fail-closed 75/65/8 preflight and two-attempt CPU reconciliation with one transcript-free watermarked attempt and atomic aggregate evidence**

## Performance

- **Duration:** 21 min
- **Started:** 2026-08-26T02:55:44Z
- **Completed:** 2026-08-26T03:16:21Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments

- Hardened the existing runner with no-symlink/no-overlap path admission, ignored owner-local destination checks, exact live `75`, selected `65`, and semantic `8` inventory checks, plus a no-render `--preflight-only` mode.
- Executed two fresh public `BeautyExampleRenderer` CPU matrices, independently compared both complete attempts, and required identical completion class, canonical payload bytes, comparator digest, and reconciliation digest before publication.
- Retained exactly one current-invocation attempt with `66` parameter-watermarked PNGs and zero other files; removed the repeat attempt, comparator reports, workspaces, renderer reports, and child output on success and failure.
- Published the honest current `semantic_fail` baseline at exit `3`; a forced renderer failure independently proved sanitized `infrastructure_failure` replacement at exit `2` with zero retained partial attempts.

## Task Commits

Each task was committed atomically:

1. **Task 1: Harden owner-local paths, exact inventory admission, and transcript-free child execution** - `8845ee5` (feat)
2. **Task 2: Reconcile two independent render attempts and publish one honest current report** - `47edcf4` (feat)

## Files Created/Modified

- `scripts/run-face-feature-batches.sh` - Path/inventory preflight, unique two-attempt CPU orchestration, transcript-free rendering, canonical reconciliation, cleanup ownership, status mapping, and atomic final publication.

## Decisions Made

- Runner exit `0` means complete `8/8` semantic pass, exit `3` means a complete deterministic semantic failure with an honest report, and exit `2` means infrastructure failure with a sanitized current envelope.
- The final semantic envelope exposes `status`, `stableSemanticPayload`, the comparator digest, and an independently recomputed reconciliation digest. Volatile attempt metadata stays temporary and cannot affect equality.
- The retained output is a unique `mktemp` child of the admitted owner-local root. Repeat images and all transient reports live outside the repository and are trap-removed; prior output attempts are never reused or deleted.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Restored canonical phase state fields after SDK normalization**
- **Found during:** Plan metadata update
- **Issue:** The state SDK advanced Plan 3 to Plan 4 but normalized `milestone_name`, dropped `current_phase`/`current_phase_name`, and reported a 75% progress update without projecting it into the stored frontmatter/body.
- **Fix:** Preserved the successful plan/session/metric/decision updates while restoring the canonical milestone/phase fields and the actual `3/4` (`75%`) progress derived from on-disk summaries.
- **Files modified:** `.planning/STATE.md`
- **Verification:** STATE records Plan 4 of 4, three completed plans, the Phase 89 identity, `75%` in frontmatter/body, the Plan 89-03 metric, decisions, and completed session marker.
- **Committed in:** Plan metadata commit

---

**Total deviations:** 1 auto-fixed (1 Rule 1 bug)
**Impact on plan:** Metadata correctness only; runner scope and behavior are unchanged.

## Issues Encountered

- The first external failure probe used the macOS lexical `/var` alias and was correctly rejected as a symlinked path component. Re-running with the physical `/private/var` path passed admission and verified the infrastructure envelope/cleanup contract. No repository change was required beyond the already planned physical-path canonicalization for runner-created temporary roots.

## Known Stubs

None. Empty shell variables are explicit trap-owned lifecycle state; the runner has no TODO, FIXME, placeholder, coming-soon, unavailable, or unwired mock-data path.

## Threat Flags

None. Path admission, local fixture reads, attempt/output ownership, child execution, report publication, and threshold immutability are the explicit T-89-01 through T-89-07 surfaces mitigated by this plan.

## Authentication Gates

None.

## User Setup Required

None - no external service configuration required.

## Automated Evidence

- Shell syntax/help/preflight → `preflight=PASS live=75 selected=65 semantic=8`.
- No-mutation preflight probe → output PNG count and report modification time unchanged.
- Path mutation probes → input/output overlap and symlinked output both rejected before rendering.
- Live two-attempt run → exit `3`, `semantic_report=semantic_fail batches=5 cases=65 directions=8 attempts=2`.
- Published semantic report → exact `5/65/8`, zero missing outputs, status/payload agreement, and comparator/reconciliation digest equality.
- Retained/removed artifacts → one current-invocation attempt, `66` retained PNGs, zero retained non-PNGs, zero repeat/workspace roots.
- Forced renderer failure → exit `2`, fixed `infrastructure_failure` reason, aggregate `75/65/8`, and zero retained partial attempts.
- Privacy/transcript scan → no source locator, media extension, raw RGBA, landmark, transcript, renderer report, or log in the published report/retained attempt.
- Source hygiene → no retry, calibration, threshold, `--no-watermark`, or persistent `render.log` route; `git diff --check` passed.

## Next Phase Readiness

- Plan 89-04 can document the exact command/status/privacy contract and current aggregate baseline without inspecting or persisting portrait-level media.
- The current eight-direction outcome is an honest semantic failure baseline for Phases 90–94 to repair. It is not device, population, naturalness, commercial, release, shipping, launch, or distribution evidence.

## Self-Check: PASSED

- The modified runner and this summary exist.
- Task commits `8845ee5` and `47edcf4` exist in Git history.
- Preflight, live reconciliation, infrastructure failure, cleanup, privacy, transcript, and whitespace checks passed.
- Authorized portraits and watermarked outputs remain ignored owner-local artifacts; no raw media or private locator was added to Git.

---
*Phase: 89-semantic-validation-baseline*
*Completed: 2026-08-26*
