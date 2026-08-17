# RELIABILITY.md

> Current SDK-only error, degradation, observability, performance-risk, archive,
> and recovery contract.

## 1. Posture

- Recoverable/environmental failures return typed errors or documented local
  degradation; production code does not crash for caller input or missing optional work.
- Every request recomputes support, effects, ownership, warnings, and metrics;
  no failed or prior request may contaminate the next valid request.
- Safe independent work continues when one support region/effect unit abstains.
- SwiftPM and SDK-owned scripts are the only active verification surfaces.
- Performance targets are engineering budgets, not claims; current v1.16 closeout
  adds no device/performance evidence.

## 2. Core Invariants

| ID | Invariant |
| --- | --- |
| R1 | Public failures use stable, redacted `BeautyError` cases. |
| R2 | Invalid input is rejected before resource, detection, allocation-heavy, or render work. |
| R3 | Default/zero-strength input is deterministic and inert. |
| R4 | No-face/missing/malformed support removes only dependent work while safe siblings continue. |
| R5 | Request-local support, masks, proposals, composition, and diagnostics are cleared on success and throw. |
| R6 | Repeated, valid-invalid-valid, reset, and independent parallel-engine tests recover without stale state. |
| R7 | Metrics/logs are optional, aggregate, bounded, and privacy-safe. |
| R8 | Generated output is disposable, ignored, bounded, and never required as a tracked baseline. |
| R9 | Archive corruption/restoration/static-boundary failure stops the mandatory suite before SwiftPM execution. |
| R10 | The no-skip parser accepts one child only and rejects failure, skip, ambiguity, oversize, or zero execution. |
| R11 | Renderer success requires exact requested/succeeded/failed/skipped reconciliation and every requested persisted output to be non-empty, decodable, and dimension-preserving. |
| R12 | Compiled CLI process coverage is bounded and exercises independent render/encode failures, typed non-zero diagnostics, and clean temporary recovery. |
| R13 | Generated CPU oracle preflight executes nonzero focused suites with zero generated skips before optional fixtures or the full SwiftPM child. |
| R14 | `BeautyResult` crosses a concurrency boundary only for `Output: Sendable`; the public test proves field-preserving transfer and the boundary guard rejects an unconditional generic declaration. |

## 3. Error and Degradation Policy

| Condition | Required behavior |
| --- | --- |
| invalid extent/orientation/limit/alpha | payload-free `.invalidInput` before expensive work |
| unsupported format/color | payload-free `.unsupportedPixelFormat` or the documented typed conversion path |
| unknown resource ID | typed redacted resource error; do not treat ID as path |
| no face | keep supported face-independent work; skip support-dependent work |
| malformed support | abstain at the smallest region/feature unit; valid peer/sibling survives |
| stale/reused support | apply the field/domain-specific documented zero or reuse scale without prior-vector carryover |
| provider-empty result | remove it from final strengths, domains, totals, warnings, metrics, points, and dispatch |
| composition collision | preserve original source pixel |
| optional private fixture absent | default suite may record the documented skip; mandatory no-skip gate fails unless opt-in executes |

Internal framework details, paths, pixels, masks, or coordinates never enter public
error associated values.

The SDK-owned renderer treats its CLI boundary as untrusted input. It rejects
unknown flags/cases/backends, missing values, duplicate scalar arguments,
missing/invalid input or output directories, empty or undecodable images, and
case-insensitive duplicate output stems before crediting work. It preserves the
compatible 74-case inventory and accepts only the CPU token in v1.16; explicit
GPU is rejected until v1.17. A requested matrix unit is credited only after an
atomic PNG write, non-empty regular-file check, ImageIO reopen, and exact input
dimension check. Missing, partial, failed, skipped, or report-write output can
never return zero.

## 4. Current Processing Reliability

Still-image local retouch follows one deterministic request sequence:

```text
validate/canonicalize
→ one detection/mapping request when demanded
→ request-local support/context
→ provider units from immutable original pixels
→ one ownership/composition transaction
→ output or typed error
```

Affected-eye/feature failure remains local. Teeth and sclera share the request
owner but not evidence, support, admission, or promotion authority. Pixel-buffer
processing and `reset()` create no local-retouch request work.

The v1.16 historical geometry implementation was CPU/Core Image-backed and did
not establish GPU execution. The current v1.17 route keeps CPU as the permanent
reference and selects GPU only through the public configuration contract below;
it never uses a silent fallback or treats configuration coverage as parity.

Phase 70 freezes the shared package-only backend contract before CPU routing
changes. Admission validates finite positive dimensions, supported format,
normalized strengths, explicit metadata, canonical carrier/extent consistency,
and bounded composition aggregates before executor work. The request retains
selected support only for the synchronous call. Result publication validates
matching dimensions and `CIImage`/pixel-buffer kind; diagnostics carry only
alpha/extent flags and bounded unit, failure, collision, and changed counts.
CPU remains the permanent reference. Phase 71–72 own the package Metal
resources/passes, and Phase 73 owns the public `.cpu`/`.gpu` selection; typed
executor failures do not trigger retry or silent fallback. Phase 74 remains
the parity/closeout owner.

## Phase 71 Metal Runtime Reliability Contract

`BeautyRender.BeautyMetalRuntime` owns the package-internal device, command
queue, pipeline, and request-local texture/buffer/command lifetime. The command queue
is created and retained only by this runtime instance.
package-only `BeautyEffects.BeautyMetalBackend` validates dimensions and bytes,
creates bounded resources, encodes the retained identity transaction, waits
for command completion, inspects terminal status, materializes the matching
output, and releases all request resources on success and every error path.

No host device is an explicit `.metalUnavailable` terminal error. It is not a
GPU success and never causes CPU fallback or retry. Queue, encoder, texture,
buffer, and command cleanup is deterministic and aggregate counters must end
with no active request resources. Diagnostics remain fixed aggregate status;
support, raster, texture, framework, geometry, and path details are never
retained. The runtime has no application, UI, or capture lifecycle dependency.

The preflight runs focused `BeautyMetalRuntimeTests` and
`BeautyMetalBackendTests` with the existing backend contract/CPU tests,
requires nonzero execution with zero failures/skips, and reports separate
`metal_available`/`metal_unavailable` status. Phase 72 owns feature passes,
Phase 73 owns public `.cpu`/`.gpu` configuration, and Phase 74 owns generated
parity/no-skip closeout. CPU remains the reference; the Phase-71 gate claims
no simulator/physical-device behavior, performance budget, commercial,
packaging, shipping, launch, or release readiness.

## 5. Archive Verification and Recovery

The active repository relies on two committed historical archives. Verification
must check code-owned ZIP/manifest digests, exact inventories/counts, compressed,
per-entry, total-uncompressed and ratio bounds, normalized safe entries, streamed
content hashes, and fresh temporary extraction before any historical use.

Recovery policy:

1. A missing, corrupt, symlinked, unsafe, or digest-mismatched bundle stops the
   gate immediately without partial extraction or SwiftPM execution.
2. Recover the exact committed artifact from trusted Git history; never repair by
   editing its manifest/digest or substituting another bundle.
3. Rerun verification for both archives.
4. Use `archive-legacy-ui.py restore` only with a nonexistent destination under a
   fresh private outside-repository temporary directory; never extract first with
   a general archive tool.
5. Rerun the post-archive scanner; restored repository roots are failure.

The historical retirement transaction was digest-bound and exact-target. A failure
before its irreversible point restored both staged roots; the completed current
state recovers from archives and does not rerun retirement.

## 6. Mandatory No-Skip Gate

`scripts/run-no-skip-swiftpm.sh` must execute in this order:

1. archive verification;
2. post-archive SDK-only boundary scanner;
3. the public SwiftPM consumer;
4. generated CPU reference preflight;
5. private opt-in validation and the existing one-child hardened SwiftPM run
   with all eight opt-in environment variables; and
6. transcript reduction that proves each expected identity exactly once, zero
   failures, zero skips, and nonzero all-tests execution.

Archive and scanner output is short aggregate status. The private test child may
write its bounded output only through a streaming limiter capped at 16 MiB and
200,000 lines; overflow terminates the child. The temporary file is removed on
exit, and the gate emits no private location or raw child output as durable
evidence. Exact parsing requires one nonzero zero-failure XCTest `All tests`
aggregate, and—when Swift Testing starts—exactly one passed Swift Testing
aggregate. XCTest and Swift Testing skip/disabled events both fail.

Any preflight failure returns non-zero and prevents test execution. Any malformed,
missing, ambiguous, failed, skipped, oversized, or zero-test transcript returns
non-zero even if the child process exit status is otherwise zero.

The generated CPU preflight keeps its bounded logs temporary and emits only
fixture, geometry/color, and local-retouch/determinism counts. It does not open
portrait media or persist pixels, masks, support, coordinates, child output, or
locators; private/native-Vision skips remain environment-gated and non-mandatory.

The public `BeautyResultConcurrencyTests` suite currently passes 3/0/0. The
The v1.16 historical mandatory wrapper passed 702 tests with zero failures and zero
skips. The Phase-71 archive-first wrapper historically passed 728 tests with zero
failures and zero skips. These are aggregate SwiftPM checks; child output and generated
outputs remain temporary, and the conditional result contract does not make
framework-backed or otherwise non-sendable payloads transferable.

The current Phase-73 archive-first wrapper passes 753 tests with zero failures
and zero skips, executes all eight opt-ins exactly once, and records separate
`metal_available=1` / `metal_unavailable=0` classifications.

The compiled `BeautyExampleRenderer` Process matrix uses fresh temporary
SwiftPM/build and fixture roots, concurrent bounded stdout/stderr capture, and
finite execution limits. It independently injects render and encode failures
through an executable-internal seam, asserting typed non-zero results, no
credited PNG, and reconciled `1/0/1/0` reports. Temporary roots are removed on
success and failure; no child output or path is retained as product
evidence.

## 7. Observability

Allowed: fixed subsystem/category/event/error codes; request-local counts, bounded
timings, caps/scales, active/skipped domain counts, and output dimension buckets.

Forbidden: image/mask bytes, paths, fixture locations, support points, bounding
boxes, pupils, tooth/eye geometry, candidate colors, rights/reviewer detail, raw
JSON, raw framework errors, and raw child output.

Logs are disabled or error-level by default and never required for correctness.
Per-request arrays/caches must be bounded and released at request completion.

## 8. Performance and Resource Boundaries

- Validate dimensions and checked byte/pixel multiplication before allocation.
- Reuse contexts/resources where the existing implementation specifies reuse;
  request-owned pixel/support storage must not become engine-global state.
- Composition owners enforce unit/capacity budgets before raster/mask allocation.
- Generated/private fixture files have explicit bounded size and inventory checks.
- No current package run establishes target-device frame rate, memory, thermal,
  endurance, or optimized latency.

## 9. Verification

```bash
swift test --package-path BeautySDK
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/check-cpu-reference-oracles.sh
git diff --check
bash scripts/run-no-skip-swiftpm.sh
```

Passing these commands establishes bounded SDK-core correctness and recovery only.
Commercial approval, packaging, shipping, launch, and release readiness remain
separate future scopes.

## Phase 72 Feature-Pass Reliability

The local-retouch carrier is composed once from the immutable source, then
consumed by Metal before color and geometry. This keeps local-retouch-only
bytes deterministic and makes mixed requests recoverable without re-running a
provider. Owner-local rejection preserves valid siblings and collision pixels
remain source bytes. A failed Metal command is terminal, publishes no partial
output, and releases all request resources; no retry or CPU alternate path is
introduced. The focused feature preflight runs after runtime authorization and
before consumer/oracle/opt-in/full-child stages, with bounded logs and
zero-failure/zero-skip accounting. Phase 73 owns public availability policy;
Phase 74 owns parity closeout.

## Phase 73 Backend Selection Reliability

`BeautyConfiguration` is immutable and defaults to `.cpu`, including when a
legacy Codable payload omits `renderBackend`. `BeautyBackendFactory` selects
the package executor once and propagates that policy request-locally: explicit
CPU requests use the permanent reference, while explicit GPU requests either
complete through the Metal runtime or terminate with typed
`.metalUnavailable`. The unavailable path publishes no output, does not retry,
and never invokes CPU fallback. Package-only injection is test-only. Generated
parity, determinism, and cross-backend safety remain Phase 74 work; this phase
does not claim UI/Demo, simulator/device, performance, commercial, packaging,
shipping, launch, or release readiness.

## Phase 74 Parity and Closeout Reliability

Repeated identical generated requests are byte-deterministic and finite for CPU
and available Metal. Bounded interleaved requests compare by request identity,
retain immutable backend policy, and leave runtime resources at zero. Safety
cases require exact alpha/protected/outside bytes, CPU-owned containment,
collision summaries, no-face/degraded no-ops, and local rejection without
erasing eligible siblings.

`check-backend-parity.sh` fails closed under mutations and the archive-first
wrapper invokes it exactly once after configuration and before all child stages.
Fresh evidence is focused `12/0/0`, full `765/0/0`, eight opt-ins once, zero
skips/failures, and separate `metal_available=1` / `metal_unavailable=0`.
Unavailable Metal is terminal `.metalUnavailable`; no retry, CPU fallback,
device, performance, commercial, packaging, shipping, launch, or
release-readiness claim follows.
