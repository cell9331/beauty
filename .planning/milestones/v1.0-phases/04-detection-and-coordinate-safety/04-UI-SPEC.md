---
phase: 4
slug: detection-and-coordinate-safety
status: approved
shadcn_initialized: false
preset: none
created: 2026-06-18
reviewed_at: 2026-06-18T10:32:34+08:00
---

# Phase 4 - UI Design Contract

> Visual and interaction contract for Phase 4 Demo changes. This phase adds status rows and debug-safe detection summaries only; overlay boxes, landmark points, and final QA debug surfaces remain Phase 7 scope.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | Native SwiftUI manual design system |
| Preset | not applicable |
| Component library | SwiftUI built-ins plus existing Demo views |
| Icon library | SF Symbols only where an existing control already uses an icon |
| Font | iOS system font |

Source: existing `EditorShellView`, `BeautyPanelView`, `BeautyModeEntryView`, `BeautyCategoryRailView`, and Phase 4 context decisions.

---

## Spacing Scale

Declared values (must be multiples of 4):

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon gaps, compact inline badges |
| sm | 8px | Rail item gaps, text stack gaps |
| md | 16px | Default view padding, preview message spacing, photo image padding |
| lg | 24px | Message horizontal inset and grouped content spacing |
| xl | 32px | Reserved for larger section separation if status rows need isolation |
| 2xl | 48px | Reserved for major preview-to-panel separation only |
| 3xl | 64px | Reserved for page-level spacing only |

Exceptions: none. Minimum hit targets follow iOS accessibility sizing rules and are not spacing tokens.

---

## Typography

Use exactly four sizes and two weights.

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Label / status | 13px | regular 400 or semibold 600 | 1.5 |
| Body | 16px | regular 400 | 1.5 |
| Heading | 20px | semibold 600 | 1.2 |
| Display | 28px | semibold 600 | 1.2 |

Usage rules:
- Detection status banners use 13px semibold.
- Debug summary rows use 13px regular for values and 13px semibold for labels.
- No Phase 4 detection state may introduce another text size or weight.

---

## Color

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | `#F7F8FA` | App background and quiet empty surfaces |
| Secondary (30%) | `#FFFFFF` | Preview card, parameter panel, floating status capsule |
| Accent (10%) | `#2F6BFF` | Selected Camera/Photo mode, selected category/subcategory, primary CTA, small status dot, focus/tint for enabled debug toggle |
| Destructive | `#D92D20` | Destructive actions only; Phase 4 declares no destructive action |
| Disabled neutral | `#EEF0F3` | Disabled mode/category surfaces |
| Accent wash | `#EEF3FF` | Informational badges and existing portrait glyph wash |
| Status text | `#202F4D` | Status banner text over white capsule |

Accent reserved for: selected mode, selected category/subcategory, primary CTA, status dot, and enabled debug toggle/focus state. Do not use accent for every interactive element.

---

## Visual Hierarchy

Primary screen focal point: the existing preview surface remains the dominant visual anchor.

Hierarchy:
1. Preview content or empty-state message.
2. Non-blocking detection status capsule at the bottom of the preview.
3. Parameter panel and category rails.
4. Debug summary rows only when debug mode is enabled.

Phase 4 status placement:
- Camera status appears in the existing bottom preview capsule area, next to the compare control when present.
- Photo status appears in the same preview capsule area and persists with the current processed result.
- Normal detection status must not cover faces, sliders, category rails, or the photo picker CTA.
- No modal, sheet, overlay box, landmark point, coordinate text, or full-screen warning is added in Phase 4.

Accessibility:
- Icon-only detection controls are not allowed in Phase 4.
- Any debug toggle must have a visible text label and an accessibility label.
- Status text must be readable as static text and must not rely on color alone.

---

## Interaction Contract

Normal mode:
- No-face, partial-face, low-confidence, stale, disabled, and not-run states keep the current visual output visible.
- Sliders remain enabled. Detection state explains whether face-dependent effects are paused, weakened, skipped, or waiting.
- Detection metadata unavailable states stay quiet in normal UI unless there is a user-actionable condition.
- Camera status changes are debounced or briefly held to avoid per-frame flicker.
- Photo status belongs to the processed snapshot and remains until the image is changed or reprocessed.

Debug mode:
- Debug UI may show `DetectionAvailability`, reason codes, `faceCount`, `usedFaceCount`, `detectionDurationMs`, and `mappingDurationMs`.
- Debug UI must not show landmark coordinates, bounding boxes, raw Vision objects, raw framework errors, file paths, or image identifiers.
- Debug rows use the existing white panel or compact row treatment; no new QA overlay surface is introduced.

---

## Copywriting Contract

| Element | Copy |
|---------|------|
| Primary CTA | Choose Photo |
| Camera permission CTA | Open Settings |
| Camera retry CTA | Try Again |
| Empty state heading | Choose Camera or Photo |
| Empty state body | Use Camera for live preview, or Photo to process a local image on this device. |
| Photo empty heading | Choose a photo |
| Photo empty body | Select an image to process locally through BeautySDK. |
| Loading state | Processing photo... |
| Processing failure | Processing paused. Showing the last usable preview. |
| Photo decode error | Could not read that photo. Choose another image. |
| No-face status | No face detected. Face adjustments are paused. |
| Partial-face status | Face partly visible. Some face adjustments are softened. |
| Low-confidence status | Face detection is uncertain. Face adjustments are softened. |
| Stale detection status | Waiting for a fresh face reading. Showing the last usable preview. |
| Detection disabled debug label | Detection disabled by configuration. |
| Detection not-run debug label | Detection not run for this result. |
| Detection unavailable debug label | Detection metadata unavailable for this result. |
| Error state | Live preview cannot start on this device. Use Photo mode to continue testing the SDK path. |
| Destructive confirmation | none - Phase 4 adds no destructive action |

Copy rules:
- Normal UI copy stays state-based and non-technical.
- Normal UI must not mention Vision, landmarks, bounding boxes, coordinates, raw error types, file paths, or framework names.
- Debug copy may use stable public enum names but not raw framework details.

---

## Component Inventory

| Component / Model | Phase 4 Contract |
|-------------------|------------------|
| `EditorPreviewViewState` | May gain detection status fields or consume a presentation model; must keep existing Camera/Photo mode states. |
| Preview status capsule | Reuse existing `cameraStatusBanner` visual treatment for Camera and Photo detection statuses. |
| `CameraProcessingState` | Carries debounced or held detection presentation without replacing last usable snapshot behavior. |
| `PhotoProcessingState` | Carries detection presentation with the loaded/failed snapshot until reprocess or image change. |
| `DetectionStatusPresentation` | Pure value model for normal UI status text and visibility. |
| `DetectionDebugSummary` | Pure value model for privacy-safe debug rows: availability, reasons, counts, and timings only. |
| `BeautyPanelView` | Sliders stay enabled during detection degradation; status row may remain parameter-focused. |

---

## State Matrix

| Detection State | Normal UI | Debug UI | Slider Behavior |
|-----------------|-----------|----------|-----------------|
| `usable` | No extra status unless replacing an older degraded state | availability, counts, timings | Enabled |
| `noFace` | `No face detected. Face adjustments are paused.` | availability, `noFaceDetected`, counts, timings | Enabled |
| `partial` | `Face partly visible. Some face adjustments are softened.` | availability, coarse missing reason codes, counts, timings | Enabled |
| `lowConfidence` | `Face detection is uncertain. Face adjustments are softened.` | availability, `lowConfidenceFace`, counts, timings | Enabled |
| `stale` | `Waiting for a fresh face reading. Showing the last usable preview.` | availability, `staleDetection`, counts, timings | Enabled |
| `disabled` | Quiet unless user enables debug | `Detection disabled by configuration.` | Enabled |
| `notRun` | Quiet unless user enables debug | `Detection not run for this result.` | Enabled |
| metadata unavailable | Quiet in normal UI | `Detection metadata unavailable for this result.` | Enabled |

---

## Registry Safety

No web component registry is used in this SwiftUI phase.

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| none | none | not applicable - native SwiftUI only; no third-party registry blocks |

---

## Out of Scope

- Drawing face boxes, landmark points, or coordinate overlays.
- Adding final QA debug overlay surfaces.
- Adding multi-face controls, face selection UI, or per-face parameter controls.
- Changing category structure, slider inventory, or visual effect quality.
- Showing raw Vision payloads, landmark coordinates, bounding boxes, raw framework errors, image paths, or source IDs.

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS
- [x] Dimension 2 Visuals: PASS
- [x] Dimension 3 Color: PASS
- [x] Dimension 4 Typography: PASS
- [x] Dimension 5 Spacing: PASS
- [x] Dimension 6 Registry Safety: PASS

**Approval:** approved 2026-06-18
