---
phase: 93
reviewed: 2026-09-10
status: clean
blockers: 0
candidate_sha: bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45
runner_sha: eb7ccc0f4dda224d8ad78080bf64bed95cb6bee7b1f608dd821c927dc54da116
---
# Phase 93 timeout continuation review

## Narrative Findings (AI reviewer)

Independent, narrow pre-evaluation source review of the timeout wrapper, its amendment/disposition and the Plan 04 appendix. The prior arithmetic and full source assessment is reused. Phase acceptance remains revoked and compatibility inconclusive; this report does not accept the rolled-back checkout. The owner's ongoing repair request supplies the continuation context; no new explicit approval or third production candidate is inferred.

### CR-01 — BLOCKER, resolved: Interrupted resume cannot be recovered by the wrapper

**File:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-timeout-recovery.py:87-94`, `:70-75`, `:116-125`, `:203-209`.

Resume records sequence 41 before writing the provider and adapter. Its command boundary catches only GateError. An OSError opening the adapter after the provider write escapes without a failure event. Rollback calls authorities(), which requires both complete candidate hashes, so the resulting mixed checkout cannot use the advertised rollback path.

**Reproduction:** Executed the actual command-dispatch AST and actual resume/rollback functions with ledger writes and production file descriptors replaced by memory objects; subprocess execution was prohibited after reading the pinned Git blobs and inventory. Injecting an adapter-open OSError produced: candidate provider present, original adapter present, zero new failure events. A subsequent rollback exited 2 and left the candidate provider present. Normal resume and normal post-acceptance failure rollback both succeeded under the same harness, isolating the incomplete-resume path.

**Fix:** Provide an audited recovery path for a recorded but incomplete resume. Validate immutable authority and original blobs without requiring complete candidate hashes, then restore both owned files and verify both original hashes before recording terminal rollback. Catch and sanitize ordinary infrastructure exceptions at the special-command boundary; retain a durable failure latch. Preflight inventory before mutation. Cover failure at each write/open/fsync boundary, including a truncated file; merely broadening the exception handler does not fix rollback admission.

### CR-02 — BLOCKER, resolved: The 600-second group deadline still contradicts the retained inner budgets

**File:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-timeout-recovery.py:160-162`; `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift:347-425` and the eight existing method bodies at `:46-345`.

Grouping preserves the static build cache, but the hard 600-second deadline does not honor the existing test deadlines requested for this correction. The class performs two setup commands allowing 120 seconds each and 37 renderer invocations allowing 30 seconds each: 1,350 seconds of nominal child waits before pipe draining, fixture work and teardown. For example, two successful 110-second setup calls plus 37 successful 20-second renderer calls take 960 seconds while every child remains within its own limit. The outer runner would still kill this permitted execution at 600 seconds.

This establishes a scheduling-budget mismatch, not the exact runtime stage of historical timeout 39 and not a prediction that the next run will take 960 seconds.

**Fix:** Derive one finite class deadline from the retained serial call budgets, with explicit allowances for pipe draining and bounded cleanup/teardown. Keep other methods' 60-second limits. Ensure forced termination also cleans only the launcher's owned scratch/fixture root, because killing the process group bypasses XCTest defers and class teardown. Exercise the budget and timeout-cleanup boundary with a virtual clock and fake child; no Swift/test changes or real evaluation are needed for that regression.

## Other scoped results and evidence

- Exact amendment, prior runner/authorization, failure hash and immutable 40-event prefix admitted under an in-memory six-scalar review. Candidate and adapter identities remain bound to the same committed bytes; no begin3 path is introduced.
- Normal resume appended sequence 41. Old receipts were rejected; five fresh receipts totaling 36/36/0/0 admitted revalidation. A later failure blocked accepted(), and ordinary rollback restored both originals. These observations do not resolve CR-01.
- The actual grouped dispatcher produced one bounded group child and correct aggregate counts with a synthetic transcript. Its filter matches all eight intended methods. The earlier commentary alleging incorrect escaping was withdrawn after checking the runtime string; there is no filter finding.
- Retained memory-only selftests: 133 passed, zero failed/skipped. New group-parser selftests: 11 passed, zero failed/skipped. These test the parser, not interrupted-resume cleanup or the class deadline envelope.
- Candidate SHA-256: `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`. Adapter SHA-256: `cf191001ae1245a82b042cc54eaca63aa6b3ba2abeed40e86781bc056eb159d9`. Reviewed runner SHA-256: `e1df70113e69508e836c3c9b8d42a165e68400a3b89b0de0c1f2cef59cddd82d`.
- Initial review probes verified durable production and ledger bytes unchanged. No Swift build, renderer, native test evaluation or commit was performed. Original `93-REVIEW.md` remains unchanged and pending.

## Final narrow re-review

Current runner SHA-256: `eb7ccc0f4dda224d8ad78080bf64bed95cb6bee7b1f608dd821c927dc54da116`, matching the repinned amendment. Candidate SHA-256 remains `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`. The preceding findings, line references and old runner hash are retained as historical evidence, not outstanding findings. No outstanding blocker was established in the two requested corrections.

CR-01 is resolved. Resume preflights inventory and stages replacement outside the SDK before atomic replacement. The special-command boundary sanitizes OSError/ValueError failures and captures owned hashes. Rollback separately admits original/candidate or exactly recorded partial hashes, and now delegates to restore_owned(), which verifies original Git blobs and uses the same atomic replacement operation. This removes the frozen restore function's incompatible source-scope prerequisite and in-place truncation. A memory-overlay probe executed actual rollback and restore_owned with only replacement writes mocked: mixed and recorded-truncated states restored both original hashes and recorded terminal rollback; an unrecorded truncated state failed owned_state_drift before any replacement. The retained atomic-replacement fault injections cover open, chmod, partial write, flush, fsync, replace and post-replace exceptions.

CR-02 is resolved. CLASS_TIMEOUT is 1,839 seconds: two setup children at 120+6+5 seconds, 37 renderer children at 30+6+5 seconds, plus an explicit 60-second fixture/teardown allowance. This covers the previously identified serial child-budget envelope while remaining bounded. class_child supplies a launch-owned TMPDIR through TemporaryDirectory; the unchanged child helper terminates the process group before scope exit removes that root. Fake-child success/timeout regressions verify cleanup scope exit, and the virtual-budget probe covers the declared envelope. This is source and mock evidence, not a measured runtime or native cleanup qualification.

Current selftests independently rerun: retained 133 passed and timeout-wrapper 27 passed, with zero failures/skips. No native evaluation was run. Earlier admission, fresh-receipt and failure-latch assessment remains applicable; phase acceptance is still revoked/pending actual same-candidate revalidation, and the original phase review remains unchanged.

Review execution disclosure: while the final helper correction arrived, the first re-review probe unexpectedly reached the new atomic restore helper and replaced the adapter with identical baseline bytes before its mocked hash check stopped execution. Both durable production hashes were verified to remain the exact originals. The corrected probe mocked replacement itself and performed the mixed/truncated/unowned checks entirely in memory. No ledger writes, candidate application, Swift execution or commit occurred; only this report's text was changed.
