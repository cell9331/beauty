---
phase: 55-original-pixel-composition-and-failure-isolation-core
plan: "01"
subsystem: testing
tags: [swiftpm, xctest, rgba8, q16, mutation-testing, asvs]

requires:
  - phase: 53-canonical-still-image-contract-and-private-request-foundatio
    provides: immutable canonical RGBA8 carrier, exact-empty admission, and opaque still-image request route
  - phase: 54-rights-approved-evidence-and-eligibility-decisions
    provides: independently closed feature decisions and exact-absence production boundary
provides:
  - compile-clean literal-byte RED specification for COMP-01 through COMP-05
  - compile-clean opaque facade/lifecycle RED specification
  - fail-closed mutation-tested Phase 55 boundary checker
  - exact ordered T-55-01 through T-55-07 HIGH threat inventory
affects: [55-02, 55-03, 55-04, 55-05, composition-core, facade-testing]

tech-stack:
  added: []
  patterns: [literal independent byte oracles, opaque aggregate-only facade observations, fixed-rule-ID checker output]

key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift
    - .planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py
    - .planning/phases/55-original-pixel-composition-and-failure-isolation-core/55-THREAT-INVENTORY.json
  modified:
    - PLANS.md

key-decisions:
  - "Wave 0 uses a compile-clean test-local reference model with literal expected bytes and fails only at named missing production seams."
  - "Boundary-checker output contains fixed rule IDs and counts only; matching source, bytes, indices, paths, and raw scanner errors are never emitted."

patterns-established:
  - "RED seam pattern: executable tests pass their contract matrix and fail only through an exact RED_MISSING_ARTIFACT marker."
  - "Threat inventory pattern: exact ordered HIGH rows are compared structurally, not accepted through a count-only denominator."

requirements-completed: [COMP-01, COMP-02, COMP-03, COMP-04, COMP-05]

duration: 11min
completed: 2026-08-03
---

# Phase 55 Plan 01: Wave 0 Composition Contract Summary

**Literal Q16/original-byte and failure-isolation RED oracles, opaque facade lifecycle contracts, and a 31-case fail-closed checker with exact T-55-01…07 HIGH ownership**

## Performance

- **Duration:** 11 min
- **Started:** 2026-08-03T06:40:19Z
- **Completed:** 2026-08-03T06:51:04Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Added 12 compile-clean mechanics tests covering literal Q16 endpoint/midpoint/clamp bytes, source alpha, exact versus foreign binding, checked relations, hard re-clipping, zero weight, duplicate raw claims/tokens, two/three-owner collision-to-source, all permutations, smallest-unit abstention, empty input, and valid-invalid-valid recovery.
- Added nine compile-clean facade tests covering both existing still-image entries, one same-source compose invocation, exact aggregate-only observations, unrelated brightness/filter continuation, recovery, pixel-buffer/reset zero work, and exact-empty production admission.
- Added a checker whose 31 self-test mutations cover all seven named HIGH threats plus required-file, scanner, privacy, SPI, candidate, package/dependency, Demo, realtime, compatibility, orphan, and specification rules.
- Added an exact structural threat inventory for T-55-01 through T-55-07; all rows are HIGH, `mitigate`, and own specific named gates.

## Task Commits

Each task was committed atomically:

1. **Task 55-01-01: Freeze literal-byte composition and failure-isolation RED specifications** — `c0963b5` (test)
2. **Task 55-01-02: Freeze facade RED contracts and mutation-tested closed-boundary checker** — `a1282b6` (test)

## Files Created/Modified

- `BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift` — tiny opaque RGBA8 literals and independently implemented RED contract model.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift` — opaque facade scenario/result expectations and lifecycle/compatibility RED seams.
- `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py` — fail-closed common, Wave 0, live, and mutation-self-test checks.
- `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/55-THREAT-INVENTORY.json` — exact ordered ASVS Level 1 HIGH inventory.
- `PLANS.md` — actual Wave 0 command results and explicit scope nonclaims.

## Verification Results

- Python syntax compilation: passed.
- Threat JSON parsing and exact structural validation: passed, 7/7 ordered HIGH rows.
- Checker `--self-test`: passed 31 mutation cases.
- Checker `--expect-wave0-red`: passed with exactly W55-01, W55-02, and W55-03 expected RED rule IDs.
- Checker default live mode: exited nonzero only with `R55-COMPOSITION`, the planned absent production artifact.
- `BeautyLocalRetouchCompositionTests`: built and discovered 12 tests; 11 passed and one failed only at `RED_MISSING_ARTIFACT:BeautyLocalRetouchComposition.swift`.
- `BeautyEngineLocalRetouchCompositionTests`: built and discovered nine tests; seven passed and two failed only at the named opaque scenario/result seams.
- `git diff --check`: passed.
- Full SwiftPM and Demo regression: intentionally not run; Plan 55-05 owns those final-only gates.

## Decisions Made

- Kept all A/B/C/D mechanics labels test-local and opaque; no production anatomy or candidate enum was introduced.
- Kept output bytes inside tests and exposed only dimensions, one source-match Boolean, invocation count, and the six aggregate counters in the facade specification.
- Required exact threat-document equality so missing, reordered, renamed, or weakened gates fail closed rather than satisfying a numeric total.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The first local verification invocation used zsh's read-only `status` variable; rerunning the exact plan command under `sh -c` resolved the shell-only issue without changing the contract.
- The initial reset-section checker boundary ended before `reset()` because the selected end anchor preceded that method. The boundary was corrected to the following public property, and all 31 mutation cases plus Wave 0 mode passed.
- The state advance helper could not parse the repository's descriptive pre-plan position line, and later state mutations normalized two frontmatter values incorrectly. The tracking record was reconciled to the actual 1/5 plan position, 12/16 plan progress, milestone name, phase identity, and measured metrics before the metadata commit.

## TDD Gate Compliance

The RED gate is present in both task commits. This Wave 0 plan deliberately forbids production implementation, so it has no GREEN `feat(...)` commit; Plans 55-02 through 55-04 own the staged GREEN implementation. Treating the absent GREEN commit as intentional preserves the plan's no-production boundary.

## Known Stubs

None. Empty arrays/strings in the test-local mutation fixture represent deliberate absence rules, and optional `nil` is used only to default a declared test claim count to its literal proposal count.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 55-02 can replace the named production-source RED seam with exact canonical storage binding and checked preflight behavior.
- Production admission, candidate inventory, Demo, realtime/pixel-buffer routing, dependencies, resources, models, and visible output remain unchanged.

## Self-Check: PASSED

- All four planned artifacts exist.
- Task commits `c0963b5` and `a1282b6` exist in repository history.
- All task acceptance and plan-level verification commands were rerun with the recorded outcomes.

---
*Phase: 55-original-pixel-composition-and-failure-isolation-core*
*Completed: 2026-08-03*
