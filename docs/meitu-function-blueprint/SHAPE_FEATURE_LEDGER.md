# Meitu Shape and Facial Feature SDK Ledger

**Created:** 2026-07-04
**Scope:** SDK core functionality only. No new SwiftUI screens, no Demo UI rebuild, no account/commercial behavior, and no remote processing.
**Canonical reference:** `meituxiuxiu/FUNCTION_MAP.md`

This ledger is the local 1:1, de-duplicated record for the Meitu Xiuxiu editor `美型 / 五官` taxonomy. It tracks first-level function groups and their second-level tools, then records the SDK-core implementation status for each tool.

## First-Principles Boundary

The product goal is not to copy UI. The goal is to build product-neutral SDK capabilities that can support the reference taxonomy.

1. **Reference taxonomy stays exact:** First-level and second-level names follow the Meitu screenshots after duplicate screenshot states are merged.
2. **SDK names stay product-neutral:** Chinese taxonomy can appear in docs and Demo mapping, but public SDK parameters should use stable domain names such as `faceSlim`, `eyeSize`, or future neutral equivalents.
3. **No UI requirement:** A feature can be SDK-complete without new SwiftUI. UI work is a separate milestone unless explicitly scoped.
4. **No fake completion:** A tool is not implemented just because it appears in a Demo rail. It must have SDK behavior and verification.
5. **Geometry needs output proof:** Geometry provider/resolver evidence is useful, but geometry tools remain below `implemented` until public facade processing can produce representative saved output through the SDK verification path.
6. **Privacy stays local-first:** No cloud upload, network AI, raw landmark persistence, raw-frame persistence, or sensitive path logging is allowed by default.

## Status Markers

| Marker | Meaning | Required update when reached |
| --- | --- | --- |
| `future` | Tool is recorded from the Meitu taxonomy but has no current SDK implementation claim. | Keep this ledger and branch README honest. |
| `partial` | SDK has a current parameter, provider/resolver behavior, unit evidence, or subtool evidence, but not enough facade-visible output for completion. | Update this ledger, branch README, and `FEATURE_MATRIX.md` if branch-level status changes. |
| `blocked-by-geometry-output` | Tool or branch needs public facade detection plus geometry render integration before saved-image output can prove behavior. | Record blocker, rerun protocol, and evidence needed. |
| `implemented` | SDK behavior exists, tests pass, safety/degradation is covered, and facade-visible output evidence exists when the tool has visible output. | Mark the tool implemented here; update branch README, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, and milestone evidence. |

## Completion Checklist

Before marking a second-level tool `implemented`:

1. Public or internal SDK contract is named and documented.
2. `BeautyEffects` behavior exists or the tool is intentionally owned by another SDK target.
3. Safety caps and missing-landmark degradation are covered.
4. Tests cover normal behavior and relevant blocker/degradation paths.
5. Public `BeautySDK` facade can exercise the behavior.
6. `BeautyExampleRenderer` or an equivalent SDK-only verification path records visible output when applicable.
7. This ledger and the owning branch README are updated in the same phase closeout.

## De-Duped Taxonomy

| First-level group | Reference images | De-duplication note |
| --- | --- | --- |
| `3D塑颜` | `IMG_0870.PNG` | One unique group. |
| `比例` | `IMG_0868.PNG`, `IMG_0869.PNG` | Two horizontal scroll positions merged. |
| `脸型` | `IMG_0856.PNG`, `IMG_0866.PNG`, `IMG_0867.PNG` | Three horizontal scroll positions merged; duplicated `去双下巴` and `去双下巴 Pro` kept as separate tools because one is a Pro variant. |
| `眼睛` | `IMG_0857.PNG`, `IMG_0858.PNG`, `IMG_0859.PNG` | Three horizontal scroll positions merged. |
| `嘴唇` | `IMG_0860.PNG`, `IMG_0861.PNG` | Two horizontal scroll positions merged. |
| 鼻子 | `IMG_0862.PNG`, `IMG_0863.PNG` | Two horizontal scroll positions merged. |
| `眉毛` | `IMG_0864.PNG`, `IMG_0865.PNG` | Two horizontal scroll positions merged. |

## Tool Ledger

| Group | Second-level tool | SDK status | Current SDK coverage | Completion gap |
| --- | --- | --- | --- | --- |
| `3D塑颜` | 对称 | blocked-by-geometry-output | None. | Product-neutral parameter, pose/landmark design, provider behavior, facade geometry output. |
| `3D塑颜` | 上下 | blocked-by-geometry-output | None. | Product-neutral parameter, pose/landmark design, provider behavior, facade geometry output. |
| `3D塑颜` | 左右 | blocked-by-geometry-output | None. | Product-neutral parameter, pose/landmark design, provider behavior, facade geometry output. |
| `3D塑颜` | 倾斜 | blocked-by-geometry-output | None. | Product-neutral parameter, pose/landmark design, provider behavior, facade geometry output. |
| `比例` | 小头 | partial | Existing `faceSmall` coverage maps to a small-head style control. | Facade-visible geometry output and branch-specific acceptance evidence. |
| `比例` | 头包脸 | future | None. | Define neutral parameter and geometry behavior. |
| `比例` | 颅顶 | future | None. | Define neutral parameter and geometry behavior. |
| `比例` | 额头 | future | None. | Define neutral parameter and geometry behavior. |
| `比例` | 中庭 | future | None. | Define neutral parameter and geometry behavior. |
| `比例` | 人中 | future | None. | Define neutral parameter and geometry behavior. |
| `比例` | 下庭 | future | None. | Define neutral parameter and geometry behavior. |
| `比例` | 短脸 | future | None. | Define neutral parameter and geometry behavior. |
| `脸型` | 脸宽 | implemented | Existing `faceSlim` coverage plus Phase 28 renderer case `faceSlim_0p35`, safety/degradation tests, and `28-FACE-SHAPE-RENDERER-EVIDENCE.md`. | Complete for the v1.5 scoped SDK slice; broader quality/device review remains separate. |
| `脸型` | 小脸 | implemented | Existing `faceSmall` coverage plus Phase 28 renderer case `faceSmall_0p35`, safety/degradation tests, and `28-FACE-SHAPE-RENDERER-EVIDENCE.md`. | Complete for the v1.5 scoped SDK slice; broader quality/device review remains separate. |
| `脸型` | 面部流畅 | future | None. | Define neutral parameter, geometry behavior, and safety caps. |
| `脸型` | 太阳穴 | future | None. | Define neutral parameter, geometry behavior, and safety caps. |
| `脸型` | 颧骨 | future | None. | Define neutral parameter, geometry behavior, and safety caps. |
| `脸型` | 下巴长短 | implemented | Existing signed `chinLength` coverage plus Phase 28 renderer cases `chinLength_plus0p30` and `chinLength_minus0p30`, safety/degradation tests, and `28-FACE-SHAPE-RENDERER-EVIDENCE.md`. | Complete for the v1.5 scoped SDK slice; broader quality/device review remains separate. |
| `脸型` | 去双下巴 | future | None. | Needs local retouch/geometry design; no cloud or remote AI by default. |
| `脸型` | 去双下巴 Pro | future | None. | Pro/commercial gating is out of scope; core SDK behavior would still need local design first. |
| `脸型` | 尖下巴 | future | None. | Define neutral parameter and geometry behavior. |
| `脸型` | V脸 | implemented | Existing `faceVShape` coverage plus Phase 28 renderer case `faceVShape_0p35`, safety/degradation tests, and `28-FACE-SHAPE-RENDERER-EVIDENCE.md`. | Complete for the v1.5 scoped SDK slice; broader quality/device review remains separate. |
| `脸型` | 下颌角 | implemented | Existing `jawSlim` coverage plus Phase 28 renderer case `jawSlim_0p35`, safety/degradation tests, and `28-FACE-SHAPE-RENDERER-EVIDENCE.md`. | Complete for the v1.5 scoped SDK slice; broader quality/device review remains separate. |
| `脸型` | 下颌线 | implemented | Phase 28 v1.5 evidence is alias-backed by `jawSlim` and shared with `下颌角`; renderer case `jawSlim_0p35`, safety/degradation tests, and `28-FACE-SHAPE-RENDERER-EVIDENCE.md` apply. | Complete only as a documented `jawSlim` alias; a distinct neutral parameter would require future design and evidence. |
| `脸型` | 发际线 | future | None. | Needs segmentation/resource design if promoted. |
| `眼睛` | 大小 | implemented | Existing `eyeSize` coverage, Phase 29 `eyeSize_0p35` output in `29-EYE-RENDERER-EVIDENCE.md`, and Phase 30 safety/degradation/boundary evidence in `30-EYE-SAFETY-EVIDENCE.md`. | Complete for this existing-parameter subtool only; broader eye tools and review remain separate. |
| `眼睛` | 上下 | implemented | Existing signed `eyeYPosition` coverage, Phase 29 positive/negative output in `29-EYE-RENDERER-EVIDENCE.md`, and Phase 30 safety/degradation/boundary evidence in `30-EYE-SAFETY-EVIDENCE.md`. | Complete for this existing-parameter subtool only; broader eye tools and review remain separate. |
| `眼睛` | 眼高 | future | None. | Define neutral parameter and geometry behavior. |
| `眼睛` | 长度 | future | None. | Define neutral parameter and geometry behavior. |
| `眼睛` | 眼距 | implemented | Existing signed `eyeDistance` coverage, Phase 29 positive/negative output in `29-EYE-RENDERER-EVIDENCE.md`, and Phase 30 safety/degradation/boundary evidence in `30-EYE-SAFETY-EVIDENCE.md`. | Complete for this existing-parameter subtool only; broader eye tools and review remain separate. |
| `眼睛` | 去脂 | future | None. | Needs local retouch/segmentation design; no cloud AI by default. |
| `眼睛` | 提肌 | future | None. | Define neutral parameter and geometry behavior. |
| `眼睛` | 眼瞳大小 | future | None. | Needs iris/pupil-safe design and privacy-safe detection assumptions. |
| `眼睛` | 眼神矫正 | future | None. | Needs gaze/landmark design and conservative safety policy. |
| `眼睛` | 眼睑下至 | future | None. | Define neutral parameter and geometry behavior. |
| `眼睛` | 眼尾上扬 | implemented | Existing `eyeTailLift` coverage, Phase 29 `eyeTailLift_0p25` output in `29-EYE-RENDERER-EVIDENCE.md`, and Phase 30 safety/degradation/boundary evidence in `30-EYE-SAFETY-EVIDENCE.md`. | Complete for this existing-parameter subtool only; broader eye tools and review remain separate. |
| `眼睛` | 倾斜 | future | None. | Define neutral parameter and geometry behavior. |
| `眼睛` | 祛红血丝 | future | None. | Needs local color/segmentation retouch design. |
| `眼睛` | 内眼角 | future | None. | Define neutral parameter and geometry behavior. |
| `眼睛` | 外眼角 | future | None. | Define neutral parameter and geometry behavior. |
| `眼睛` | 对称 | future | None. | Define neutral parameter and geometry behavior. |
| `嘴唇` | 大小 | implemented | Existing signed `mouthSize`; Phase 33 positive/negative output plus Phase 34 exact-cap, degradation, combined-safety, and boundary evidence. | Complete for this existing-parameter subtool only; branch review remains separate. |
| `嘴唇` | 宽度 | implemented | Existing signed `mouthWidth`; Phase 33 positive/negative output plus Phase 34 exact-cap, degradation, combined-safety, and boundary evidence. | Complete for this existing-parameter subtool only. |
| `嘴唇` | 上下 | future | None. | Define neutral parameter and geometry behavior. |
| `嘴唇` | 倾斜 | future | None. | Define neutral parameter and geometry behavior. |
| `嘴唇` | 左右 | future | None. | Define neutral parameter and geometry behavior. |
| `嘴唇` | M唇 | future | None. | Define neutral parameter and geometry behavior. |
| `嘴唇` | 丰唇 | partial | Demo currently maps this to `lipColor`, which is visible color evidence, not true geometry plump behavior. | Decide whether to create a distinct geometry parameter or relabel mapping; then add facade-visible evidence. |
| `嘴唇` | 微笑 | implemented | Existing `smile`; Phase 33 output plus Phase 34 exact-cap, degradation, combined-safety, and boundary evidence. | Complete for this existing-parameter subtool only. |
| `嘴唇` | 白牙 | future | None. | Needs local teeth segmentation/retouch design. |
| `鼻子` | 大小 | implemented | Existing `noseSlim`; Phase 31 `noseSlim_0p35` output plus Phase 32 exact-cap, degradation, combined-safety, and boundary evidence. | Complete for this existing-parameter subtool only; branch review remains separate. |
| `鼻子` | 提升 | implemented | Independent public `noseTipLift`; Phase 35 contract/provider evidence, Phase 36 isolated facade output distinct from both signed `noseTipSize` directions, and Phase 37 exact-cap, six-field degradation, combined-safety, and boundary evidence. | Complete for the exact SDK-core nose taxonomy; device/commercial visual review remains separate. |
| `鼻子` | 鼻翼 | implemented | Existing `noseWingSlim`; Phase 31 `noseWingSlim_0p35` output plus Phase 32 safety/degradation/boundary evidence. | Complete for this existing-parameter subtool only. |
| `鼻子` | 山根 | implemented | Independent public `noseRootNarrowing`; Phase 35 contract/provider evidence, Phase 36 isolated facade output distinct from `noseBridge`, and Phase 37 exact-cap, six-field degradation, combined-safety, and boundary evidence. | Complete independently; this row does not borrow `noseBridge` / `鼻梁` evidence. |
| `鼻子` | 鼻梁 | implemented | Existing `noseBridge`; Phase 31 `noseBridge_0p30` output plus Phase 32 safety/degradation/boundary evidence. | Complete for this existing-parameter subtool only; not evidence for `山根`. |
| `鼻子` | 鼻尖 | implemented | Existing signed `noseTipSize`; Phase 31 positive/negative output plus Phase 32 signed-cap, degradation, and combined-safety evidence. | Complete for this signed existing-parameter subtool only. |
| `眉毛` | 上下 | future | None. | Needs landmark/resource design if promoted. |
| `眉毛` | 粗细 | future | None. | Needs landmark/resource design if promoted. |
| `眉毛` | 长短 | future | None. | Needs landmark/resource design if promoted. |
| `眉毛` | 间距 | future | None. | Needs landmark/resource design if promoted. |
| `眉毛` | 眉头间距 | future | None. | Needs landmark/resource design if promoted. |
| `眉毛` | 倾斜 | future | None. | Needs landmark/resource design if promoted. |
| `眉毛` | 眉峰 | future | None. | Needs landmark/resource design if promoted. |

## Update Rule After Feature Completion

When a phase completes any SDK-core tool:

1. Update the corresponding row in this ledger.
2. Update the owning branch README under `features/beauty-shaping/`.
3. Update `FEATURE_MATRIX.md` only when branch-level status changes.
4. Update `EXAMPLE_IMAGE_VALIDATION.md` when new SDK verification output exists.
5. Record exact commands and evidence in the phase verification artifact.

Do not mark a tool `implemented` from Demo-only mapping, planned taxonomy, or provider-only evidence.
