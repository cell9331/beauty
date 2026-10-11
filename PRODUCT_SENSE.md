# PRODUCT_SENSE.md

## Reference-style face editing (2026-10-11)

Owner hosts can map one face slider with
`BeautyFaceShapeSlider.smallFace.applying(position: position, to: parameters)`.
Centered controls span both directions around .5; V-face and contour smoothing
start neutral at 0. The helper uses each existing cap and reverses only the
chin-length slider, preserving direct API polarity. [All ten mappings](docs/sdk/FACE_SHAPE_SLIDERS.md).
Eight observed/lip-registered still-image contour fields now use continuous
local deformation with exact tested eye/mouth/exterior protection; small-face
chin scalloping on the first owner portrait is repaired. Missing valid support
abstains. Actual macOS/Vision examples and generated public CPU/Metal tests do
not establish identical Meitu appearance, iOS inference, device performance or
an updated host binary. Hairline/smoothing remain inactive on both supplied
portraits; their narrower admitted source classes remain explicit limitations.

## Repeated fixed-photo editing (2026-10-10)

An owner host can call `prepareStillImage(image:metadata:)` once on an RGB8 photo,
then `processResult(preparedImage:parameters:textureExclusionMask:)` for each
slider snapshot. The engine owns one deep-copied original; every edit starts
there. Detection is lazy and reused by purpose/raster on usable/no-face outcomes.
Replacement/reset/`releasePreparedStillImage()` expires old handles and releases
the source/support. Failed preparation preserves the prior source; unavailable
or partial detection retries without using older support. Serialize engine
access. The token exposes dimensions only, not bytes or landmarks. Preview and
full-size sources require independent preparation/support; the external editor
uses ordinary fresh calls for full-size export. Existing APIs and effects keep
their contract. See [integration and limits](docs/sdk/PREPARED_PHOTO_EDITING.md).

## Owner-only landmark overlay (2026-10-09)

The adjacent editor's debug overlay now uses `OwnerDiagnostics` SPI with the
same production adapter as rendering: MediaPipe 478 on iOS, Vision on macOS.
Source/output points are independently re-detected, upright, top-left normalized
and index ordered. They are observation samples, not applied warp-control points
or proof of correspondence/effect accuracy. The owner must serialize the detector,
clear overlay points on debug-off/photo replacement and never encode/log/export
them. The diagnostic instance is separate from the rendering engine and cached
native task; no prior observations substitute for a failed or no-face result.

## Dense still-image behavior (2026-10-09)

Mapped facial controls accept independent capped values on fresh dense support,
with actual composed-map safety applied during rendering. Adding another field
does not consume the previous field's scalar quota or overwrite its requested
value; the final map may still attenuate an excessive combination. Source-raster
admission/translation and legacy geometry keep separate conservative limits.
The external owner editor keeps unavailable categories and suspended tools grey,
disabled and silent; its guards preserve selection, parameters and history.
Its "整体" label describes the implemented whole-face scope, not a side selector.

The iOS still-image facade now consumes the 478-point distribution for fixed
canvas mapping, measured iris boundaries for eligible size/gaze work, near-rigid
pose for conservative map attenuation and denser geometric texture exclusions.
Smoothing and sharpening retain separate contributions rather than canceling
through one constant gain. No new public control or nonzero default is added.
Both backend selections share CPU-owned dense geometry/texture; known host
protection remains exact. [Mechanism and qualified evidence scope](docs/sdk/DENSE_FACE_REFACTOR.md)
are separate from general anatomy, unknown-input protection and device speed.

## Current owner-local batch validation (2026-10-03)

Use `python3 -B scripts/current-batch/run.py` for the current default inventory
and declared pixel checks; [suite examples and result meanings](scripts/current-batch/README.md)
cover custom local inputs. The built-in input is a no-face control, not a portrait
quality assessment. Missing oracles are explicitly unverified. The old 75-case
wrapper remains historical and is not the current integration entry point.

## Current upper-eyelid disposition (2026-10-03)

`去脂` remains `suspended`, unqualified and default-hidden. The owner-authorized
v1.25 attempt narrowed the target to automatic eyelid tone correction and
visible-boundary skin-colored patch protection. Both exhausted their original
two-method/four-version budgets without qualification. Under the owner's latest
stop-at-the-boundary instruction, the [terminal disposition](docs/history/retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)
closes both as undelivered, with no automatic continuation. No tone effect or
automatic object detector is newly available. Hiding and compatibility do not
count as implementing either automatic goal.

The retained implementation performs bounded upper-eyelid luminance correction
inside observed per-eye support. It does not identify fat or measure tissue
volume. Its brightness-based admission can confuse lighting with the target;
on the fixed natural-background challenge, admitting both eyes in a candidate
still left too little effective correction after reconstruction. Loosening
that constraint restored visible artifacts. Controlled dome/flat, protection
and calibrated live Vision tests prove their stated pixel behavior, not a
usable natural-portrait effect. Generated provenance is not the cause of the
failure, and further parameter tuning is not known to solve it. The
[research record](docs/history/upper-eyelid/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md) and
[quality evidence](QUALITY_SCORE.md) retain the concrete results.

The 77-field API retains `upperEyelidFullnessReduction`, its zero default,
range, Codable behavior, explicit still-image calls and safety regressions.
API compatibility does not mean effect acceptance. Of 99 registered renderer
cases, 98 appear in the default catalog and batch. The old
`--case upperEyelidFullnessReduction_1p00` remains an explicit diagnostic call;
omitting `--case` selects the default batch. Older wrappers with frozen
inventories are historical artifacts, not guaranteed current entry points.
This repository has no active application UI to hide.

The restart and terminal closure are recorded in [PLANS](PLANS.md). Reopening
requires an explicit owner request with new scope and a falsifiable hypothesis
or new information/resources. General requests to continue do not restart it;
no learned architecture, need for self-training or eventual success is presumed.

The [v1.21 public activation](plans/history/completed-04.md#c-2026-08-25-v1-21-provisional-upper-eyelid-public-activation),
[v1.24 mechanics receipt](.planning/V1.24-UPPER-EYELID-CURRENT.md) and
[earlier failing-branch receipt](.planning/milestones/v1.18-phases/79-conditional-productization-and-sdk-only-closeout/79-VERIFICATION.md)
remain historical evidence, not current effect approval or development orders.

## 2026-09-29 owner-supplied texture protection

The owner can pass a request-local binary `BeautyTextureExclusionMask` with a
decoded or in-memory encoded still-image `processResult` call. This lets a
controlled host protect a
skin-colored non-skin object when it knows the object's pixels: smoothing and
sharpening leave those pixels exact, while eligible unmasked cheek texture
still changes. The host supplies the mask in the upright image grid after
input orientation and mirroring. The SDK does not discover all such objects
automatically; other requested effects have separate protection contracts.

The [2026-10-03 finite feasibility probe](docs/history/retouch/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)
rejected the single source-periodicity candidate: it also stopped valid skin
texture. General unmasked automatic object protection remains unqualified. The subsequent v1.25 finite patch-domain repair also rejected all four versions
and is now closed without automatic delivery. Host masks remain an assisted
capability; they are not credited as automatic recognition. No arbitrary-object or universal unknown-input
rejection guarantee is made, and identical-observation ambiguity remains.
The existing eye/lip zones are coarse guards, not anatomical segmentation;
a new deep-skin low-contrast lip outside that zone failed exact protection.
Known critical feature pixels must also be included in the host mask when exact
texture preservation is required. The failed probe remains separate from
bounded SDK acceptance. The [host integration guide](docs/sdk/HOST_TEXTURE_PROTECTION.md)
and new public-path regression now verify the object + complete lip union on
that same generated source: both stay exact while the other cheek meets the
frozen smoothing/sharpening direction thresholds. This supplies independent
host information; coarse automatic feature protection remains unqualified.

## Current qualified 2D shape controls (2026-10-01)

The original 15 additional controls are `implemented` within the owner-local
generated-image domains below. The [final qualification table](plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md)
owns detailed positive/negative/protection evidence; [taxonomy](docs/SDK_EFFECT_TAXONOMY.md)
owns each status. Unsupported image classes remain limitations rather than
uncompleted requirements for these bounded qualifications.

| Controls | Qualified still-image behavior and admission boundary |
| --- | --- |
| `wholeFaceXPosition`, `wholeFaceYPosition` | Signed rigid translation of one connected visible head against a uniform background, preserving eye/mouth widths, eye spacing and foreground area. Detached foreground objects or ambiguous support exit source-exact. |
| `wholeFaceTilt` | Signed 2D movement of eye/lip lines, crown and chin on the tested generated portraits, with eye-spacing and exterior protection. No depth estimate is supplied. |
| `wholeFaceSymmetry` | Reduction of source/observation-matched lower-contour width imbalance; symmetric negatives remain exact, with eye/mouth/central-face protection. |
| `headSmall`, `headWrap`, `cranialCrownHeight` | Visible full-head reduction, increased hair/face width ratio, and signed visible hair-cap height changes respectively. Tested hair continuity and feature protection apply; headWrap requires a coherent high-contrast hair cap and rejects hairless/low-contrast/short-band negatives. |
| `hairlineHeight`, `foreheadHeight` | Signed source hair/skin-boundary displacement and its inverse forehead-gap change. High-contrast dark-hair/light-skin flat and wavy boundaries are admitted; hairless, low-contrast and brow-overlap negatives exit exact. Equal opposing requests cancel. |
| `midfaceLength`, `philtrumLength`, `lowerFaceLength` | Signed visible eye/nose, nose/upper-lip and lip/chin proportion changes with feature protection. Philtrum requires registered source/observed upper-lip support; missing or offset lip bands exit exact. Missing required nose/lip observations also exit exact. |
| `faceShortening` | Full visible head shortening on matched long-face positives; matched short-face negatives remain exact, with eye/mouth width and nose protection. |
| `doubleChinReduction`, `doubleChinReductionPro` | Reduction of a continuous outer submental skin bulge, with additional depth/area reduction for Pro. Flat chins, internal shadow folds without an outer bulge and detached light collars remain exact. |

These are image-plane effects. General hair/lip/skin segmentation, skull-depth
measurement and internal-fat recognition have not been qualified. Neutral,
repeatability, metadata, protection and typed-failure checks apply as listed in
the owning qualification record; source admission can deliberately return an
unchanged image. Pixel-buffer/provider mechanics do not extend the qualified
still-image domain.

The [earlier product narrative](docs/history/product-effect-qualification-snapshot-2026-10-01.md)
preserves intermediate partial states and withdrawn candidates for traceability.
They are not current pending work.

## Owner-local integration

`beauty` exposes one SDK-only SwiftPM library to locally controlled Apps/tools.
The host imports `BeautySDK`, creates an engine/configuration, submits explicit
metadata and normalized parameter snapshots, then handles output, typed errors
and redacted result diagnostics. SDK code owns processing; hosts own their UI,
permissions, input acquisition, protected-resource lifecycle and export.
Source, binaries, model assets, fixtures and derived data remain owner-local.

On iOS, ordinary `BeautyEngine()` now uses bundled MediaPipe Face Landmarker
1.1.0; the host does not supply a model path or add a separate detector. macOS
uses Vision. Existing calls, parameter defaults, rendering backend selection and
caller serialization are unchanged. Actual iOS nose/lip/lower-contour coordinates
now come from dense observed points. This changes detection support, so old Vision
effect evidence is not a claim of identical MediaPipe output or general portrait
quality. No new beauty effect or automatic object/skin segmentation is introduced.

A still-image result with admitted MediaPipe support can include aggregate
`beauty.detection.meshPointCount` (478) and
`beauty.detection.hasFacialTransformation` (0/1). These are support diagnostics,
not raw point/pose APIs or effect-quality scores. Unrequested/skipped/no-face
routes do not reuse those metrics. Detection failure still removes dependent
work and preserves admitted global color/filter work.

`maximumFaceCount` caps detector selection, not multi-face rendering. Current
still-image effects use the primary selected face; `usedFaceCount` is a detector
summary and must not be presented as a count of visibly changed faces.
Pixel-buffer input supports its admitted color/filter work and fresh-face
texture, without facial geometry/local retouch or a realtime performance promise.
Indexed camera/video images abstain on skipped detection frames rather than
reusing prior observations. One engine requires caller-serialized access.

## Still-image retouch call


The two active local-retouch controls below are directly callable from the
owner-controlled host. A minimal photo path is:

```swift
import CoreGraphics
import CoreImage
import BeautySDK

let engine = try BeautyEngine()
let metadata = BeautyInputMetadata(
    orientation: .up,
    source: .photo
)
let parameters = BeautyParameters(
    teethWhitening: 0.65,
    scleraRednessReduction: 0.55
)
let result = try engine.processResult(
    image: inputCIImage,
    metadata: metadata,
    parameters: parameters
)
let outputCIImage = result.output
```

`BeautyEngine.process(image:orientation:parameters:)` is the shorter equivalent
when the host only needs the output image. These controls are positive-only,
default to zero, and clamp finite strengths to `0...1`. Zero strength is a
source-preserving no-op. The supported local-retouch path is an opaque bounded
still `CIImage` with `BeautyInputSource.photo`; transparent input is rejected,
realtime/pixel-buffer local retouch is not activated, and the SDK validates
extent, alpha, named-sRGB output, local support, and typed failure/degradation
before returning a result. Callers serialize access to one `BeautyEngine`
instance; independent instances may run concurrently.

This is an owner-local integration contract, not a third-party distribution or
release claim. Suspended `upperEyelidFullnessReduction` is intentionally
absent from this normal-use example; its compatibility and effect limits are
defined in the current upper-eyelid disposition above.

## Input limits and assistance

The encoded `Data` result entry preflights its byte limit (32 MiB default), one
frame and declared dimensions before decoding. Decoded still/pixel-buffer
inputs obey the pixel ceiling, default/hard maximum 50,000,000. Active texture
has the smaller 8,388,608-pixel ceiling; hosts must respect it for originals as
well as previews. `preferredProcessingSize` reduces only the Vision raster;
it does not resize output or promise faster inference. `renderQuality` selects
the active texture neighborhood rather than general export quality.

Texture's fresh face/interior/color/edge and coarse eye/lip guards do not
identify skin semantics or every non-skin object. Host-provided exclusion masks
protect known canonical-grid pixels only from smoothing/sharpening. Other
effects retain their own protection behavior. Correct explicit masks are a
usable assisted capability; their presence never completes an automatic target.

`.cpu` is the default reference backend. Explicit unavailable `.gpu` fails as
`.metalUnavailable`. The single admitted geometry-capacity route executes a
complete over-256-point still-image plan on CPU when no row restrictions exist,
reporting its capacity metric; runtime failures do not retry. Selected GPU
does not imply end-to-end GPU local retouch, broad parity or device performance.

## Acceptance and verification

Compatibility, mechanical safety and effect qualification are separate claims.
Every claimed effect needs source-defined positive/negative, direction and
protected-region evidence with applicable dimensions, orientation/mirror,
color/alpha, neutral identity, tolerance, repeatability and typed recovery.
Visual/no-worsening claims additionally require original-detail inspection.
A safe no-op or changed-pixel count cannot pass a positive effect oracle.
Generated images are eligible; genuine portraits and physical devices are
optional under [IMAGE_EFFECT_ACCEPTANCE.md](docs/validation/IMAGE_EFFECT_ACCEPTANCE.md).

Clean local-path SwiftPM consumer tests import only `BeautySDK` and measure
actual output bytes/dimensions. Renderer integration requires every requested
input×case to yield a nonempty, decodable, same-size output and reconciled
versioned report; incomplete work fails nonzero. The current batch tool measures
declared pixels separately from missing oracles and semantic/visual qualification.
Its default no-face batch does not requalify all portrait effects.

`bash scripts/run-no-skip-swiftpm.sh` is complete SDK engineering closeout:
archive/boundary/preflights, all nine opt-ins, zero failures/skips and nonzero
execution. [QUALITY_SCORE.md](QUALITY_SCORE.md) links actual dated receipts;
historical gate counts are never current rerun claims. Successful SDK checks do
not erase the separate frozen EYE/SEG failures or confer device, population,
commercial visual quality, packaging, launch or external distribution approval.
Physical-device feedback is optional after SDK completion and becomes a new
reproducible finding in [PLANS.md](PLANS.md).

The independently authorized owner editor lives outside this repository;
[FRONTEND.md](FRONTEND.md) describes its boundary and known failed simulator
checks. Historical UI material is recoverable only under the verified archive
contract and creates no current SDK feature, UI gate or automatic backlog.

## Signed nose editing (2026-10-10)

The owner's local host can expose all six nose controls at -100/0/+100, mapped
to unchanged absolute SDK caps. The SDK accepts negative values through init,
Codable, mutable normalization, planning and backend validation. With fresh
dense nasal anatomy, size contracts/expands observed width and length, tip size
uses its own local center, wings change lateral width, and lift moves lower
support up/down. Root/bridge retain distinct surface-width bands; neither
supplies 3-D height, relighting or Meitu appearance parity. Legacy positive
geometry and neutral keys/defaults remain compatible.

Generated source-fixed nasal markers verify opposite directions, four monotone
settings, >1 pixel endpoint change at the tested 480×640/640×480 sizes, alpha,
protected exterior, determinism and missing-support abstention. This is bounded
2-D geometry acceptance, not a naturalness or population-level assertion. The
separate host throttles starts at 40 ms, replaces pending values and flushes on
release; current-output debug detection waits for settled editing. Actual
simulator timings and native checks belong to the linked [plan](PLANS.md).
