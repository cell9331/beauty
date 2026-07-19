# Phase 42: Independent Eye Geometry and Pipeline Integration — Context

**Gathered:** 2026-07-16  
**Status:** Ready for planning  
**Mode:** Auto-resolved by `$gsd-autonomous --auto`

<domain>
## Phase Boundary

Implement the ten unresolved eye geometry controls on top of Phase 41's private,
validated `BeautyEyeSemanticSupport`, route all fourteen eye fields through the
existing provider/resolver/unified local-warp facade, and make eligibility and
aggregate accounting field-local. This phase owns provider vectors, provisional
effect caps, named emissions, resolver preflight/final sanitization, conflict
convergence, and unit/integration evidence. Phase 43 owns renderer cases,
decoded output/ROI evidence, and gallery files. Phase 44 owns final cap
calibration, exhaustive transition/safety ledgers, promotion, and owner docs.

</domain>

<decisions>
## Implementation Decisions

### Geometry Semantics

- `eyeHeight` changes only vertical aperture using each observed contour's upper
  and lower lid subsets around its stable center; `eyeLength` changes only
  horizontal span using inner/outer/corner support. Neither may reuse radial
  `eyeSize`, eye-center translation, or shipped tail-lift points.
- `upperEyelidLift` emits upper-lid-only upward vectors and
  `lowerEyelidDrop` emits lower-lid-only downward vectors. Corners and the
  opposite lid stay unchanged outside the provider's local falloff.
- Signed `eyeTilt` rotates each complete observed contour about its own center;
  positive and negative values must produce opposite tangential displacement,
  while center radius and eye-tail/vertical controls stay independent.
- `innerCornerOpen` targets the nasal/inner corner for each anatomical side and
  `outerCornerOpen` targets the temporal/outer corner. They are separate named
  emissions and cannot be implemented as aliases of length or tail lift.
- `pupilSize` is pupil-local radial geometry around each validated pupil and its
  owning contour. `gazeCorrection` is automatic only: move each validated pupil
  toward its owning contour's neutral center by a bounded monotonic fraction,
  with a small neutral dead zone; no manual direction or fabricated pupil is
  accepted.
- `eyeSymmetry` uses both valid eyes only to reduce measured paired differences
  (center, span/aperture, and tilt) toward a conservative midpoint. It no-ops
  when the pair is already neutral or implausible and never mirrors/replaces an
  identity-specific contour.

### Provider and Eligibility

- Extend `BeautyEffectiveStrengths` and `BeautySafetyCaps` with exactly the ten
  new scalars and keep positive-only versus signed normalization from Phase 41.
  Use conservative provisional caps in Phase 42; record them as provisional
  and leave evidence-backed exact values to Phase 44.
- `EyeWarpProvider` owns a `EyeWarpFieldEmissions` value containing all fourteen
  named arrays (four shipped plus ten new). Each emitter validates only the
  support it needs and returns `[]` when that support is absent, malformed,
  neutral/dead-zone, or non-renderable.
- A field whose provider emission is empty is zeroed before active-domain
  membership, totals, weakened counts, warnings, metrics, geometry-point
  counts, and dispatch. Valid eye siblings continue; invalid pupil support
  zeros only `pupilSize` and `gazeCorrection`.
- A missing either contour remains the established complete-eye-domain skip for
  all contour-dependent work. Nil legacy observed support keeps the shipped
  coarse proxy behavior needed by zero-default compatibility; explicit malformed
  observed support never falls back to synthetic proxies.
- Reuse `BeautyGeometryEffectPipeline` and the existing resolver; add no target,
  render pass, dependency, public support/result type, persistence, Demo import,
  network/cloud, or commercial path. Diagnostics remain aggregate and redacted.

### Resolver and Conflict Convergence

- Add all ten fields to normalized face-geometry requirement scans, effective
  strengths, eye requested-work checks, complete-eye degradation, and field
  sanitization. Preserve reused/stale complete-eye skip and safe non-eye domains.
- Preflight provider emissions before conflict accounting; after any combined
  weakening, re-evaluate eye, nose, and mouth emissions from one retained
  baseline so final-scale-ineligible fields are removed exactly once. Phase 42
  must be bounded for the fourteen eye + six nose + eight mouth fields; Phase
  44 will lock the final twenty-eight-removal evidence.
- Keep the public facade scalar-only. An isolated new field must activate the
  same detection → adapter → resolver → `BeautyGeometryEffectPipeline` route as
  shipped controls, with no new API or diagnostic geometry payload.

### Testing and Evidence

- Add deterministic synthetic semantic-support fixtures for both eyes, pupil
  presence/absence, measured asymmetry, neutral gaze, malformed support, and
  reused/stale/no-face states. Assert source/target locality, sign, radius,
  field distinction, named emission counts, and exact field-local zeroing.
- Test each ten-field isolation against its nearest shipped/new neighbors and
  verify all fourteen emission arrays are independently addressable. Exercise
  provider preflight/final sanitization and resolver active/skipped domains,
  warnings, metrics, and redaction. Full output/PNG visibility is explicitly
  deferred to Phase 43.

### the agent's Discretion

- Choose private helper names, exact provisional caps/dead-zone threshold,
  falloff/radius values, and the precise midpoint blend so long as they are
  finite, bounded, conservative, tested at boundaries, and documented as
  provisional rather than Phase 44 promotion evidence.
- Reuse the existing `FaceGeometry` fields for compatibility fixtures while
  preferring semantic supports whenever present; do not broaden the public
  model or introduce a separate eye geometry package.

</decisions>

<specifics>
## Specific Ideas

- Keep positive displacement semantics in image-normalized coordinates explicit:
  vertical lid lift moves toward smaller `y`, lower-lid drop toward larger `y`,
  and signed tilt preserves opposite tangential directions.
- Distinction tests must inspect source subsets and vector directions, not only
  aggregate point counts; a symmetric fixture can hide inner/outer or left/right
  mistakes.
- Gaze and symmetry are reductions of observed evidence, never user-authored
  directions or identity replacement.

</specifics>

<deferred>
## Deferred Ideas

- Renderer case matrix, strict decoded output/ROI proof, portrait pupil
  inventory, and ignored gallery publication — Phase 43.
- Final natural caps, exhaustive malformed/fresh/reused/stale transitions,
  combined 28-field convergence ledger, active-source boundary gate, exact
  promotion, and owner documentation — Phase 44.
- `去脂`, `祛红血丝`, Demo UI, device/commercial quality, packaging, shipping,
  and launch readiness — future scope.

</deferred>
