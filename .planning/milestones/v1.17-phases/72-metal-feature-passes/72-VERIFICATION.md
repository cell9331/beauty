---
phase: 72-metal-feature-passes
verified: 2026-08-17T01:20:23Z
status: passed
score: 8/8 must-haves verified
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 7/8
  gaps_closed:
    - "Combined Metal saturation now preserves the CPU skin-smoothing contribution."
    - "Generated combined saturation-plus-skin-smoothing CPU-vs-Metal coverage rejects the omitted-term mapping."
    - "The identified backend withUnsafeMutableBytes warning is absent."
    - "The Phase 72 roadmap plan inventory and progress row are synchronized."
  gaps_remaining: []
  regressions: []
---

# Phase 72: Metal Feature Passes Verification Report

**Phase Goal:** The Metal backend renders every shipped feature family in scope while preserving the CPU semantics and existing safety boundaries.
**Verified:** 2026-08-17T01:20:23Z
**Status:** passed
**Re-verification:** Yes — after closure of G-01

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1 | Metal color/skin requests preserve CPU direction, bounds, metadata, finite math, alpha, and untouched eligible pixels, including combined plans. | ✓ VERIFIED | `BeautyMetalBackend.makePasses` now maps `saturationDelta` as `strengths.saturation * 0.28 - strengths.skinSmoothing * 0.18 + filter.saturation` (line 286), matching both CPU still-image and pixel-buffer equations (lines 162 and 213 of `BeautyColorEffectPipeline.swift`). The generated combined regression passes for `(0.8, 0.8)`, `(0.55, 0.35)`, and `(0.25, 0.7)`. |
| 2 | Metal color output preserves BGRA/RGBA behavior, alpha, dimensions, extent, and named sRGB metadata. | ✓ VERIFIED | Backend conversion/materialization remains wired through `bgraToRgba`, `rgbaToBgra`, checked row bytes, named sRGB output, and extent restoration. `BeautyMetalColorPassTests` and `BeautyMetalBackendTests` pass in the 32-test feature gate. |
| 3 | Geometry derives only from the existing selected-face adapter and unified control-point pipeline, preserving finite bounded payloads and shipped caps/directions. | ✓ VERIFIED | `BeautyMetalBackend` calls `BeautyFaceGeometryAdapter.makeGeometry` and `BeautyGeometryEffectPipeline.controlPoints`; bounded serialization and the generated 44-family inventory pass in `BeautyMetalGeometryPassTests`. |
| 4 | Geometry uses CPU-compatible top-left inverse displacement, falloff, clamped bilinear sampling, alpha/locality/extent, and no-face degradation. | ✓ VERIFIED | `Warp.metal` contains the bounded inverse-displacement, falloff, clamped bilinear sampling, and source-alpha path. Feature preflight and full no-skip execution pass generated geometry direction/locality/no-face checks. |
| 5 | Local retouch consumes only the owner-produced canonical carrier and preserves immutable-original composition, Q16 bytes, protected bytes, alpha, extent, and metadata. | ✓ VERIFIED | `BeautyMetalBackend` consumes the canonical composed carrier before other passes; `BeautyMetalLocalRetouchPassTests` passes carrier, Q16, protected-byte, alpha, extent, metadata, and mixed-pass checks. |
| 6 | Malformed, foreign, duplicate, colliding, and rejected local-retouch units remain smallest-unit isolated; valid siblings and collision-to-source semantics continue. | ✓ VERIFIED | Existing composition-owner tests and generated Metal local-retouch tests pass in the feature gate and the 745-test no-skip run. Metal receives only the carrier and bounded aggregate summary. |
| 7 | Ordered Metal runtime work is bounded, finite, synchronized, request-local, and cleaned on success and terminal failure. | ✓ VERIFIED | `BeautyMetalRuntimeTests` pass with the ordered pass graph, private ping-pong resources, malformed-work rejection, terminal failures, repeated requests, and cleanup checks. Runtime preflight reports `focused_tests=29`, `metal_available=1`, `metal_unavailable=0`, `failures=0`, `skips=0`. |
| 8 | Phase scope remains package-only: no public backend selector, new parameter/preset/algorithm, UI/Demo/device/release expansion, or raw payload diagnostics. | ✓ VERIFIED | Feature static/mutation self-test passes; public inventory remains 61 parameters, 10 configuration fields, 5 presets, and 74 renderer cases. No public `.cpu`/`.gpu` selector is introduced; that remains Phase 73. |

**Score:** 8/8 truths verified

## Deferred Items

Public backend configuration and typed unavailable-GPU policy remain Phase 73 work. Generated cross-backend parity and final SDK-only closeout remain Phase 74 work, as explicitly scoped in the roadmap; these are not Phase 72 gaps.

## Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift` | Finite package-only color/geometry/composed-retouch carriers | ✓ VERIFIED | Primitive payload validation and bounded point counts are present and consumed by the runtime. |
| `BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift` | Ordered bounded Metal dispatch and cleanup | ✓ VERIFIED | Real dispatch, private textures, synchronization/status checks, and cleanup are exercised by runtime tests. |
| `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` | Retained identity plus color, geometry, and composed-retouch kernels | ✓ VERIFIED | All four expected kernels and bounded output math are present; the single shader inventory is unchanged. |
| `BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift` | CPU-plan mapping, geometry serialization, carrier and channel bridge | ✓ VERIFIED | Combined saturation equation is corrected; BGRA/RGBA, sRGB, geometry, and carrier links are wired. |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` | Retained CPU still-image and pixel-buffer coefficient consistency | ✓ VERIFIED | Both CPU paths include `-strengths.skinSmoothing * 0.18`. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift` | Generated color and CPU-vs-Metal coverage | ✓ VERIFIED | Named combined regression exists and routes the same generated fixture through `BeautyCPUBackend` and `BeautyMetalBackend`. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift` | Generated geometry safety/recovery coverage | ✓ VERIFIED | Unified 44-row inventory and direction/locality/no-face checks pass. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalLocalRetouchPassTests.swift` | Carrier, protection, isolation, mixed-order, cleanup coverage | ✓ VERIFIED | Five generated local-retouch tests pass in the full feature focused suite. |
| `scripts/check-metal-feature-passes.sh` | Static/mutation/focused feature preflight | ✓ VERIFIED | Self-test and live mode pass; live accounting is 32 focused tests, zero failures/skips, and explicit availability split. |
| `scripts/run-no-skip-swiftpm.sh` | Archive-first exactly-once feature gate | ✓ VERIFIED | Full run invokes the feature gate once and completes 745 tests with zero failures/skips; all eight opt-ins execute exactly once. |
| `.planning/ROADMAP.md` | Four-plan Phase 72 inventory and completion row | ✓ VERIFIED | `72-04-GAP-01-PLAN.md` is listed and progress is `4/4 | Complete | 2026-08-17`. |

## Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| `BeautyMetalBackend.swift` | `BeautyMetalRuntime.swift` | One ordered `runtime.render` request with RGBA8 bytes and pass payloads | ✓ WIRED | Backend invokes the runtime once with the selected pass graph. |
| `BeautyMetalBackend.swift` | `BeautyMetalPass.swift` | Color uniforms, geometry payload, and composed carrier | ✓ WIRED | `BeautyMetalColorParameters`, `BeautyMetalGeometryParameters`, and composed-retouch payloads are constructed and validated. |
| `BeautyMetalRuntime.swift` | `Warp.metal` | Bundle kernel lookup and pass-specific pipelines | ✓ WIRED | Runtime resolves and dispatches color, geometry, local-retouch, and retained identity kernels. |
| `BeautyMetalBackend.swift` | `BeautyFaceGeometryAdapter` | Selected observation adaptation | ✓ WIRED | One request-local geometry adaptation feeds the unified point pipeline. |
| `BeautyMetalBackend.swift` | `BeautyGeometryEffectPipeline` | Existing `controlPoints(for:face:)` source | ✓ WIRED | No duplicate support discovery or warp provider path is introduced. |
| `BeautySDK/BeautyEngine.swift` | `BeautyLocalRetouchCompositionOwner` | Canonical composition before backend request publication | ✓ WIRED | Metal consumes the owner-produced carrier and aggregate summary. |
| `BeautyMetalColorPassTests.swift` | `BeautyMetalBackend.swift` / `BeautyCPUBackend.swift` | Generated combined plan uses both backend executors | ✓ WIRED | The named regression renders identical generated inputs through `.metal` and `.cpu` and compares alpha, max channel delta, and mean RGB delta. |
| `run-no-skip-swiftpm.sh` | `check-metal-feature-passes.sh` | Archive-first exactly-once preflight ordering | ✓ WIRED | The feature gate runs before consumer/oracle/opt-in/full-child stages. |

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|---|---|---|---|---|
| `BeautyMetalBackend.swift` | `BeautyMetalColorParameters` | Normalized `BeautyEffectPlan.effectiveStrengths` plus filter contribution | Yes; includes the full combined CPU coefficient | ✓ FLOWING |
| `BeautyMetalBackend.swift` | `BeautyMetalGeometryParameters` | Selected observation → existing face adapter → unified control points | Yes; finite bounded provider output | ✓ FLOWING |
| `BeautyMetalBackend.swift` | Composed-retouch carrier | `BeautyLocalRetouchCompositionOwner` canonical RGBA8 result | Yes; immutable source-derived bytes | ✓ FLOWING |
| `BeautyMetalRuntime.swift` | Ordered pass output | Private textures, buffers, and synchronized Metal kernels | Yes on available host; unavailable is explicit | ✓ FLOWING |

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|---|---|---|---|
| Combined CPU-vs-Metal saturation/skin-smoothing parity | `swift test --package-path BeautySDK --filter 'BeautyEffectsTests.BeautyMetalColorPassTests|BeautyEffectsTests.BeautyMetalBackendTests|BeautyEffectsTests.CPUReferenceColorOracleTests'` | 19 tests, 0 failures, 0 skips; combined regression passed | ✓ PASS |
| Three-family feature preflight | `bash scripts/check-metal-feature-passes.sh` | `focused_tests=32`, `metal_available=1`, `metal_unavailable=0`, `failures=0`, `skips=0` | ✓ PASS |
| Runtime preflight | `bash scripts/check-metal-runtime.sh` | `focused_tests=29`, `metal_available=1`, `metal_unavailable=0`, `failures=0`, `skips=0` | ✓ PASS |
| Build and identified warning scan | `swift build --package-path BeautySDK` plus `withUnsafeMutableBytes` warning scan | Build succeeded; no identified backend warning | ✓ PASS |
| SDK-only boundary | `bash scripts/check-sdk-only-boundary.sh --post-archive` | `POST-ARCHIVE SDK BOUNDARY PASSED` | ✓ PASS |
| Mandatory archive-first no-skip gate | `bash scripts/run-no-skip-swiftpm.sh` | 745 tests, 0 failures, 0 skips; 8 opt-ins exactly once | ✓ PASS |
| No-skip transcript accounting self-test | `bash scripts/run-no-skip-swiftpm.sh --self-test` | `NO-SKIP TRANSCRIPT SELF-TEST PASSED` | ✓ PASS |
| Diff hygiene | `git diff --check` | No whitespace errors | ✓ PASS |

## Probe Execution

No phase-declared or conventional `probe-*.sh` was found; this is not a migration/tooling probe phase.

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|---|---|---|---|---|
| METAL-02 | 72-01 and 72-04-GAP-01 | CPU color/skin semantics, metadata, finite math, and untouched pixels | ✓ SATISFIED | Corrected combined coefficient, generated parity regression, color tests, feature preflight, and full no-skip gate pass. |
| METAL-03 | 72-02 | CPU geometry direction/cap/extent/protection/collision/no-face semantics | ✓ SATISFIED | Unified 44-row control-point inventory, bounded inverse warp, locality/alpha/recovery tests, and feature preflight pass. |
| METAL-04 | 72-03 | Request-local composition, immutable original, protected/alpha, and unit isolation | ✓ SATISFIED | Canonical carrier and generated local-retouch isolation tests pass, with the full gate green. |

No orphaned Phase-72 requirement IDs were found.

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---:|---|---|---|
| `BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` | retained identity kernel | `beauty_warp_placeholder` marker | ℹ️ Info | Intentional retained neutral/runtime probe; feature kernels are substantive and tested. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalLocalRetouchPassTests.swift` | 266 | Unused `withUnsafeMutableBytes` result warning in a test helper | ℹ️ Info | Does not affect Phase 72 behavior or the cleaned backend warning; optional future warning cleanup. |
| `.planning/PROJECT.md` | 51 | Text still says “Phase 72 is next” | ⚠️ Warning | Lifecycle metadata must be advanced to Phase 73 by the phase-completion workflow. |
| `.planning/STATE.md` | 123–125 | Resume state still says Phase 72 stopped at Plan 03 and next action is Plan 03 | ⚠️ Warning | State ledger is stale after gap closure; update it before advancing the milestone. |

No unreferenced `TBD`, `FIXME`, or `XXX` debt marker was found in Phase-72 implementation files. The `TBD` entries in the roadmap belong to not-started Phases 73 and 74.

## Human Verification Required

None for this package-only aggregate/static feature-pass contract. Visual feel, performance, device behavior, and release validation remain explicitly outside Phase 72.

## Gaps Summary

G-01 is closed. The Metal adapter now preserves the complete CPU saturation equation for combined saturation and skin smoothing, the generated regression compares the same in-memory input through both backends, and all focused, runtime, boundary, and mandatory no-skip gates are green. Phase 72's roadmap inventory and progress row are synchronized. The only remaining findings are lifecycle-document warnings in `.planning/PROJECT.md` and `.planning/STATE.md`; they do not indicate an implementation gap but must be repaired by phase-completion bookkeeping before Phase 73 work proceeds.

---

_Verified: 2026-08-17T01:20:23Z_  
_Verifier: the agent (gsd-verifier)_
