---
phase: 72-metal-feature-passes
plan: "04"
subsystem: metal-rendering
tags: [swiftpm, metal, cpu-reference, color-parity, generated-tests]

# Dependency graph
requires:
  - phase: 72-metal-feature-passes
    provides: bounded Metal color pass, CPU reference backend, and feature preflight
provides:
  - combined saturation and skin-smoothing CPU/Metal coefficient parity
  - generated in-memory combined color regression and updated feature-gate accounting
  - synchronized four-plan Phase 72 roadmap ledger
affects: [73-public-backend-configuration, 74-parity-closeout, metal-rendering, sdk-only-validation]

# Tech tracking
tech-stack:
  added: []
  patterns: [exact retained CPU coefficient mapping, generated aggregate-only parity regression]

key-files:
  created:
    - .planning/phases/72-metal-feature-passes/72-04-GAP-01-SUMMARY.md
  modified:
    - BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift
    - scripts/check-metal-feature-passes.sh
    - .planning/ROADMAP.md

key-decisions:
  - "Keep the CPU still-image coefficient authoritative and align the CPU pixel-buffer reference with it before comparing combined CPU/Metal output."
  - "Use generated in-memory fixtures with bounded max/mean RGB deltas and aggregate-only diagnostics; persist no pixels, masks, landmarks, or locators."

patterns-established:
  - "Combined color plans must exercise saturation and skin smoothing together; independent-row tests are insufficient for coefficient parity."
  - "Phase progress rows advance only after focused/live feature preflight and SDK-only boundary checks pass."

requirements-completed: [METAL-02]

# Metrics
duration: ~10min
completed: 2026-08-17
---

# Phase 72 Plan 04: Combined Metal Color Parity Summary

**Restored the retained CPU saturation coefficient for combined saturation and skin smoothing, added a generated CPU-vs-Metal regression, and closed the Phase 72 roadmap gap.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-08-17T09:05:00Z (approximate)
- **Completed:** 2026-08-17T09:13:00Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Metal `saturationDelta` now includes `-strengths.skinSmoothing * 0.18`, matching the retained CPU equation while preserving the separate smoothing uniform and shader contract.
- The CPU pixel-buffer reference now mirrors the same retained coefficient as the still-image path, preventing the two CPU reference paths from disagreeing on combined plans.
- Added a generated `(0.8, 0.8)` saturation/skin-smoothing matrix regression with alpha, bounded max-channel (`<= 8`) and mean-RGB (`< 5.0`) assertions; the feature gate now expects 32 focused tests and requires the named marker.
- Removed the scoped backend `withUnsafeMutableBytes` unused-result warning and marked Phase 72 as `4/4 Complete` on 2026-08-17.

## Verification

- `swift build --package-path BeautySDK` — passed.
- Focused Metal/backend/CPU suites — 19 executed, 0 failures, 0 skips.
- `bash scripts/check-metal-feature-passes.sh --self-test` — passed.
- `bash scripts/check-metal-feature-passes.sh` — passed with `focused_tests=32`, `metal_available=1`, `metal_unavailable=0`, `failures=0`, `skips=0`.
- Backend warning scan and `git diff --check` — passed.
- `bash scripts/check-sdk-only-boundary.sh --post-archive` — passed.
- `bash scripts/run-no-skip-swiftpm.sh --self-test` — passed.

## Task Commits

Each task was committed atomically:

1. **Task 1: Restore the combined CPU coefficient and prove G-01** — `92b68cd` (fix)
2. **Task 2: Finalize the Phase 72 progress ledger after gap closure** — `8731807` (docs)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift` - Restored the full combined saturation coefficient and explicitly discarded the rasterization copy closure result.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` - Aligned the CPU pixel reference with the retained still-image coefficient.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift` - Added generated combined CPU/Metal output coverage and bounded max-channel diagnostics.
- `scripts/check-metal-feature-passes.sh` - Increased focused accounting to 32 and enforces the combined regression marker.
- `.planning/ROADMAP.md` - Lists the gap-closure plan and records Phase 72 as complete.

## Decisions Made

- CPU remains the reference; the gap fix makes both existing CPU execution paths use the same retained saturation equation before validating Metal.
- The regression stays package-only and generated; no public backend selector, shader inventory, parameter, UI/Demo, device, performance, or release scope was added.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Aligned the CPU pixel-buffer reference with the retained still-image saturation equation**
- **Found during:** Task 1 (Restore the combined CPU coefficient and prove G-01)
- **Issue:** After correcting Metal, the CPU pixel-buffer path still omitted `-skinSmoothing * 0.18`, causing the new combined regression and existing smoothing row to fail despite the authoritative still-image path containing the term.
- **Fix:** Added the same bounded term to `BeautyColorEffectPipeline`'s CPU byte transform; this keeps the two retained CPU reference paths consistent and makes the CPU-vs-Metal regression meaningful.
- **Files modified:** `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`
- **Verification:** Focused suites and the 32-test Metal feature preflight pass with zero failures/skips.
- **Committed in:** `92b68cd`

**Total deviations:** 1 auto-fixed (Rule 1 - Bug)
**Impact on plan:** Required for correctness of the existing CPU reference boundary; no public API or scope expansion.

## Issues Encountered

- The first regression attempt exposed a pre-existing CPU-path coefficient drift; it was fixed inline as documented above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 72 is ready for independent re-verification. Phase 73 can proceed with public `.cpu`/`.gpu` configuration and typed fail-closed Metal availability; parity and SDK-only closeout remain Phase 74 work.

---
*Phase: 72-metal-feature-passes*
*Completed: 2026-08-17*

## Self-Check: PASSED

- Summary file exists.
- Task commits `92b68cd` and `8731807` exist in git history.
- Stub scan found only the intentionally retained `beauty_warp_placeholder` kernel marker and a temporary shell variable; no new implementation stubs were introduced.
