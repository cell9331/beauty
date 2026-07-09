---
phase: 07
slug: rich-demo-qa-surface
status: approved
shadcn_initialized: false
preset: none
created: 2026-06-22
reviewed_at: 2026-06-22T18:01:11+08:00
---

# Phase 07 - UI Design Contract

> Visual and interaction contract for Phase 7 Demo QA surface work. This phase adds parameter JSON import/export, final read-only debug overlay, compare/debug polish, unavailable-state polish, and final Demo QA evidence without changing the SDK public UI boundary.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | Native SwiftUI, manual contract |
| Preset | Not applicable; this is not a web/shadcn phase |
| Component library | SwiftUI built-in controls plus existing `EditorShellView`, `BeautyPanelView`, rails, sliders, picker chips, status capsules, and preview surface components |
| Icon library | SF Symbols only through `Image(systemName:)`; text labels remain visible for unfamiliar actions |
| Font | SF Pro via `.font(.system(...))` |

Source: `07-CONTEXT.md`, `07-RESEARCH.md`, `FRONTEND.md`, `PRODUCT_SENSE.md`, `SECURITY.md`, `RELIABILITY.md`, current SwiftUI source, and approved Phase 4/5 UI contracts. No `components.json`, Tailwind, postcss, React, Next.js, Vite, or web component registry config exists in the repository.

---

## Spacing Scale

Declared values (must be multiples of 4):

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon gaps, compact inline badges, row dividers |
| sm | 8px | Toolbar gaps, debug row gaps, chip gaps, sheet field spacing |
| md | 16px | Default preview padding, sheet padding, panel padding, grouped control spacing |
| lg | 24px | Preview message horizontal inset and sheet section separation |
| xl | 32px | Major separation between JSON preview summary and editor field when needed |
| 2xl | 48px | Reserved for large empty-state separation only; do not add to compact toolbars |
| 3xl | 64px | Not used by Phase 7 Demo surfaces |

Exceptions: 44px minimum touch target height for compare, debug, JSON, reset, preset, filter, and sheet action controls. This is a hit-target rule, not a spacing token.

Rules:

- New Phase 7 controls use 8px internal row gaps and 16px default container padding.
- Do not introduce non-scale spacing values for the JSON sheet, debug overlay, or preview toolbar.
- Preview overlays must stay inset from the preview edge and must not overlap slider rows, category rails, or photo picker actions.

---

## Typography

Use exactly four sizes and two weights.

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Label / debug row | 13px | regular 400 or semibold 600 | 1.4 |
| Body | 16px | regular 400 | 1.5 |
| Heading | 20px | semibold 600 | 1.2 |
| Display | 28px | semibold 600 | 1.2 |

Rules:

- Use regular 400 and semibold 600 only.
- Use 13px for preview toolbar buttons, debug overlay rows, JSON sheet field labels, import/export helper copy, badges, reset controls, and compact state copy.
- Use 16px for JSON editor body text, preview body copy, and normal sheet body copy.
- Use 20px for sheet headings and panel headings.
- Use 28px only for the existing first-screen preview heading; do not use display text in debug rows, JSON actions, chips, or disabled-category copy.

---

## Color

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | `#F7F8FA` | App background, inactive enabled controls, quiet sheet background |
| Secondary (30%) | `#FFFFFF` | Preview surface, parameter panel, JSON sheet field surface, debug overlay surface, status capsule |
| Accent (10%) | `#2F6BFF` | Selected mode/category/subcategory, selected preset/filter chip, primary sheet action, slider tint, preview toolbar focus, status dot |
| Destructive | `#D92D20` | Invalid import message marker and destructive-only semantics if a future persisted deletion is added |

Accent reserved for: selected Camera/Photo mode, selected top-level category, selected Facial Features subcategory, selected preset chip, selected filter chip, slider tint, `Preview Parameter JSON`, `Apply Imported Parameters`, `Copy Parameter JSON`, debug toggle active state, preview toolbar focus, status dot, and `#EEF3FF` informational badge backgrounds.

Supporting neutrals:

| Token | Value | Usage |
|-------|-------|-------|
| Disabled surface | `#EEF0F3` | Disabled categories, disabled future controls, unavailable resource chips |
| Accent tint | `#EEF3FF` | Informational badges and active-but-quiet debug/source chips |
| Muted text | `#8A8F98` | Disabled labels, helper copy, unavailable reasons |
| Status text | `#202F4D` | Preview status, debug rows, import preview summary |

Rules:

- Do not introduce a second accent palette for JSON, debug, source, or future-category states.
- Do not use accent for every control. Secondary actions use neutral styling unless selected or focused.
- Invalid import copy uses the destructive color only for the error marker or heading; the current parameter state must remain visually stable.

---

## Visual Hierarchy

Primary screen focal point: the preview surface remains the dominant visual anchor. Phase 7 adds QA controls around it without competing with the image/camera output.

Hierarchy:

1. Preview content, loaded photo, or live camera surface.
2. Preview toolbar with `Show Before` / `Show After`, `Show Debug Details`, and `Parameter JSON`.
3. Non-blocking status capsule or read-only debug overlay when enabled.
4. Parameter panel controls, preset/filter chips, and reset controls.
5. Disabled/future-category badges and reasons.

Rules:

- The debug overlay is a compact read-only surface on the preview, not a new page, not a full-screen modal, and not a geometry drawing layer.
- The JSON sheet is a transient QA utility. It must not replace the parameter panel, add a new top-level category, or create a saved custom-preset feature.
- The preview toolbar should scan as a tool surface: compact labels, stable hit targets, no marketing copy, no decorative cards.
- Disabled future categories remain visible in the existing rails; their badge and reason copy are secondary to implemented controls.

---

## Copywriting Contract

| Element | Copy |
|---------|------|
| Primary CTA | Preview Parameter JSON |
| Import apply CTA | Apply Imported Parameters |
| Export CTA | Copy Parameter JSON |
| JSON sheet title | Parameter JSON |
| Import mode label | Import |
| Export mode label | Export |
| Empty state heading | Paste parameter JSON |
| Empty state body | Paste a schemaVersion 1 payload to preview changes before applying. Current settings stay unchanged. |
| Import preview heading | Review imported parameters |
| Import preview body | Check the decoded parameter snapshot, then apply it to the current preview. |
| Invalid JSON error | Parameter JSON could not be read. Fix the pasted payload and preview again. Current settings stay unchanged. |
| Unsupported schema error | Unsupported parameter JSON version. Export a fresh payload from this build and try again. |
| Unknown filter error | Filter is unavailable in this build. Current settings stay unchanged. |
| Oversized JSON error | Parameter JSON is too large. Paste a smaller parameter payload. |
| Export helper | Copy this deterministic payload for SDK QA or round-trip tests. |
| Debug toggle off | Show Debug Details |
| Debug toggle on | Hide Debug Details |
| Debug empty state | Debug details are unavailable for this preview. |
| Destructive confirmation | No persisted destructive action in Phase 7. `Reset All Parameters` remains an immediate in-memory reset to SDK defaults with an explicit label and no dialog. |

Existing labels that must remain unchanged:

| Element | Copy |
|---------|------|
| Compare after action | Show Before |
| Compare before action | Show After |
| Photo picker | Choose Photo |
| Reset all | Reset All Parameters |
| Single reset | Reset {Control Label} |
| No-filter option | None |
| Built-in preset chips | Natural, Clear, Refined, Male Natural, ID Photo Natural |
| Filter chips | Soft Clean, Warm Light |

Copy rules:

- Normal UI copy must not mention Vision, landmarks, bounding boxes, coordinates, raw framework errors, local paths, stack traces, `NSError`, or image bytes.
- The JSON sheet may show user-pasted or exported parameter JSON because that is the explicit import/export utility. Status banners, error copy, debug overlay, logs, and tests must not dump raw JSON payloads.
- Failed import copy always states that current settings stay unchanged.
- Debug overlay copy may use stable public enum values and redacted reason codes, but must not expose geometry or raw framework strings.

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| shadcn official | none | Not applicable; native SwiftUI phase, no `components.json` found - 2026-06-22 |
| Third-party registries | none | Not applicable; no web registry or third-party UI block allowed - 2026-06-22 |

Rules:

- Phase 7 must not add remote UI packages, web registries, or third-party component blocks.
- New SwiftUI surfaces should be built from local views and value models already present in `BeautyDemo`.

---

## Phase 7 Interaction Contract

### Preview Toolbar

- Add Phase 7 controls near the existing compare button on the preview surface.
- Keep `Show Before` and `Show After` labels and behavior unchanged.
- Add one debug toggle with visible text: `Show Debug Details` when hidden and `Hide Debug Details` when visible.
- Add one JSON utility entry labeled `Parameter JSON`; it opens the JSON sheet through enum-driven sheet state.
- Toolbar actions must not mutate parameters except the explicit `Apply Imported Parameters` action in the import preview state.
- Toolbar visibility follows existing preview behavior: compare/debug are useful only when a camera or photo snapshot exists; JSON remains available when the parameter store exists.

### Parameter JSON Sheet

- Use a single enum-driven sheet state, for example `.parameterJSON`, with internal import/export mode state. Do not use parallel booleans.
- Import and export are copy/paste only. Do not add document pickers, file import/export, sharing sheets, persistence, saved custom presets, or a new presets page.
- Export reads from `BeautyParameterStore.parametersSnapshot` and emits only:
  - `schemaVersion`
  - `parameters`
- Export payload must be deterministic enough for normalized JSON round-trip tests. Do not include timestamps, app/build metadata, preset labels, detection summaries, debug metrics, local paths, or source names.
- Import starts from user-pasted text and decodes into preview state first.
- Import must enforce a documented size limit of 64 KB before decoding.
- Import accepts only supported `schemaVersion` values for this Demo contract; unsupported versions show the schema error copy.
- Import validates decoded parameters through the public `BeautySDKResources.validate(parameters:)` facade before preview or apply.
- Unknown filter IDs fail before preview/apply and leave selected filter, selected preset, slider values, and current parameters unchanged.
- `Apply Imported Parameters` synchronizes all visible display values, filter selection, and parameter snapshot from the validated candidate, clears selected preset state, and marks the parameter source as imported/custom according to the store model.
- Dismissal or switching away from a failed/preview import state does not mutate current parameters.

### Preset, Source, and Reset Semantics

- Preserve current built-in preset chip behavior and labels.
- Single reset always resets that control to SDK zero/default, not the selected preset or imported baseline.
- `Reset All Parameters` always returns to SDK zero defaults, clears selected filter, clears selected preset, and clears imported-source state.
- Applying imported JSON deselects preset chips and does not create an imported preset chip.
- Any manual slider or filter change after a preset or import clears applied-source state and returns the snapshot to custom.
- The UI may show a compact source chip such as `Custom Parameters`, `Preset: Natural`, or `Imported Parameters`, but it is optional and must not add another color system.

### Debug Overlay

- Add one read-only debug overlay view owned by the preview/editor surface.
- The overlay is shared by camera and photo paths.
- Toggle state only changes overlay visibility; it must not mutate SDK output, compare state, parameter state, detection summaries, or processing snapshots.
- Allowed fields:
  - frame status such as camera running, photo loaded, photo loading, photo failed, or processing paused
  - detection availability
  - redacted reason codes
  - face count and used face count
  - detection duration and mapping duration
  - warning count
  - last redacted error code
  - friendly status copy already safe for normal UI
- Forbidden fields:
  - face boxes, landmarks, control points, landmark coordinates, bounding boxes, rectangles, `CGPoint`, `CGRect`, `VNFaceObservation`, Vision request objects, raw `NSError`, raw framework strings, local paths, stack traces, image bytes, thumbnails, or pasted raw JSON.
- The overlay must not cover the primary face area when avoidable; use compact rows and allow scrolling or truncation before overlapping the panel or toolbar.
- When no safe debug summary exists, show `Debug details are unavailable for this preview.`

### Unavailable-State Polish

- Keep the current top-level category order: Beauty, Face Shape, Facial Features, Makeup, Filters, Stickers, Background, Style.
- Keep the current Facial Features subcategory order: Eyes, Nose, Mouth, Eyebrows, Teeth, Hairline.
- Implemented categories stay active; future categories stay disabled and visible with short reason copy.
- Do not hide future categories, add tappable info pages, or imply v1 support for advanced makeup, stickers, background segmentation, style templates, body shaping, AI style, or video export.
- Disabled/future copy must remain shorter and quieter than active panel controls.

---

## Component Inventory

| Component / Model | Phase 7 Contract |
|-------------------|------------------|
| `EditorShellView` | Owns enum-driven JSON sheet presentation, preview toolbar placement, compare/debug visibility, and sheet wiring. |
| `EditorPreviewViewState` | May gain safe debug and JSON affordance fields without exposing SDK internals. |
| `CompareState` | Keeps display-only before/after behavior and labels; debug toggling and JSON sheet presentation must preserve it. |
| `PreviewDebugOverlayState` or equivalent | Pure value model for read-only debug rows, redacted error code, warning count, frame status, and detection summary. |
| `DetectionDebugSummary` | Continues to expose only availability, reason codes, counts, and timings. |
| `ParameterJSONEnvelope` or equivalent | Demo-side schemaVersion plus `BeautyParameters` wrapper for import/export. |
| `ParameterJSONImportState` or equivalent | Idle/editing/preview/failed states; failed states contain friendly copy and no parameter mutation. |
| `BeautyParameterStore` | Owns parameter source semantics, imported apply method, reset/source clearing, selected filter, selected preset, and normalized `BeautyParameters` snapshot. |
| `BeautyPanelView` | Keeps presets, filters, sliders, reset all, disabled-state presentation, and compact panel styling. |
| `InputPipelinePrivacyTests` | Expands privacy/static scans for JSON/debug overlay surfaces. |

Accessibility requirements:

- `Parameter JSON` button accessibility label: `Open Parameter JSON`.
- `Preview Parameter JSON` accessibility hint: `Decodes pasted parameters without changing current settings.`
- `Apply Imported Parameters` accessibility hint: `Applies the validated parameter snapshot to the current preview.`
- `Copy Parameter JSON` accessibility hint: `Copies the current parameter snapshot as deterministic JSON.`
- Debug toggle accessibility value is `Debug details hidden` or `Debug details visible`.
- Debug overlay rows are readable as static text and do not rely on color alone.
- Reset controls keep existing explicit labels and meaningful values.
- Dynamic Type must not overlap toolbar actions, sheet buttons, debug rows, chip text, slider values, or disabled-state reasons; horizontal rows may scroll.

---

## Verification Contract

Planner and executor should preserve the existing deterministic XCTest/view-state style. Simulator screenshot or UI automation is optional and must not become a hard gate unless it is actually run and stable.

Required UI/view-state evidence:

| Contract | Evidence |
|----------|----------|
| JSON export emits only `schemaVersion` plus `parameters` | Focused JSON coding test with normalized payload comparison |
| JSON import previews before applying | Import state test proving decode/preview happens before store mutation |
| Failed import is non-mutating | Store/import test covering invalid JSON, unsupported schema, oversized payload, invalid values, and unknown filter ID |
| Import apply clears preset source and syncs sliders/filter | `BeautyParameterStoreTests` or equivalent |
| Single reset and reset all use SDK zero/default semantics | Store tests for imported, preset, and custom snapshots |
| Compare toggle preserves parameters and debug visibility | `CompareStateTests` or editor view-state test |
| Debug overlay is read-only and redacted | Pure model tests plus static privacy scan for forbidden geometry/raw tokens |
| Disabled/future categories remain visible and ordered | `BeautyDemoViewStateTests` |
| Demo imports only `BeautySDK` | Existing facade-only import scan expanded to new Phase 7 files |
| No network/file import/export scope creep | Static scan for `URLSession`, `http://`, `https://`, upload, document picker, and local-path leakage in Phase 7 surfaces |

Required closeout scans:

```bash
rg -n "import Beauty(Core|Detection|Effects|Render|Resources)" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests
rg -n "VNFaceObservation|boundingBox|landmark|CGPoint|CGRect|NSError|/private/var|rawPresetJson|URLSession|http://|https://|upload" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests
```

Manual release-risk evidence remains separate:

- Visual naturalness review of fixtures or simulator preview.
- Real-device front-camera parity.
- Real Vision behavior on physical devices.
- Long-run hardware, memory, and performance checks.
- Production render-quality claims.

---

## Out of Scope

- Local file import/export, document picker integration, share sheet export, saved custom presets, preset-like imported chips, or persistent parameter libraries.
- New public `BeautyParameters` fields, new beauty domains, advanced makeup, stickers, background segmentation, body shaping, AI style, video export, or per-face UI.
- Geometry overlays, face boxes, landmark points, control points, coordinate labels, or debug drawing on top of faces.
- Raw framework errors, local paths, stack traces, raw Vision/Core Image/Metal objects, image bytes, or raw JSON in logs/status/debug surfaces.
- Release-grade naturalness, real-device front-camera parity, real Vision quality, production render quality, or long-run hardware readiness claims without separate proof.

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS
- [x] Dimension 2 Visuals: PASS
- [x] Dimension 3 Color: PASS
- [x] Dimension 4 Typography: PASS
- [x] Dimension 5 Spacing: PASS
- [x] Dimension 6 Registry Safety: PASS

**Approval:** approved 2026-06-22
