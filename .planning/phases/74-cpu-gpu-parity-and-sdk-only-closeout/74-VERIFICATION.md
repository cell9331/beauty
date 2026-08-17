---
phase: 74-cpu-gpu-parity-and-sdk-only-closeout
verified: 2026-08-17T11:25:00+08:00
status: passed
score: 5/5 must-haves verified
overrides_applied: 0
---

# Phase 74: CPU/GPU Parity and SDK-Only Closeout Verification Report

**Phase Goal:** Generated SDK-owned evidence demonstrates safe, deterministic parity between available backends and closes the milestone without weakening the CPU oracle or expanding the active product boundary.
**Verified:** 2026-08-17T11:25:00+08:00
**Status:** passed
**Re-verification:** Yes — after current-owner documentation drift closure in commit `9cf311d`

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Generated SwiftPM fixtures compare CPU and GPU through explicit structural checks and bounded tolerances, with exact neutral bytes and dimensions. | ✓ VERIFIED | `BeautyBackendParityFixtureFactory` and `BeautyBackendParityTests` use identical generated requests, exact `XCTAssertEqual(gpuBytes, cpuBytes)` neutral comparison, dimensions/kind/alpha/extent/named-sRGB observations, and pinned max-channel `8` / mean-RGB `<5.0` active tolerances. Focused parity passed. |
| 2 | Parity covers alpha, metadata, extent, outside/containment, collision-to-source, no-face/degraded requests, and failure isolation without durable raw payloads. | ✓ VERIFIED | `BeautyBackendSafetyParityTests` passed 4/4; containment, protected/outside/alpha equality, translated extent, source-bound collision summary, malformed/no-face and sibling isolation assertions are present. Mutation-tested gate and SDK-only boundary reject raw output/scope drift. |
| 3 | Repeated identical requests are finite/deterministic for available backends, selection is request-local and concurrency-safe, and prior requests cannot alter later output. | ✓ VERIFIED | Determinism and selection suites passed 4 combined tests; bounded task groups compare request IDs to serial CPU baselines, assert diagnostics/resource cleanup, immutable policies, and one executor call per request. |
| 4 | Failed GPU units do not suppress eligible siblings, and unavailable-host coverage is explicit rather than borrowed as GPU parity. | ✓ VERIFIED | Safety/routing tests assert sibling preservation, typed `.metalUnavailable`, one factory call, no successful GPU result, and separate availability markers. Live gate reports `metal_available=1`, `metal_unavailable=0`. |
| 5 | Mandatory archive-first SDK-owned gate is green and current owners agree on CPU/GPU semantics and exclusions. | ✓ VERIFIED | Parity self-test/live gate, post-archive boundary, and full no-skip evidence pass; `QUALITY_SCORE.md` and `PRODUCT_SENSE.md` current sections now state Phase-74 completion and accepted generated parity only for shipped SDK features, retaining UI/device/release exclusions. |

**Score:** 5/5 truths verified

## Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift` | Generated bounded fixtures and aggregate observations | ✓ VERIFIED | Exists, substantive (227 lines), reuses CPU reference fixtures, keeps bytes request-local, and is consumed by parity/safety/determinism suites. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityTests.swift` | Structural/numeric CPU–Metal parity matrix | ✓ VERIFIED | Exists, substantive (102 lines), executes both CPU and Metal backends; 4 tests pass. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift` | Containment, protected bytes, degradation, collision and isolation parity | ✓ VERIFIED | Exists, substantive (165 lines), wired to geometry/composition owners; 4 tests pass. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyBackendDeterminismParityTests.swift` | Repeated/concurrent deterministic backend coverage | ✓ VERIFIED | Exists, substantive (94 lines), wired to CPU/Metal backends and runtime counters; 2 tests pass. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyBackendSelectionConcurrencyTests.swift` | Request-local selection and unavailable separation | ✓ VERIFIED | Exists, substantive (102 lines), wired to `BeautyBackendFactory` and typed terminal-error injection; 2 tests pass. |
| `scripts/check-backend-parity.sh` | Mutation-tested parity preflight | ✓ VERIFIED | Exists, substantive (205 lines); self-test and live preflight pass with focused `12/0/0` and separate availability markers. |
| `scripts/run-no-skip-swiftpm.sh` | Archive-first mandatory closeout integration | ✓ VERIFIED | Invokes parity exactly once in required order; full wrapper evidence is `765/0/0`, with eight opt-ins exactly once and zero skips/failures. |

## Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `BeautyBackendParityTests.swift` | `BeautyCPUBackend.swift` | Identical generated request through CPU executor | ✓ WIRED | `gsd-tools query verify.key-links` passed; focused tests pass. |
| `BeautyBackendParityTests.swift` | `BeautyMetalBackend.swift` | Identical generated request through available Metal executor | ✓ WIRED | Link check passed; host classified available. |
| `BeautyBackendSafetyParityTests.swift` | `BeautyGeometryEffectPipeline.swift` | CPU control-point envelope for GPU changed-index checks | ✓ WIRED | Link check passed; assertions use `localityEnvelope` and `changed.isSubset`. |
| `BeautyBackendSafetyParityTests.swift` | `BeautyLocalRetouchComposition.swift` | Composition source/collision/failure summary | ✓ WIRED | Link check passed; aggregate diagnostics are asserted. |
| `BeautyBackendDeterminismParityTests.swift` | `BeautyCPUBackend.swift` | Serial CPU request baselines | ✓ WIRED | Link check passed; concurrent results compare by request ID. |
| `BeautyBackendSelectionConcurrencyTests.swift` | `BeautyBackendFactory.swift` | Immutable public policy and terminal factory | ✓ WIRED | Link check passed; `.cpu`/`.metal`, call counts and typed unavailable error asserted. |
| `run-no-skip-swiftpm.sh` | `check-backend-parity.sh` | Exactly-once archive-first invocation | ✓ WIRED | Static count is one; wrapper emitted `no_skip_backend_parity_verified`. |

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `BeautyBackendParityTests.swift` | Generated request/output bytes | In-memory CPU fixtures → CPU/Metal executors → transient readback | Yes; actual outputs compared, 4 tests pass | ✓ FLOWING |
| `BeautyBackendSafetyParityTests.swift` | Changed/protected/alpha/extent aggregates | Actual Metal output versus source and CPU-owned envelope | Yes; 4 tests pass | ✓ FLOWING |
| `BeautyBackendDeterminismParityTests.swift` | Request-ID output/diagnostic observations | Serial CPU baselines and repeated/concurrent calls | Yes; 2 tests pass with resources at zero | ✓ FLOWING |
| `BeautyBackendSelectionConcurrencyTests.swift` | Policy/call count/error | Public configuration → factory → injected executor/failure | Yes; 2 tests pass | ✓ FLOWING |

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Generated CPU/GPU parity matrix | `swift test --package-path BeautySDK --filter 'BeautyEffectsTests.BeautyBackendParityTests\|BeautyEffectsTests.BeautyBackendSafetyParityTests\|BeautyEffectsTests.BeautyBackendDeterminismParityTests\|BeautyCoreTests.BeautyBackendSelectionConcurrencyTests'` | 12 executed, 0 failures, 0 skips | ✓ PASS |
| Mutation-tested parity preflight | `bash scripts/check-backend-parity.sh --self-test` | `backend_parity_self_test_passed` | ✓ PASS |
| Live parity preflight | `bash scripts/check-backend-parity.sh` | focused `12/0/0`; `metal_available=1`; `metal_unavailable=0` | ✓ PASS |
| Post-archive SDK-only boundary | `bash scripts/check-sdk-only-boundary.sh --post-archive` | `POST-ARCHIVE SDK BOUNDARY PASSED` | ✓ PASS |
| Full archive-first no-skip gate | `bash scripts/run-no-skip-swiftpm.sh` | Prior fresh run: `765/0/0`, `opt_in_tests=8`, `skipped_tests=0`; code unchanged by docs-only commit `9cf311d` | ✓ PASS |
| Diff hygiene | `git diff --check` | Passed | ✓ PASS |

## Probe Execution

No Phase-74 probes are declared or present under `scripts/*/tests/probe-*.sh`; not applicable.

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| PARITY-01 | 74-01, 74-04, 74-05 | Generated structural checks, bounded tolerances, exact neutral bytes/dimensions | ✓ SATISFIED | Parity artifacts and live focused gate pass. |
| PARITY-02 | 74-01, 74-02, 74-04, 74-05 | Alpha/metadata/extent/containment/collision/degradation/isolation, aggregate-only | ✓ SATISFIED | Safety suite 4/4, mutation gate, privacy boundary and full gate pass. |
| PARITY-03 | 74-03, 74-04, 74-05 | Determinism, request-local concurrency, typed unavailable separation | ✓ SATISFIED | Determinism/selection 4/4; availability markers and no-skip gate pass. |
| CLOSE-01 | 74-04, 74-05 | Archive-first CPU/configuration/Metal/parity/static gate with zero failures/skips | ✓ SATISFIED | Full `765/0/0`, 8 opt-ins exactly once, parity once, boundary/archive checks pass. |
| CLOSE-02 | 74-05 | Current owners and ledgers agree on CPU/GPU semantics and exclusions | ✓ SATISFIED | Current owner drift repaired in `9cf311d`; all five Phase-74 requirements/ledgers are synchronized. |

No orphaned Phase-74 requirements were found: ROADMAP and REQUIREMENTS map the same five IDs, and all five are claimed by Phase-74 plans.

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyMetalLocalRetouchPassTests.swift` | 266 | Existing compiler warning: unused `withUnsafeMutableBytes` result | ℹ️ INFO | Not a Phase-74 modified file or parity stub; full gate has zero failures/skips. |
| `scripts/check-backend-parity.sh` | 184 | `FileManager` in deliberate raw-output mutation string | ℹ️ INFO | Self-test mutation verifies static privacy rejection; no implementation writes raw output. |

No unreferenced `TODO`, `FIXME`, `XXX`, `HACK`, or placeholder markers were found in Phase-74 implementation/gate files. No `XCTSkip`, sleep, UI/device/network import, public test API, or static empty-result stub was found in Phase-74 artifacts.

## Human Verification Required

None for Phase-74 SDK-only acceptance. Device/simulator behavior, performance,
commercial visual approval, packaging, shipping, launch, and release readiness
are explicitly excluded by the milestone contract.

## Gaps Summary

No gaps remain. Executable parity, safety, determinism, request-local selection,
typed availability, archive-first no-skip evidence, SDK-only boundary, current
owners, and planning ledgers all agree. The retained CPU implementation remains
the reference; unavailable Metal never lends success to GPU parity.

---

_Verified: 2026-08-17T11:25:00+08:00_  
_Verifier: the agent (independent goal-backward verification)_
