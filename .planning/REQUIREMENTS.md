# Requirements: Beauty

**Defined:** 2026-06-23
**Milestone:** v1.1 Meitu UI
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.1 Requirements

Requirements for the Meitu UI rebuild milestone. Each requirement maps to exactly one roadmap phase.

### Home Experience

- [x] **HOME-01**: User sees a Meitu Xiuxiu-style Home first screen matching `meituxiuxiu/HOME_MAP.md`, with dark background, retro film hero, search capsule, brand capsule, VIP chip, orange `拍一拍` CTA, and no SDK-dashboard copy.
- [x] **HOME-02**: User sees primary Home actions in the same hierarchy as the reference: large `图片美化` and `修视频` cards, then smaller `人像美容`, `拼图`, `相机`, and `视频美容` cards.
- [x] **HOME-03**: User can swipe or page through the Home tool grid states represented by `IMG_0871.PNG`, `IMG_0872.PNG`, and `IMG_0873.PNG`, with a visible page indicator.
- [x] **HOME-04**: User sees recommendation sections matching the reference content pattern, including `欧美闪光滤镜`, `不能错过热门玩法`, `欧美曲线塑形`, and `欧美美容常态`, each as horizontal rounded image-card rails.
- [x] **HOME-05**: User sees the floating bottom tab bar with `首页`, `图库`, `AI 修图`, and `我`; `首页` is selected with white text and a pink underline, and `我` shows a small pink dot.
- [x] **HOME-06**: When the Home screen scrolls down, the hero collapses out of view and the primary actions become a sticky horizontal shortcut rail matching `IMG_0874.PNG`.

### Editor Experience

- [x] **EDIT-01**: User can enter a Meitu-style editor screen with full-screen camera/photo preview above a white bottom tool panel, not a form-like SDK panel.
- [x] **EDIT-02**: User sees the editor chrome from `meituxiuxiu/FUNCTION_MAP.md`: centered brand capsule, `背景保护` toggle, compare affordance, intensity slider, `整体` chip, left cancel button, and right confirm button.
- [x] **EDIT-03**: User can switch first-level editor categories in the reference order: `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛`, with selected black text and pink underline.
- [x] **EDIT-04**: User can scroll second-level tool rails for each editor category, with icon/label items and static `限免`, `Pro`, or `OFF` badges where the reference shows them.
- [x] **EDIT-05**: User can adjust supported tools through one shared intensity slider, and the selected tool's value updates existing `BeautyParameterStore` state where an equivalent v1 SDK parameter exists.
- [x] **EDIT-06**: Unsupported Meitu reference tools remain visible but disabled/static with honest unavailable state; the Demo does not claim fake support for advanced makeup, segmentation, body shaping, AI style, or commercial Pro effects.
- [x] **EDIT-07**: User can cancel editor changes or confirm them without losing the previous preview, compare state, or selected input mode.

### Flow and Verification

- [x] **FLOW-01**: `图片美化` opens the local photo editing path and preserves existing PhotosPicker, still-image processing, loading, error, and compare behavior.
- [x] **FLOW-02**: `相机` and the Home `拍一拍` CTA open the local camera path and preserve existing permission, realtime processing, bounded in-flight, and privacy behavior.
- [x] **FLOW-03**: `人像美容` opens the editor focused on the Meitu-style beauty tool panel while still using the public `BeautySDK` facade and existing parameter model.
- [x] **FLOW-04**: Home actions that are not implemented in v1.1 remain visibly disabled or static, with no network/upload behavior and no misleading success state.
- [x] **FLOW-05**: Automated Demo tests cover Home view-state structure, editor taxonomy, supported parameter mapping, disabled unavailable tools, and facade-only import boundaries.
- [x] **FLOW-06**: Manual or screenshot-backed verification records that the Home first screen, Home scrolled state, and Editor tool panel visually match the local `meituxiuxiu` references closely enough for v1.1 acceptance.

## Future Requirements

Deferred to later releases. These are valuable but not in this milestone unless explicitly promoted.

### Advanced Reference Coverage

- **FUT-01**: User can use Home `图库`, `AI 修图`, and `我` tabs as fully functional screens.
- **FUT-02**: User can use actual AI tools such as AI 写真, AI 发型, AI 扩图, AI 消除, AI 改图, AI 合照, and AI 舞蹈.
- **FUT-03**: User can use Home VIP, search, template details, and recommendation-card detail flows.
- **FUT-04**: User can use real 3D/Pro facial shaping algorithms beyond the existing v1 `BeautyParameters` model.
- **FUT-05**: User can use makeup, segmentation/background, body shaping, stickers, AR masks, style effects, and video export.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Full consumer App Store product | The product remains an SDK with a Demo validation app. |
| Network AI generation or upload flows | Current privacy posture remains local-first and no-upload by default. |
| Paid membership or Pro entitlement logic | `限免`, `Pro`, and `VIP` are visual/static states in v1.1 only. |
| Real video editing pipeline | `修视频` and `视频美容` can be visible but are not v1.1 working video processors. |
| New SDK algorithm families | v1.1 focuses on UI fidelity and existing SDK parameter wiring, not new beauty algorithms. |
| Exact commercial asset copying | The Demo should match structure and feel using local/repo assets or generated placeholders, not depend on copyrighted app assets. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| HOME-01 | Phase 8 | Complete |
| HOME-02 | Phase 8 | Complete |
| HOME-03 | Phase 8 | Complete |
| HOME-04 | Phase 8 | Complete |
| HOME-05 | Phase 8 | Complete |
| HOME-06 | Phase 8 | Complete |
| EDIT-01 | Phase 9 | Complete |
| EDIT-02 | Phase 9 | Complete |
| EDIT-03 | Phase 9 | Complete |
| EDIT-04 | Phase 9 | Complete |
| EDIT-05 | Phase 9 | Complete |
| EDIT-06 | Phase 9 | Complete |
| EDIT-07 | Phase 9 | Complete |
| FLOW-01 | Phase 10 | Complete |
| FLOW-02 | Phase 10 | Complete |
| FLOW-03 | Phase 10 | Complete |
| FLOW-04 | Phase 10 | Complete |
| FLOW-05 | Phase 10 | Complete |
| FLOW-06 | Phase 10 | Complete |

**Coverage:**
- v1.1 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0
- Complete: 19

---
*Requirements defined: 2026-06-23*
*Last updated: 2026-06-24 after v1.1 implementation verification*
