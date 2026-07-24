# Phase 46: Independent Contour and Chin Geometry - Context

**Gathered:** 2026-07-23
**Status:** Ready for planning
**Mode:** Auto-resolved by `$gsd-autonomous --auto`

<domain>
## Phase Boundary

Implement four distinct provider-level face geometry behaviors on top of Phase 45's validated package-only `BeautyFaceSemanticSupport`, and route them through the existing detection, resolver, conflict, unified warp, and public-facade processing path. This phase owns provisional caps, named field emissions, field-local eligibility, provider-empty sanitization, representative degradation, and provider/resolver/integration evidence. Phase 47 owns decoded public-facade output and ignored-gallery evidence. Phase 48 owns final cap calibration, exhaustive transition/convergence proof, active-source closeout, and exact four-row promotion.

</domain>

<decisions>
## Implementation Decisions

### Geometry Semantics and Locality

- `faceContourSmooth` is a contour-only local continuity transform: move eligible interior contour points conservatively toward their immediate-neighbor chord while preserving endpoints, overall center, and gross face scale. It must not reuse whole-face `faceSmall` shrinkage or modify the five shipped face-field vectors.
- `templeFullness` is a contour-only upper-lateral transform: select symmetric upper-side contour support and move it outward from the face centerline with local falloff. It must not move the full contour or borrow cheek/jaw sources.
- `cheekboneSlim` is a contour-only mid-lateral transform: select symmetric middle-side contour support and move it inward toward the face centerline with local falloff. Its sources and vertical band must remain distinct from `templeFullness`, shipped `faceSlim`, `faceSmall`, and `jawSlim`.
- `chinTaper` requires complete contour-plus-centerline eligibility and the validated semantic apex. Move only contour points adjacent to the apex inward toward the median axis, keep the apex vertical position unchanged, and never reuse signed `chinLength`, `faceVShape`, or the synthetic seven-point proxy.
- All source/target/radius/falloff values must be finite, unit-bounded, conservative, and expressed in the repository's image-normalized coordinate system. Exact displacement constants are provisional Phase 46 implementation choices, not final naturalness evidence.

### Provider Emissions and Eligibility

- Extend the existing face/chin providers with one independently addressable named emission per shipped and new face field, following the established eye/nose/mouth field-emission pattern. Do not hide the four additions behind one aggregate face array.
- The three contour-only fields require `observedFaceSupport.contourEligible`; `chinTaper` additionally requires `centerlineEligible`, a valid median line, and a valid apex index. Explicit malformed or incomplete observed support never falls back to the synthetic compatibility contour.
- The five shipped face fields keep their current seven-point compatibility behavior and vectors. New support and emissions are attached beside those paths and cannot alter them at zero or when ineligible.
- A requested field whose own provider emission is empty must be zeroed before active-domain membership, conflict totals, weakened counts, warnings, metrics, geometry-point counts, or dispatch. Eligible new and shipped siblings continue independently.
- Add conservative provisional caps for the four new effective strengths in Phase 46 and mark them as provisional. Phase 48 remains the authority for final evidence-backed caps and dead-zone policy.

### Resolver, Conflict, and Facade Routing

- Add all four fields to `requiresFaceGeometry`, `BeautyEffectiveStrengths`, cap application, requested/reusable face-work checks, freshness handling, zero/scale helpers, face-domain activation, and unified pipeline dispatch without adding a new public API or render pass.
- Preflight face/chin field emissions before conflict accounting, then re-evaluate all provider emissions from one retained baseline after combined weakening. The mask-and-recompute loop must remain monotone and bounded: fields can only be removed, never revived.
- Provider-empty work contributes zero times to final strength, total, count, scale, weakened count, active-domain evidence, geometry point count, warnings, metrics, and emitted control points.
- Preserve established freshness behavior: no face and stale geometry disable the four new fields; reused geometry applies the existing exact non-eye reuse scale only when the required observed support remains eligible. Missing contour or centerline degrades only dependent new fields while shipped and face-agnostic domains continue.
- Keep diagnostics aggregate and redacted. Do not expose field-specific contour indices, point counts beyond existing approved aggregates, coordinates, bounds, displacements, or support-derived measurements through warnings, metrics, descriptions, or facade results.

### Testing and Evidence

- Add deterministic asymmetric observed-contour fixtures that make upper temple, middle cheekbone, local continuity, and apex-adjacent taper sources distinguishable. Symmetric aggregate point-count assertions alone are insufficient.
- For each field, assert named emission ownership, non-empty valid output, exact source subset, direction/locality, finite bounded control points, zero neutrality, nearest shipped-field distinction, and unchanged existing face/chin emissions.
- Add representative contour-only, missing contour, missing centerline, malformed, no-face, stale, reused, provider-empty, and valid-sibling cases. Exact exhaustive nine-field transitions and the final thirty-seven-field convergence ledger remain Phase 48.
- Verify isolated public requests enter detection and the existing facade/unified-warp route, but defer decoded image comparisons, ROI thresholds, renderer case matrices, and gallery generation to Phase 47.
- Run focused provider, resolver, conflict, pipeline, degradation, and facade tests plus the full SwiftPM suite and diff hygiene. Do not claim visual naturalness, final caps, product-row promotion, Demo behavior, or release readiness.

### Privacy, Scope, and Ownership

- Preserve Phase 45's package-only, non-Codable, request-scoped observed support and aggregate-only reflection/description contract.
- Add no dependency, target, semantic model/resource, network/cloud path, new render pass, facade method, public geometry/result type, Demo import, tracked generated image, or commercial path.
- Keep `去双下巴`, `去双下巴 Pro`, `发际线`, branch-level `脸型` completion, device parity, commercial approval, performance certification, packaging, shipping, and launch readiness outside this phase.

### the agent's Discretion

- Choose private emission/helper type names, contour band/index selection rules, provisional cap values, radii, falloff, and displacement constants where the codebase has no locked value.
- A small shared face/chin provider refactor is allowed when it preserves byte-for-byte zero behavior and exact shipped vectors in tests.
- Select the narrowest representative degradation and combined-conflict fixtures needed for Phase 46, leaving exhaustive matrices and final constants to Phase 48.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautyFaceSemanticSupport` already provides validated `contour`, optional `medianLine`, semantic `apexIndex`, `contourEligible`, and `centerlineEligible` on `FaceGeometry`.
- `FaceShapeWarpProvider` owns shipped face-slim/small/V/jaw vectors; `ChinWarpProvider` owns signed chin length; `BeautyGeometryEffectPipeline` already concatenates both providers into the unified local warp.
- `EyeWarpFieldEmissions`, `NoseWarpFieldEmissions`, and `MouthWarpFieldEmissions` provide the established named-array plus `sanitizing(_:)` pattern.
- `BeautyEffectResolver`, `GeometryConflictResolver`, `BeautyEffectiveStrengths`, and `BeautySafetyCaps` centralize routing, caps, freshness, conflict accounting, warnings, metrics, and provider dispatch.

### Established Patterns

- Normalize and cap first, apply freshness policy, sanitize provider emissions before totals, converge from one retained baseline, then compute domain/metric/point accounting.
- Explicit malformed observed support fails closed; compatibility fallback is allowed only for shipped controls whose legacy support was intentionally preserved.
- Provider-level distinction tests inspect sources and vectors rather than relying only on aggregate counts.
- Current `.planning/codebase/*` maps are stale background; current source, tests, root owner docs, and archived Phase 42 artifacts are the authoritative patterns.

### Integration Points

- Extend `BeautyEffectPlan.swift` and `BeautySafetyCaps.swift` with four internal effective values and provisional caps.
- Extend `FaceShapeWarpProvider.swift` and `ChinWarpProvider.swift` with named field emissions and observed-support-only new vectors.
- Extend `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, and `BeautyGeometryEffectPipeline.swift` so preflight, conflict convergence, accounting, and dispatch agree.
- Extend provider, resolver, conflict, pipeline, missing-landmark, combined-safety, and facade tests; synchronize owner docs only for Phase 46's provisional provider/routing contract.

</code_context>

<specifics>
## Specific Ideas

- Use asymmetric contour fixtures so temple outward, cheekbone inward, smoothing neighbor-chord movement, and chin-adjacent taper cannot accidentally pass with aliased sources.
- Keep the chin apex vertically fixed under `chinTaper`; signed vertical apex movement remains exclusively `chinLength`.
- Preserve the blocker-honest four-row scope and treat renderer visibility and final naturalness as separate downstream evidence.

</specifics>

<deferred>
## Deferred Ideas

- Decoded public-facade output matrix, strict ROI/non-alias comparisons, ignored output helper/gallery, and representative no-face/malformed image evidence — Phase 47.
- Final caps/dead zones, exhaustive nine-field face transitions, thirty-seven-field geometry convergence, active-source boundary checker, final security/reliability closeout, exact four-row promotion, and milestone owner synchronization — Phase 48.
- `去双下巴`, `去双下巴 Pro`, `发际线`, semantic-region models/resources, Demo UI, physical-device evidence, commercial visual approval, optimized performance, packaging, shipping, and launch readiness — future scope.

</deferred>
