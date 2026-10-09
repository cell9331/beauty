# RELIABILITY.md

## 2026-10-09 sustained simulator detection limitation

The adjacent owner host's sustained nose regression exposed progressively
out-of-image landmarks on the same iPhone 15 Pro / iOS 17.5 simulator after
repeated requests. Independent Vision requests against unchanged source pixels
also reproduce it; request revisions, legacy CPU mode and independent raster
copies did not remove it. Explicit selection of the advertised GPU immediately
returns Vision code 9, so that path cannot substitute for CPU. The internal
platform cause remains unidentified.
The SDK retains its existing `.partial / .mappingFailed` summary and safe
abstention; no malformed support, fabricated point or lower threshold is admitted.
This task does not modify SDK production code or replace the previous no-skip
receipt. A few successful native face calls do not establish sustained inference.
Host debug mode displays the observed points/revisions/reasons and may expose
drift rather than qualify accuracy. Aggregate checks, the failed nose oracle and
the passed bounded host tests are separately scoped in the
[repair record](plans/history/2026-10/A-2026-10-08-owner-editor-debug.md).

## 2026-10-08 simulator Vision compute compatibility

The newly authorized external owner editor exposed `com.apple.Vision / 9` in
the default face-landmark inference path on the reused iPhone 15 Pro / iOS 17.5
simulator. `VisionFaceDetector.defaultObservationProvider` now selects advertised
CPU devices for each compute stage under `targetEnvironment(simulator)` using
[Apple's compute-device API](https://developer.apple.com/documentation/vision/vnrequest/setcomputedevice(_:for:)).
Physical-device and macOS requests retain Vision's default policy. No public
configuration, target boundary, model, Metal implementation or effect semantics
changed; unavailable detection still yields the existing redacted typed summary.

The native editor's actual authorized portrait now uses one detected face,
changes output pixels and repeats identically. The archive-first full SDK gate
passed **1076 tests / 0 failures / 0 skips, 9 opt-ins**. This does not establish
physical-device performance or new algorithm qualification. The separate host's
system person-segmentation positive still failed on this simulator and was not
converted into a successful protection result; its macOS pass is separately
scoped. Details are in the [owner-host record](plans/history/2026-10/A-2026-10-08-owner-ios-editor.md).

## Current reliability contract

The SDK-only SwiftPM facade returns stable typed errors or documented local
degradation. Invalid input is rejected before expensive dependent work;
request-owned support/proposals never contaminate a later valid request.
One engine requires caller serialization. Conditional result sendability does
not make framework payloads or an engine safe for shared parallel use.

| Condition | Current behavior |
| --- | --- |
| Invalid extent, dimensions, byte/pixel limit, single-frame encoding or mask | `.invalidInput` through the applicable preflight. |
| Unsupported pixel format | `.unsupportedPixelFormat`; pixel-buffer input is BGRA. |
| Invalid resource ID / resource decode | Typed resource error with a fixed/redacted description; IDs never become arbitrary paths. |
| No face / disabled or skipped detection | Remove dependent work, preserve supported global color/filter work. |
| Malformed/low-confidence/ambiguous support | Field/side-local abstention; valid peers survive without borrowing support. |
| Empty provider | Remove its strengths, domains, counts, warnings/metrics and dispatch consistently. |
| Local composition collision | Preserve the original source pixel. |
| Explicit unavailable GPU | Terminal `.metalUnavailable`; no CPU retry or parity credit. |
| Over-capacity GPU still geometry | Pre-dispatch full-plan CPU route only when no row-restricted point exists; emit its capacity metric. Direct Metal/row-restricted paths keep typed failure. |
| Missing fixture opt-in | Plain SwiftPM may report its established skip; the complete gate rejects any skip. |

The error enum and associated-value redaction are defined in
[BeautyError.swift](BeautySDK/Sources/BeautyCore/Models/BeautyError.swift).
Framework messages, private paths, raw pixels and geometry must not become
public error/report content.

## Request recovery and bounds

Still-image retouch canonicalizes once, detects/maps once, creates one request
context, derives independent units from original pixels and composes once.
Rejected eyes/features do not poison siblings or subsequent requests. Texture
requires fresh face bounds on both still-image and pixel-buffer routes; disabled,
missing or interval-skipped support leaves it inert. Indexed camera/video frames
never recover support from a prior frame. Geometry's package-internal freshness
rules do not imply observation reuse in the public facade.

Source-admitted still-image refiners suppress corresponding legacy point
emissions even if source admission fails. Hairline/forehead ambiguity, brow
overlap, absent registered lip support, detached head foreground and unsupported
submental boundaries fail source-exact within their qualified tests. The direct
color pipeline cannot discover a face and cannot authorize texture without
package-internal supplied face bounds.

All decoded inputs obey `maximumInputPixelCount`, default/hard maximum
50,000,000. Encoded stills additionally obey the 32 MiB default byte limit and
declared-dimension checks before decode. Active texture obeys the smaller
8,388,608-pixel ceiling; its three RGBA8 buffers account for at most 96 MiB,
excluding system/Core Image/Metal overhead. A supplied texture mask adds at
most one byte per pixel and must match canonical dimensions even at neutral
strength. A failed mask request does not retain protection for a later call.

Default renderer discovery/batches omit suspended upper-eyelid correction;
explicit legacy calls preserve compatibility and safe rejection. Reconstruction,
quantization and calibrated Vision checks do not repair its failed natural
appearance. Coarse skin/eye/lip guards also do not reliably protect all
skin-colored objects or low-contrast lip borders. The
[explicit union mask](docs/HOST_TEXTURE_PROTECTION.md) protects known pixels
from texture only. EYE/SEG closure leaves these limits visible without creating
an automatic continuation or claiming universal rejection of unknown inputs.

## Renderer and current batch results

`BeautyExampleRenderer` accepts the CPU CLI token only, with 98 default and
99 registered case identities. Unknown/duplicate arguments, invalid paths,
case-insensitive duplicate output stems, malformed images and incomplete work
fail nonzero. A unit is credited only after atomic PNG write, nonempty regular
file verification, ImageIO reopen and exact input-dimension validation.
Requested/succeeded/failed/skipped counts must reconcile; report-write failure
also prevents success. Test-only render/encode failure seams are not CLI flags
or public SDK APIs. Child capture and temporary outputs are bounded.

The [current batch tool](docs/CURRENT_BATCH_VALIDATION.md) checks independent
ordered inventory and two decoded outputs per input/case. `passed`, `abstained`,
`effect_failed`, `execution_error` and `unverified` are separate outcomes:
exit 0 satisfies the declared pixel rules, 1 is effect failure, 2 execution/input
error, and 3 missing oracle. Inventory-only preflight never earns pixel credit.
Subprocess groups are cleaned up after timeout/overflow, including descendants
whose parent exited. Missing output, extra output, nonzero child exit or receipt
failure cannot be repaired into success. The old 75-case wrapper is historical.

## Mandatory SDK gate

`bash scripts/run-no-skip-swiftpm.sh` performs archive verification, boundary
self-test/live scan, example storage, historical v1.18 binding self-test/live
check, sequential backend/runtime/feature/configuration/parity preflights,
public consumer and generated CPU oracle checks before one full SwiftPM child.
Exact order and expected opt-ins are owned by the script and its mutation test.

The child transcript is capped at 16 MiB/200,000 lines and removed after parsing.
Preflight failure prevents that child. Acceptance requires one nonzero,
zero-failure XCTest aggregate, all nine opt-in identities exactly once,
zero skip/disabled events and, if Swift Testing starts, one passed aggregate.
Missing, ambiguous, oversized, failed or zero-test output fails regardless of
child exit status. Nine test identities and the five explicitly assigned child
environment inputs are distinct counts; fixture overrides may be inherited.
Historical v1.18 resolution uses explicit repository-root, unique regular-file
active/archive paths and normalized failure reasons without rebinding old receipts.

Actual image output must pass the owning pixels/metadata oracle; script completion
alone cannot qualify an effect. Generated inputs are eligible under the
[acceptance policy](docs/IMAGE_EFFECT_ACCEPTANCE.md). Missing physical devices or
optional user feedback never blocks this gate.

## Storage, archive and observations

The archive verifier uses pinned ZIP/manifest identities, bounded streamed
hashing/extraction, path/symlink defenses and rollback. Corruption, unsafe
restore or SDK-only boundary violation prevents closeout. Restore only into a
fresh outside-repository temporary directory under
[the archive contract](archives/legacy-ui/README.md).

[Example storage](example-images/README.md) rejects quota, link/special-file,
manifest or undecodable-preview failures with sanitized fixed reasons. Checks
do not delete files. Cleanup touches only classified regenerable caches;
required inputs/current bundles and unknown files remain. The full `.build`
tree contains frozen sources/receipts and cannot be treated as disposable cache.

Observations are result-local fixed codes, counts and bounded timings; debug/
performance flags create no persistent or OS logger. Facade timing excludes
deferred image evaluation and proves no target-device latency, peak memory,
frame rate, thermals, battery or endurance. Device feedback is optional and
becomes a sanitized reproducible issue in [PLANS.md](PLANS.md). Current known
simulator failures remain distinct from successful bounded SDK/host evidence.
Latest executed engineering checkpoints are linked from
[QUALITY_SCORE.md](QUALITY_SCORE.md); document edits never re-sign them.
