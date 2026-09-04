# Phase 91: Independent Gaze Correction - Context

**Gathered:** 2026-09-04
**Status:** Ready for planning
**Mode:** Auto-resolved under the owner-invoked `--auto` chain

<domain>
## Phase Boundary

Repair the existing positive `gazeCorrection` control so each independently
supported pupil moves measurably toward that pupil's own observed eye center
through the owner-local still-image public facade. The repair must preserve eye
aperture and contour, eyebrows, face, background, alpha, extent, metadata, and
all existing compatibility boundaries. An unsupported eye remains source-safe
without disabling an independently valid peer eye.

</domain>

<decisions>
## Implementation Decisions

### Per-eye anatomy ownership

- **D-01:** The only admissible production anatomy source is the existing
  request-local Apple Vision eye contour and pupil support after exactly-once
  coordinate mapping and current plausibility validation. Output darkness,
  lashes, shadows, foreign patches, symmetric proxies, inferred peer geometry,
  and new model/data paths cannot establish pupil or own-eye-center semantics.
- **D-02:** Eligibility and failure are per eye. One valid contour-plus-pupil
  side must remain active when the peer side is missing or implausible; the
  rejected side is preserved source-safe and contributes no borrowed,
  synthesized, mirrored, or stale support.
- **D-03:** Pair-level checks may remain only where a genuinely bilateral field
  needs them. They must not suppress an otherwise valid `gazeCorrection` side
  or make one eye's eligibility depend on the peer eye.

### Correction envelope

- **D-04:** Preserve the Phase 44 exact behavior contract: a normalized
  pupil-to-own-center offset at or below `0.002` is neutral, the public strength
  cap remains `0.25`, and the maximum centerward correction at that cap remains
  `35%`. The frozen Phase 89 thresholds are evidence boundaries and cannot be
  weakened after observing results.
- **D-05:** Use the narrowest pupil-local, anatomy-bounded influence that moves
  admitted pupil pixels while keeping eye aperture/contour, eyebrows, face,
  background, alpha, extent, and metadata inside existing exact or frozen
  tolerances. CPU remains the semantic oracle; the retained `Warp.metal`, public
  backend API, and CPU/GPU selection contract are unchanged.
- **D-06:** Neutral, no-face, reused/stale support, non-finite input, malformed
  contour/pupil, centered pupil, and rejected-side behavior remain deterministic
  and fail closed. A later valid request must recover without retained support.

### Semantic evidence and publication

- **D-07:** Phase 91 completion requires two linked proof layers: deterministic
  generated in-memory actual input/output pixel oracles whose pupil and eye
  anatomy are independently declared, and production-path request-local
  aggregate anatomy facts proving every eligible eye moved closer to its own
  center. Aggregate control-point evidence alone and image-darkness centroids
  alone are both insufficient.
- **D-08:** The Phase 89 gaze metric may become creditable only by consuming an
  allowlisted aggregate anatomy contract tied to the same request/output, while
  still enforcing its frozen actual-pixel target, locality, sibling, and
  protected-region gates. Phase 95 retains the final clean two-attempt,
  65-output, seven-effective-plus-one-deferred publication gate.
- **D-09:** Durable reports and diagnostics may contain only aggregate eligible,
  corrected, rejected, and protection counts; all-eyes-reduced/abstained state;
  bounded reduction statistics; and fixed reason codes. Raw or per-side
  coordinates, contour/pupil values, masks, pixels, fixture paths, private
  locators, and child transcripts remain request-local or temporary.

### Agent's Discretion

- Choose the narrowest existing internal seam for carrying the aggregate
  anatomy fact from `BeautyEffects` through the SDK-owned renderer/comparator,
  provided public facade signatures, parameter/preset/case inventories, and
  privacy boundaries remain unchanged.
- Choose exact private type names, generated fixture layout, integer/Q16
  representation, and focused test-file organization. The evidence must bind to
  actual rendered pixels and must mutation-test unsupported/proxy admission.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone and phase authority

- `.planning/ROADMAP.md` § Phase 91 — phase goal, three success criteria, and
  the one-research/one-checked-plan/two-attempt timebox.
- `.planning/REQUIREMENTS.md` § EYE-01 — independent per-eye centerward
  correction, protected anatomy, and fail-closed behavior.
- `.planning/PROJECT.md` § v1.22 — active repair boundary, compatibility
  invariants, nonclaims, and the rejected non-anatomical gaze proxy decision.
- `.planning/phases/89-semantic-validation-baseline/89-VERIFICATION.md` — exact
  deferred handoff: replace `unsupported_metric` only with independently owned
  pupil/own-eye anatomy; Phase 95 owns final publication.
- `PLANS.md` § Phase 89 / v1.22 — durable current-state ledger for the revoked
  gaze aggregate and remaining repair scope.

### SDK behavior owners

- `DESIGN.md` § Phase 41 and § v1.11 Phase 44 — observed eye support,
  validation ceilings, exact `0.002` dead zone, `0.25` cap, `35%` correction,
  and field-local failure contract.
- `ARCHITECTURE.md` § Current Still-Image Flow and Boundaries — detector,
  effects, renderer, request-local support, and public-facade ownership.
- `PRODUCT_SENSE.md` — owner-local SDK journey and user-visible acceptance
  boundary for any changed control behavior.
- `QUALITY_SCORE.md` § Phase 89 Semantic Validation Quality Evidence — why the
  dark-pixel centroid is non-creditable and which actual-pixel gates remain.
- `SECURITY.md` § Phase 89 semantic metric admission — forbidden persistent
  anatomy and aggregate-only evidence rules.
- `RELIABILITY.md` § Phase 89 semantic execution — fail-closed metric admission,
  status classes, deterministic reconciliation, and recovery behavior.
- `docs/SDK_EFFECT_TAXONOMY.md` § 眼睛 — current `gazeCorrection` semantic row
  and branch status authority.

### Fixture and privacy constraints

- `.codex/skills/spike-findings-beauty/SKILL.md` — request-local anatomy,
  fail-closed region isolation, mechanics-only generated fixtures, and
  persistence prohibitions.
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md` —
  canonical input, independent regional failure, original-pixel evidence, and
  aggregate-only diagnostics.
- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md`
  — generated fixtures prove mechanics only; owner-local real media and paths
  cannot enter durable artifacts.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautyObservedEyeSupport` and `VisionFaceDetector`: already carry actual
  left/right contour plus optional pupil data through one request-local mapped
  observation with no Codable representation.
- `BeautyFaceGeometryAdapter`: already validates contour finiteness, topology,
  bounds, containment, ellipse offset, and current paired ratios before forming
  `BeautyEyeSemanticSupport`.
- `EyeWarpProvider.gazeSample` and `gazeCorrectionEvidence`: already implement
  the exact dead zone, bounded own-center vector, and aggregate reduction math;
  these are reusable mechanics but not sufficient pixel evidence by themselves.
- `BeautyResult.metrics`, the SDK-owned renderer report, and Phase 89 stable
  payload machinery provide existing aggregate-only transport/publication seams
  that research can compare without exposing raw support.
- Phase 89 comparator self-tests and generated SwiftPM image oracles provide
  mutation, watermark, locality, protection, determinism, and recovery patterns.

### Established Patterns

- Explicit observed support never falls back to synthetic geometry; nil support
  exists only for zero-default compatibility.
- Geometry is mapped once, remains immutable/request-local, and diagnostics use
  fixed aggregate fields only.
- Provider emissions are sanitized per field after support validation and again
  after conflict resolution; CPU output is the permanent semantic reference.
- Generated image evidence must assert real input/output pixels and metadata;
  scripts succeeding or control points moving do not prove the effect.

### Integration Points

- `BeautyFaceGeometryAdapter.validatePairedPupils` currently couples two valid
  pupil outcomes through peer contour ratios and must be assessed against D-02.
- `EyeWarpProvider.semanticSupports` currently returns observed support only
  when both sides exist, directly blocking valid-peer gaze correction.
- `EyeWarpProvider.gazePoints` currently uses a fixed face-width influence
  radius; research must prove or narrow its eye-contour/aperture containment.
- `scripts/compare-face-feature-batches.swift` deliberately throws
  `unsupported_metric` for `pupilToOwnEyeCenter`; Phase 91 must replace that
  branch with anatomy-bound admission without reviving the rejected darkness
  proxy.
- `BeautyExampleRenderer` currently publishes output inventory only; any
  aggregate anatomy transport must remain SDK-owned, temporary/allowlisted,
  deterministic, and tied to the exact rendered request.

</code_context>

<specifics>
## Specific Ideas

- Keep the repair tightly scoped to the existing `gazeCorrection_0p25` case and
  current public field. Do not add controls, cases, presets, facade methods,
  models, datasets, or UI.
- Treat the three rejected Phase 89 gaze adversaries—lash/shadow darkness,
  foreign dark patches, and centered/off-center proxy images—as mandatory
  negative admission tests for any new metric bridge.

</specifics>

<deferred>
## Deferred Ideas

- Phase 95 owns the clean authorized-portrait rerun and final 65-output stable
  publication across all seven active repair directions plus deferred/partial
  `faceContourSmooth`.
- Phases 92–94 retain eyebrow-head, nose, and mouth-width repairs.
- New pupil models, datasets, weights, realtime/video support, physical-device
  qualification, population/naturalness claims, commercial approval, packaging,
  shipping, launch, release readiness, and external distribution remain outside
  Phase 91.

</deferred>

---

*Phase: 91-independent-gaze-correction*
*Context gathered: 2026-09-04*
