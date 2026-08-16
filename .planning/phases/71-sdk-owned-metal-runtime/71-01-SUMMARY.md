---
phase: 71-sdk-owned-metal-runtime
plan: "01"
subsystem: metal-runtime
tags: [swiftpm, metal, resource-lifecycle, bounded-runtime, privacy]

# Dependency graph
requires:
  - phase: 70-backend-neutral-contract-and-cpu-reference
    provides: package-only backend boundary and CPU reference ownership
provides:
  - package-only BeautyMetalRuntime with device, queue, library, function, and pipeline ownership
  - bounded private-texture identity transaction with synchronized completion and cleanup
  - typed unavailable, creation, validation, encoder, and terminal command failure seams
  - aggregate resource counters proving request-local cleanup and recovery
affects: [71-02, 71-03, 71-04, 72-metal-feature-passes, 73-public-backend-configuration]

# Tech tracking
tech-stack:
  added: []
  patterns: [request-local Metal transaction, private texture plus shared staging/readback, injected package-only provider seams]

key-files:
  created:
    - BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift
    - BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift
  modified: []

key-decisions:
  - "Keep device, queue, and compiled pipeline owned by each runtime instance; never introduce a global cache or host lifecycle dependency."
  - "Use private RGBA8 textures with request-local shared staging/readback buffers, allowing SwiftPM's bundled raw Warp.metal resource to compile at runtime when no default metallib is present."
  - "Expose only package-level dependency closures and aggregate lifecycle counters; no public backend selector, CPU fallback, retry, or durable raster diagnostics."

patterns-established:
  - "Validate dimensions, checked RGBA8 arithmetic, pixel ceilings, and dispatch-grid bounds before any request allocation."
  - "Every tracked texture, buffer, command buffer, encoder, and temporary raster allocation is released through scope cleanup on success and throw paths."

requirements-completed: [METAL-01]

# Metrics
duration: ~35min
completed: 2026-08-16
status: complete
---

# Phase 71 Plan 01: SDK-Owned Metal Runtime Summary

**Bounded package-only Metal identity transactions with typed fail-closed seams, private textures, synchronized completion, and zero retained request resources.**

## Performance

- **Duration:** ~35 min
- **Started:** 2026-08-16T03:30:00Z
- **Completed:** 2026-08-16T04:05:13Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Added `BeautyMetalRuntime` to the existing `BeautyRender` target. It owns one device, command queue, bundled `beauty_warp_placeholder` pipeline, private RGBA8 input/output textures, request-local shared upload/readback buffers, command synchronization, and aggregate cleanup counters.
- Added preallocation validation for positive dimensions, checked RGBA8 row/byte arithmetic, configured pixel ceilings, aligned staging rows, and bounded finite dispatch grids. Invalid work fails with `.invalidInput` before request resources are created.
- Added package-only dependency closures for device, queue, library, function, pipeline, command buffer, compute encoder, texture, completion, and status seams. Failures are typed/redacted (`.metalUnavailable`, `.commandQueueCreationFailed`, `.textureCreationFailed`, `.shaderFunctionNotFound`, or stable `.renderFailed` reasons) with no CPU success fallback.
- Added six focused XCTest cases covering unavailable host behavior, initialization/resource/encoder/command failures, malformed input, real available-host byte-for-byte identity output, repeated requests, failed-then-valid recovery, and exact `created == released` / `active == 0` counters. The combined runtime and legacy render suite is 9/0/0.

## Task Commits

Each task was committed atomically:

1. **Task 1: Implement the bounded SDK-owned Metal transaction** - `b29b673` (feat)
2. **Task 2: Prove availability, malformed-input, and cleanup behavior** - `c6bc903` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift` - package-only Metal setup, bounded request transaction, typed failures, and lifecycle counters.
- `BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift` - generated in-memory lifecycle, availability, failure, recovery, and identity-copy coverage.

## Decisions Made

- Keep the runtime independent of application/UI lifecycle and keep all long-lived Metal objects scoped to one runtime instance.
- Compile `Bundle.module`'s existing raw `Warp.metal` source when SwiftPM does not provide a precompiled default library; this preserves the existing shader and adds no shader source or algorithm.
- Use aggregate-only counters and typed stable error reasons; no Metal object descriptions, framework error text, pixels, paths, or host/device matrix are published.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Supported SwiftPM's raw shader resource on the available host**
- **Found during:** Task 1
- **Issue:** SwiftPM packages the existing `Warp.metal` as a raw resource, so `makeDefaultLibrary(bundle:)` returned no library and prevented the required available-host transaction.
- **Fix:** Kept the default-library attempt, then loaded only `Bundle.module`'s existing `Warp.metal` and compiled it through Metal's source-library API.
- **Files modified:** `BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift`
- **Verification:** Available-host identity transaction passes; build and source scope scan pass.
- **Committed in:** `b29b673`

**2. [Rule 2 - Missing Critical] Completed lifecycle accounting for every tracked request object**
- **Found during:** Task 1
- **Issue:** Initial cleanup scope released references but did not decrement counters for buffers, textures, command buffers, or encoders on all exits.
- **Fix:** Added unconditional counter-release defers paired with every tracked request allocation, including encoder-end cleanup.
- **Files modified:** `BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift`
- **Verification:** Success, terminal failure, malformed, repeated, and recovery tests all prove `active == 0` and `created == released`.
- **Committed in:** `b29b673`

**3. [Rule 1 - Bug] Corrected malformed-input test fixture classification**
- **Found during:** Task 2
- **Issue:** One intended malformed row used an exact valid 2×2 RGBA8 byte count and did not throw.
- **Fix:** Changed that generated in-memory fixture to a one-byte-overlong carrier.
- **Files modified:** `BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift`
- **Verification:** Focused runtime suite passes 6/0/0 and malformed work leaves counters unchanged.
- **Committed in:** `c6bc903`

---

**Total deviations:** 3 auto-fixed (1 Rule 1, 1 Rule 2, 1 Rule 3)
**Impact on plan:** All fixes were directly required for the bounded runtime's available-host behavior, cleanup correctness, or deterministic test coverage. No public API, dependency, algorithm, UI/Demo, or device scope was added.

## Issues Encountered

- `gsd-tools` was not installed on PATH; the documented Node CLI at `/Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs` was used for initialization/state inspection, with direct metadata edits reserved for the final closeout where needed.
- The normal full SwiftPM suite passes 719 tests with 0 failures and 8 pre-existing environment-gated skips. Focused runtime/legacy render coverage passes 9 tests with 0 failures and 0 skips.

## User Setup Required

None - no external service configuration or package installation required.

## Next Phase Readiness

Phase 71 Plan 02 can consume this package-only runtime behind the existing backend-neutral boundary. The runtime is intentionally an identity-copy resource/synchronization probe only; public backend configuration, feature passes, parity, device evidence, performance, packaging, shipping, and release claims remain out of scope.

## Known Stubs

None. The retained `beauty_warp_placeholder` identity kernel is an intentional resource/lifecycle probe specified by the plan, not a user-visible output stub.

## Self-Check: PASSED

- Both created source/test files exist.
- Task commits `b29b673` and `c6bc903` are present in Git history.
- `swift build --package-path BeautySDK` passes.
- `swift test --package-path BeautySDK --filter 'BeautyRenderTests.BeautyMetalRuntimeTests'` passes 6/0/0.
- `swift test --package-path BeautySDK --filter 'BeautyRenderTests.CopyRenderPassTests|BeautyRenderTests.BeautyMetalRuntimeTests'` passes 9/0/0.
- `swift test --package-path BeautySDK` passes 719/0/8.
- Runtime scope/privacy scans and `git diff --check` pass.

---
*Phase: 71-sdk-owned-metal-runtime*
*Completed: 2026-08-16*
