---
phase: 62-sclera-evidence-and-admission-contract
plan: "03"
subsystem: evidence-admission
tags: [sclera, licensed-evidence, guarded-review, reviewcore, privacy]
requires: [62-02]
provides: [accepted-sclera-pair, exact-open-sclera-decision, serializer-byte-reproduction]
affects: [62-04, 62-05, 63]
tech-stack:
  added: []
  patterns: [guard-before-score, post-feather-reclip, phase54-serializer-authority]
key-files:
  created: []
  modified:
    - .planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-EVIDENCE-DECISIONS.json
    - .planning/phases/62-sclera-evidence-and-admission-contract/62-evidence-admission.contract.test.js
    - .planning/phases/62-sclera-evidence-and-admission-contract/62-SCLERA-EVIDENCE-ADMISSION-CONTRACT.md
    - .planning/phases/62-sclera-evidence-and-admission-contract/62-private-evidence-runner.js
    - .planning/phases/62-sclera-evidence-and-admission-contract/62-VALIDATION.md
key-decisions:
  - The authorized positive and negative are independent genuine rows; same-person identity is unnecessary.
  - Only guarded baseline derivatives passed original-detail review; legacy and adversarial artifacts remain ineligible.
  - ReviewCore rejected an inconsistent local acceptance score before any ledger write, proving the frozen positive coverage threshold remains authoritative.
metrics:
  tasks: 2
  harness_self_tests: 24
  contract_tests: 22
  required_private_tests: 22
  fixed_reviews: 4
  tracked_files_scanned: 1376
completed: 2026-08-07
---

# Phase 62 Plan 03 Summary

## Outcome

Accepted one authorized genuine visible-redness positive and one authorized
genuine normal/already-low-redness negative after guarded original-detail
review. Both originals retain exact local bytes, each owns a predeclared opaque
identity and polarity, and every original/mask/after asset plus all harness and
QA outputs remains ignored and untracked.

The Phase 54 serializer now independently records teeth and sclera open at
`2/2/2/0/2`, with upper-eyelid fullness unchanged and closed. A fresh required
private child reproduces the canonical ledger bytes exactly. No runtime sclera
field, demand, provider, renderer case or Demo mapping exists at this commit.

## Fixed Review Result

| Polarity | Target | Coverage | Protected leakage | Naturalness | Structure | Decision |
| --- | --- | ---: | --- | ---: | --- | --- |
| positive | present | 4 | false | 4 | unchanged | accept |
| negative | absent | 1 | false | 4 | unchanged | accept |

Only these fixed judgments entered the durable export. No local media,
locator, digest, rights detail, reviewer identity, support, mask, geometry,
pixel metric or free-form text entered tracked evidence.

## Verification

| Gate | Result |
| --- | --- |
| RetouchSpikeLab self-test | 24/24 passed |
| Guarded positive and negative runs | passed |
| Native and color-adversarial protected leakage | zero for both accepted guarded rows |
| Ignored complete bundle | passed |
| Required private contract | 22/22 passed |
| Fresh serializer byte reproduction | passed |
| Tracked/staged privacy with all local media digests | passed, 1,376 tracked files |
| Runtime sclera absence owners | passed |
| Phase 59 runner/adapter preservation | zero diff |

## Commits

| Task | Commit | Description |
| --- | --- | --- |
| 62-03-01 | `9131a45` | Intake and review authorized guarded fixtures |
| 62-03-02 | `eaadf2f` | Serialize independent exact-open sclera evidence |

## Deviations from Plan

- The unoptimized guarded grid produced no artifacts after more than six
  minutes. It was stopped before output and rerun from the identical source and
  thresholds with the release configuration; the debug configuration had
  already passed the required 24/24 self-test.
- Git's ignored inventory included safe directory entries ending in `/`. The
  NUL parser was extended to accept only that safe directory form while
  retaining traversal, duplicate and malformed inventory rejection.
- An initial local record combined `accept` with positive coverage `3`.
  ReviewCore rejected it before serialization because the frozen passing
  threshold is `4`; that record was discarded and the complete original-detail
  review was rerun without changing criteria or derivatives.

## Nonclaims

This evidence admission does not prove public visible sclera output, population
coverage, production thresholds, target-device performance, commercial
approval, packaging, shipping, launch or release readiness. `祛红血丝` and
`去脂` remain future and the eye branch remains partial.

## Self-Check: PASSED

- Both task commits exist and all tracked artifacts contain aggregate/fixed
  allowlisted evidence only.
- Canonical teeth and eyelid sibling states are unchanged.
- Plan 62-04 is unlocked solely by the exact serializer-open sclera row.
- Only `.planning/config.json` remains as the autonomous-chain working-tree
  change.
