# Phase 38: Public Contract and Lip-Support Geometry - Context

**Gathered:** 2026-07-14
**Status:** Ready for planning
**Mode:** Autonomous smart discuss (`--auto` recommendations accepted)

<domain>
## Phase Boundary

Freeze five compatibility-safe public mouth controls, expand the stored model from 33 to 38 fields, record package-internal inner-lip availability, derive explicit upper/lower/inner supports, and route eight independently eligible mouth geometry fields through the existing resolver, conflict, provider, and public-facade path. Saved-output/helper/gallery evidence belongs to Phase 39; final caps, exhaustive safety, boundary closeout, and row promotion belong to Phase 40.

</domain>

<decisions>
## Implementation Decisions

### Public Contract
- Canonical signed fields are `mouthYPosition`, `mouthTilt`, and `mouthXPosition`; each is an independent `Float` normalized to `-1...1`, defaults to `0`, and preserves both directions without aliasing shipped mouth fields.
- Canonical positive-only fields are `lipPeakDefinition` and `lipPlump`; each is normalized to `0...1`, defaults to `0`, and is not an alias for `smile`, `mouthSize`, `mouthWidth`, or `lipColor`.
- Preserve existing source-style initializer calls through defaulted arguments and legacy 33-field JSON/preset behavior through missing-key decoding to zero; the exact new inventory is 37 numeric fields plus `filterId`.
- Keep bundled preset JSON unchanged so missing-key decoding, rather than explicit inserted zero keys, remains the compatibility proof.

### Lip Support and Geometry
- Keep `outerLips` sufficient for shipped mouth fields and the three whole-mouth transforms; record `innerLips` as a separate package-only availability group.
- Extend package-internal `FaceGeometry` with explicit deterministic `upperLips`, `lowerLips`, and `innerLips` support, default-empty for source compatibility and populated only from available lip groups.
- `mouthYPosition` translates eligible outer-lip sources vertically; `mouthXPosition` translates them horizontally; `mouthTilt` rotates them around a stable mouth center. Their source sets and displacement vectors must remain mutually distinguishable and bounded.
- `lipPeakDefinition` shapes a local upper-lip/cupid-bow subset and requires valid upper plus inner support; `lipPlump` thickens local upper and lower lip subsets away from the inner opening and requires valid upper, lower, and inner support.

### Eligibility and Conflict Convergence
- Start all five fields at provisional internal caps of `0.25`; Phase 39 output evidence may inform calibration and Phase 40 owns the final exact-cap lock.
- Expand provider-owned mouth emissions from three to eight fields. Missing, malformed, duplicate-only, non-finite, displacement-empty, or final-scale-empty support zeros only the dependent field while eligible siblings remain active.
- Reuse the bounded monotonic retained-field convergence already shared by nose and mouth. It may grow from nine to fourteen possible removals, but effective strengths, totals, counts, scales, metrics, and final provider emissions must agree.
- Any new field independently triggers the existing public-facade face-geometry route; diagnostics remain aggregate/redacted and must not expose raw landmarks, support arrays, or control points.

### Verification Boundary
- Contract tests cover exact defaults/ranges, mutation normalization, non-finite fallback, legacy decode, new round trip, preset neutrality, existing source-style construction, and exact 38-field inventory.
- Detection/adapter tests cover independent inner-lip availability plus finite, deterministic, bounded, non-duplicate support construction without making inner lips globally required for usable face geometry.
- Provider tests assert source subset, axis/direction, rotation, local peak/plump semantics, non-aliasing, deterministic ordering, bounds, and field-local fail-closed behavior—not point counts alone.
- Phase 38 closes only MOUTH-01 through MOUTH-08. It does not add renderer cases, generate galleries, finalize artistic caps, promote ledger rows, or claim branch completion.

### the agent's Discretion
- Exact private helper names, deterministic support ordering, proxy support coordinates, focused test organization, and small enumeration helpers may follow current source conventions.
- Exact provisional displacement coefficients and radii may be chosen conservatively provided every emitted point is finite, nonzero, normalized, bounded, deterministic, and capped.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyParameters` already owns explicit coding keys, defaulted initializer arguments, missing-key float decoding, signed/positive finite clamping, and normalized-copy forwarding.
- `BeautyFaceLandmarks`, `VisionFaceDetector`, `FaceGeometry`, and `BeautyFaceGeometryAdapter` already provide the package-only availability-to-support seam used by nose root/tip work.
- `MouthWarpProvider.fieldEmissions`, `BeautyEffectResolver`, and `GeometryConflictResolver` already converge shipped per-field mouth eligibility before metrics and dispatch.

### Established Patterns
- Public normalized ranges remain broader than conservative internal caps, and final cap promotion waits for public-facade output evidence.
- Missing support fails closed per field; stale geometry zeros geometry work; reused non-eye geometry scales by exact `0.5`.
- Public results expose redacted summaries, aggregate warnings, counts, totals, and scales only; raw biometric-adjacent geometry stays package-internal.

### Integration Points
- Public/storage changes center on `BeautyCore/Models/BeautyParameters.swift`; availability/support changes center on `BeautyDetection`, `WarpControlPoint.swift`, and `BeautyFaceGeometryAdapter.swift`.
- Strength, cap, activation, degradation, convergence, and dispatch changes center on `BeautyEffectPlan.swift`, `BeautySafetyCaps.swift`, `BeautyEffectResolver.swift`, `GeometryConflictResolver.swift`, and `MouthWarpProvider.swift`.
- Focused evidence belongs in existing `BeautyCoreTests`, `BeautyDetectionTests`, and `BeautyEffectsTests`; changed public, architecture, design, security, and reliability contracts must remain synchronized.

</code_context>

<specifics>
## Specific Ideas

Use `.planning/research/SUMMARY.md` as the v1.10 semantic authority, preserve archived v1.8/v1.9 evidence unchanged, and treat current source/tests as authoritative over stale `.planning/codebase/` maps.

</specifics>

<deferred>
## Deferred Ideas

- Eight isolated renderer cases, strict 308-output helper/gallery evidence, ROI and signed-direction comparisons — Phase 39.
- Final exact caps, exhaustive eight-field degradation/conflict matrices, active-source boundary scans, current-owner synchronization, and exact five-row promotion — Phase 40.
- `白牙`, teeth segmentation/retouch, Demo UI, device/commercial/packaging/shipping/launch evidence — outside Phase 38 and v1.10 geometry scope.

</deferred>
