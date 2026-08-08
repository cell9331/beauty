---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
plan: "06"
subsystem: testing
tags: [sclera, adversarial-safety, bilateral-truth, proposal-evidence, three-state-checker]
requires:
  - phase: 64-05
    provides: exact pre-promotion quarantine under canonical gaps_found authority
provides:
  - immutable internal actual-proposal evidence available only to BeautyEffects @testable tests
  - bilateral full-resolution six-family protected truth with an exact 27-scenario perturbation matrix
  - aggregate-only three-state closeout checker with substantive runtime and lifecycle validation
affects: [64-07, 64-08, 64-09, 64-10, 64-11, 65]
tech-stack:
  added: []
  patterns: [request-local-test-observability, independent-protected-truth, aggregate-only-runtime-proof, non-circular-three-state-promotion]
key-files:
  created:
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-06-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift
    - .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py
key-decisions:
  - "Actual proposal indices are immutable internal request-local evidence for @testable BeautyEffects tests only; they are not package/public/SPI/Codable or durable diagnostics."
  - "The checker consumes exact aggregate runtime evidence and independent lifecycle artifacts; a product owner's claimed state can never authorize itself."
  - "SAFE-06 and the DeviceRGB/named-sRGB warning remain exclusively in Phase 65 scope."
patterns-established:
  - "Independent tests intersect the production proposal set with bilateral full-resolution truth, then prove all protected and outside-proposal RGBA bytes remain original-source exact."
  - "Pre-promotion, promotion-pending-verification, and final are distinct fail-closed states with no legacy allow-promotion escape hatch."
requirements-completed: []
requirements-evidence-ready: [SCLERA-14, SCLERA-15]
coverage:
  - id: D9
    description: "Actual runtime proposals intersect zero pixels in independently authored bilateral six-family protected truth across 27 ordered scenarios."
    verification:
      - kind: test
        ref: "BeautyScleraRednessAdversarialCloseoutTests 5/5"
        status: pass
      - kind: other
        ref: "PHASE64_ADVERSARIAL_AGGREGATE: protected_intersection_count=0, actual_proposal_count=744"
        status: pass
    human_judgment: false
  - id: D10
    description: "Every protected truth pixel and every pixel outside actual proposals remains byte exact after recolor and the production composition path."
    verification:
      - kind: other
        ref: "protected_truth_pixel_count=1632, recolored_protected_pixel_count=1632, protected/outside mismatch counts=0"
        status: pass
    human_judgment: false
  - id: D17-D21
    description: "The closeout checker enforces non-circular pre, pending, and final lifecycle states against exact 11-plan/20-task ownership."
    verification:
      - kind: other
        ref: "checker 18/18 mutations, full pre-promotion mode, and eight isolated HIGH selectors"
        status: pass
    human_judgment: false
duration: 18min
completed: 2026-08-08
status: complete
---

# Phase 64 Plan 06: Bilateral Sclera Oracle and Three-State Checker Summary

**Direct actual-proposal evidence now proves bilateral full-resolution protected anatomy and whole-output byte identity, while an aggregate-only checker enforces non-circular closeout states.**

## Performance

- **Duration:** 18 min
- **Started:** 2026-08-08T05:29:18Z
- **Completed:** 2026-08-08T05:47:04Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Replaced the literal-zero protected-count claim with immutable internal actual proposal indices, constrained to the provider and three authorized `@testable import BeautyEffects` test owners.
- Replaced six sampled left-eye pixels with bilateral full-resolution truth covering aperture exterior, highlight, iris, lash margin, pupil, and skin; exercised 27 ordered baseline, independent left/right, asymmetric, and local-reject scenarios.
- Recolored all 1,632 protected truth pixels and proved zero protected intersections, zero protected byte mismatches, zero outside-proposal byte mismatches, and active-peer continuation from 744 real runtime proposals.
- Replaced token-only checker acceptance with exact aggregate, proposal-owner, product-owner, 11-plan/20-task, independent-authority, and lifecycle assertions across three explicit states.

## Task Commits

Each TDD task was committed at its RED and GREEN gates:

1. **Task 1 RED: Add failing bilateral sclera oracle** — `e5a602b`
2. **Task 1 GREEN: Expose request-local sclera proposal indices** — `8ed5445`
3. **Task 2 RED: Require complete closeout task inventory** — `53c9a36`
4. **Task 2 GREEN: Enforce three-state sclera closeout** — `47b64ad`

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift` — exposes immutable internal request-local proposal indices and removes the misleading literal-zero summary field.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift` — verifies proposal cardinality and protected exclusion through internal test access.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift` — proves proposal indices remain outside composition summaries and durable observation.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift` — owns bilateral full-resolution truth, exact 27-scenario runtime proof, complete recolor/byte comparisons, privacy scans, and aggregate output.
- `.planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py` — validates live aggregate evidence and non-circular pre/pending/final closeout contracts.
- `.planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-06-SUMMARY.md` — records execution evidence and serial handoff.

## Decisions Made

- Kept `proposalPixelIndices` as an immutable `internal` member of the request-local BeautyEffects result. Only the three authorized `@testable` tests may observe it; composition and durable summaries do not.
- Made the aggregate schema exact and count-based. Raw indices, coordinates, geometry, pixels, masks, heatmaps, and vein-like details never cross into durable checker output.
- Kept canonical verification at `gaps_found` and product owners quarantined. Plan 64-07 must independently establish pre-promotion eligibility before any later product-owner transaction.
- Left DeviceRGB unchanged because SAFE-06 belongs to Phase 65.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first bounded asymmetric right-eye fixture placed one protected pixel inside a proposal. The test perturbation was tightened within the planned asymmetric grid; production guards, thresholds, transforms, and bounds were not changed. The resulting matrix retains distinct unilateral/asymmetric evidence and reports zero protected intersections.

## Verification Evidence

- `BeautyScleraRednessProviderTests`: 11/11 passed.
- `BeautyLocalRetouchCompositionTests`: 22/22 passed.
- `BeautyScleraRednessAdversarialCloseoutTests`: 5/5 passed.
- Runtime aggregate: 27 scenarios, 23 accepted, 4 locally rejected, 11 left-only and 11 right-only perturbations, 744 actual proposals, 1,632 bilateral protected truth pixels, and every safety/mismatch counter at zero.
- Renderer-output helper self-test: 14/14 passed.
- Closeout checker self-test: 18/18 mutations passed; full pre-promotion and each of T-64-01 through T-64-08 passed with nonzero check counts.
- Exposure allowlist, package/public/SPI/Codable/log/persistence/diagnostic negative scans, legacy `--allow-promotion` rejection, and `git diff --check` passed.

## Known Stubs

None. Quarantined future/unproven product wording and canonical `gaps_found` are intentional serial lifecycle state, not implementation stubs.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 64-07 can run the complete fresh pre-promotion conjunction and author independent `eligible_promotion_pending` authority from the corrected oracle/checker baseline.
- SCLERA-18, exact product promotion, canonical final verification, Phase 65, milestone audit/readiness, and release work remain blocked on Plans 64-07 through 64-11.

## Self-Check: PASSED

- All five implementation/test/checker files and this summary exist.
- Task commits `e5a602b`, `8ed5445`, `53c9a36`, and `47b64ad` exist in repository history.
- All plan-prescribed focused tests, helper/checker self-tests, live pre-promotion checks, isolated HIGH selectors, exposure scans, legacy-option rejection, and diff hygiene checks passed.

---
*Phase: 64-sclera-output-adversarial-safety-and-independent-closeout*
*Completed: 2026-08-08*
