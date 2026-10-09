# ARCHITECTURE.md

## Current repository contract

`beauty` is an SDK-only SwiftPM repository for the project owner's local Apps
and tools. [Package.swift](BeautySDK/Package.swift) owns the build graph: iOS 17
and macOS 14, one `BeautySDK` library product, one `BeautyExampleRenderer`
executable product, six library targets and six test targets, no remote dependencies.
Swift `public` describes the owner's callable surface, not third-party distribution.

Historical UI/Demo material is confined to verified `archives/legacy-ui/`
artifacts. [FRONTEND.md](FRONTEND.md) owns recovery and the separately authorized
external editor boundary. No application source or lifecycle belongs to SDK targets.
Current work and limitations are owned by [PLANS.md](PLANS.md); dated file/line
inventory and executed gate evidence are recorded once in [QUALITY_SCORE.md](QUALITY_SCORE.md).

## Target ownership

| Target | Dependencies | Responsibility |
| --- | --- | --- |
| `BeautyCore` | none | Shared/public value models, configuration, errors, canonical carrier and redacted diagnostics. |
| `BeautyDetection` | Core | Vision detection, mapping, selection and package-only observed support. |
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
→ one request-local Vision/mapping route when face support is required
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

Unindexed support-dependent still calls detect afresh. The indexed camera/video
route detects on indices divisible by `detectionFrameInterval`; other frames
abstain from face-dependent work without reusing prior observations.
`preferredProcessingSize` bounds only the Vision raster, preserving output size.
Detection selects faces, but current still-image effects use only the primary face.

## Backend and effect ownership

`BeautyConfiguration.renderBackend` is exactly `.cpu` or `.gpu`, with `.cpu`
as the default and permanent reference. `BeautyBackendFactory` selects the
package executor at initialization. Explicit unavailable GPU terminates with
`.metalUnavailable`; construction/runtime failures never trigger retry.
The still-image facade has one separate capacity route: over 256 geometry
points without row restrictions execute the complete admitted plan on CPU,
with `beauty.backend.cpuGeometryCapacityFallback = 1`. Direct Metal calls and
row-restricted over-capacity plans retain typed failure. The retained
`Warp.metal` and GPU/API boundaries remain pinned by the boundary scanner.

Geometry providers feed one `BeautyGeometryEffectPipeline`. Shared CPU-owned
still-image refiners implement source-admitted hairline/forehead, outer
submental contour, philtrum and whole-face translation behavior on both selected
backends. On these routes, corresponding legacy point emissions are suppressed
even if source admission rejects. Pixel buffers retain their separate admitted
capabilities; still-image qualification does not extend them.

Skin smoothing/sharpening uses the shared CPU-owned spatial texture stage with
fresh primary-face bounds, conservative face/eye/lip/color/edge admission and
a bounded pixel budget. `BeautyTextureExclusionMask` excludes known pixels only
from those two effects on decoded/encoded still images. It adds no detector or
semantic segmentation; [host integration](docs/HOST_TEXTURE_PROTECTION.md)
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
integrated; [terminal disposition](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)
creates no automatic follow-up. Exact control status is owned by the
[taxonomy](docs/SDK_EFFECT_TAXONOMY.md).

## Validation ownership

The renderer retains 99 registered identities and exposes 98 default cases;
explicit legacy upper-eyelid selection remains callable. It accepts only CPU
at its CLI boundary and validates persisted outputs before crediting them.
The [current batch tool](docs/CURRENT_BATCH_VALIDATION.md), outside production
targets, independently checks ordered inventory and repeated decoded pixels.
The old 75-case wrapper is historical and incompatible with current inventory.

Current gates, fixture opt-ins and evidence scope are owned by
[QUALITY_SCORE.md](QUALITY_SCORE.md). Privacy, errors and caller recovery are
owned by [SECURITY.md](SECURITY.md) and [RELIABILITY.md](RELIABILITY.md).
New API, dependency, resource or backend work must update its owner documents
and public/target tests in the same change.
