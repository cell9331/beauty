# RELIABILITY.md

## 2026-10-04 example media storage failures

The [storage entry](scripts/manage-example-images.py) returns 0 with aggregate
counts on success and 1 with a fixed reason for limit, path, manifest or I/O
failure. The archive-first wrapper runs its read-only `check` after boundary
verification; exceeded limits stop the gate before SwiftPM tests. The gate never
cleans files automatically. Explicit `clean` checks the complete tree, tracked
entries and current manifest references before removing its cache allowlist;
unclassified files are retained. A failed removal is not a successful cleanup;
repeating `clean` is idempotent and `check` confirms the remaining storage state.

Display encoding has a 120-second local compiler deadline and a 30-second helper
deadline, uses temporary copies, rejects malformed/multi-image/oversized inputs,
and verifies decoded JPEG dimensions and stripped metadata before retaining a
preview. Existing preview IDs are rejected rather than overwritten. These
commands add no SDK failure, retry or effect-qualification behavior.

## 2026-10-03 current batch result contract

The [new batch entry](scripts/current-batch/README.md) independently verifies exact
98/99 inventory, both renderer reports, actual files, source identity, metadata
and repeated pixels. Per-case results distinguish `passed`, oracle-declared
`abstained`, `effect_failed`, `execution_error` and `unverified`. Abstention means
the input's declared unchanged-output contract passed; it does not reconstruct
an unexported Vision diagnosis. Missing oracles never become passes.
Exit precedence is execution error 2, effect failure 1, missing oracle 3, then 0;
`preflight_only` gives inventory credit only. These codes belong to this entry,
not the frozen historical wrapper. Children have a 600-second deadline and 8 MiB
output limit; timeout/interruption kills their process group. Report-write failure
returns a fixed redacted error. Fresh run directories prevent stale success reuse.
Malformed PNGs, empty sampled regions, alpha changes and nondeterministic output
cannot pass. No production error or recovery behavior changes.

## 2026-10-03 SEG automatic development

The [development runner](scripts/experiments/seg-development/README.md) uses the
same bounded child execution and frozen inputs/metrics in disposable SwiftPM copies.
Exit 0 means only the development numeric conjunction passed; 1 means completed
measurement with effect failure; 2 means unavailable/incomplete execution. It never
signs G1 itself. All four versions completed measurement but returned 1 for effects.
Missing rows, duplicate identities, skips, changed source/contract hashes or stale
baseline controls reject execution. Registered candidate/protocol digests are checked.

The initial missing import ran zero tests. A later export-name collision was fixed
without changing pixels or metric rows; old revisions remain preserved. Passing
observation/public/repeat equivalence does not imply complete effect qualification.
No production error/resource contract changed. SEG stops after the finite budget;
retrying controls or read-only replay cannot create a fifth candidate version.

## 2026-10-03 SEG G0 isolated validation

The [complete SEG G0 runner](scripts/experiments/seg-g0-complete/README.md) uses a
disposable package, verified local inputs, a 600-second child deadline and a
16 MiB in-memory transcript limit. A successful exit requires every expected
XCTest, zero skips/failures and the exact aggregate identity/count sets; missing
rows, duplicates and incomplete execution cannot qualify. Structured aggregates
are atomically written separately from XCTest logs and checked before a receipt
is retained. Child transcripts are never persisted. The first complete-run
receipt failure remains recorded; r2 passed 20/0/0 on unchanged inputs.

Actual invalid-grid, corrupt/empty/nonopaque-input recovery, neutral identity,
repeatability, orientation equivalence and metadata checks passed for the scope
in the [freeze report](docs/SEG_G0_FREEZE_2026-10-03.md). These are G0 host controls,
not automatic rejection or device-performance qualification. Production error,
resource and retry behavior is unchanged.

## 2026-10-01 suspended upper-eyelid default selection

Default renderer discovery and execution omit the suspended upper-eyelid case;
explicit legacy selection retains its previous validation and typed failures.
The complete 99-item registration list still owns stale-output invalidation;
default discovery and batch execution use 98 items. The opaque-input and typed
failure contracts also apply to explicit compatibility calls. Existing
SDK safety tests and the nine mandatory opt-ins remain active; pausing effect
R&D does not suppress tests or turn the independent failing natural challenge
into a passing result. That challenge is kept as a manual research artifact
and is not repeatedly scheduled or a blocker for other SDK work. The explicitly
reopened v1.25 branches are now [closed as unmet](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)
after finite failures; no automatic retry or G0 continuation remains. Original
failure evidence, safety opt-ins and runtime error/resource contracts are unchanged.

The final EYE diagnostic runner has a 600-second child deadline and 16 MiB
in-memory output bound, with process-group termination and fresh review directories.
It validates controls before candidates and source bindings before each stage;
missing/duplicate measurements, build failure or incomplete XCTest execution return
2. Complete unsuccessful effects return 1 even when measurement XCTest returns 0.
The initial compile failure ran zero tests; an equivalent pixel-count loop repaired
the harness without changing candidate bytes. Final controls passed 1/0/0 and
candidate measurement 3/0/0, while all three candidates failed effect qualification.
No production error or retry behavior changed.

## 2026-10-01 upper-eyelid reconstruction bounds

The per-eye editor retains the existing source admission, but replaces the
overcompressing gain with a source-bounded correction and descending priority
reconstruction. For `n` supported pixels it adds request-local arrays, an
index map and a heap: work is `O(n log n)`, storage `O(n)`, with at most the
initial `n` entries plus one insertion per traversed neighbor edge. Every
pixel is finalized once; there is no iterative convergence wait. The final
Q16 encoding checks at most 17 targets and applies strength after the
continuous reconstruction. Targets retain the full source/channel allowance
and the full reconstructed-correction cap; nearest final-output selection
avoids the systematic low-strength loss of two downward quantizations.
Strength is monotone, ties choose the smaller target, and a zero visible
correction emits no nonzero target. No device latency, peak-memory or throughput
equivalence to the previous editor is claimed.

Any support pixel lacking a complete 3×3 source neighborhood rejects only
that eye; a valid peer and a subsequent valid request remain usable. Invalid
strength/support, neutral requests and existing typed failure paths remain
under their previous owners. The editor can conservatively yield zero final
change for a boundary-connected ridge or insufficient correction headroom;
admission is not a guarantee of visible effect or correct anatomical selection.
The guide is an image-luminance proxy, not fat or shape truth. The proposal and
actual composed-pixel counts retain their distinct meanings. No raw fields leave the
request, and no extra detector, model, backend or persistent state is added.

The effect-specific orientation suite now covers all 32 EXIF/input-mirror/
preview-mirror combinations on a non-square asymmetric source. It confirms
canonical input metadata and exact upright effect output, while neutral
requests retain the existing raw-raster route. Empty and nonopaque inputs
fail with `invalidInput`; the same engine then recovers on an oriented,
mirrored valid request. A separate fixture-backed test runs the existing live
Vision path; missing or invalid local fixture data fails with a fixed error
instead of exposing a private file locator.

The separate [natural-background challenge runner](scripts/experiments/upper-eyelid-natural-challenge/README.md)
builds a disposable copy with a separate SwiftPM scratch directory and runs
exactly the frozen main XCTest method. It preserves a nonzero child exit;
zero tests, skips, missing/invalid inputs or unrecognized execution summaries
cannot report success. It does not participate in the mandatory green gate
and does not turn the unresolved natural-positive assertion into an
expected failure. Its output is bounded to 16 MiB/200,000 child lines in private
memory, and only aggregate results are exposed. An interrupted runner signals
its child process group before cleaning the temporary package.

## 2026-09-29 texture exclusion recovery

Malformed binary masks fail with typed `invalidInput`; a correctly sized mask
for the canonical orientation remains request-local and does not affect a
later request. The encoded-PNG entry is covered by a wrong-grid failure
followed by a valid request on the same engine. The texture stage reads one
immutable byte per source pixel
and skips excluded centers, using the same CPU-owned operation on CPU and
Metal-selected routes. The caller-provided mask adds up to one byte per
pixel of request memory beyond the earlier three-RGBA8-buffer texture bound;
Core Image and Metal allocations remain outside that earlier estimate.

The [2026-10-03 frozen probe](docs/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)
retains a failed protection assertion for a low-contrast lip extending outside
the coarse zone. Object-only masks do not cover unmarked lip pixels. This is an
unqualified input/protection limitation, not a new typed failure or a repaired
production path; known protected pixels can use the existing explicit mask.
General automatic object identification is paused after one rejected candidate.
The [host union regression](docs/HOST_TEXTURE_PROTECTION.md) supplies the known
object and full lip together, verifies exact protection and active cheek texture,
and checks wrong-grid recovery plus absence of mask state in later requests.
It does not extend the unmasked coarse feature admission domain.

## 2026-09-28 source-qualified geometry recovery

Still-image whole-face translation rejects invalid dimensions, nonopaque or
nonuniform borders, disconnected foreground, unmatched face bounds and
out-of-frame destination bounds by returning the source bytes. Philtrum
source admission rejects missing or offset visible upper-lip evidence before
point selection. Both operate on request-local bytes, emit no logs or private
coordinates, and retain typed input failure and subsequent-request recovery.

## 2026-09-28 source-contour still-image recovery

The hairline and outer-submental decisions are recomputed from each admitted
still image. Ambiguous or absent boundaries leave their contributions exact;
a later source can qualify on the same engine. CPU and Metal-selected paths
use the same deterministic source-resampling functions, while pixel buffers
retain their existing point route. Each admitted raster adjustment copies one
RGBA8 image before local row edits; combined requests may hold both copies
briefly. The existing general pixel admission limit still applies, but these
new copies have no separate lower pixel cap and large-image peak memory has
not been measured. No new typed error or logging surface is introduced.
`headWrap` reuses the same source detector on still images before admitting
its existing geometry points. This adds a bounded per-column scan only when
head-wrap is active; an unsupported source exits that control unchanged and
later requests recompute admission.
`foreheadHeight` shares the same single raster boundary pass with
`hairlineHeight`: normalized opposing requests cancel and same-direction
requests clamp to the hairline displacement cap. Ambiguous/no-hair input
remains exact for that control, with no additional raster allocation.
The submental candidate search now checks a continuous source-skin run to
the outer edge before resampling. A detached collar or internal dark fold
does not leave a stale candidate for a later request; this adds bounded
per-column source reads and no new allocation or typed error.

## 2026-09-28 hairline brow-overlap recovery

The existing `hairlineHeight` point provider checks request-local observed
eyebrow traces before emitting its paired points. Invalid supplied traces or
an influence area's vertical reach meeting the observed brow with a 3%
face-height margin make this control emit no points. A later request recomputes
the check, unaffected by the earlier exit. Other controls in the same request
remain independent; no new typed error, log, stored geometry, or backend is added.

## 2026-09-27 texture detection and recovery

Still-image and pixel-buffer texture requests use only face bounds selected
for that request. No-face, disabled, malformed, or scheduled skipped detection
leaves the texture contribution source-exact, with no stale face reuse; a later
supported request on the same engine can apply texture normally. Other color
controls remain independent. The row-bounded ellipse loop visits only the
conservative face interior before the existing alpha, color, and edge checks.
The same request-local bounds exclude fixed eye/lid and lip zones before
neighborhood sampling. A saturated-warm source-RGB rejection keeps the tested
in-face decoration source-exact while the opposite cheek remains active; it
is deterministic and uses no stored classification state. These guards are
conservative protection regions, not observed feature segmentation; unusual
face framing or skin-colored objects can still require additional protection.
The earlier texture pixel cap still bounds allocation; Vision and Core Image
memory and physical-device speed remain unmeasured.

## 2026-09-27 vertical proportion recovery

Forehead and midface points are derived from the selected face for each
request and retained nowhere afterward. Missing or malformed contour support
exits unchanged. Oversized input keeps the existing typed failure, and a
later valid request succeeds through the same engine.

## 2026-09-27 short-face recovery

Face shortening derives two points per request from validated face support
and retains no geometry between calls. Missing, malformed, or insufficiently
tall support exits unchanged. Oversized input keeps the existing typed
failure, and a later valid request succeeds.

## 2026-09-27 texture request resource ceiling

The texture admission cap is 8,388,608 pixels. The decoded and pixel-buffer
public facades reject an oversized active texture request before a texture
raster is allocated; the encoded facade checks declared dimensions before
decode and decoded dimensions again after decode. The backend request repeats
the cap for package callers. The CPU still-image texture step may own three
packed RGBA8 buffers, bounded to 96 MiB together at this cap; Core Image,
system allocator peaks and additional Metal-selected backend buffers are not
measured. The rule is per request and failure does not retain image data or
poison a later request.

## 2026-09-27 dense geometry capacity recovery

A 288-point admitted still-image combination no longer fails solely because
the Metal uniform holds 256 points. The facade chooses the existing CPU
reference executor before GPU submission; it never retries a failed Metal
runtime call or silently truncates points. The CPU request remains subject to
the admitted image-pixel limit. Direct Metal calls and row-restricted geometry
retain their typed errors. GPU device throughput, large-image CPU time and
energy are unmeasured; no performance qualification follows.

## 2026-09-27 whole-face tilt recovery

Tilt is resolved per request from validated selected-face support. An absent
contour produces no tilt points, and no geometry is cached between calls.
Signed targets are bounded inside the unit image. An oversized input retains
the existing typed failure; a later valid request still succeeds.

## 2026-09-26 diagnostic filtering and recovery

The `logLevel` verbosity threshold is applied after each successful public
result route; `enableDebugMode` gates the debug-stage event. Encoded input
reuses the static-image path without duplicating events. Failure remains a
typed throw with no result; the next valid request emits the same configured
events. Default `.error` continues to produce no success diagnostics.

## 2026-09-26 opt-in performance timing

The monotonic timer starts before each public result facade's synchronous
admission work. Encoded input includes its decode phase; nested still-image
timing is replaced with the outer value. Invalid requests keep their typed
error and produce no successful metric; later requests recover. Disabled
timing leaves the original metrics and pixels unchanged. Deferred `CIImage`
evaluation is outside the measurement.

## 2026-09-26 whole-face horizontal recovery

The signed horizontal face point is absent for missing or malformed face
support; a later valid request still produces the requested direction. The
existing combined-strength scale and Metal geometry point validation apply.
Neutral input is source exact; repeated valid requests are deterministic.

## 2026-09-26 encoded input failure and recovery

The encoded `Data` facade performs bounded byte and pixel preflight, then
reuses the existing still-image rendering state machine. It rejects empty,
malformed, animated/multiframe, byte-oversized and pixel-oversized inputs as
typed `invalidInput`; a later valid request on the same engine proceeds.
`maximumInputByteCount` normalizes nonpositive mutation to its default.
No diagnostic includes encoded contents or a source path.

## Current whole-face vertical bounds and recovery (2026-10-01)

The signed `wholeFaceYPosition` field caps at `±0.30`. The provider checks face
bounds/contour support and emits either zero points or five finite,
unit-bounded points: one center, two feature and two edge points. Existing
combined-strength scaling and geometry-capacity checks still apply to provider
plans; reused non-eye geometry retains its half-scale policy.

In the current RGBA8 still-image geometry path, these provider translation
points are suppressed. `WholeFaceTranslationRefiner` instead applies a rigid
translation after source-silhouette admission: one connected head, uniform
background and a safe output envelope. Missing/ambiguous source support leaves
the translation unchanged. Eye/mouth widths, eye spacing, foreground area,
extent/alpha and repeatability are covered by the qualified generated-image
tests. The same admitted still-image operation is used for CPU and Metal-selected
results; this is not a realtime/pixel-buffer geometry or device-performance claim.

## 2026-09-26 FACE-01 chromatic edge and side recovery

Weak RGB brightness edges can use a coherent source-row chroma crossing;
strong competing edges retain the earlier fail-closed result. A sustained
compact dark occlusion closes its observed lateral run, and both still-image
backends remove the corresponding `faceContourSmooth` points before geometry
execution. The opposite side and unrelated controls remain eligible. The
request-local side flags and pixels are not retained or logged. Generated
single-side and repeated-output tests, the frozen second portrait oracle, and
the full archive-first no-skip gate pass with zero skips.

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

## 2026-09-26 indexed frame interval recovery

The explicit camera/video frame index selects detection by modulo of a
positive normalized interval; it does not depend on prior calls. Invalid
indices and source kinds fail with `BeautyError.invalidInput` before detector
work. Off-cycle face work has a deterministic `.skipped` summary and fixed
`.detectionInterval` reason, with no retained support; the next scheduled
frame can detect normally. Unindexed still images preserve their prior route.

## 2026-09-26 preferred Vision detection bounds

`preferredProcessingSize` bounds the Vision raster but does not relax the
original image's typed pixel-limit rejection. Invalid or absent sizes retain
the unscaled detector path after initialization, decoding, or mutation
normalization. Downsampling
keeps at least one pixel per axis and never upscales. Detection failure still
uses the existing skipped-support behavior; output dimensions stay unchanged.

## 2026-09-26 skin-texture bounds and recovery

The spatial stage samples immutable request-local RGBA8 pixels within a 3×3,
5×5, or 7×7 footprint and writes each result once. It checks input dimensions and byte
products before allocating for the direct CI path; the public facade still
rejects invalid extents and configured pixel-limit violations with typed
`BeautyError.invalidInput`. Nonopaque centers or neighboring pixels, strong
color discontinuities, and borders are source-exact for texture work. The
neutral plan avoids this stage. Identical input and plan produce identical
output; a failed request does not retain a prior neighborhood or output.

This CPU-owned stage also runs when Metal is selected, before retained GPU
passes. Its worst-case work is 49 neighbor samples per pixel and it can hold
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
At that audit date, `maximumInputByteCount` was a normalized Codable value
only; the new in-memory entry above now enforces it.

## Historical upper-eyelid gain bound (2026-09-24)

The earlier `1.8` gain retained `±16`, RGB headroom, Q16 and source ownership,
but its generated score improvement did not establish natural-image quality.
It is no longer the production correction rule; current bounded reconstruction
and quantization are described above. Historical constants and results remain
in the [technical history](docs/history/upper-eyelid-technical-history-2026-10-01.md),
without an instruction to continue tuning them.

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

Suspended upper-eyelid explicit compatibility retains the selected-observation
and per-eye support/editor transaction. Neutral, no-face, missing/malformed
support, unsupported relief and composition collision retain their bounded,
deterministic outcomes; invalid public input keeps its typed failure. Safety,
ring/quantization fixes and orientation recovery do not establish effective
natural-image reduction. The v1.21 provisional acceptance and `816/0/0` gate
are [historical facts](docs/history/upper-eyelid-technical-history-2026-10-01.md),
not an active effect-quality promise or a requirement to resume optimization.

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
case-insensitive duplicate output stems before crediting work. The current CLI
has 99 renderer cases and accepts only the CPU backend token; the SDK's selectable
GPU backend is a separate facade contract. The v1.16 74-case inventory is a
historical snapshot. A requested matrix unit is credited only after an
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
   with the wrapper's five explicit environment inputs (three opt-in switches
   and two evidence-bundle selectors); and
8. transcript reduction that proves all nine expected opt-in test identities
   execute exactly once, zero failures, zero skips, and nonzero all-tests execution.

The identity list is owned by `expected_opt_in_tests` in the wrapper and
checked separately from its environment inputs by
`scripts/check-no-skip-wrapper.py`. Test identities and environment-variable
counts are different contracts.

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

## Retained Upper-Eyelid Support and Editor Reliability

The package-only support seam reuses one mapped Vision observation and one
semantic-owner call per request. Missing or malformed support is isolated to
the smallest eye region; a rejected peer cannot authorize or suppress an
eligible eye. Confidence, finite dimensions, plausible brow-to-eye geometry,
hard containment, unique pixel ownership and bounded Q16 weights are checked
before composition. `CoordinateMapper` remains the orientation/mirror owner.

The retained relief analyzer validates canonical RGBA8 layout, finite strength,
a nondegenerate patch, at least six boundary anchors, a solvable affine plane
and a nonempty central region. Its box radius is patch-derived and capped at
`24`; two patch-local integral arrays provide constant-time sample lookups.
The current editor's reconstruction and quantization bounds are described
above. They introduce no previous-request state, external model, network or
retry path. The composition owner preserves protected/exterior pixels,
alpha/metadata and overlap-to-source behavior.

Repeated supported requests are deterministic. Neutral and rejected local
units emit no proposals, while public malformed/nonopaque input retains typed
failure and same-engine recovery. A supported brightness proxy may still
produce little or no useful natural-image reduction. This is the retained
compatibility behavior of a suspended effect, not a passing efficacy claim.

## Historical Upper-Eyelid Evaluation and Decision Binding

Phases 77–79 recorded bounded mechanics and `mechanics-only-not-promotion` for
the then-unexposed `61/5/74` surface. Later v1.19 candidates failed actual
image applicability, adjacent continuity, texture or visible-reduction checks,
despite some green generated tests. The exact historical counts, failed bounds
and original evidence links are retained in the
[technical history](docs/history/upper-eyelid-technical-history-2026-10-01.md).
These are completed experiments, not tasks to acquire new private evidence.

`scripts/check-v1-18-decision-binding.py` still validates the immutable
Phase-75/78/79 decision and archived inventory. It does not bind the current
editor to that historical implementation or prohibit the later explicit
compatibility API. Resolution failures expose normalized reasons only;
child transcripts and private paths are not persistent evidence.

## Inactive Upper-Eyelid Prediction Reliability

The learned/data route was canceled on 2026-08-25 and remains paused under the
2026-10-01 suspension. `BeautyUpperEyelidFullnessPredicting` has no registered
implementation or model resource; the explicit compatibility route does not
use it. The retained validator rejects invalid requests before a predictor
call and rejects missing, malformed, non-finite, out-of-support or incorrectly
owned results. It enforces confidence/uncertainty, alpha/flow/tone boundaries,
local continuity and fold-over limits, with independent per-eye rejection and
no proposal on failure. The exact retained bounds are in [DESIGN.md](DESIGN.md).

The historical fixed-output/model-conversion/review workflow is not a current
reliability obligation. Historical validator tests prove rejection and
recovery mechanics only, not model availability or effect quality. Candidate
failures do not prove all no-model routes impossible or a learned replacement
sufficient; a new owner request would need a separately evidenced design.

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

At Phase 90 close, the compatibility surface had 62 stored parameter fields,
five presets, 75 renderer cases, `BeautyEngine.processResult(image:metadata:parameters:)`,
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
