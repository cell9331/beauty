---
phase: 71-sdk-owned-metal-runtime
plan: "02"
subsystem: metal-backend
tags: [swiftpm, metal, backend-contract, resource-lifecycle, privacy]

# Dependency graph
requires:
  - phase: 70-backend-neutral-contract-and-cpu-reference
    provides: package-only request/result boundary and retained CPU reference executor
  - phase: 71-sdk-owned-metal-runtime
    provides: bounded BeautyMetalRuntime resource transaction and typed failure seams
provides:
  - package-only `.metal` execution policy through the shared backend boundary
  - stateless BeautyMetalBackend identity executor for BGRA pixel buffers and still images
  - exact invocation/error hooks and aggregate-only backend lifecycle coverage
affects: [71-03, 71-04, 72-metal-feature-passes, 73-public-backend-configuration]

# Tech tracking
tech-stack:
  added: []
  patterns: [request-local RGBA8 bridge, explicit-sRGB still-image conversion, terminal typed errors]

key-files:
  created:
    - BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift
    - BeautySDK/Tests/BeautyEffectsTests/BeautyMetalBackendTests.swift
  modified:
    - BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift

key-decisions:
  - "Keep `.metal` package-only; public configuration, parameter storage, preset keys, and CLI selection remain unchanged for Phase 73."
  - "Use one runtime invocation per request with named ExecutionHooks, and publish no result after any typed terminal error."
  - "Reuse canonical still-image bytes when supplied; otherwise rasterize one bounded request-local image into explicit-sRGB RGBA8 and restore its original extent."

patterns-established:
  - "Pixel-buffer requests copy packed BGRA rows into a transient carrier, execute once, and copy into a distinct SDK-owned output buffer."
  - "Backend results carry only matching output kind, dimensions, alpha/extent flags, and bounded composition aggregates."

requirements-completed: [METAL-01]

# Metrics
duration: ~2h25m
completed: 2026-08-16
status: complete
---

# Phase 71 Plan 02: SDK-Owned Metal Runtime Summary

**Package-only Metal execution now crosses the Phase-70 request/result boundary through one bounded identity transaction with explicit-sRGB conversion, typed terminal failures, and no CPU path.**

## Performance

- **Duration:** ~2h25m
- **Started:** 2026-08-16T04:07:11Z
- **Completed:** 2026-08-16T06:31:10Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Extended `BeautyBackendExecutionPolicy` with internal `.metal` admission while preserving the public backend/configuration and 61-field/five-preset schemas.
- Implemented `BeautyMetalBackend` as a stateless bridge over one `BeautyMetalRuntime` transaction per request for BGRA pixel buffers and bounded still images, including canonical-byte reuse, explicit sRGB RGBA8 conversion, distinct output materialization, matching diagnostics, and original-extent restoration.
- Added named `BeautyMetalBackend.ExecutionHooks` plus generated tests for output-kind pairing, unavailable hosts, malformed input, command/texture terminal errors, exact one-invocation behavior, failed-then-valid recovery, mixed CPU/Metal isolation, and zero active Metal resources.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add the internal Metal policy and executor** - `30ba107` (feat)
2. **Task 2: Exercise shared-boundary output, failure, and isolation contracts** - `d379363` (test)

## Files Created/Modified

- `BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift` - admits package-only `.metal` requests and exposes shared checked extent validation to the executor.
- `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift` - owns the request-local bridge and result publication around `BeautyMetalRuntime`.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalBackendTests.swift` - generated in-memory shared-boundary, failure, hook, recovery, and privacy tests.

## Decisions Made

- Keep public backend selection deferred to Phase 73; `.metal` is not persisted in parameters/presets and does not enter the CLI.
- Keep conversion and resource ownership request-local, with aggregate-only hooks/results and terminal typed errors.
- Preserve the CPU executor as an independent reference; the Metal executor contains no CPU dispatch path.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Shared the contract’s checked extent validation with the executor**
- **Found during:** Task 1 (Add the internal Metal policy and executor)
- **Issue:** The existing `checkedDimensions(for:)` helper was file-private, preventing the executor from reusing the contract’s exact extent validation.
- **Fix:** Raised the helper to package visibility without changing its behavior or public surface.
- **Files modified:** `BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift`
- **Verification:** Package build and focused backend tests pass.
- **Committed in:** `30ba107`

**2. [Rule 3 - Blocking] Updated the Core Graphics data-provider bridge for the current Swift SDK**
- **Found during:** Task 1 (Add the internal Metal policy and executor)
- **Issue:** `CGDataProviderCopyData` is obsolete in the available SDK and prevented compilation of still-image raster conversion.
- **Fix:** Used the provider’s current `.data` property while retaining checked row copying and explicit conversion errors.
- **Files modified:** `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift`
- **Verification:** Package build and non-canonical still-image identity test pass.
- **Committed in:** `30ba107`

---

**Total deviations:** 2 auto-fixed (Rule 3: 2)
**Impact on plan:** Both fixes were directly required to compile and reuse existing validation; no public API, dependency, algorithm, UI/Demo, or device scope was added.

## Issues Encountered

- The first filtered test invocation crashed in a stale incremental test binary while loading the newly added package enum. A clean SwiftPM build removed the stale artifact; the focused suite then passed 24/0/0 and the full package suite passed 728/0/8.
- The full package suite includes eight pre-existing environment-gated Vision skips; the new focused backend suite has 9/0/0 with no skips.

## User Setup Required

None - no external service configuration or package installation required.

## Next Phase Readiness

Plan 71-03 can consume the package-only Metal executor and its shared result validation for feature passes. Public `.cpu`/`.gpu` configuration and availability policy remain reserved for Phase 73; generated CPU/GPU parity and closeout remain reserved for Phase 74.

## Known Stubs

None in the files created or modified by this plan. The underlying `beauty_warp_placeholder` shader remains the intentional identity resource probe owned by Plan 71-01; feature algorithms remain deferred to Plan 71-03/Phase 72.

## Self-Check: PASSED

- Created source and test files exist.
- Task commits `30ba107` and `d379363` are present in Git history.
- `swift build --package-path BeautySDK` passes.
- Focused backend/CPU/runtime tests pass 24/0/0.
- Full `swift test --package-path BeautySDK` passes 728/0/8.
- Public-surface/privacy scans and `git diff --check` pass.

---
*Phase: 71-sdk-owned-metal-runtime*
*Completed: 2026-08-16*
