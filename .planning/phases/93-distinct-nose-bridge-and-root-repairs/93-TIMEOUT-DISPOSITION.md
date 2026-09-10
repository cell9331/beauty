# Phase 93 compatibility launcher correction

Status: infrastructure correction prepared; independent review and revalidation pending.
This is the orchestrator's narrowly scoped implementation of the owner's ongoing
“使用第一性原理，查找并修复问题” request, not an additional explicit owner decision,
new research pass, third numerical candidate, or permission to change efficacy.

Candidate 2 at `851d1d5f` passed all 36 core methods. Compatibility repeated those
36 successfully, then discovered 229 methods and passed 67 before an external
`child_timeout` in `testCompiledRendererBindsOnlyExactSuccessfulGazeAggregate`.
Ledger event 39 records zero assertion failures and zero skips; one timed out
method and 161 later methods receive no pass credit. Event 40 records the exact
rollback of both owned production files. These events stay byte-unchanged.

The source-level scheduling defect is concrete: every individually launched
XCTest process starts with an empty static renderer cache, creates a fresh
scratch build, and permits each build child 120 seconds. The outer gate kills
the entire process group at 60 seconds. A cold build and subsequent rendering
cannot rely on the inner budget. Captured output was not persisted, so this
identifies the incompatible budgets, not the exact runtime instruction reached
at timeout and not a proven renderer, compiler or numerical defect.

The correction runs exactly the existing eight process-test methods together
in one bounded 1,839-second XCTest subprocess, preserving the class-owned cache
and normal class teardown. Every method must be uniquely discovered, started
once and passed once; exact total summaries, zero skips/errors and successful
exit remain mandatory. All other methods retain their individual 60-second
limit. No Swift test, threshold, input, rendering contract or production byte
changes. Fixed aggregate/parser mutation tests precede independent review.

The new runner pins the original runner/authorization and exact 40-event prefix.
It can restore only the same committed candidate and D-09 adapter, without a
new begin/attempt. A separate infrastructure-resume receipt identifies this
bounded disposition. All 36 core receipts must be freshly reproduced at the
new runner identity before a revalidation receipt can admit compatibility and
closeout. The earlier timeout is never relabeled passed or erased. Any new
failure blocks acceptance and supports owned rollback; no generic retry loop,
error exemption, third candidate or test-assertion relaxation is introduced.

Independent code and goal review, unchanged public inventory and owner-local
scope remain required. Phase 95 and external/device qualification remain outside
this repair. Durable evidence contains only fixed status, counts and hashes.

The class bound is derived as `2*(120+6+5) + 37*(30+6+5) + 60 = 1839`
seconds: existing setup/renderer waits, per-child termination/drain allowance,
and an explicit fixture/teardown allowance. The launcher supplies one owned
TMPDIR and removes it after child-group termination on both pass and timeout.
This is a finite operational bound, not a guarantee under arbitrary OS stalls.

Resume stages each file outside the SDK inventory and atomically replaces it.
Immutable pins and original blobs admit recovery from original/candidate mixed
state without requiring a complete candidate. Ordinary infrastructure errors
are sanitized into a failure record; recorded partial hashes can be restored,
while unrelated source drift is rejected. No raw child text or temporary paths
are copied to durable receipts.
