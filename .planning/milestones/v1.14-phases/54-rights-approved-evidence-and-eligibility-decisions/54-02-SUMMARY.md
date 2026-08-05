---
phase: 54-rights-approved-evidence-and-eligibility-decisions
plan: "02"
subsystem: evidence
tags: [javascript, json-schema, immutable-snapshot, privacy, fail-closed]

requires:
  - phase: 54-rights-approved-evidence-and-eligibility-decisions
    provides: D-01 through D-16 RED mutation contract and fail-closed core checker from Plan 54-01
provides:
  - Strict draft-2020-12 one-feature evidence manifest schema with exact asset-key boundaries
  - Immutable current-genuine evidence snapshots and independent feature-local reducers
  - Deterministic positive-allowlist durable export with no time, session, path, rights, media, or raw geometry data
affects: [54-03-offline-reviewer, 54-04-decision-ledger, 54-05-closeout, phase-55-composition]

tech-stack:
  added: []
  patterns: [exact-relative-asset-key, immutable-one-feature-snapshot, request-local-review-provenance, positive-allowlist-export]

key-files:
  created:
    - .planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-manifest.schema.json
    - .planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-core.js
  modified: []

key-decisions:
  - "A selected product row is exactly approved_internal_evaluation plus genuine_candidate; every other role or rights state remains tooling-valid but has zero product denominator and naturalness weight."
  - "Cross-feature review ownership is carried only as a non-enumerable request-local array marker; it never enters review fields, aggregates, or durable serialization."
  - "Upper-eyelid eligibility requires both a passing evidence snapshot and the exact reviewed/qualified/independent_nonwarp design record."

patterns-established:
  - "Structural validity, asset availability, product readiness, review pass, and feature decision are separate fail-closed stages."
  - "Durable artifacts are constructed field by field in fixed feature and fixture order; rich caller data is never spread into output."

requirements-completed: [EVID-01, EVID-02, EVID-03, EVID-04, EVID-05, LID-01]

duration: 12min
completed: 2026-07-31
---

# Phase 54 Plan 02: Immutable Evidence Core Summary

**A dependency-free browser/Node core now turns bounded one-feature manifests into frozen genuine-evidence snapshots, isolated eligibility decisions, and byte-stable privacy-safe exports.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-07-31T18:09:00+08:00
- **Completed:** 2026-07-31T18:21:08+08:00
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added an exact draft-2020-12 schema and matching semantic validator for 1...64 row, one-feature manifests with opaque IDs, predeclared polarity/target expectation, current rights/role classification, and complete original/mask/after triples.
- Added exact selected-root-relative asset-key handling that rejects absolute, traversal, dot, backslash, colon, NUL, duplicate, basename-collision, and ambiguous inventory cases without alias repair.
- Added deeply frozen stable-sorted snapshots, exact structured review predicates, three independent reducers, the upper-eyelid evidence/design conjunction, and deterministic two-space LF export.
- Kept non-product rows at zero product denominator/weight and kept every durable object free of manifest, media, path, rights, reviewer, time, event, freeform, and raw-geometry data by construction.

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement exact schema, safe asset keys, eligibility classification, and immutable snapshot** — `089053d` (`feat`)
2. **Task 2: Implement frozen reviews, independent reducers, and deterministic allowlist export** — `b05e16a` (`feat`)

## Files Created/Modified

- `.planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-manifest.schema.json` — exact dependency-free schema with closed object shapes, enums, IDs, row bounds, and relative asset keys.
- `.planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-core.js` — frozen dual browser/CommonJS API for validation, snapshots, reviews, reducers, and durable export.
- `.planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-02-SUMMARY.md` — execution evidence and downstream handoff.

## Verification Evidence

- Task 1 focused Node sample: **10/10 passed**.
- Complete core Node suite: **23/23 passed**, zero skipped and zero failed.
- JavaScript syntax and JSON parsing: **passed**.
- Boundary checker `--core`: **passed**, reporting ASVS Level 1 HIGH **6/6** and exact UI inventory `27 = 8 + 19`.
- `git diff --check`: **passed**.

## ASVS Level 1 HIGH Gate

| Threat | Result | Evidence |
|---|---|---|
| T-54-01 tampering | PASS | Exact schema/path/identity/cross-row mutations and immutable snapshot tests passed. |
| T-54-02 tampering/repudiation | PASS | Exact review-set, frozen predicate, sibling isolation, and upper-eyelid conjunction tests passed. |
| T-54-03 information disclosure | PASS | Positive-allowlist, recursive forbidden sentinel, deterministic-byte tests, and core source scan passed. |
| T-54-05 denial of service | PASS | Manifest, row, asset-byte, and decoded-dimension budgets are frozen and tested. |

No HIGH mitigation was skipped, inferred, or left unverified.

## Decisions Made

- Valid-but-partial and valid tooling-only inputs return frozen closed snapshots rather than becoming structural errors.
- Exact asset availability is checked only against normalized selected-root-relative keys; basename and suffix aliases are never created.
- Review-array ownership uses a private non-enumerable request-local marker to reject reuse across feature reducers without adding a review field or any durable/process-global review registry.
- Upper-eyelid design qualification is projected to its four exact fields before evaluation; extra rich caller metadata remains unreachable by durable serialization.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

The isolated-reducer test deliberately supplies field-identical review rows for different features. The implementation preserves feature ownership on the request-local review container with a private non-enumerable marker, allowing deterministic cross-feature rejection without changing the frozen review schema or export.

## Known Stubs

None. Every declared API entry is implemented and the complete Wave 0 core contract is green.

## User Setup Required

None - no package, dependency, server, account, network, or external service was introduced.

## Next Phase Readiness

- Plan 54-03 can bind the static File API reviewer to `ReviewCore` without duplicating eligibility or export policy.
- Plan 54-04 can generate the exact three-feature closed ledger through `serializeDurableExport` while leaving sensitive local manifests and media untracked.
- No SDK, Demo, production renderer, preset, realtime path, packaged spike, or root contract file changed.

## Self-Check: PASSED

- Both implementation artifacts and this summary exist.
- Task commits `089053d` and `b05e16a` exist in Git history.
- Complete 23/23 Node tests, JavaScript/JSON syntax, checker `--core`, ASVS HIGH 6/6, and diff hygiene were re-run after summary creation and passed.

---
*Phase: 54-rights-approved-evidence-and-eligibility-decisions*
*Completed: 2026-07-31*
