---
phase: 93-distinct-nose-bridge-and-root-repairs
plan: "04"
subsystem: validation
status: complete
tasks_completed: 2
tasks_total: 2
implementation_attempt: 2
code_review_status: passed
independent_goal_verification: pending
supplemental_cross_phase_regression: passed
requirements-addressed: [NOSE-01, NOSE-02]
requirements-completed: []
key-files:
  created:
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-CHECKS.json
    - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-REVIEW.md
  modified: []
completed: 2026-09-10
---
# Phase 93 Plan 04: Compatibility and Independent Review

The exact second candidate passed the complete focused and compatibility conjunction, all eight SDK-owned boundary commands and independent code review. Goal verification and owner synchronization remain separate. The later supplemental cross-phase selection error is retained and its reviewed scope correction has passed; it does not turn these actually completed gates into unexecuted or failed tests.

## Current evidence

| Gate | Discovered / passed / failed / skipped | Evidence |
|---|---|---|
| Fresh core revalidation | 36 / 36 / 0 / 0 | Ledger42–47; provider22, registration4, metric4, pixel2, lifecycle4 |
| Core repeated by compatibility | 36 / 36 / 0 / 0 | Ledger48–52; matching candidate and runner |
| Eleven compatibility classes | 229 / 229 / 0 / 0 | Ledger53; every method uniquely discovered and passed |
| Eight SDK-owned commands | 8 / 8 / 0 / 0 | Ledger54; counts here are commands, not XCTest methods |
| Independent implementation review | passed, blockers0 | `93-REVIEW.md`, committed `ee6d55f9` |

Compatibility includes parameters, presets, metadata, CPU oracle, renderer process and output tests, resolver/conflict/missing-support logic, coordinate mapping and observation mapping. The eight existing renderer process methods share one bounded XCTest process under the reviewed launcher correction; each must start and pass exactly once. No skipped method receives credit.

The eight-command result includes comparator576 mutations and inventories5/65/8; runner boundary/report-cleanup6; shell syntax; preflight75/65/8; backend-neutral24 and CPU-reference41 tests; both verified historical archives; SDK-only boundary; and diff hygiene. The parent observed each fixed command through bounded capture and exact aggregate parsing. No private portraits, full65-output render, real-device test or full no-skip milestone gate was executed.

## Bound identity and actual pixels

- Provider: `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`.
- Adapter: `cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9`.
- Timeout-recovery runner: `eb7ccc0f4dda224d8ad78080bf64bed95cb6bee7b1f608dd821c927dc54da116`.
- Full code review SHA-256: `1d86dcdd42ca8c6fedf239f835c1abd070628b66039e3688017a4d165e8e6441`.

Bridge target/source and target/neutral comparisons each change611 pixels with RGB delta29460 and margin383 Q8; minimum sibling margin373. Root comparisons each change1043 pixels with RGB delta43917 and margin24 Q16; minimum sibling margin24. Comparison counts remain6/5; all outside/protected/background/watermark changes and RGB deltas are0. Both repeat checks pass and retained sibling digests agree. The eight-orientation loop covers bridge raw-facade agreement, not root semantic qualification at every orientation.

## Infrastructure deviations and preserved history

Attempt1's field-safety failure and rollback remain unchanged. Candidate2 first passed core36, then compatibility timeout39 triggered rollback40. Review exposed the outer60s/inner120s cold-build budget mismatch. `35899899` adds a separately reviewed scheduling/recovery wrapper; `2194e04c` restores the exact same candidate. No third production candidate, radius/test/threshold change or baseline rewrite occurred. New runner selftests133 retained plus27 new pass; the same candidate then freshly passed the gates above.

After these gates, the parent's additional prior-phase selector mistakenly included two private-portrait opt-ins. Ledger55 records `skip_failure` after34 passes; no portrait access occurred and no later method received credit. See `93-REGRESSION-DISPOSITION.md`: the scope correction preserves this failure and requires106 deterministic methods, while reusing the unchanged, complete receipts47/53/54 transparently. The reviewed correction `07664fa5` subsequently passed all106 deterministic methods with zero failures/skips at ledger56; prior completed receipts remain unchanged with explicit identity provenance in CHECKS.

## Handoff

Seven owner documents must describe the accepted mechanics, bounded actual-pixel evidence, exact compatibility and failure history. Independent goal verification remains required for both NOSE requirements. Phase 95 owns private-portrait/final-output qualification and full milestone closeout; this owner-local SDK evidence does not establish naturalness, device performance or external distribution readiness.
