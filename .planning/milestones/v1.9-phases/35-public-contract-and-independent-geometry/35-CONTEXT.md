# Phase 35: Public Contract and Independent Geometry - Context

**Gathered:** 2026-07-13
**Status:** Ready for planning
**Mode:** Autonomous smart discuss (`--auto` recommendations accepted)

<domain>
## Phase Boundary

Freeze the compatibility-safe public contracts for `noseRootNarrowing` and `noseTipLift`, expand the public model from 31 to 33 stored fields, route both values through the existing geometry planning path, and implement bounded independent provider geometry. Renderer/gallery evidence belongs to Phase 36; exhaustive six-field safety, boundary scans, and branch promotion belong to Phase 37.

</domain>

<decisions>
## Implementation Decisions

### Public Contract
- Canonical fields are `noseRootNarrowing` and `noseTipLift`; neither is an alias for an existing nose field.
- Both fields are positive-only public `Float` values normalized to `0...1` with default `0` and non-finite fallback to `0`.
- The source-distributed package preserves existing source-style initializer calls through defaulted arguments and old JSON/preset behavior through missing-key decoding to `0`.
- The milestone does not claim ABI compatibility for already compiled binary clients; binary distribution remains separate scope.

### Independent Geometry
- `noseRootNarrowing` symmetrically contracts only a deterministic upper-root subset toward the nose centerline; source and target Y must remain equal.
- `noseTipLift` moves only a deterministic lower-tip subset upward; source and target X must remain equal.
- Root output must differ structurally from `noseBridge`; lift output must differ structurally from both signed `noseTipSize` directions.
- Insufficient subsets fail closed with no legacy point substitution; all emitted points remain deterministic, finite, clamped, and bounded.

### Planning and Safety Scope
- Begin with independent internal caps of `0.25` for both new fields; Phase 36 output evidence may calibrate them, and Phase 37 owns the final exact-cap lock.
- Thread both values through geometry-required detection, effective strengths, activation, metrics, reusable scaling, zeroing, and conflict totals in Phase 35.
- Preserve current resolver call placement in Phase 35 unless moving to one-pass resolution is required for correctness; Phase 37 owns the exhaustive once-only weakening contract and regression gate.
- Existing face, eye, nose, mouth, color, and filter behavior must remain unchanged when both new values are zero.

### Verification Boundary
- Contract tests must cover defaults, normalization, non-finite inputs, 33-field inventory, old-payload decode, new round trip, and bundled preset neutrality.
- Provider tests must assert subset, axis, direction, nonzero displacement, non-aliasing, deterministic ordering, bounds, and missing-input behavior—not point counts alone.
- Facade tests must prove either field independently triggers existing geometry routing without exposing raw landmarks or control points.
- Phase 35 closes only NOSE-01 through NOSE-06; it must not promote ledger rows or branch status.

### the agent's Discretion
- Exact private helper names, deterministic subset-selection implementation, and focused test organization may follow existing code conventions.
- A small internal refactor is allowed when it reduces repeated six-field enumeration without changing public or previously verified behavior.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyParameters` already has explicit coding keys, defaulted initializer arguments, missing-key float decoding, normalization, and finite clamping.
- `BeautyEffectResolver`, `BeautyEffectiveStrengths`, `BeautySafetyCaps`, and `GeometryConflictResolver` already own activation, caps, freshness reduction, and combined geometry weakening.
- `NoseWarpProvider` already separates slim, wing, signed tip-size, and bridge point generation behind the unified warp pipeline.

### Established Patterns
- Public normalized ranges remain broader than internal natural-output caps.
- Missing/stale nose geometry fails closed; reused non-eye geometry scales by exact `0.5`.
- Public results expose redacted summaries, warnings, counts, and scales only; raw geometry stays package-internal.

### Integration Points
- Production changes center on `BeautyCore/Models/BeautyParameters.swift`, `BeautyEffectPlan`, `BeautySafetyCaps`, `BeautyEffectResolver`, `GeometryConflictResolver`, and `NoseWarpProvider`.
- Focused coverage belongs in `BeautyCoreTests`, `BeautyEffectsTests`, and public-facade geometry tests; current contract docs must be updated when the public model changes.

</code_context>

<specifics>
## Specific Ideas

Use the research reconciliation in `.planning/research/SUMMARY.md` as the semantic authority. Preserve archived v1.7 four-field evidence unchanged and treat current source/tests as authoritative over stale codebase maps.

</specifics>

<deferred>
## Deferred Ideas

- Renderer/helper/gallery evidence and ROI calibration — Phase 36.
- Exhaustive six-field degradation, once-only combined weakening, active-source boundary scans, owner synchronization, and SDK-core branch promotion — Phase 37.
- Signed root widening, downward tip movement, 3D depth/relighting, Demo UI, device/commercial/packaging/launch evidence — outside v1.9.

</deferred>
