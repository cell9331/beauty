---
phase: 89-semantic-validation-baseline
reviewed: 2026-08-26T04:37:50Z
depth: standard
files_reviewed: 8
files_reviewed_list:
  - scripts/face-feature-batch-manifest.json
  - scripts/compare-face-feature-batches.swift
  - scripts/run-face-feature-batches.sh
  - example-images/README.md
  - QUALITY_SCORE.md
  - SECURITY.md
  - RELIABILITY.md
  - PLANS.md
findings:
  critical: 0
  warning: 3
  info: 0
  total: 3
status: issues_found
---

# Phase 89: Code Review Report

**Reviewed:** 2026-08-26T04:37:50Z
**Depth:** standard
**Files Reviewed:** 8
**Status:** issues_found

## Summary

The iteration-2 blockers are fixed on the repository's default paths. Comparator publication now preserves aliased manifest/fixture/output bytes and uses descriptor-relative atomic replacement. A missing input with the normal safe report path returns exit 2 and replaces stale pass/fail content. Destructive runner mutations now execute under held no-follow parent descriptors, and the cleanup documentation accurately distinguishes verified removal from `cleanup_failure`. The original five critical findings and exact-reason warning remain fixed as well.

The final re-review nevertheless found one new path-contract defect introduced by the descriptor helper integration: the shell admits custom report paths containing spaces, Unicode, or longer legal component names, but the mutation helper rejects them. When input admission subsequently fails, failure-envelope publication also fails and the prior semantic report remains unchanged despite the destination having been marked admitted. Two additional consistency defects remain: preflight inventory failures can still escape as undocumented exit 1, and the Phase 89 closeout ledger retains the obsolete 542-mutation count alongside the current 554 count.

Verification performed: JSON parse, Swift type-check, shell syntax, called-helper Python syntax, `git diff --check`, comparator self-test (`554` mutations), cleanup/path-swap self-test, stale/alias boundary self-test, and exact `75/65/8` preflight all passed. An isolated comparator alias probe preserved the manifest bytes. An admitted report-path probe under a real directory containing spaces returned exit 2 but left the prior report digest unchanged while failure publication emitted `path_operation_failed`. Called path helpers were traced because they implement the reviewed runner's mutation behavior; the configured review scope remains the eight files listed above. No private fixture paths, pixels, identities, or derived media are included here.

## Narrative Findings (AI reviewer)

## Warnings

### WR-01: WARNING — Admitted custom paths can prevent failure publication and preserve stale semantic evidence

**File:** `scripts/run-face-feature-batches.sh:75-142,283-300,427-468`

**Issue:** `admit_report_destination` and `admit_paths` accept any non-empty absolute component except newline, carriage return, NUL, and `..`. All later mutations are delegated to the new path helper, whose component contract is narrower: ASCII `[A-Za-z0-9_.-]`, at most 120 characters. The runner never applies that contract during admission. Thus `report_destination_admitted` can be set for a path the publisher cannot open. A probe using a canonical `/private/tmp` directory whose name contained spaces, a pre-existing semantic report, and a missing input returned the documented exit 2, but both failure-publication attempts emitted `path_operation_failed` and the report SHA-256 remained byte-for-byte unchanged. Unicode and legal 121–255-byte components have the same mismatch. Exit 2 still prevents the invocation from earning credit, but the admitted-path state and promised current failure envelope are inconsistent, leaving avoidable stale-report ambiguity. This contradicts `example-images/README.md:120-125`, `SECURITY.md:305-311`, and `RELIABILITY.md:324-331`.

**Fix:** Use one path contract for admission and mutation. Prefer making the descriptor helper accept every valid POSIX component except empty, `.`, `..`, NUL, and `/`, with byte-length bounded by the filesystem limit; otherwise explicitly reject the helper's narrower grammar during both report-only and full admission and document it. Do not set `report_destination_admitted` until the exact helper can open/create the parent. Extend the boundary self-test with spaces, Unicode, and 120/121/255-byte component boundaries and require either a current failure envelope or an explicit pre-admission rejection that cannot leave a document represented as current.

### WR-02: WARNING — Preflight inventory faults can return undocumented exit 1

**File:** `scripts/run-face-feature-batches.sh:475-492,497-558,583-588`

**Issue:** `validate_inventory` is invoked as a bare command under `set -e`. If the comparator self-test, renderer inventory, or manifest inventory check returns 1, the EXIT trap intentionally skips both failure publication and status normalization when `preflight_only == 1`, so the process exits 1. The command contract describes admission/inventory faults as exit-2 infrastructure failures; only the no-mutation behavior should differ for preflight. This makes automation interpret the same fault differently depending on whether rendering was requested.

**Fix:** Wrap `validate_inventory` and explicitly `exit 2` on failure, or normalize every nonzero preflight infrastructure status to 2 while continuing to suppress report mutation. Add preflight mutations for comparator self-test failure, malformed manifest inventory, and renderer-list failure, each asserting exit 2 and unchanged output/report state.

### WR-03: WARNING — Phase closeout records conflicting self-test counts

**File:** `PLANS.md:518,530,533`

**Issue:** The Phase 89 generated-gate and checklist rows correctly record the current comparator self-test as 554 mutations, but the closeout row still claims the post-review comparator self-test ran 542. The executable now reports 554. Conflicting counts weaken the ledger as reproducible evidence and obscure which remediation state was actually closed.

**Fix:** Replace the stale 542 count with 554 and record the cleanup/path-helper plus stale/alias boundary self-tests in the same closeout row so the documented evidence matches the current commands.

---

_Reviewed: 2026-08-26T04:37:50Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
