---
phase: 55-original-pixel-composition-and-failure-isolation-core
plan: "03"
subsystem: composition-core
tags: [swiftpm, rgba8, q16, collision-isolation, privacy, asvs]

requires:
  - phase: 55-01
    provides: literal mechanics oracles and fail-closed T-55 checker
  - phase: 55-02
    provides: exact canonical source binding, bounded unit issuance, and checked preflight
provides:
  - deterministic original-canonical RGB composition with UInt64 Q16 round-half-up blending
  - post-filter hard re-clipping, zero-claim elimination, and exact no-change carrier reuse
  - sorted single ownership with two-or-more-owner collision-to-source semantics
  - aggregate-only six-count result and smallest-unit failure isolation
affects: [55-04, 55-05, 56, 57, local-retouch-providers]

tech-stack:
  added: []
  patterns: [canonical-source-only integer blend, deterministic sparse claim reduction, pixel-local collision suppression]

key-files:
  created: []
  modified:
    - BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift
    - .planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py
    - PLANS.md

key-decisions:
  - "Every accepted RGB channel is blended from immutable canonical bytes with UInt64 Q16 round-half-up arithmetic; mutable output is only a destination."
  - "Claims are sorted by pixel index and opaque unit token; a group with two or more units performs no write and increments one collision-pixel count."
  - "A structurally valid unit is accepted only when hard re-clipping leaves an effective nonzero claim, and a composition with no changed RGB returns the exact captured canonical carrier."

patterns-established:
  - "Ownership reduction: preflight every unit, remove zero/outside claims, sort effective claims, then process each pixel group exactly once."
  - "Failure isolation: foreign, duplicate, malformed, and effective-empty units abstain while unrelated accepted claims compose unchanged."

requirements-completed: [COMP-03, COMP-04]

duration: 12min
completed: 2026-08-03
---

# Phase 55 Plan 03: Deterministic Original-Pixel Composition Summary

**Canonical RGBA8 pixels now compose through deterministic Q16 RGB blending with hard re-clipping, collision-to-source ownership, exact alpha preservation, and aggregate-only failure isolation.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-08-03T07:12:39Z
- **Completed:** 2026-08-03T07:24:12Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Implemented UInt64 Q16 round-half-up blending from immutable canonical RGB, preserving canonical alpha and every unowned byte while reusing the exact source carrier when no RGB changes.
- Added deterministic sorted sparse ownership reduction: unique claims blend once, while two or three owners at one pixel preserve source and increment exactly one aggregate collision count without dropping adjacent sibling work.
- Bounded duplicate-token frequency storage to the at-most-eight locally issued tokens, so arbitrarily many foreign units abstain without growing request-owned frequency state or suppressing a valid local sibling.
- Added production-backed literal endpoint/midpoint/clamp, disjoint permutation, two/three-owner collision, foreign/duplicate/effective-empty abstention, opaque failure-matrix, empty-call, and valid-invalid-valid recovery coverage.
- Strengthened checker `--composition` and `--privacy` modes to require production oracles, original-source and bounded-frequency anchors, exact six-field summary/two-field result shapes, and feature-neutral non-Codable diagnostics. Its historical 44-case synthetic self-test is superseded by the post-review live-fixture checker recorded in `55-COMPOSITION-EVIDENCE.md`.

## Task Commits

Each task was committed atomically:

1. **Task 55-03-01: Compose uniquely owned pixels once from canonical RGB with hard re-clipping** — `a108690` (feat)
2. **Task 55-03-02: Suppress collisions pixel-locally and isolate every invalid or absent opaque unit** — `7902f2b` (feat)
3. **Task 55-03-02 security follow-up: Bound duplicate-token accounting to issued local tokens** — `4849622` (fix)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift` — preflights and sorts effective claims, composes canonical-source RGB, suppresses collisions, and returns the six-count result.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift` — independent reference literals plus production-backed composition, collision, failure, privacy-shape, and recovery oracles.
- `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py` — distinct composition/privacy enforcement with exact result-shape and feature-neutral source checks.
- `PLANS.md` — Wave 2 implementation and verification evidence.

## Verification Results

- Exact Task 55-03-01 focused command: 3/3 tests passed; checker `--composition` passed T-55-01…07; diff hygiene passed.
- Exact Task 55-03-02 command: complete `BeautyLocalRetouchCompositionTests` passed 20/20; checker `--privacy` passed T-55-01…07; diff hygiene passed.
- Checker Python syntax passed; the historical 44-case synthetic result is superseded by the post-review live-fixture self-test.
- Full SwiftPM and Demo regression remain intentionally reserved for Plan 55-05.

## Decisions Made

- Used a total deterministic claim comparator of pixel index followed by opaque issued token. Token ordering never selects a winner: any same-index group with more than one accepted unit is suppressed to source.
- Counted `ownedPixelCount` only for uniquely owned post-collision pixels and `changedPixelCount` only when the final RGB differs; `changedOutsideUnionPixelCount` remains mechanically zero because no other index can be written.
- Reconstructed a canonical carrier only after at least one RGB change; unchanged targets, empty inputs, effective-empty inputs, and collision-only calls preserve exact source storage identity.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Made the privacy mode enforce its declared boundary**
- **Found during:** Task 55-03-02
- **Issue:** Plan 55-02 had added the `--privacy` parser mode, but it still delegated to composition checks and did not verify the exact six-field summary, two-field result, or feature-neutral diagnostic surface.
- **Fix:** Added narrow privacy-shape/source checks and three mutation cases while retaining all pre-existing common, source-binding, candidate, admission, Demo, realtime, dependency, and compatibility gates.
- **Files modified:** `.planning/phases/55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py`
- **Verification:** Python syntax, 43-case self-test, `--composition`, and `--privacy` all pass.
- **Committed in:** `7902f2b`

**2. [Rule 2 - Missing Critical] Bounded duplicate-token frequency storage**
- **Found during:** Final T-55-02 threat-surface scan after Task 55-03-02
- **Issue:** `Dictionary(grouping: units)` retained every supplied unit in frequency buckets even though only at most eight locally issued tokens can ever be accepted, allowing foreign input to grow request-owned accounting unnecessarily.
- **Fix:** Count only exact-source, exact-owner, issued local tokens in a saturated frequency dictionary bounded by `effectiveUnitLimit`; all foreign units still abstain individually and a valid local sibling remains accepted.
- **Files modified:** `BeautyLocalRetouchComposition.swift`, `BeautyLocalRetouchCompositionTests.swift`, and the Phase 55 checker.
- **Verification:** The 20-test suite includes ten foreign units plus one retained valid sibling; the checker rejects unbounded grouping. Current live-fixture mutation evidence is recorded in `55-COMPOSITION-EVIDENCE.md`.
- **Committed in:** `4849622`

---

**Total deviations:** 2 auto-fixed (2 missing critical)
**Impact on plan:** Both changes close plan-owned HIGH privacy/allocation gaps without expanding production or product scope.

## Issues Encountered

- Swift could not type-check a compact test-only `flatMap` literal within its time limit. Replacing it with an explicit bounded 16-pixel byte builder preserved the same oracle and allowed the complete suite to compile.
- The Plan 55-02 source-binding test expected the original carrier because composition was previously a no-op. Its assertion was advanced to literal changed bytes plus identical normalized metadata; exact carrier identity remains asserted for all no-change paths.

## Known Stubs

None. Empty collections in preflight accumulators, the reference model, and checker synthetic absence fixtures are intentional initialized state rather than unwired output.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 55-04 can connect this completed feature-neutral core to the existing opaque Testing-only request-context seam without adding production admission.
- Exact-empty production admission, all three closed feature gates, public API, candidate inventory, Demo, realtime/pixel-buffer paths, dependencies, resources, and product evidence remain unchanged.

## Self-Check: PASSED

- All three implementation/verification artifacts, `PLANS.md`, and this summary exist.
- Task commits `a108690`, `7902f2b`, and `4849622` are present in repository history.
- Both exact plan verification commands, checker self-test, and final diff hygiene pass.

---
*Phase: 55-original-pixel-composition-and-failure-isolation-core*
*Completed: 2026-08-03*
