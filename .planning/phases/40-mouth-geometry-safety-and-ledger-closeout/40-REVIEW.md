---
phase: 40-mouth-geometry-safety-and-ledger-closeout
status: findings
depth: standard
reviewed: 2026-07-14
reviewed_commit: 18cdcac
files_reviewed: 7
findings:
  critical: 0
  warning: 3
  info: 0
  total: 3
---

# Phase 40 Code, Test, and Boundary Review

## Scope

Standard-depth review covered the Phase 40 cap, resolver, degradation, conflict, combined-effect, public-facade, and boundary-checker changes requested for review. Relevant production sources were read to compare test expectations with cap normalization, per-field provider sanitization, freshness policy, retained-baseline convergence, warning/metric redaction, and final dispatch behavior.

## Findings

### WR-01 — Boundary self-test does not test the boundary checker

**Severity:** Warning  
**File:** `check_mouth_geometry_boundaries.py:222-238`

`--self-test` asserts three values returned by `expected_row_statuses` and only the generic command helper's exit-1/exit-2 behavior. It never invokes `check_required_paths`, `check_manifest`, `check_inventory`, `check_source_classification`, `check_imports`, `check_public_geometry`, `check_remote_and_commercial`, `check_promotion`, `check_closeout_owners`, or `check_artifacts`. Consequently, a regression that makes any one of those checks accept a known-bad fixture still produces `SELF-TEST PASS`. This does not satisfy the Plan 40-03 contract for a positive fixture plus one deterministic failure per boundary, classified-match/no-match/error coverage, path escape, artifact, owner, and lifecycle failures.

**Required remediation:** Build deterministic temporary fixtures and exercise every check through at least one passing case and one targeted failing mutation. Include explicit search states (classified match, no match, command error, missing tool), escaping symlink/path containment, tracked/staged generated artifacts, contradictory or missing promotion rows, each required owner, and premature lifecycle artifacts/claims. Report an exact passed/total self-test count and return nonzero when any fixture fails.

### WR-02 — Promotion and closeout checks can accept contradictory or stale owners

**Severity:** Warning  
**File:** `check_mouth_geometry_boundaries.py:156-206`

The promotion guard checks only whether each desired row substring occurs somewhere. A ledger containing both the desired row and a duplicate contradictory row passes; the three branch owners likewise need only contain one matching substring. In allow-promotion mode, field/phase tokens may be scattered across any of the three concatenated owner files, so two stale owners can pass when the third contains all tokens. Root/planning owner checks similarly search tokens anywhere in whole files rather than proving a co-located Phase 40 owner section, exact requirement traceability, or exact row uniqueness. The checker also has no lifecycle nonclaim check, so a premature v1.10 audit artifact or `audit passed` / `archived` / `tagged` claim is not rejected despite the plan's explicit boundary.

**Required remediation:** Parse ledger and matrix rows structurally; require one unique row per expected label, the exact five promoted statuses, `白牙: future`, and exact partial branch rows. Validate a Phase 40-scoped contract independently in every owner rather than across concatenated documents. Add exact requirement checklist/traceability checks and a lifecycle guard that rejects audit artifacts and audit/archive/tag/cleanup/readiness claims before the independent milestone lifecycle runs. Cover every condition with adversarial self-tests.

### WR-03 — Compatibility, privacy, raw-geometry, and command checks are not fail-closed enough

**Severity:** Warning  
**File:** `check_mouth_geometry_boundaries.py:69-147,209-219`

The compatibility check proves only `38` declarations, `37` `Float` declarations, one `filterId`, and the five new names. Replacing a legacy field with an arbitrary `Float` preserves all four predicates and passes despite compatibility drift. The public-geometry scan is a same-line regex with a narrow token list; public or SPI declarations containing generic landmark/support/bounds types on another line are not covered. There is no active-source diagnostic leakage scan, privacy-manifest disposition check, or archive/worktree immutability check. Finally, `command_lines` treats exit `1` as a clean result for every command, including `git ls-files` and `git diff`, although exit `1` is only the expected no-match state for `rg`; an operational Git exit `1` can therefore be interpreted as artifact cleanliness.

**Required remediation:** Freeze the exact 38-field public inventory (or a canonical exact legacy-plus-new set), use typed command wrappers that accept exit `1` only for searches, and require Git commands to exit `0`. Restore broad public/SPI raw-geometry and diagnostic-leak scans with explicit classifiers, privacy-manifest disposition, and archive/worktree checks. Add failing fixtures for each bypass.

## Reviewed Test Semantics

No additional defect was found in the six Swift test files in scope. Their Phase 40 additions agree with the current production contract: exact-cap inputs do not increment cap evidence, overflow increments once, all thirteen mouth directions preserve sign under one computed scale, missing inner support removes only peak/plump work, reused scaling precedes independent conflict weakening, stale/no-face removes all eight mouth geometry strengths, safe domains continue, and facade diagnostics remain aggregate/redacted. The boundary checker findings above block a clean review because the checker can over-authorize promotion even while the XCTest evidence is valid.

## Evidence Run

- `python3 -m py_compile .../check_mouth_geometry_boundaries.py`: passed.
- `python3 .../check_mouth_geometry_boundaries.py --self-test`: exited zero but emitted only one aggregate self-test pass line, confirming WR-01.
- Pre-promotion live checker: 10/10 reported pass; this result is not accepted as a promotion-quality gate until WR-01 through WR-03 are remediated.

## Verdict

Findings. Three warnings remain in the fail-closed Phase 40 promotion boundary. Plan 40-04 and any owner-ledger promotion should remain blocked until fixes are applied and the review is rerun.
