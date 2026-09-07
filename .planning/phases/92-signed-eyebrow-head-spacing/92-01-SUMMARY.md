---
phase: 92-signed-eyebrow-head-spacing
plan: "01"
implementation_attempt: 2
subsystem: eyebrow-geometry-contract
tags: [swift, tdd, red-contract, eyebrow-head-spacing, actual-pixels]

requires:
  - phase: 89-semantic-validation-baseline
    provides: Frozen BROW-01 target, sibling, locality, protection, and Q16 acceptance predicates
provides:
  - Deterministic three-test public-facade RED pixel and lifecycle oracle for BROW-01
  - Two-test provider RED contract for normalized carriers, taper, target clearance, peer independence, and request isolation
affects: [92-02-provider-repair, 92-03-generated-validation, BROW-01]

tech-stack:
  added: []
  patterns: [independent PPM oracle, checked integer darkness centroid, progress-normalized provider contract]

key-files:
  created:
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineEyebrowHeadSpacingRepairTests.swift
    - .planning/phases/92-signed-eyebrow-head-spacing/92-01-SUMMARY.md
  modified:
    - BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift

key-decisions:
  - "Freeze BROW-01 through public-facade rendered bytes plus provider invariants; provider coordinates alone are supporting evidence."
  - "Select expected carriers from independently recomputed cumulative progress strictly below one half, with own-axis smoothstep-complement motion and target-centered clearance bounds."
  - "Keep missing and malformed peer support side-local while preserving exact dead-zone, cap, sibling, and request-isolation behavior."

duration: 14min
completed: 2026-09-07
---

# Phase 92 Plan 01: Signed Eyebrow-Head Spacing RED Contract Summary

**BROW-01 now has an independently specified, deterministic RED contract over public rendered pixels and the private provider seam, with production left byte-for-byte unchanged.**

## Performance

- **Duration:** 14 min
- **Started:** 2026-09-07T01:19:24Z
- **Completed:** 2026-09-07T01:33:06Z
- **Tasks:** 2
- **Files created/modified:** 3, including this summary

## Accomplishments

- Added an in-memory 512×512 explicit-sRGB RGBA8 fixture and independent PPM regions for the two head targets, two outer anchors, eyes, backgrounds, and watermark.
- Froze source/neutral target darkness, 500/2,000 signal floors, signed Q16 gap margins, opposite-sign and four whole-brow distinctions, locality/protection ceilings, alpha, extent, metadata, determinism, unilateral support, provider-empty behavior, lifecycle recovery, and redacted diagnostics.
- Froze provider expectations across 4-, 5-, and 16-sample production-admitted traces: cumulative-progress carriers strictly below one half, per-side axes, smoothstep-complement motion, tapered target-clearance-bounded radii, unit safety, exact strength boundaries, sibling equality, malformed-peer isolation, and valid-invalid-valid recovery.
- Adjusted only the existing generic head-spacing radius branch to accept the new variable-radius ceiling; all six sibling rows retain their prior exact-radius assertions.

## Task Commits

1. **Task 1: Freeze the RED public-facade pixel and lifecycle oracle** — `25f945a`
2. **Task 2: Freeze RED provider invariants at the private repair seam** — `1acda57`

## Exact Test Inventory

Public-facade discovery returned exactly **3** tests:

1. `testBROW01PublicFacadePassesFrozenSignedSemanticSiblingProtectionAndMetadataContract`
2. `testBROW01PerSideEligibilityAndProviderEmptyRemainSourceSafe`
3. `testBROW01ValidInvalidValidRecoveryIsByteDeterministicAndRedacted`

Provider discovery returned exactly **2** tests:

1. `testBROW01HeadSpacingUsesOwnAxisInnerHalfMonotoneTaperAndTargetClearance`
2. `testBROW01HeadSpacingPreservesDeadZoneCapPeerIndependenceAndRequestIsolation`

## Controlled RED Evidence

- The public-facade suite compiled, discovered exactly three tests, and exited nonzero with **3 tests executed, 20 assertion failures, 0 unexpected failures**.
- Failures were limited to the intended BROW-01 repair predicates: both signed candidates missed target-signal floors, produced zero signed-gap separation from source/neutral and whole-brow siblings, unilateral valid sides produced no target change, and the valid recovery output produced no active target change. Metadata, extent, alpha, neutral, invalid/provider-empty, determinism, lifecycle equality, and redaction assertions did not introduce unrelated failures.
- The focused provider suite compiled, discovered exactly two tests, and exited nonzero with **2 tests executed, 58 assertion failures, 0 unexpected failures**. The dead-zone/cap/peer/request-isolation method passed, while the formula method failed only the intended repair predicates: the pre-repair two-carrier inventory, `0.020` displacement scale, and fixed `0.060` radius do not satisfy normalized carrier selection, the `0.065` smoothstep-complement displacement contract, or the variable nominal/target-clearance radius bounds.
- Neither focused run crashed, produced zero discovered tests, nor failed on build infrastructure.

## Frozen Starting Point

- Phase execution base: `94d01d51362ff9b8426be0a006b26551c1e274ee`.
- Pre-attempt `EyebrowWarpProvider.swift` blob OID: `124946d79d380fe7e2eb14a36b3686ebdc1580a3`.
- The provider blob remained identical after both task commits, and no file under `BeautySDK/Sources` changed from the phase base.

## Security, Privacy, and Scope

- Fixture and rendered RGBA8 storage remained process-local. No image, mask, report, raw geometry record, private fixture locator, local path, or transcript was added to the repository.
- Durable changes are limited to the two declared Swift test files and this aggregate-only summary.
- No production source, testing SPI, manifest, comparator, script, package target, dependency, backend, shader, retained `Warp.metal`, public API, owner document, UI/Demo, model, data, or weight changed.
- This RED contract makes no device, portrait-quality, commercial, packaging, shipping, launch, release-readiness, or distribution claim.

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None. These tests are intentionally RED contracts for Plan 92-02; they contain complete executable predicates rather than placeholder assertions or mock output.

## Threat Flags

None. All HIGH threats assigned to this wave are represented by executable public-pixel or provider predicates, and no new production trust boundary was introduced.

## Next Phase Readiness

- Plan 92-02 can change only the private `headSpacingPoints` seam until these five tests turn GREEN without weakening the frozen oracle.
- The Phase 89 manifest, comparator, sibling set, protection limits, and package-host evidence remain unchanged for later validation.

## Self-Check: PASSED

- Both declared test files exist, and task commits `25f945a` and `1acda57` exist in history.
- Discovery counts are exactly 3 public-facade tests and 2 provider tests; both focused RED commands compile and fail only controlled BROW-01 predicates.
- `git diff --check` passes for both test files.
- The production provider hash still matches its pre-attempt blob, and the phase-base source diff is empty.
- No generated media or temporary report/log artifact remains in the repository.

---
*Phase: 92-signed-eyebrow-head-spacing*
*Completed: 2026-09-07*
