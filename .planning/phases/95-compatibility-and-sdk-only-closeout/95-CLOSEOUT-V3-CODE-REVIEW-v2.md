---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T03:01:19Z
depth: deep
files_reviewed: 7
files_reviewed_list:
  - scripts/phase95-closeout-evidence.py
  - scripts/test-phase95-closeout-evidence.py
  - scripts/phase95-genuine-gate.py
  - scripts/check-phase95-closeout.py
  - BeautySDK/Tests/BeautyCoreTests/RepairedControlSafetyTests.swift
  - BeautySDK/Tests/BeautyCoreTests/RepairedControlSafetyFixture.swift
  - scripts/check-sdk-only-boundary.sh
findings:
  critical: 2
  warning: 0
  info: 0
  total: 2
status: issues_found
---

# Phase 95: Closeout v3 tooling re-review

## Narrative Findings (AI reviewer)

Bounded re-review of fixes to `95-CLOSEOUT-V3-CODE-REVIEW.md`, plus the generated RGB fixture. The first report remains unchanged. This report is not a measurement admission, implementation-repair approval, goal-verification receipt, or milestone acceptance. No source edits, portraits, SwiftPM, full no-skip runs, or actual acceptance JSON were performed/created by this reviewer.

### Original finding dispositions

| Finding | Disposition and evidence |
| --- | --- |
| CR-01 — BLOCKER | Resolved in the reviewed tooling: exact row fields, per-case metrics, strict Int64 quantities, protection inventory, and failure reasons are checked. Source/neutral/sibling/locality/protection conjunction matches the original comparator for the required single fixture. The original manifest hash is checked. `parse_float` now rejects exponent overflow and floating literals. All 128 individual row-field omissions reject. Generated rebinding tests reject failed protection evidence. Frozen manifest thresholds are preserved rather than replaced with zero ceilings. |
| CR-02 — BLOCKER | Original contradictory-total defect resolved: all unique terminal XCTest events must pass and equal the aggregate; persisted full-run totals must be at least eight. The eight-events/one-total original counterexample now rejects. A distinct exact-opt-in identity gap is documented below as CR-04. |
| CR-03 — BLOCKER | Partially resolved for XCTest; still open for the supported Swift Testing runner, as documented below. |
| WR-01 — WARNING | Static assertion gap resolved: both pre-rejection and recovered renders must differ from source, while still matching each other. The new deterministic RGB fixture supplies nonuniform signal with bounded byte values and unchanged opaque alpha. A forced all-neutral path now fails these assertions. Native execution is pending coordinator verification and is not claimed here. |

### CR-03 — BLOCKER: Stage ordering still ignores the supported Swift Testing runner

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-genuine-gate.py:105-116`.

**Issue:** Ordering is now enforced for XCTest events/start lines and its all-tests summary, but the transcript parser also recognizes Swift Testing's `Test run started` and `Test run with ... passed` messages. Neither contributes to `first_test` or the last terminal summary. Two generated mixed-runner counterexamples remain accepted: (1) Swift Testing starts before the archive/prerequisite markers; (2) the final no-skip success marker appears before Swift Testing's terminal success summary. Both use a valid eight-event XCTest run and the supported zero-test Swift Testing summary, so they are accepted by both validators despite violating the claimed full-process stage order.

**Fix:** Include supported Swift Testing start/event positions when proving that all prerequisite markers precede execution, and include every required terminal runner summary when proving final wrapper success is last. Require coherent start/end pairing and order. Add generated mixed XCTest/Swift Testing positive and negative controls, including a zero-test Swift Testing runner. This closes the original ordering finding without requiring native execution for the parser tests.

### CR-04 — BLOCKER: Opt-in credit still accepts different method identities

**File:** `/Users/yakangwang/codes/beauty/scripts/phase95-genuine-gate.py:95-112` (called validator: `scripts/check-no-skip-transcript.py:58-60`).

**Issue:** Terminal event reconciliation checks uniqueness and totals, but never matches those identities exactly to the eight required opt-ins. The called legacy validator uses the unanchored pattern `expected_name + .*passed` over arbitrary transcript text. Replacing every required method with its name followed by `Different` still passes `counts()` with eight unique successful events and a matching total, even though none of the eight exact required tests executed. The output nevertheless reports `opt_in_tests=8`. This is a demonstrated missing-opt-in acceptance, not a proposed test naming convention.

**Fix:** Derive opt-in credit from parsed successful terminal test-case identities, normalize only the documented suite/module qualification, and require each exact expected method once. Reject suffix/prefix lookalikes and arbitrary log-line occurrences. Prefer shared strict parsing or add the exact identity condition in this gate without weakening the existing transcript validator. Add controls replacing all eight names with suffixed names, duplicating an exact name under different suites, and embedding expected names in unrelated logs.

## Validation

- Generated evidence tests: **16/16 passed normally and 16/16 with Python optimization enabled**.
- Genuine-gate self-test in both modes: **10 transcript mutations rejected, 6 review mutations rejected, 3 child checks passed**.
- Additional schema probes: **128/128 individual row-field omissions rejected**.
- Additional transcript counterexamples: **2/2 mixed-runner ordering violations accepted; 1/1 all-eight suffixed-identity replacement accepted**.
- Source-only review confirms recovery positive assertions and exact updated safety-test hash. Native tests were deliberately not started; their outcome remains a separate coordinator responsibility.
- No raw child transcript, pixel array, private path, or support geometry is persisted. Generated fixture files existed only in temporary test roots and were cleaned. Only this report was written.

## Reviewed identities

| File | SHA-256 |
| --- | --- |
| `scripts/phase95-closeout-evidence.py` | `8ff124be22829fb1be66da869144846ab55d3b40f89ffc562bded3bfe0ee76f9` |
| `scripts/test-phase95-closeout-evidence.py` | `de0b3069822b761c8977cb9cd37a7f2ee62a8603e32478d9ecf673d0b2ebcbd0` |
| `scripts/phase95-genuine-gate.py` | `5201f4c88ec6cc1ba6a46a075f772bb8419e56b4da8a3af44d70ae609fa7919f` |
| `scripts/check-phase95-closeout.py` | `276b56b812b5be73eab0c94ff073a3defb5eea2231283554ea2a0cb6251ea8e0` |
| `BeautySDK/Tests/BeautyCoreTests/RepairedControlSafetyTests.swift` | `342f7baeed85577a367a8c1fea0c51a4c7b7d77db07cfb3806cf28c899ccc6ac` |
| `BeautySDK/Tests/BeautyCoreTests/RepairedControlSafetyFixture.swift` | `2fa397a576e26b678a7b6ef3c3bf8dc1564a171e9d5a146f08bca9ca02c1b4b7` |
| `scripts/check-sdk-only-boundary.sh` | `ae267517be928439e56fa839881896a4fd587d5a9bbecbcc51c1407a962d0f27` |
| Context: `95-CLOSEOUT-CONTRACT-v3.md` | `00b9a18ff94acfa43f8bf5ab4567f5f534732b59ba400fe1c4b04958d18db348` |

The boundary-script scope is only the exact safety-test digest update; whole-file hashing does not approve unrelated edits. Remaining findings must be fixed before this tooling is used to issue acceptance.

_Reviewer: closeout_review (gsd-code-reviewer); tooling review only._
