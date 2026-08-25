# RELIABILITY.md

> Current SDK-only error, degradation, observability, performance-risk, archive,
> and recovery contract.

## Current Post-Archive Audit Status

The v1.17 archive at `afb04b4` is immutable historical evidence: its
Metal-available host ran focused parity `12/0/0` and the full gate `765/0/0`.
The current tree has repaired raw non-up/mirrored metadata routing (`53e8da1`),
unavailable-host parity accounting (`d29b90a`), and geometry point binding past
the 4 KiB inline limit (`556499a`). Geometry arrays now use a request-local
shared `MTLBuffer`, the scalar count remains bounded inline, and cleanup stays
deterministic.

The current gate distinguishes an available parity branch
(`focused_tests=13`, `parity_executed=1`) from an unavailable typed-coverage
branch (`parity_executed=0`); the latter may pass the mandatory host gate but is
never GPU parity success. The 2026-08-18 Metal-available branch recorded
`metal_available=1`, `metal_unavailable=0`, `parity_executed=1`,
`focused_tests=13`, and `unavailable_tests=0`. The archive-first closeout passed
at XCTest `776/0/0`, all eight opt-ins exactly once, and `skipped_tests=0`.
The bounded runtime contract is explicit: CPU owns local-retouch composition,
Metal transports that carrier; `.gpu` rejects non-opaque/unsupported RGB before
detection and emits named sRGB; still-image math matches the CPU oracle within
`max <= 2` / mean `< 0.75`; and one non-`Sendable` engine requires caller
serialization. Geometry safety
parity now derives the envelope and rendered request from one immutable
observation (`a577dd1`) and mutation-tests that provenance. Backend results now fail closed on
false alpha/extent flags and still-image extent-origin drift.

## 1. Posture

- Recoverable/environmental failures return typed errors or documented local
  degradation; production code does not crash for caller input or missing optional work.
- Every request recomputes support, effects, ownership, warnings, and metrics;
  no failed or prior request may contaminate the next valid request.
- Safe independent work continues when one support region/effect unit abstains.
- SwiftPM and SDK-owned scripts are the only active verification surfaces.
- Performance targets are engineering budgets, not claims; current v1.16 closeout
  adds no device/performance evidence.
- Physical-iPhone testing is optional post-SDK user evaluation and is never an
  implicit milestone gate, dependency, timeout, or blocker. Device feedback is
  supplemental and enters a follow-up only when actionable.

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
| R15 | Image-producing milestone evidence validates actual output pixels and metadata against deterministic exact/bounded oracles; process completion without output checks is failure. |
| R16 | Physical-device access or user feedback is not required for SDK milestone progress; a reproducible post-SDK finding gains an automated regression where possible, while device/product claims remain withheld without separate evidence. |

The automated image oracle applies contract-specific checks rather than one
global visual heuristic: dimensions/extent, orientation/mirroring, color space,
alpha, neutral identity, intended-region change, protected-region stability,
bounded error, repeated determinism, and typed failure are asserted where
relevant. Generated in-memory fixtures provide the default uniform path;
rights-approved local fixture gates may add algorithm-specific evidence through
the same scripts. Neither path requires a physical iPhone.

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
3. archive-aware v1.18 decision/baseline self-test followed by live gate;
4. backend/runtime/parity preflights, each completing before the next begins;
5. the public SwiftPM consumer;
6. generated CPU reference preflight;
7. private opt-in validation and the existing one-child hardened SwiftPM run
   with all eight opt-in environment variables; and
8. transcript reduction that proves each expected identity exactly once, zero
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

The v1.18 successor resolves Phase 75/78/79 inputs from explicit `--repo-root`
active-or-archived candidates. Missing, duplicate, non-file, unreadable, or
symlink artifacts return one normalized failure reason, including when invoked
outside the repository cwd. Its self-test and live baseline suites run
sequentially and finish before backend preflights and the complete SwiftPM
child; the wrapper mutation test rejects reordering, duplication, removal, or
background execution. Child output stays bounded and ephemeral.

The generated CPU preflight keeps its bounded logs temporary and emits only
fixture, geometry/color, and local-retouch/determinism counts. It does not open
portrait media or persist pixels, masks, support, coordinates, child output, or
locators; private/native-Vision skips remain environment-gated and non-mandatory.

Physical-iPhone evaluation is deliberately outside this mandatory chain. A
missing device, a slow manual run, or pending user feedback must not be encoded
as a failed prerequisite or prevent the next plan. If later feedback exposes a
repeatable defect, record it in `PLANS.md`, reproduce it with the smallest
deterministic SwiftPM/script fixture, and then apply the normal fix/verification
workflow. Without separately authorized device work, do not infer performance,
thermal, battery, endurance, commercial-quality, packaging, shipping, launch,
or release-readiness evidence from the automated gate.

The public `BeautyResultConcurrencyTests` suite currently passes 3/0/0. The
The v1.16 historical mandatory wrapper passed 702 tests with zero failures and zero
skips. The Phase-71 archive-first wrapper historically passed 728 tests with zero
failures and zero skips. These are aggregate SwiftPM checks; child output and generated
outputs remain temporary, and the conditional result contract does not make
framework-backed or otherwise non-sendable payloads transferable.

The historical Phase-73 archive-first wrapper passed 753 tests with zero failures
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

## Phase 74 Historical Parity and Closeout Reliability

Repeated identical generated requests are byte-deterministic and finite for CPU
and available Metal. Bounded interleaved requests compare by request identity,
retain immutable backend policy, and leave runtime resources at zero. Safety
cases require exact alpha/protected/outside bytes, CPU-owned containment,
collision summaries, no-face/degraded no-ops, and local rejection without
erasing eligible siblings.

`check-backend-parity.sh` fails closed under mutations and the archive-first
wrapper invokes it exactly once after configuration and before all child stages.
Archived evidence is focused `12/0/0`, full `765/0/0`, eight opt-ins once, zero
skips/failures, and separate `metal_available=1` / `metal_unavailable=0`.
The repaired gate credits parity only on the available branch with
`parity_executed=1`; unavailable Metal is terminal `.metalUnavailable`, reports
`parity_executed=0`, and provides no retry, CPU fallback, or GPU parity credit.
The bounded contract above also means no transparent-input, end-to-end GPU
local-retouch, shared-instance parallel, device, performance, commercial,
packaging, shipping, launch, or release-readiness claim follows.

The current bounded closeout evidence is backend-neutral `24/0/0`, Metal
runtime `42/0/0`, Metal feature `34/0/0`, configuration `19/0/0`, CPU reference
`41/0/0`, parity `13/0/0`, and full XCTest `776/0/0`. These results close F-01
through F-10 while retaining the excluded product claims.

## Phase 76 Per-Eye Support Reliability

The package-only upper-eyelid support seam reuses one mapped Vision observation
and performs one semantic-owner call per request. Missing or malformed support
is isolated to the smallest eye region; the peer remains independently
eligible, while an unsupported eye returns source-exact bytes. Confidence,
finite dimensions, hard-envelope containment, unique pixel ownership, and
typed pose/occlusion reasons are checked before downstream composition.

The existing `CoordinateMapper` remains the only orientation/mirror conversion
boundary. The composition handoff uses the immutable canonical source and
returns overlap claims to that source with an aggregate collision count. This
phase proves package-host mechanics and privacy only; no genuine efficacy,
device, performance, commercial, packaging, shipping, launch, or
release-readiness claim follows.

## Phase 77 Deterministic Editor Reliability

The package-only editor validates finite strength, source layout, per-eye
support, unique/in-bounds ownership, and bounded channel deltas before it emits
proposals. A neutral request and every invalid or unsupported outcome publish
no edits; the valid eye remains independent from a rejected peer. Repeated
requests over the same canonical source are deterministic and preserve the
exact source residual, alpha, extent, and metadata.

`BeautyLocalRetouchCompositionOwner` remains the terminal source of truth for
containment, protected/exterior bytes, and overlap-to-source collisions. The
Phase 77 focused suite is 7/0/0, its boundary checker rejects 8/8 mutations,
and the archive-first full gate is 797/0/0 with zero skips. These are SDK
mechanics only; genuine efficacy, device, performance, commercial, packaging,
shipping, launch, and release-readiness claims remain outside the result.

## Phase 78 Candidate Decision Reliability

The candidate gate delegates evidence admission to the frozen Phase 75
evaluator and preserves typed missing, incomplete, rights, review, and privacy
failures. Metadata-only manifests are deterministic mechanics evidence and
always resolve to `mechanics-only-not-promotion`. The Phase 77 deterministic
editor remains the baseline; an optional additive comparator is terminally
rejected unless exact rights, bounded-map, all-safety, and superiority checks
pass.

The focused decision suite is 6/0/0, the evaluator self-test records 12 checks
and 8 mutation rejections, and the Phase 78 boundary checker rejects 8/8
mutations. The archive-first full gate is 797/0/0 with zero skips. No genuine
efficacy or naturalness, device, commercial, packaging, shipping, launch, or
release-readiness claim follows without a supplied rights-approved bundle.

## Phase 79 Failing-Branch Reliability

The closeout consumes the single Phase 78 decision and fails closed before any
public activation. Exact inventories, package/resource/SPI absence, taxonomy
status, source-diff protection, canonical metadata, alpha, CPU authority,
explicit GPU selection, and terminal `.metalUnavailable` behavior are checked
with isolated mutations. Existing request-local deterministic recovery remains
the authority for output and failure behavior.

The final archive-first gate is the only milestone closeout authority. A green
SDK run does not convert the mechanics candidate into genuine efficacy,
naturalness, device, commercial, packaging, shipping, launch, or
release-readiness evidence. The Phase-79 checker passes live mode and rejects
8/8 isolated mutations; the final archive-first gate passes 797/0/0 with all
eight opt-ins exactly once and zero skips.

After archival, `scripts/check-v1-18-decision-binding.py` replaces—not mutates—
that historical checker. It consumes the Phase-78 machine program and Phase-75
canonical contract, validates five resolved Phase-79 contract artifacts, binds
the deterministic-editor source/evidence digests and ten-test attestation, and
rechecks exact 61/5/74 absence. Seven artifact-resolution checks cover active,
archived, ambiguous, missing, direct/parent symlink, and outside-cwd cases. Failures expose
only normalized reason identifiers; neither successful nor failed runs persist
child transcripts or private paths.

## v1.19 Phase 80 Candidate-v3 Remediation Reliability

The per-eye resolver now separates `missingEyeEnvelope`,
`missingEyebrowEnvelope`, `implausibleBrowEyeGap`, ambiguous order, invalid
weight, and existing semantic/pose/occlusion failures. One rejected side cannot
suppress a valid peer, and an absent semantic owner still returns two typed
source-exact no-ops. Feathered pixel enumeration and validation are bounded to
the permitted envelope rather than scanning or retaining arbitrary payloads.

Candidate v2's generated tests passed but its first genuine automated run
stopped at 14/19 rows: real-image neighboring corrections reached an aggregate
maximum jump of 30 against 5, and texture retention fell below the frozen
bound. No v2 image entered human review.

The candidate-v3 editor validates source layout, finite strength, unique
in-bounds weighted pixels, one whole-eye clipping bound, and maximum channel
delta before emitting proposals. The pre-feather contour is one non-positive
equal-RGB scalar for every accepted pixel; deterministic Q16 ownership supplies
the only spatial falloff. Repeated requests produce identical proposals,
summaries, and bytes. Generated pixel tests require target change, a single
correction sign, exact source channel and spatial-detail differences before
feathering, source-exact exterior/protected rows, exact alpha/extent/metadata,
adjacent correction continuity, texture retention at or above `0.98`, and the
existing `±16` safety cap.

The candidate-v2 remediation verification was focused `24/0/0`, full SwiftPM `803/0/8`
(the eight established opt-ins remain disabled in a plain run), SDK-only
post-archive boundary pass, and diff-hygiene pass. This does not make a genuine
efficacy, public API, device, commercial, packaging, shipping, launch, or
release-readiness claim.

## v1.19 Phase 80 Candidate-v4 Relief Analysis Reliability

Candidate v4 replaces the invalidated uniform contour with deterministic
request-local relief analysis. It validates canonical RGBA8 layout, finite
strength, unique in-bounds support, bounded Q16 weights, a nondegenerate patch,
at least six boundary anchors, a solvable affine plane, and a nonempty central
region. Any failed precondition rejects only that eye and emits no proposal.

The box-filter radius is derived from the admitted patch and capped at `24`.
Two patch-local integral arrays make every sample lookup constant-time; no
whole-image cache, prior-request state, external model, network, or retry path
exists. Correction magnitudes are finite by construction, clipped to `±16` and
RGB headroom, and composed once against immutable source. Repeated generated
requests produce byte-identical proposals and output.

The candidate-v4 focused group passes `30/0/0`. It covers convex relief
compression, rejection of planar lighting and crease-only detail, production
semantic admission, peer isolation, overlap-to-source, protected/exterior
bytes, color/alpha/extent/metadata preservation, smooth feathering, and
determinism. The plain full SwiftPM run passes `805/0/8`; the eight skips are the
established opt-in suites and are not milestone closeout evidence. Genuine
efficacy and naturalness remain pending the separately frozen private gate.

## v1.19 Learned Upper-Eyelid Reliability Contract

The candidate-v4 private matrix invalidated its generated reliability premise:
repeatable genuine runs failed applicability, boundary continuity, and minimum
relief before review. No v5 threshold retune is allowed. The replacement seam
has an explicit unavailable state and emits no proposal until one validated,
checksum-bound learned predictor exists.

Each per-eye prediction validates fixed tensor dimensions, finite confidence
and uncertainty, calibrated admission, alpha containment, zero protected and
boundary flow, bounded mapped displacement, smooth gradients, positive local
Jacobian, bounded low-frequency tone, and independent-eye ownership. Invalid
resource, compile, inference, output, crop, mirror, color, or mapping state
fails only that eye to immutable source without heuristic or CPU-proxy fallback.
The predictor resource is loaded once per owning engine/resource boundary;
request crops, tensors, outputs, and composition state are never shared between
requests.

Before private review, source-model and converted Core ML output/decision parity
must pass on representative and threshold-boundary cases. Generated SwiftPM
oracles cover invalid/missing models, malformed outputs, protection, strength-
zero identity, orientation/mirror/color/alpha/extent, determinism, cancellation,
recovery, and public absence. Genuine efficacy still requires a frozen unseen
private matrix to pass twice and blinded original-detail review; generated tests
cannot supply that result.

Plan 80-20 passes `8/0/0` learned-prediction tests and `23/0/0` across all
upper-eyelid suites. It covers no-model, invalid request before inference,
protected overlap, envelope escape, abstention, confidence, uncertainty, side
mismatch, missing/malformed samples, non-zero boundary flow, excessive flow or
tone, discontinuity, local fold-over, inference failure, and independent-peer
recovery. The plain full package passes `813/0/8`; the eight existing opt-ins
remain disabled in a plain development run and this is not final closeout.
