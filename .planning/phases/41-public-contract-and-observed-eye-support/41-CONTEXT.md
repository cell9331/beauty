# Phase 41: Public Contract and Observed Eye Support - Context

**Gathered:** 2026-07-16
**Status:** Ready for planning
**Mode:** Auto-resolved by `$gsd-autonomous --auto`

<domain>
## Phase Boundary

Add exactly ten default-zero, independently stored public eye-geometry scalars and the package-private, frame-scoped observed eye contour/pupil support needed to implement them honestly. This phase owns source/JSON compatibility, Vision-to-repository coordinate conversion, semantic eye-support derivation, validation, side/orientation correctness, and privacy boundaries. It does not implement the ten provider transforms, facade output cases, final caps, exhaustive degradation/convergence, ledger promotion, Demo UI, or device/commercial/release evidence owned by Phases 42-44 or later work.

</domain>

<decisions>
## Implementation Decisions

### Public Scalar Contract
- Add exactly `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, `eyeTilt`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry` to `BeautyParameters`; do not add aliases or a public eye-support type.
- Keep `eyeTilt` signed and normalize it to `[-1, 1]`; keep the other nine new fields positive-only and normalize them to `[0, 1]`.
- Default every new field to zero in source initialization and missing-key decoding so existing call sites, the legacy 38-field JSON shape, presets, shipped caps, and shipped vectors remain unchanged.
- Encode all ten fields independently and prove the exact stored inventory becomes 48 fields: 47 numeric fields plus `filterId`.

### Observed Eye-Support Model
- Capture Vision left/right eye contours and optional left/right pupils in one private, `Sendable`, request-scoped representation owned by `BeautyDetection`; never synthesize a pupil when Vision omits one.
- Convert face-bounds-normalized Vision coordinates exactly once into the repository image-normalized convention before provider use, with finite and closed-unit-bounds validation at the conversion boundary.
- Preserve anatomical side identity explicitly and canonicalize semantic upper, lower, inner, outer, corner, center, and pupil supports independently of input winding; cover portrait orientation and mirrored metadata with fixtures.
- Prefer validated observed support for the new fields while retaining the established symmetric proxy path only for shipped zero-default compatibility and shipped fields.

### Validation and Degradation
- Reject contour support that is empty, duplicate-only, non-finite, out of bounds, implausibly small/large, degenerate, or over a fixed point ceiling before it reaches `BeautyEffects`.
- Validate pupils independently using finiteness, containment relative to the owning eye, bounded center offset, and paired plausibility so blink-inaccurate or malformed pupils cannot move eyelids or create gaze evidence.
- Missing or implausible pupil support invalidates only `pupilSize` and `gazeCorrection`; contour-only siblings remain eligible when their contour support is valid.
- Missing either eye contour preserves the existing complete eye-domain skip; paired-only symmetry support also fails closed without fabricating the absent side.

### Privacy and Ownership
- Keep all raw and derived contour/pupil coordinates package-internal, ephemeral, and absent from public APIs, Codable state, logs, metrics, warnings, errors, descriptions, snapshots, and Demo imports.
- Use fixed redacted reason codes and aggregate counts only; no diagnostic may reveal side-specific coordinates, bounding boxes, pupil offsets, contour samples, or biometric-adjacent payloads.
- Add no dependency, target, model download, network/cloud path, persistence, render pass, facade method, or public result type.
- Phase 41 tests own compatibility, conversion, ordering, side identity, validation, field-local support availability, and boundary scans; visible transform semantics and cap calibration remain downstream.

### the agent's Discretion
- Exact private type names and file splits may follow the existing `BeautyFaceObservation` / `VisionFaceDetector` / `BeautyFaceGeometryAdapter` seams.
- Exact conservative numerical validation thresholds and point ceilings may be selected during planning, provided they are explicit, bounded, fixture-tested, and not presented as final visual caps.
- The adapter may retain validated full contours in addition to derived semantic subsets when that avoids lossy re-derivation, provided lifecycle and privacy constraints remain intact.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` already centralizes stored fields, `CodingKeys`, defaulted source initialization, normalization, decoding, and encoding.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` owns Vision observation mapping and the existing `CoordinateMapper` conversion into image-normalized space.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` owns package-only selected-face observations and landmark availability.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` is the existing detection-to-effect geometry seam; `EyeWarpProvider.swift` and `BeautyEffectResolver.swift` are downstream consumers reserved primarily for Phase 42.

### Established Patterns
- Public behavior is scalar-only through the `BeautySDK` facade; internal targets use package visibility and redacted diagnostics.
- Compatibility additions use defaulted initializers and missing-key decoding while bundled presets remain textually unchanged.
- Existing mouth/nose work validates private observed supports once, keeps field eligibility local, and tests both malformed support and safe-sibling continuation.
- Geometry rendering stays in the existing unified local warp; provider-emitted work, resolver strengths, and conflict accounting must ultimately converge.

### Integration Points
- Extend `BeautyParameters` and its core tests for the exact 38-to-48 contract.
- Extend Vision observation construction and coordinate mapping without changing public detector/facade results.
- Extend the package observation and `BeautyFaceGeometryAdapter` with validated side-aware eye supports consumed by Phase 42.
- Synchronize owning contracts in `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, and `PLANS.md` where Phase 41 changes their invariants or records verification.

</code_context>

<specifics>
## Specific Ideas

- Treat observed contours/pupils as evidence, not identity replacement: gaze and symmetry may later reduce only measured deviation and must never infer a requested direction.
- Lock side/orientation behavior before implementing warp vectors; a passing symmetric fixture is insufficient evidence for inner/outer corners, signed tilt, gaze, or symmetry.
- Keep `去脂` and `祛红血丝` outside this geometry milestone and preserve branch-level `眼睛` as partial until separately scoped retouch/color work exists.

</specifics>

<deferred>
## Deferred Ideas

- Ten field-specific provider transforms, fourteen named emissions, resolver/conflict/facade routing, correction dead zones, and automatic symmetry behavior — Phase 42.
- Renderer matrix, strict decoded output comparisons, eligibility-aware fixture evidence, and ignored gallery — Phase 43.
- Final exact caps, exhaustive degradation/transitions, provider-eligible combined convergence, fail-closed boundary checker, ledger promotion, and owner closeout — Phase 44.
- `去脂`, `祛红血丝`, Demo UI, physical-device validation, commercial naturalness, optimized performance, packaging, shipping, and launch readiness — future scope.

</deferred>
