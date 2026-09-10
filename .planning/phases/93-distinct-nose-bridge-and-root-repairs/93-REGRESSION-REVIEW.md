---
phase: 93
reviewed: 2026-09-10
status: clean
blockers: 0
candidate_sha: bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45
runner_sha: 7ff1598beb9708ba1917e3f8f1d7ca995de2fdd98eaed2adcd1a1eeb0f784378
---
# Phase 93 supplemental regression review

## Narrative Findings (AI reviewer)

Narrow review of the regression-closeout wrapper and its disposition. Prior independent algorithm/source approval is reused. No new production candidate or native evaluation is part of this review. The finding below is resolved in the current hash-bound runner; its original description is retained as history. No outstanding blocker remains in the reviewed scope. Fresh regression and downstream closeout obligations remain mandatory.

### CR-01 — BLOCKER, resolved: Child wait timeout escapes the new-failure latch

**File:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-regression-closeout.py:176-182`; delegated child wait at `/Users/yakangwang/codes/beauty/scripts/check-phase93-nose-repair.py:178`.

**Issue:** The regression command catches only GateError and OSError. The unchanged child helper can raise subprocess.TimeoutExpired from proc.wait() after its pipes have closed while the process remains alive. TimeoutExpired derives from SubprocessError, not OSError. The new command therefore exits without recording a failure. Neither authorities() nor regression() can then distinguish the interrupted execution from an unused continuation, so a subsequent invocation is admitted. This violates the requested rule that every new failure blocks continuation. The frozen gate's normal main() catches Exception; this special dispatch bypasses that boundary.

**Memory-only counterexample:** Admitted the actual pinned 55-event history, receipt hashes 47/53/54, current identity and an in-memory review. Executed the actual command-dispatch AST and regression() with prepare() raising TimeoutExpired at the delegated child boundary, append() collecting only in memory, and alarms disabled. Two successive invocations both reached prepare(), both let TimeoutExpired escape, and produced zero failure records. No Swift child or native test ran.

**Fix:** Normalize TimeoutExpired to a fixed failure category and append the blocking failure at this special command boundary. Prefer parity with the frozen main's ordinary-exception handling, sanitizing non-GateError exceptions instead of persisting their command/output/message. Add an actual-dispatch memory regression proving a wait timeout records one failure and that the next invocation is rejected before preparation. Preserve failure 55 and all pinned passed receipts.

## Scoped assessment and evidence

- Actual read-only authority admission succeeded with the exact prefix through 55, failure digest, current timeout-runner identity and pinned completed receipts: revalidation 47 (36), compatibility 53 (229), checks 54 (8).
- The historical exception is limited by the immutable prefix/failure digest; validate_history rejects any later recorded failure. CR-01 concerns failures that never reach that record.
- The selector removes exactly the two named portrait methods and retains the two explicitly listed contour methods. It requires 106 unique, actually discovered method identities; no test assertions, candidate bytes or portrait inputs are changed by this wrapper.
- accepted() requires a current-identity 106/106/0/0 regression receipt. Prior core/compatibility/check evidence is admitted only at its pinned original sequence and identity. Cumulative CHECKS preserves the original receipt objects and labels the prior validation identity separately.
- Wrapper selftests independently rerun: 10 passed, zero failed/skipped. These cover selection/history mutations but do not cover the ordinary child exception escaping special dispatch.
- Reviewed candidate SHA-256: `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`. Reviewed runner SHA-256: `f951fea6ca748549818105720f11e38597c33f11c0d5bc5e8eabb60910fb673f`.

Only this report was authored. No production, test, gate, ledger, CHECKS, source-review or pre-evaluation-report file was modified. No native evaluation or commit was performed. Compatibility/core/checks results are retained recorded evidence, not reviewer reruns; supplemental regression and closeout remain pending.

## Final narrow re-review

Current runner SHA-256 is `7ff1598beb9708ba1917e3f8f1d7ca995de2fdd98eaed2adcd1a1eeb0f784378`, matching the repinned disposition. Candidate SHA-256 remains `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`. The preceding old hash and finding describe the superseded draft only.

The command now delegates to run_regression_command(), which catches ordinary Exception, maps TimeoutExpired to child_timeout, sanitizes other ordinary exceptions to infrastructure_failure and appends a failure record. The historical exception remains limited to pinned failure 55; subsequent recorded failures still block authorities().

Independent regression executed the actual command-dispatch AST, real regression(), full authority admission and chained ledger parsing against the real pinned prefix with only the new review/ledger overlaid in memory. A synthetic prepare-time TimeoutExpired produced failure 56 with category child_timeout. A second invocation produced attempt_failed at 57 and did not re-enter prepare: total preparation calls remained one. Neither the synthetic command nor output text entered captured output or ledger data. The durable ledger was verified unchanged. No Swift or render child ran.

Current memory-only selftests independently rerun: 12 passed, zero failed/skipped. CR-01 is resolved; the earlier scoped identity, exclusions, provenance and fresh-106-receipt assessment remains applicable. Only this review artifact was updated.
