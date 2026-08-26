---
phase: 89-semantic-validation-baseline
plan: "04"
subsystem: testing
tags: [documentation, semantic-validation, privacy, reliability, compatibility]

requires:
  - phase: 89-03-semantic-batch-runner
    provides: "Fail-closed 75/65/8 preflight, two-attempt reconciliation, atomic aggregate reports, and honest semantic failure status"
provides:
  - "Canonical owner-facing command, report, exit-status, retention, and nonclaim contract"
  - "Synchronized Phase 89 security, reliability, and quality owners"
  - "Privacy-safe Phase 89 completion ledger with exact downstream repair handoff"
affects: [phases-90-94-repairs, phase-95-closeout, owner-local-semantic-validation]

tech-stack:
  added: []
  patterns: [aggregate-only-durable-evidence, semantic-vs-infrastructure-status, owner-local-ignored-artifacts]

key-files:
  created:
    - .planning/phases/89-semantic-validation-baseline/89-04-SUMMARY.md
  modified:
    - .gitignore
    - example-images/README.md
    - QUALITY_SCORE.md
    - SECURITY.md
    - RELIABILITY.md
    - PLANS.md

key-decisions:
  - "Phase 89 completion certifies the shared semantic validation machinery, while the observed seven failing directions remain owned by Phases 90–94."
  - "Exit 3 is a creditable complete semantic measurement but neither infrastructure success nor evidence that a repair passed."
  - "Durable evidence is limited to aggregate stable payload facts and fixed reasons; portrait media, paths, geometry, and transcripts remain ignored or temporary."

patterns-established:
  - "Documentation mirrors the executable 75/65/8, two-attempt, stable-payload, atomic-publication contract exactly."
  - "Quality ledgers record honest failing aggregates without weakening thresholds or upgrading repair status."

requirements-completed: [VAL-01, VAL-02]

duration: 6min
completed: 2026-08-26
status: complete
---

# Phase 89 Plan 04: Semantic Validation Baseline Summary

**Owner-facing 75/65/8 semantic validation contract with aggregate-only evidence, exact failure semantics, and a preserved seven-direction repair handoff**

## Performance

- **Duration:** 6 min
- **Started:** 2026-08-26T03:20:47Z
- **Completed:** 2026-08-26T03:26:46Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Replaced the preliminary face-feature README paragraph with the exact runnable flags, preflight, two-attempt reconciliation, retained/removed artifact, report-schema, exit-status, privacy, compatibility, and nonclaim contract.
- Added matching Phase 89 trust and reliability owners for non-symlink path admission, request-local media/geometry, aggregate allowlisting, stale-report prevention, atomic publication, cleanup, and distinct semantic/infrastructure failures.
- Recorded the live baseline without promoting repairs: `1/8 semantic_pass`, `7/8 semantic_fail`, locality `3/8`, protected-region ceilings `6/8`, and 202 excluded watermark rows after two identical complete CPU attempts.
- Reverified the 180-mutation comparator, exact 75/65/8 preflight, focused 107/0/0 compatibility selection, both legacy archives, post-archive SDK-only boundary, privacy-safe ledger, and diff hygiene.

## Task Commits

Each task was committed atomically:

1. **Task 1: Document the repeatable semantic command, trust boundaries, and bounded quality interpretation** - `86bafaa` (docs)
2. **Task 2: Record Phase 89 completion and run focused compatibility and SDK-only gates** - `2e069eb` (docs)

## Files Created/Modified

- `.gitignore` - Keeps the canonical owner-local aggregate report directory ignored and reproducible.
- `example-images/README.md` - Documents the canonical runner interface and exact safe interpretation.
- `QUALITY_SCORE.md` - Records observed aggregate evidence while leaving repairs to Phases 90–94.
- `SECURITY.md` - Owns manifest/path/report/transcript trust boundaries and the durable allowlist.
- `RELIABILITY.md` - Owns fresh attempts, deterministic reconciliation, stale-report recovery, cleanup, atomic publication, and exit classes.
- `PLANS.md` - Preserves the predecessor record and adds the Phase 89 completion/handoff ledger.
- `.planning/phases/89-semantic-validation-baseline/89-04-SUMMARY.md` - Captures Plan 89-04 execution evidence.

## Decisions Made

- A complete deterministic `semantic_fail` remains valid evidence at exit 3; only admission/render/output/report/stale/determinism faults are non-creditable infrastructure failure.
- Validation success is separate from repaired-control success. The seven observed failures remain unchanged inputs to Phases 90–94, and no threshold is re-authored from the live result.
- Compatibility remains exactly 62 public parameter fields, five presets, and 75 renderer cases with unchanged `process`/`processResult` still-image facades, CPU authority, public GPU selection, and typed unavailable-GPU behavior.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Bound the documented owner-local report path to Git ignore policy**
- **Found during:** Task 1
- **Issue:** The runner's canonical aggregate report lives under `example-images/local-test-records/`; without an explicit ignore entry, the privacy and reproducibility contract could permit accidental staging.
- **Fix:** Verified and incorporated the intended `.gitignore` addition alongside the command/security/reliability boundary documentation.
- **Files modified:** `.gitignore`
- **Verification:** `git check-ignore` is exercised by runner preflight; exact `75/65/8` preflight passed and the report remains untracked.
- **Committed in:** `86bafaa`

**2. [Rule 1 - Bug] Restored canonical completed-phase state after SDK normalization**
- **Found during:** Plan metadata update
- **Issue:** The state SDK correctly moved Phase 89 to verification and calculated one of seven phases complete, but normalized `milestone_name`, removed the canonical phase identity fields, and left stale 75%/executing body text and zero aggregate metrics.
- **Fix:** Preserved SDK-recorded plan metrics, decisions, session, and 14% milestone calculation while restoring the canonical milestone/phase fields and synchronizing the body to completed Phase 89, 4 plans, 59 minutes, and verification readiness.
- **Files modified:** `.planning/STATE.md`
- **Verification:** Frontmatter/body now agree on v1.22, Phase 89 completion, 4/4 plans, 14% milestone progress, completed session, and the Plan 89-04 metric.
- **Committed in:** Plan metadata commit

---

**Total deviations:** 2 auto-fixed (1 Rule 1 metadata bug, 1 Rule 2 missing critical privacy support)
**Impact on plan:** The minimal ignore rule makes the documented owner-local report boundary enforceable, and the metadata repair preserves accurate workflow state; neither changes runner behavior or product scope.

## Issues Encountered

None.

## Known Stubs

None. The modified contract sections contain no TODO, FIXME, placeholder, coming-soon, or unwired behavior; historical uses of those words elsewhere in the long-lived ledger are unrelated.

## Authentication Gates

None.

## User Setup Required

None - no external service configuration required.

## Verification

- `swift scripts/compare-face-feature-batches.swift --self-test` → `PASS`, 180 mutations, exact `5/65/8` inventory.
- `bash scripts/run-face-feature-batches.sh --preflight-only` → `PASS`, live `75`, selected `65`, semantic `8`.
- Focused parameter/resource/renderer/metadata/backend/concurrency selection → `107/0/0`.
- Archive verification → both pinned legacy UI archives verified.
- `bash scripts/check-sdk-only-boundary.sh --post-archive` → passed after archive verification.
- Ledger aggregate/privacy assertion and owner-contract scan → passed.
- `git diff --check` → passed.
- Source audit → the intended predecessor `PLANS.md` record, README section, and local-report ignore rule were extended in place; no unrelated edit was reverted.

## Threat Flags

None. This plan documents the already-planned manifest/path/report trust surfaces and adds no endpoint, authentication path, schema trust boundary, model/network route, or production API.

## Next Phase Readiness

- Phase 89's validation machinery and durable owners are complete for VAL-01/VAL-02.
- Phases 90–94 can repair their assigned control families against the frozen source-plus-neutral, polarity, signal, locality, sibling, and protected-region contract.
- There are no execution blockers. Passing Phase 89 does not claim naturalness, device/population quality, performance, commercial use, packaging, shipping, launch, release readiness, or distribution.

## Self-Check: PASSED

- All seven listed created/modified files exist.
- Task commits `86bafaa` and `2e069eb` exist in Git history.
- Summary counts and statuses match the reconciled Plan 89-03 aggregate and current focused reruns.
- No private source identity, locator, raw report row, media, pixel, mask, landmark, geometry, or transcript was copied into durable evidence.

---
*Phase: 89-semantic-validation-baseline*
*Completed: 2026-08-26*
