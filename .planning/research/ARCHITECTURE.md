# Architecture Research

**Domain:** Private observed face and semantic-region support through the existing local-first facade
**Researched:** 2026-07-21
**Confidence:** HIGH for package boundaries; MEDIUM for the local semantic resource until Phase 45 proves feasibility

## Recommended Architecture

```text
BeautyParameters (7 new default-zero scalars)
  -> existing BeautySDK geometry-required route
  -> VisionFaceDetector
       observed face contour + median line (mapped once)
       optional local semantic-region request (only when needed)
  -> BeautyFaceGeometryAdapter
       validated canonical contour/centerline/submental/hairline support
  -> BeautyEffectResolver
       caps, freshness, per-field eligibility
  -> named face-field emissions
       FaceShapeWarpProvider: smooth / temple / cheekbone / basic double-chin
       ChinWarpProvider: independent taper
       region refinement: Pro double-chin / signed hairline
  -> provider-eligible conflict convergence
  -> existing unified render/facade output
  -> public image + fixed aggregate diagnostics
```

## Component Responsibilities

| Component | v1.12 responsibility |
| --- | --- |
| `BeautyParameters` | Add seven independent values everywhere the manual 48-field model is constructed, decoded, encoded, normalized, diffed, or reset. |
| `BeautyDetection` observation | Carry optional package-only mapped contour, median line, and semantic-region descriptor for the current request only. |
| `VisionFaceDetector` | Extract and map actual `faceContour`/`medianLine`; invoke semantic support only for nonzero dependent fields and never log raw values. |
| `BeautyFaceGeometryAdapter` | Validate finite bounds, count, winding/order, apex, lateral bands, centerline, mask dimensions/confidence, and cross-support consistency. |
| Face providers | Produce seven named emissions/operations with independent prerequisites and no reuse of existing field IDs. |
| Resolver/conflict loop | Remove unsupported/provider-empty work before final totals, counts, scales, warnings, metrics, and dispatch. |
| Renderer/helper | Prove visibility, locality, direction, independence, basic-vs-refined difference, no-face/no-mask no-op, dimensions, decoding, and ignored-gallery containment. |

## Architectural Invariants

### One Coordinate Conversion Boundary

Vision face landmarks are normalized to the face bounding box. Compose them into image space, then use the existing `CoordinateMapper` exactly once. Reject non-finite, out-of-range, duplicate, undersized, side-inverted, or centerline-inconsistent support before effects see it.

### Private Ephemeral Supports

Contours and masks remain package-only, non-Codable, non-public, non-diagnostic, non-persistent, and request-scoped. Public results expose only fixed availability/reason codes and aggregate counts.

### Region Feasibility Gate

Before downstream phases claim `去双下巴 Pro` or `发际线`, Phase 45 must prove a local support source with license/provenance, bundle hash, supported-platform behavior, bounded memory/output, semantic fixture eligibility, and no network. Failure blocks those rows; it must not be papered over with a face-box proxy.

### Field-Local Degradation

- Missing observed contour removes contour-dependent new rows, not existing zero-default compatibility or face-agnostic effects.
- Missing submental support removes double-chin fields only.
- Missing hair/skin support removes `hairlineHeight` only.
- Reused support is sign-preserving and conservatively scaled; stale support emits no dependent work.
- Provider-empty fields are removed before final combined accounting.

## Suggested Build Order

1. Exact 55-field contract plus observed face/region support feasibility and privacy boundaries.
2. Four independent contour/chin geometry controls and named emissions.
3. Basic/refined double-chin plus signed hairline local-region pipeline.
4. Public-facade output matrix, semantic/locality comparisons, and ignored gallery.
5. Final caps, exhaustive transitions/convergence, active-source/security/resource gate, exact promotion, and branch closeout.

## Sources

- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, and `RELIABILITY.md` — owning repository contracts.
- `BeautyFaceObservation.swift`, `VisionFaceDetector.swift`, `BeautyFaceGeometryAdapter.swift`, `FaceShapeWarpProvider.swift`, and `GeometryConflictResolver.swift` — current integration seams.
- [Apple `VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — face contour, median line, and coordinate convention.
- [Apple Vision](https://developer.apple.com/documentation/vision) — local requests, normalized geometry, and segmentation APIs.
- [Apple `MLComputeUnits`](https://developer.apple.com/documentation/coreml/mlcomputeunits) — local compute selection if an approved model is required.

---
*Architecture research for: Beauty v1.12 Face Shape Remaining Capabilities*
