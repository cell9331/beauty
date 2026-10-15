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
All six nose fields (`noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`,
`noseRootNarrowing`, `noseTipLift`) are signed, including reconstruction and
mutable normalization. Keys, zero defaults and absolute safety caps are unchanged.
Positive size/wing/tip/root/bridge contract their image-plane region; negative
values expand it. Positive lift moves tip support up; negative moves it down.
Fresh dense still images now use an eye-axis-aligned continuous nasal field.
Size adjusts lateral width while preserving axial height; Tip separately shapes
the bulb above the nostrils, with a stronger positive contraction. Root and
Bridge cover distinct short upper and longer dorsal bands. The same immutable
source defines complete eye/brow/lip protection and smooth exterior falloff.
Each field has fixed signed-cap admission before combined-field gradient and
displacement checks; a tiny new sibling cannot abruptly re-budget prior work.
Missing required nose/protection observations clear dense nasal requests and
cannot restore circular kernels. Planner admission does not require proxy point
emission. Historical Vision geometry remains compatible. See
[dense geometry](docs/sdk/DENSE_FACE_REFACTOR.md).

Unit controls normalize to `0...1`, signed controls to `-1...1`; nonfinite
values become neutral. Algorithm-specific caps and combination budgets are
separate from public ranges. Default numeric controls are zero and `filterId`
is `nil`, requesting no effects; neutral pixel assertions account for the owning
orientation/color/copy route. The resolver derives strengths, domains, warnings,
metrics and emitted geometry from one admitted set, removing unsupported work
without leaving ghost strength or points. Hosts submit value snapshots rather
than storing slider state in the SDK. The five built-in presets are neutral.

`faceSlim`, `faceSmall`, `jawSlim`, `templeFullness`, `cheekboneSlim` and
`chinTaper` now normalize/reconstruct as signed values with unchanged keys,
zero defaults and absolute caps. `BeautyFaceShapeSlider` maps a host's 0...1
position over those caps; centered controls are neutral at .5, V-face/smoothing
at 0. Its chin-length direction is shortening-positive, while direct API
positive chin length remains longer. No slider view/state belongs to the SDK.
See [mapping and implementation](docs/sdk/FACE_SHAPE_SLIDERS.md).

Eleven eye geometry fields now accept both signs, including reconstruction,
resolver caps and backend admission; combination budgets use absolute values.
The existing keys, zero defaults and absolute caps are retained.
`BeautyEyeShapeSlider` maps a host's 0...1 position with neutral at .5 and an
inverse mapping for selection/undo. Its tilt polarity follows the reference:
rightward lowers the outer corner and raises the inner corner, opposite direct
positive `eyeTilt`. Observed-eye still images use a continuous local field;
the first five controls have aperture-centered scale and shared image-axis
position directions, with bounded source-RGB registration for position span
and the size/length horizontal pivot. Ambiguous source evidence keeps the geometric frame;
negative iris size requires a valid dense visible iris ring. Sparse positive
pupil behavior remains compatible. Dense pupil strength is excluded from the
eye lattice and legacy points. The shared pre-geometry `BeautyIrisScaleRemap`
uses an observed horizontal-ring circle, one signed inverse scale and a
Hermite band with C1 inner/outer joins and an analytically positive radial
derivative. Both backend selections use this CPU remap on immutable stage
sourceRGBA; later geometry carries its result. Fixed opening/window/feature
exteriors remain source-exact. Four bilinear source pixel centers need geometry
ownership before RGBA use and opaque alpha255; any required unsafe sample
abstains for that whole eye. Negative geometric occlusion may estimate only
same-eye, same-radius two-sided polar color, with an inner-core catchlight veto;
it does not recover hidden tissue or replace legal uniform-scale samples.
A negative-only white illumination field is admitted only when at least32
distributed existing-owned opaque four-tap white samples fit a conditioned
2D affine RGB field with every residual at most1 code. All prospective target
values must also remain in RGB range or the whole field falls back to the
existing sampler. The field evaluates destination illumination through C1
white-only entry weights after the required original sample checks; uniform
iris core, source owner and destination protection do not expand. This
conditional model does not classify tissue or reconstruct arbitrary photographic
white material.
Zero-pupil, sparse compatibility and other old eye paths retain their behavior.
The old lattice .45 bound is not a derivative bound for this independent
radial/color-mask path; new native effect acceptance remains pending.
[Eye contract](docs/sdk/EYE_SHAPE_SLIDERS.md).

All eight mouth geometry fields are signed, including `smile`,
`lipPeakDefinition` and `lipPlump`. Reconstruction, mutable normalization,
resolver caps, absolute combination budgets and backend admission agree;
keys, zero defaults and absolute caps are retained. `BeautyMouthSlider` maps
the external owner's centered positions over those caps and reverses size
and vertical position to make rightward mean smaller/upward. Direct size
positive still enlarges; direct Y positive moves down. Teeth whitening keeps
its separate one-way mapping. See [mouth contract](docs/sdk/MOUTH_SLIDERS.md).

All seven eyebrow geometry fields are signed, including `eyebrowPeakDefinition`.
Keys, zero defaults and absolute `.25` caps remain. `BeautyEyebrowSlider` maps
0...1 over those caps with `.5` neutral; rightward means up, thicker, longer,
wider spacing/head spacing, outer ends down and stronger peaks. Direct positive
Y still moves down and direct positive tilt raises outer ends. Negative peak
flattens the interior apex. Init/decode/normalization, resolver, absolute
combination budgets and backend bounds share this contract. See the
[eyebrow implementation guide](docs/sdk/EYEBROW_SLIDERS.md) and current plan
for source qualification and reference evidence.

Actual outer/inner lip observations now reach the shared still-image mouth
map. Pixel-space mouth axes govern scale, vertical translation and rotation;
horizontal position moves along upright image X with exactly zero field Y.
The inner opening independently constrains Cupid's bow and lip thickness.
Explicit invalid observed support exits without reviving template-point work.
The legacy coarse route retains its positive behavior for old consumers.
X/M/fullness slider components have independent source-fixed admission before
their actual sum is bounded, preserving continuity when another control crosses
neutral. Negative M follows the source flattening target within the tissue.
Negative fullness projects its fixed endpoint through a shared-edge scalar
minorant, then uses a calibrated continuous response with pose applied once;
the complete fixed oral band, feature, halo and original safety limits remain.
Thin-source positive M shortens only its exterior transition. Horizontal
position uses an analytic source-support sweep with a shared material-corner
plateau and fixed radial/terminal transition profiles. Visible whole-lip
rigidity and reference amplitude require independent pixel evidence. See the
[mouth contract](docs/sdk/MOUTH_SLIDERS.md) for implementation and limits.

[BeautyConfiguration](BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift)
has 11 stored fields and is captured by `BeautyEngine` at initialization.
Later mutation of the caller's copy does not change that engine.

| Field | Implemented meaning |
| --- | --- |
| `preferredProcessingSize` | Optional finite positive maximum detector raster width/height; no output resize. MediaPipe applies it after upright normalization. Invalid values become `nil`. |
| `maximumFaceCount` | Detector selection cap and iOS MediaPipe output cap, at least one at init/decode; iOS native budgets above 32 abstain before allocation. Effects still use the primary face. |
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

Detection/support remains package-only. Ordinary facade calls keep observations
request-local and never reuse earlier face support. Unindexed still-image calls
detect when required. Indexed camera/video calls require a nonnegative index
and camera/video metadata; only multiples of the configured interval detect.
Skipped frames return `.skipped / .detectionInterval` and remove dependent work.
Invalid support fails at the smallest field/side rather than being guessed or
borrowed. Detector `usedFaceCount` is a selection count, not an edited-face count.

The default iOS detector is pinned MediaPipe 1.1.0 in synchronous CPU image
mode; macOS retains Vision. Image mode intentionally supplies no temporal
tracking/smoothing or timestamp contract. Inference receives upright pixels after
EXIF and explicit input-mirror normalization; its normalized points already
match the render grid. A malformed 478-point mesh rejects that face; a malformed
optional transform only removes the transform, preserving valid point support.
MediaPipe exposes no per-face confidence value in this task result: the internal
admission marker means the configured 0.5 detection/presence thresholds passed,
not a probability or certainty score. Pose/visibility/occlusion estimates do not
replace existing regional support admission. Dense points and transforms are
non-Codable internal source/request data and never appear in standard render results. The owner's
explicit `OwnerDiagnostics` SPI separately returns only transient x/y samples for
an in-memory overlay; pose stays internal and all durable diagnostics stay aggregate.

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

### Explicit fixed-photo preparation

`prepareStillImage(image:metadata:)` accepts only `.photo` RGB8 `CGImage` and
deep-copies its checked raster bytes while retaining its bitmap/color/alpha and
metadata meaning. One current source belongs to an engine; public handles carry
only opaque identity and dimensions. Successful replacement/reset/release expires
old handles; invalid prepare preserves the prior source. Wrong-engine/expired
handles fail with `invalidInput` before inference. Original and canonical detector
rasters and geometry/local/combined purposes have separate bounded entries.
Only usable/no-face results are reused; partial/unavailable/low-confidence results
retry without borrowing another purpose's support. Neutral/disabled work does
not detect. Fixed-source reuse is not cross-frame `.reused` landmark freshness:
the observed pixels are still the exact immutable input of the current render.
All parameter-dependent maps, source admission, retouch and masks remain fresh.
`beauty.detection.preparedReuse` reports 0/1 only when this route requires detection;
the detection summary retains its original outcome and any original timings.
See [prepared photo contract](docs/sdk/PREPARED_PHOTO_EDITING.md).

The separately requested CPU `processIrisPreviewResult(preparedImage:maximumPreviewEdge:
parameters:textureExclusionMask:)` consumes an original-bound prepared photo,
with maximum edge 1...960 (default 960), and returns an opaque upright sRGB
thumbnail rather than the original extent. GPU entry, expired/foreign handles,
invalid edge or a mask outside the original canonical grid fail with typed
`invalidInput`; the mask is not a preview-grid mask. Its explicit resize does
not change ordinary `processResult` same-extent/backend contracts or prepared
replacement/release/reset rules. Original normalization/local composition and
an independent original color/texture/source-refiner/iris prefix precede resize.
With no mask, the companion baseline resizes the source first, then runs existing
view color/texture/refiners. An explicit original-grid mask retains the original-
prefix baseline without lending the mask to a view grid. The same-original-prefix
companion identifies exact unchanged IR pixels only for skipping a copy; hard
geometric ownership remains the sole edit authorization. Remaining geometry runs
once after clipping. With unchanged C61 SDK rendering source, C74 actual original
and explicit CPU preview each pass their bound frozen numeric, fixed partial-arc,
declared protection, neutral and repeat gates on one edited portrait. This does
not qualify a full semantic circle or general appearance; a thin lower gray rim
remains. The same C74 source passes the iPad's actual Metal original/independent
CPU parity and explicit CPU preview photo checks. A targeted old-ten photo
method and six host checks pass. The two dated C74 iPad panel attempts fail their initial foreground-scene
guard before layout assertions; those failures remain intact. C75's bounded
active/unique scene and key-window wait subsequently executes the unchanged
physical Panel assertions:1 passed/0 failed/0 skipped, with three native generated-
input screenshots inspected. This proves that Panel case's layout scope, not
portrait/touch quality or gray-rim repair. The [active follow-up](plans/active/A-2026-10-15-iris-gray-panel-repair.md)
retains failed gray-rim appearance qualification and the separate local owner
experiment. The
[iris preview API contract](docs/sdk/EYE_SHAPE_SLIDERS.md#原图先行的-iris-preview-api)
owns usage, ordering and qualification limits.

Providers produce validated request-local `WarpControlPoint` sets into one
geometry pipeline. Field-local caps, finite/bounded source and target checks,
support freshness and aggregate conflict budgets apply before dispatch.
On fresh dense still-image support, mapped fields retain their independently
capped signed strengths; the old sum-of-parameters quota does not represent
their actual combined displacement. The final shared inverse map enforces
pixel displacement, per-triangle gradient and pose bounds. The nine fields with
source-raster refinement/admission or post-map translation retain a separate
conservative sum budget: contour smoothing, hairline/forehead height, both
double-chin controls, head wrap, philtrum length and whole-face x/y translation.
Legacy support retains its previous all-geometry conflict budget. No public
range, default or cap changes; requested values are distinct from admitted
output strength. See [exact dense behavior](docs/sdk/DENSE_FACE_REFACTOR.md).
Provider-empty work is removed consistently from the final plan. Observed
eye, brow, nose and lip support is not part of the standard geometry/UI API.
The owner-only diagnostic overlay has its separate upright top-left x/y contract.

Still-image source admission additionally qualifies contour smoothing,
hairline/forehead displacement, outer submental tiers, philtrum and rigid
whole-face translation. The source-raster refiners suppress their legacy point
routes even when admission rejects. Ambiguous hair/skin/lip/head boundaries
remain source-exact rather than reverting to a proxy. Head wrap requires a
coherent source hair cap. Whole-face X/Y provider points remain narrower
mechanics; admitted still images use rigid translation. These are bounded 2D
image operations, not depth, fat or general segmentation estimates.

The internal `BeautyStillImageGeometryStage` now prepares the raster and final
points once per admitted geometry stage on either backend. Head-wrap/philtrum
admission still reads the contour-refined, pre-hairline/submental raster.
CPU passes its already-colored raster; Metal passes its textured raster and
keeps its color pass before the dense sampler. A rejected dense map preserves
the supplied raster; rigid translation follows the selected sampler. CPU's
neutral preflight and canonical rasterization callback are unchanged. Both
executors construct existing aggregate diagnostics through one bounded initializer.

Dense still images use a fixed full-canvas inverse lattice, pixel-metric radius,
canonical centers, final displacement and per-triangle gradient bounds; validated
pose can only attenuate that map. Visible iris rings and geometric feature
exclusions stay request-local. [Exact mechanism and limits](docs/sdk/DENSE_FACE_REFACTOR.md)
separate this CPU-owned stage from the retained legacy point renderer.

The legacy Metal uniform capacity is 256 points. A selected-GPU still-image plan over
capacity without row restrictions executes the entire admitted plan once on
CPU and reports `beauty.backend.cpuGeometryCapacityFallback = 1`. No strength
or point is silently discarded. Direct Metal and row-restricted over-capacity
requests retain typed failure; unavailable GPU and runtime errors never retry.

Observed, lip-registered still images use a continuous source-anchored contour
band for eight face/chin fields, with local pixel axes, fixed feature boxes and
cap-shape gradient/displacement bounds. It follows other legacy/dense sampling
and precedes rigid translation on both executors; corresponding eight points
are suppressed even when new-map admission rejects. Coarse historical positive
fixtures remain on their old route; new negative fields require registration.
This contour stage preserves source color/extent/alpha. Stages have separate
bounds, so their composition is not a single all-field 6% displacement budget.
Soft hair/skin boundary admission now supplements the prior hard-edge route;
ambiguous/bangs-like boundaries still abstain. [Details](docs/sdk/FACE_SHAPE_SLIDERS.md).

## Texture and exclusion masks

`skinSmoothing` lowers bounded source luminance-detail variation;
`skinSharpen` increases it through source-edge admission. The shared CPU-owned
stage runs on both selected backends with 3×3/5×5/7×7 footprints. It requires
fresh primary-face bounds, a conservative interior ellipse and eye/lip/color/
edge guards. Bilateral range weights and separate smoothing/sharpen detail
branches prevent the former constant-gain cancellation. Dense still support adds
oval containment and padded eyelid/brow/lip exclusions; these are unioned with
existing coarse and host guards, not anatomical or skin-material segmentation.

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
See [host protection](docs/sdk/HOST_TEXTURE_PROTECTION.md) for the object + full-lip union.

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
[terminal report](docs/history/retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md).

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
The [image acceptance policy](docs/validation/IMAGE_EFFECT_ACCEPTANCE.md) requires joint
source-defined direction/negative/protection/metadata/repeat/failure evidence.
Generated inputs are eligible; genuine portraits and physical devices are
optional. Exact status and bounded input ranges belong to the taxonomy,
not historical candidates, changed-pixel counts or full-suite success alone.
