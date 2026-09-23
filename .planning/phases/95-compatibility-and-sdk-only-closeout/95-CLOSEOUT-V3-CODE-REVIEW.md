---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T02:52:17Z
depth: deep
files_reviewed: 6
files_reviewed_list:
  - scripts/phase95-closeout-evidence.py
  - scripts/test-phase95-closeout-evidence.py
  - scripts/phase95-genuine-gate.py
  - scripts/check-phase95-closeout.py
  - BeautySDK/Tests/BeautyCoreTests/RepairedControlSafetyTests.swift
  - scripts/check-sdk-only-boundary.sh
findings:
  critical: 3
  warning: 1
  info: 0
  total: 4
status: issues_found
---

# Phase 95: Closeout v3 tooling code review

## Narrative Findings (AI reviewer)

This is an independent, bounded review of closeout tooling and the strengthened safety test. It is **not** an independent implementation-repair approval, measurement admission, goal-verification receipt, or milestone completion. No source was modified, no actual portrait/full no-skip gate was run, and no real approval or completion JSON was created. Boundary-script review covers only the exact safety-test digest allowance; unrelated existing edits remain outside scope.

### CR-01 — BLOCKER: Finalization accepts absent and nonfinite portrait measurements

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-closeout-evidence.py:144-153` (also JSON decoding at line 63 and finalization at lines 227-247).

**Issue:** Each direction requires only `caseID` and a claimed `verdict`; only the root row additionally checks `metric`. Every signal count, signed margin, sibling margin, outside/protected-region measurement, fixture count, and failure reason can be missing or wrongly typed. Other case-to-metric associations are unchecked. The generated positive fixture at `scripts/test-phase95-closeout-evidence.py:49-57` contains exactly such incomplete rows and reaches completion. Thus receipt validation cannot reject contradictory or absent numerical evidence even when its transport hashes are internally consistent. The comment assigning numerical conjunction to the classifier does not validate that the retained report actually contains that classifier's required measurements.

There is also a concrete nonfinite bypass: `json.loads(..., parse_constant=...)` rejects literal `NaN`/`Infinity` but decodes `1e999` as positive infinity. A generated portrait with a row numeric field containing `1e999`, and coherently rebound generated binding/checks/goal hashes, successfully reached `finalize()` and published a temporary-fixture completion. All artifacts stayed in an automatically removed temporary directory. This contradicts the v3 contract's rejection of missing/nonfinite/wrong-type evidence. Independently authored receipt attribution remains a workflow duty; this finding concerns schema and predicate validation, not cryptographic authenticity.

**Fix:** Require the exact successor row schema, exact per-direction metric identities, strict integer types/ranges excluding booleans, exact protected-region inventory, and well-typed failure reasons. Recompute the existing source/neutral/sibling/signal/protection conjunction and compare it with each declared verdict; preserve the frozen thresholds. Reject nonfinite decoded numbers recursively or use a checked `parse_float` in addition to `parse_constant`. Add generated mutations with recomputed receipt hashes for omitted fields, wrong metrics/types, negative or overflowing counts, failed protections, contradictory margins/verdicts, and exponent overflow. The future v3 classifier must supply this complete schema before live closeout is admitted.

### CR-02 — BLOCKER: No-skip accounting accepts impossible executed totals

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-genuine-gate.py:90-106` and `/Users/yakangwang/codes/beauty/scripts/phase95-closeout-evidence.py:172-177`.

**Issue:** The reused transcript validator checks a positive aggregate and each opt-in name, but does not reconcile the aggregate with actual test-case events. `counts()` returns the aggregate unchanged. A generated transcript with all eight distinct required opt-ins passing and `Executed 1 test, with 0 failures` is accepted and yields `executed=1, opt_in_tests=8`. `validate_counts()` also accepts this impossible combination. Consequently CHECKS can declare a valid full execution from contradictory accounting, which finalization does not reject.

**Fix:** Reconcile the selected full XCTest run's unique terminal test-case events with its executed total, reject duplicate/failed/skipped terminal events and contradictory suite outcomes, and reconcile any supported Swift Testing accounting explicitly. At minimum, persisted full-run totals must be at least the eight required opt-ins, but that lower bound alone is not sufficient reconciliation. Add an eight-events/one-total negative control and controls for extra failure events, mismatched larger totals, and duplicate identities.

### CR-03 — BLOCKER: Archive-first evidence does not require archive verification before tests

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-genuine-gate.py:98-105` and `:158`.

**Issue:** Marker positions are compared only with other markers. They are never compared with the actual SwiftPM test run. A generated transcript containing all eight passing test-case events and its passing all-tests summary **before** every prerequisite marker is accepted, provided the markers appear in their own expected order. `run()` then publishes `archive_first=True`. The current wrapper is visibly archive-first, but this acceptance logic fails to prove the advertised stage order and misses a reordered/regressed wrapper transcript.

**Fix:** Require all prerequisite completion markers before the first full-run start/test event, and require the final no-skip success marker after the unique successful terminal summaries. Reject markers interleaved with the test run. Add generated negative controls for tests-before-archive, prerequisite markers after the summary, and final success before the terminal summary.

### WR-01 — WARNING: Recovery assertions have no positive rendering control

**File:** `/Users/yakangwang/codes/beauty/BeautySDK/Tests/BeautyCoreTests/RepairedControlSafetyTests.swift:19-43`.

**Issue:** Valid renders are compared only with each other. Recovery compares `before.bytes` with `recovered.bytes`, while only the rejected render is compared with the source. An engine that still invokes the detector three times but always returns the original image satisfies every assertion, including `P95S_RECOVERY`. This does not show that rendering resumes after rejection/reset. The v3 contract correctly says other suites and goal review must prove broader efficacy/safety; that limitation does not give this particular recovery assertion a positive control.

**Fix:** For each carrier used to claim recovery, prove that the valid pre-rejection and recovered outputs exercise the intended active path with a meaningful generated-image pixel change or appropriate internal availability assertion, then retain the byte-equality recovery comparison and rejected-source identity. Use a generated fixture with sufficient signal if the current low-contrast fixture cannot expose the transformation. A deliberately forced neutral result should fail the recovery check. Do not treat this fixture alone as portrait efficacy evidence.

## Validation and limits

- Generated evidence suite: **15 tests passed**.
- Genuine-gate generated self-test: **7 transcript mutations and 6 review mutations rejected; 3 child-bound checks passed**.
- Additional generated counterexamples: **1 incomplete portrait positive fixture accepted; 1 nonfinite portrait finalized; 1 contradictory-total transcript accepted; 1 archive-after-tests transcript accepted**. Only fixed reason/count aggregates are retained here.
- A focused SwiftPM invocation waited on another owner's build lock and was terminated before execution. No native test result is claimed by this review. The coordinator separately reported its focused safety/compatibility result; that report is not substituted for reviewer execution here.
- Same-filesystem exclusive publication, duplicate-key rejection, hash rebinding, current-input checks, and scoped safety-test hash matching were traced. No separate defect is reported in the publication implementation or exact boundary hash update. Existing Python generated tests cover exclusive publication and several stale/missing/interrupted-write cases, but passing tests do not resolve the findings above.
- Serena and dedicated Read/Write tools were unavailable. Context and cross-file calls were inspected through read-only shell commands; only this report was created through the available patch tool. No raw pixels, private fixture locators, geometry, or child transcripts are retained.

## Reviewed identities

| File | SHA-256 |
| --- | --- |
| `scripts/phase95-closeout-evidence.py` | `6cecaef51586019fdc758fa8879735ccbdb35a3a6cbcaa751a973ee2c7a49610` |
| `scripts/test-phase95-closeout-evidence.py` | `3f08fa081e611caf5a1b5c9d88e5f478368fb19e6bf636848c2ed0a118379457` |
| `scripts/phase95-genuine-gate.py` | `57ff0c5bceef774615ce1ea4e410e04e9b534198f9941ad4595eca8b5158ca28` |
| `scripts/check-phase95-closeout.py` | `c63e6c4b0b7808e53fd8d028875511859f2ba68e58ece8d5f0858642e2d08606` |
| `BeautySDK/Tests/BeautyCoreTests/RepairedControlSafetyTests.swift` | `f9b7fc6807f091bdfd048ebb2dbec6b9aee74e20c2a2493c88dd835d5fc0190e` |
| `scripts/check-sdk-only-boundary.sh` | `07377b541fd00037c05bc3ff8c669797123f92d13da1169019af455ccc811bec` |
| Context: `95-CLOSEOUT-CONTRACT-v3.md` | `00b9a18ff94acfa43f8bf5ab4567f5f534732b59ba400fe1c4b04958d18db348` |

The boundary script's allowed safety-test SHA-256 exactly matches the reviewed safety test. Whole-file hashes record the reviewed worktree, not approval of unrelated pre-existing edits.

_Reviewer: closeout_review (gsd-code-reviewer); tooling review only._
