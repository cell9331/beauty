---
phase: 93-distinct-nose-bridge-and-root-repairs
reviewed: 2026-09-10T07:21:57Z
depth: standard
files_reviewed: 4
files_reviewed_list:
  - scripts/check-phase93-nose-repair.py
  - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-GATE-AMENDMENT.json
  - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-01-PLAN.md
  - .planning/phases/93-distinct-nose-bridge-and-root-repairs/93-01-SUMMARY.md
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
---

# Phase 93: Infrastructure Amendment Review

## Narrative Findings (AI reviewer)

Current verdict: **clean within the precise CR-01 fix and amendment-binding scope**. No unresolved findings. Initial review history is retained below; its resolved finding is excluded from current frontmatter counts.

### CR-01 resolution — 2026-09-10T07:21:57Z

The admission guard at `scripts/check-phase93-nose-repair.py:678` now requires the selected RED receipt's gate identity to equal the effective baseline gate before any begin append. Existing source/count checks and the narrow regression exception remain intact. The added self-tests exercise the real `begin(1)` path with in-memory dependencies, check both acceptance and rejection, and restore patched dependencies in `finally`.

Independent recheck results:

- Self-tests passed **69/0/0**; direct `authorities()` and scoped `git diff --check` passed.
- Repeated the original reproduction using real authorities and historical ledger prefixes, intercepting only events and append in memory. Both the original five-event prefix and the six-event prefix from the first amendment were rejected with `hash_drift`, with zero captured begin events. The current seven-event ledger admitted the fresh receipt into the in-memory collector only.
- The latest recorded old-root RED is bound to the current gate and reports **3 discovered / 2 passed / 1 expected failure / 0 skipped**. This review inspected that receipt; it did not rerun Swift or append evidence.
- Current gate SHA-256: `fcee37289aeba5d657179e2d5a6c02f1caf33a3c514d81887c59b6688a9778e0`. The amendment matches this identity. Its original baseline and previous-gate bindings still match the committed bytes; loading changes only the effective gate field.
- The original baseline remains byte-identical to HEAD, the committed ledger remains an exact prefix, and the disk ledger stayed unchanged during the probes with **zero begin events**.

CR-01 is **resolved**. This verdict grants no broader phase, product or semantic validation.

### Resolved history: CR-01 — BLOCKER: Attempt admission accepts RED from the superseded gate

The following records the initial finding at 2026-09-10T07:15:39Z against the superseded gate; it is not a current defect.

**File:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-nose-repair.py:247-249`

**Affected admission:** `/Users/yakangwang/codes/beauty/scripts/check-phase93-nose-repair.py:677-681`

**Issue:** The amendment permits a new effective gate identity, but `begin(1)` obtains the historical RED receipt with `current=False` and compares only five source identities. It never compares the receipt's gate identity against the effective baseline gate. Consequently, the corrected gate admits attempt 1 using RED produced by the superseded gate, without the corrected-gate RED rerun required by the appended infrastructure amendment. Before this change, the frozen gate identity prevented this transition; the new amendment makes that missing check reachable.

**Reproduction:** Loaded the current gate and real authorities, supplied only the original five ledger events through an in-memory `events` replacement, and replaced `append` with an in-memory collector. The historical RED gate differed from the effective gate, yet `begin(1)` reached the begin append. Authorities passed; the disk ledger remained byte-identical and contained zero begin events. The current sixth event is a corrected-gate RED receipt, so the intended continuation presently has fresh evidence; its existence does not close the admission bypass.

**Fix:** Before admitting attempt 1, require `old["identity"][GATE] == base["gate"]` in addition to the existing source checks. Preserve the narrow regression-file exception and all historical receipts. Add a regression that rejects a previous-gate RED receipt with otherwise identical sources/counts and accepts a corrected-gate receipt. Update the reviewed amendment's corrected-gate hash after changing the gate; retain the original baseline bytes and previous-gate binding.

## Initial review scope and checks

Review was limited to the current gate diff, amendment JSON, last plan amendment and checkpoint summary, with direct reads of the baseline/ledger and affected admission/binding functions. No broader phase or product audit was performed.

- The named-method comparison permits the unchanged file or the exact approved two substitutions and rejects outside-method differences. No source-scope weakening was found in that correction.
- The amendment's baseline digest matches the original baseline bytes; its previous-gate digest matches the committed gate. Loading the amendment changes only the effective `gate` field in memory. Later registration bindings still hash the original baseline file.
- Gate self-tests passed 66/0/0. Direct `authorities()` passed. Scoped `git diff --check` passed. These checks do not cover the admission defect above.
- D-09 remains approved. No semantic/production changes, product-scope extension or attempt authorization was introduced by this review.

Only this aggregate review artifact was created and subsequently updated. No source, baseline, ledger or checkpoint files were modified by either review; no attempt was started and no commit was made.
