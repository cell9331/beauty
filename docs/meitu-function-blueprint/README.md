# Meitu Core Beauty Module Plan

> Historical blueprint reference. Current effect status and scope are owned by [SDK_EFFECT_TAXONOMY.md](../SDK_EFFECT_TAXONOMY.md). `去脂` is suspended and is not a pending completion requirement. Dated phase outcomes below retain their original scope; this page does not authorize new R&D.

**Milestone:** v1.3 Meitu Core Beauty Module Design and Implementation
**Created:** 2026-06-26
**Original purpose:** Record the v1.3 reference grouping, design and image-output verification approach.

This directory preserves the old reference taxonomy and milestone design history. Current plans, implementation contracts and qualification decisions are owned by `PLANS.md` and the current root owners; this directory is not an executable backlog.

The following branch-level labels describe the historical Phase 17 vocabulary:

| Status | Meaning |
| --- | --- |
| `implemented` | Current SDK/Demo behavior exists and has appropriate tests plus facade-visible example output when the branch has visible image output. |
| `partial` | Current public parameters, provider logic, resolver behavior, or unit evidence exists, but the branch is not complete enough for a visible end-to-end claim. |
| `blocked-by-geometry-output` | The branch is promoted enough to describe, but visible saved-image completion is blocked by missing public facade detection plus geometry render integration. |
| `future` | Out of current implementation scope; no v1.3 behavior claim. |

## Historical Reading Order

1. `MINDMAP.md` - Full feature tree and Mermaid mind map.
2. `SHAPE_FEATURE_LEDGER.md` - 1:1 de-duplicated `美型 / 五官` first-level and second-level SDK-core status ledger.
3. `FEATURE_MATRIX.md` - Branch-level feature inventory, status, and implementation priority.
4. `EXAMPLE_IMAGE_VALIDATION.md` - How to run authorized generated or genuine example images through SDK module logic and save outputs.
5. `MODULES.md` - SDK/Demo module ownership and dependency boundaries.
6. `DELIVERY_BOUNDARY.md` - What this milestone includes and excludes.
7. Feature folders under `features/` - One large function family per folder.
8. Branch folders under each feature family - One branch capability per folder.

## Feature Families

| Folder | Function family | Scope |
| --- | --- | --- |
| `features/editor-shell/` | Minimal beauty editor shell | Input routing, preview chrome, bottom panel, cancel/confirm semantics needed by core beauty tools. |
| `features/beauty-shaping/` | Face and facial-feature shaping | 3D sculpt, proportion, face shape, eyes, lips, nose, eyebrows. |
| `features/skin-retouch/` | Skin and retouch | Smoothing, whitening, rosy, repair, teeth/hairline extensions. |

## Original Inputs

- `meituxiuxiu/FUNCTION_MAP.md` - Editor `美型 / 五官` taxonomy from screenshots.
- `ARCHITECTURE.md` - SDK package boundaries and dependency direction.
- `DESIGN.md` - Parameter model, detection/render/effect state contracts.
- `FRONTEND.md` - SwiftUI Demo ownership and UI state rules.
- `SECURITY.md` - Privacy, validation, resource trust, and redaction.
- `RELIABILITY.md` - Error/degradation/metrics/performance rules.
- `PRODUCT_SENSE.md` - User journeys and acceptance criteria.

## Current Use of This Blueprint

- Folders preserve the historical `editor-shell`, `beauty-shaping` and `skin-retouch` reference grouping. They do not add application or UI scope to the SDK-only repository.
- `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md` and branch pages are background material. Current per-effect status comes from the taxonomy; current work comes from [PLANS.md](../../PLANS.md).
- An unsupported or suspended reference tool is not an automatic future milestone. Historical implementation instructions and acceptance recipes must not override the current [image-effect acceptance policy](../IMAGE_EFFECT_ACCEPTANCE.md).

## Excluded From This Milestone

The following families are intentionally not documented in this milestone:

- Home/discovery surfaces.
- Resource/style systems such as filters, makeup, stickers, templates, dynamic downloads, and style packs.
- AI/background systems such as AI retouch, background segmentation, cutout, and eraser.
- Video/body pipelines such as video beauty, body shaping, and export.
- Gallery/account surfaces, including gallery management, account state, search, VIP, payment, and entitlement behavior.
