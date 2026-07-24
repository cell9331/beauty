# Feature Research

**Domain:** Exact seven-row SDK-core `眉毛` branch
**Researched:** 2026-07-24
**Confidence:** HIGH

## Feature Scope

| Ledger row | Product-neutral semantic | Direction | Required support | Independent behavior |
| --- | --- | --- | --- | --- |
| `上下` | `eyebrowYPosition` | signed | Valid brow trace | Translate each complete brow vertically without moving eyes. |
| `粗细` | `eyebrowThickness` | signed | Valid brow trace and protected local strip | Expand/compress across local trace normals without makeup synthesis. |
| `长短` | `eyebrowLength` | signed | Ordered endpoints | Extend/contract outer endpoint neighborhoods without whole-brow scaling. |
| `间距` | `eyebrowSpacing` | signed | Valid paired traces | Translate both complete brows symmetrically around the face center. |
| `眉头间距` | `eyebrowHeadSpacing` | signed | Canonical inner endpoints | Move only inner endpoint neighborhoods; preserve outer endpoints. |
| `倾斜` | `eyebrowTilt` | signed | Valid trace centers and direction | Rotate locally around each center; preserve sign under mirror/orientation. |
| `眉峰` | `eyebrowPeakDefinition` | positive-only | Ordered trace with an interior apex candidate | Raise/define a bounded interior peak without translating the whole brow. |

## Table Stakes

- Seven independent public fields with zero-default source/JSON/preset compatibility.
- Actual left/right Vision eyebrow traces mapped exactly once and validated independently.
- No borrowing from eye contours, synthetic face boxes, makeup resources, or existing eye/face parameters.
- Field-local eligibility: single-brow tools may preserve an eligible sibling; paired spacing requires both valid brows.
- Provider-empty work is removed before final totals, counts, metrics, warnings, and dispatch.
- Isolated public-facade evidence covers both directions for six signed controls and one positive peak case.
- Exact caps, dead zones, no-face/missing/malformed/reused/stale transitions, combined weakening, privacy, and artifact gates.

## Output Inventory

The intended strict evidence matrix adds thirteen isolated cases to the current 59-case renderer:

- 12 cases for positive/negative directions of the six signed controls;
- 1 case for positive eyebrow peak definition.

The resulting target is 72 cases across the established seven fixtures, or 504 decoded same-dimension outputs. The helper must prove brow-local visibility, protected eye/forehead locality, direction, family distinctions, ineligible safe no-ops, and exact renderer/output/gallery inventory agreement.

## Completion Definition

The branch becomes `implemented` only when all seven rows independently pass public compatibility, observed support, provider/pipeline routing, decoded output, safety/degradation, privacy/security, and exact ledger promotion. No Demo UI, makeup, device parity, commercial visual approval, packaging, shipping, or launch readiness is implied.

## Explicit Exclusions

- SwiftUI/Demo controls or screenshots.
- Eyebrow makeup, hair generation, texture synthesis, style assets, templates, or color selection.
- `3D塑颜`, `比例`, eye retouch, teeth, hairline, or double-chin work.
- Network/cloud processing, remote model download, account, entitlement, or payment behavior.

## Sources

- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — authoritative seven-row taxonomy.
- `docs/meitu-function-blueprint/features/beauty-shaping/eyebrows/README.md` — current future boundary.
- Installed Vision eyebrow-region declarations and existing repository geometry patterns.

---
*Feature research for: Beauty v1.13 Eyebrow Geometry Controls*
