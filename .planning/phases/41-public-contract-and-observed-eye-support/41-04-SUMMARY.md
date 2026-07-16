---
phase: 41-public-contract-and-observed-eye-support
plan: "04"
subsystem: boundary-and-contracts
tags: [python, privacy, boundary-gate, documentation]

requires:
  - phase: 41-public-contract-and-observed-eye-support
    provides: 48-field scalar contract and validated request-scoped observed eye support
provides:
  - Fail-closed Phase 41 baseline, active-source, privacy, and artifact boundary gate
  - Synchronized design, security, reliability, product, and work-ledger contracts
affects: [phase-42-eye-geometry, phase-43-eye-output, phase-44-eye-closeout]

tech-stack:
  added: []
  patterns:
    - Explicit rg 0/1/error classification with aggregate-only scan results
    - Git-baseline and generated-root containment checks with adversarial fixtures

key-files:
  created:
    - .planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py
  modified:
    - DESIGN.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - PLANS.md

key-decisions:
  - "Use f1c28fa as the immutable Package.swift and BeautyDemo baseline for Phase 41."
  - "Treat every rg status other than 0 or 1, every unclassified match, and every artifact mutation as a blocking result."
  - "Record Phase 41 support thresholds as validation ceilings, never as provider or visual caps."

requirements-completed: [EYE-01, EYE-02, EYE-03, EYE-04, EYE-05, EYE-06, EYE-07]

coverage:
  - id: D1
    description: "The boundary helper rejects baseline, exposure, diagnostic, network, commercial, tool, path, and artifact mutations."
    requirement: EYE-07
    verification:
      - kind: other
        ref: "check_eye_support_boundaries.py --self-test (24/24)"
        status: pass
      - kind: other
        ref: "check_eye_support_boundaries.py live (10/10)"
        status: pass
    human_judgment: false
  - id: D2
    description: "The compatible scalar and observed-support implementation remains regression-safe."
    requirement: EYE-01
    verification:
      - kind: unit
        ref: "swift test --package-path BeautySDK (283/283)"
        status: pass
    human_judgment: false

duration: 18min
completed: 2026-07-16
status: complete
---

# Phase 41 Plan 04: Eye-Support Boundary and Contract Closeout Summary

**Phase 41 now has a reusable fail-closed gate for its 48-field public contract, private observed-support lifecycle, unchanged Demo/manifest baseline, active-source privacy boundaries, and generated-artifact containment.**

## Accomplishments

- Implemented explicit `rg` result classification: status 0 is classified matches, status 1 is a clean no-match, and every other status or runner exception blocks.
- Locked `BeautySDK/Package.swift` and every `BeautyDemo` tracked/untracked path to baseline `f1c28fa`, while scanning all active SDK source targets for public/SPI geometry, Codable/persistence drift, raw diagnostics, network/cloud, commercial, and internal-import paths.
- Enforced actual `example-images/output`, `example-images/gallery`, `.gallery-staging`, and `.gallery-quarantine` states: tracked 0, staged 0, non-ignored untracked 0, with all four representative paths ignored.
- Synchronized `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `PLANS.md` on the ten field names, exact 48-field inventory, one-mapper request-scoped support, validation ceilings, pupil-local degradation, no-proxy explicit-side behavior, aggregate diagnostics, and downstream non-claims.

## Task Commits

1. **Task 41-04-01 RED: Add the failing helper contract** — `d8946f5`
2. **Task 41-04-01 GREEN: Implement and adversarially self-test the helper** — `fc427ac`
3. **Task 41-04-02: Synchronize owner contracts and run the live gate** — `ebc2160`

## Verification

- `swift test --package-path BeautySDK` — 283 tests passed, 0 failures.
- `python3 .../check_eye_support_boundaries.py --self-test` — 24/24 checks passed, including search errors/tool absence, allowlist classification, path escape, baseline/Demo drift, public/Codable/persistence/diagnostic/network/commercial mutations, and tracked/staged/non-ignored-untracked artifacts.
- `python3 .../check_eye_support_boundaries.py` — 10/10 live checks passed.
- Live scan dispositions: public/SPI classified 1 and unclassified 0; Codable/persistence classified 24 and unclassified 0; raw diagnostic, network/cloud, commercial, and forbidden Demo/renderer imports each 0 unclassified.
- Baseline disposition: `f1c28fa` exists; manifest/Demo changed 0 and untracked 0.
- Artifact disposition: tracked 0, staged 0, non-ignored untracked 0, representatives-not-ignored 0, errors 0.
- Every owner contains all ten field names; `git diff --check` passed.

## Decisions Made

- Helper failures report aggregate counts and stable reason categories rather than raw matching geometry/source payloads.
- Existing Codable and renderer persistence literals are admitted only by narrow path-and-literal classifiers; new or moved matches fail closed.
- Phase 41 documents contour/pupil limits as support-validation ceilings. Provider vectors, visual caps, output evidence, and promotion remain downstream.

## Deviations from Plan

None. Execution resumed from the already committed RED gate after transient stream disconnects and did not repeat or revert that commit.

## Scope and Deferred Work

Phase 41 adds no ten-field provider transforms, provisional or final visual caps, conflict convergence, public-facade output cases, renderer matrices, gallery evidence, ledger promotion, Demo UI, device evidence, commercial naturalness review, optimized performance certification, packaging, shipping, launch readiness, or whole-branch `眼睛` completion. Phase 42 owns provider behavior; Phases 43-44 own output evidence and final safety/promotion closeout.

## User Setup Required

None.

## Self-Check: PASSED

- Summary and helper files exist.
- RED `d8946f5`, GREEN `fc427ac`, and owner-doc `ebc2160` commits exist in history.
- Full SwiftPM, helper self-test/live, owner field scan, and diff hygiene all passed.
- No blocking stubs or new threat surface beyond the planned repository/source inspection gate were introduced.
