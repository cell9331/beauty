---
phase: 72-metal-feature-passes
plan: "02"
subsystem: metal-rendering
tags: [swiftpm, metal, geometry-pass, warp, cpu-reference, safety]

# Dependency graph
requires:
  - phase: 72-metal-feature-passes
    provides: bounded Metal pass carriers, ordered runtime graph, and sRGB/BGRA bridges from Plan 72-01
provides:
  - unified CPU geometry control-point serialization into the bounded Metal warp pass
  - top-left inverse-displacement geometry sampling with finite validation, locality, alpha, and extent preservation
  - generated 44-row geometry inventory coverage and geometry-focused mutation/static preflight
affects: [72-03-local-retouch-pass, 73-public-backend-configuration, 74-parity-closeout]

# Tech tracking
tech-stack:
  added: []
  patterns: [provider-owned control-point serialization, request-local bounded warp payloads, inverse displacement with clamped bilinear sampling]

key-files:
  created:
    - BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift
    - BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift
    - BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift
    - BeautySDK/Sources/BeautyRender/Shaders/Warp.metal
    - scripts/check-metal-feature-passes.sh

key-decisions:
  - "Keep BeautyGeometryEffectPipeline.controlPoints as the sole geometry source; the Metal adapter performs no support discovery, conflict resolution, or collision ownership."
  - "Preserve CPU pass order by appending geometry after color and omit malformed or absent geometry locally while face-agnostic siblings continue."
  - "Use explicit finite point/count validation and shader-side clamping/manual bilinear sampling to preserve alpha, extent, and locality without a second warp algorithm."

patterns-established:
  - "Metal geometry payloads contain only bounded primitive point data; observations and canonical bytes remain request-local outside the runtime."
  - "Availability is classified separately from geometry evidence; generated tests use in-memory fixtures and never persist raw support or pixels."

requirements-completed: [METAL-03]

# Metrics
duration: 15min
completed: 2026-08-16
status: complete
---

# Phase 72 Plan 02: Metal Geometry Pass Summary

**Existing unified geometry control points now execute through a bounded Metal warp with CPU-compatible direction, locality, alpha, extent, degradation, and request-isolation coverage.**

## Performance

- **Duration:** 15 min
- **Started:** 2026-08-16T09:38:18Z
- **Completed:** 2026-08-16T09:53:08Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Adapted the selected face once, routed points exclusively through `BeautyGeometryEffectPipeline.controlPoints`, rejected non-finite/out-of-unit/zero-radius/over-capacity payloads, and preserved color-before-geometry ordering.
- Implemented the bounded Metal geometry kernel with top-left normalized coordinates, inverse displacement, radius/falloff weighting, clamped sampling, and exact source alpha for unaffected pixels.
- Added generated 44-row inventory, locality/alpha/extent/no-face/recovery/composition ownership coverage and synchronized the mutation-tested feature-pass gate to 26 focused tests.

## Verification

- `swift build --package-path BeautySDK` — pass.
- Focused geometry/color/backend/CPU-oracle suites — **22 executed, 0 failures, 0 skipped** (the command includes the five CPU-oracle tests; feature gate adds the nine runtime tests for its **26 focused** total).
- `bash scripts/check-metal-feature-passes.sh --self-test` — pass.
- `bash scripts/check-metal-feature-passes.sh` — pass with `metal_available=1`, `metal_unavailable=0`, `focused_tests=26`, `failures=0`, `skips=0`.
- Requested geometry privacy scan and `git diff --check` — pass.

## Task Commits

Each implementation task was committed atomically:

1. **Task 1: Serialize existing control points into the Metal geometry pass** — `b99067b` (feat)
2. **Task 2: Prove geometry direction, cap, locality, and recovery** — `df1ac88` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift` — selected-face adaptation, unified point serialization, finite bounds, and ordered geometry dispatch.
- `BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift` — finite falloff range compatible with retained CPU provider values.
- `BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift` — bounded geometry point/count uniform encoding.
- `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` — inverse-displacement geometry kernel and manual clamped bilinear sampler.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift` — generated inventory and safety/recovery tests.
- `scripts/check-metal-feature-passes.sh` — geometry target/privacy/shader/static markers and focused accounting.

## Decisions Made

- Geometry remains package-internal and consumes the existing resolver/provider output; no public backend selector, parameter, preset, semantic-mask API, or alternate CPU path was added.
- Collision-to-source and composition diagnostics remain input-owned; the geometry pass does not synthesize collision or raw-support state.
- Host availability is reported separately from feature evidence; unavailable hosts are not treated as geometry success or parity.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Enabled the existing geometry payload instead of silently discarding it**
- **Found during:** Task 1 (Serialize existing control points into the Metal geometry pass)
- **Issue:** The Plan-72-01 carrier and runtime graph recognized geometry passes, but runtime encoding ignored their points and the shader was identity-only, so geometry requests could not execute.
- **Fix:** Added point/count uniform encoding, the CPU-compatible Metal geometry kernel, and backend pass construction while retaining runtime ownership and cleanup.
- **Files modified:** `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift`, `BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift`, `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal`
- **Verification:** Available-host geometry tests and feature preflight pass.
- **Committed in:** `b99067b`

**2. [Rule 1 - Bug] Accepted retained provider falloff values in the bounded carrier**
- **Found during:** Task 1 (Serialize existing control points into the Metal geometry pass)
- **Issue:** `BeautyMetalWarpPoint` rejected falloff values above `1`, while every shipped provider emits falloff `2`; this made valid unified points fail before dispatch.
- **Fix:** Bounded carrier falloff to `0...3`; backend provider serialization remains stricter (`1...3`) and the shader preserves CPU's `max(1, falloff)` behavior.
- **Files modified:** `BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift`
- **Verification:** Runtime pass graph, geometry suite, and feature preflight pass.
- **Committed in:** `b99067b`

---

**Total deviations:** 2 auto-fixed (Rule 1: 2)
**Impact on plan:** Both fixes were required to make the already-declared bounded geometry contract execute; no public or architectural scope expanded.

## Issues Encountered

- No package installation, external service, manual setup, or durable fixture artifact was required.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 72-03 can consume the same ordered runtime graph while retaining composition-owned source bytes and aggregate collision diagnostics. Phase 73 can add explicit public backend selection without changing this package-only geometry payload or public parameter schema. Device/performance/release claims remain outside scope.

---
*Phase: 72-metal-feature-passes*
*Completed: 2026-08-16*

## Self-Check: PASSED

- Summary and all six plan files exist; task commits `b99067b` and `df1ac88` are present.
- Build, focused suites, geometry feature preflight self/live modes, privacy scan, and diff hygiene pass.
- No tracked raw pixels, support, landmarks, masks, paths, or host/UI/network behavior was added.
