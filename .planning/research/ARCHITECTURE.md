# Architecture Research

**Domain:** Request-scoped eyebrow support through the existing geometry pipeline
**Researched:** 2026-07-24
**Confidence:** HIGH

## Recommended Architecture

```text
BeautyParameters (7 new default-zero scalars; 59 stored fields)
  -> existing BeautySDK geometry-required route
  -> existing single Vision face-landmarks request
       leftEyebrow + rightEyebrow point copies
  -> request-local CoordinateMapper exactly once
  -> package-only observed eyebrow support
  -> BeautyFaceGeometryAdapter validation/canonicalization
  -> EyebrowWarpProvider (7 named field emissions)
  -> BeautyEffectResolver + provider-eligible conflict convergence
  -> existing unified BeautyGeometryEffectPipeline
  -> public image + fixed aggregate diagnostics
```

## Component Responsibilities

| Component | v1.13 responsibility |
| --- | --- |
| `BeautyParameters` | Add seven normalized values everywhere the manual 52-field model is initialized, decoded, encoded, diffed, reset, and tested. |
| `BeautyDetection` | Carry optional left/right eyebrow traces as package-only request values and record only coarse availability/counts. |
| `VisionFaceDetector` | Read eyebrow regions from the existing selected-face request, preflight point ceilings, and map accepted values once. |
| `BeautyFaceGeometryAdapter` | Canonicalize side/order; validate finite bounds, uniqueness, span, separation, chord, curvature, eye-relative position, and pair consistency. |
| `EyebrowWarpProvider` | Emit seven independently named local transforms without changing shipped eye/face arrays. |
| Resolver/conflict loop | Apply caps/freshness, remove unsupported or provider-empty work, converge over the exact 44-field geometry inventory, and dispatch once. |
| Renderer/helper | Prove 72-case/504-output visibility, locality, direction, distinctions, safe no-ops, and ignored gallery containment. |

## Architectural Invariants

### One Detection and Mapping Boundary

Eyebrow regions come from the same `VNDetectFaceLandmarksRequest` and selected face as existing eye/face support. Accepted point values are composed from face-local Vision coordinates into image space and passed through `CoordinateMapper` exactly once.

### Private Ephemeral Support

Raw eyebrow coordinates remain package-only, non-public, non-SPI, non-Codable, non-persistent, non-cached, non-networked, and absent from warnings/errors/metrics/descriptions/dumps. Only fixed reasons and aggregate counts are permitted.

### Open-Trace Validation

Eyebrows are open traces, not polygons. Validation must preserve adjacency and reject non-finite, out-of-bounds, duplicate-only, undersized, direction-degenerate, side-inverted, eye-crossing, or implausibly paired traces without sorting points or substituting eye contours.

### Field-Local Degradation

- Whole-pair spacing requires two valid brows.
- Single-brow transforms may preserve an eligible side when the other side is invalid.
- Missing or malformed support removes only dependent eyebrow work.
- Reused/stale behavior is explicitly locked before promotion.
- Provider-empty work contributes no effective strength, count, scale, metric, warning, or emitted point.

## Suggested Build Order

1. Exact 59-field compatibility and request-scoped observed eyebrow support.
2. Seven independent providers plus resolver/conflict/facade routing.
3. Thirteen isolated public cases and strict 504-output helper/gallery evidence.
4. Final caps/transitions/44-field convergence, active-source security, owner synchronization, and exact seven-row promotion.

## Sources

- Root `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, and `PRODUCT_SENSE.md`.
- `BeautyFaceObservation.swift`, `VisionFaceDetector.swift`, `BeautyFaceGeometryAdapter.swift`, existing providers/resolver/pipeline.
- Installed `VNFaceLandmarks2D` eyebrow-region API.

---
*Architecture research for: Beauty v1.13 Eyebrow Geometry Controls*
