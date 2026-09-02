# SDK Effect Taxonomy

This is the current SDK-owned authority for supported effect grouping and the
legacy `美型 / 五官` control vocabulary. It is intentionally independent of the
archived application and UI-reference source trees.

## Boundary

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

The current contract contains exactly 62 stored fields: 61 numeric controls and
the optional `filterId`. Unit controls normalize to `0...1`; signed controls
normalize to `-1...1`; `filterId` is an optional logical resource identifier.

<!-- SDK_PARAMETER_INVENTORY_BEGIN -->
- Skin: `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen`
- Global tone: `brightness`, `contrast`, `saturation`, `temperature`, `tint`, `exposure`, `highlight`, `shadow`
- Face: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`, `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, `chinTaper`
- Eyes: `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`, `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `eyeTilt`, `innerCornerOpen`, `outerCornerOpen`, `eyeSymmetry`
- Eyebrows: `eyebrowYPosition`, `eyebrowThickness`, `eyebrowLength`, `eyebrowSpacing`, `eyebrowHeadSpacing`, `eyebrowTilt`, `eyebrowPeakDefinition`
- Nose: `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`, `noseRootNarrowing`, `noseTipLift`
- Mouth and local color: `mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`, `lipPeakDefinition`, `lipPlump`, `lipColor`, `teethWhitening`
- Eye local retouch and color: `upperEyelidFullnessReduction`, `scleraRednessReduction`
- Filter: `filterId`, `filterIntensity`
<!-- SDK_PARAMETER_INVENTORY_END -->

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
known to be weak and is future quality work.

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
| 3D塑颜 | 上下 | future | — | Requires a new neutral whole-face geometry contract. |
| 3D塑颜 | 左右 | future | — | Requires a new neutral whole-face geometry contract. |
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
| 脸型 | 面部流畅 | partial | `faceContourSmooth` | Owner-local public field and current fail-closed observed-contour path remain available, but the bounded v1.22 Phase 90 attempt series did not meet the frozen effectiveness gate; further repair is deferred to a separately authorized milestone. |
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
| 眼睛 | 眼神矫正 | implemented | `gazeCorrection` | Bounded pupil-to-own-center correction. |
| 眼睛 | 眼睑下至 | implemented | `lowerEyelidDrop` | Lower-contour geometry. |
| 眼睛 | 眼尾上扬 | implemented | `eyeTailLift` | Outer-eye lift geometry. |
| 眼睛 | 倾斜 | implemented | `eyeTilt` | Signed paired-contour rotation. |
| 眼睛 | 祛红血丝 | implemented | `scleraRednessReduction` | Opaque still-image per-eye local color only. |
| 眼睛 | 内眼角 | implemented | `innerCornerOpen` | Independent inner-corner geometry. |
| 眼睛 | 外眼角 | implemented | `outerCornerOpen` | Independent outer-corner geometry. |
| 眼睛 | 对称 | implemented | `eyeSymmetry` | Bounded paired symmetry correction. |
| 嘴唇 | 大小 | implemented | `mouthSize` | Signed whole-mouth size geometry. |
| 嘴唇 | 宽度 | implemented | `mouthWidth` | Signed mouth width. |
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
| 鼻子 | 山根 | implemented | `noseRootNarrowing` | Independent root narrowing; never aliases `noseBridge`. |
| 鼻子 | 鼻梁 | implemented | `noseBridge` | Bridge definition. |
| 鼻子 | 鼻尖 | implemented | `noseTipSize` | Signed tip-size geometry. |
| 眉毛 | 上下 | implemented | `eyebrowYPosition` | Signed bilateral vertical translation. |
| 眉毛 | 粗细 | implemented | `eyebrowThickness` | Signed geometry-only trace thickness. |
| 眉毛 | 长短 | implemented | `eyebrowLength` | Signed outer-endpoint length geometry. |
| 眉毛 | 间距 | implemented | `eyebrowSpacing` | Signed whole-brow spacing. |
| 眉毛 | 眉头间距 | implemented | `eyebrowHeadSpacing` | Independent inner-head spacing. |
| 眉毛 | 倾斜 | implemented | `eyebrowTilt` | Signed local rotation. |
| 眉毛 | 眉峰 | implemented | `eyebrowPeakDefinition` | Bounded interior-apex geometry. |
<!-- SDK_LEGACY_TAXONOMY_END -->

Branch status remains conservative: `3D塑颜` is future; `比例` and `脸型` are
partial; `眼睛`, `嘴唇`, `鼻子`, and `眉毛` are implemented at SDK-core
scope. `脸型` is partial because double-chin and hairline semantic-region work is
future. The `眼睛` branch is implemented with the explicit provisional-quality
caveat on `去脂`; this does not establish commercial visual quality.

## Non-legacy SDK groups

- Skin owns smoothing, whitening, rosy tone, and sharpening.
- Global tone owns brightness, contrast, saturation, temperature, tint,
  exposure, highlights, and shadows.
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
surface is 62 fields, five presets, and 75 renderer cases.
`implemented` is an owner-local engineering status only and never authorizes
external distribution or commercial release.

## Phase 90 Chin Repair and Contour Deferral

Phase 90 preserves the taxonomy distinction between one proven repair and one
deferred field:

- `chinTaper` / `尖下巴` remains `implemented`. Its evidence is the measured
  request-local, centerline-owned paired lower-chin behavior recorded by Plan
  90-02, including exact `0.25` cap, neutral/deterministic behavior, locality,
  protected regions, and field-local recovery through the existing owner-local
  still-image facades.
- `faceContourSmooth` / `面部流畅` remains `partial`. The public field stays
  owner-local and callable with its current source-unchanged, fail-closed
  behavior. Revision 22 classified only `prior_stop_not_reproduced` with zero
  render/oracle invocations; it is diagnostic-only and supplies no semantic,
  repair, effectiveness, or GREEN authority. No revision 23 is authorized.
  Further repair is FUTURE-04 under a separately authorized milestone.

The current inventory remains exactly 62 stored fields, five presets, and 75
renderer cases. Both public still-image facades, the CPU-reference/selectable-
GPU policy, retained `Warp.metal`, request-local privacy, SDK-only owner use,
and non-distribution boundary remain unchanged. Phase 95 owns the direct chin
precision/tie residual, the clean 65-output seven-effective-plus-one-deferred
publication, and the complete no-skip closeout; Phase 90 provides no device,
commercial-quality, packaging, shipping, launch, release, or distribution
qualification.
