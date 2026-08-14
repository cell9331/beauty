---
phase: 67-swiftpm-consumer-and-cli-validation-contract
plan: "04"
subsystem: testing-and-tooling
tags: [swiftpm, consumer, cli, foundation-process, privacy, documentation]

# Dependency graph
requires:
  - phase: 67-swiftpm-consumer-and-cli-validation-contract
    provides: public-only consumer fixture, CPU CLI/report contract, and compiled Process matrix
provides:
  - synchronized current owners and codebase maps for the measured consumer/CLI contract
  - archive → SDK-boundary → consumer → one-child no-skip closeout evidence
  - privacy-safe Phase 67 ledger record with exact 74-case and CPU-only scope fences
affects: [phase-68-cpu-algorithm-reference, phase-69-sdk-only-closeout, v1.17-metal-rendering]

# Tech tracking
tech-stack:
  added: []
  patterns: [measured SwiftPM inventory, public-product-only consumer evidence, bounded aggregate CLI reporting]

key-files:
  created:
    - .planning/phases/67-swiftpm-consumer-and-cli-validation-contract/67-04-SUMMARY.md
  modified:
    - ARCHITECTURE.md
    - SECURITY.md
    - RELIABILITY.md
    - PRODUCT_SENSE.md
    - QUALITY_SCORE.md
    - PLANS.md
    - .planning/PROJECT.md
    - .planning/codebase/STRUCTURE.md
    - .planning/codebase/TESTING.md
    - .planning/codebase/INTEGRATIONS.md

key-decisions:
  - "Document the external fixture as a public BeautySDK-only SwiftPM consumer, not an SDK target or public API."
  - "Keep the renderer CPU-only in v1.16: `gpu` and unknown backend tokens fail until v1.17, with no public backend selector."
  - "Persist only versioned aggregate report identities/counts; treat paths, child output, pixels, masks, geometry, and fixture metadata as transient or forbidden."

patterns-established:
  - "Record measured source/test inventories and the single no-skip child aggregate rather than carrying forward predicted counts."
  - "Bind focused consumer/renderer/process evidence before the archive-first mandatory conjunction."

requirements-completed: []

# Metrics
duration: 32min
completed: 2026-08-14
---

# Phase 67 Plan 04: SwiftPM Consumer and CLI Validation Contract Summary

**Current owners and maps now record a measured public-only consumer/CPU CLI contract, closing the 74-case process matrix through the archive-first no-skip conjunction.**

## Performance

- **Duration:** 32 min
- **Started:** 2026-08-14T05:29:00Z
- **Completed:** 2026-08-14T06:01:44Z
- **Tasks:** 2
- **Files modified:** 10 (summary included separately)

## Accomplishments

- Synchronized ARCHITECTURE, SECURITY, RELIABILITY, PRODUCT_SENSE, and QUALITY_SCORE with the public-only local-path consumer, exact 74-case CPU CLI, versioned privacy-safe report, typed failures, persisted PNG validation, and executable-internal render/encode seams.
- Recalculated the active inventory at 66 Swift source files / 14,830 source lines and 51 SwiftPM test files / 27,993 test lines; recorded the measured 656-test full child with all eight opt-ins, zero failures, and zero skips.
- Updated PROJECT, STRUCTURE, TESTING, INTEGRATIONS, and PLANS with SPM-01/SPM-02/CLI-01/CLI-02/CLI-03 evidence, focused commands, mandatory ordering, and explicit CPU-only/non-release boundaries.

## Task Commits

Each task was committed atomically:

1. **Task 1: Synchronize architecture, security, reliability, product, and quality owners** - `7965d37` (docs)
2. **Task 2: Close current project, maps, and ledger through the mandatory conjunction** - `523d2e6` (docs)

## Files Created/Modified

- `ARCHITECTURE.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` - current owner contracts for public consumer, CLI reports, trust boundaries, typed failures, and v1.16 scope.
- `.planning/PROJECT.md`, `.planning/codebase/STRUCTURE.md`, `.planning/codebase/TESTING.md`, `.planning/codebase/INTEGRATIONS.md` - measured project snapshot and current codebase/integration maps.
- `PLANS.md` - completed Phase 67 ledger row with requirement evidence and nonclaims.

## Decisions Made

- Keep integration evidence outside the SDK target graph: the consumer has one local path dependency and imports only public `BeautySDK`.
- Preserve the CPU/Core Image implementation, 61 public fields, five neutral presets, retained shader digest, and 74 renderer cases without adding a public backend or Metal path.
- Treat report identities and aggregate counts as the only durable CLI evidence; temporary output, child diagnostics, environment seams, raw pixels, masks, geometry, and private metadata are not persisted.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Serena was not exposed in this executor session; plain-text documentation inspection, repository-owned scripts, SwiftPM, and `rg` were used as permitted by AGENTS.md.
- An existing unrelated Swift warning in `FaceObservationMappingTests.swift` appeared during SwiftPM compilation; it did not affect the focused or no-skip result and was not changed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 67's consumer, CLI, and no-skip conjunction is ready for independent phase verification and Phase 68 CPU oracle work.
- v1.16 remains CPU-only. Public backend selection, Metal/GPU execution, UI/Demo, simulator/device, commercial, packaging, shipping, launch, and release-readiness work remain outside this closeout.

## Verification

- `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui` - passed both retained archive digests.
- `bash scripts/check-sdk-only-boundary.sh --post-archive` - passed before focused checks and after documentation updates.
- `bash scripts/check-swiftpm-consumer.sh` - passed clean public-product consumer smoke.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` - passed 24/24.
- `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyExampleRendererProcessTests` - passed 5/5.
- `bash scripts/run-no-skip-swiftpm.sh` - passed archive → boundary → consumer → one-child order, 656 executed, 0 failures, 0 skips, all 8 opt-ins.
- `git diff --check` - passed.

## Self-Check: PASSED

- Summary and all ten planned owner/map/ledger files exist as regular files.
- Task commits `7965d37` and `523d2e6` exist in repository history.
- Stub scan found no unintentional placeholder, TODO/FIXME, empty UI data source, or unconnected product surface in files modified by this plan.
- Threat scan found no new runtime trust boundary; documentation records only the already-planned public consumer, CLI report, temporary output, and executable-internal failure seam with privacy/nonclaim fences.

## Known Stubs

- `.planning/codebase/STRUCTURE.md:49` - retained `Warp.metal` is intentionally
  documented as a byte-pinned inactive placeholder resource; v1.16 does not
  claim GPU execution and v1.17 owns any future implementation.

---
*Phase: 67-swiftpm-consumer-and-cli-validation-contract*
*Completed: 2026-08-14*
