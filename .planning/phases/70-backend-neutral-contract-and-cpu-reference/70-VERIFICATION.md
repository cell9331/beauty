---
phase: 70-backend-neutral-contract-and-cpu-reference
verified: 2026-08-16T03:34:49Z
status: passed
score: 7/7 must-haves verified
overrides_applied: 0
---

# Phase 70: Backend-Neutral Contract and CPU Reference Verification Report

**Phase Goal:** SDK execution has one backend-neutral request/result boundary, while the existing CPU implementation remains a complete, selectable, deterministic reference for the shipped feature set.
**Verified:** 2026-08-16T03:34:49Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Requests use one backend-neutral contract for canonical input/normalization, support, privacy, alpha, extent, containment, collision-to-source, and smallest-unit failure isolation. | ✓ VERIFIED | `BeautyBackendRequest`/`BeautyBackendResult` admit the existing `BeautyCanonicalStillImage`, `BeautyEffectPlan`, transient `BeautyFaceObservation`, and `BeautyLocalRetouchCompositionSummary`; validation rejects malformed dimensions, metadata/carrier mismatch, non-normalized strengths, output-kind mismatch, and unbounded aggregates. Engine-owned detection/composition remains before the executor. Focused contract tests pass 7/0/0; full generated/local-retouch safety and recovery suites pass. |
| 2 | CPU is the complete deterministic reference policy and its existing neutral/protected/dimensional behavior is reachable through the backend seam. | ✓ VERIFIED | `BeautyBackendExecutionPolicy` has `.cpu` as the sole Phase-70 policy; `BeautyEngine` defaults to stateless `BeautyCPUBackend`, while the package-only injection seam permits policy selection in routing tests. CPU delegates to the retained color/geometry Core Image path. Generated CPU preflight passes 41/0/0, and full normal SwiftPM passes 713/0/8 with zero failures. |
| 3 | Backend choice is execution policy only; parameters, presets, algorithm inventory, public configuration, and UI/Metal scope remain unchanged. | ✓ VERIFIED | Static gate passes exactly 61 public parameter fields, 10 configuration fields, five preset IDs, and 74 renderer cases; it rejects `renderBackend`/`BeautyRenderBackend`, public backend declarations, dependencies, Metal/GPU/UI/network drift. No such implementation exists in the Phase-70 source. |
| 4 | Support and intermediate data remain request-local; only bounded aggregate-safe diagnostics cross the boundary. | ✓ VERIFIED | Contract diagnostics contain only dimensions, alpha/extent flags, and bounded unit/failure/collision/change counts. No raw support, masks, pixels, paths, or landmarks are represented. Full request-local determinism/recovery/concurrency tests pass; static privacy mutation self-test rejects a raw diagnostic field. |
| 5 | Every public image and pixel-buffer process-result path dispatches exactly once through the shared contract, and executor failures are typed and terminal without fallback. | ✓ VERIFIED | `BeautyEngine.swift` has three `BeautyBackendRequest` constructions and exactly three `backendExecutor.execute` calls: pixel buffer, admitted canonical still image, and legacy still image. Direct facade pipeline dispatch is absent. Routing tests prove one still-image dispatch and terminal `.renderFailed` propagation; static mutation/self-test rejects direct dispatch and fallback tokens. |
| 6 | Existing color/geometry direction, alpha/extent, containment, collision-to-source, no-face degradation, recovery, and per-unit isolation remain compatible with the generated CPU oracle. | ✓ VERIFIED | `BeautyCPUBackend` calls the retained `BeautyColorEffectPipeline`; that pipeline retains `BeautyGeometryEffectPipeline`, while Engine retains canonicalization, detection, provider ownership, composition, and result metadata. Generated fixture/geometry-color/local-determinism counts are 15 + 10 + 16 = 41, all passing; full SwiftPM passes with zero failures. |
| 7 | Backend preflight and the archive-first no-skip gate execute positively and report bounded aggregate status with zero failures and zero unexpected skips. | ✓ VERIFIED | `check-backend-neutral-contract.sh --self-test` and normal mode pass (`focused_tests=11 cpu_reference_tests=41`). `run-no-skip-swiftpm.sh --self-test` passes. Independent archive-first wrapper passes archive verification, SDK-only boundary, backend gate, consumer, CPU oracle, all 8 opt-ins, and the full child with `opt_in_tests=8 skipped_tests=0`; final exit code 0. |

**Score:** 7/7 truths verified

### Deferred Items

No Phase-70 gaps were identified for deferral. Public `.cpu`/`.gpu` configuration, Metal runtime/passes, unavailable-GPU behavior, and parity evidence are explicitly owned by later v1.17 phases and are not Phase-70 deliverables.

## Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift` | Package-only request/result/diagnostics/executor contract | ✓ VERIFIED | Exists (385 lines), substantive validation and bounded diagnostics; consumed by Engine, CPU backend, and contract tests. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyBackendContractTests.swift` | Contract validation and privacy/terminal-error tests | ✓ VERIFIED | Exists (229 lines), 7 tests execute and pass; imports `BeautyEffects` with `@testable` and exercises all contract variants. |
| `BeautySDK/Sources/BeautyEffects/Backend/BeautyCPUBackend.swift` | Stateless CPU executor | ✓ VERIFIED | Exists (72 lines), substantive retained-pipeline delegation and result diagnostics; defaulted by `BeautyEngine`. |
| `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | One executor dispatch per facade path | ✓ VERIFIED | Uses shared requests and exactly three executor calls; no direct `BeautyColorEffectPipeline.apply` remains in the facade. |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyCPUBackendTests.swift` | CPU neutral/alpha/extent regression tests | ✓ VERIFIED | Exists (145 lines), 2 tests pass for pixel-buffer bytes/alpha and canonical still-image extent. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift` | Facade dispatch/failure routing tests | ✓ VERIFIED | Exists (88 lines), injected executor proves one dispatch and typed terminal failure without fallback. |
| `scripts/check-backend-neutral-contract.sh` | Mutation-tested static/focused backend preflight | ✓ VERIFIED | Exists (230 lines); live and mutation self-test both pass, including schema, privacy, direct-dispatch, and scope mutations. |
| `scripts/run-no-skip-swiftpm.sh` | Archive-first mandatory gate integration | ✓ VERIFIED | Calls backend preflight after archive/boundary checks and before consumer/oracle/opt-in/full-child stages; wrapper passes. |
| `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `.planning/codebase/TESTING.md` | Synchronized ownership/privacy/scope rules | ✓ VERIFIED | Phase edits describe the same package-only CPU boundary, request-local support, aggregate-only diagnostics, and later Metal/public-selection ownership. |
| `PLANS.md`, `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` | Aggregate Phase-70 ledger and requirement traceability | ✓ VERIFIED | BACKEND-01 and BACKEND-02 are mapped once with measured aggregate evidence; later Metal/config phases remain pending. |

`gsd-tools` was unavailable in this environment, so its artifact/key-link query was replaced with direct file, symbol, import, call-site, and runtime checks.

## Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `BeautyBackendContract.swift` | `BeautyCanonicalStillImage.swift` | `BeautyBackendRequest.canonicalImage` and canonical metadata/extent checks | ✓ WIRED | `BeautyCore` carrier is admitted and validated; Engine supplies the canonical carrier on the local-retouch path. |
| `BeautyBackendContract.swift` | `BeautyEffectPlan.swift` | `BeautyBackendRequest.plan` | ✓ WIRED | Every request carries the resolver-produced normalized plan; contract validates all effective unit/signed strengths. |
| `BeautyEngine.swift` | `BeautyCPUBackend.swift` | default `backendExecutor = BeautyCPUBackend()` and `execute` | ✓ WIRED | Public init selects CPU; package injection is test-only; all three facade request branches call the executor once. |
| `BeautyCPUBackend.swift` | `BeautyColorEffectPipeline.swift` | retained CPU/Core Image `apply` calls | ✓ WIRED | Pixel-buffer and both still-image variants delegate to retained CPU rendering; geometry remains downstream in that pipeline. |
| `run-no-skip-swiftpm.sh` | `check-backend-neutral-contract.sh` | preflight invocation before consumer/oracle stages | ✓ WIRED | Wrapper line 56 invokes the backend gate and aborts on failure. |
| `.planning/REQUIREMENTS.md` | `PLANS.md` | BACKEND-01/BACKEND-02 aggregate ledger entries | ✓ WIRED | Both IDs are present in requirements, plan frontmatter, and the completed ledger with measured counts. |

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `BeautyCPUBackend.swift` | `request.input`, `request.plan`, `request.selectedFaceSupport`, `request.canonicalImage` | Engine validation/resolution/canonicalization/detection plus retained Core Image pipeline | Yes | ✓ FLOWING |
| `BeautyCPUBackend.swift` | `BeautyBackendDiagnostics` | Output dimensions and Engine composition aggregate summary | Yes, bounded from request-local composition | ✓ FLOWING |
| `BeautyEngine.swift` | `backendResult.output` and public warnings/metrics/detection summary | Executor result plus resolver/detection-owned metadata | Yes | ✓ FLOWING |
| `BeautyBackendContract.swift` | request/result fields | Validated carriers/plans and transient support; no hardcoded user-visible payload | Yes | ✓ FLOWING |

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Contract, CPU executor, and facade routing | `swift test --package-path BeautySDK --filter 'BeautyEffectsTests.BeautyBackendContractTests\|BeautyEffectsTests.BeautyCPUBackendTests\|BeautyCoreTests.BeautyEngineBackendRoutingTests'` | 11 executed, 0 failures, 0 skipped | ✓ PASS |
| Backend mutation/static preflight | `bash scripts/check-backend-neutral-contract.sh --self-test` | `backend_neutral_contract_self_test_passed` | ✓ PASS |
| Backend live preflight and generated CPU gate | `bash scripts/check-backend-neutral-contract.sh` | `backend_neutral_contract_passed focused_tests=11 cpu_reference_tests=41` | ✓ PASS |
| Generated CPU reference oracles | `bash scripts/check-cpu-reference-oracles.sh` | `fixture_tests=15 geometry_color_tests=10 local_determinism_tests=16` (41 total) | ✓ PASS |
| Full normal SwiftPM suite | `swift test --package-path BeautySDK` | 713 executed, 0 failures, 8 environment-gated skips | ✓ PASS |
| SwiftPM build | `swift build --package-path BeautySDK` | Build complete, exit 0 | ✓ PASS |
| Archive-first SDK-only no-skip closeout | `bash scripts/run-no-skip-swiftpm.sh` | 8 opt-ins, 0 skipped, 0 failures; exit 0 | ✓ PASS |

The eight skips in the normal test command are existing environment-gated Vision/private-evidence tests. The archive-first no-skip command enabled all eight documented opt-ins and independently reported zero skips.

## Probe Execution

No `scripts/*/tests/probe-*.sh` probe is declared by either Phase-70 plan or present in the repository. Probe execution is not applicable; the phase’s declared executable checks were run directly above.

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| BACKEND-01 | `70-01-PLAN.md` | One backend-neutral request/result contract shares canonical input, support, privacy, alpha/extent, containment, collision, and failure-isolation semantics. | ✓ SATISFIED | Contract validation/tests pass; Engine retains canonicalization/detection/composition ownership; aggregate-only privacy mutation passes; full generated safety/determinism suite passes. |
| BACKEND-02 | `70-02-PLAN.md` | CPU remains complete/selectable/deterministic reference; backend choice does not alter public parameter/preset/algorithm schema. | ✓ SATISFIED | CPU backend and injected routing tests pass; generated 41-test oracle and full 713-test suite pass; static gate confirms 61 fields, five presets, 74 cases, and no public backend schema. |

No Phase-70 requirement is orphaned: both roadmap-mapped IDs appear in plan frontmatter and are traced above.

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| `.planning/ROADMAP.md` | 105, 129, 151, 183, 205–208 | Pre-existing `TBD` markers for later phases with plans not yet started | ℹ️ Info | These lines predate Phase 70 and explicitly describe future Phase 71–74 work; none is Phase-70 implementation debt. |
| `BeautyBackendContract.swift` | 381–384 | Comments mention “fallback”/“retry” to prohibit those behaviors | ℹ️ Info | This is an explicit terminal-error contract guard, not a stub or executable fallback. |

No modified Phase-70 source/test/script contains an untracked TODO/FIXME/XXX, placeholder implementation, empty user-visible handler, hardcoded empty data source, or console-log-only implementation. `git diff --check` passes.

## Human Verification Required

None. Phase 70 has no UI, visual approval, realtime/device, or external-service deliverable; the claimed behavior is covered by package tests, generated CPU oracles, static mutation gates, and the SDK-owned archive-first wrapper.

## Gaps Summary

No gaps found. The package-only request/result boundary exists, is substantively validated, is wired through both public process families, and carries real CPU output through the retained implementation. CPU reference behavior and request-local safety regressions pass independently. Public GPU/Metal configuration and Metal execution are explicitly not claimed here and remain assigned to later phases.

---

_Verified: 2026-08-16T03:34:49Z_
_Verifier: the agent (gsd-verifier)_

