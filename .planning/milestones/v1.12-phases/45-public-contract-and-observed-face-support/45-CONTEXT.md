# Phase 45: Public Contract and Observed Face Support - Context

**Gathered:** 2026-07-21
**Status:** Ready for planning
**Mode:** Auto-resolved by `$gsd-autonomous --auto`

<domain>
## Phase Boundary

Add exactly four default-zero, independently stored public face-geometry scalars and the package-private, request-scoped observed face-contour and median-line support required to implement them honestly. This phase owns source/JSON compatibility, Vision-to-repository coordinate conversion, contour/centerline validation, canonical ordering, orientation correctness, privacy boundaries, and the explicit exclusion of semantic-region rows. It does not implement the four provider transforms, facade output cases, final caps, exhaustive degradation/convergence, ledger promotion, Demo UI, or device/commercial/release evidence owned by Phases 46-48 or future work.

</domain>

<decisions>
## Implementation Decisions

### Public Scalar Contract
- Add exactly `faceContourSmooth`, `templeFullness`, `cheekboneSlim`, and `chinTaper` to `BeautyParameters`; do not add aliases or any public face-support type.
- Keep all four fields positive-only and normalize each public `Float` to `[0, 1]`, with non-finite input falling back to `0`.
- Default every new field to zero in source initialization and missing-key decoding so existing call sites, the legacy 48-field JSON shape, bundled presets, shipped caps, and shipped vectors remain unchanged.
- Encode all four fields independently and prove the exact stored inventory becomes 52 fields: 51 numeric fields plus `filterId`.

### Observed Face-Support Model
- Capture Vision `faceContour` and `medianLine` points in one package-private, `Sendable`, request-scoped representation owned by `BeautyDetection`; do not reconstruct either support from face bounds.
- Convert face-bounds-normalized Vision coordinates exactly once into repository image-normalized coordinates through the existing `CoordinateMapper`, then validate finite closed-unit bounds at the conversion boundary.
- Preserve contour ordering while canonicalizing stable left/right traversal and centerline direction independently of Vision winding, portrait orientation, and mirrored metadata.
- Keep the legacy seven-point synthetic face-box contour only for already shipped face controls. The four new fields may consume only validated observed support and must fail closed when it is absent.

### Validation and Degradation
- Reject support that is empty, duplicate-only, non-finite, out of bounds, undersized, degenerate, side-inverted, internally inconsistent, or above an explicit fixed point ceiling before it reaches providers.
- Validate contour and median line independently, but expose field eligibility conservatively: contour-only transforms may use validated contour support, while any centerline-dependent derivation requires a valid median line.
- Missing or malformed observed support disables only the four new fields; eligible shipped face controls and face-agnostic domains continue unchanged.
- Use face-specific validation thresholds and tests. Do not reuse eye-support constants solely because a prior structure looks similar.

### Privacy, Scope, and Ownership
- Keep raw and derived contour/centerline coordinates package-internal, ephemeral, non-Codable, non-persistent, and absent from public APIs, logs, metrics, warnings, errors, descriptions, snapshots, and Demo imports.
- Use fixed redacted reason codes and aggregate counts only; diagnostics must not reveal coordinates, bounds, point samples, or biometric-adjacent payloads.
- Add no dependency, semantic model, resource manifest, runtime download, network/cloud path, render pass, facade method, or public result type.
- Keep `去双下巴`, `去双下巴 Pro`, and `发际线` explicitly future. A person matte, synthetic face-box region, or unlicensed/unversioned model is not acceptable evidence for them.

### Verification Boundary
- Contract tests cover defaults, normalization, non-finite input, exact 52-field inventory, legacy-payload decode, new-field round trip, and unchanged bundled preset JSON.
- Detection/adapter tests cover one-time conversion, stable ordering, side and centerline orientation, validation bounds, malformed rejection, absence behavior, and legacy synthetic-path isolation.
- Boundary tests prove no public/Codable/persistent/diagnostic/Demo exposure and no semantic resource or dependency is introduced.
- Phase 45 closes only FACE-07, FACE-08, FACE-09, FACE-12, SUPP-01, SUPP-02, and SUPP-04; provider geometry and visible output remain downstream.

### the agent's Discretion
- Exact package-private type names, file splits, and conservative validation thresholds may follow existing observation/adapter conventions.
- The adapter may retain validated full contours plus derived semantic indices when that avoids lossy re-derivation, provided ownership and privacy boundaries remain intact.
- A small internal refactor is allowed to share bounded point-validation helpers when it does not change shipped-field behavior or broaden scope.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` already centralizes stored fields, `CodingKeys`, defaulted initialization, normalization, missing-key decoding, and encoding.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` owns Vision observation mapping and `CoordinateMapper` conversion into image-normalized space.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` owns the package-only selected-face observation and current landmark-availability summary.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` is the detection-to-effect seam and currently synthesizes seven contour points from face bounds.

### Established Patterns
- The archived Phase 41 observed-eye implementation provides lifecycle, conversion, redaction, and malformed-support patterns, but face thresholds and topology remain independent decisions.
- Public behavior stays scalar-only through the `BeautySDK` facade; raw observed geometry stays package-internal.
- Compatibility additions use defaulted initializer arguments and missing-key decoding while bundled preset files remain unchanged.
- Existing face fields may keep the synthetic contour compatibility path; new claims require actual observed Vision evidence.

### Integration Points
- Extend `BeautyParameters` and `BeautyCoreTests` for the exact 48-to-52 contract.
- Extend `BeautyFaceObservation` and `VisionFaceDetector` to carry actual Vision face contour and median line through one-time coordinate mapping.
- Extend `BeautyFaceGeometryAdapter` with validated observed support parallel to, not replacing, the shipped synthetic `FaceGeometry.faceContour` path.
- Synchronize `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `PLANS.md` wherever Phase 45 changes their owned invariants or verification record.

</code_context>

<specifics>
## Specific Ideas

- Treat observed contour and median-line points as ephemeral render evidence, never an identity-bearing public model.
- Lock ordering and mirrored-orientation behavior before provider geometry is implemented; symmetric fixtures alone cannot prove temple, cheekbone, or chin semantics.
- Preserve the user's blocker-honest reduced scope: four rows can advance without pretending that missing semantic-region infrastructure exists.

</specifics>

<deferred>
## Deferred Ideas

- Four field-specific provider transforms, named emissions, resolver/conflict/facade routing, and provider-empty effective accounting — Phase 46.
- Renderer cases, decoded strict output comparisons, no-face/missing/malformed evidence, and ignored gallery — Phase 47.
- Final exact caps, exhaustive nine-field face transitions, thirty-seven-field geometry convergence, boundary closeout, and exact four-row promotion — Phase 48.
- `去双下巴`, `去双下巴 Pro`, `发际线`, local semantic models/resources, Demo UI, physical-device validation, commercial naturalness, optimized performance, packaging, shipping, and launch readiness — future scope.

</deferred>
