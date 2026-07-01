---
phase: 22
slug: automated-demo-qa-and-screenshot-evidence
status: draft
shadcn_initialized: false
preset: none
created: 2026-07-01
---

# Phase 22 - UI Design Contract

> Visual and interaction contract for Phase 22 Demo visual/layout QA. This phase captures or documents evidence for existing SwiftUI Home and Editor surfaces; it does not redesign the app or add product routes.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | Native SwiftUI, manual QA evidence contract |
| Preset | Not applicable; this is an iOS SwiftUI phase, not a web/shadcn phase |
| Component library | SwiftUI built-in controls plus existing `MeituHomeView`, `EditorShellView`, and `MeituEditorToolPanelView` |
| Icon library | SF Symbols only through `Image(systemName:)` in existing Demo source |
| Font | SF Pro via `.font(.system(...))` |

Source: `22-CONTEXT.md`, `22-RESEARCH.md`, `.planning/REQUIREMENTS.md`, `FRONTEND.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and current SwiftUI source. `components.json` and `package.json` are absent at the project root; shadcn initialization is explicitly out of scope.

---

## Spacing Scale

Declared values (must be multiples of 4):

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Badge inset, selected indicator height, icon-to-badge offsets |
| sm | 8px | Compact rail gaps, sticky rail vertical padding, label/icon gaps |
| md | 16px | Default horizontal screen inset, preview/status padding, evidence-note table rhythm |
| lg | 24px | Major group separation between Home action blocks, rails, and review-note sections |
| xl | 32px | Large Home/editor visual grouping separation only when already present |
| 2xl | 48px | Reserved for first-screen hero/review framing; do not add new QA UI with this gap |
| 3xl | 64px | Not used by Phase 22 evidence surfaces |

Exceptions: Existing SwiftUI values such as 10, 13, 14, 15, 18, 52, 75, 82, 116, and fixed rail/card dimensions are allowed as current-source facts for screenshot review. New Phase 22 code, if any minimal launch-only hook is required, must use the scale above and keep 44px minimum touch targets.

Rules:

- Do not change existing Home or Editor spacing to satisfy this phase.
- Screenshot review must check that current controls, labels, badges, bottom tabs, sticky rail, slider row, category rail, and tool rail do not clip or overlap at `platform=iOS Simulator,name=iPhone 17,OS=26.5`.
- Evidence notes must call out any visible clipping, overlap, or cramped text instead of silently accepting it.
- If an optional compact or large iPhone smoke screenshot is added, use the same spacing review checklist.

---

## Typography

Use exactly four review roles and two accepted weights for any new QA-only copy. Existing SwiftUI source may keep its current Meitu-style sizes and heavier decorative weights.

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Label / badge | 13px | regular 400 or semibold 600 | 1.4 |
| Body / control | 16px | regular 400 | 1.5 |
| Heading / rail title | 20px | semibold 600 | 1.2 |
| Display / screenshot focal text | 28px | semibold 600 | 1.2 |

Current-source review anchors:

| Surface | Text That Must Remain Legible |
|---------|-------------------------------|
| Home first screen | `复古胶片相机`, `不去建模 - 拍出氛围感照片`, `拍一拍`, `图片美化`, `修视频`, `人像美容`, `拼图`, `相机`, `视频美容` |
| Home sticky state | Sticky shortcut labels, bottom tabs `首页`, `图库`, `AI 修图`, `我`, recommendation section headings |
| Editor tool panel | Category order `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`; selected tool label; slider value; `对比`; `调试`; `背景保护`; `整体` |
| Disabled honesty | `限免`, `Pro`, `OFF`, and unavailable/future labels must remain readable and visibly secondary |

Rules:

- New QA artifacts and evidence README copy use regular 400 and semibold 600 only.
- Screenshot review may accept existing `.bold` / `.heavy` decorative Home/editor source where already implemented; Phase 22 must not introduce more display weights.
- Text inside rails, badges, and icon buttons must fit by line limit, minimum scale, or stable width; evidence notes must record any truncation that hides route or disabled-state meaning.

---

## Color

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | `#000000` | Home background, editor preview background, black chrome, screenshot framing |
| Secondary (30%) | `#FFFFFF` | Editor bottom tool panel, Home VIP/search surfaces, badges, cards, overlay surfaces |
| Accent (10%) | `#FF2F68` | Editor selected tool ring, selected category underline, slider tint, selected bottom-tab indicator |
| Destructive | `#D92D20` | Not used in current Phase 22 surfaces; reserve for documented destructive actions only |

Accent reserved for: selected editor tool ring, editor category underline, slider tint, selected bottom-tab indicator, and active selection emphasis already present in current source.

Supporting current-source colors allowed in screenshots:

| Token | Value | Usage |
|-------|-------|-------|
| Home CTA orange | `#FF8B2C` | Existing `拍一拍` hero CTA only |
| Home subtitle lime | `#D9E96F` | Existing hero subtitle only |
| Disabled gray | `#A8A8A8`, `#B4B4BA`, `#9B9BA1` | Unsupported/off tool badges, disabled labels, inactive rail items |
| Editor quiet surface | `#F7F7F7` | Existing `整体` capsule and quiet panel affordances |

Rules:

- Do not add a new color system for evidence, blockers, or optional QA hooks.
- Do not use accent for every interactive element; neutral actions stay black/white/gray unless selected.
- Disabled/future states must remain visibly inactive through gray text/badges and non-supported route behavior.

---

## Copywriting Contract

| Element | Copy |
|---------|------|
| Primary CTA | Capture Demo Screenshots |
| Empty state heading | No current v1.4 screenshots captured |
| Empty state body | Run the explicit iPhone 17 simulator build, install, launch, and `simctl io screenshot` commands, or record the local blocker before claiming evidence. |
| Error state | Demo screenshots are blocked by the local Metal Toolchain. Install it with `xcodebuild -downloadComponent MetalToolchain`, then rerun the recorded iPhone 17 commands. |
| Destructive confirmation | No destructive action in Phase 22. Do not add deletion, reset, or overwrite confirmation UI. |

Existing app copy that Phase 22 must preserve:

| Surface | Required Copy |
|---------|---------------|
| Home hero | `复古胶片相机`, `不去建模 - 拍出氛围感照片`, `拍一拍` |
| Home primary actions | `图片美化`, `修视频`, `人像美容`, `拼图`, `相机`, `视频美容` |
| Home tabs | `首页`, `图库`, `AI 修图`, `我` |
| Editor categories | `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛` |
| Editor controls | `背景保护`, `整体`, `对比`, `调试`, `取消`, `确认` |
| Unsupported badges | `限免`, `Pro`, `OFF` |
| Unsupported reason | `v1.1 暂未实现该美图参考功能` |

Copy rules:

- Evidence notes must say what was checked: clipping, overlap, disabled honesty, route scope, screenshot path, command, destination, and blocker/pass status.
- Evidence notes must not claim production naturalness, effect quality, physical-device parity, exact Meitu commercial parity, screenshot-diff coverage, or new product capability.
- If screenshot capture is blocked, use blocker language and rerun protocol; do not write pass language for current v1.4 screenshots.

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| shadcn official | none | Not applicable; native SwiftUI phase, `components.json` absent, `package.json` absent - 2026-07-01 |
| Third-party registries | none | Not applicable; no web registry or third-party UI block allowed - 2026-07-01 |

Rules:

- Phase 22 must not add shadcn, Tailwind, React, Next.js, Vite, web registries, or third-party UI blocks.
- If a reusable helper is added by execution, it must be a small local Demo/evidence helper, not a component registry or screenshot framework.

---

## Phase 22 Visual Evidence Contract

### Required States

| State | Launch Route | Required Evidence | Review Checks |
|-------|--------------|-------------------|---------------|
| Home first screen | normal launch, no route argument | `.planning/evidence/v1.4/home-first-screen.png` or blocker record | Hero, top chrome, `拍一拍`, primary action grid, visible disabled/static routes, no clipping/overlap |
| Home sticky state | `--beauty-demo-home-sticky` | `.planning/evidence/v1.4/home-sticky-state.png` or blocker record | Sticky shortcut rail visible, recommendation area framed, bottom tab bar visible, route labels readable, no overlap with safe areas |
| Editor beauty/photo tool panel | `--beauty-demo-route editor-beauty` or `--beauty-demo-route editor-photo` | `.planning/evidence/v1.4/editor-tool-panel.png` or blocker record | Black preview area, white bottom panel, slider row, tool rail, category rail, cancel/confirm actions, disabled badges readable |

Optional state: `--beauty-demo-route editor-camera` may produce `editor-camera-route.png` only if permission/session behavior is cheap and reliable. It must not block required completion.

### Evidence File Contract

The evidence README must be `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` and include:

- Scope and non-claims.
- Date, Xcode version, destination `platform=iOS Simulator,name=iPhone 17,OS=26.5`, and resolved simulator UDID if used.
- Exact `xcodebuild` build/test command results.
- Exact `simctl` boot/install/launch/screenshot commands when screenshots exist.
- Screenshot inventory with file paths, launch arguments, and captured state.
- Per-state factual review notes for clipping, overlap, disabled honesty, route scope, and framing.
- Metal Toolchain blocker record if build/capture is blocked.
- Physical iPhone manual protocol and blocked status unless actual hardware evidence exists.
- Rerun protocol.

### Review Note Format

Each required state needs a note with these fields:

| Field | Required Content |
|-------|------------------|
| Screenshot path | Exact `.planning/evidence/v1.4/*.png` path, or `not captured` with blocker reason |
| Command | Exact launch and screenshot command used |
| Framing | What first-viewport content is visible |
| Clipping / overlap | `pass`, `issue`, or `blocked`, with factual observation |
| Disabled honesty | Future or unsupported areas are inactive, visibly secondary, and not routable |
| Route scope | Confirms only current local Home/editor routes are active |
| Non-claims | Explicitly no production naturalness, physical-device parity, or screenshot-diff claim |

---

## Interaction Contract

### Launch Routing

- Normal launch must still show `MeituHomeView`.
- `--beauty-demo-home-sticky` must only force the existing sticky Home preview path.
- `--beauty-demo-route editor-photo` must open `EditorShellView` in photo mode.
- `--beauty-demo-route editor-beauty` must open the photo-backed beauty editor route.
- `--beauty-demo-route editor-camera` remains optional for Phase 22 evidence.
- Unknown route arguments must not enable hidden routes.

### Home Surface

- Supported Home routes remain limited to `图片美化`, `相机`, `拍一拍`, and `人像美容`.
- `修视频`, `拼图`, `视频美容`, AI tools, VIP/account/gallery tabs, video/body/product discovery, commerce, and entitlement flows remain static or disabled.
- Sticky preview must not create a new user-facing feature; it is a launch-only visual evidence hook.
- Screenshot review must verify the first screen and sticky state without using archived v1.1 or v1.2 screenshots as current pass evidence.

### Editor Tool Panel

- First-level editor category order stays: `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛`.
- Supported tools may write only existing `BeautyControlID` mappings through `BeautyParameterStore`.
- Unsupported tools stay visible with `限免`, `Pro`, `OFF`, gray treatment, or `v1.1 暂未实现该美图参考功能`.
- Slider row, `背景保护`, `整体`, `对比`, `调试`, and bottom cancel/confirm controls stay in the current bottom panel.
- Phase 22 must not add new editor categories, public `BeautyParameters`, parameter mappings, export flows, or SDK algorithm behavior.

### Blocker Honesty

- If the Metal Toolchain blocker remains, Phase 22 may record blocker evidence and rerun protocol, but must not claim screenshots passed.
- Blocker records must include exact command, destination, environment, failure summary, impact, and next step.
- Archived screenshots are background comparison only.

---

## Component Inventory

| Component / Model | Phase 22 Contract |
|-------------------|-------------------|
| `ContentView` | Owns launch argument routing for Home sticky and editor routes; unknown routes stay inert. |
| `MeituHomeView` | Existing Home first screen and sticky preview surface; no redesign or route expansion. |
| `MeituHomeModels` | Source of truth for enabled and disabled Home routes, primary actions, tools, recommendations, and tabs. |
| `EditorShellView` | Existing photo/camera shell and black preview area; screenshot route starts here for editor evidence. |
| `MeituEditorToolPanelView` | Existing white bottom panel with slider row, tool rail, category rail, and cancel/confirm actions. |
| `MeituEditorToolModels` | Source of truth for category order, supported tool mappings, badges, and unsupported reasons. |
| `BeautyDemoViewStateTests` | Existing route/model honesty tests; execution may extend only narrow QA-04 gaps. |
| `.planning/evidence/v1.4/VISUAL-EVIDENCE.md` | Required evidence ledger for commands, screenshots or blockers, review notes, and non-claims. |

---

## Checker Sign-Off

- [ ] Dimension 1 Copywriting: PASS
- [ ] Dimension 2 Visuals: PASS
- [ ] Dimension 3 Color: PASS
- [ ] Dimension 4 Typography: PASS
- [ ] Dimension 5 Spacing: PASS
- [ ] Dimension 6 Registry Safety: PASS

**Approval:** pending
