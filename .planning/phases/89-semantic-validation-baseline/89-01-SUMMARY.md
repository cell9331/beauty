---
phase: 89-semantic-validation-baseline
plan: "01"
subsystem: testing
tags: [swift, json, semantic-validation, generated-fixtures, privacy]

requires:
  - phase: v1.22-roadmap
    provides: "Five-batch 65-case owner-local renderer inventory and eight weak/inert directions"
provides:
  - "Frozen aggregate semantic contracts for exactly eight renderer directions"
  - "Typed fail-closed manifest admission with integer PPM half-open regions"
  - "Generated 146-mutation self-test for exact boundary and precision behavior"
affects: [89-02-semantic-metrics, 89-03-batch-runner, 89-04-validation-documentation]

tech-stack:
  added: []
  patterns: [integer-ppm-half-open-regions, category-only-validation-errors, generated-in-memory-oracles]

key-files:
  created: []
  modified:
    - scripts/face-feature-batch-manifest.json
    - scripts/compare-face-feature-batches.swift

key-decisions:
  - "Semantic acceptance uses exact source, neutral, and documented sibling comparisons before any live portrait result is inspected."
  - "Region ownership and verdict boundaries use checked integer PPM/Q16 arithmetic; background and watermark protection remain byte-exact."

patterns-established:
  - "Manifest admission validates exact 5/65/8 ordering, closed enums, fixed references, disjoint half-open ownership, and nonnegative frozen thresholds before image work."
  - "Self-tests report only fixed category names and aggregate counts while generated RGBA buffers remain invocation-local."

requirements-completed: [VAL-01, VAL-02]

coverage:
  - id: D1
    description: "Five batches and 65 live cases retain their order while eight directions own frozen semantic contracts."
    requirement: VAL-02
    verification:
      - kind: integration
        ref: "python3 manifest 5/65/8 inventory assertion"
        status: pass
    human_judgment: false
  - id: D2
    description: "Generated boundary, ownership, admission, ordering, arithmetic, and verdict probes fail closed without portrait input."
    requirement: VAL-01
    verification:
      - kind: unit
        ref: "swift scripts/compare-face-feature-batches.swift --self-test"
        status: pass
      - kind: other
        ref: "swiftc -typecheck scripts/compare-face-feature-batches.swift"
        status: pass
    human_judgment: false

duration: 13min
completed: 2026-08-26
status: complete
---

# Phase 89 Plan 01: Semantic Validation Baseline Summary

**Eight direction-specific semantic contracts with checked integer regions and a 146-mutation generated fail-closed harness**

## Performance

- **Duration:** 13 min
- **Started:** 2026-08-26T02:14:53Z
- **Completed:** 2026-08-26T02:27:47Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Preserved the exact five batches and all 65 unique renderer case IDs while adding eight ordered semantic contracts.
- Froze source, neutral, sibling, polarity, target, locality, and independently named protected-region requirements using integer PPM rectangles and Q16 margins.
- Added 146 generated mutations across six named probe categories, including equality/one-unit boundaries, half-open ownership, missing inputs, stable ordering, checked overflow, and fail-closed verdicts.
- Confirmed the self-test reads no authorized portrait and emits no raw buffer, locator, temporary path, mask, or landmark data.

## Task Commits

Each task was committed atomically:

1. **Task 1: Freeze eight direction-specific manifest contracts** - `73dfdcc` (feat)
2. **Task 2 RED: Add failing semantic contract harness** - `51cd7ca` (test)
3. **Task 2 GREEN: Validate semantic contract boundaries** - `a18c665` (feat)

## Files Created/Modified

- `scripts/face-feature-batch-manifest.json` - Compatible semantic schema extension with exact 5/65/8 inventory and fixed region/threshold contracts.
- `scripts/compare-face-feature-batches.swift` - Typed contracts, exact manifest validator, checked PPM/Q16 helpers, generated self-test, and preserved mechanical comparator entry point.

## Decisions Made

- Comparison lists are frozen in source → `geometryBaseline_noop` → documented sibling order so live results cannot choose their own comparator or threshold.
- Historical broad ROIs remain outer bounds, but semantic targets and adjacent anatomy are disjoint subregions; background and watermark ceilings are exactly zero.
- Validation errors exposed by mutations are fixed category-only identifiers, keeping malformed-input diagnostics privacy-safe and deterministic.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- The initial shell assertion used zsh's read-only `status` variable; the verification command was immediately rerun with a task-local variable and passed. No repository change was required.

## Known Stubs

None. Stub-pattern scanning found no TODO, FIXME, placeholder, coming-soon, or unavailable implementation in the modified files.

## Authentication Gates

None.

## User Setup Required

None - no external service configuration required.

## Verification

- `swift scripts/compare-face-feature-batches.swift --self-test` → `semantic_contract_self_test=PASS mutations=146 directions=8 categories=boundary,ownership,admission,ordering,arithmetic,verdict`
- `swiftc -typecheck scripts/compare-face-feature-batches.swift` → passed
- Manifest inventory assertion → `manifest_contract=5/65/8`
- Semantic private-locator scan → passed
- `git diff --check` → passed
- TDD gates → RED `51cd7ca`, GREEN `a18c665`

## Next Phase Readiness

- Plan 89-02 can implement the seven live semantic metrics against the frozen typed contracts without changing inventory, comparators, regions, or thresholds.
- No blockers. Generated mechanics do not establish portrait efficacy, device behavior, population quality, commercial quality, release readiness, or distribution authority.

## Self-Check: PASSED

- Both modified files exist.
- Task commits `73dfdcc`, `51cd7ca`, and `a18c665` exist in Git history.
- All task acceptance criteria and plan-level verification commands passed.
- No authorized portrait was read during the generated self-test.

---
*Phase: 89-semantic-validation-baseline*
*Completed: 2026-08-26*
