---
phase: 90-face-contour-and-chin-repairs
plan: "04"
subsystem: closeout
tags: [swiftpm, chin-taper, face-contour, boundary, archive, compatibility]

requires:
  - phase: 90-face-contour-and-chin-repairs
    provides: Completed-deferred FACE-01 summary, completed FACE-02 repair, and synchronized owner contracts
provides:
  - Fresh bounded package-host evidence for the completed FACE-02 repair
  - Honest FACE-01 completed-deferred non-GREEN closeout
  - Exact boundary-checker synchronization with the partial taxonomy authority
affects: [91-gaze-direction-repairs, 95-compatibility-and-sdk-only-closeout, FUTURE-04]

tech-stack:
  added: []
  patterns: [exact tuple-only boundary synchronization, aggregate-only closeout evidence, deferred-vs-complete requirement separation]

key-files:
  created:
    - .planning/phases/90-face-contour-and-chin-repairs/90-04-SUMMARY.md
  modified:
    - scripts/check-sdk-only-boundary.sh
    - QUALITY_SCORE.md
    - PLANS.md

key-decisions:
  - "FACE-02 is the sole completed active Phase 90 requirement; FACE-01 remains completed-deferred, partial, and non-GREEN."
  - "The only script change is the owner-authorized exact faceContourSmooth expected-status tuple from implemented to partial."
  - "Phase 95 retains direct chin precision/tie tests, clean semantic publication, and the complete no-skip closeout."

patterns-established:
  - "A boundary checker must mirror the current taxonomy authority and prove any owner-authorized synchronization as an exact byte-for-byte tuple-only diff."
  - "Safe/current-behavior tests cannot be presented as frozen semantic effectiveness evidence for a deferred requirement."

requirements-completed: [FACE-02]

duration: 6min
completed: 2026-09-04
---

# Phase 90 Plan 04: Bounded Closeout Summary

**Fresh focused, compatibility, semantic-preflight, archive, and SDK-boundary gates close FACE-02 while preserving FACE-01 as an unchanged partial and non-GREEN deferral.**

## Performance

- **Duration:** 6 min
- **Started:** 2026-09-04T11:39:00+08:00
- **Completed:** 2026-09-04T11:45:00+08:00
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Changed exactly one boundary-checker tuple for `面部流畅` /
  `faceContourSmooth` from expected status `implemented` to `partial`, matching
  the owner-authorized taxonomy authority. The pre-commit verifier proved the
  working file was exactly `HEAD` with that one replacement.
- Re-ran the bounded Phase 90 closeout from fresh commands: focused
  `142/0/0`, compatibility `154/0/1`, comparator self-test `PASS` with 554
  mutations and `5/65/8`, preflight-only `75/65/8`, two verified archives,
  and a passing post-archive SDK-only boundary scan.
- Moved the complete historical Phase 90 ledger into Completed without
  deleting its attempt history. FACE-02 is the only completed active
  requirement; FACE-01 remains `completed-deferred`, FUTURE-04, partial, and
  non-GREEN.
- Recorded Phase 91's one-research/one-independent-plan/two-attempt timebox and
  Phase 95 ownership of the precision/tie residual, clean semantic
  publication, and complete all-opt-ins no-skip gate.

## Task Commits

1. **Task 1: Run bounded focused, compatibility, archive, and SDK-boundary evidence** - `4c0970e` (`docs`)
2. **Task 2: Close the Phase 90 ledger and hand off deterministic remaining work** - `675b79c` (`docs`)

## Verification

- Predecessor check: `90-01` is a regular `completed-deferred` summary with
  `promotion_eligible: false` and `requirements-completed: []`; `90-02` and
  `90-03` each list `requirements-completed: [FACE-02]`.
- Exact diff check: `FACE01_BOUNDARY_DIFF=exact-one-tuple` before Task 1 commit;
  no other script changed and `BeautySDK` stayed byte-unchanged throughout.
- Focused filter: `142` executed, `0` failures, `0` skips. It included the two
  permitted FACE-01 safe/current-behavior methods and excluded the frozen
  effectiveness method.
- Compatibility filter: `154` executed, `0` failures, `1` existing Vision
  integration opt-in skip. It reconfirmed 62 public fields, five presets, 75
  renderer cases, both still-image facades, CPU/GPU policy, and unchanged
  retained `Warp.metal` boundaries.
- Comparator self-test: `semantic_validation_self_test=PASS mutations=554
  inventories=5/65/8`.
- Runner preflight: `preflight=PASS live=75 selected=65 semantic=8`; no
  portrait was rendered or published.
- Archive verification:
  - `BeautyDemo` SHA-256
    `04c14bbaa201cc6e9100f4c7b272b697670014041e62804dfa2f561faa29db52`
  - `meituxiuxiu` SHA-256
    `330e8aa08155eb4ad3a7b2ab84773a8279a8cd3ae87d4737b93e2491232fce9a`
- Boundary scan: `POST-ARCHIVE SDK BOUNDARY PASSED`.
- The exact Phase Completion Gate passed after both task commits.

## Requirement Disposition

- **FACE-02 — complete:** Fresh tests reconfirm deterministic paired lower-chin
  ownership, X-only movement, apex/Y and protected-region preservation,
  request-local fail-closed recovery, and sibling distinction. The established
  generated/public result remains target `1001/48557`, direction `+60 Q16`,
  and outside `0/0`.
- **FACE-01 — completed-deferred, not complete:** Revision 22 remains
  diagnostic-only `prior_stop_not_reproduced` evidence with zero render/oracle
  invocations. It does not repair the frozen effectiveness miss and creates no
  GREEN authority. The existing public field and safe/fail-closed source remain
  unchanged and classified `partial`; any repair needs separate FUTURE-04
  authorization.

## Chin Precision Residual

Direct tests cover exact `Float.ulpOfOne` and
`Float.ulpOfOne.nextDown` rejection, least-nonzero rejection, half `0.125`,
exact cap `0.25`, and over-cap `1` equaling the cap. Source defines strict
`> Float.ulpOfOne`, cap via `min`, strict `<` quantization-hostile selection,
and exact `== cap` three-pair selection. Phase 95 owns direct tests for
`Float.ulpOfOne.nextUp`, cap `nextDown`/`nextUp`, and exact plus one-step values
around the `immediateDistance == maximumDisplacement * 0.5` tie. Those strict
comparison outcomes are source-audit conclusions, not newly executed branch
measurements.

## Scope and Privacy

No production/test/fixture/parameter/preset/renderer/facade/backend/shader,
model, weight, network, UI, Demo, archive, or private-media behavior changed.
No pixels, anatomy, masks, landmarks, private fixture locators, or child
transcripts entered durable evidence. The live portrait command, frozen
FACE-01 effectiveness method, plain full SwiftPM run, and
`scripts/run-no-skip-swiftpm.sh` were intentionally not executed.

Package-host success grants no device, population, visual-quality,
commercialization, packaging, shipping, launch, external-distribution, or
release-readiness authority.

## Deviations from Plan

No product-scope or verification deviation. The delegated executor could not
start because its account usage window was exhausted, so the root workflow
performed the already independently authorized plan locally without changing
the plan contract or skipping any gate.

## Known Stubs

None in Phase 90 scope. FACE-01 future effectiveness work is an explicit
deferred requirement, not a hidden implementation stub.

## Threat Flags

None. All HIGH threats in the plan are mitigated by separate requirement
dispositions, allowlisted tests, exact preflight/archive/boundary ordering,
aggregate-only evidence, and owner-local nonclaims.

## Next Phase Readiness

- Phase 91 may begin under the owner-locked one-research, one independently
  checked plan, and maximum-two-attempt rule.
- Phase 95 retains the 65-output seven-effective-plus-one-deferred rerun,
  direct chin precision/tie residual tests, and complete all-opt-ins no-skip
  closeout.

## Self-Check: PASSED

- Task commits `4c0970e` and `675b79c` exist.
- The summary lists only `FACE-02` in `requirements-completed`.
- `faceContourSmooth` remains explicitly partial/non-GREEN and no frozen
  effectiveness success is claimed.
- `git diff --check` passed and `BeautySDK` plus every other script remain
  unchanged.

---
*Phase: 90-face-contour-and-chin-repairs*
*Completed: 2026-09-04*
