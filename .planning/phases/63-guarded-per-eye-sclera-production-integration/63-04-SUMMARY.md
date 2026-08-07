---
phase: 63-guarded-per-eye-sclera-production-integration
plan: "04"
subsystem: image-effects
tags: [swift, sclera, private-evidence, security, verification]
requires:
  - phase: 63-03
    provides: one-request sclera lifecycle and per-eye peer isolation
provides:
  - final authorized native-Vision positive/negative provider gate
  - eight-HIGH security disposition and tracked aggregate-only evidence
  - full SDK and Demo regression with Phase 64-only lifecycle handoff
affects: [64-sclera-output, 65-combined-closeout]
tech-stack:
  added: []
  patterns: [reviewed-guard-lower-bound, fixed-output-private-gate, provider-before-promotion]
key-files:
  created:
    - .planning/phases/63-guarded-per-eye-sclera-production-integration/63-SECURITY.md
    - .planning/phases/63-guarded-per-eye-sclera-production-integration/63-VERIFICATION.md
  modified:
    - BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
    - .planning/STATE.md
key-decisions:
  - "Private acceptance thresholds and reviewed evidence remain immutable; production pupil/iris protection is no smaller than the pre-existing reviewed circular guard."
  - "An initial containment failure blocks until the production guard is corrected and the entire fixed-output conjunction reruns green."
  - "Phase 63 verifies provider integration only; renderer output, adversarial final-output proof, visual review and product promotion remain Phase 64."
patterns-established:
  - "Real-fixture containment failures are classified with fixed aggregate tokens and never expose media, paths, masks, pixels or raw metrics."
  - "Small synthetic eye fixtures use realistic aperture proportions so conservative production guards are not weakened for test convenience."
requirements-completed: [SCLERA-09, SCLERA-10, SCLERA-11, SCLERA-12, SCLERA-13]
coverage:
  - id: D1
    description: "Authorized positive/negative production output passes frozen native-Vision containment and naturalness bounds."
    requirement: SCLERA-10
    verification:
      - kind: integration
        ref: "Phase 62 fixed-output private runner"
        status: pass
    human_judgment: false
  - id: D2
    description: "All provider, lifecycle, privacy, HIGH, SDK, Demo and inventory gates agree before Phase 64 handoff."
    requirement: SCLERA-13
    verification:
      - kind: unit
        ref: "SwiftPM 612/0/8; Demo 121/0/0"
        status: pass
      - kind: other
        ref: "checker self/live and T-63-01 through T-63-08"
        status: pass
    human_judgment: false
duration: 30 min
completed: 2026-08-07
status: complete
---

# Phase 63 Plan 04: Private Evidence and Closeout Summary

**The guarded per-eye sclera provider now passes its authorized native-Vision,
security, regression and lifecycle gates without adding output promotion or a
deferred surface.**

## Performance

- **Duration:** 30 min
- **Completed:** 2026-08-07
- **Tasks:** 2
- **Plans reconciled:** 4/4

## Accomplishments

- Executed the authorized positive/negative pair only through fixed-output
  private discovery and preserved zero reviewed-mask escape after correcting a
  production guard mismatch.
- Closed T-63-01 through T-63-08 with checker self-test, live discovery, each
  isolated threat mode and aggregate-only security records.
- Passed 20 focused tests, all 612 SwiftPM tests with eight documented opt-in
  skips, and all 121 Demo tests on iPhone 17e / iOS 26.5.
- Verified five requirements, sixteen decisions, eight tasks, eight HIGH
  threats and four plans, then routed only to Phase 64.

## Task Commits

1. **Task 1: Execute private fixtures and isolated security gates** — `213ce12`
2. **Task 2: Full regression, owner synchronization and Phase 64 handoff** — this owner/summary commit

## Verification

- Final private fixed-output execution: passed.
- Provider + integration: 20/20.
- Checker: 8/8 mutation rejections, 8/8 live owners, 8/8 isolated HIGH modes.
- Full SwiftPM: 612 executed, 0 failed, 8 documented non-required skips.
- Demo: build passed; 121 passed, 0 failed, 0 skipped.
- Compatibility/privacy/inventory/syntax/JSON/diff: passed.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Corrected under-protected pupil/iris guard topology**

- **Found during:** First private native-Vision execution.
- **Issue:** The production ellipse admitted pixels outside the already-reviewed
  conservative circular guard, so the fixed containment class failed.
- **Fix:** Kept every private bound and reviewed artifact unchanged; enlarged
  production protection to the pre-existing reviewed circular guard and reran
  the complete conjunction.
- **Verification:** Final private runner, 20 focused tests and all eight HIGH
  modes pass.
- **Committed in:** `213ce12`

**2. [Rule 1 - Test Fixture] Corrected unrealistic synthetic eye proportions**

- **Found during:** Focused tests after the conservative guard correction.
- **Issue:** Small tall/narrow synthetic apertures were fully consumed by the
  valid protection radius even though real reviewed support retained sclera.
- **Fix:** Changed only test-owned contours and face-box proportions to
  anatomical eye apertures; no production protection or acceptance criterion
  was weakened.
- **Verification:** Provider 11/11 and integration 9/9 pass.
- **Committed in:** `213ce12`

**Total deviations:** 2 auto-fixed (one blocking safety mismatch and one
test-fixture defect). **Impact:** Eligible production area became narrower;
public output/promotion scope did not change.

## User Setup Required

None. Authorized media remains ignored and local-only.

## Next Phase Readiness

Phase 64 is ready for discussion and planning. It alone owns strict public
renderer output, color-independent and recolored protected-anatomy adversarial
proof, new original-detail review and exact `祛红血丝` promotion. Renderer 73,
five presets, 61 fields and three disabled Demo rows remain unchanged.

## Self-Check: PASSED

- Four plans and four summaries are present.
- Eight task rows, sixteen decisions, five requirements and eight HIGH threats
  are complete and non-skipped.
- No private media, locator, digest, support, mask, pixel or raw metric is
  tracked.
- Phase 64-only handoff and all nonclaims are explicit.
