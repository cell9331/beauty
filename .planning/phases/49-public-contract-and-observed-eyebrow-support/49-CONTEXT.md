# Phase 49: Public Contract and Observed Eyebrow Support - Context

**Gathered:** 2026-07-24
**Status:** Ready for planning
**Mode:** Auto-resolved (`gsd-autonomous --auto`)

<domain>
## Phase Boundary

Establish the exact seven-field public eyebrow contract and private request-scoped left/right Apple Vision eyebrow support. This phase owns compatibility, capture, mapping, validation, canonicalization, privacy, and lifecycle evidence only. Providers, resolver routing, visible output, row promotion, Demo/UI, device, commercial, packaging, and release claims remain downstream or out of scope.

</domain>

<decisions>
## Implementation Decisions

### Public Contract and Compatibility
- Add seven independent controls for vertical position, thickness, length, overall spacing, inner-head spacing, tilt, and peak definition.
- Preserve the milestone's signed-versus-positive semantics: the first six controls are signed and peak definition is positive-only; every new field defaults to zero and normalizes finitely.
- Expand `BeautyParameters` to exactly 59 stored fields, 58 numeric plus `filterId`, without changing legacy 52-field decoding, source compatibility, reset/diff/equality behavior, or bundled preset bytes.
- Keep nonzero values inert in this phase: public storage and compatibility land before any provider, resolver, facade, renderer, or output activation.

### Observation Capture and Mapping
- Reuse the existing single selected-face Vision landmarks request and copy actual left/right eyebrow traces immediately into request-local value data.
- Preflight each side independently with fixed point ceilings before mapping; malformed or oversized optional eyebrow data fails locally without erasing the selected face or valid sibling regions.
- Map every accepted point exactly once through the existing request-local orientation and mirror metadata; do not retry, cache, persist, or remap framework landmark objects.
- Never substitute eye contours, the historical eye geometry proxy, generated traces, or synthetic points for missing eyebrow evidence.

### Canonicalization and Validation
- Canonicalize both side identity and inner-to-outer point order using mapper-derived face-local axes so behavior is invariant across orientation, input mirroring, preview mirroring, and reversed Vision trace order.
- Treat each eyebrow as an independently validated open path with bounded counts, finite closed-unit coordinates, nondegenerate span, exact-bit uniqueness, and side/order checks.
- Preserve adjacency by whole-array reversal only; do not sort points or infer a closed polygon.
- Keep paired eligibility distinct from per-side validity so a malformed side does not contaminate valid support or unrelated landmark domains.

### Privacy, Lifecycle, and Evidence
- Keep raw and derived eyebrow support package-only, request-scoped, non-Codable, non-persistent, non-networked, and unavailable to Demo imports or public API.
- Diagnostics may expose only fixed reasons and aggregate counts; coordinates, stable geometry signatures, and biometric/profile-like data must not escape.
- Prove alternating, repeated, interrupted, stale/no-face, and parallel request isolation with no shared mutable support state.
- Close only BROW-01, BROW-02, SUPP-01, SUPP-02, and SUPP-03; explicitly retain all provider/output/promotion and v1.14-v1.16 claims as future.

### the agent's Discretion
- Exact internal type names, validation constants, helper placement, and test decomposition may follow existing face/eye support conventions, provided the ROADMAP counts, privacy boundaries, and fail-closed behavior remain exact.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Existing `BeautyParameters` compatibility, normalization, preset-byte, reflection, and legacy-payload tests provide the public-contract pattern.
- The current Apple Vision selected-face request, request-local coordinate mapper, and observed eye/face support value types provide the capture and exactly-once mapping boundary.
- Existing face-support boundary scripts and fixtures provide fail-closed privacy, lifecycle, topology, and owner-contract checks.

### Established Patterns
- Public controls land neutral before provider activation, with exact stored-field and numeric-field counts.
- Optional Vision regions are copied immediately, preflighted independently, mapped once, canonicalized by whole-array reversal, and validated at the adapter boundary.
- Raw landmark support remains internal and ephemeral; diagnostics are fixed and aggregate-only.

### Integration Points
- Public model work belongs in the current BeautySDK parameter model and its compatibility/resource tests.
- Eyebrow capture extends the existing Vision observation payload and selected-face request without adding requests, dependencies, targets, models, resources, network, or persistence.
- Validated semantic support attaches to the current face geometry adapter boundary but must not enter providers or unified warp dispatch until Phase 50.

</code_context>

<specifics>
## Specific Ideas

Mirror the proven Phase 45 observed-face-support rollout: safeguards and public compatibility first, actual framework capture and canonical mapping next, bounded validation and concurrency isolation after that, then an owner/boundary closeout with exact nonclaims.

</specifics>

<deferred>
## Deferred Ideas

- Phase 50: seven distinct eyebrow providers, resolver/conflict accounting, unified warp/facade routing.
- Phase 51: decoded public-facade image evidence and exact renderer/gallery inventory.
- Phase 52: final caps, exhaustive transitions, exact promotion, branch closeout.
- v1.14-v1.16 and all Demo/UI, device, commercial, packaging, shipping, and release-readiness work.

</deferred>
