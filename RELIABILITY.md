# RELIABILITY.md

## 2026-09-26 FACE-01 hair-row recovery

The source-edge search now rejects a second edge at least eight columns away
when its contrast reaches 40% of the strongest. This guards a dark hair
occlusion whose return edge is weaker than its outer edge. The rejected row is
left source-exact; independently supported neighboring rows continue through
the bounded smoothing path. The focused generated input initially reproduced
90 changed pixels on the hair rows and now has zero. The full local refiner
class, public facade orientation/recovery tests, and frozen generated portrait
oracle pass. No extra allocation, retained state, or diagnostic pixel content
was introduced.

## 2026-09-26 skin-texture bounds and recovery

The spatial stage samples immutable request-local RGBA8 pixels within a 5×5
footprint and writes each result once. It checks input dimensions and byte
products before allocating for the direct CI path; the public facade still
rejects invalid extents and configured pixel-limit violations with typed
`BeautyError.invalidInput`. Nonopaque centers or neighboring pixels, strong
color discontinuities, and borders are source-exact for texture work. The
neutral plan avoids this stage. Identical input and plan produce identical
output; a failed request does not retain a prior neighborhood or output.

This CPU-owned stage also runs when Metal is selected, before retained GPU
passes. Its worst-case work is 25 neighbor samples per pixel and it can hold
both source and result rasters while Core Image or the backend owns other
buffers. No physical-device latency, peak-memory, sustained-load or power
measurement has been made for this new behavior. Large-image throughput and
additional non-face low-contrast textures remain follow-up quality risks.

## 2026-09-26 FACE-01 lower-cheek recovery and bounds

The follow-up robustness gate verifies a dark background rough-positive,
coherent weak contrast, short opaque occlusion, and conflicting rowwise
brightness directions. The dark-background edge can use the same bounded
correction as the light-background edge. Weak or contradictory direction
evidence fails the whole side closed; a short double-edge occlusion remains
source-exact on its rows without suppressing supported neighbors. Tests keep
center/background, alpha, and repeatability assertions. No per-row pixels or
observed coordinates are logged.

The shared still-image refiner can scan a bounded 48-column neighborhood
around each observed lateral row when Vision support is offset from the
visible cheek. It admits the wider pass only with a coherent strong source
edge across at least two thirds of the lower-cheek interval; competing
outward edges on many rows make that side source-exact. If the wider pass is
unavailable, the previous fractional correction remains available. The wider
pass caps displacement at six pixels and its band radius at 32 columns, reads only
immutable opaque source samples, preserves alpha, and never retains image
data. The upper ear/temple junction is excluded from wide correction.

In-memory positive, smooth-negative, competing-edge, and transparent-row
regressions exercise these branches. The frozen generated portrait oracle
exercises output direction, containment, protection, neutral identity, repeat,
and alpha through the public CPU renderer. Existing tests cover typed
invalid-support recovery and CPU/Metal still-image use of the shared step.
These host results do not qualify device latency, memory, or sustained load.

## Current image-fixture recovery policy (2026-09-24)

The complete no-skip wrapper now permits a generated Vision fixture file name
and generated teeth/sclera bundle overrides. A missing, unreadable, or
unsuitable replacement fails the owning test or preflight; it does not turn an
expected opt-in into a skip. The established default paths remain usable for
existing local runs, and the wrapper retains exactly one SwiftPM child plus
the archive-first, backend, 8-opt-in, zero-failure, zero-skip checks.

Unavailable genuine human portraits cannot block SDK effect verification.
Use owner-authorized generated portrait-like positive/negative inputs with a
predeclared source-fixed oracle; fail the effect gate only for missing or
incorrect effect evidence, not for generated provenance. A legacy real-only
fixture dependency should be migrated to an equivalent generated-input gate
before a future milestone closeout. Existing typed errors, no-skip accounting,
and aggregate-only diagnostics still apply. See
[image-effect acceptance](docs/IMAGE_EFFECT_ACCEPTANCE.md).

## 2026-09-24 audit repair errors and recovery

Malformed Codable EXIF orientation outside 1–8 throws
`DecodingError.dataCorrupted` at the `orientation` key. Configured input pixels
cannot exceed the backend's 50,000,000-pixel ceiling. Invalid still-image
dimensions fail as `BeautyError.invalidInput` at the facade before detection;
the canonicalizer retains its own bound check. A Metal geometry plan exceeding
256 combined points fails as `BeautyError.invalidInput` rather than silently
discarding geometry; a subsequent valid request remains independently usable.
Still-image selective highlights/shadows use built-in Core Image filters and
retain the existing bounded tone coefficient.
`maximumInputByteCount` remains a normalized Codable value only; the current
public API has no encoded-byte input on which to enforce it.

## v1.24 upper-eyelid bounded correction

The source-derived per-pixel gain is `1.8` at positive strength, still rounded
deterministically and clipped to `±16` plus RGB headroom before the unchanged
Q16 feather and immutable-source composition. No extra detection, allocation,
cache, retry, or backend path is introduced. Neutral/invalid strength,
unsupported peer, malformed support, and planar/crease-only negatives keep
their existing source-exact behavior. The generated adjacent-correction and
high-frequency safety checks remain gates; the historical genuine private
matrix failures are not erased by a generated pixel improvement.

## Independent face-mapping degradation (2026-09-23)

The Vision adapter maps eligible observations independently. One malformed
observation is discarded without suppressing another valid selected face. The
summary becomes `.partial` with redacted `.mappingFailed`, a candidate count
including the rejected observation, and a selected count limited to valid
faces. If no observation maps, selection resets and face-dependent work remains
source-safe. This changes neither the single-primary-face effect route nor
the existing typed detector-unavailable and timeout behavior.

## Observed-root raster protection (2026-09-23)

Paired-eye nasal-root fields explicitly stop before the bridge-owned integer
row (`row < floor(split * height)`). The private optional cutoff defaults to nil
for all other controls and is rejected when nonfinite/out of normalized range.
This prevents continuous-support checks from overlooking a changed boundary row.
The retained Metal adapter rejects non-nil cutoffs with `BeautyError.invalidInput`
before runtime submission; it cannot silently discard the protection. A later
supported or neutral request remains usable. The repaired observed-root path
therefore requires the CPU backend.
Narrowing and protection are checked on actual generated and registered original
pixels; a valid sampler or inward control point alone does not prove efficacy.

Default Vision now consumes an explicit named-sRGB CGImage from the existing
CIImage extent. Failure to form this detection raster is typed detectorUnavailable;
metadata orientation and canonical coordinate mapping remain unchanged. This
also rejects fractional crop origins or dimensions instead of silently rounding
the detection raster against different mapper dimensions. Nonzero integral
origins remain supported; allocation obeys the caller's configured pixel budget.
This
removes the CIImage/CGImage source-boundary disagreement rather than compensating
with a fixed pixel offset. All observed controls require the full portrait gate
because they share this provider.


## Generated measurement child supervision (2026-09-15)

Phase95 test-only Python transport uses exact canonical success bytes rather
than Foundation JSON coercion. Nonblocking full-duplex pipes bound input262144
bytes, output4096 bytes and monotonic execution time. A fixed preamble establishes
process-group ownership; cleanup recovers readiness even on early timeout, uses
bounded TERM grace then KILL, and never calls unbounded waitUntilExit. Generated
test observations retain process identities only in memory, require post-setup
acknowledgements and verify processes stop executing. Test-owned final cleanup
protects the suite when deliberate KILL/leader-only mutations fail assertions.
This is test infrastructure, not a new SDK runtime/subprocess API.

## Phase 95 metric-amendment checkpoint (2026-09-14)

Actual reviewed source registration rejected with `child_invalid_output`; a
bounded source-only diagnostic exposed `ambiguous_structure` plus one native
diagnostic line. Transport v3 separates stdout protocol from discarded stderr
under one aggregate output cap, preserving typed rejection and nonzero exits.
This is a transport correction only, not a workaround for source ambiguity.
Original v2 review and failure remain historical; successor review is required.

The independently confirmed legacy metric defect is not an effect pass. The
case-to-metric validation fix intentionally changes comparator identity; the
unchanged v1 driver binding now fails closed. Do not repair that mismatch by
overwriting the old registration. A separately reviewed versioned amendment,
source-only registration and report identity plumbing are required first.

The generated-only structural metric exposes typed invalid-input, unavailable,
ambiguous and identity-mismatch outcomes. It has no portrait input or passing
closeout output. Missing correspondence cannot drop an output row or borrow a
new template. Old portrait failures remain separate immutable observations.

Draft-2 generic math is independently approved (a205d973). The separate registrar
is still review-gated and accepts no candidate/reference inputs. It must compare
two complete source-only records and recheck code, source, compiler and OS
identities; no automatic fallback or parameter retuning follows unavailable,
ambiguous or mismatched registration. Its aggregate output cannot grant an
effect pass or repair the still-unchanged v1 clean65 driver admission.

## Execution-backed Phase 95 closeout (2026-09-14)

`check-phase95-closeout.py full-closeout` uses the genuine gate, requiring an
independent review bound to current source/test/script/owner/history hashes.
It re-executes the portrait gate, wrapper self-test, and archive-first no-skip
wrapper, validates actual XCTest totals and all eight opt-ins, then rechecks
identities before exclusive receipt creation. Missing/stale review, input drift,
failure/skip, capture overflow or deadline failure issues no passing receipt.
Pre-existing receipts are never silently overwritten. Declared-counter legacy
baseline/freeze lanes are disabled; their historical artifacts remain unchanged.

Capture stays in bounded memory; only fixed stage labels and aggregate receipts
are emitted. Both wall-clock and monotonic elapsed time bound children. Managed
portrait execution inherits the supervisor's owned process group so timeouts
also terminate descendants rather than orphaning a nested runner session.
These mechanics and their self-tests do not establish live effect success.

## Phase 95 resumed CPU sampling repair (2026-09-13)

A deterministic in-memory vertical gradient reproduced 2274 changed bytes
under a pure horizontal observed mouth field. Pixel-center inverse conversion
now preserves the gradient exactly on admitted homogeneous observed inward
fields. Legacy/mixed sets explicitly retain prior conversion: global conversion
was rejected because it changed frozen legacy mouth receipts. The correction
is CPU-scoped; it does not claim Metal parity for the new sampling convention.
Malformed or excessive fields return no points; no fallback borrowing is added.

## Phase 95 clean-65 classification (2026-09-12)

The established batch runner's exit 3 means a complete deterministic semantic
measurement, including its expected deferred contour failure. The closeout
driver now submits that result to per-direction classification: all seven
active directions must pass, and the failed contour stays deferred/partial.
An active failure, unexpected contour promotion, malformed or stale report,
digest mismatch or incomplete inventory remains a failure. Measured target,
sibling and protected values are preserved. Preparation uses the established
runner's preflight and fresh-attempt ownership, without recursively deleting
previous owner-local output attempts. Full no-skip closeout remains contingent
on successful registered portrait evidence.

Observed chin rejects a complete invalid flank pair without discarding other
validated lower pairs. Explicit malformed lips remain rejected at detection and
geometry; absence in historical synthetic fixtures remains a separate state.
Small observed support is never enlarged by legacy minimum-radius clamps.
Candidate 1's two registered attempts passed four active directions but still
failed chin, root and negative mouth. Candidate 2 is under evaluation; this is
not a final closeout or evidence of device/visual-quality qualification.

Candidate 2 has now completed: four active directions pass, chin/root/negative
mouth still fail fixed direction/distinctness margins. All seven active target
signals and every outside/protected zero-change check pass. Execution stops
at the recorded two-candidate boundary; no automatic retry loop, weakened
threshold or fabricated completion is used.

> Current SDK-only error, degradation, observability, performance-risk, archive,
> and recovery contract.

## Current Post-Archive Audit Status

v1.21 adds provisional upper-eyelid fullness to the existing still-image
local-retouch transaction. Positive intent uses the selected observation and
existing per-eye support/editor; neutral, no-face, missing/malformed/ambiguous
support, unsupported relief, invalid source, and composition collision remain
deterministic source-exact outcomes. The known weak visual result is accepted
as product debt, not hidden as a reliability success claim.
The final archive-first no-skip gate passed `816/0/0`, all eight opt-ins exactly
once, and zero skips.

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

- Runtime, model resources, fixtures, and generated weights are installed and
  operated only inside the owner's controlled local environment. There is no
  update service, customer distribution channel, remote model replacement, or
  third-party availability promise to recover or support.
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
| R17 | Upper-eyelid intent performs at most one canonicalization, one detection/mapping request, one request context, one immutable-source composition, and one render; no-face or per-eye rejection cannot contaminate siblings or later requests. |
| R18 | Phase 89 credits semantic evidence only after two fresh exact 75/65/8 attempts have identical completion class, canonical `stableSemanticPayload` bytes, and digests; stale or infrastructure-failed output is never evidence. |

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
  compatible 75-case current inventory (74 in the v1.16 historical snapshot) and accepts only the CPU token in v1.16; explicit
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

Affected-eye/feature failure remains local. Teeth, sclera, and upper-eyelid
fullness share the request owner but not support/admission authority. Upper-
eyelid units are generated only after per-eye semantic and source-relief
approval. Pixel-buffer processing and `reset()` create no local-retouch request
work.

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

## Phase 89 Semantic Batch Reliability Contract

The runner binds the exact live/selected/semantic inventory `75/65/8` and
report schema `beauty.face-feature-batch-report.semantic.1`. Preflight admits
only regular non-symlink input/output/report descendants with no unsafe overlap,
then validates exact manifest, renderer, and comparator inventory before any
mutation. Every full invocation creates two fresh, never-reused attempt roots;
each must reconcile 65/65 outputs, five batches, eight direction rows, zero
missing output, source and neutral evidence, watermark exclusion, and complete
aggregate metrics.

The two attempts must have identical completion class, canonical
`stableSemanticPayload` bytes, comparator digest, and reconciliation digest.
Only after equality does the runner atomically replace the current aggregate
report. Exit `0` is reserved for complete 8/8 `semantic_pass`. Exit 3 is a
complete deterministic `semantic_fail` with an aggregate report: it is a
trustworthy completed measurement, not infrastructure success and not repair
acceptance. Admission, rendering, output, report, stale-state, or determinism
faults use the separate exit `2` `infrastructure_failure`; that class is not
creditable evidence. The runner independently admits a distinct report
destination, so a missing or rejected input/output path still atomically
replaces a prior safe report with a sanitized current envelope. If the report
destination itself is unsafe or aliased, the runner preserves the referenced
bytes, returns exit 2, and requires consumers to reject any pre-existing
report.

Every direction must measure every admitted fixture. Metric admission is never
converted into a stable `semantic_fail` reason or reported with an unearned full
fixture count. The current gaze direction is deliberately `unsupported_metric`
until an independently validated request-local pupil/eye-contour owner exists;
therefore a full eight-direction invocation terminates as exit-2 infrastructure
failure rather than publishing the superseded pre-review aggregate.

On semantic completion, the first attempt is retained under the ignored
owner-local output root with watermarked PNGs only; the repeat attempt is
removed. Successful semantic publication requires verified removal of
temporary renderer/comparator reports, workspaces, repeat media, and child
transcripts; a partial attempt is never published. `cleanup_failure` means
removal could not be verified, blocks semantic publication, and requires
owner-local containment and remediation of any remaining artifacts. Recovery
never relies on or appends to a prior report or raw transcript. These rules
preserve the 62/5/75 public surface, both
still-image facades, CPU reference and selectable-GPU/typed-unavailable policy,
and every device/population/commercial/release/distribution nonclaim.

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
that historical checker. v1.21 narrows its current responsibility to resolving
and validating the immutable Phase-75/78/79 machine decision and archived
61/5/74 disposition. It no longer treats later public-surface changes as drift
or binds the current editor source/tests. Artifact-resolution failures expose
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

The owner canceled this runtime path on 2026-08-25. No predictor or model
resource will be registered in v1.19; the existing package-only validator stays
fail-closed and experimental code remains unreachable from the public facade.
The remaining contract is retained only for a separately authorized future
milestone.

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

The reliability lifecycle ends at an owner-local, checksum-pinned model. A
research-only dataset may feed only a non-commercial local candidate under its
actual terms. Distribution, monetization, customer upgrade, remote delivery,
and externally supported rollback are prohibited rather than unimplemented
reliability promises; any future change requires a new model/license/resource
reliability contract.

Plan 80-20 passes `8/0/0` learned-prediction tests and `23/0/0` across all
upper-eyelid suites. It covers no-model, invalid request before inference,
protected overlap, envelope escape, abstention, confidence, uncertainty, side
mismatch, missing/malformed samples, non-zero boundary flow, excessive flow or
tone, discontinuity, local fold-over, inference failure, and independent-peer
recovery. The plain full package passes `813/0/8`; the eight existing opt-ins
remain disabled in a plain development run and this is not final closeout.

## Phase 90 Chin Repair and Contour Deferral Reliability Contract

Existing generated provider, CPU-raster, and public-facade tests bind
`chinTaper` to source-exact neutral behavior, deterministic repeat output,
half-strength behavior, exact `0.25` cap and over-cap clamping, bounded X-only
movement, protected-region stability, and metadata preservation. No-face,
missing, malformed, one-sided, uncovered, provider-empty, reused/stale, and
invalid support fail closed for the named field. Valid siblings continue, and
the valid-invalid-valid sequence recomputes request-local state without
carrying a prior contour, median, point, pixel, or failure into the next
request.

FACE-01 terminates as `completed-deferred`, not repaired. The callable
`faceContourSmooth` field remains source-unchanged, fail-closed, and `partial`;
revision 22's `prior_stop_not_reproduced` classification and zero render/oracle
invocations supply no runtime success or GREEN evidence. No retry, fallback,
threshold relaxation, or revision 23 is part of this reliability contract.

Phase 95 owns direct coverage for the exact one-step-above-neutral input, both
cap-adjacent values, the exact and adjacent quantization threshold, and
strict-comparison tie behavior. It also owns the clean 65-output seven-
effective-plus-one-deferred publication and the complete archive-first no-skip
closeout. Until those direct residuals run, the current comparisons are
source-defined behavior rather than newly measured Phase 90 evidence.

The compatibility surface remains 62 stored parameter fields, five presets,
75 renderer cases, `BeautyEngine.processResult(image:metadata:parameters:)`,
and `BeautyEngine.process(image:orientation:parameters:)`. CPU stays the
reference; selectable GPU either succeeds through unchanged retained
`Warp.metal` or returns terminal typed `.metalUnavailable` without silent CPU
fallback. Request-local aggregate evidence remains redacted and SDK-only.
Automated completion makes no device, population, performance, thermal,
battery, endurance, commercial-quality, packaging, shipping, launch, release-
readiness, or distribution claim.

## Phase 91 Independent Gaze Correction Reliability Contract

Positive gaze work is recomputed per request and per eye. Exact displacement
`0.002` is neutral; positive input caps at `0.25`; cap movement is 35% toward
that eye's own center; and source/destination plus the frozen half-clearance
radius must remain inside a finite simple aperture. Missing, malformed,
centered, outside, ellipse-invalid, duplicate, stale, reused, or otherwise
ineligible support rejects only that eye. A valid peer continues, while paired
`pupilSize` compatibility and unrelated eye fields remain unchanged.

The resolver attaches aggregate evidence only after conflict convergence and
final field recomputation. Any count, boolean, Q16, point-admission, or identity
inconsistency collapses to deterministic abstention. Renderer/report parse,
schema, replay, path, symlink, alias, or cleanup faults are infrastructure
failures and cannot be recast as semantic failures or passes. Valid-invalid-
valid sequences and repeated cap requests reproduce the same bytes and
aggregate without stale support.

Attempt records are consistent at implementation attempt 1; no second attempt
was needed. The current-authority SwiftPM suite passed `840/0/8`, focused
compatibility passed `107/0/0`, comparator self-test passed 576 mutations,
runner boundaries and exact `75/65/8` preflight passed, and temporary reports
were verified removed. The sole excluded discovered test remains the Phase-90-
deferred frozen FACE-01 effectiveness oracle and receives no GREEN claim.

Phase 91 changes no public inventory, facade, backend, shader, or threshold.
Phase 95 retains portrait publication and the complete no-skip gate. Package-
host determinism does not establish device performance, endurance, population
quality, naturalness, commercial suitability, packaging, shipping, launch,
release readiness, or distribution.

## Phase 92 Signed Eyebrow-Head Spacing Reliability Contract

R5 (`470ae0d`) recomputes brow support per request and admits candidates per
side. Nonfinite/unit/clearance errors or failure of the final per-side 0.9
summed displacement budget cause that side to abstain. Dense admitted traces
cannot bypass this bound through individually safe overlapping cones. Sparse
fields remain byte-exact, and the unchanged generic 4.5% face-width radius
ceiling, public cap 0.25 and Float.ulpOfOne dead zone remain enforced. This is
a per-side inverse-field bound, not an arbitrary combined-effects guarantee.

Provider-empty and valid-invalid-valid requests remain deterministic; a failed
peer does not suppress or borrow from the valid peer. R4's sparse semantic pass
did not close the phase: independent review exposed dense folding, a retained
RED regression reproduced it, and reviewed R5 resolved it. Repair cycle 1 /
cumulative attempt 7 preserves every earlier failure and frozen threshold.

Fresh evidence: provider 18/0/0, public/registration 5/0/0, combined compatibility
and freshness 217 discovered / 0 failures / 2 established portrait opt-in skips.
The required compatibility subset is 120/0/0; the two skipped live Vision tests
remain Phase 95 work. Comparator 576 mutations and inventories 5/65/8 passed;
runner cleanup 6, exact preflight 75/65/8, backend-neutral 24+41, archive and
SDK-only boundaries passed. Metrics and metadata assertions bind to final
pixels; no child transcript, raw geometry, pixels or private locator is retained.
No new public error/log/report API or shared renderer/backend/shader change was
introduced. Phase 95 retains portraits and full no-skip closeout; no device,
commercial-quality, launch or distribution claim is made.

## Phase 94 Prerequisite Compile Recovery

The first registration preparation stopped before test discovery. A bounded
diagnostic build reproduced a Swift type-check timeout in the registration
test's channel predicate; an equivalent explicit loop cleared that build.
This is compiler recovery evidence, not registration or effect evidence.
`check-phase94-compile-recovery.py` binds the exact before/after test bytes
and original terminal history through `94-COMPILE-AMENDMENT.json`. It writes
only separate successor evidence, retains the original deadlines and bounded
memory-only child capture, and records stage/exit status on later failures.
New failures and interrupted lanes cannot automatically restart. Prerequisite
GREEN, if earned, still leaves MOUTH-01 incomplete and attempts at 0/2.

The next retained-row baseline failure is also preserved. Diagnostic execution
localized an unexpected test error to the test's mandatory color-space guard.
Color-only lip filtering does not carry the geometry rasterizer's exact source
tag contract. Its test now checks optional RGB metadata and exact agreement
across wrappers/repeats while materializing every pixel in named sRGB. Neutral
and emitting-geometry tags remain strict. This test correction changes no SDK
output, pixel threshold or protected-region policy and requires fresh baseline
evidence under its own reviewed disposition.

## Phase 93 Nose Field Admission and Recovery

The owner-local evidence in
[93-CHECKS.json](.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-CHECKS.json)
binds independent code review and separate 36/0/0 core, 229/0/0 compatibility,
8/0/0 script-command and 106/0/0 deterministic regression gates.

Actual Float displacement, not strength metadata alone, controls rendering.
Both repaired fields retain finite/bounded support, source/cap-target/target
disks, strict radius/L1 >0.0001, direction checks and the final 0.45 field
budget. Invalid root work abstains as a pair; any required point failure
empties only its field and sanitation removes its effective work. Missing
support cannot borrow a sibling; valid-invalid-valid recovery is deterministic.

Frozen tests cover 2/4/16/64-support fields, quarter/half/cap strengths,
129x129 maps, disk neighbors/midline, exact reuse and fixed signed sibling
combinations. Applicable cap fields require nonempty output; dense lower
strengths may correctly abstain at the strict cutoff. The isolated two-field
0.90 bound does not establish arbitrary mixed-field/GPU/clamped-raster safety.

Attempt 1's field-budget failure remains a failure. Attempt 2's compatibility
timeout 39 and rollback 40 also remain: 229 discovered, 67 passed, no completed
assertion failures or skips, one timeout and 161 unexecuted. Infrastructure
review established an outer 60s/inner 120s scheduling mismatch, not the exact
historical runtime stage. The corrected launcher keeps the eight renderer
process methods in one cache-sharing child with a derived 1839s envelope and
owned cleanup; other methods retain 60s deadlines. The exact same candidate
then passed compatibility, without a third production candidate or test change.

Supplemental selection error 55 remains separate from numerical failure;
its reviewed scope correction excludes only two Phase 95 portrait opt-ins
and requires the fresh 106-method deterministic pass. Independent goal verification passed. Phase 95 owns portrait/final-output and full
no-skip evidence; no device performance or distribution claim is made.

Independent goal verdict: [93-VERIFICATION.md](.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-VERIFICATION.md), 18/18 must-haves and zero blockers.

## Phase94 Negative Mouth-Width Reliability Contract

MOUTH-01 acceptance `94-REMAINING-CHECKS.json` SHA256
`fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4`
passed41/41, including actual Float field and signed lifecycle checks.
Signed caps remain±0.35; fresh/reused/stale resolution and existing conflict
sanitation remain unchanged. Tests verify reuse displacement scaling within an8-ULP
reconstruction tolerance. Provider emission retains its legacy tiny-vector
policy; renderer admission separately requires radius and L1 displacement
strictly greater than0.0001.

The original baseline demonstrated protection leakage and actual narrow-support
crossing/reversal. PolicyA fixed those but failed the fixed500 changed-pixel
minimum at392; its complete41/40/1 result and owned rollback remain recorded.
The predeclared policyB passed at520 changed pixels with−24Q16 source/neutral
margins and all negative protection maxima0/0. Compile/review/seal and native
acceptance bind the same code; failed, stale, interrupted or incomplete evidence
cannot authorize a retry or completion. The two-attempt budget is exhausted.

Both signs preserve neutral/nonfinite identity, cap equality, integral extent
including translated input, opaque alpha, wrapper/repeat determinism, eight
raw EXIF encodings and the existing input/preview-mirror policy. Raw geometry
retains Device RGB while measurements use named-sRGB extraction; neutral
metadata and the existing optional color-only lipColor tag policy are retained.
Reset/rejected-support/recovery checks preserve exact source and recovered
bytes, reasons and invocation counts. No all-orientation semantic ROI,
device performance or long-duration claim follows. Phase95 final65/private
portraits/full no-skip and commercial/distribution qualification remain separate.

## v1.23 FACE-01 Candidate Reliability

The subpixel step is deterministic for a fixed canonical image, support, and
strength. It bounds input byte-count multiplication, reads immutable source
pixels for both interpolation neighbors, clips to image bounds, preserves
alpha, and returns source bytes for neutral or unsupported requests. The
four-pair source-edge scan is bounded and falls back to the previous
half-pixel correction for weak or ambiguous boundaries; a unique strong edge
can move by at most 1.5 pixels. Generated nearest and inward edge alignments
both pass the independent boundary oracle, while real portrait benefit is
still unverified. The
provider rejects malformed or nonmonotone lateral runs and any nonfinite,
unbalanced, or over-cap quantized point field. Its sparse 10–12-point support
rule was added after the 44-field combined regression found an unintended
abstention; the focused 17-test class now passes with all 44 fields retained.

The refiner makes one full RGBA copy and then the existing geometry warp
performs its own image operation. Package-host tests establish bounded
behavior and generated CPU/Metal still-image parity, not device memory,
latency, thermal, battery, or sustained-load performance. Orientation and
mirror tests show active output for supported generated fixtures and exact
neutral output when the fixed test support becomes ineligible; they do not
prove contour efficacy at every orientation. The final archive-first no-skip
gate passed `944/0/0`, all eight opt-ins, and zero skips on the final source.
This result belongs
to the v1.23 evidence record, not the historical v1.22 receipt; actual
portrait contour improvement is still unverified.
