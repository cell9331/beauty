---
phase: 72-metal-feature-passes
plan: "01"
subsystem: metal-rendering
tags: [swiftpm, metal, color-pass, rgba8, bounded-runtime, mutation-gate]

# Dependency graph
requires:
  - phase: 71-sdk-owned-metal-runtime
    provides: package-owned bounded Metal resources, synchronization, cleanup, and typed terminal errors
provides:
  - package-only finite Metal color, geometry, and composed-retouch pass carriers
  - ordered ping-pong Metal pass execution with RGBA8 staging and deterministic cleanup
  - CPU-coefficient color/skin mapping with BGRA/RGBA conversion and named-sRGB still-image output
  - generated color-direction/locality/metadata coverage and mutation-tested feature-pass preflight
affects: [72-02-geometry-pass, 72-03-local-retouch-pass, 73-public-backend-configuration, 74-parity-closeout]

# Tech tracking
tech-stack:
  added: []
  patterns: [package-only primitive pass payloads, ordered private-texture ping-pong, generated semantic color oracle, aggregate-only mutation preflight]

key-files:
  created:
    - BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift
    - scripts/check-metal-feature-passes.sh
  modified:
    - BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift
    - BeautySDK/Sources/BeautyRender/Shaders/Warp.metal
    - BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift
    - BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift
    - scripts/check-metal-runtime.sh

key-decisions:
  - "Keep the existing no-pass runtime overload as the identity probe while the backend supplies ordered package-only color/geometry/retouch passes."
  - "Map the retained CPU direct RGBA8 color equations into finite Metal uniforms; keep support discovery and composition ownership outside the runtime."
  - "Convert BGRA pixel-buffer bytes at the backend boundary, preserve alpha exactly, and materialize still-image output with named sRGB metadata."
  - "Keep geometry and composed-retouch kernels identity-safe until their owning Phase-72 plans supply semantics; this plan closes only METAL-02."

patterns-established:
  - "Pass payloads contain only finite bounded scalar/control data; observations, masks, pixels, framework objects, and diagnostics never cross the runtime boundary."
  - "Every pass transaction uses private request-local textures, one synchronized command buffer, bounded dispatch, and paired resource counters."

requirements-completed: [METAL-02]

# Metrics
duration: ~25min
completed: 2026-08-16
status: complete
---

# Phase 72 Plan 01: Metal Feature Passes Summary

**Bounded Metal pass graph and CPU-semantic color/skin rendering with exact alpha, locality, BGRA bridging, and named-sRGB output.**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-08-16T09:08:00Z
- **Completed:** 2026-08-16T09:33:00Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- Added finite package-only `BeautyMetalPass` carriers for color uniforms, bounded warp points, and composed-retouch copy operations; no public backend/configuration or diagnostic surface changed.
- Extended the SDK-owned runtime to resolve the retained identity kernel plus color/geometry/local-retouch kernels, encode an ordered ping-pong graph, and retain checked dimensions, bounded dispatch, synchronized completion, and cleanup counters on success and terminal errors.
- Mapped existing CPU color coefficients and filter identities into a real Metal color kernel; pixel-buffer requests convert BGRA↔RGBA, alpha remains exact, still images retain extent and named sRGB metadata, and unsupported/no-op local lip plans remain byte-identical.
- Added generated global color/skin/filter and face-local lip coverage against CPU directional metrics, bounded deltas, alpha/locality/repetition checks, and explicit unavailable-host classification.
- Added `check-metal-feature-passes.sh` with regular-file/target ownership, shader inventory, schema/manifest invariants, privacy/dependency scans, cleanup/alternate/public/raw-diagnostic mutations, and aggregate-only focused accounting.

## Verification

- `swift build --package-path BeautySDK` — pass.
- Focused color + CPU oracle + Metal backend/runtime suites — **27 executed, 0 failures, 0 skipped**.
- Feature-pass preflight — **22 focused, 0 failures, 0 skips**; self-test and live mode pass with `metal_available=1`, `metal_unavailable=0`.
- Existing Phase-71 runtime preflight — **29 focused, 0 failures, 0 skips** after the three additional runtime graph tests; self-test and live mode pass.
- Full `swift test --package-path BeautySDK` — **735 executed, 0 failures, 8 documented environment-gated skips**.
- Requested privacy/debug scan and `git diff --check` — pass.

## Task Commits

Each implementation task was committed atomically:

1. **Task 1: Define the bounded Metal pass graph and color execution path** — `958853f` (feat)
2. **Task 2: Prove Metal color direction, bounds, locality, and metadata** — `2e162c1` (test)

**Plan metadata:** pending final planning commit.

## Files Created/Modified

- `BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift` — finite package-only pass and uniform carriers.
- `BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift` — ordered pass encoding, private texture ping-pong, bounded dispatch, and cleanup.
- `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` — retained identity plus color, geometry, and local-retouch kernels.
- `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift` — CPU-plan mapping, BGRA/RGBA bridge, and named-sRGB output.
- `BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift` — graph success/failure/repetition and resource lifecycle tests.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift` — generated color semantic and metadata tests.
- `scripts/check-metal-runtime.sh` — synchronized runtime focused count.
- `scripts/check-metal-feature-passes.sh` — feature-pass static/mutation gate.

## Decisions Made

- Preserve the existing direct runtime identity overload so Phase-71 runtime mechanics remain independently testable while all backend feature execution uses the ordered pass API.
- Keep the pass graph package-internal and primitive-only; public `.cpu`/`.gpu` selection remains Phase 73 work.
- Treat Metal availability as an aggregate classification, never as feature success or CPU fallback evidence.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Synchronized the Phase-71 focused accounting after adding graph tests**
- **Found during:** Task 1
- **Issue:** The existing runtime gate expected 26 tests, but the planned graph setup/repetition coverage increased the focused suite to 29.
- **Fix:** Updated the gate’s expected focused count while retaining zero-failure/zero-skip accounting.
- **Files modified:** `scripts/check-metal-runtime.sh`
- **Verification:** Runtime self-test/live preflight pass with 29/0/0.
- **Committed in:** `958853f`

**2. [Rule 1 - Bug] Made the feature gate’s privacy scanner self-safe**
- **Found during:** Task 2
- **Issue:** The requested scanner terms matched the gate’s own source and the legitimate aggregate `changedPixelCount` field.
- **Fix:** Built forbidden terms from safe fragments, narrowed diagnostics scanning to sensitive field families, and replaced direct print-based availability output.
- **Files modified:** `scripts/check-metal-feature-passes.sh`
- **Verification:** Feature self-test/live preflight and the exact requested privacy scan pass.
- **Committed in:** `2e162c1`

---

**Total deviations:** 2 auto-fixed (Rule 1: 2)
**Impact on plan:** Both fixes preserve the declared mutation/privacy and focused-accounting contracts; no architectural or product scope expansion occurred.

## Known Stubs

- `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` — `beauty_geometry_pass` and `beauty_local_retouch_pass` are bounded identity kernels. Their payload contracts and runtime encoders are intentionally established for Plans 72-02 and 72-03; this plan’s completed requirement is METAL-02 color/skin behavior.

## Issues Encountered

- No package installation, external service, or manual setup was required.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Plan 72-02 can consume the bounded warp-point payload and geometry kernel without changing the public schema or runtime ownership. Plan 72-03 can consume the composed-retouch payload while retaining request-local composition ownership. Public backend configuration and CPU/GPU parity remain explicitly assigned to Phases 73 and 74.

---
*Phase: 72-metal-feature-passes*
*Completed: 2026-08-16*

## Self-Check: PASSED

- Summary, pass carrier, generated color suite, and feature-pass gate exist.
- Task commits `958853f` and `2e162c1` are present in Git history.
- Build, focused 27/0/0 suite, full 735/0/8 suite, both Metal preflights, mutation self-tests, privacy scan, and diff hygiene pass.
- The only identity kernels are explicitly documented as later-plan pass contracts; METAL-02 color behavior is fully wired and verified.
