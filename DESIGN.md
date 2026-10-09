# DESIGN.md

## Current design ownership

The SDK-only SwiftPM design is defined by implemented value models, resolver,
providers and facade tests. [ARCHITECTURE.md](ARCHITECTURE.md) owns target
direction; [taxonomy](docs/SDK_EFFECT_TAXONOMY.md) owns control mappings and
qualification. Historical phase contracts are evidence for their dated inputs,
not alternative current models or a continuation queue.

## Parameters and configuration

[BeautyParameters](BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift)
has 77 stored fields: 76 numeric controls and optional logical `filterId`.
Unit controls normalize to `0...1`, signed controls to `-1...1`; nonfinite
values become neutral. Algorithm-specific caps and combination budgets are
separate from public ranges. Default numeric controls are zero and `filterId`
is `nil`, requesting no effects; neutral pixel assertions account for the owning
orientation/color/copy route. The resolver derives strengths, domains, warnings,
metrics and emitted geometry from one admitted set, removing unsupported work
without leaving ghost strength or points. Hosts submit value snapshots rather
than storing slider state in the SDK. The five built-in presets are neutral.

[BeautyConfiguration](BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift)
has 11 stored fields and is captured by `BeautyEngine` at initialization.
Later mutation of the caller's copy does not change that engine.

| Field | Implemented meaning |
| --- | --- |
| `preferredProcessingSize` | Optional finite positive maximum Vision raster width/height; no output resize. Invalid values become `nil`. |
| `maximumFaceCount` | Detector selection cap, at least one at init/decode; effects still use the primary face. |
| `enableFaceTracking` | Enables detection-backed support; disabling it removes dependent work. It is not a promise of cross-frame support reuse. |
| `detectionFrameInterval` | Explicit indexed camera/video cadence, normalized to at least one. |
| `renderQuality` | Active texture footprint: `.performance` 3×3, `.balanced` 5×5, `.quality` 7×7. |
| `enablePerformanceLog` | Adds synchronous facade duration to a successful in-memory result. |
| `enableDebugMode` | Allows the fixed backend-stage diagnostic only at debug verbosity. |
| `logLevel` | Maximum verbosity of fixed result events; no persistent/OS log sink. |
| `maximumInputByteCount` | Encoded `Data` limit, default 32 MiB; nonpositive values return to default. |
| `maximumInputPixelCount` | Decoded/pixel-buffer limit, default and hard maximum 50,000,000; nonpositive values return to default. |
| `renderBackend` | Exactly `.cpu` / `.gpu`, default `.cpu`, including missing legacy decode key. |

The byte/pixel limit and backend keys are additive decode defaults; this does
not make every configuration key optional. Direction, source, input mirror and
preview mirror belong to
[BeautyInputMetadata](BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift),
not global configuration. Presets encode parameters, never execution policy.

## Input, detection and output

Decoded `CIImage` and BGRA `CVPixelBuffer` entries enforce configured pixel
bounds. Encoded `Data` additionally requires nonempty bytes within its byte
limit, exactly one ImageIO frame and valid declared dimensions before decode;
decoded dimensions are rechecked. Explicit metadata supplies orientation rather
than independently applying encoded EXIF orientation a second time.

Opaque still-image retouch or an exclusion mask uses one canonical upright,
input-mirror-corrected sRGB raster. Transparent local-retouch input is rejected.
Selected GPU still images require the retained opaque bounded-RGB admission.
Other decoded-image behavior keeps its existing route-specific extent/color/
alpha contract; no global transparent-input claim is made.

Detection/support remains package-only and request-local. The current facade
does not cache or reuse prior face observations. Unindexed still-image calls
detect when required. Indexed camera/video calls require a nonnegative index
and camera/video metadata; only multiples of the configured interval detect.
Skipped frames return `.skipped / .detectionInterval` and remove dependent work.
Invalid support fails at the smallest field/side rather than being guessed or
borrowed. Detector `usedFaceCount` is a selection count, not an edited-face count.

No-face routing is explicit: a detected no-face request skips face-dependent
geometry and the skin domain while preserving supported global color/filter
work. Standalone whitening/rosy tone can use a no-detection color route; a skin
combination containing texture requests detection and must respect no-face
abstention. Active texture requires fresh face bounds even on pixel-buffer
input. Pixel-buffer input does not activate facial geometry or local retouch.

[BeautyResult](BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift) carries
output, redacted warnings, aggregate metrics, detection summary and fixed-code
events. Only sendable output makes the result sendable. One engine is serialized
by its caller; independent engines may execute concurrently. `reset()` clears
detector/testing state and advances the reset generation; it does not enable
an asynchronous stream, shared-instance parallelism or persistent support.

## Geometry and raster ownership

Providers produce validated request-local `WarpControlPoint` sets into one
geometry pipeline. Field-local caps, finite/bounded source and target checks,
support freshness and aggregate conflict budgets apply before dispatch.
Provider-empty work is removed consistently from the final plan. Observed
eye, brow, nose and lip support is not public geometry or a UI coordinate API.

Still-image source admission additionally qualifies contour smoothing,
hairline/forehead displacement, outer submental tiers, philtrum and rigid
whole-face translation. The source-raster refiners suppress their legacy point
routes even when admission rejects. Ambiguous hair/skin/lip/head boundaries
remain source-exact rather than reverting to a proxy. Head wrap requires a
coherent source hair cap. Whole-face X/Y provider points remain narrower
mechanics; admitted still images use rigid translation. These are bounded 2D
image operations, not depth, fat or general segmentation estimates.

The Metal uniform capacity is 256 points. A selected-GPU still-image plan over
capacity without row restrictions executes the entire admitted plan once on
CPU and reports `beauty.backend.cpuGeometryCapacityFallback = 1`. No strength
or point is silently discarded. Direct Metal and row-restricted over-capacity
requests retain typed failure; unavailable GPU and runtime errors never retry.

## Texture and exclusion masks

`skinSmoothing` lowers bounded source luminance-detail variation;
`skinSharpen` increases it through source-edge admission. The shared CPU-owned
stage runs on both selected backends with 3×3/5×5/7×7 footprints. It requires
fresh primary-face bounds, a conservative interior ellipse and eye/lip/color/
edge guards. These are not anatomical or skin-material segmentation.

An active texture request is limited to `min(maximumInputPixelCount, 8_388_608)`
pixels at decoded, encoded-declaration, pixel-buffer and backend boundaries.
Three RGBA8 buffers account for at most 96 MiB; this does not bound all system/
Core Image/Metal peak memory. Source alpha and protected bytes retain their
existing per-route contract.

[BeautyTextureExclusionMask](BeautySDK/Sources/BeautyCore/Models/BeautyTextureExclusionMask.swift)
has positive dimensions, one byte per pixel and only `0`/`255` values. Its grid
must match the upright input-mirror-corrected raster. `255` protects that pixel
from smoothing/sharpening only; `0` retains existing admission. It adds no
support and cannot enable a no-face request. Dimensions are checked even with
neutral parameters. Only decoded/encoded still-image result entries accept it;
it never becomes engine state, Codable output or raw diagnostic data.
See [host protection](docs/HOST_TEXTURE_PROTECTION.md) for the object + full-lip union.

## Local-retouch composition and suspended compatibility

Teeth and sclera intent uses one canonicalization, one detection/mapping
handoff, one request context and one immutable-source composition transaction.
Each provider reads original pixels under independently valid local support.
The composition owner enforces hard containment, protected bytes, source alpha/
metadata, bounded units and collision-to-source behavior. Per-eye/feature
rejection leaves valid siblings eligible; no prior request proposals survive.
Pixel buffers do not activate these controls. Composition stays CPU-owned
before the selected backend transport.

`upperEyelidFullnessReduction` retains zero default, normalization, Codable,
explicit facade/CLI calls and `BeautyExperimentalUpperEyelid*` safety code.
Its observed brow/lid envelope bounds luminance-proxy edits; it does not
identify fat, recover morphology, borrow peer-eye authority or alias eye/brow/
smoothing controls. Plane/residual reconstruction and quantization repairs
prove bounded mechanics only. Natural-appearance qualification failed, so
the control is `suspended` and omitted from default examples/discovery/batches.
The inactive prediction validator has no registered predictor or model asset.

v1.25's automatic eyelid-tone and patch-protection branches both closed as
unmet after their finite budgets. No full EYE G0, candidate holdout or production
integration is queued. Current failure and restart semantics are owned by the
[terminal report](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md).

## Diagnostics and acceptance

Successful result events are closed code/level values: `.none`/`.error` emit
none; `.warning` can emit `warningsPresent`; `.info` also `requestSucceeded`;
`.debug` emits `backendExecuted` only with debug mode enabled. Events contain
no input content or free-form framework messages. Typed failures throw.

With performance logging enabled, a successful result adds finite nonnegative
`beauty.performance.facadeElapsedMilliseconds`. It measures synchronous facade
time using a monotonic clock; encoded input includes preflight/decode, deferred
CIImage evaluation is excluded. Convenience output-only calls do not expose it.

Compatibility, safe mechanics and useful effect qualification are distinct.
The [image acceptance policy](docs/IMAGE_EFFECT_ACCEPTANCE.md) requires joint
source-defined direction/negative/protection/metadata/repeat/failure evidence.
Generated inputs are eligible; genuine portraits and physical devices are
optional. Exact status and bounded input ranges belong to the taxonomy,
not historical candidates, changed-pixel counts or full-suite success alone.
