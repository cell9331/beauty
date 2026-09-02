---
phase: 90-face-contour-and-chin-repairs
plan: "01"
subsystem: geometry
tags: [swift, face-contour, deferred, terminal-record]
status: completed-deferred
promotion_eligible: false
requirements-completed: []
completed: 2026-09-02

requires:
  - phase: 89-semantic-validation-baseline
    provides: Frozen FACE-01 semantic, locality, sibling, and protection contract
provides:
  - Owner-approved terminal FACE-01 deferral record
  - Explicit non-GREEN boundary for the consumed revision-22 diagnostic
affects: [90-03, 90-04, 95-compatibility-and-sdk-only-closeout, future-face-contour-repair]

key-files:
  created:
    - .planning/phases/90-face-contour-and-chin-repairs/90-01-SUMMARY.md
  modified: []

key-decisions:
  - "No FACE-01 revision 23 is authorized in v1.22."
  - "faceContourSmooth remains owner-local, unchanged, fail-closed, and partial; future repair requires a separately authorized milestone."
---

# Phase 90 Plan 01: FACE-01 Terminal Deferral Summary

**This is a post-decision deferral record, not a GREEN implementation summary. FACE-01 is not completed and revision 22 is not repair evidence.**

## Outcome

- The bounded FACE-01 construction series did not meet the frozen `+16 Q16`
  semantic, sibling, locality, protection, point-budget, and inverse-map safety
  contract together.
- Revision 18 remains the terminal verified construction stop. Revisions 19–21
  were bounded diagnostic-harness failures. Revision 22 executed exactly once
  and classified only `prior_stop_not_reproduced`; it invoked neither rendering
  nor the frozen oracle and cannot promote the effect.
- On 2026-09-02 the owner ended the retry loop, prohibited revision 23, removed
  FACE-01 from active v1.22 requirements, and moved further repair to
  FUTURE-04.

## Preserved Product and Safety State

- The existing owner-local `BeautyParameters.faceContourSmooth` field remains
  callable with its current implementation and fail-closed behavior.
- No production source, generated RED test, threshold, fixture, public API,
  preset, renderer case, facade signature, CPU/GPU contract, `Warp.metal`,
  model, data, network, UI/Demo, or distribution boundary changed in this
  closeout record.
- `docs/SDK_EFFECT_TAXONOMY.md` classifies the direction as `partial`, not
  `implemented`.
- Raw pixels, contours, landmarks, masks, fixture locators, and child output
  remain outside durable evidence.

## Evidence Boundary

- The authoritative attempt history remains in `90-01-ATTEMPT.md`.
- Revision-22 aggregate-only evidence is committed at `fe2e8c2`: one
  request-local reconstruction, provider/reference cap and half admissions
  `20/20`, final count `20`, zero render/oracle invocations, byte-exact
  provider/test restoration, temporary symbols absent, and
  `FACE01_DIAGNOSTIC_ROLLBACK_VERIFIED`.
- None of those facts demonstrate the frozen FACE-01 output contract. This
  summary deliberately contains no FACE-01 GREEN marker and claims no completed
  requirement.

## Next Phase Readiness

- Phase 90 may continue only with owner-document synchronization and bounded
  compatibility/boundary verification for the completed FACE-02 chin repair
  plus this explicit FACE-01 deferral.
- Phase 95 must complete the unchanged 65-output inventory with seven active
  directions effective and `faceContourSmooth` reported deferred/partial.
- Any future FACE-01 implementation requires a new separately authorized
  milestone and a fresh independently checked plan.

## Deviations from Original Plan

The original Plan 90-01 required GREEN repair evidence and intentionally
forbade a summary on implementation stop. The 2026-09-02 owner scope decision
supersedes that workflow instruction only for this terminal deferred record; it
does not convert the stopped implementation into completion.

## Self-Check: PASSED

- `promotion_eligible` is false and `requirements-completed` is empty.
- The summary states that FACE-01 is deferred and non-GREEN.
- No production or test source was modified to create this record.
- No revision 23, renderer/oracle retry, threshold change, or public/backend
  change occurred.

---
*Phase: 90-face-contour-and-chin-repairs*
*Disposition recorded: 2026-09-02*
