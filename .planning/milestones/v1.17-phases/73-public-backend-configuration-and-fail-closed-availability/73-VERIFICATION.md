---
phase: 73-public-backend-configuration-and-fail-closed-availability
verified: 2026-08-17T10:30:00Z
status: passed
score: 8/8 must-haves verified
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 7/8
  gaps_closed:
    - "Current owner/map text no longer claims public GPU routing is absent or belongs to a later phase."
    - "ROADMAP and PROJECT current-status drift is repaired; Phase 73 is checked/completed and Phase 74 is the next position."
  gaps_remaining: []
  regressions: []
---

# Phase 73: Public Backend Configuration and Fail-Closed Availability Verification Report

**Phase Goal:** Integrators can explicitly choose CPU or GPU execution with compatibility-safe defaults and an honest failure when the requested GPU cannot execute.
**Verified:** 2026-08-17T10:30:00Z
**Status:** passed
**Re-verification:** Yes — after gap closure commits `d09bd14` and `64fd9a7`

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Public `BeautyConfiguration.renderBackend` exposes exactly `.cpu` and `.gpu` without changing the parameter/preset/renderer schemas. | ✓ VERIFIED | `BeautyRenderBackend` has exactly two cases; configuration tests and the static gate pass; `BeautyParameters` remains 61 fields, presets 5, renderer cases 74. |
| 2 | New and missing-key legacy configurations deterministically use `.cpu`; explicit `.gpu` round-trips. | ✓ VERIFIED | `BeautyConfiguration.init(from:)` uses `decodeIfPresent(... .renderBackend) ?? .cpu`; focused configuration coverage is included in the 16-test gate. |
| 3 | Explicit unavailable GPU construction fails with typed `.metalUnavailable` and never falls back to CPU or publishes success. | ✓ VERIFIED | `BeautyBackendFactory` has a closed `.cpu`/`.gpu` switch with unchanged throwing Metal construction; routing/runtime tests pass and static fallback mutations fail. |
| 4 | Backend policy is immutable and request-local across still-image, pixel-buffer, and interleaved engine requests. | ✓ VERIFIED | `BeautyEngine` stores `backendPolicy` and propagates `policy: backendPolicy` at all three request constructors; routing suite covers CPU/GPU isolation. |
| 5 | The SDK-owned configuration gate rejects selector/default/branch/policy/fallback drift before child execution. | ✓ VERIFIED | `bash scripts/check-backend-configuration.sh --self-test` passes all mutation cases; live gate passes `16/0/0`. |
| 6 | The archive-first mandatory gate runs configuration/runtime/CPU/reference/consumer/SwiftPM checks with explicit availability accounting and no unexpected skips. | ✓ VERIFIED | `bash scripts/run-no-skip-swiftpm.sh` exits 0: `753` executed, `0` failures, `0` skips; all 8 opt-ins exactly once; `metal_available=1`, `metal_unavailable=0`. |
| 7 | Current owner documents agree on the completed public CPU/GPU/fail-closed contract and exclusions. | ✓ VERIFIED | Re-check confirms `.planning/codebase/ARCHITECTURE.md` names Phase-73 public routing and `RELIABILITY.md` names Phase 73 selection/current Phase 74 parity ownership; root owners retain CPU reference and all exclusions. |
| 8 | Phase 73 planning ledgers are internally synchronized to completion and the Phase 74 handoff. | ✓ VERIFIED | ROADMAP Phase 73 is checked/completed, STATE points to Phase 74 with `completed_phases: 4` and 80%, PROJECT records the Phase 74 parity handoff, and `roadmap.analyze` reports Phase 73 complete. |

**Score:** 8/8 truths verified

## Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` | Closed public backend enum and compatibility-safe configuration field | ✓ VERIFIED | Substantive implementation; consumed by public engine and tests. |
| `BeautySDK/Sources/BeautySDK/BeautyBackendFactory.swift` | Immutable CPU/GPU executor selection | ✓ VERIFIED | Package-only factory is wired from `BeautyEngine`; `.gpu` constructs Metal and propagates errors. |
| `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | Public selection and policy propagation | ✓ VERIFIED | Public initializer selects once; all three request routes carry the stored policy. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift` | Codable/default/schema regressions | ✓ VERIFIED | Focused tests execute as part of the live 16-test gate. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift` | Routing, fail-closed, and request isolation regressions | ✓ VERIFIED | Tests cover factory, public GPU integration, typed failure, and interleaving. |
| `scripts/check-backend-configuration.sh` | Static/mutation/live configuration gate | ✓ VERIFIED | Self-test/live execution pass; wrapper invokes it once. |
| `scripts/run-no-skip-swiftpm.sh` | Archive-first full gate integration | ✓ VERIFIED | Configuration gate appears once before consumer/oracle/opt-ins/full child. |
| `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` | Current contract owners | ✓ VERIFIED | Current Phase 73 sections describe the selector and fail-closed policy; historical sections remain phase-qualified. |
| `RELIABILITY.md` | Current failure/recovery contract | ✓ VERIFIED | Current processing section and Phase 73 section agree on public selection and Phase 74 parity ownership. |
| `.planning/codebase/ARCHITECTURE.md` | Current codebase map | ✓ VERIFIED | Current flow now names Phase-73 `BeautyConfiguration`/`BeautyBackendFactory` routing; no stale absent-routing claim remains. |
| `.planning/codebase/STACK.md`, `.planning/codebase/TESTING.md` | Current stack/test maps | ✓ VERIFIED | Both record the public selector, typed unavailable outcome, and measured evidence. |
| `.planning/PROJECT.md` | Current project position | ✓ VERIFIED | Implementation/verification state now records Phase 73 completion and Phase 74 parity handoff. |
| `.planning/REQUIREMENTS.md` | CONFIG-01/02 traceability | ✓ VERIFIED | Both requirements are mapped to Phase 73 and marked complete against the gate evidence. |
| `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` | Phase lifecycle and handoff ledgers | ✓ VERIFIED | Phase 73 is checked/completed, STATE reports four completed phases and current Phase 74, and PLANS records the measured handoff. |

## Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `BeautyConfiguration.renderBackend` | `BeautyBackendFactory` | `BeautyBackendFactory.select(configuration:)` | ✓ WIRED | Closed switch selects exactly one executor/policy. |
| `BeautyBackendFactory` | `BeautyMetalBackend.init` | `.gpu` branch and throwing `metalFactory` | ✓ WIRED | Construction errors escape unchanged; no CPU branch executes after failure. |
| `BeautyEngine` | `BeautyBackendRequest` | `policy: backendPolicy` | ✓ WIRED | Three request constructors carry the immutable policy. |
| `scripts/run-no-skip-swiftpm.sh` | `scripts/check-backend-configuration.sh` | one archive-first invocation | ✓ WIRED | Static/live configuration gate runs before consumer/oracle/opt-in/full child. |
| `.planning/REQUIREMENTS.md` | `73-03-SUMMARY.md` | CONFIG-01/02 evidence traceability | ✓ WIRED | Requirement map and summary record the 16/34/753 gate evidence. |

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `BeautyEngine` | `backendExecutor` / `backendPolicy` | `BeautyBackendFactory.select` and backend `execute` | Yes — selected executor performs the request and returns typed result/error | ✓ FLOWING |
| `BeautyConfigurationTests` / routing tests | encoded config and recorded request policy | real SwiftPM model/factory/engine calls | Yes — assertions observe actual Codable and request behavior | ✓ FLOWING |

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Configuration selector/default/no-fallback gate | `bash scripts/check-backend-configuration.sh` | focused `16`, failures `0`, skips `0`, `metal_available=1`, `metal_unavailable=0` | ✓ PASS |
| Metal runtime available/unavailable classification | `bash scripts/check-metal-runtime.sh` | focused `34`, failures `0`, skips `0`, separate availability markers | ✓ PASS |
| Full SDK-only archive-first gate | `bash scripts/run-no-skip-swiftpm.sh` | exit 0; `753/0/0`; 8 opt-ins exactly once | ✓ PASS |
| SDK-only static boundary | `bash scripts/check-sdk-only-boundary.sh --post-archive` | pass (also invoked by full gate) | ✓ PASS |
| Diff hygiene | `git diff --check` | pass | ✓ PASS |

## Probe Execution

No phase-declared `probe-*.sh` scripts were found; this phase uses the SDK-owned configuration/runtime gates and the mandatory no-skip wrapper instead.

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| CONFIG-01 | 73-01, 73-03, 73-04 | Public exact `.cpu`/`.gpu` configuration with source/Codable compatibility and CPU defaults | ✓ SATISFIED | Model/tests/static gate pass; 61-parameter, 5-preset, 74-renderer inventories unchanged. |
| CONFIG-02 | 73-02, 73-03, 73-04 | Explicit unavailable GPU is typed `.metalUnavailable` with no CPU fallback/success | ✓ SATISFIED | Factory/routing/runtime tests and live availability classification pass; no fallback mutation survives. |

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | ---: | --- | --- | --- |
No blocker anti-patterns found. No unreferenced `TBD`, `FIXME`, `XXX`, or `TODO` debt marker was found in the Phase 73 implementation files; the pending Phase 74 `TBD` entries are legitimate pre-planning markers.

## Human Verification Required

None. UI appearance, device behavior, performance feel, and external integrations are explicitly outside this SDK-only phase; the available code paths and gates are programmatically checkable.

## Gaps Summary

The public configuration and fail-closed runtime behavior are independently green: exact selector/default/Codable behavior, immutable request policy, typed unavailable-GPU handling, mutation gates, Metal classifications, boundary checks, and the full 753-test no-skip gate all pass. The owner/map and lifecycle drift was closed by `d09bd14` and `64fd9a7`; the final consistency check reports Phase 73 complete and Phase 74 next. Phase 73 is ready to proceed.

---

_Verified: 2026-08-17T10:30:00Z_
_Verifier: the agent (gsd-verifier)_
