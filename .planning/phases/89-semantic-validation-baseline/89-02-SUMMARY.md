---
phase: 89-semantic-validation-baseline
plan: "02"
subsystem: testing
tags: [swift, core-image, semantic-validation, deterministic-json, privacy]

requires:
  - phase: 89-01-semantic-validation-contracts
    provides: "Frozen five-batch, 65-case, eight-direction semantic contracts with integer PPM/Q16 thresholds"
provides:
  - "Seven source-and-neutral-grounded semantic metric oracles for eight repair directions"
  - "Exact 5/65/8 fail-closed input and output reconciliation with watermark-safe measurements"
  - "Canonical aggregate-only semantic payloads with stable digests and separate volatile run metadata"
affects: [89-03-batch-runner, 89-04-validation-documentation, phases-90-94-repairs]

tech-stack:
  added: []
  patterns: [checked-int64-q16-metrics, exact-inventory-admission, canonical-stable-payload]

key-files:
  created: []
  modified:
    - scripts/compare-face-feature-batches.swift

key-decisions:
  - "Semantic acceptance is one conjunction of source signal, neutral signal, signed direction, minimum signal, outside locality, sibling distinction, and every protected-region ceiling."
  - "The canonical payload contains only fixed aggregate fields; timestamp and attempt identity stay in a separate volatile envelope and cannot change the stable digest."

patterns-established:
  - "Every image is admitted, canonically decoded once, dimension-matched, and measured through half-open watermark-clipped regions using checked integer arithmetic."
  - "Infrastructure rejection removes any prior report before reconciliation; only a complete exact-inventory payload is written atomically."

requirements-completed: [VAL-01, VAL-02]

coverage:
  - id: D1
    description: "Eight repair directions use seven direction-specific semantic oracles grounded in both source and neutral evidence, with locality, protection, sibling, and minimum-signal gates."
    requirement: VAL-01
    verification:
      - kind: unit
        ref: "scripts/compare-face-feature-batches.swift#runSemanticSelfTests"
        status: pass
      - kind: other
        ref: "scripts/compare-face-feature-batches.swift#swiftc typecheck"
        status: pass
    human_judgment: false
  - id: D2
    description: "The comparator reconciles exact 5/65/8 inventories and writes deterministic aggregate-only semantic payloads with distinct success, semantic-failure, and infrastructure-failure statuses."
    requirement: VAL-02
    verification:
      - kind: integration
        ref: "scripts/compare-face-feature-batches.swift#runSemanticReportSelfTests"
        status: pass
      - kind: other
        ref: "no-argument fail-closed CLI probe (exit 3)"
        status: pass
    human_judgment: false

duration: 19min
completed: 2026-08-26
status: complete
---

# Phase 89 Plan 02: Semantic Validation Baseline Summary

**Seven fixed-point facial-direction oracles with exact input reconciliation and deterministic privacy-safe 5/65/8 semantic reports**

## Performance

- **Duration:** 19 min
- **Started:** 2026-08-26T02:31:33Z
- **Completed:** 2026-08-26T02:50:13Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments

- Added contour continuity, centerline taper, own-eye pupil centering, signed inner-brow gap, bridge definition, root contraction, and mouth-width contraction metrics using checked `Int64`/Q16 arithmetic.
- Required every semantic direction to clear source and neutral target signal, signed polarity, minimum signal, outside-target locality, all protected ceilings, and documented sibling distinction; mechanical changed-pixel summaries remain descriptive only.
- Replaced the prior report with a canonical aggregate-only schema that admits exact fresh regular-file inventories, rejects unsafe paths and malformed images, separates volatile metadata, recursively scans privacy, and emits distinct semantic versus infrastructure statuses.

## Task Commits

Each task was committed atomically through its TDD gates:

1. **Task 1 RED: Add failing direction oracle gate** - `842a45e` (test)
2. **Task 1 GREEN: Implement semantic direction oracles** - `088917f` (feat)
3. **Task 2 RED: Add failing semantic report gate** - `5114c67` (test)
4. **Task 2 GREEN: Publish stable semantic reports** - `f19117e` (feat)

## Files Created/Modified

- `scripts/compare-face-feature-batches.swift` - Seven semantic metrics, source/neutral conjunctions, exact file admission, stable aggregate report types, privacy scan, digest, exit codes, and 180 generated mutations.

## Decisions Made

- A missing or ambiguous metric observation, including one pupil core without its peer, is a direction-local semantic failure; malformed paths, inventories, files, decodes, or dimensions are infrastructure failures.
- Watermark rows are removed from target, outside, sibling, and protected measurements. A protected watermark rectangle wholly removed by that clipping contributes exact zero rather than becoming semantic evidence.
- Stable arrays are canonicalized by frozen batch, case, direction, and protected-region order before sorted-key encoding; volatile timestamps and attempt IDs never enter the stable digest.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Known Stubs

None. Stub-pattern scanning found no TODO, FIXME, placeholder, coming-soon, unavailable, or unwired mock-data implementation in the modified file.

## Threat Flags

None. The new local file-admission and report-encoding surfaces are the explicit T-89-01 through T-89-06 mitigation scope in the plan threat model.

## Authentication Gates

None.

## User Setup Required

None - no external service configuration required.

## Automated Evidence

- Comparator semantic self-test → `semantic_validation_self_test=PASS mutations=180 inventories=5/65/8`
- Swift compiler type-check of the comparator → passed
- Git whitespace validation → passed
- No-argument fail-closed CLI probe → exit `3`, fixed output `semantic_report=infrastructure_failure`
- TDD gates → Task 1 RED/GREEN `842a45e` / `088917f`; Task 2 RED/GREEN `5114c67` / `f19117e`

## Next Phase Readiness

- Plan 89-03 can pass a runner-owned attempt ID, remove child render transcripts, execute two never-reused run roots, and compare the stable payload digests.
- Live authorized portrait outcomes remain owner-local and ignored. Generated mechanics do not establish device, population, commercial, release, shipping, launch, or distribution claims.

## Self-Check: PASSED

- The modified comparator and this summary exist.
- Task commits `842a45e`, `088917f`, `5114c67`, and `f19117e` exist in Git history.
- All plan verification commands and generated privacy/admission/status mutations passed.
- No authorized portrait media was read during execution.

---
*Phase: 89-semantic-validation-baseline*
*Completed: 2026-08-26*
