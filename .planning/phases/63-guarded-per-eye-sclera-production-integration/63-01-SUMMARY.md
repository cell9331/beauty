---
phase: 63-guarded-per-eye-sclera-production-integration
plan: "01"
subsystem: testing
tags: [swift, vision, sclera, privacy, mutation-testing]
requires:
  - phase: 62-sclera-evidence-and-admission-contract
    provides: exact-open sclera decision, public scalar, opaque demand and private runner
provides:
  - RED per-eye support, anatomy guard, reclip and transform contracts
  - RED one-request lifecycle and private genuine-fixture contracts
  - eight-HIGH fail-closed mutation checker
affects: [63-02, 63-03, 63-04, sclera-provider]
tech-stack:
  added: []
  patterns: [guard-before-score, fixed-output-private-evidence, eight-threat-mutation-gate]
key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineScleraRednessIntegrationTests.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift
    - .planning/phases/63-guarded-per-eye-sclera-production-integration/check_phase63_sclera_provider_boundaries.py
  modified: []
key-decisions:
  - "The production API is frozen as one result containing stable left-then-right zero-to-two units plus aggregate per-eye outcomes."
  - "Private production bounds were authored before actual output execution and require zero reviewed-mask escape."
patterns-established:
  - "Per-eye RED contract: ambiguous side ownership rejects sclera globally; canonical missing/malformed support rejects only that eye."
  - "Privacy-safe RED gate: local fixture execution is opt-in and fixed-output through the Phase 62 runner."
requirements-completed: [SCLERA-09, SCLERA-10, SCLERA-11, SCLERA-12, SCLERA-13]
coverage:
  - id: D1
    description: "Per-eye support, hard-envelope, reclip and transform contracts are frozen before source implementation."
    requirement: SCLERA-09
    verification: []
    human_judgment: true
    rationale: "The XCTest suite is intentionally RED until Plans 63-02 and 63-03 implement the frozen seams."
  - id: D2
    description: "Eight HIGH threat owners reject one isolated mutation each."
    requirement: SCLERA-13
    verification:
      - kind: other
        ref: "python3 check_phase63_sclera_provider_boundaries.py --self-test"
        status: pass
    human_judgment: false
duration: 8 min
completed: 2026-08-07
status: complete
---

# Phase 63 Plan 01: Guarded Sclera RED Contracts Summary

**Per-eye anatomy, transform, lifecycle and private-fixture expectations are frozen behind an eight-HIGH mutation gate before production source exists.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-08-07T10:32:00Z
- **Completed:** 2026-08-07T10:40:36Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added deterministic contracts for actual contour/pupil ownership, peer-eye
  isolation, guard-before-score, post-feather reclip and source-only transform.
- Froze one-request engine lifecycle, teeth/sclera activation isolation,
  recovery and opt-in genuine positive/negative aggregate bounds.
- Added a fixed-output checker whose eight isolated HIGH mutations pass 8/8.

## Task Commits

1. **Task 1: Freeze actual-support, per-eye hard-envelope and reclip contracts** — `85c6f13`
2. **Task 2: Freeze transform, lifecycle, private pair and scope contracts** — `df26f9d`

## Files Created/Modified

- `BeautyScleraRednessProviderTests.swift` — per-eye mechanics and transform RED oracles.
- `BeautyEngineScleraRednessIntegrationTests.swift` — production routing and recovery RED oracles.
- `BeautyScleraRednessRealFixtureTests.swift` — frozen fixed-output private aggregate gate.
- `check_phase63_sclera_provider_boundaries.py` — eight-threat mutation/live checker.

## Decisions Made

- Result ordering is deterministic left then right even when support-array order differs.
- Actual same-eye pupil support is mandatory; no mirrored, inferred or cached substitute is test-authorized.
- Private positive/negative bounds are fixed before the implementation is run on genuine media.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

The focused XCTest build is intentionally RED on missing Phase 63 provider,
Testing observation and eye-support fixture seams. Existing source/test syntax
compiled far enough to isolate those expected missing interfaces.

## User Setup Required

None - the authorized ignored fixture bundle is already available through the
existing private runner.

## Next Phase Readiness

Ready for 63-02 provider and transform implementation. No safety or intake
blocker is open; renderer, Demo and promotion remain deferred.

## Self-Check: PASSED

- Four required files exist.
- Both task commits are present.
- Checker self-test passes 8/8 mutations.
- Private paths/media are absent from tracked contracts.

