---
phase: 45-public-contract-and-observed-face-support
plan: "05"
subsystem: contract-validation
tags: [swift, vision, documentation, privacy, face-geometry, nyquist]

requires:
  - phase: 45-public-contract-and-observed-face-support
    provides: Plans 45-01 through 45-04 exact public storage, actual Vision mapping, face-specific validation, and legacy isolation
provides:
  - authoritative owner contracts for the exact 52-field public model and private observed face support
  - executed 34-check self-test and 13-check live fail-closed boundary evidence
  - complete focused and 347-test SwiftPM requirement closeout
  - explicit provider, output, semantic-region, Demo, and release-readiness nonclaims
affects: [46-independent-contour-and-chin-geometry, 47-public-facade-face-output-evidence, 48-face-safety-and-scoped-closeout]

tech-stack:
  added: []
  patterns:
    - owner-routed contract synchronization without duplicating detailed invariants
    - validation status changes only after executable evidence passes

key-files:
  created:
    - .planning/phases/45-public-contract-and-observed-face-support/45-05-SUMMARY.md
  modified:
    - DESIGN.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - PLANS.md
    - .planning/phases/45-public-contract-and-observed-face-support/45-VALIDATION.md

key-decisions:
  - "Keep exact model/support mechanics in DESIGN, trust prohibitions in SECURITY, lifecycle/failure evidence in RELIABILITY, user acceptance in PRODUCT_SENSE, and execution history in PLANS."
  - "Mark Phase 45 validation complete only after every focused suite, both checker modes, full SwiftPM, active-source review, and diff hygiene pass."
  - "Keep all four public controls storage-only and unrouted until Phase 46; observed support remains separate from the exact seven-point compatibility proxy."

patterns-established:
  - "Closeout evidence records commands, actual counts, immutable baselines, requirement mapping, final constants, and downstream nonclaims together."
  - "A sandbox-only toolchain failure is recorded and rerun with required host access rather than reclassified as a product pass or fixed through source changes."

requirements-completed: [FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, SUPP-04]

duration: 7 min
completed: 2026-07-23
---

# Phase 45 Plan 05: Face Contract and Boundary Closeout Summary

**Exact 52-field public compatibility and request-local observed contour/median support are synchronized across their owners and closed by fail-closed boundary plus 347-test SwiftPM evidence**

## Performance

- **Duration:** 7 min
- **Started:** 2026-07-23T05:42:23Z
- **Completed:** 2026-07-23T05:49:34Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Updated each authoritative root owner with the delivered public model, actual Vision provenance, one-mapper canonicalization, face-specific validation, proxy separation, privacy/lifetime policy, deterministic degradation, user acceptance, and explicit downstream nonclaims.
- Completed `45-VALIDATION.md` with every Plan 45 task command, actual counts, the final A1 envelope, requirement traceability, aggregate-only fixture evidence, active-source/diff review, and zero unresolved HIGH threats.
- Closed FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, and SUPP-04 without adding provider, resolver, conflict, facade, renderer, Demo, dependency, target, model, resource, network, persistence, or generated-artifact scope.

## Task Commits

Each task was committed atomically with repository hooks enabled:

1. **Task 45-05-01: Synchronize authoritative contracts and nonclaims** — `f81a9ab` (`docs`)
2. **Task 45-05-02: Execute the live boundary and requirement closeout gate** — `31fb090` (`docs`)

## Files Created/Modified

- `DESIGN.md` — owns the four exact public names, normalization/default/52-key contract, actual Vision mapping, canonical paths, full A1 constants, independent eligibility, proxy separation, and no-consumer boundary.
- `SECURITY.md` — owns malformed/oversized trust checks, proxy-spoofing prohibition, raw-coordinate privacy/lifetime, no identity or biometric-profiling claim, and dependency/model/resource/network/public-surface bans.
- `RELIABILITY.md` — owns one-request/one-mapper bounded work, interruption/no persistence, region and sibling isolation, deterministic metadata behavior, aggregate diagnostics, and executable closeout counts.
- `PRODUCT_SENSE.md` — owns user-verifiable public compatibility and honest observed-support acceptance while keeping all four controls visibly neutral until later phases.
- `PLANS.md` — records the complete Phase 45 scope, evidence, seven closed requirements, and downstream/deferred nonclaims.
- `.planning/phases/45-public-contract-and-observed-face-support/45-VALIDATION.md` — records final Nyquist/Wave 0 status, commands, actual outcomes, requirements, constants, source review, and threat closeout.

## Exact Executed Evidence

| Gate | Result |
| --- | --- |
| `check_face_support_boundaries.py --self-test` | PASS — 34/34 |
| `check_face_support_boundaries.py` | PASS — 13/13 live checks |
| `BeautyParametersTests` | PASS — 32/32 |
| `BeautyResourceCatalogTests` | PASS — 9/9 |
| `BeautyEffectResolverTests` | PASS — 20/20 |
| `VisionFaceDetectorTests` | PASS — 18/18 |
| `FaceObservationMappingTests` | PASS — 15/15 |
| `BeautyFaceGeometryAdapterTests` | PASS — 27/27 |
| Complete `BeautyDetectionTests` | PASS — 48/48 |
| `swift test --package-path BeautySDK` | PASS — 347/347, zero failures; final rerun 33.802 seconds |
| Owner/static acceptance and `git diff --check` | PASS |

The live checker confirms 52 stored fields, 51 numeric fields, one `filterId`, all four exact face fields, five unchanged preset hashes with absent new keys, no unclassified public/privacy/network/model/import matches, unchanged manifest/Demo/resource baselines, and clean generated-artifact containment.

## Requirement Closure

| Requirement | Closed evidence | Downstream nonclaim |
| --- | --- | --- |
| FACE-07 | Independent positive-only `faceContourSmooth`, defaults/normalization/52-key/legacy/preset tests | No provider or output |
| FACE-08 | Independent positive-only `templeFullness`, unequal round trip and no-routing test | No alias to shipped face fields |
| FACE-09 | Independent positive-only `cheekboneSlim`, compatibility and no-routing test | No borrowed cheek output |
| FACE-12 | Independent positive-only `chinTaper`, signed `chinLength` preserved | No taper vector or final cap |
| SUPP-01 | Actual Vision contour/median, one existing request, one mapped conversion path, proxy isolation | No provider consumer |
| SUPP-02 | Full metadata matrix, face-only bounded open-path validation, independent contour/centerline eligibility | No field prerequisite assignment |
| SUPP-04 | Package-only immutable lifecycle, repeated/parallel isolation, static privacy/persistence checker | No public/raw geometry surface |

## Final Support Constants

| Predicate | Inclusive bound |
| --- | ---: |
| Contour count | `7...32` |
| Median count | `3...16` |
| Contour relative width | `0.50...1.00` |
| Contour relative height | `0.20...1.00` |
| Endpoint horizontal separation | `>= 0.35` |
| Maximum chord-perpendicular curvature | `>= 0.10` |
| Median net-down projection | `>= 0.25` |
| Direction magnitude | `>= 0.000001` |
| Median-bottom chord position | `0.15...0.85` |
| Nearest-apex distance | `<= 0.40` |
| Contour points on each apex side | `>= 2` |

All six committed portraits pass the locked envelope through aggregate-only evidence. No coordinate, bounds, point sample, framework-region description, raw error, or identity claim enters committed evidence.

## Decisions Made

- Kept documentation ownership narrow: detailed design mechanics are not copied into security/reliability/product owners; those owners state their own invariants and cross-boundary consequences.
- Treated the implementation and locked `45-CONTEXT.md` names as authoritative where the plan's coverage-audit labels contained stale unrelated identifiers. No alias or invented public field was documented.
- Preserved Phase 46/47/48 ownership: Phase 45 proves storage and support readiness only, not visible effect behavior.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- A post-edit full-suite attempt inside the restricted filesystem sandbox could not write Swift's user Clang module cache. The exact command was rerun with required host/module-cache and Apple Vision access and passed 347/347; no source or package change was made.
- The plan's multi-source coverage table and static regex included stale names (`chinWidth`, `faceLift`, `foreheadHairline`, `mouthCornerLift`) that conflict with the locked context, requirements, implementation, and the same plan's D-01 action. Owner docs use only the verified names `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper`; the required regex still passes on its valid `observedFaceSupport`/`52` alternatives.

## Known Stubs

None. Provider consumption and visible output are deliberately absent Phase 46/47 work, not unfinished Phase 45 stubs.

## Security Closeout

- T-45-18 through T-45-22 and T-45-SC are mitigated.
- Unresolved HIGH threats: **0**.
- No new threat surface was introduced by the Plan 45-05 documentation/validation changes.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 46 can assign contour-only versus contour-plus-centerline prerequisites and implement four independent emissions without reopening public compatibility, mapping direction, or proxy provenance.
- Phase 47 remains responsible for decoded public-facade output evidence; Phase 48 remains responsible for final caps, exhaustive degradation/convergence, and exact four-row promotion.
- `去双下巴`, `去双下巴 Pro`, `发际线`, and branch-level `脸型` remain future or partial. Demo, device, commercial, optimized-performance, packaging, shipping, launch-readiness, and milestone-completion evidence remain unclaimed.

## Self-Check: PASSED

- All six plan-owned modified artifacts and this summary exist.
- Task commits `f81a9ab` and `31fb090` exist in repository history.
- Checker self/live modes, every focused suite, full SwiftPM, owner/static acceptance, requirement traceability, and diff hygiene pass.

---
*Phase: 45-public-contract-and-observed-face-support*
*Completed: 2026-07-23*
