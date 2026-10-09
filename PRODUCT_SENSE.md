# PRODUCT_SENSE.md

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
stop-at-the-boundary instruction, the [terminal disposition](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md)
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
[research record](docs/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md) and
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

The [2026-10-03 finite feasibility probe](docs/TEXTURE_SEMANTIC_FEASIBILITY_2026-10-03.md)
rejected the single source-periodicity candidate: it also stopped valid skin
texture. General unmasked automatic object protection remains unqualified. The subsequent v1.25 finite patch-domain repair also rejected all four versions
and is now closed without automatic delivery. Host masks remain an assisted
capability; they are not credited as automatic recognition. No arbitrary-object or universal unknown-input
rejection guarantee is made, and identical-observation ambiguity remains.
The existing eye/lip zones are coarse guards, not anatomical segmentation;
a new deep-skin low-contrast lip outside that zone failed exact protection.
Known critical feature pixels must also be included in the host mask when exact
texture preservation is required. The failed probe remains separate from
bounded SDK acceptance. The [host integration guide](docs/HOST_TEXTURE_PROTECTION.md)
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
optional under [IMAGE_EFFECT_ACCEPTANCE.md](docs/IMAGE_EFFECT_ACCEPTANCE.md).

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
