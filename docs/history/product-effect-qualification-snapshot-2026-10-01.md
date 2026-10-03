# Historical product qualification narrative (2026-10-01 excerpt)

Captured before the current-document drift repair. Dated partial statuses,
candidate descriptions and next steps below apply to their original stage;
they do not override [PLANS.md](../../PLANS.md) or
[current taxonomy](../SDK_EFFECT_TAXONOMY.md). No test result is re-signed.

## 2026-09-28 qualified final shape controls

The owner-local still-image `wholeFaceYPosition` and `wholeFaceXPosition`
move the complete visible generated head in signed directions while keeping
eyes and mouth rigid. They act only when a single connected head is separated
from a uniform background; extra foreground objects or ambiguous portraits
remain unchanged. `philtrumLength` moves the visible upper lip relative to
the nose in both directions when the source lip band matches the observed
location; absent or offset bands exit unchanged. All three rows are
`implemented` within these generated-image 2D admission ranges. No 3D
geometry, general subject masking, or general lip segmentation is claimed.

## 2026-09-28 admitted outer submental tiers

`doubleChinReduction` reduces a generated continuous outer submental bulge;
Pro reduces its visible depth and area further without a sharp chin edge.
Two skin values and two bulge depths pass. Flat chins, internal dark folds
without an outer protrusion, and detached light collars remain exact after
source-continuity admission, with CPU/Metal parity and upper-face protection.
Both rows are `implemented` for this owner-local generated-image 2D outer
contour class. They do not identify internal fat or guarantee all neck forms.

## 2026-09-28 admitted lower-face proportion

`lowerFaceLength` changes the visible lip-to-chin gap in both signed
directions on two skin values and three generated lip/chin-height forms.
The visible upper lip, face features and distant background are protected;
the lower contour remains continuous. Missing lip observation exits exact.
The row is `implemented` for owner-local generated-image 2D proportion.
`philtrumLength` now covers several aligned nose/lip forms with nose
protection, but a small offset lip still has a one-direction no-response;
that row remains `partial`.

## 2026-09-28 admitted forehead and midface proportions

Positive `foreheadHeight` now moves an observed high-contrast hair/skin
boundary in the direction that changes its gap to the visible eyes. Flat and
wavy generated boundaries pass both signs; brows, eyes and mouth stay exact,
while hairless and low-contrast inputs exit unchanged. Equal opposing
`foreheadHeight` and `hairlineHeight` requests cancel. CPU and Metal agree.
`midfaceLength` changes the eye-to-nose share of eye-to-lip distance in both
directions on two skin and two nose-length variants; the visible brow/eye and
lip structures remain exact, and absent nose observation exits unchanged.
Both rows are `implemented` for owner-local generated-image 2D proportion
effects; neither identifies skull depth or broad population behavior.

## 2026-09-28 admitted 2D facial symmetry

`wholeFaceSymmetry` now has a source- and observation-matched generated
portrait positive on two skin values: visible lower-contour width imbalance
decreases while the eyes, mouth and central face remain unchanged. A matched
symmetric portrait remains exact, with repeat, no-face, exterior, alpha and
contour-continuity checks. The row is `implemented` for owner-local 2D
contour balance; it makes no 3D face claim.

## 2026-09-28 admitted head silhouette behavior

`headSmall` now has generated portrait evidence for visible full-head width
and height reduction across two skin and two head-shape variants, with eye,
mouth and nose protection. Signed `cranialCrownHeight` changes the visible
hair cap height in both directions while preserving the tested face interior.
Hair silhouette continuity, neutral, no-face, exterior, alpha, repeat and
extent are checked. These two rows are `implemented` for owner-local
image-plane effects; neither identifies a skull or segments hair. `headWrap`
now also improves the visible hair/face width ratio on those admitted sources,
while hairless, low-contrast and short-forehead-band inputs stay exact after
source hair-cap admission. Its CPU and Metal still-image results agree. That
row is `implemented` within the same high-contrast generated-image scope.

## 2026-09-28 source-contour submental behavior

On a generated portrait with a coherent skin silhouette protruding below the
selected chin box, `doubleChinReduction` now reduces visible bulge depth and
area. Pro reduces both further. Two skin values and two protrusion depths
pass; matched flat chins remain source-exact, and the eyes, mouth and distant
background are protected. This owner-local class does not cover an internal
shadow fold without a protruding outer contour. Both rows remain `partial`
while that phenotype and broader negative/protection inputs are reviewed.

## 2026-09-28 source-boundary hairline behavior

For still images with a coherent dark hair cap and lighter forehead, signed
`hairlineHeight` now moves the visible source hair/skin boundary locally.
Two generated skin values, flat and wavy boundaries pass both directions,
while eyes, brows and mouth remain source-exact and adjacent output columns
stay continuous. Generated hairless, low-contrast and short forehead-band
negatives are unchanged, as are requests with an observed brow too close to
the effect area. This qualifies the row as `implemented` for an admitted
high-contrast still-image class. It does not establish general hair
segmentation or an effect on light or low-contrast hair.

## 2026-09-28 generated portrait effect qualification update

Source-fixed 512-pixel generated portraits now show visible full-head width
and height reduction for `headSmall`, lateral hair widening for `headWrap`,
bidirectional hair-top movement for `cranialCrownHeight`, and complete
hair-top-to-chin shortening for a long-face `faceShortening` positive.
Registered nose/lip/chin boundaries show the requested bidirectional gap
changes for `philtrumLength` and `lowerFaceLength`. `wholeFaceYPosition`
moves both visible hair top and chin edge, and `wholeFaceXPosition` moves
the face center. A symmetric observed/source portrait remains unchanged under
`wholeFaceSymmetry`. These are owner-local generated-image findings. The
later short-face protection and negative checks qualify `faceShortening`;
the other rows here remain `partial` while their listed gaps are tested.

The earlier point-only path increased the area of a generated internal
submental fold; the new outer-contour route above is separately qualified
and fails closed on that non-protruding phenotype. An earlier five-point
hairline candidate shifted an offset boundary negative and was reverted;
the later source-boundary route is recorded above.

## 2026-09-27 symmetry and lower-chin owner-local controls

`3D塑颜 / 对称` now maps to `wholeFaceSymmetry`, a bounded lower-contour
image-plane correction driven by observed asymmetry. `脸型 / 去双下巴` and its
Pro variant have independent public parameters; their pixel-buffer/provider
route lifts a generated chin marker, while Pro also changes paired lower
flanks. Still-image behavior now follows the source-contour route above.
Public generated pixels,
exterior/upper-face/alpha protection, neutral, no-face, orientation/mirror,
repeat, Codable defaults and typed failure recovery are checked. These rows
remain taxonomy `partial`; no 3D or submental-fat effect is claimed.

## 2026-09-27 head-region owner-local controls

`比例 / 小头`, `比例 / 头包脸`, `比例 / 颅顶` and `脸型 / 发际线` now map to four
independent public parameters. Generated markers move in the documented
direction through the public still-image path while a separate central
marker, image exterior and alpha remain protected. Neutral, no-face,
orientation/mirror, repeat, Codable defaults and typed failure recovery pass.
All four taxonomy rows remain `partial`; hair silhouette, true skull geometry
and realistic hairline reconstruction await broader portrait evidence.
When an observed eyebrow overlaps the local `hairlineHeight` warp area, that
control exits unchanged. The older natural-style portraits still exit under
this brow guard; the source-boundary route above admits a separate,
high-contrast generated class. Neither result proves general hair segmentation.

## 2026-09-27 philtrum and lower-face owner-local controls

`比例 / 人中` and `比例 / 下庭` now have independent signed parameters. Each
moves a separate generated marker in both requested directions through the
public still-image path while preserving the other marker, far background
and alpha. Neutral, no-face, repeat, four orientations, input mirror, legacy
Codable defaults and typed failure recovery pass. Taxonomy remains `partial`
pending broader portrait acceptance.

## 2026-09-27 forehead and midface owner-local controls

`比例 / 额头` and `比例 / 中庭` now have separate signed parameters. On generated
input each moves its own marker in opposite directions for positive and
negative strengths while preserving the other marked region, far background
and alpha. Neutral, mirror/orientation, no-face, repeat and failure recovery
are checked. Taxonomy remains `partial` pending broader portrait evidence;
these controls make no three-dimensional quality claim.

## 2026-09-27 short-face owner-local control

`比例 / 短脸` has an independent `faceShortening` parameter. Generated upper
and lower markers move toward one another through the public still-image
path; a center marker, distant background, and alpha remain protected.
Neutral, missing-face, orientation, mirror, repetition, and failure recovery
are checked. A later source-qualified long-face positive also shortens the
complete visible head while retaining eye and mouth widths within 1 pixel
and leaving the nose exact; a matched short-face negative stays exact. This
row is now `implemented` for owner-local generated-image 2D behavior.

## 2026-09-27 texture protection and size limit

On generated portraits with lighter or deeper skin, smoothing and sharpening
still change cheek texture while cool and warm low-contrast backgrounds outside
the selected face stay exact. Texture now requests fresh face detection on
still images and pixel buffers, and exits unchanged without usable support;
other color controls remain available. The conservative face-interior ellipse
also leaves broad eye/lid and lip zones source-exact. On one generated
natural-style portrait, both cheek targets changed while selected eye and lip
core regions, hair and far background stayed exact. This is not anatomical
skin segmentation. An additional generated high-saturation warm cheek
decoration now remains exact for both controls while the other cheek changes;
similarly colored non-skin content elsewhere inside the envelope remains a
quality limitation. A texture request above
8,388,608 pixels
now fails typed before processing; the same engine accepts a later small
request. Owners can process a larger image without these texture controls or
provide a smaller input. No device throughput or total-memory claim follows.

## 2026-09-27 dense geometry on a GPU-selected still image

An owner-local host selecting `.gpu` can combine face controls even when a
valid observed landmark shape yields more than 256 geometry points. The SDK
renders that whole still-image plan on CPU and reports the fixed capacity
metric. A generated 288-point double-brow case has source-exact CPU parity;
the next ordinary request keeps the GPU route. Hosts should treat `.gpu` as
a preferred execution route for this rare combination, not a latency promise.

## 2026-09-27 whole-face tilt owner-local control

`3D塑颜 / 倾斜` has an independent `wholeFaceTilt` control. On an in-memory
generated face marker, signed strengths rotate two different colored regions
in opposite directions through the public still-image path. Neutral, distant
background, alpha, missing-face and typed-failure recovery are checked. The
2026-09-28 generated portrait qualification adds coherent signed eye-line,
lip-line, crown and chin movement on two skin variants, with eye-center spacing,
exterior, alpha, repeat and extent checks. The row is `implemented` for the
owner-local two-dimensional image-plane effect; this does not establish a depth
effect or general visual quality.

## 2026-09-26 owner-local diagnostics

`logLevel` now selects bounded event verbosity on `BeautyResult.diagnostics`;
`enableDebugMode` permits one backend-stage debug event at `.debug`. The
owner-local host can inspect successful requests without exposing images,
paths or free-form log text. Failed requests keep their typed error and have
no result event list.

## 2026-09-26 owner-local performance result

The owner-local host can opt into a per-request synchronous facade duration
with `enablePerformanceLog` and read it from `BeautyResult.metrics` on
`processResult`. The measurement helps compare local calls without storing
images or paths. For `CIImage` output it excludes later caller-triggered
rendering, so it is not a total image-processing or device-performance claim.

## 2026-09-26 owner-local horizontal face control

`3D塑颜 / 左右` now has an independent `wholeFaceXPosition` owner-local control.
Positive and negative strengths move visible eyes and mouth in the requested
horizontal direction on two generated portrait schematics while leaving
distant background and alpha unchanged. The taxonomy remains `partial` until
broader portrait and silhouette evidence exists; the result does not establish
a depth effect or commercial visual quality.

## 2026-09-26 owner-local encoded image entry

The local host can now pass one encoded still image as in-memory `Data` to
`BeautyEngine.processResult(encodedImageData:metadata:parameters:)`. The
configured byte limit is checked before ImageIO decoding, and a valid image
continues through the same still-image effects and result metadata as an
already decoded `CIImage`. Malformed or oversized input returns a typed error;
the next valid request remains usable. The SDK still does not read file paths.

## 2026-09-26 whole-face vertical owner-local control

The `3D塑颜 / 上下` taxonomy row has a new `wholeFaceYPosition` candidate.
It moves visible eyes and mouth downward for positive input and upward for
negative input on two generated portrait schematics through the public
still-image SDK path. Neutral, repeat, distant-background and alpha checks
pass; a missing face is source-exact, and a typed oversized-input failure does
not affect the next request. The control is image-space geometry only; this
evidence does not establish true 3D shape or broad portrait visual quality.

## 2026-09-26 FACE-01 second generated portrait acceptance

A second predeclared natural-style generated rough/smooth pair, with deep skin,
oblique light and cheek-crossing hair, now passes the public CPU pixel oracle.
The rough right cheek improves at the fixed threshold; the smooth negative,
hair, center, far background, neutral, repeat and alpha checks pass. A long
hair occlusion can safely leave one side unchanged while the unobstructed side
continues. This is owner-local evidence for the tested inputs, not a claim
about a population, real-device behavior or commercial visual quality.

## 2026-09-26 FACE-01 additional generated coverage

Code-generated deep, medium, and light cheek colors pass bilateral roughness
improvement while smooth negatives do not worsen. Opposite background
brightness across the two sides also passes. A short dark hair band crossing
the cheek is now source-exact on its rows, without suppressing supported rows
below it; upper ear, center, far background, and alpha remain protected. The
predeclared natural-style generated portrait pair continues to pass through
the public CPU renderer. More varied portrait hair, lighting, and skin
appearance remain to be qualified before broader coverage is claimed.

## 2026-09-26 explicit detection frame interval

The new indexed camera/video CIImage entry accepts `frameIndex ≥ 0`. With
`detectionFrameInterval = n`, face-dependent effects request detection on
indices divisible by `n`; intervening frames return a skipped detection
summary with the fixed `detectionInterval` reason and leave those effects off.
Other color controls continue; texture is source-exact on skipped frames
because it requires fresh face support. Unindexed still-image calls continue
to detect each time. This explicit cadence is suitable only when a host accepts
the visible fail-closed gaps; it does not interpolate or reuse face positions.

## 2026-09-26 preferred Vision detection size

An owner-local host can set `preferredProcessingSize` to limit the image sent
to face detection while retaining the original output size. It has no effect
on requests that do not need a face. A smaller detection raster may alter which
landmarks Vision finds; no claim of faster or more accurate detection follows
without device measurements.

## 2026-09-26 generated skin-texture acceptance

`renderQuality` now selects the texture footprint when smoothing or sharpening
is active: performance 3×3, balanced 5×5, quality 7×7. On the generated
high-frequency cheek positive, smoothing increases in that order. A neutral
request and other controls do not change with this setting. The names describe
the neighborhood choice, not measured device speed or broad portrait quality.

At this dated stage, `skinSmoothing` reduced fine luminance variation in an admitted opaque
neighborhood; `skinSharpen` increases a moderate soft-edge gradient. A uniform
color stays uniform, and hard color boundaries are guarded. The owner-local
public still-image tests use code-generated textured and flat cheek regions,
soft-edge positives, and a portrait-like source with eyes, hair, mouth and
background protections. They assert effect direction, neutral identity,
repeatability, extent, orientation/mirroring, sRGB and Display P3 behavior,
alpha, and typed pixel-limit recovery. CPU and Metal-selected buffer/still
outputs met the generated pixel-delta contract. The current face-support rule
above supersedes this stage's face-free route. These controls still do not
promise an anatomical skin mask. No real-person or device visual-quality claim
follows from this set.

## 2026-09-26 FACE-01 generated portrait acceptance

The follow-up code-generated robustness checks now cover a dark background
rough-positive, a low-contrast negative, and a short opaque occlusion. The
dark-background cheek improves under the same fixed two-sided direction
threshold; low or conflicting contrast is intentionally source-exact, and the
occluded rows remain unchanged while neighboring cheek rows can improve.
These additions narrow known lighting/occlusion risks without claiming broad
portrait or physical-device qualification.

`faceContourSmooth` now uses an opaque still-image lower-cheek source-edge
alignment when the observed contour sits inside a visible, unambiguous
silhouette. The owner-local public scalar and neutral/default behavior are
unchanged. The previously failing, source-qualified natural-style generated
rough-positive/smooth-negative pair passes its predeclared public CPU effect
oracle on the repaired code: the rough cheeks improve on both sides, the
smooth negative stays within its non-worsening bound, and target/protection,
alpha, neutral, and repeat checks pass. The output was also inspected at
original size for obvious ear/temple artifacts. This is owner-local generated
portrait acceptance for the tested effect and does not establish behavior
across real people or device and commercial visual quality.

The dated failed probe and older stylized evidence below remain historical
records for their source versions.

