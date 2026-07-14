# Architecture Research

**Domain:** Mouth geometry expansion inside the existing modular iOS SDK
**Researched:** 2026-07-14
**Confidence:** HIGH

## Recommended Architecture

```text
BeautyCore
  BeautyParameters (+5 defaulted fields)
        ↓
BeautyDetection
  outerLips + innerLips availability (package-only)
        ↓
BeautyEffects Planning
  BeautyFaceGeometryAdapter
    whole-mouth outer support
    explicit upper/lower + inner-lip support
        ↓
  BeautyEffectResolver / BeautyEffectiveStrengths / BeautySafetyCaps
        ↓
BeautyEffects Warp
  MouthWarpProvider field emissions (+5 independent fields)
  GeometryConflictResolver + bounded provider-eligible convergence
        ↓
BeautyRender unified warp
        ↓
BeautySDK facade output
        ↓
BeautyExampleRenderer + strict helper + ignored gallery
```

## Component Responsibilities

| Component | New responsibility | Must not own |
| --- | --- | --- |
| `BeautyParameters` | Store/normalize/code five public values compatibly | Caps, landmarks, product labels |
| `BeautyDetection` | Report `innerLips` availability beside existing `outerLips` | Public/raw coordinate exposure |
| `BeautyFaceGeometryAdapter` | Construct validated package-internal whole/upper/lower lip supports | Product field semantics or diagnostics |
| `MouthWarpProvider` | Emit and sanitize each of eight mouth geometry fields independently | Global conflict policy or color effects |
| `BeautyEffectResolver` | Cap, degrade, route, redact, and preserve eligible siblings | Fabricating missing supports |
| `GeometryConflictResolver` | Include every retained geometry field exactly once | Counting provider-empty work |
| Facade/renderer/helper | Prove observable output and compatibility boundaries | Direct internal target imports |

## Support Model

### Whole-Mouth Transforms

`mouthYPosition`, `mouthTilt`, and `mouthXPosition` require a valid outer-lip ring and center. They transform the whole mouth and can remain eligible when `innerLips` is absent.

### Local Lip Shape

`lipPeakDefinition` and `lipPlump` require explicit upper/lower supports plus an inner-lip opening. The adapter should derive these supports only from the presence of both Vision outer- and inner-lip groups. If any required support is missing, malformed, non-finite, duplicate-only, or displacement-ineligible, only the dependent field becomes zero.

The package currently stores group availability and synthesizes normalized support geometry from the face bounds. v1.10 should follow that established seam rather than introducing raw landmark arrays into public models or diagnostics.

## Public Data Contract

```swift
public var mouthYPosition: Float       // signed
public var mouthTilt: Float            // signed
public var mouthXPosition: Float       // signed
public var lipPeakDefinition: Float    // positive-only
public var lipPlump: Float             // positive-only
```

- All initializer arguments default to zero.
- Missing JSON keys decode to zero; existing preset files remain unchanged.
- Existing fields and meanings remain stable.
- Stored inventory changes atomically from 33 to 38 fields.

## Provider Emission Contract

Extend `MouthWarpFieldEmissions` from three to eight named arrays. Its `sanitizing` operation is the one per-field truth source for preflight and final scaled eligibility. The resolver must not infer support from an aggregate non-empty point list.

Suggested geometry semantics:

- `mouthYPosition`: translate eligible outer/upper/lower points on Y while preserving sign.
- `mouthXPosition`: translate eligible points on X while preserving sign.
- `mouthTilt`: rotate eligible points about mouth center; positive/negative directions remain distinct.
- `lipPeakDefinition`: raise the two upper-lip peaks relative to the upper center without moving the whole mouth.
- `lipPlump`: move upper and lower outer/inner supports apart locally without applying `lipColor` or whole-mouth scaling.

Exact displacement constants and final caps remain provisional until output evidence is collected.

## Conflict and Degradation Flow

1. Normalize and cap every field.
2. Apply freshness policy: reused mouth geometry scales by exact `0.5`; stale geometry becomes zero; lip color remains its independent color-domain policy.
3. Preflight all eight mouth geometry fields through provider-owned emissions.
4. Compute combined geometry total from the retained baseline.
5. Apply weakening.
6. Recheck final emissions; remove any threshold-crossing field and recompute until stable.
7. Record active/skipped domains, warning, count, scale, and dispatch from the same converged set.

The existing loop bound of nine nose/mouth fields must be updated to the exact combined retained field count: six nose plus eight mouth fields, so at most fourteen monotonic mask changes.

## Phase Ordering

1. **Phase 38 — Public Contract and Lip-Support Geometry:** compatibility, explicit supports, field emissions, resolver/facade integration.
2. **Phase 39 — Public-Facade Output Evidence:** eight cases, 308 derived outputs, ROI/direction/distinction checks, ignored gallery.
3. **Phase 40 — Mouth Geometry Safety and Ledger Closeout:** final caps, exhaustive support/freshness/conflict behavior, fail-closed boundaries, exact five-row promotion.

## Anti-Patterns

- Do not alias M-lip/plump to existing size or color fields.
- Do not make `innerLips` part of all mouth eligibility; whole-mouth transforms need only outer support.
- Do not add a new package or Metal pass per field.
- Do not expose or log raw support points.
- Do not promote branch-level `嘴唇` while `白牙` remains unresolved.

## Sources

- Current package architecture and source files named above.
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`.
- v1.8 mouth and v1.9 independent-geometry milestone archives.
- Apple Vision face landmarks: https://developer.apple.com/documentation/vision/vnfacelandmarks2d

---
*Architecture research for: v1.10 Mouth Remaining Geometry Controls*
*Researched: 2026-07-14*
