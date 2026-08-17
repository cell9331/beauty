---
phase: 71-sdk-owned-metal-runtime
verified: 2026-08-16T08:54:00Z
status: passed
score: 14/14 must-haves verified
overrides_applied: 0
---

# Phase 71: SDK-Owned Metal Runtime Verification Report

**Phase Goal:** The SDK can own and safely execute bounded Metal work without relying on an application lifecycle or leaking state across requests.
**Verified:** 2026-08-16T08:54:00Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Available requests create and use SDK-owned Metal device, queue, pipeline, textures, command synchronization, and request resources, then return through the shared boundary. | ✓ VERIFIED | `BeautyMetalRuntime` owns device/queue/pipeline; `render` creates private RGBA8 textures, staging buffers, blit/compute encoders, commits and waits; `BeautyMetalBackend` returns `BeautyBackendResult`. Focused Metal/backend tests pass 26/0/0. |
| 2 | Successful, failed, repeated, and mixed CPU/Metal requests release request resources and do not retain prior-request state. | ✓ VERIFIED | Runtime uses paired tracking/defer cleanup for staging buffers, textures, command buffer, encoders, and output bytes; tests cover success, command/texture/encoder failures, repetition, failed-then-valid recovery, and mixed CPU/Metal isolation, asserting `active == 0` and `created == released`. |
| 3 | Malformed or unsupported work is bounded and finite, with cleanup independent of host lifecycle. | ✓ VERIFIED | Checked positive dimensions, overflow-safe RGBA8 byte arithmetic, pixel ceiling, row alignment, Int32 dimensions, and finite thread grid run before request allocation; typed terminal errors and unconditional cleanup are source- and test-verified. |
| 4 | Unavailable Metal is explicit fail-closed state and never CPU success or parity evidence. | ✓ VERIFIED | `deviceProvider == nil` throws `.metalUnavailable`; backend unavailable test records zero runtime/terminal invocations. Preflight reports `metal_available=1` and `metal_unavailable=0` separately; no CPU path exists in the Metal executor. |
| 5 | Internal `.metal` requests use the same request/result contract without changing public configuration, parameters, presets, or CLI schema. | ✓ VERIFIED | `BeautyBackendExecutionPolicy.metal` is `package`; requests/results use the existing validated boundary. Static preflight confirms 61 public parameter fields, 10 configuration fields, five preset IDs, and 74 renderer cases; no public `renderBackend`/`BeautyRenderBackend` exists. |
| 6 | Both supported pixel-buffer and still-image inputs perform one bounded identity transaction and return matching output kind, dimensions, alpha, extent, and aggregate diagnostics. | ✓ VERIFIED | `BeautyMetalBackend.execute` has one runtime invocation per request; tests verify BGRA bytes, canonical and noncanonical still-image extent restoration, matching kinds, dimensions, alpha/extent flags, and bounded composition aggregates. |
| 7 | Metal unavailability, malformed input, resource/command failures, and output conversion failures are terminal typed outcomes with no fallback or retry. | ✓ VERIFIED | Runtime/backend catch typed `BeautyError`, invoke terminal hook once, and return no result after failure. Focused contract/backend tests pass; static mutation gate rejects alternate execution and fallback/retry branches. |
| 8 | The runtime/backend and tests remain package-owned and free of application/UI/capture lifecycle dependencies and raw durable diagnostics. | ✓ VERIFIED | Runtime is in `BeautyRender`, executor in `BeautyEffects`, only the existing `Warp.metal` is authorized, and the static preflight rejects target movement, host/UI/network imports, public declarations, and raw support/pixel/texture/framework diagnostic fields. |
| 9 | The SDK-owned Metal preflight proves source scope, bounds, cleanup, synchronization, schema, privacy, availability, and mutation fail-closed behavior. | ✓ VERIFIED | `bash scripts/check-metal-runtime.sh --self-test` passed with `metal_runtime_static_boundary_passed` and `metal_runtime_self_test_passed`; mutations for cleanup, public schema, alternate execution, raw diagnostics, and target movement all fail as intended. |
| 10 | The archive-first no-skip wrapper invokes the Metal preflight before consumer/oracle/opt-in/full-child stages and rejects failures/skips. | ✓ VERIFIED | `run-no-skip-swiftpm.sh` line 62 invokes `check-metal-runtime.sh` after archive/boundary and backend authorization and before consumer/oracle stages; full wrapper passed with eight opt-ins exactly once and zero skipped tests. |
| 11 | Current architecture/design/security/reliability/product/quality/codebase owners describe the same package-only runtime, fail-closed availability, cleanup, CPU reference, and Phase 72/73/74 boundaries. | ✓ VERIFIED | All nine owner documents contain the corresponding ownership, lifecycle, aggregate-only, no-fallback, CPU-reference, and later-phase statements. A stale historical baseline count of 702 remains in several owners (see warning below), but it does not contradict the runtime contract. |
| 12 | Durable ledgers report only aggregate runtime evidence and preserve the package-only/nonclaim boundary. | ✓ VERIFIED | `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` record focused 26/0/0, full 728/0/0, separate availability, cleanup/error status, CPU reference, and no public selector/feature/device/release claims. |
| 13 | METAL-01 is marked complete only after executable runtime/backend, mutation, boundary, and no-skip evidence. | ✓ VERIFIED | Direct reruns passed runtime preflight, post-archive boundary, wrapper self-test, focused suite, build, and full archive-first wrapper before this report was written. |
| 14 | Phase 71 does not claim feature-pass parity, public `.cpu`/`.gpu` configuration, new algorithms, UI/Demo, device/performance, commercial, packaging, shipping, launch, or release readiness. | ✓ VERIFIED | Source scans find no public selector or feature-pass implementation; roadmap/requirements/project/state assign feature passes to Phase 72, public configuration to Phase 73, and parity/closeout to Phase 74, with explicit nonclaims. |

**Score:** 14/14 truths verified

## Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift` | Package-owned bounded Metal resource transaction | ✓ VERIFIED | Exists (408 lines), substantive typed setup/validation/encoding/status/cleanup; consumed by `BeautyMetalBackend` and runtime tests; real available-host identity output passes. |
| `BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift` | Availability, malformed, failure, synchronization, cleanup, recovery tests | ✓ VERIFIED | Exists (188 lines), six tests execute as part of focused 26/0/0; covers nil device, setup seams, malformed preallocation, terminal failures, repeated and recovery paths. |
| `BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift` | Package-only `.metal` policy and shared result validation | ✓ VERIFIED | Exists (385 lines), `case metal` is package-scoped and request/result validation remains shared; imported/used by backend and tests. |
| `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift` | Stateless backend bridge over one runtime transaction | ✓ VERIFIED | Exists (277 lines), one `invokeRuntime` per admitted request, matching output conversion and aggregate diagnostics; imported by package tests. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalBackendTests.swift` | Boundary, output-kind, no-fallback, error, isolation tests | ✓ VERIFIED | Exists (428 lines), nine tests execute and pass; hooks assert exact invocation and terminal-error counts. |
| `scripts/check-metal-runtime.sh` | Mutation-tested static/focused runtime preflight | ✓ VERIFIED | Exists (374 lines), live and self-test modes pass; checks regular-file target ownership, shader inventory, bounds, cleanup, schema, privacy, and availability. |
| `scripts/run-no-skip-swiftpm.sh` | Archive-first mandatory wrapper integration | ✓ VERIFIED | Invokes Metal preflight before later stages; self-test and full wrapper pass. |
| `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `.planning/codebase/{ARCHITECTURE,STACK,TESTING}.md` | Synchronized ownership/security/reliability/acceptance/quality maps | ✓ VERIFIED | All exist and describe the same internal lifecycle and later-phase boundaries; stale 702 historical baseline counts are noted under Anti-Patterns. |
| `PLANS.md`, `.planning/{PROJECT,REQUIREMENTS,ROADMAP,STATE}.md` | Aggregate closeout and exact METAL-01 traceability | ✓ VERIFIED | Four plan IDs and METAL-01 are present; measured 26/0/0 and 728/0/0 evidence and nonclaims are recorded. |

## Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `BeautyMetalRuntime.swift` | `Shaders/Warp.metal` | `Bundle.module` library/source lookup and `beauty_warp_placeholder` function | ✓ WIRED | Production library lookup first tries the module default library, then loads the existing bundled `Warp.metal`; function name matches the shader. |
| `BeautyMetalRuntime.swift` | `BeautyError.swift` | Typed initialization, validation, and terminal errors | ✓ WIRED | `.metalUnavailable`, `.commandQueueCreationFailed`, `.textureCreationFailed`, `.shaderFunctionNotFound`, `.invalidInput`, and stable `.renderFailed` reasons are thrown in concrete branches. |
| `BeautyMetalBackend.swift` | `BeautyMetalRuntime.swift` | `runtime.render` through `invokeRuntime` | ✓ WIRED | Pixel-buffer and still-image branches convert request-local RGBA8 data and call the runtime exactly once. |
| `BeautyMetalBackend.swift` | `BeautyBackendContract.swift` | `BeautyBackendExecutor`, `BeautyBackendRequest`, `BeautyBackendResult` | ✓ WIRED | Executor accepts the shared request, validates `.metal`, and publishes a result through shared kind/dimension/diagnostic validation. |
| `scripts/run-no-skip-swiftpm.sh` | `scripts/check-metal-runtime.sh` | Ordered preflight invocation | ✓ WIRED | The wrapper calls the Metal gate after archive/boundary/backend gates and before consumer/CPU/opt-in/full-child stages. |
| `.planning/REQUIREMENTS.md` | `PLANS.md` / `.planning/ROADMAP.md` | METAL-01 status and four-plan traceability | ✓ WIRED | METAL-01 is mapped only to Phase 71 and all four plan IDs are recorded in the ledgers. |

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `BeautyMetalRuntime.swift` | `rgba8Bytes` / `output` | Backend packed BGRA or canonical/rasterized RGBA8 request bytes → staging buffer → private textures → retained identity kernel → readback buffer | Yes; available-host tests assert byte-for-byte output | ✓ FLOWING |
| `BeautyMetalBackend.swift` | `renderedBytes` / output carrier | `CVPixelBuffer` row copy or canonical-image/rasterized CIImage conversion, then one runtime result | Yes; pixel-buffer and still-image tests assert bytes/dimensions/extent | ✓ FLOWING |
| `BeautyMetalBackend.swift` | `BeautyBackendDiagnostics` | Actual output dimensions plus request composition aggregate, bounded by pixel count | Yes, bounded aggregate values | ✓ FLOWING |
| `BeautyMetalRuntime` | `resourceCountersForTesting` | Every tracked request allocation and paired cleanup defer | Yes; success/failure/recovery tests assert `active == 0` and `created == released` | ✓ FLOWING |

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Metal mutation/static preflight | `bash scripts/check-metal-runtime.sh --self-test` | `metal_runtime_static_boundary_passed`; `metal_runtime_self_test_passed` | ✓ PASS |
| Metal live preflight | `bash scripts/check-metal-runtime.sh` | `metal_runtime_preflight_passed`, `metal_available=1`, `metal_unavailable=0`, `focused_tests=26`, `failures=0`, `skips=0` | ✓ PASS |
| Focused runtime/backend/contract/CPU/routing tests | `swift test --package-path BeautySDK --filter 'BeautyRenderTests.BeautyMetalRuntimeTests|BeautyEffectsTests.BeautyMetalBackendTests|BeautyEffectsTests.BeautyBackendContractTests|BeautyEffectsTests.BeautyCPUBackendTests|BeautyCoreTests.BeautyEngineBackendRoutingTests'` | 26 executed, 0 failures, 0 skipped | ✓ PASS |
| SwiftPM package build | `swift build --package-path BeautySDK` | Build complete, exit 0 (one non-blocking unused `withUnsafeMutableBytes` result warning) | ✓ PASS |
| SDK-only post-archive boundary | `bash scripts/check-sdk-only-boundary.sh --post-archive` | `POST-ARCHIVE SDK BOUNDARY PASSED` | ✓ PASS |
| No-skip wrapper mutation accounting | `bash scripts/run-no-skip-swiftpm.sh --self-test` | `NO-SKIP TRANSCRIPT SELF-TEST PASSED` | ✓ PASS |
| Full archive-first SDK-owned gate | `bash scripts/run-no-skip-swiftpm.sh` | `no_skip_swiftpm_passed opt_in_tests=8 skipped_tests=0`; SwiftPM child 728 executed, 0 failures, 0 skips; exit 0 | ✓ PASS |
| Diff hygiene | `git diff --check` | No output, exit 0 | ✓ PASS |

## Probe Execution

No `scripts/*/tests/probe-*.sh` probes are present, and no Phase-71 plan or summary declares one. Probe execution is not applicable; the declared preflight and SwiftPM commands were run directly.

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| METAL-01 | `71-01-PLAN.md`, `71-02-PLAN.md`, `71-03-PLAN.md`, `71-04-PLAN.md` | SDK owns bounded Metal device, queue, texture, synchronization, and resource lifetime with deterministic cleanup and no host/UI lifecycle dependency. | ✓ SATISFIED | Runtime/backend source and wiring pass all levels; focused 26/0/0, live preflight availability classification, mutation self-test, boundary gate, and full 728/0/0 no-skip wrapper pass. |

No Phase-71 requirement is orphaned. The later METAL-02..04, CONFIG-01..02, PARITY-01..03, and CLOSE-01..02 requirements are explicitly assigned to Phases 72–74 and are not claimed here.

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| `QUALITY_SCORE.md` | 23, 74 | Owner snapshot still says the latest mandatory wrapper is 702 tests; Phase-71 closeout actually executes 728. | ⚠️ Warning | Documentation baseline drift only; runtime/preflight behavior and the Phase-71 closeout ledgers are unaffected. |
| `ARCHITECTURE.md` | 185 | Same stale 702-test historical sentence. | ⚠️ Warning | Update the current owner snapshot when convenient; no scope or runtime contradiction. |
| `RELIABILITY.md` | 175 | Same stale 702-test historical sentence. | ⚠️ Warning | Update the current owner snapshot when convenient; no scope or runtime contradiction. |
| `PRODUCT_SENSE.md` | 110 | Same stale 702-test historical sentence. | ⚠️ Warning | Update the current owner snapshot when convenient; no scope or runtime contradiction. |
| `.planning/codebase/TESTING.md` | 21, 64 | Same stale 702-test historical sentence. | ⚠️ Warning | Update the current codebase test map to 728 for current closeout accuracy. |
| `scripts/check-metal-runtime.sh`, `scripts/run-no-skip-swiftpm.sh`, `SECURITY.md` | 260, 350, 91, 85 | `XXXXXX` temporary-name suffixes match a literal `XXX` grep, but are `mktemp` templates, not debt markers. | ℹ️ Info | False-positive marker scan; no TODO/FIXME/XXX implementation debt found. |
| `.planning/ROADMAP.md`, `.planning/STATE.md` | future-phase plan/count rows | `TBD` denotes not-yet-started Phases 72–74, not Phase-71 implementation debt. | ℹ️ Info | Explicit future scope; no blocker in the delivered Phase-71 runtime. |

No runtime/backend source contains TODO/FIXME/XXX debt, placeholder user-visible output, empty handlers, console-only implementation, public selector, CPU fallback, retry, or raw durable runtime payload.

## Human Verification Required

None. This phase intentionally claims package-only host-available/unavailable mechanics and aggregate cleanup/error behavior; it does not claim visual feature behavior, UI/user flow, real-time behavior, physical-device behavior, performance feel, or external-service integration. Those are either later-phase scope or explicitly out of scope.

## Gaps Summary

No METAL-01 implementation gap was found. The SDK-owned runtime exists, is substantive, is wired through the package-only backend-neutral boundary, and produces real identity output on the available host. Failure, unavailable, malformed, repeated, mixed-backend, cleanup, and no-fallback paths are covered by direct tests and mutation/static gates. The only finding is warning-level documentation drift: five current owner/map locations retain the older 702-test baseline while the independently rerun Phase-71 archive-first wrapper reports 728/0/0. This does not alter the phase goal or create a runtime failure, but those owner snapshots should be synchronized before relying on them as the current count.

Feature passes, public `.cpu`/`.gpu` configuration, CPU/GPU parity, device/performance evidence, UI/Demo behavior, commercial approval, packaging, shipping, launch, and release readiness remain unverified and are correctly assigned outside Phase 71.

---

_Verified: 2026-08-16T08:54:00Z_
_Verifier: the agent (gsd-verifier)_
