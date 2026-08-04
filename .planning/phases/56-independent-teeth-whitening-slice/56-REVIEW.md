---
phase: 56
reviewed: 2026-08-03
status: needs_fixes
baseline: 43f35f6
head: 4eb75e3
review_standard: bugs, security, fail-closed behavior, test quality, privacy, contract drift
findings: 3
blockers: 2
warnings: 1
---

# Phase 56 Code Review

## Verdict

**NEEDS FIXES.** Current repository tests and final regressions pass, but the
Phase 56 boundary checker has two reproducible false-green paths that invalidate
its fail-closed claim. Requirement bookkeeping also needs a clearer distinction
between a completed conditional contract and an implemented positive branch.

## Findings

### CR-56-01 — BLOCKER — Final evidence lifecycle and contradictory claims are not enforced

**Location:**
`.planning/phases/56-independent-teeth-whitening-slice/check_phase56_teeth_boundaries.py`,
`evidence_failures()`.

The checker still searches for Wave 1 substrings such as `status: draft` and
`pending`. The finalized evidence happens to contain those words in historical
explanation, so changing the actual YAML frontmatter from `status: validated`
back to `status: draft` still passes. Appending an affirmative contradiction
such as `Teeth whitening is implemented and released.` also passes because the
checker validates a handful of required substrings but does not enforce the
final lifecycle state or reject positive promotion/readiness claims.

**Impact:** A stale or self-contradictory evidence artifact can remain green
while the repository claims validation, violating T-56-05/T-56-07 and the
evidence-before-promotion contract.

**Reproduction:** A temporary copy of the live fixture returned `[]` from
`classified_live_failures()` after each independent mutation:

1. replace the first frontmatter `status: validated` with `status: draft`;
2. append `Teeth whitening is implemented and released.`.

**Required fix:** Parse the evidence frontmatter structurally and require the
exact current final state (`phase: 56`, `status: validated`, ASVS L1,
`block_on: HIGH`, exact six requirements). Require finalized result sections
without relying on historical `draft`/`pending` words. Reject affirmative
implemented/promoted/released/shipped/readiness claims for the closed candidate,
while permitting explicit nonclaims. Add real-fixture mutations for lifecycle
downgrade, missing/duplicate frontmatter, pending result, and contradictory
promotion prose.

### CR-56-02 — BLOCKER — `enamelWhitening` bypasses the candidate and alias boundary

**Location:** checker constants and `production_failures()` in
`.planning/phases/56-independent-teeth-whitening-slice/check_phase56_teeth_boundaries.py`.

The production scanner covers `teeth`, `tooth`, `dental`, and `oral`; the exact
candidate tuple covers four spellings. A tooth-specific synonym that avoids
those stems is accepted. In a temporary live fixture, adding this valid internal
alias before `BeautyEffectResolver` returned a clean failure set:

```swift
private func enamelWhitening(_ parameters: BeautyParameters) -> Float {
    parameters.skinWhitening
}
```

**Impact:** A production alias can borrow an existing whitening control without
using the currently banned names, violating TEETH-01, D-56-02/D-56-05/D-56-06,
and T-56-02/T-56-03.

**Required fix:** Add `enamel`/`dentition` candidate stems and explicit camel-case
aliases such as `enamelWhitening`, `enamelWhite`, and `enamelBrightness` to the
context-aware production/Demo boundary. Keep legitimate prose/tests handled by
fixture-specific checks rather than a repository-wide ban. Add real-source
mutations for an internal resolver helper, Testing SPI name, renderer/preset
name, and Demo control name using the synonym family.

### CR-56-03 — WARNING — Completed requirement marks can be misread as positive-branch implementation

**Location:** `.planning/REQUIREMENTS.md`, TEETH-01 through TEETH-06 checklist
and traceability table.

All six requirements are checked `Complete`, while TEETH-02 through TEETH-05
describe behavior that intentionally does not exist. The evidence correctly
records these rows as `not_applicable_closed_gate`, but the canonical requirement
page does not display that disposition next to the checked rows.

**Impact:** A later reader or milestone auditor may interpret the checklist as
proof that tooth support, containment, naturalness, and abstention algorithms
were implemented.

**Required fix:** State near the requirement checklist that a checked
conditional requirement means its branch was resolved, not that its positive
branch shipped. In the traceability table, record TEETH-01 as complete through
`false_branch_exact_absence`, TEETH-02..05 as complete through
`not_applicable_closed_gate`, and TEETH-06 as complete through `no_promotion`.
Do not alter the requirement wording or claim implementation.

## Evidence Reviewed

- Focused Phase 56 SDK suite: 96/96 passed.
- Current checker aggregate: 97/97 passed; current live mode reports exact
  59/5/72 and seven HIGH IDs.
- Full recorded Phase 56 regression: 539 SwiftPM tests executed with six
  documented opt-in skips and zero failures; Demo 119/119.
- Independent temporary-fixture review reproductions: evidence lifecycle
  downgrade accepted, contradictory promotion accepted, and
  `enamelWhitening` internal alias accepted.
- Production source remains unchanged at review time; the defects are checker
  and canonical-state enforcement gaps.

## Fix Gate

After fixes, rerun:

1. Python syntax and exact threat inventory parse.
2. Checker aggregate, live, and every T-56-01..07 mode with the expanded
   mutation denominator.
3. Focused 96-test SDK and focused Demo tests.
4. Full SwiftPM and explicit Demo build/test because both blockers affect the
   final security evidence.
5. Schema/UI/decision/gap/codebase-drift classification and diff hygiene.
6. Refresh evidence, validation, QUALITY_SCORE, SECURITY, PLANS, and this review
   with actual post-fix counts; do not reuse pre-fix results.

**Review status:** fixes required before independent phase verification.
