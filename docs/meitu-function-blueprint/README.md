# Meitu Core Beauty Module Plan

**Milestone:** v1.3 Meitu Core Beauty Module Design and Implementation
**Created:** 2026-06-26
**Purpose:** Reference the Meitu Xiuxiu beauty editor, clarify core beauty module boundaries, and guide SDK-level design, encapsulation, implementation, and image-output verification.

This directory is the local planning and verification contract for SDK core beauty work. It intentionally excludes new SwiftUI screens.

Phase 17 status labels are branch-level only. The allowed values are:

| Status | Meaning |
| --- | --- |
| `implemented` | Current SDK/Demo behavior exists and has appropriate tests plus facade-visible example output when the branch has visible image output. |
| `partial` | Current public parameters, provider logic, resolver behavior, or unit evidence exists, but the branch is not complete enough for a visible end-to-end claim. |
| `blocked-by-geometry-output` | The branch is promoted enough to describe, but visible saved-image completion is blocked by missing public facade detection plus geometry render integration. |
| `future` | Out of current implementation scope; no v1.3 behavior claim. |

## Reading Order

1. `MINDMAP.md` - Full feature tree and Mermaid mind map.
2. `FEATURE_MATRIX.md` - Feature inventory, status, and implementation priority.
3. `EXAMPLE_IMAGE_VALIDATION.md` - How to run real example images through SDK module logic and save outputs.
4. `MODULES.md` - SDK/Demo module ownership and dependency boundaries.
5. `DELIVERY_BOUNDARY.md` - What this milestone includes and excludes.
6. Feature folders under `features/` - One large function family per folder.
7. Branch folders under each feature family - One branch capability per folder.

## Feature Families

| Folder | Function family | Scope |
| --- | --- | --- |
| `features/editor-shell/` | Minimal beauty editor shell | Input routing, preview chrome, bottom panel, cancel/confirm semantics needed by core beauty tools. |
| `features/beauty-shaping/` | Face and facial-feature shaping | 3D sculpt, proportion, face shape, eyes, lips, nose, eyebrows. |
| `features/skin-retouch/` | Skin and retouch | Smoothing, whitening, rosy, repair, teeth/hairline extensions. |

## Canonical Inputs

- `meituxiuxiu/FUNCTION_MAP.md` - Editor `美型 / 五官` taxonomy from screenshots.
- `ARCHITECTURE.md` - SDK package boundaries and dependency direction.
- `DESIGN.md` - Parameter model, detection/render/effect state contracts.
- `FRONTEND.md` - SwiftUI Demo ownership and UI state rules.
- `SECURITY.md` - Privacy, validation, resource trust, and redaction.
- `RELIABILITY.md` - Error/degradation/metrics/performance rules.
- `PRODUCT_SENSE.md` - User journeys and acceptance criteria.

## Document Rules

- Every large function family gets one folder.
- The active family set is exactly `editor-shell`, `beauty-shaping`, and `skin-retouch`.
- Branch docs must state business logic, core technical logic, primary owner, dependencies, boundaries, current public `BeautyParameters` coverage, future parameter needs, and acceptance signals.
- Unsupported core beauty capabilities are documented as future branches, not fake current behavior.
- Implementation phases must be derived from this module plan and verified through code-level tests plus example-image output where the current module can produce visible output.

## Excluded From This Milestone

The following families are intentionally not documented in this milestone:

- Home/discovery surfaces.
- Resource/style systems such as filters, makeup, stickers, templates, dynamic downloads, and style packs.
- AI/background systems such as AI retouch, background segmentation, cutout, and eraser.
- Video/body pipelines such as video beauty, body shaping, and export.
- Gallery/account surfaces, including gallery management, account state, search, VIP, payment, and entitlement behavior.
