# Phase 50: Independent Eyebrow Geometry and Pipeline Integration - Context

**Gathered:** 2026-07-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Activate the seven Phase 49 eyebrow parameters as distinct provider-owned geometry through the existing effective-strength, resolver, conflict, unified-warp, and public-facade path. This phase proves compiled behavior and routing only; decoded output evidence, final cap calibration, exhaustive transition closure, and ledger promotion remain Phases 51-52.

</domain>

<decisions>
## Implementation Decisions

### Seven Independent Geometry Semantics
- Implement one named provider emission per public field: vertical position translates the whole supported brow vertically; thickness expands/contracts locally across the trace normal; length extends/contracts the outer endpoint region; whole-brow spacing moves both brows symmetrically away from/toward the face center; inner-head spacing moves only the inner endpoint neighborhoods; tilt applies an endpoint-weighted rotation around each brow center; peak definition moves only an eligible apex neighborhood.
- Preserve signed direction for the six signed fields and positive-only behavior for peak definition; no field may alias another field's vectors or silently reuse an eye/face parameter.
- Providers consume the Phase 49 canonical inner-to-outer semantic traces directly and must not sort, remap, close, synthesize, or persist them.
- Keep all geometry brow-local and leave every shipped face, eye, nose, and mouth control-point array byte-for-byte unaffected by eyebrow-only input.

### Eligibility and Local Degradation
- Vertical position, thickness, and length are independently eligible per valid side; a missing or malformed sibling removes only that side's contribution.
- Whole-brow spacing requires two distinct valid sides; inner-head spacing remains independently computable per valid side from its canonical inner endpoint.
- Tilt is per-side and requires a nondegenerate canonical chord; peak definition is per-side and additionally requires the Phase 49 unique interior apex.
- Provider-empty work is removed field-locally before final evidence; missing, malformed, no-face, stale, or ineligible support never fabricates fallback geometry, while eligible eyebrow siblings and unrelated safe domains continue.

### Resolver, Conflict, and Unified Dispatch
- Add seven named effective strengths and seven named provider emissions through the existing resolver and public facade; preserve normalized public values until the provider-specific provisional caps are applied exactly once.
- Extend the provider-eligible convergence inventory from 37 to exactly 44 named fields, with one monotone removal loop, no re-entry, and one final scale shared consistently by strengths, provider output, dispatch, metrics, and warnings.
- Route eyebrow emissions through the existing unified warp dispatch exactly once; do not add a second renderer, pre-warp pass, or eyebrow-special public path.
- Preserve conflict policy symmetry with existing provider-owned geometry: field-local removals are monotone, unrelated domains are not weakened merely because eyebrow support is absent, and reused eligible geometry follows the established freshness scale exactly once.

### Evidence and Scope Guardrails
- Use focused provider, resolver, conflict, combined-plan, pipeline, degradation, and public-facade tests plus the full SwiftPM suite; lock exact named-field counts, totals, scales, removals, and dispatch agreement rather than relying on visual inspection.
- Keep provisional eyebrow caps internal to Phase 50 and explicitly non-final; Phase 52 owns conservative final cap calibration and exhaustive boundary/transition evidence.
- Add no dependency, model, resource pack, SwiftUI/Demo source, network/cloud path, persistence, commercial behavior, or public/SPI raw-geometry surface.
- Do not add Phase 51 renderer/gallery cases or claim visible direction/locality/distinction evidence, and do not promote any `眉毛` product row or branch status before Phase 52.

### the agent's Discretion
- Exact provider type names, helper decomposition, provisional cap values, locality falloff functions, and test-file partitioning may follow the existing eye/mouth/face provider patterns, provided all seven semantics remain independently named, eligibility rules and the exact 44-field convergence contract are enforced, and Phase 49 privacy/non-substitution boundaries remain intact.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyEyebrowSemanticTrace`, `BeautyEyebrowSemanticSupport`, and `FaceGeometry.observedEyebrowSupport` already provide validated canonical points, endpoints, center, optional apex, side identity, and paired eligibility.
- Existing face, eye, nose, and mouth geometry providers demonstrate provider-owned vector generation, field-local sanitization, named emissions, provisional caps, freshness scaling, and aggregate diagnostics.
- `BeautyEffectResolver`, the combined-plan/conflict machinery, `BeautyGeometryEffectPipeline`, and the public `BeautyEngine` facade already provide the single routing and unified dispatch seams this phase must extend.

### Established Patterns
- Geometry is emitted as immutable named work, sanitized and removed monotonically before a single final convergence scale and exactly-once unified warp dispatch.
- Missing or malformed semantic support fails locally; safe independent domains continue and diagnostics expose fixed labels/counts rather than coordinates.
- New milestone fields first use provisional internal caps, gain decoded public-facade output evidence in the next phase, and receive final calibrated caps plus promotion only in closeout.

### Integration Points
- Add eyebrow provider emissions beside existing provider-owned geometry in `BeautyEffects`, not in detection or public model storage.
- Extend resolver effective strengths, geometry requirements, conflict/convergence inventory, combined planning, pipeline control points, metrics, warnings, and facade tests at their existing named-field seams.
- Reuse the ignored historical portrait fixtures only for compiled/facade test setup in this phase; Phase 51 owns saved decoded output and gallery evidence.

</code_context>

<specifics>
## Specific Ideas

The Phase 49 contract is frozen: seven exact public identifiers, actual Apple Vision eyebrow provenance, request-local exactly-once mapping, canonical inner-to-outer open traces, independent side validity, aggregate-only diagnostics, and no eye/synthetic substitution. Phase 50 should mirror the repository's established incremental geometry-slice pattern while making the exact 44-field convergence and seven named emissions auditable.

</specifics>

<deferred>
## Deferred Ideas

- Phase 51: thirteen isolated public-facade cases, decoded 504-output direction/locality/distinction evidence, safe no-ops, and ignored gallery containment.
- Phase 52: final caps, exhaustive fresh/reused/stale/no-face/missing/malformed/provider-empty transitions, active-source/privacy gates, exact seven-row promotion, and implemented branch status.

</deferred>
