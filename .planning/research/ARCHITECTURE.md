# Architecture Research

**Domain:** Private observed eye geometry through an existing local-first facade
**Researched:** 2026-07-16
**Confidence:** HIGH for boundaries; MEDIUM for private support representation until Phase 41 planning

## Recommended Architecture

```text
BeautyParameters (10 new scalars; default zero)
  -> BeautySDK geometry-required route
  -> VisionFaceDetector
       availability + private frame-scoped eye contours/pupils
  -> BeautyFaceGeometryAdapter
       validated side-aware upper/lower/corner/pupil supports
  -> BeautyEffectResolver
       normalization, caps, freshness, field-local eligibility
  -> EyeWarpProvider
       14 independent emissions (4 shipped + 10 new)
  -> provider-eligible conflict convergence
  -> existing unified local warp
  -> public image + redacted aggregate evidence
```

## Component Responsibilities

| Component | Responsibility | v1.11 change |
| --- | --- | --- |
| `BeautyParameters` | Stable host-facing scalar contract | Add ten defaulted fields across all manual model seams; exact 38-to-48 compatibility. |
| `BeautyDetection` observation | Selected face and landmark evidence | Carry validated package-only normalized eye contour/pupil values for the current request; never public or persisted. |
| `VisionFaceDetector` | Vision request and coordinate conversion | Convert left/right eye and optional pupil points from face-bounds coordinates into the repository image-normalized convention with finite/bounds checks. |
| `BeautyFaceGeometryAdapter` | Package observation to render support | Produce side-aware ordered contours, upper/lower subsets, corners, centers, and optional pupil anchors; no fabricated pupil. |
| `EyeWarpProvider` | Field-specific vectors and eligibility | Expand from aggregate point output to fourteen named field emissions and sanitize each independently. |
| Resolver/conflict pipeline | Effective strengths, warnings, metrics | Remove unsupported work before and after scaling so effective values equal emitted work. |
| Renderer/helper | Public behavior evidence | Add isolated cases, eligibility-aware ROI/direction/independence checks, and ignored artifact containment. |

## Architectural Patterns

### Private Ephemeral Support

Raw Vision points remain package-internal and request-scoped. They may flow from detection to geometry planning but must not appear in public models, errors, logs, metrics, serialized state, or Demo imports. This is a deliberate extension of the availability-only seam because gaze and symmetry cannot be evidenced honestly from symmetric proxies.

### Side-Aware Canonicalization

Vision points use a face-bounding-box coordinate system with a lower-left origin, while repository rendering uses its established image-normalized convention. Convert once, validate once, and canonicalize each eye into semantic upper/lower/inner/outer supports independent of input winding. Tests must cover orientation, left/right identity, and mirrored metadata.

### Field-Local Provider Eligibility

The provider owns named emissions for all fourteen eye fields. Missing pupils remove only `pupilSize` and `gazeCorrection`; malformed paired comparison removes only `eyeSymmetry`; valid contour siblings continue. After conflict scaling, any field whose displacement becomes ineligible is removed from totals, counts, metrics, warnings, and dispatch.

### Correction Rather Than Fabrication

`gazeCorrection` moves a validated pupil offset toward its eye center by a bounded fraction. `eyeSymmetry` moves only measured inter-eye differences toward a conservative midpoint. Neither control emits when measured deviation is absent, ambiguous, or outside plausible bounds.

## Integration Boundaries

| Boundary | Invariant |
| --- | --- |
| Public SDK ↔ detection | Scalar parameters trigger existing detection; no geometry type becomes public. |
| Vision ↔ package observation | Coordinates are finite, normalized, side-aware, ephemeral, and independently optional. |
| Observation ↔ adapter | Observed contours are preferred for new controls; zero-default new fields preserve all shipped proxy behavior. |
| Adapter ↔ provider | Each field declares its exact support prerequisites. |
| Provider ↔ resolver | Provider emissions are the source of eligibility before final evidence. |
| Resolver ↔ public result | Only fixed codes, counts, scales, and aggregate summaries cross the facade. |

## Suggested Build Order

1. Public 48-field compatibility and private support representation.
2. Ten independent provider semantics plus fourteen-field resolver integration.
3. Public-facade renderer/helper/gallery evidence.
4. Exact caps, exhaustive degradation/convergence, security boundary, and promotion.

## Sources

- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, and `RELIABILITY.md` — owning repository boundaries.
- `BeautyFaceObservation.swift`, `VisionFaceDetector.swift`, `BeautyFaceGeometryAdapter.swift`, and `EyeWarpProvider.swift` — current implementation seams.
- [Apple `VNFaceLandmarks2D`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — face-bounds-normalized eye and pupil regions.
- [Apple Vision coordinate overview](https://developer.apple.com/documentation/vision) — normalized Vision coordinate convention.

---
*Architecture research for: Beauty v1.11 Eye Remaining Geometry Controls*
*Researched: 2026-07-16*
