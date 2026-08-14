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

Status has exactly these meanings:

- `implemented`: SDK behavior exists, relevant safety/degradation tests pass,
  and public-facade output evidence exists when the effect changes pixels.
- `partial`: some SDK capability maps to the concept, but the exact branch or
  reference control is not independently complete.
- `future`: no current SDK implementation claim; promotion requires a separately
  scoped product-neutral contract, implementation, and evidence.

Appearance in this document never creates a public API. The public contract is
`BeautyParameters` in `BeautyCore`; this file maps product taxonomy onto that
contract without renaming or aliasing unsupported behavior.

## Current public parameter inventory

The current contract contains exactly 61 stored fields: 60 numeric controls and
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
- Eye local color: `scleraRednessReduction`
- Filter: `filterId`, `filterIntensity`
<!-- SDK_PARAMETER_INVENTORY_END -->

`lipColor` is color-only and is not evidence for geometric `丰唇` (`lipPlump`).
`teethWhitening` and `scleraRednessReduction` are bounded opaque still-image
local-retouch controls. Neither implies realtime/pixel-buffer support.
`去脂` remains future upper-eyelid-fullness work and must not alias
`eyeHeight`, `upperEyelidLift`, brow movement, eye opening, eye-bag removal,
dark-circle removal, or global smoothing. Request-local masks and face geometry
are implementation details, not taxonomy entries or public diagnostics.

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
| 脸型 | 面部流畅 | implemented | `faceContourSmooth` | Observed-contour continuity only. |
| 脸型 | 太阳穴 | implemented | `templeFullness` | Upper-lateral contour geometry. |
| 脸型 | 颧骨 | implemented | `cheekboneSlim` | Mid-lateral contour geometry. |
| 脸型 | 下巴长短 | implemented | `chinLength` | Signed chin-length geometry. |
| 脸型 | 去双下巴 | future | — | Requires approved local semantic-region support. |
| 脸型 | 去双下巴 Pro | future | — | Semantic support and commercial entitlement are both outside current scope. |
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
| 眼睛 | 去脂 | future | — | Upper-eyelid fullness needs an independently qualified non-proxy method. |
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

Branch status remains conservative: `3D塑颜` is future; `比例`, `脸型`, and
`眼睛` are partial; `嘴唇`, `鼻子`, and `眉毛` are implemented at SDK-core
scope. `脸型` is partial because double-chin and hairline semantic-region work is
future. `眼睛` is partial solely because `去脂` is future.

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
or a future plan.
