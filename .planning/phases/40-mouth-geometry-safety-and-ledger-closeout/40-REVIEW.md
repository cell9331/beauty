---
phase: 40-mouth-geometry-safety-and-ledger-closeout
status: findings
depth: standard
reviewed: 2026-07-14
reviewed_commit: 7afcba1
iteration: 2
files_reviewed: 7
findings:
  critical: 0
  warning: 3
  info: 0
  total: 3
---

# Phase 40 Code, Test, and Boundary Re-Review

## Scope

The re-review inspected fix commit `7afcba1` against WR-01 through WR-03 and reran Python compilation, the checker self-test, and the live pre-promotion checker. The six Swift test files remain sound against the current production cap, support, freshness, convergence, redaction, and public-facade contracts; the remaining findings are confined to the promotion boundary checker.

## Findings

### WR-01 — Adversarial self-test coverage remains incomplete

**Severity:** Warning  
**File:** `check_mouth_geometry_boundaries.py:286-418`

The fix materially improves the old one-line self-test and now exercises positive live checks plus mutations for dependency, inventory, classification, imports, one multiline raw-geometry form, network, one same-line diagnostic, duplicate promotion, manifest, aggregate stale closeout, artifact, command, and path behavior. However, the reported `29/29 ... owner, lifecycle ... checks` still overstates what is executed:

- Lifecycle coverage at lines 388-389 calls only `LIFECYCLE_CLAIM.search(...)`; it never mutates a repository fixture and invokes `check_lifecycle_and_archive` to prove audit artifact, tag, archive, and claim rejection.
- Owner/traceability coverage invokes one fixture with many missing files/tokens, so it does not prove a one-failure-per-owner or one-failure-per-traceability-row guard.
- The commercial scanner, missing promotion row, multiline diagnostic form, plural raw-geometry identifiers, and archive/worktree mutation have no targeted negative.

This remains below Plan 40-03's deterministic positive plus one-failure-per-boundary contract and can let the self-test stay green while a boundary regresses.

**Required remediation:** Add isolated mutations that call the actual check for each lifecycle condition, every promotion/current owner and requirement row, commercial source, multiline diagnostic, plural/raw support identifier, missing row, archive mutation, and worktree mutation. The self-test total must count each observed check result, not a regex classifier proxy.

### WR-02 — Owner and lifecycle guards still admit stale or multiline overclaims

**Severity:** Warning  
**File:** `check_mouth_geometry_boundaries.py:42-45,187-195,230-270`

Exact ledger/matrix row uniqueness, per-file branch tokens, and exact requirement traceability are improved. The remaining closeout-owner tokens are nevertheless searched anywhere in each full historical file. They are not required to be co-located in a bounded v1.10/Phase 40 owner section, so stale facts from unrelated sections can satisfy the current owner contract.

The lifecycle claim regex is also line-bound because it is compiled without `DOTALL` and the `rg` call does not use multiline mode. A normal Markdown form such as a `## v1.10` heading followed on the next line by `- Milestone audit passed` is not matched. This bypass was reproduced directly: same-line `v1.10 audit passed` matched, while the heading-plus-bullet form returned false. The archive guard checks `.planning/milestones` only and does not cover `.worktrees`, despite the requested archive/worktree immutability boundary.

**Required remediation:** Validate every current owner inside a bounded v1.10/Phase 40 section, make lifecycle matching newline-safe (or parse the scoped sections), and include `.worktrees` status/diff containment. Add direct adversarial fixtures through `check_closeout_owners` and `check_lifecycle_and_archive`.

### WR-03 — Raw-geometry and diagnostic scans retain simple syntax bypasses

**Severity:** Warning  
**File:** `check_mouth_geometry_boundaries.py:149-175`

The exact 38-field inventory, typed search/Git exit handling, privacy-manifest disposition, and generated-artifact Git checks are fixed. The raw-geometry regex still uses exact word-boundary alternatives `landmark`, `support`, and `bounds`; public identifiers such as `landmarks` and `supports` are not matched unless another listed token happens to appear. Direct regex probes confirmed both `public let landmarks: MouthLandmarks` and `public let supports: MouthSupports` evade the scan.

The diagnostic scan has no `-U`/multiline mode and uses `.*?`, so a common formatted Swift diagnostic with `message:` on one line and `outerLips coordinate` on the next is not detected. The self-test covers only the same-line form and therefore does not expose the bypass.

**Required remediation:** Match singular/plural and identifier variants (`landmark`, `landmarks`, `support`, `supports`, `bounds`, and compound names) and make diagnostic scanning multiline-safe with bounded context. Add one accepted classified testing-SPI fixture and failing plural/multiline fixtures.

## Fixes Verified

- Exact ordered 38-field inventory rejects replacement of a legacy field.
- `search_lines` and `git_lines` now separate search exit `1` from Git failure; the self-test proves Git exit `1` is blocking.
- Promotion rows are structurally parsed and duplicate contradictory rows fail.
- Matrix and parent branch rows require uniqueness; each of the three branch owners independently requires its promotion tokens.
- Phase 40 requirement traceability requires one exact `Phase 40 / Complete` row per requirement.
- Privacy-manifest disposition and same-line diagnostic checks were added.
- Generated artifact checks require successful Git commands and retain tracked/staged/ignore guards.

## Evidence Run

- Python compilation: passed.
- Checker self-test: reported 29/29 passed.
- Live pre-promotion checker: reported 13/13 passed.
- Independent probes: plural `landmarks`/`supports`, multiline diagnostic, and multiline lifecycle claim forms were not matched, confirming the remaining findings.

## Verdict

Findings remain. Fix commit `7afcba1` closes substantial portions of all three warnings but does not fully remediate any of them. Plan 40-04 and owner-ledger promotion remain blocked pending a further checker hardening pass and clean re-review.
