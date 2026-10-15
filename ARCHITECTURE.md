# ARCHITECTURE.md

## Current repository contract

`beauty` is an SDK-only SwiftPM repository for the project owner's local Apps
and tools. [Package.swift](BeautySDK/Package.swift) owns the build graph: iOS 17
and macOS 14, one `BeautySDK` library product, one `BeautyExampleRenderer`
executable product, six library targets and six test targets. Three pinned
official MediaPipe 1.1.0 binary targets are dependencies on iOS only; there
are no remote source-package dependencies. The float16/1 Face Landmarker model
is bundled in Detection and checked against its fixed size/SHA-256 at native
task initialization. [Provenance and licenses](BeautySDK/ThirdParty/MediaPipe/README.md)
own the exact assets. The package remains a local-path owner consumer.
Swift `public` describes the owner's callable surface, not third-party distribution.

Historical UI/Demo material is confined to verified `archives/legacy-ui/`
artifacts. [FRONTEND.md](FRONTEND.md) owns recovery and the separately authorized
external editor boundary. No application source or lifecycle belongs to SDK targets.
Current work and limitations are owned by [PLANS.md](PLANS.md); dated file/line
inventory and executed gate evidence are recorded once in [QUALITY_SCORE.md](QUALITY_SCORE.md).

## Target ownership

| Target | Dependencies | Responsibility |
| --- | --- | --- |
| `BeautyCore` | none | Shared/public values, canonical carrier, redacted diagnostics and bounded package-only Core Image contexts. |
| `BeautyDetection` | Core; three MediaPipe binaries on iOS | Platform detector, mapping, selection and package-only observed mesh/support. |
| `BeautyRender` | Core | Render primitives, pixel buffers, bundled retained shader and package-only Metal runtime. |
| `BeautyResources` | Core | Bundled manifest, presets, LUTs and logical resource-ID validation. |
| `BeautyEffects` | Core, Detection, Render, Resources | Resolver, safety caps, geometry/color/texture pipelines, local-retouch providers and composition. |
| `BeautySDK` | all five internal targets | Public facade, immutable backend selection and request policy. |
| `BeautyExampleRenderer` | SDK only | CPU command-line consumer, case discovery, validated PNG outputs and aggregate reports. |

Owner hosts import only the `BeautySDK` product. The local-path consumer in
`IntegrationTests/` exercises that same boundary; it is a validation fixture.
Raw detection/support types and backend injection remain package-only.
`BeautyResult<Output>` is `Sendable` only when `Output: Sendable`;
`BeautyEngine` requires caller-serialized access.

## Processing routes

The [engine](BeautySDK/Sources/BeautySDK/BeautyEngine.swift) accepts decoded
`CIImage`, in-memory encoded still-image `Data`, BGRA `CVPixelBuffer`, and an
explicitly indexed camera/video `CIImage` route. Parameters are request snapshots;
configuration is captured at engine initialization.

```text
still image
→ validate dimensions, limits, resources and applicable color/alpha contract
→ canonicalize once when local retouch or an exclusion mask requires it
→ resolve face support: fresh detection, or valid explicit prepared-source reuse
→ resolve normalized strengths, provider admission and geometry budget
→ original-pixel local-retouch composition when requested
→ selected backend: shared texture/color, geometry and source-raster refiners
→ output, typed error, redacted warnings/metrics/diagnostic events
```

Encoded input preflights byte count, frame count and declared dimensions before
decoding one image, then delegates to the still-image route. Explicit metadata
owns orientation. Pixel-buffer input produces a distinct output buffer and
supports face-independent work; active smoothing/sharpening additionally requests
fresh face bounds. It has no detection-backed facial geometry or teeth/sclera/
upper-eyelid local-retouch route. No realtime throughput claim follows from this API.

Ordinary unindexed support-dependent still calls detect afresh. The indexed camera/video
route detects on indices divisible by `detectionFrameInterval`; other frames
abstain from face-dependent work without reusing prior observations.
`preferredProcessingSize` bounds only the detector raster, preserving output size.
Detection selects faces, but current still-image effects use only the primary face.

The explicit `prepareStillImage(CGImage, metadata:)` editing route deep-copies
one RGB8 photo into an engine-owned source. Its opaque handle authorizes only
that engine's current source. Prepared renders reuse usable/no-face detection
by purpose and original/canonical raster (at most six entries), while geometry,
texture, masks and local composition execute per snapshot. Replacement, release
and reset release the source/support and expire the handle. Ordinary still,
encoded and indexed frame routes retain their existing fresh/cadence contracts.
The external editor prepares each engine's fixed preview only; full-size export
uses fresh support. See [prepared photo editing](docs/sdk/PREPARED_PHOTO_EDITING.md).

`BeautyFaceDetector.production()` chooses MediaPipe on iOS and Vision on macOS.
The owner's external editor can import `OwnerDiagnostics` SPI and serialize a
separate `BeautyOwnerLandmarkDetector`. It reuses that factory, canonicalizer and
pinned assets for transient upright preview/output re-detection, independently
of render-engine selection state. It adds no model copy, target or dependency.
`BeautyOwnerLandmarks` exposes 478 ordered x/y samples on iOS only to the owner's
in-memory overlay; standard result diagnostics and reflection stay aggregate.
The package compatibility name `VisionFaceDetector` remains available to existing
Vision-specific fixtures. The iOS provider uses CPU image mode, lazily reuses
the native task and recreates it on `reset()` or face-budget changes. It retains
no observations. All EXIF directions and explicit input mirroring are baked into
an upright raster before `MPImage`; mapped points bypass the Vision mapper to
avoid a second orientation transform. Preview mirroring does not affect inference.
`maximumFaceCount` also bounds the MediaPipe task's output face count.
The native task accepts budgets 1...32; larger values abstain before allocation.

The iOS mesh has 478 finite bounded x/y points and finite z, with an optional
validated row-major 4×4 facial transform. Ordered mesh subsets supply observed
eyes/iris centers, eyebrows, nose, lips, lower contour and median support. Existing
geometry uses detected nose/lip/contour points instead of face-box templates on
this route, retaining existing regional plausibility checks. The transform stays
request-local: validated near-rigid rotation now attenuates the dense unified
inverse map, rather than being applied to image pixels as a 4x4 warp.
Visible iris-ring points support size/gaze admission, while oval/eyelid/brow/lip
geometry adds conservative texture protection. Blendshapes remain disabled.
[Dense static-image contract](docs/sdk/DENSE_FACE_REFACTOR.md) owns the mechanism and limits.
The resolver distinguishes dense mapped fields from source-raster-dependent and
legacy fields. Dense mapped strengths reach the shared final map independently
capped; its physical displacement/gradient admission replaces their scalar sum
quota. This changes no target, dependency, retained shader or public API boundary.
No second detector is invoked on failure. These changes do not qualify new beauty
effects or guarantee arbitrary pose/occlusion accuracy.

## Backend and effect ownership

`BeautyConfiguration.renderBackend` is exactly `.cpu` or `.gpu`, with `.cpu`
as the default and permanent reference. `BeautyBackendFactory` selects the
package executor at initialization. Explicit unavailable GPU terminates with
`.metalUnavailable`; construction/runtime failures never trigger retry.
The legacy point route has one separate still-image capacity route: over 256
geometry points without row restrictions execute the complete admitted plan on CPU,
with `beauty.backend.cpuGeometryCapacityFallback = 1`. Direct Metal calls and
row-restricted over-capacity plans retain typed failure. The retained
`Warp.metal` and GPU/API boundaries remain pinned by the boundary scanner.
The internal runtime uses uniform compute threadgroups with rounded-up width;
all retained kernels guard padded image-edge threads. This supports older
Apple3/A10 GPUs without nonuniform-dispatch support, retaining the same shader,
pipelines, resource/error semantics and backend selection.

Geometry providers feed one `BeautyGeometryEffectPipeline`. Dense still images
use a full-canvas lattice with fixed triangle connectivity, pixel-metric influence,
combined displacement/gradient bounds and canonical pixel centers. Both selected
backends share this CPU-owned stage; GPU does not also submit its old point pass.
`BeautyStillImageGeometryStage` owns request-local contour/hairline/submental
preparation, source admission, final control points and post-sampler translation
for both executors. CPU and Metal supply their rasters at the original stage
boundaries; their existing color order remains intact. Metal adapts the selected
face once and reuses the prepared points rather than repeating source admission.
The Metal 256-point bound applies only to the retained point route. Shared CPU-owned
still-image refiners implement source-admitted hairline/forehead, outer
submental contour, philtrum and whole-face translation behavior on both selected
backends. On these routes, corresponding legacy point emissions are suppressed
even if source admission rejects. Pixel buffers retain their separate admitted
capabilities; still-image qualification does not extend them.

Eight lip-registered contour fields additionally use `BeautyContinuousFaceMap`,
a request-local CPU-owned ROI lattice shared by both still executors. The
shared stage suppresses their old point emissions and applies the new sampler
after other legacy/dense geometry, before translation. Feature-edge knots and
fixed source kernels preserve protected regions. Each sampler has its own
gradient/displacement bound; this is not one all-field sampling transaction.
The target graph, model resources, retained shaders and pixel-buffer route are
unchanged. [Exact face behavior](docs/sdk/FACE_SHAPE_SLIDERS.md).

Six dense nasal fields use `BeautyContinuousNoseMap`, a request-local CPU-owned
ROI map shared by both still executors. Planning records admitted work separately
from legacy point counts; valid continuous work can have zero control points.
The dense carrier suppresses old nasal kernels even when regional admission
fails. Its eye-aligned axes and crest follow the immutable source, and complete
eye/brow/lip envelopes bound its protected regions. It follows the general
dense/legacy pass and precedes mouth and face/eye refinement. Signed field and
combined-map limits remain local to this stage. The Vision-only compatibility
route is retained. [Exact nasal contract](docs/sdk/DENSE_FACE_REFACTOR.md).

Eight observed mouth fields also use a request-local CPU-owned continuous
map shared by the two still executors. The adapter carries actual inner and
outer lips; planning preserves admitted strengths without emitting duplicate
legacy points. Shared preparation suppresses the old mouth points even when
the observed map rejects. The source-bound mouth axes use pixel distances,
and independently admitted inner support governs peak/thickness work. The
map follows existing nose geometry and precedes face/eye refinement and rigid
translation. No target, model, shader or pixel-buffer capability is added.
See [mouth contract](docs/sdk/MOUTH_SLIDERS.md).

Eleven observed eye fields use `BeautyContinuousEyeMap` in the same shared
still-image stage, following face-contour refinement and before rigid translation.
Pixel-space eye axes separate height, length and corners; the first five use
aperture-centered scale and image-axis position controls. A bounded source-RGB
edge check in the same request calibrates position span and the horizontal scale pivot.
Lower-lid work also derives an upper-trace clearance from the observed contour,
registers a bounded visible horizontal frame and confirms contrast at an already
validated dense iris core. These request-local checks retain neither pixels nor
new tissue labels and never replace regional support admission.
The stage suppresses matching legacy points even when observed admission rejects;
sparse positive pupil work retains its compatibility route. Dense visible iris
support admits both iris-size signs. Nonzero dense iris work independently samples
shape-only and full-iris colors from the same immutable input raster to this eye
stage, then blends colors under fixed material/protection ownership. The full
sample's four bilinear pixel centers must belong to its observed aperture, avoid
protected features and match alpha; rejection keeps eligible shape-only work.
Negative-only geometric occlusion projection still rechecks that ownership.
This is not sequential sampling of rendered output or a second geometry stage;
zero-pupil, sparse compatibility and the old eye fields retain their single-source
sampler. Source-fixed grids and feature protection
remain request-local; this adds no target, shader or pixel-buffer capability.
[Eye mapping and limits](docs/sdk/EYE_SHAPE_SLIDERS.md).

Skin smoothing/sharpening uses independent bounded detail branches with bilateral
range weights in the shared CPU-owned texture stage, with
fresh primary-face bounds, conservative face/eye/lip/color/edge admission and
a bounded pixel budget. `BeautyTextureExclusionMask` excludes known pixels only
from those two effects on decoded/encoded still images. It adds no detector or
semantic segmentation; [host integration](docs/sdk/HOST_TEXTURE_PROTECTION.md)
owns the exact grid and protection contract.

Teeth and sclera retouch share one opaque canonical carrier, detection/context
handoff and immutable-source composition owner. Per-feature/per-eye admission
remains independent; unexpected overlap preserves source. Composition is
CPU-owned before backend transport, so selected Metal does not imply end-to-end
GPU local retouch. Raw pixels, masks and support die with the request.

Upper-eyelid correction retains explicit compatibility through the same owner
chain but remains `suspended` and default-hidden. Its brightness proxy is not
tissue recognition. The inactive prediction validator has no registered model,
resource or inference route. v1.25's rejected EYE/SEG experiments were never
integrated; [terminal disposition](docs/history/retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)
creates no automatic follow-up. Exact control status is owned by the
[taxonomy](docs/SDK_EFFECT_TAXONOMY.md).

## Validation ownership

The renderer retains 99 registered identities and exposes 98 default cases;
explicit legacy upper-eyelid selection remains callable. It accepts only CPU
at its CLI boundary and validates persisted outputs before crediting them.
The [current batch tool](docs/validation/CURRENT_BATCH_VALIDATION.md), outside production
targets, independently checks ordered inventory and repeated decoded pixels.
The old 75-case wrapper is historical and incompatible with current inventory.

Current gates, fixture opt-ins and evidence scope are owned by
[QUALITY_SCORE.md](QUALITY_SCORE.md). Privacy, errors and caller recovery are
owned by [SECURITY.md](SECURITY.md) and [RELIABILITY.md](RELIABILITY.md).
New API, dependency, resource or backend work must update its owner documents
and public/target tests in the same change.

## Refactor reference

The [learning and refactor playbook](docs/refactor-playbook/README.md) explains
the implemented fixed-canvas dense map, bounded texture detail and composition
admission, alongside candidate temporal, semantic-mesh, TPS and GPU-native work.
Its implemented baseline follows this owner and the
[dense contract](docs/sdk/DENSE_FACE_REFACTOR.md); candidate material creates no
target, backend, API or automatic task. Current authorized work is tracked in
[PLANS](PLANS.md). Its source-code review records static findings for the named
external examples, separately from SDK implementation and executed evidence.
