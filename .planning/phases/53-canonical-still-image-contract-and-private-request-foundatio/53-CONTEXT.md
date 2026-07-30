# Phase 53: Canonical Still-Image Contract and Private Request Foundation - Context

**Gathered:** 2026-07-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish the SDK-only still-image request boundary that any independently admitted v1.14 local-retouch feature can reuse: validate and canonicalize one opaque image, run one selected-face Vision request and mapping pass, keep mapped support request-local, and preserve exact legacy parameter and realtime/pixel-buffer behavior. This phase does not qualify a visible feature, add Demo UI, implement teeth/sclera/upper-eyelid transforms, or broaden the milestone to transparent, HDR, realtime, cloud, model, device, performance-budget, packaging, or release work.

</domain>

<decisions>
## Implementation Decisions

### Public Still-Image Entry and Runtime Isolation
- Reuse the existing public `BeautyEngine.process(image:orientation:parameters:)` and `processResult(image:metadata:parameters:)` facade entries; callers must not import an internal target or adopt a parallel local-retouch facade.
- Introduce the reusable local-retouch request foundation behind the still-image path only. `CVPixelBuffer` and realtime/camera/video routes must remain unable to activate v1.14 retouch and retain their shipped behavior.
- Keep the foundation feature-neutral: Phase 53 may add private admission plumbing and compatibility scaffolding, but visible feature controls and providers are added only after their independent Phase 54 gates permit them.
- Preserve safe-domain continuation: invalid local-retouch support or unavailable face support must not suppress unrelated shipped face-agnostic color behavior, while invalid canonical input must fail before Vision or local-mask work.

### Canonical Image Ownership and Rejection Policy
- Create exactly one opaque, up-oriented, explicitly color-managed sRGB RGBA8 canonical raster per admitted still-image request and share that same raster with Vision, private support providers, and rendering.
- Reject transparent input in v1.14 before Vision; do not silently composite, preserve alpha as a partial policy, or infer a background. Transparent/HDR/gain-map/extended-range ownership remains future work.
- Validate finite non-empty extent, configured pixel ceilings, orientation validity, supported RGB semantics, and opacity before local-retouch analysis, returning an existing or narrowly additive typed privacy-safe `BeautyError` without embedding metadata, paths, dimensions, or portrait-derived detail.
- Apply orientation and managed-color conversion once at the canonicalization boundary. Vision receives the canonical raster with `.up`; no downstream mapper or renderer may own a second orientation/color interpretation.

### Selected Face and Request-Local Support
- Perform at most one `VNDetectFaceLandmarksRequest` and one mapping pass for a still-image request with any admitted local-retouch effects; sibling effects consume one shared mapped request context rather than re-running detection.
- Preserve the existing selected-face policy semantics, but make the still-image local-retouch support value request-scoped and non-reusable: no mask, landmark, pupil, lip/teeth, sclera, or eyelid support may be stored on the engine or cross repeated, parallel, canceled, reset, or no-face requests.
- Treat selection, mapped observations, and eventual masks as package-private implementation data. Public results and diagnostics retain only current redacted summaries and allowlisted aggregates.
- Fail closed at the smallest supported unit in later providers. A no-face or missing-support result produces empty local support for the affected feature without stale fallback or cross-feature contamination.

### Compatibility and Admission Contracts
- Preserve the legacy 59 stored fields, trailing-default source construction, missing-key JSON decoding, bundled preset decoding, zero defaults, and shipped output byte behavior when no admitted local-retouch control is active.
- Any field later admitted by an independent gate must be a distinct positive-only `Float`, finite-normalized to `0...1`, default-zero, decode-missing-as-zero, and appended compatibly; no field may alias global whitening, brightness, lip color, eye geometry, or another candidate.
- Lock exact stored-field and Codable inventory tests at each admission. A closed feature gate adds no public field, coding key, preset key, provider, renderer case, or inert route.
- Keep existing input ceilings authoritative and reject before allocation-heavy canonicalization or Vision where the public input surface makes the condition observable; document narrower observability for already-decoded `CIImage` values rather than claiming encoded-byte validation the facade cannot perform.

### the agent's Discretion
- Choose the smallest package-internal types and file layout that make canonical raster ownership and request-local support explicit while preserving target dependency direction.
- Choose focused typed-error cases only where existing `invalidInput` or `unsupportedPixelFormat` cannot express a stable caller action without leaking sensitive context.
- Choose deterministic test fixtures and injection seams that prove exactly-once canonicalization/detection/mapping and zero cross-request retention without tracking portrait media.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyEngine` already separates public `CIImage` still-image and `CVPixelBuffer` processing and enforces configured pixel ceilings before resolution.
- `resolveStillImageGeometry` already centralizes face-geometry demand, selected observation routing, detection summaries, and safe degradation for the still-image facade.
- `VisionFaceDetector`, `CoordinateMapper`, `FaceSelectionPolicy`, `BeautyFaceObservation`, and `BeautyFaceGeometryAdapter` provide the existing Vision request, exactly-once coordinate mapping, selection, and package-private observed-support foundation.
- `BeautyParameters` already implements trailing defaulted construction, missing-key JSON compatibility, finite normalization, and signed/unit clamps across the shipped 59-field inventory.

### Established Patterns
- Host apps import only `BeautySDK`; internal targets and raw observed geometry remain hidden behind package access.
- Geometry support is carried in mapped observations and consumed through resolver/provider boundaries; diagnostics expose aggregate availability/reason codes rather than raw coordinates.
- Unsupported/malformed inputs use typed `BeautyError`, while missing face support degrades through `BeautyDetectionSummary` and plan warnings instead of throwing portrait-derived detail.
- Compatibility is enforced with exhaustive initializer, Codable, preset, field-count, no-op output, and public-facade tests rather than inferred from defaults alone.

### Integration Points
- Public request ownership begins in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` and the still-image routing extension in `BeautyEngineGeometryDetection.swift`.
- Canonical input and request-context types should live behind the facade in dependency-compatible package targets; Vision extraction remains owned by `BeautyDetection` and effect planning/rendering by `BeautyEffects`.
- Parameter admission attaches to `BeautyParameters`, resource validation/presets, `BeautyEffectResolver`, and exact compatibility tests only after the relevant feature gate opens.
- Contract changes belong in `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and `PLANS.md` according to their existing ownership.

</code_context>

<specifics>
## Specific Ideas

- Follow the wrapped Spike 013 normalize-once blueprint, while preserving its explicit nonclaim: cross-profile Vision landmarks and masks need bounded stability rather than byte-identical topology.
- Treat one selected-face request, request-local support, transparent-input rejection, and the original-pixel composition handoff as durable boundaries for later phases, not as visible feature proof.
- `--auto` accepted repository-backed recommendations; no new product scope or user preference was inferred beyond the v1.14 contracts already recorded in PROJECT/REQUIREMENTS/ROADMAP.

</specifics>

<deferred>
## Deferred Ideas

- Rights-approved feature eligibility and go/no-go decisions belong to Phase 54.
- Original-pixel ownership, provider overlap, and failure-isolation composition belong to Phase 55.
- Teeth, sclera, and conditional upper-eyelid algorithms and public controls belong to Phases 56-57 after their independent gates.
- Transparent/HDR/gain-map/multi-face policy, realtime/pixel-buffer local retouch, Demo UI, learned models, device/performance budgets, packaging, shipping, and release readiness remain outside v1.14.

</deferred>
