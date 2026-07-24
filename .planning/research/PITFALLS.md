# Pitfalls Research

**Domain:** Adding eyebrow geometry to a mature local-first face pipeline
**Researched:** 2026-07-24
**Confidence:** HIGH

## Critical Pitfalls

### 1. Eye contours masquerade as eyebrow evidence

**Failure:** New controls move regions inferred from eyes because eyebrow traces were not captured.
**Prevention:** Require actual left/right Vision eyebrow support and fail closed when absent.
**Phase:** 49.

### 2. Vision side/order flips under orientation or mirroring

**Failure:** Inner/outer endpoints, spacing direction, tilt sign, or peak location reverse.
**Prevention:** Use the existing mapper metadata, canonical side/order, translated-face fixtures, and direct signed output comparisons.
**Phases:** 49, 51, 52.

### 3. `间距` and `眉头间距` alias

**Failure:** Both fields move identical points.
**Prevention:** Whole-brow translation versus inner-endpoint-local deformation with fixed outer-endpoint assertions.
**Phases:** 50-51.

### 4. Thickness silently becomes makeup

**Failure:** Color overlays, generated hair, style assets, or texture synthesis enter a geometry milestone.
**Prevention:** Define bounded trace-normal expansion/compression over a protected local strip and scan out resource/makeup paths.
**Phases:** 49-52.

### 5. Brow warps alter eyes, forehead, hair, or watermark

**Failure:** Large influence radii produce visible changes outside brow-local regions.
**Prevention:** Fixed protected-region locality checks, bounded radii, direction-aware comparisons, and exact outside-region floors.
**Phases:** 50-52.

### 6. Partial support disables unrelated work

**Failure:** One invalid brow zeros both brows, eye geometry, or face-agnostic effects.
**Prevention:** Encode per-side eligibility; require pairs only for paired fields; preserve safe siblings/domains.
**Phases:** 49-52.

### 7. Combined accounting retains empty providers

**Failure:** Effective strengths or metrics claim eyebrow work that emits no points after validation/scaling.
**Prevention:** Named emissions, post-scale sanitization, exact 44-field monotone convergence, and final emission/dispatch agreement.
**Phases:** 50, 52.

### 8. Public or diagnostic geometry leakage

**Failure:** New support names, coordinates, framework objects, bounds, or arrays enter Codable/public/debug surfaces.
**Prevention:** Public/SPI, reflection, description, persistence, network, path, and raw-coordinate fail-closed scans.
**Phases:** all.

## “Looks Done But Isn’t” Checklist

- [ ] Exact 59-field public model and legacy 52-field neutrality pass.
- [ ] Actual left/right Vision eyebrow traces are mapped once.
- [ ] Seven controls own distinct named behavior and prerequisites.
- [ ] Six signed controls preserve both directions; peak remains independent.
- [ ] Missing/malformed/reused/stale/provider-empty behavior is field-local.
- [ ] Exact 72-case/504-output matrix is decoded, visible, local, and bijective.
- [ ] Final 44-field totals/counts/scales equal emitted and dispatched work.
- [ ] Raw support and generated images remain private and untracked.
- [ ] Exactly seven rows and branch-level `眉毛` are promoted.

## Sources

- Installed Vision eyebrow-region declarations.
- Existing eye/face support review fixes and convergence evidence.
- Root privacy, reliability, geometry, and ledger contracts.

---
*Pitfalls research for: Beauty v1.13 Eyebrow Geometry Controls*
