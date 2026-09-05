---
phase: 91-independent-gaze-correction
plan: "04"
implementation_attempt: 1
subsystem: closeout
tags: [swiftpm, gaze-correction, compatibility, privacy, archive]

requires:
  - phase: 91-independent-gaze-correction
    plans: ["01", "02", "03"]
    provides: Independent gaze mechanics, generated public pixels, and renderer-bound aggregate evidence
provides:
  - Current-authority package-host closeout for EYE-01
  - Synchronized behavior, architecture, product, trust, reliability, quality, and taxonomy owners
  - Explicit preservation of the Phase-90-deferred frozen FACE-01 RED oracle
affects: [92-signed-eyebrow-head-spacing, 95-compatibility-and-sdk-only-closeout, EYE-01]

tech-stack:
  added: []
  patterns: [authority-aware suite selection, output-identity-bound aggregate evidence, aggregate-only closeout]

key-files:
  created:
    - .planning/phases/91-independent-gaze-correction/91-04-SUMMARY.md
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/CPUReferenceGeometryOracleTests.swift
    - PLANS.md
    - DESIGN.md
    - ARCHITECTURE.md
    - PRODUCT_SENSE.md
    - SECURITY.md
    - RELIABILITY.md
    - QUALITY_SCORE.md
    - docs/SDK_EFFECT_TAXONOMY.md

key-decisions:
  - "Run every current SwiftPM test except the one exactly discovered Phase-90-deferred frozen FACE-01 effectiveness oracle; preserve that oracle as intentionally RED and make no FACE-01 GREEN claim."
  - "Move only the CPU reference inventory's two test-local gaze samples from the aperture boundary to deterministic interior positions so the inventory exercises the Phase 91 strict-containment contract."
  - "Retain gazeCorrection as implemented only with the verified per-eye, output-bound, actual-pixel-qualified Phase 91 scope."

patterns-established:
  - "A newer closeout must respect an explicit earlier deferred RED oracle instead of silently weakening it or falsely describing the whole discovered suite as GREEN."
  - "Temporary semantic evidence may contribute only after exact output identity and algebra checks, then must be consumed and verified removed."

requirements-completed: [EYE-01]
duration: 22min
completed: 2026-09-06
---

# Phase 91 Plan 04: Independent Gaze Closeout Summary

**EYE-01 closes in implementation attempt 1 with independent own-eye correction, generated actual-pixel proof, output-bound aggregate admission, and synchronized owner contracts.**

## Performance

- **Duration:** 22 min
- **Started:** 2026-09-05T23:43:00+08:00
- **Completed:** 2026-09-06T00:05:00+08:00
- **Tasks:** 3
- **Files created/modified:** 10

## Accomplishments

- Reconciled all three predecessor summaries to the same
  `implementation_attempt: 1`; no second implementation attempt was required.
- Closed the generated public-facade, final aggregate, renderer/comparator,
  privacy, compatibility, archive, and SDK-only evidence as one dependent set.
- Synchronized `PLANS.md`, design, architecture, product, security,
  reliability, quality, and taxonomy owners without changing the public
  surface or overstating the Phase 95 boundary.
- Preserved the sole Phase-90-deferred frozen FACE-01 effectiveness oracle as
  discovered and intentionally non-GREEN while passing all 840 other current
  tests.

## Task Commits

1. **Task 1: Reconcile attempt ledger and package-host gate** — `5f4ee81`
2. **Task 2: Synchronize behavior, architecture, and owner journey** — `22a3b51`
3. **Task 3: Synchronize trust, reliability, quality, and taxonomy** — `db12f60`

## Final Gaze Evidence

- Exact displacement `0.002` is neutral; positive input caps at `0.25`; cap
  movement is 35% toward each pupil's own eye center.
- The radius is bounded by 5% face width and half the smaller source/target
  aperture clearance. Eligibility and rejection are per eye; no legacy or
  peer-eye fallback exists for positive gaze.
- Generated public-facade pixels measured own-center reductions `201/203 Q16`,
  target signal `1316/51731`, and protected outside, contour, brow, background,
  and watermark aggregates all at `0/0`.
- The exact aggregate rows are bilateral `2/2/0/1/0/688`, single
  `1/1/0/1/0/688`, and abstaining `0/0/0/0/1/0` for eligible/corrected/
  rejected/all-reduced/abstained/minimum-reduction-Q16.

## Gate Results

- Summary admission: all 91-01/02/03 summaries are regular non-symlink files
  with exactly one matching attempt-1 record.
- SwiftPM discovery: the Phase-90-deferred frozen FACE-01 effectiveness oracle
  is present exactly once.
- Current-authority SwiftPM: `840` tests executed, `0` failures, `8` established
  opt-in skips; the sole deferred FACE-01 oracle was not executed or claimed
  GREEN.
- Focused compatibility: `107` tests executed, `0` failures, `0` skips.
- Comparator: `semantic_validation_self_test=PASS`, `mutations=576`,
  `inventories=5/65/8`.
- Runner boundary: `PASS`, including `report_cleanup=6`,
  `preflight_faults=3`, and unchanged preflight coverage.
- Runner preflight: `PASS`, exact `live=75 selected=65 semantic=8`.
- Backend-neutral contract: `PASS`, with `focused_tests=24` and
  `cpu_reference_tests=41`.
- Archive verification: `BeautyDemo`
  `04c14bbaa201cc6e9100f4c7b272b697670014041e62804dfa2f561faa29db52`;
  `meituxiuxiu`
  `330e8aa08155eb4ad3a7b2ab84773a8279a8cd3ae87d4737b93e2491232fce9a`.
- SDK-only boundary: `POST-ARCHIVE SDK BOUNDARY PASSED`.
- Both owner-document consistency commands and `git diff --check` passed.

## Compatibility Fixture Correction

The initial closeout exposed that the old CPU reference inventory placed both
test-local gaze samples on its triangular aperture boundary. Strict Phase 91
containment correctly rejected them. Task 1 moved only those two samples to
deterministic off-center interior positions. The inventory test then passed;
no production source, assertion threshold, public field, preset, renderer case,
facade, backend, shader, or semantic acceptance value changed.

## Scope and Privacy

Exactly 62 stored fields, five presets, 75 renderer cases, both public
still-image facades, CPU reference, selectable `.cpu`/`.gpu`, terminal
`.metalUnavailable`, and retained `Warp.metal` remain unchanged. Raw or
per-side anatomy, pixels, masks, radii, private locators, paths, temporary
reports, and transcripts are absent from durable evidence.

The live authorized portrait batch, final clean 65-output publication, and
`scripts/run-no-skip-swiftpm.sh` did not run. Phase 95 remains their sole owner.
Phase 91 creates no device, population, naturalness, performance, commercial,
packaging, shipping, launch, release-readiness, or distribution authority.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking authority conflict] Reconciled the closeout suite with the explicit Phase 90 FACE-01 deferral**

- **Found during:** Task 1 verification
- **Issue:** Plain `swift test` executed the intentionally RED frozen FACE-01
  effectiveness oracle even though Phase 90's higher-authority completed
  contract explicitly defers it to FUTURE-04 and forbids a GREEN claim.
- **Fix:** Proved that oracle remains discovered exactly once, excluded only
  that method, and ran all 840 remaining tests. Updated the Phase 91 research,
  validation, and Plan 91-04 wording to state this authority boundary exactly.
- **Verification:** The 840-test current-authority suite passed with no
  failures; the deferred oracle remains byte-unchanged.
- **Committed in:** `5f4ee81`

**2. [Rule 1 - Test fixture defect] Moved the CPU reference gaze samples inside their aperture**

- **Found during:** Task 1 verification
- **Issue:** Boundary samples could not exercise a field whose locked contract
  requires strict aperture interior.
- **Fix:** Changed only the two target-internal test samples; retained all
  assertions and production constants.
- **Verification:** The inventory oracle, 840-test suite, focused
  compatibility, and backend-neutral CPU-reference gate all passed.
- **Committed in:** `5f4ee81`

---

**Total deviations:** 2 authority-preserving auto-fixes.
**Impact on plan:** No EYE-01 threshold, production behavior, public surface,
privacy rule, or Phase-95 responsibility was weakened.

## Known Stubs

None in Phase 91 scope. The frozen FACE-01 effectiveness oracle is an explicit
FUTURE-04 deferral, not a hidden gaze stub.

## Threat Flags

None. All HIGH threats are mitigated by observed per-eye ownership, strict
aperture admission, final-point reconciliation, exact report identity,
unchanged actual-pixel gates, aggregate-only durable evidence, and verified
cleanup.

## Next Phase Readiness

- Phase 92 can begin its signed eyebrow-head-spacing repair under the same
  bounded research/check/attempt policy.
- Phase 95 retains authorized portrait publication and milestone closeout.

## Self-Check: PASSED

- Commits `5f4ee81`, `22a3b51`, and `db12f60` exist.
- The summary contains exactly one `implementation_attempt: 1` line and lists
  `requirements-completed: [EYE-01]`.
- All eight owner documents contain matching Phase 91 sections.
- No report, image, model, data, or UI artifact was added.

---
*Phase: 91-independent-gaze-correction*
*Completed: 2026-09-06*
