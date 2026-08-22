---
phase: 75-semantics-and-genuine-evidence-contract
plan: "02"
subsystem: private-evidence
tags: [rights, rubric, blinded-review, aggregate-only, fail-closed]

# Dependency graph
requires:
  - phase: 75-semantics-and-genuine-evidence-contract
    provides: Frozen semantic authority and exact public absence gate.
provides:
  - Frozen rights/category manifest and measurement/review contract.
  - Metadata-only local evaluator with validate, aggregate, and export modes.
  - Typed missing/incomplete evidence failure without promotion authority.
affects: [phase 78 genuine evaluation, phase 79 conditional closeout]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Private manifests remain caller-local; durable output is an explicit aggregate allowlist.", "Metadata-only mechanics cannot receive genuine efficacy weight."]

requirements-completed: [EVID-01, EVID-02]

# Metrics
duration: ~15min
completed: 2026-08-22
---

# Phase 75 Plan 02: Genuine Evidence Contract Summary

## Accomplishments

- Froze required genuine positive/negative, ambiguity, pose/occlusion,
  identity-diversity, and protected-structure categories with rights and
  provenance bindings.
- Froze efficacy, containment, texture, geometry, metadata, no-op, and
  deterministic metric records plus blinded original-detail review fields and
  fixed reason codes.
- Added a local metadata-only evaluator. It validates a caller-supplied
  manifest, emits aggregate-only output, and fails closed when no bundle or
  incomplete rights/evidence is present.

## Verification

- Combined semantic/evidence Node suite: 8/8 passed.
- Evaluator self-test: passed, 10 checks and 7 mutation rejections.
- Explicit evaluator `--validate`, `--aggregate`, and `--export`: all passed
  for a temporary metadata-only mechanics manifest.
- Missing-bundle path: typed nonzero `evidence.missing-bundle`.
- Aggregate decision: `mechanics-only-not-promotion`; no genuine efficacy claim.
- Exact absence and all isolated Phase-75 threat modes: passed.
- `git diff --check`: passed.

## Evidence boundary

No rights-approved genuine bundle was present in the workspace. This is an
intentional fail-closed state: metadata-only self-tests prove mechanics only,
and the evaluator cannot authorize tuning, promotion, or a public route.

## Self-Check: PASSED

The evidence path is frozen and privacy-safe; genuine evaluation remains
conditional on a private caller-supplied bundle and blinded review.

