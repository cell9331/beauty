---
phase: 67-swiftpm-consumer-and-cli-validation-contract
verified: 2026-08-14T06:53:28Z
status: passed
score: 5/5 must-haves verified
overrides_applied: 0
---

# Phase 67: SwiftPM Consumer and CLI Validation Contract Verification Report

**Phase Goal:** SDK integrators can validate public `BeautySDK` consumption and deterministic processing entirely through SwiftPM and the SDK-owned command line.
**Verified:** 2026-08-14T06:53:28Z
**Status:** passed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | A clean external Swift package can depend on the local `BeautySDK` package, import only the public product, and build without `@testable`, Demo, Xcode-project, or internal-target access. | ✓ VERIFIED | `IntegrationTests/BeautySDKConsumer/Package.swift` has exactly one `../../BeautySDK` dependency and one `.product(name: "BeautySDK", package: "BeautySDK")`; fresh static self-test, `dump-package`, clean-scratch build, and runtime checker passed. |
| 2 | The clean consumer can generate a synthetic image, submit a neutral request through the public facade, and verify successful dimension-preserving output. | ✓ VERIFIED | Consumer source generates a 4×3 opaque named-sRGB RGBA8 pattern, calls public `BeautyEngine.processResult`, renders through named-sRGB Core Image, and compares exact dimensions and all 48 RGBA bytes; `swiftpm_consumer_check_passed`. |
| 3 | A maintainer can list the exact renderer cases and run an explicit input/case/supported-CPU-backend selection into an explicit output directory with reproducible results. | ✓ VERIFIED | Compiled `BeautyExampleRenderer` lists ordered unique 74 cases with `beauty.example-renderer.cases.v1`; Process tests run explicit `--input`, `--output`, `--case`, `--backend cpu`, and `--no-watermark` twice with byte-identical PNG/report results. |
| 4 | Each CLI run produces a machine-readable aggregate report that identifies requested, succeeded, failed, skipped, input, output, and case identities without exposing private landmark or mask data. | ✓ VERIFIED | `RendererReport` uses the versioned `beauty.example-renderer.report.v1` schema, reconciles counts, and exposes bounded identities; Process tests decode success/failure reports and privacy-scan stdout, stderr, reports, help, and case-list output. |
| 5 | Invalid inputs, unknown cases, decode/write failures, and missing requested outputs produce typed diagnostics and a non-zero exit, while successful generated outputs stay in an ignored/reproducible location. | ✓ VERIFIED | Actual compiled Process matrix covers missing/empty/corrupt inputs, unknown cases/flags/backends, duplicate arguments, missing/file/symlink output roots, collisions, report failures, and independent `render`/`encode` seams; every required failure is typed/nonzero and successful outputs are temporary/generated. |

**Score:** 5/5 truths verified

## Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `IntegrationTests/BeautySDKConsumer/Package.swift` | Independent public-product local-path manifest | ✓ VERIFIED | Exists, substantive, resolves one local package and one public product, and is compiled by the checker. |
| `IntegrationTests/BeautySDKConsumer/Sources/BeautySDKConsumer/main.swift` | Generated-input public-facade consumer | ✓ VERIFIED | Exists, imports only `BeautySDK` plus permitted Apple modules, generates input, calls `processResult`, and verifies exact output bytes. |
| `scripts/check-swiftpm-consumer.sh` | Static boundary plus clean-scratch runtime gate | ✓ VERIFIED | Exists, has mutation/self-test and bounded cleanup/build/runtime checks; invoked by the mandatory gate. |
| `BeautySDK/Sources/BeautyExampleRenderer/RendererCLIContract.swift` | Strict CLI, diagnostic, case-list, and report contracts | ✓ VERIFIED | Exists and is used by the real executable; versioned sorted-key Codable contracts and typed codes are exercised by Process tests. |
| `BeautySDK/Sources/BeautyExampleRenderer/RendererExecution.swift` | Public-facade matrix execution and persisted-output validation | ✓ VERIFIED | Exists and is called by the executable; stages outputs, calls public `BeautyEngine.processResult`, reopens PNGs, reconciles counts, and writes reports. |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | Exact renderer catalog and executable entry | ✓ VERIFIED | Real binary exposes the exact ordered 74-case catalog and routes through the shared runner; no public backend API was added. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift` | Compiled-binary CLI-03 matrix | ✓ VERIFIED | Foundation `Process` builds/resolves only the compiled executable and covers success, privacy, invalid matrix, collisions, replacement, duplicate scalars, and both failure seams. |
| `scripts/run-no-skip-swiftpm.sh` | Archive → boundary → consumer → complete SwiftPM gate | ✓ VERIFIED | Script invokes the live consumer before the sole complete SwiftPM child and passed the fresh full gate. |

## Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `IntegrationTests/BeautySDKConsumer/Package.swift` | `BeautySDK/Package.swift` | Local path dependency and public product declaration | WIRED | Manifest inspection and `swift package dump-package` both verified the exact local dependency/product graph. |
| `BeautySDKConsumer/main.swift` | `BeautyEngine.processResult` | Generated neutral CIImage request | WIRED | Source and live clean-scratch checker verified the public facade call and exact output. |
| `scripts/run-no-skip-swiftpm.sh` | `scripts/check-swiftpm-consumer.sh` | Fail-closed pre-test invocation | WIRED | Script ordering and fresh `no_skip_swiftpm_consumer_verified` output confirm the link. |
| `main.swift` | `RendererExecution.swift` | `RendererCLI.run` dispatch for the actual executable | WIRED | Compiled binary `--help`, `--list-cases`, success, and failure behavior passed. |
| `RendererExecution.swift` | `BeautySDK` | Public `BeautyEngine.processResult` call | WIRED | Source trace plus actual output and failure-seam Process tests passed. |
| `RendererExecution.swift` | `beauty-example-renderer-report.json` | Sorted-key report write after output/count validation | WIRED | Success and reconciled failure reports were decoded from the generated output roots. |
| `BeautyExampleRendererProcessTests.swift` | compiled `BeautyExampleRenderer` | SwiftPM build and Foundation `Process` | WIRED | Fresh focused run executed 7 Process tests with zero failures. |

## Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `BeautySDKConsumer/main.swift` | `expectedBytes` → `input` → `result.output` → `RenderedImage.bytes` | Swift-generated RGBA bytes → public facade → named-sRGB CIContext | Yes; exact 4×3/48-byte equality | ✓ FLOWING |
| `RendererExecution.swift` | `imageURLs` → `inputImage` → `result.output` → persisted PNG → reopened `CGImage` | Enumerated caller input files → public facade → atomic PNG → ImageIO validation | Yes; output dimensions and non-empty decode are checked | ✓ FLOWING |
| `RendererExecution.swift` | `units` → `RendererReport` counts/identities | Per-input×case success/failure records, including render/encode seams | Yes; `requested = succeeded + failed + skipped` is enforced | ✓ FLOWING |
| `BeautyExampleRendererProcessTests.swift` | Process stdout/stderr/files | Actual compiled binary and generated temporary fixtures | Yes; independent Codable mirrors observe process behavior | ✓ FLOWING |

## Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Retained archive integrity | `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui` | Both retained ZIP digests verified | ✓ PASS |
| SDK-only active boundary | `bash scripts/check-sdk-only-boundary.sh --post-archive` | `POST-ARCHIVE SDK BOUNDARY PASSED` | ✓ PASS |
| External public consumer | `bash scripts/check-swiftpm-consumer.sh` | `swiftpm_consumer_check_passed` | ✓ PASS |
| Consumer and transcript mutation gates | `bash scripts/check-swiftpm-consumer.sh --self-test`; `bash scripts/run-no-skip-swiftpm.sh --self-test`; `python3 scripts/check-no-skip-transcript.py self-test` | All self-tests passed | ✓ PASS |
| Renderer source/output contract | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` | 24 tests, 0 failures | ✓ PASS |
| Compiled renderer process contract | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyExampleRendererProcessTests` | 7 tests, 0 failures, 0 skips | ✓ PASS |
| Mandatory all-opt-ins SwiftPM gate | `bash scripts/run-no-skip-swiftpm.sh` | 658 executed, 0 failures, 0 skips, 8 opt-ins | ✓ PASS |
| Diff hygiene | `git diff --check` | No whitespace errors | ✓ PASS |

## Probe Execution

No phase-declared or conventional `scripts/*/tests/probe-*.sh` probes were found; probe execution was not applicable.

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| SPM-01 | 67-01 | External package imports/links only public `BeautySDK` through local SwiftPM dependency | ✓ SATISFIED | Manifest/source static classifier, `dump-package`, clean build, and live consumer check. |
| SPM-02 | 67-01 | Generated synthetic neutral request verifies dimension-preserving public-facade result | ✓ SATISFIED | 4×3 generated RGBA input and exact 48-byte output comparison. |
| CLI-01 | 67-02 | Deterministic SDK-owned CLI selects input/case/CPU backend/output and discovers exact cases | ✓ SATISFIED | Compiled 74-case list and explicit CPU render Process runs. |
| CLI-02 | 67-02 | Versioned machine-readable aggregate report with bounded identities and reconciled counts | ✓ SATISFIED | Decoded success/failure reports, sorted-key contract, privacy assertions, and count checks. |
| CLI-03 | 67-03 | Typed nonzero failures and reproducible generated outputs for invalid/incomplete processing | ✓ SATISFIED | 7-test compiled Process matrix plus fresh full gate; render/encode seams and output/report collisions included. |

No Phase 67 requirements are orphaned or duplicated in the roadmap/plan mapping.

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| — | — | None in Phase 67 implementation, test, script, or owner files | — | No unreferenced debt markers, placeholder implementation, empty data path, or public/UI/Metal scope drift found. |

## Human Verification Required

None. Phase 67 is a SwiftPM/CLI contract and its observable behaviors are covered by compiled code, generated fixtures, process assertions, and repository-owned gates. No visual, device, UI, or external-service claim is made.

## Gaps Summary

No gaps found. The five roadmap success criteria and all five Phase 67 requirements are verified against the current codebase. The fresh archive-first SDK-only boundary, external public consumer, focused renderer suites, and all-opt-ins no-skip SwiftPM gate pass. This verification does not claim public GPU/Metal selection, UI/Demo behavior, simulator/device coverage, performance/commercial approval, packaging, shipping, launch, or release readiness.

---

_Verified: 2026-08-14T06:53:28Z_  
_Verifier: the agent (gsd-verifier)_
