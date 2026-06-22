---
phase: 06-core-beauty-effects
plan: 06-01
subsystem: effects
tags: [beauty-effects, safety-caps, color-pipeline, presets, filters]
requires:
  - phase: 05-filters-presets-and-resource-flow
    provides: Metadata filter IDs and built-in preset parameter bundles.
provides:
  - BeautyEffects planning model with safety caps and resolver metadata.
  - Deterministic BGRA and CI skin, color, filter, and preset output path.
  - Public BeautyEngine facade routing through validated filter IDs and effect plans.
affects: [core-beauty-effects, face-shape-providers, eye-nose-providers, mouth-lip-effects, rich-demo-qa-surface]
tech-stack:
  added: []
  patterns: [pure effect resolver, deterministic fixture color pipeline, facade-owned engine routing]
key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectDomain.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
    - BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift
    - BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift
    - BeautySDK/Sources/BeautySDK/BeautyEngine.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift
  modified:
    - BeautySDK/Package.swift
    - BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift
key-decisions:
  - "The concrete BeautyEngine implementation now lives in the BeautySDK facade target so it can depend on BeautyEffects and BeautyResources without introducing a BeautyCore dependency cycle."
  - "Phase 6 starts with deterministic CPU/Core Image color transforms rather than LUT assets or GPU-only rendering."
patterns-established:
  - "Algorithm safety caps live in BeautyEffects and do not narrow public BeautyParameters ranges."
  - "BeautyResult warnings and metrics carry cap and effect evidence using redacted stable keys."
requirements-completed: ["EFFECT-01"]
duration: 25 min
completed: 2026-06-22
---

# Phase 06: Plan 06-01 Summary

**Safety-capped BeautyEffects resolver with visible BGRA and CI skin, color, filter, and preset output through the public BeautyEngine.**

## Performance

- **Duration:** 25 min
- **Started:** 2026-06-22T00:56:00Z
- **Completed:** 2026-06-22T01:21:11Z
- **Tasks:** 2
- **Files modified:** 13

## Accomplishments

- Added `BeautyEffectsTests` plus focused resolver and safety-cap coverage for Phase 6 effect strengths.
- Implemented `BeautyEffectResolver`, `BeautySafetyCaps`, `BeautyEffectPlan`, and active-domain metadata for skin, color, filter, and later geometry domains.
- Routed public `BeautyEngine` pixel-buffer and image processing through a deterministic visible color/effect pipeline while preserving default no-op behavior.
- Validated built-in metadata filters and at least one built-in preset as visible output without adding `.cube`, thumbnail, or swatch assets.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add effect planning foundation and safety caps** - `8e538e7` (feat)
2. **Task 2: Route engine through visible skin, color, and filter output** - `df0876a` (feat)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectDomain.swift` - Internal effect-domain model used by resolver and render routing.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift` - Resolved active domains, warnings, metrics, and effective strengths.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Pure parameter-to-plan resolver with safety-cap warnings.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` - Single source for Phase 6 naturalness cap constants.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` - Deterministic BGRA and CI non-geometry effect pipeline.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Public engine implementation now owned by the facade target for cross-module routing.
- `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` - Exact cap-constant regression tests.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` - Resolver active-domain, cap, warning, and redaction tests.
- `BeautySDK/Package.swift` - Added `BeautyEffectsTests` test target.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` - Replaced color/filter no-op assertions with Phase 6 visible-output coverage.

## Requirements Addressed

- `EFFECT-01` is complete for skin smoothing, whitening, rosy tone, and sharpen output.
- `EFFECT-09` is partially addressed for default no-op behavior, conservative visible presets, and high-intensity safety caps. It remains globally pending until Plan 06-05 completes face-dependent degradation behavior.

## Decisions Made

- Moved the concrete public `BeautyEngine` implementation from `BeautyCore` into the `BeautySDK` facade target. `BeautyCore` cannot import `BeautyEffects` or `BeautyResources` without reversing the package dependency direction, while the facade can compose those internal modules without changing the public API.
- Kept first visible effects deterministic and CPU/Core Image based. This gives fixture-verifiable output now and leaves GPU quality work out of the Phase 6 MVP scope.

## Deviations from Plan

### Auto-fixed Issues

**1. Module boundary correction for `BeautyEngine`**
- **Found during:** Task 2 (Route engine through visible skin, color, and filter output)
- **Issue:** The plan listed `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`, but routing through `BeautyEffects` and `BeautyResources` from `BeautyCore` would create a dependency cycle.
- **Fix:** Kept the public `BeautyEngine` API unchanged and moved the concrete implementation to `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.
- **Files modified:** `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift`
- **Verification:** `CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` passed with 79 XCTest cases.
- **Committed in:** `df0876a`

---

**Total deviations:** 1 auto-fixed dependency-boundary correction.
**Impact on plan:** Public behavior and Phase 6 output goals are preserved; ownership now matches the package dependency graph.

## Issues Encountered

- RED engine tests initially failed because Phase 5 behavior intentionally copied non-zero color/filter parameters as no-ops.
- RED resolver tests initially failed because `BeautySafetyCaps` and `BeautyEffectResolver` did not exist yet.
- A test expression ambiguity was resolved during Task 2 while keeping the intended visible-output assertion.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 06-02 can reuse `BeautySafetyCaps`, `BeautyEffectResolver`, `BeautyEffectPlan`, and the engine/pipeline routing hooks for face-shape geometry providers. The full SDK SwiftPM suite passed after this plan.

---
*Phase: 06-core-beauty-effects*
*Completed: 2026-06-22*
