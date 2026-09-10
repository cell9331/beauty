---
phase: 93
reviewed: 2026-09-10
status: clean
blockers: 0
candidate_sha: bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45
runner_sha: 4b07195cf2855911d1c5a0d840274f2f26d9e0260f6fe76efd3da041d462f7c3
---
# Phase 93 attempt 2: independent pre-evaluation review

## Narrative Findings (AI reviewer)

**Current re-review:** 2026-09-10T09:01:17Z. **Clean: zero active blockers, zero warnings.** CR-01, CR-02 and CR-03 are resolved for the exact identities below. This is pre-evaluation source/admission review, not Phase 93 acceptance or native candidate validation.

**Candidate SHA-256:** `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`

**Final runner SHA-256:** `4b07195cf2855911d1c5a0d840274f2f26d9e0260f6fe76efd3da041d462f7c3`

**Final manifest SHA-256:** `85411d57f9121dba19d58123082558c23d72fb90ec6714db31d10c05859379fb`

### Final narrow regression results

Reviewed the recovery-owned failed-finish branch at `/Users/yakangwang/codes/beauty/scripts/check-phase93-attempt2.py:94-109` and the persistent memory-only regressions at lines 229-253. The independent probe exercised the actual CLI dispatcher, recovery authority/latch, frozen successful-finish function and original restoration implementation. Ledger operations and output file descriptors were redirected to memory; test execution was prohibited.

- **Exact CR-03 counterexample resolved:** all five current passing receipts followed by a provider safety failure now allow failed cleanup. Both original production files are restored byte-for-byte, their hashes are verified, and exactly one terminal finish records `status: failed`, the last failure's category/counts, the pre-rollback candidate identity and `production_restored`. The frozen finish function is not called on this path.
- **Rejected-success cleanup resolved:** semantic failure plus complete passing receipts still rejects successful finish as `attempt_failed`; the subsequent failed finish now restores both originals and records that last failure rather than hitting the old receipt-dependent safety guard.
- **Failed-finish invariants:** incomplete-receipt cleanup also passes. Historical ledger prefixes remain byte-exact. Repeating cleanup produces no additional restoration writes or terminal finish, and provider replay remains rejected. The scoped latch override resets on successful and rejected exits.
- **Successful/post-acceptance paths retained:** failure-free successful finish calls the unchanged frozen gate and retains the candidate. A later compatibility failure blocks execution; failed cleanup restores both originals, preserves the original successful finish exactly and appends the separate `recovery_rollback` receipt.
- **Persistent self-test:** **133/0/0**, including both newly added actual-wrapper cleanup regressions. The final manifest matches the final runner and all 17 pins. The strict six-scalar review parser and replay latch retain their prior resolved dispositions.

Only the reported cleanup counterexamples and their directly related terminal-state invariants were revisited. No arithmetic/candidate changes or numerical sweeps were introduced. The candidate, original gate, live production and original 26-record ledger remain unchanged; ledger SHA-256 is `2692dfdf94f9280856886034997bad5822b58d829254ad59e392b3215dd761ee`. All simulated attempts, receipts, failures, restoration bytes and finishes stayed in memory. Only this report was updated; no Swift build/test, rendering, durable ledger event, production edit, new attempt or commit occurred. Parent-owned application/evaluation remains subject to the existing D-10 scope and two-attempt ceiling.

## Prior re-review — preserved history, 2026-09-10T08:58:44Z

This record applies to runner `3117340df750301f593d51c13edb464f62cefff0820be54f9a67872e9d8a4b8b`; CR-03 is now resolved as recorded above.

**Historical re-review verdict:** One active BLOCKER; zero warnings at that time. Earlier findings and evidence are retained below as history.

**Candidate SHA-256:** `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`

**Current runner SHA-256:** `3117340df750301f593d51c13edb464f62cefff0820be54f9a67872e9d8a4b8b`

**Current manifest SHA-256:** `37051cd76cb53a88279821822811196db4a679b75a2ae93a3685d3b7b2e6cfb5`

### CR-03: BLOCKER — Failed-finish cleanup still depends on successful-finish eligibility

**File:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-attempt2.py:75-94`, specifically the delegation at line 94.

**Related code:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-nose-repair.py:809-814`.

**Issue:** The scoped failed-finish flag correctly bypasses the new failure latch, but an unfinished attempt still delegates to the original `finish`. When all five current gate receipts exist, that function requires every subsequent failure to have category `semantic_signal` even for `status == "failed"`. A later safety/infrastructure failure therefore raises `safety_failure` before reaching rollback. No failed finish is recorded and the candidate/D-09 production bytes remain applied. Retrying the same cleanup encounters the same check. This leaves the rollback portion of CR-01 unresolved.

**Reproduction:** Using the actual CLI dispatcher, wrapper authorities, delegated original finish, hash-linked in-memory ledger and original `restore_original` implementation with only output file descriptors redirected to memory:

1. Establish simulated begin 2 and the pinned candidate/D-09 bytes.
2. Supply current passing receipts for provider, registration, metrics, pixels and lifecycle, totaling 36 tests.
3. Append an attempt-2 provider `assertion_failure` with the same identity, then dispatch `finish --attempt 2 --status failed`.
4. Result: exit 2 / `safety_failure`, zero restoration writes, neither production file restored, and no finish-2 event.

The same cleanup failure followed the required semantic-replay regression: the new latch correctly rejected `finish --status passed` as `attempt_failed`, but that rejection became a failure event; with complete receipts present, the subsequent failed finish then returned `safety_failure` instead of restoring production.

**Fix:** Give unfinished attempt-2 failed cleanup a recovery-owned path that validates pins and attempt order, captures the actual failure category/counts, restores both original production files, verifies their hashes and appends exactly one failed finish. It must not run the original successful-receipt/failure-category eligibility checks. Preserve the existing post-acceptance `recovery_rollback` receipt path, the original successful finish, and the `finally` reset of the scoped flag. Add memory-only tests for both complete-receipt cleanup cases above before repinning.

### Narrow re-review results

- **CR-01 replay/acceptance portions corrected:** provider replay after a safety failure and successful finish after semantic failure plus later passing receipts both reject with `attempt_failed`. No test-execution sentinel was reached. Post-acceptance failure also rejects further compatibility execution.
- **CR-01 cleanup partially corrected:** failed finish with incomplete receipts restored both original files and appended a failed finish. Post-acceptance failed finish restored both files, preserved the original successful finish exactly, and appended `recovery_rollback`. The scoped flag reset in success and failure cases. Complete-receipt cleanup remains blocked by CR-03.
- **CR-02 resolved:** the actual authorization path admitted the declared six-scalar frontmatter and rejected an issues-found verdict with a fenced success example, duplicate blockers, Boolean/quoted blockers and an incorrect runner hash. Body examples no longer supply admission fields.
- Wrapper self-test: **131/0/0**. All 17 manifest pins matched. Candidate, original gate, live production and the original 26-record ledger remained unchanged. No arithmetic sweep or further candidate assessment was performed.

Re-review scope was the revised wrapper, repinned manifest and the previously traced delegated finish/authorization functions. All simulated begin/receipt/failure/finish events and restoration outputs were memory-only. No Swift build/test, rendering, durable ledger mutation, production edit, new attempt or commit occurred. Only this report was updated. This is not Phase 93 acceptance.

## Earlier review — preserved history, 2026-09-10T08:50:49Z

The following verdict and line references apply to runner `76ca1bb536684030383a01d683286f392342717dd10c27991e8f12e60875aa92`. They are historical; current dispositions are above. Original review depth: deep. Seven source files were reviewed: `/tmp/beauty93-attempt2-NoseWarpProvider.swift`, `scripts/check-phase93-attempt2.py`, `scripts/check-phase93-nose-repair.py`, `BeautySDK/Tests/BeautyEffectsTests/NoseRepairFieldTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift`, `BeautySDK/Sources/BeautyEffects/Warp/LandmarkGeometryHelper.swift`, and `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`. Original finding counts: critical 2, warning 0, info 0.

**Verdict:** Two recovery-runner BLOCKERs prevent admission. No concrete blocker was established in the replacement provider arithmetic. This report does not authorize evaluation or accept Phase 93.

**Candidate SHA-256:** `bafa9d2ac365f104e2dc0ec16ed080cddcced1199a16d471c27d5923d5166b45`

**Runner SHA-256:** `76ca1bb536684030383a01d683286f392342717dd10c27991e8f12e60875aa92`

### CR-01: BLOCKER — Attempt-2 failures do not stop replay or invalidate acceptance

**File:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-attempt2.py:67-72`, with delegation at lines 137-144.

**Related code:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-nose-repair.py:797-816` and `830-836`.

**Issue:** Recovery authorities require a begin-2 event and matching files, but never reject subsequent failure events. The unchanged gate also permits historical `semantic_signal` failures when the latest receipts pass. Consequently the wrapper does not enforce D-10's requirement that failure consumes attempt 2 and stops. Matching source/runner hashes establish identity, but do not invalidate earlier success after a later failure.

**Reproduction:** In-memory overlays used the actual pinned files and original 26-record ledger, a simulated reviewed begin-2 event, and candidate/D-09 source bytes. All writes were replaced with memory operations and test execution with a sentinel. Results:

- After an attempt-2 provider `assertion_failure`, calling the real delegated `provider("green")` reached the test-execution sentinel instead of rejecting replay.
- A failed pixel receipt and `semantic_signal` failure followed by current passing receipts for all five required gates caused the real delegated `finish(2, "passed")` to append an in-memory finish with both status and category `passed`.
- After that successful finish, a later compatibility `assertion_failure` still left `accepted()` successful. Existing acceptance therefore cannot reliably guard later compatibility/closeout operations.

**Fix:** Add recovery-specific command/transition admission that latches every failure after begin 2, rejects further evaluation and successful finish, and invalidates acceptance/closeout after a later failure. Preserve a dedicated failed-finish/owned-rollback path; simply throwing unconditionally from `authorities()` would also block the delegated rollback. Keep the original gate immutable and implement these restrictions in the wrapper. Add memory-only regressions for safety replay, semantic failure followed by passing receipts, and failure after successful finish. Historical attempt-1 dispositions must remain unchanged.

### CR-02: BLOCKER — Review admission ignores the actual frontmatter verdict

**File:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-attempt2.py:34-36`.

**Issue:** The two multiline regex searches match anywhere in the report, including fenced examples. They do not parse the leading frontmatter or reject conflicting verdict/count fields. A report whose actual frontmatter rejects the candidate can authorize begin 2.

**Reproduction:** With all actual pins and the terminal ledger unchanged, an in-memory report had leading frontmatter declaring `status: issues_found` and `blockers: 1`, the exact candidate/runner hashes, and a fenced example containing the successful status/count lines. The real `authorization()` returned successfully. No report file or begin event was written.

**Fix:** Parse exactly one leading YAML frontmatter block with duplicate-key rejection. Require its status to be the literal clean verdict and its blockers value to be an integer zero; reject missing, ambiguous, duplicate, or wrongly typed values. Body examples must never supply admission fields. Retain the exact candidate/runner identity checks and add positive and negative memory-only parser tests before repinning the wrapper.

## Mathematical and scope assessment

Byte comparison against failed candidate `e4e89680` established that only `phase93Field` differs. Candidate-1 radii, caps, shared helpers, sibling dispatch, root ownership, disk/straddle guards and strict renderer cutoffs remain unchanged.

The directed Double quotients and additions upper-bound the cap sum. The predecessor of the Double ceiling and downward division/products bound each allocation. Source-disk admission and the per-point bound place endpoints within the factor-of-two interval needed for exact Float subtraction. The one-neighbor inward adjustment is followed by explicit sign/magnitude checks, so endpoint reconstruction cannot silently enlarge an admitted allocation. Every rejected required point still returns the entire field empty; there is no cutoff compensation or redistribution. The final stored-sum guard remains necessary.

Independent in-memory binary32 reconstruction with exact rational checks exercised the existing frozen arithmetic cases, without invoking a sampler or renderer:

| Frozen support count | Reconstructed cap budget | Quarter / half / cap cutoff admission |
| --- | --- | --- |
| 2 | 0.4499982828740846 | admitted / admitted / admitted |
| 4 | 0.44999642022902386 | admitted / admitted / admitted |
| 16 | 0.4499703431981733 | admitted / admitted / admitted |
| 64 | 0.44989583739574335 | abstain / abstain / admitted |

The inspected quarter/half/cap and weakened-strength arithmetic cases had maximum scaling errors below one target ulp for both fields, within the frozen eight-ulp bound. These probes support the reconstruction correction only. Native whole-field/dense-map and mixed-sibling assertions, complete cutoff/reuse coverage, actual pixels, metadata and semantic effectiveness remain unexecuted. The real-arithmetic isolated-field argument does not establish arbitrary Float, raster, GPU or mixed-legacy injectivity.

## Review evidence and boundary

The wrapper self-test passed **114/0/0**. Its six additional checks cover terminal-history mutations; they did not catch the two admission defects above. All 17 manifest pins matched. Both live production files matched their original rollback hashes. The original terminal ledger had exactly 26 records and SHA-256 `2692dfdf94f9280856886034997bad5822b58d829254ad59e392b3215dd761ee`; it remained unchanged after the probes. Old registration receipts were correctly rejected as stale under the candidate/runner identity.

Reviewed D-10, authorization/derivation/manifest, the appended 93-03 disposition, failure analysis, frozen tests and relevant project contracts. Serena and dedicated Read/Write tools were unavailable; local reads, memory-only Python probes, the allowed self-test and the artifact-writing tool were used. Only this report was authored. No Swift build/test, rendering, live-source edit, durable ledger event, new attempt or commit occurred. Correct and independently re-review the wrapper and its pins before parent-owned application/evaluation; no third attempt is authorized.
