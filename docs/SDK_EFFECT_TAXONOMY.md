# SDK Effect Taxonomy

This is the current SDK-owned authority for supported effect grouping and the
legacy `美型 / 五官` control vocabulary. It is intentionally independent of the
archived application and UI-reference source trees.

## Boundary

The [current image-effect acceptance policy](IMAGE_EFFECT_ACCEPTANCE.md)
permits owner-authorized generated portrait-like positive/negative inputs to
complete an owner-local effect qualification. No row remains `partial` merely
because qualifying images are generated rather than genuine human portraits.
Historical receipts retain their narrower claims; each row still needs its own
effect-direction and protection evidence before promotion.

The taxonomy preserves algorithm intent, neutral public parameter mappings, and
implementation status. It does not preserve or require SwiftUI views, visual layout, screen
layout, navigation, badges, sliders, sticky headers, image-card styling, account
or entitlement behavior, or any other application lifecycle. Historical visual
material is recoverable through `archives/legacy-ui/README.md`; it is not an
active SDK requirement.

The SDK is owner-only and non-distributed. In this document, `public` means the
Swift access surface callable by the owner's local host and exercised by
repository tests; it does not mean a third-party SDK, public package, customer
contract, model/weight distribution, commercial launch, or release approval.

Status has exactly these meanings:

- `implemented`: SDK behavior exists, relevant safety/degradation tests pass,
  and public-facade output evidence exists when the effect changes pixels.
- `partial`: some SDK capability maps to the concept, but the exact branch or
  reference control is not independently complete.
- `future`: no current SDK implementation claim; promotion requires a separately
  scoped owner-local contract, implementation, and evidence.

Appearance in this document never creates a public API. The public contract is
`BeautyParameters` in `BeautyCore`; this file maps product taxonomy onto that
contract without renaming or aliasing unsupported behavior.

## Current public parameter inventory

The current contract contains exactly 64 stored fields: 63 numeric controls and
the optional `filterId`. Unit controls normalize to `0...1`; signed controls
normalize to `-1...1`; `filterId` is an optional logical resource identifier.

<!-- SDK_PARAMETER_INVENTORY_BEGIN -->
- Skin: `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen`
- Global tone: `brightness`, `contrast`, `saturation`, `temperature`, `tint`, `exposure`, `highlight`, `shadow`
- Face: `faceSlim`, `faceSmall`, `wholeFaceYPosition`, `wholeFaceXPosition`, `faceVShape`, `jawSlim`, `chinLength`, `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, `chinTaper`
- Eyes: `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`, `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `eyeTilt`, `innerCornerOpen`, `outerCornerOpen`, `eyeSymmetry`
- Eyebrows: `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, `eyebrowTilt`, `eyebrowPeakDefinition`
- Nose: `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`, `noseRootNarrowing`, `noseTipLift`
- Mouth and local color: `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, `lipPlump`, `lipColor`, `teethWhitening`
- Eye local retouch and color: `upperEyelidFullnessReduction`, `scleraRednessReduction`
- Filter: `filterId`, `filterIntensity`
<!-- SDK_PARAMETER_INVENTORY_END -->

`skinSmoothing` and `skinSharpen` now use a bounded spatial luminance-detail
filter on admitted opaque, low-contrast neighborhoods. Generated skin-colored
cheek and soft-edge positives, flat negatives, and protected facial features
pass owner-local public-pixel tests. This is not face segmentation or a claim
about all real skin, hair, devices, or commercial visual quality. The four
skin-control fields and their caps are unchanged.

`lipColor` is color-only and is not evidence for geometric `丰唇` (`lipPlump`).
`teethWhitening`, `scleraRednessReduction`, and
`upperEyelidFullnessReduction` are bounded opaque still-image local-retouch
controls. None implies realtime/pixel-buffer support. `去脂` must not alias
`eyeHeight`, `upperEyelidLift`, brow movement, eye opening, eye-bag removal,
dark-circle removal, or global smoothing. Request-local masks and face geometry
are implementation details, not taxonomy entries or public diagnostics.

The v1.18 Phase-78/79 decision remains immutable historical evidence that the
then-current 61/5/74 surface did not promote the mechanics candidate. The owner
first deferred further work on 2026-08-25, then superseded that current-product
decision later the same day: the bounded v4 mechanics are accepted as a
provisional owner-local `去脂` implementation and are callable through
`upperEyelidFullnessReduction`. This is an owner-provided acceptance decision,
not a claim that a new blinded review was run. The visual result is explicitly
known to be weak and is future quality work. v1.24 adjusts the same bounded
internal relief gain and records a generated half-strength pixel improvement;
it does not promote natural-portrait or commercial visual-quality claims.

Internal `BeautyExperimentalUpperEyelid*` names remain unchanged to preserve
provenance. The current route uses the existing source-derived relief analyzer,
per-eye semantic envelope, bounded RGB correction, immutable-source
composition, and source-exact failure behavior. It adds no trained model,
weight, dataset, network path, geometry warp, or external distribution claim.
Future optimization may replace the internal implementation but must preserve
the public field's neutral/default/Codable and fail-closed contract.

## Legacy shaping and facial-feature mapping

The rows below are the de-duplicated algorithm/control taxonomy. Reference image
names and visual organization are intentionally omitted from the active contract.

<!-- SDK_LEGACY_TAXONOMY_BEGIN -->
| Group | Control | Status | Canonical SDK parameter | Scope note |
| --- | --- | --- | --- | --- |
| 3D塑颜 | 对称 | future | — | Requires a new neutral whole-face geometry contract. |
| 3D塑颜 | 上下 | partial | `wholeFaceYPosition` | Signed bounded image-space whole-face displacement passes generated public pixels and complete no-skip; this is not depth or a 3D mesh effect. Broader portrait evidence remains pending. |
| 3D塑颜 | 左右 | partial | `wholeFaceXPosition` | Signed bounded image-space horizontal displacement passes generated public pixel direction and protection checks; it is not depth or a 3D mesh effect. Broader portrait evidence remains pending. |
| 3D塑颜 | 倾斜 | future | — | Requires a new neutral whole-face geometry contract. |
| 比例 | 小头 | partial | `faceSmall` | Existing small-face behavior is related but not an independently complete proportion control. |
| 比例 | 头包脸 | future | — | No current neutral parameter. |
| 比例 | 颅顶 | future | — | No current neutral parameter. |
| 比例 | 额头 | future | — | No current neutral parameter. |
| 比例 | 中庭 | future | — | No current neutral parameter. |
| 比例 | 人中 | future | — | No current neutral parameter. |
| 比例 | 下庭 | future | — | No current neutral parameter. |
| 比例 | 短脸 | future | — | No current neutral parameter. |
| 脸型 | 脸宽 | implemented | `faceSlim` | Bounded contour narrowing. |
| 脸型 | 小脸 | implemented | `faceSmall` | Bounded small-face geometry. |
| 脸型 | 面部流畅 | implemented | `faceContourSmooth` | The repaired lower-cheek source-edge alignment passes the predeclared public CPU oracle on a natural-style generated rough/smooth pair: bilateral roughness improves, the smooth negative stays within tolerance, and target, protection, neutral, repeat, and alpha checks pass. Code-generated dark-background positives also improve; weak, contradictory, or ambiguous outward edges fail closed. This owner-local generated-input result does not qualify real-person populations, devices, or commercial visual quality. |
| 脸型 | 太阳穴 | implemented | `templeFullness` | Upper-lateral contour geometry. |
| 脸型 | 颧骨 | implemented | `cheekboneSlim` | Mid-lateral contour geometry. |
| 脸型 | 下巴长短 | implemented | `chinLength` | Signed chin-length geometry. |
| 脸型 | 去双下巴 | future | — | Requires approved local semantic-region support. |
| 脸型 | 去双下巴 Pro | future | — | Semantic support and compatible actual-use authorization are outside current scope. |
| 脸型 | 尖下巴 | implemented | `chinTaper` | Centerline-gated chin taper. |
| 脸型 | V脸 | implemented | `faceVShape` | Bounded V-shape geometry. |
| 脸型 | 下颌角 | implemented | `jawSlim` | Bounded jaw narrowing. |
| 脸型 | 下颌线 | implemented | `jawSlim` | Explicit alias-backed row; no distinct public parameter claim. |
| 脸型 | 发际线 | future | — | Requires approved local segmentation/resources. |
| 眼睛 | 大小 | implemented | `eyeSize` | Eye-aperture size geometry. |
| 眼睛 | 上下 | implemented | `eyeYPosition` | Signed vertical position. |
| 眼睛 | 眼高 | implemented | `eyeHeight` | Contour-height geometry. |
| 眼睛 | 长度 | implemented | `eyeLength` | Contour-length geometry. |
| 眼睛 | 眼距 | implemented | `eyeDistance` | Signed paired spacing. |
| 眼睛 | 去脂 | implemented | `upperEyelidFullnessReduction` | Provisional owner-accepted opaque still-image relief correction; bounded and fail-closed, with known weak visual quality. |
| 眼睛 | 提肌 | implemented | `upperEyelidLift` | Upper-contour geometry; not `去脂`. |
| 眼睛 | 眼瞳大小 | implemented | `pupilSize` | Requires plausible request-local pupil support. |
| 眼睛 | 眼神矫正 | implemented | `gazeCorrection` | Per-eye request-local pupil-to-own-center correction with no peer borrowing; strict aperture containment and source-safe local rejection. |
| 眼睛 | 眼睑下至 | implemented | `lowerEyelidDrop` | Lower-contour geometry. |
| 眼睛 | 眼尾上扬 | implemented | `eyeTailLift` | Outer-eye lift geometry. |
| 眼睛 | 倾斜 | implemented | `eyeTilt` | Signed paired-contour rotation. |
| 眼睛 | 祛红血丝 | implemented | `scleraRednessReduction` | Opaque still-image per-eye local color only. |
| 眼睛 | 内眼角 | implemented | `innerCornerOpen` | Independent inner-corner geometry. |
| 眼睛 | 外眼角 | implemented | `outerCornerOpen` | Independent outer-corner geometry. |
| 眼睛 | 对称 | implemented | `eyeSymmetry` | Bounded paired symmetry correction. |
| 嘴唇 | 大小 | implemented | `mouthSize` | Signed whole-mouth size geometry. |
| 嘴唇 | 宽度 | implemented | `mouthWidth` | Signed mouth width; Phase94 verifies bounded negative contraction on the registered generated source while retaining positive output. |
| 嘴唇 | 上下 | implemented | `mouthYPosition` | Signed vertical position. |
| 嘴唇 | 倾斜 | implemented | `mouthTilt` | Signed mouth rotation. |
| 嘴唇 | 左右 | implemented | `mouthXPosition` | Signed horizontal position. |
| 嘴唇 | M唇 | implemented | `lipPeakDefinition` | Upper-lip peak geometry. |
| 嘴唇 | 丰唇 | implemented | `lipPlump` | True lip geometry; never `lipColor`. |
| 嘴唇 | 微笑 | implemented | `smile` | Bounded smile geometry. |
| 嘴唇 | 白牙 | implemented | `teethWhitening` | Opaque still-image request-local color work. |
| 鼻子 | 大小 | implemented | `noseSlim` | Bounded nose-size geometry. |
| 鼻子 | 提升 | implemented | `noseTipLift` | Independent tip lift. |
| 鼻子 | 鼻翼 | implemented | `noseWingSlim` | Nose-wing narrowing. |
| 鼻子 | 山根 | implemented | `noseRootNarrowing` | Independent inner dorsal surface narrowing with source-owned bridge protection. Repaired observed paired-eye path requires CPU; retained Metal rejects its unsupported raster cutoff with typed invalidInput. Never aliases `noseBridge`. |
| 鼻子 | 鼻梁 | implemented | `noseBridge` | Bridge definition. |
| 鼻子 | 鼻尖 | implemented | `noseTipSize` | Signed tip-size geometry. |
| 眉毛 | 上下 | implemented | `eyebrowYPosition` | Signed bilateral vertical translation. |
| 眉毛 | 粗细 | implemented | `eyebrowThickness` | Signed geometry-only trace thickness. |
| 眉毛 | 长短 | implemented | `eyebrowLength` | Signed outer-endpoint length geometry. |
| 眉毛 | 间距 | implemented | `eyebrowSpacing` | Signed whole-brow spacing. |
| 眉毛 | 眉头间距 | implemented | `eyebrowHeadSpacing` | Signed inner-head-only spacing along each side's canonical axis; per-side fail-closed and distinct from whole-brow spacing. |
| 眉毛 | 倾斜 | implemented | `eyebrowTilt` | Signed local rotation. |
| 眉毛 | 眉峰 | implemented | `eyebrowPeakDefinition` | Bounded interior-apex geometry. |
<!-- SDK_LEGACY_TAXONOMY_END -->

Branch status remains conservative: `3D塑颜`, `比例`, and `脸型` are
partial; `眼睛`, `嘴唇`, `鼻子`, and `眉毛` are implemented at SDK-core
scope. `3D塑颜` has bounded image-space vertical and horizontal controls so far; `脸型`
is partial because double-chin and hairline semantic-region work is
future. The `眼睛` branch is implemented with the explicit provisional-quality
caveat on `去脂`; this does not establish commercial visual quality.

## Non-legacy SDK groups

- Skin owns smoothing, whitening, rosy tone, and sharpening. Current smoothing
  and sharpening use bounded spatial luminance-detail filters.
- Global tone owns brightness, contrast, saturation, temperature, tint,
  exposure, highlights, and shadows. Still-image highlights and shadows now
  apply the bounded selective lift to bright and dark source-luminance regions.
- Filters use a logical `filterId` plus bounded `filterIntensity`.

These groups are product-neutral SDK effects. Home/discovery, galleries,
templates, search, VIP/payment, AI content feeds, account behavior, and visual
editor organization are application/product surfaces and have no SDK mapping.

## Update rule

Update this file in the same change that adds, removes, renames, or promotes a
public effect. A row becomes `implemented` only with SDK behavior, safety and
degradation coverage, and public-facade output evidence where applicable. Do not
promote from archived UI presence, a disabled control, provider-only mechanics,
or a future plan. The Phase-79 archive continues to record exact 61-field,
five-preset, 74-case absence at its historical close. The current owner-accepted
surface is 64 fields, five presets, and 79 renderer cases.
`implemented` is an owner-local engineering status only and never authorizes
external distribution or commercial release.

## Historical Phase 90 Chin Repair and Contour Deferral

Phase 90 preserves the taxonomy distinction between one proven repair and one
deferred field:

- `chinTaper` / `尖下巴` remains `implemented`. Its evidence is the measured
  request-local, centerline-owned paired lower-chin behavior recorded by Plan
  90-02, including exact `0.25` cap, neutral/deterministic behavior, locality,
  protected regions, and field-local recovery through the existing owner-local
  still-image facades.
- `faceContourSmooth` / `面部流畅` was `partial` at Phase 90 close. The public
  field stayed owner-local and callable with its then-unchanged, fail-closed
  behavior. Revision 22 classified only `prior_stop_not_reproduced` with zero
  render/oracle invocations; it is diagnostic-only and supplies no semantic,
  repair, effectiveness, or GREEN authority. No revision 23 is authorized.
  Further repair was tracked as FUTURE-04 and is now addressed by the
  2026-09-26 generated-portrait acceptance described in the current row.

At Phase 90 close, the inventory remained 62 stored fields, five presets, and
75 renderer cases. Both public still-image facades, the CPU-reference/selectable-
GPU policy, retained `Warp.metal`, request-local privacy, SDK-only owner use,
and non-distribution boundary remain unchanged. Phase 95 owns the direct chin
precision/tie residual, the clean 65-output seven-effective-plus-one-deferred
publication, and the complete no-skip closeout; Phase 90 provides no device,
commercial-quality, packaging, shipping, launch, release, or distribution
qualification.

## Phase 91 Independent Gaze Correction

`gazeCorrection` / `眼神矫正` retains `implemented` status after Phase 91.
Positive gaze uses only independently valid request-local observed support for
each eye; it never borrows peer geometry or revives a darkness, symmetric, or
legacy proxy. Exact displacement `0.002` is neutral, the public input caps at
`0.25`, cap motion is 35% toward that eye's own center, and the influence radius
is bounded by half the source/target aperture clearances. Invalid or absent
support fails closed per eye while a valid peer continues.

Generated public-facade pixels prove own-center direction, target signal,
protected regions, neutral behavior, determinism, and recovery. The final
six-field aggregate is output-identity-bound and cannot replace the actual-
pixel target, sibling, locality, or protection gates; temporary reports are
verified removed before any durable result. This qualification changes no
taxonomy tuple or public surface: exactly 62 stored fields, five presets, 75
renderer cases, both still-image facades, CPU/GPU policy, and retained
`Warp.metal` remain unchanged.

Phase 95 still owns the authorized portrait rerun, final clean 65-output
publication, and complete no-skip closeout. Phase 91 supplies no device,
population, naturalness, commercial-quality, packaging, shipping, launch,
release, or distribution qualification.

## Phase 92 Signed Eyebrow-Head Spacing

R5 (`470ae0d`) qualifies the existing implemented row with generated owner-local
package-host evidence for positive/negative inner-head motion. Each side fails
closed independently; dense same-side overlap is bounded by the final 0.9 sum
of displacement norm/radius. The unchanged actual-pixel oracle passes signs
+48/-22 Q16, all sibling distinctions and zero protected-region changes.
Neutral, metadata, unilateral peer protection and deterministic recovery pass.
The 62 fields/5 presets/75 renderer cases and facades/backends/shader are unchanged.
Phase 95 retains portrait evaluation and full no-skip closeout. No portrait,
device, commercial-quality or external-distribution approval is implied.

## Phase 93 Distinct Nose Bridge and Root Qualification

The existing implemented `noseBridge` and `noseRootNarrowing` rows retain
their mappings and statuses. Candidate 2 qualifies their distinct owner-local
generated mechanics through
[93-CHECKS.json](../.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-CHECKS.json)
and independent code review, without promoting another control or changing
FACE-01, the 62 fields, five presets, 75 cases, facades or backend policy.

Canonical bridge source/neutral evidence is 611 changed pixels / 29460 RGB,
+383 Q8 and minimum sibling margin 373; root is 1043 / 43917, +24 Q16 and
minimum sibling margin 24. Comparisons are 6/5, repeats 1/1, and all protected,
outside, background and watermark changes are 0/0. The eight-orientation
bridge raw-facade agreement test does not qualify root semantics at every
orientation. Core 36/0/0, compatibility 229/0/0, eight script commands and
supplemental regression 106/0/0 have separate recorded evidence.

Both attempts and preserved failures retain their original meaning; no third
candidate or relaxed threshold supplies this qualification. Independent goal verification passed. Phase 95 retains private portraits, final-output
and full no-skip qualification; no naturalness, device, commercial or external
distribution approval is implied.

Independent goal verdict: [93-VERIFICATION.md](../.planning/phases/93-distinct-nose-bridge-and-root-repairs/93-VERIFICATION.md), 18/18 must-haves and zero blockers.

## Phase94 Mouth-Width Qualification

MOUTH-01 retains the existing implemented `mouthWidth` field and±0.35 cap;
no control, status count, preset or renderer case is added. Private policyB
repairs negative protection leakage and narrow-support crossing/reversal,
while the original positive/shared implementation and14 retained row hashes
remain unchanged. Acceptance is41/41 at CHECKS SHA256
`fa696dba3273f248924bdd34744088979bae1e23a35a8d5d433e1c379a8f3ac4`.
Source/neutral each520 changed pixels,73743 RGB,−24Q16; all five comparisons
and every protected-area bound pass. All negative protection maxima are0/0.
This is the owner-local registered generated-source CPU contract. Eight-encoding
lifecycle coverage does not establish semantic effectiveness for all faces or
orientations. Phase95 private portraits/final65/full no-skip, optional device
feedback, commercial quality and distribution claims remain separate.

## Historical v1.23 FACE-01 Snapshot

The old Phase 90 `completed-deferred` record remains true for its snapshot.
At v1.23 close, the owner-authorized FACE-01 candidate passed the unchanged generated
`+16 Q16` gate, with source-exact neutral behavior, bounded lateral changes,
protected-region stability, and public-facade pixels. It was still `partial` then:
the one available natural portrait produced a bounded target-area pixel signal
but no measured contour-direction gain or clear visual improvement. The old
portrait comparator's fixed generated-image FACE-01 ROIs do not localize that
portrait, and a source-admitted exploratory ROI still measured `0 Q16` gain.
An independent generated silhouette edge oracle exposed a second raster
alignment that worsened under the first candidate. A bounded source-edge
correction passed both generated alignments and left a straight-side negative
unchanged. The field stayed `partial` because the existing portrait pair had not
demonstrated rough-positive improvement and smooth-negative non-worsening.
The owner-directed [v1.23 qualification](../.planning/V1.23-FACE01-CURRENT.md)
used two fictional generated portraits for a bounded synthetic-mechanics
completion claim. Their render and repeat results gave no natural-portrait
direction credit. The later 2026-09-26 generated rough-positive/smooth-negative
acceptance is recorded in the current taxonomy row and `PLANS.md`; it did not
change any historical receipt or FACE-01 threshold.
