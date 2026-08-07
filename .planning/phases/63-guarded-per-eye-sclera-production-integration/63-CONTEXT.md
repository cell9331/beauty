# Phase 63: Guarded Per-Eye Sclera Production Integration - Context

**Gathered:** 2026-08-07
**Status:** Ready for planning
**Mode:** Autonomous recommendations accepted under the active `--auto` run

<domain>
## Phase Boundary

Implement the independently admitted still-image sclera provider behind
`scleraRednessReduction`. The provider consumes the current request's one
canonical RGBA8 source plus actual mapped eye-contour and pupil support,
validates left and right independently, constructs a protected hard envelope
before scoring, re-clips after feathering, derives bounded targets only from
immutable source pixels, and contributes request-local per-eye units through
the existing composition owner.

This phase establishes production provider behavior and integration for
SCLERA-09 through SCLERA-13. Phase 64 still owns color-independent and
recolored-iris adversarial closeout, strict public-facade output cases,
original-detail final review, product-ledger promotion, and `眼睛` branch
disposition. Phase 63 adds no Demo activation, realtime/pixel-buffer route,
external model, network path, `去脂`, or release claim.

</domain>

<decisions>
## Implementation Decisions

### Canonical per-eye support and trust boundary

- **D-01:** Phase 62's fresh exact-open `sclera_redness` decision and direct
  normalized positive `scleraRednessReduction` admission are immutable
  prerequisites. Phase 63 uses the existing exact order `canonicalize -> one
  Vision detect/map -> request context -> providers -> compose -> render`; it
  cannot issue another Vision request, canonicalize again, cache support, or
  synthesize eye geometry from face bounds, teeth support, peer-eye support, or
  legacy geometry proxies.
- **D-02:** Production consumes only `BeautyFaceObservation.observedEyeSupport`
  from the current request. Explicit support is usable only when anatomical
  order is `.canonical`; an invalid/ambiguous order disables sclera work rather
  than guessing or swapping sides. Missing left or right support remains an
  independent local absence and does not erase an accepted peer.
- **D-03:** Each eye requires one side-unique simple contour and exactly one
  finite, in-bounds, polygon-contained plausible pupil sample. Duplicate sides,
  missing/multiple pupils, duplicate/degenerate/self-intersecting contours,
  collapsed aperture, implausible aspect/area, gaze beyond the accepted
  envelope, or malformed values reject only the affected eye unless side
  ownership itself is ambiguous.
- **D-04:** Guard thresholds are production constants frozen from a
  predeclared deterministic sweep over the already authorized ignored
  positive/negative pair plus bounded mechanics perturbations. The spike's
  `0.30` aspect and `0.14` width uncertainty values are calibration seeds, not
  values to copy automatically; uncertainty must prefer abstention and zero
  protected leakage over broader coverage.

### Hard envelope and protected anatomy

- **D-05:** For each accepted eye, rasterize the validated aperture and build
  one binary hard envelope before any redness score. It is the aperture minus
  a conservative contour-boundary band, an uncertainty-inflated pupil/iris
  exclusion, source-derived protected highlights, and lash/eyelid-margin
  exclusions. Skin and aperture exterior are absent by construction; a color
  gate is never allowed to stand in for iris, pupil, lash, skin, or highlight
  protection.
- **D-06:** Pupil/iris exclusion is centered only on that eye's actual mapped
  pupil and scales from that eye's validated width/height plus calibrated
  uncertainty. The provider cannot mirror a pupil, infer one from the peer,
  reuse an earlier request, shrink protection to recover coverage, or accept a
  pupil that falls outside the contour.
- **D-07:** Near-white highlights and dark lash/margin candidates are excluded
  from the hard envelope before redness scoring and conservatively expanded by
  a bounded local neighborhood. If exclusions leave no plausible sclera area,
  that eye abstains. Protected masks and candidates stay request-local and no
  vessel-like or pixel-level descriptor enters diagnostics.
- **D-08:** Redness scoring occurs only inside the accepted hard envelope.
  Every blur or feather is followed by multiplication with the same binary
  envelope, and every emitted proposal explicitly asserts hard-envelope
  membership. Final per-eye masks may be combined only by the composition
  owner; unexpected cross-unit overlap preserves the original pixel.

### Redness score, bounded transform, and detail preservation

- **D-09:** Score sclera likelihood from source luminance and saturation, then
  multiply it by measured positive red excess. Require a material local score
  and a plausible nonempty area; already-low-redness and unsafe candidates are
  exact no-ops. Thresholds are frozen before final private evaluation and may
  not be relaxed after viewing an unfavorable result.
- **D-10:** The transform reads each accepted RGB triplet only from the
  immutable canonical source, reduces only measured red excess by a bounded
  fraction of normalized public strength, adds only small compensating
  green/blue movement, restores original luminance within an explicit byte
  bound, and preserves alpha. It cannot globally desaturate, replace local
  color with white, or feed a partially transformed pixel back into scoring.
- **D-11:** Soft mask weight is applied exactly once by the existing Q16
  composition owner. The provider computes one full-strength source-derived
  target per accepted pixel; strength and soft weight cannot be multiplied
  twice. Vessel/detail variation remains visible because only measured excess
  is partially reduced and spatial texture is never blurred in the source
  image itself.
- **D-12:** The provider returns zero, one, or two per-eye units plus
  aggregate-only per-eye outcomes. One rejected eye cannot suppress or reuse
  an accepted peer; teeth and sclera units share one request-local composition
  owner, and collision-to-source, source binding, unit limits, alpha, and
  outside-union identity remain owned by that existing boundary.

### Production routing, recovery, evidence, and scope

- **D-13:** A direct positive sclera intent invokes the production provider
  exactly once after request-context creation, even when both eyes abstain.
  Teeth-only invokes no sclera provider; sclera-only creates no teeth work; both
  intents share one canonical request and one composition pass. Opaque Testing
  demand, aliases, color/skin/geometry fields, Demo labels, and `去脂` proxies
  cannot activate production sclera behavior.
- **D-14:** Missing/no-face support, blink/closure, severe gaze, glasses or
  contact occlusion, glare, collapsed contour, malformed pupil, and empty score
  preserve canonical pixels for only the affected eye while unrelated eligible
  teeth, color, or geometry effects continue. Repeated, parallel,
  valid-invalid-valid, reset, independent-engine, and interrupted requests
  retain no support, mask, proposal, target, output, or summary; pixel-buffer
  and reset paths perform zero sclera-provider work.
- **D-15:** Reuse the authorized ignored sclera positive/negative bundle only
  through fixed-output private execution. Before running it, freeze aggregate
  checks for positive per-eye red-excess improvement, bounded luminance/channel
  movement, zero reviewed-mask escape, retained detail/alpha, and negative
  naturalness or abstention. No media, locator, digest, rights detail, reviewer
  identity, raw support, mask, pixel, mechanics stream, or freeform text is
  tracked.
- **D-16:** Phase 63 closes only when deterministic provider, transform,
  per-eye containment, peer isolation, recovery, private genuine-fixture,
  privacy, security, focused/full SwiftPM, and Demo compatibility gates pass.
  Passing authorizes production provider integration only: renderer inventory
  remains 73, all three local-retouch Demo rows remain disabled, and visible
  output promotion, adversarial final-output proof, population sufficiency,
  device/performance, commercial, packaging, shipping, launch, and release
  readiness remain unclaimed.

### the agent's Discretion

The agent may choose private type/file names, checked raster helpers, exact
aggregate summary shape, calibrated constants within the frozen procedure, and
atomic plan boundaries. It may not weaken actual-support ownership, per-eye
failure isolation, pre-score protection, post-feather re-clipping,
immutable-source composition, private-fixture handling, or the Phase 64 output
and promotion boundary.

</decisions>

<canonical_refs>
## Canonical References

### Phase and milestone authority

- `.planning/ROADMAP.md` §Phase 63 and `.planning/REQUIREMENTS.md` SCLERA-09
  through SCLERA-13, plus the v1.15 exclusions and phase traceability.
- Phase 62 context, verification, security disposition, and exact-open ledger
  for the scalar/demand prerequisite and no-borrowed-evidence boundary.
- Phase 60 provider context and implementation for the one-request provider,
  immutable-source transform, composition-owner, private-fixture, and
  production-vs-output phase split patterns.

### Validated spike and safety findings

- `.codex/skills/spike-findings-beauty/references/sclera-redness.md` for
  guard-before-score, per-eye isolation, post-feather re-clip, bounded red-
  excess correction, privacy, and the two required adversarial oracles.
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md`
  for canonical input, one Vision request, original-pixel ownership,
  overlap-to-source, and request-local privacy/failure boundaries.
- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md`
  for ignored genuine-fixture and sanitized durable-output rules.

### Current implementation owners

- `BeautyFaceObservation.swift` and `VisionFaceDetector.swift` for actual
  mapped per-side contour/pupil support and explicit anatomical order.
- `BeautyEngine.swift` and `BeautyStillImageRequestContext.swift` for the one
  canonical still-image request and provider/composition insertion point.
- `BeautyTeethWhiteningProvider.swift`,
  `BeautyTeethWhiteningTransform.swift`, and
  `BeautyLocalRetouchComposition.swift` for checked ROI/mask helpers,
  source-only target derivation, Q16 weighting, source binding, and collision
  handling patterns.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautyObservedEyeSupport` already carries package-only side, contour, and
  pupil arrays mapped once into image-normalized space; `observedEyeOrder`
  records whether anatomical side order is trustworthy.
- `BeautyCanonicalStillImage` provides checked opaque sRGB RGBA8 bytes and an
  unforgeable request-local source binding. The existing composition owner
  accepts multiple source-bound units, blends Q16 weights once, suppresses
  collisions to source, preserves alpha, and exposes aggregate counts only.
- The teeth provider demonstrates checked polygons, bounded ROI rasterization,
  local blur followed by hard re-clip, immutable-source targets, per-request
  provider results, and engine integration without changing package
  dependencies.

### Established Patterns

- Direct normalized intent is the only production activator; Testing hooks may
  observe aggregate behavior but cannot create provider authority.
- Support is immutable, non-Codable, request-local, and fail-closed. Existing
  detection diagnostics expose counts only and do not persist coordinates,
  pupils, masks, candidate colors, or stable identities.
- Provider integration precedes a later strict public-output/promotion phase.
  Neutral presets, renderer inventory, disabled Demo taxonomy, realtime
  absence, and product ledgers remain unchanged here.

### Integration Points

- Add private sclera provider/transform code under `BeautyEffects/LocalRetouch`
  and invoke it in the admitted still-image branch beside the teeth provider.
- Extend request/test observation only with fixed aggregate per-eye counts and
  outcomes; production can read `selectedFaceObservation.observedEyeSupport`
  directly without exposing new public or Codable support.
- Add deterministic provider and facade lifecycle tests, then a fixed-output
  private authorized-fixture runner, exact-boundary checker, security report,
  and post-owner full regression.

</code_context>

<specifics>
## Specific Ideas

- Use the already authorized visible-redness positive and normal-sclera
  negative supplied for Phase 62; the two subjects need not match and no new
  originals are required for Phase 63's minimum private calibration gate.
- Prefer one provider result containing zero-to-two independently issued
  per-eye units so peer-eye abstention and aggregate observations are explicit.
- Treat the spike constants as measured starting points only. Freeze final
  production constants through the declared private/deterministic sweep before
  broad regression, and never trade protected-region safety for coverage.

</specifics>

<deferred>
## Deferred Ideas

- Color-independent geometry perturbation, recolored-protected-iris final-
  output oracle, strict renderer/helper evidence, final original-detail review,
  exact `祛红血丝` promotion, and `眼睛` branch disposition belong to Phase 64.
- Combined standalone merge equivalence, cross-provider collision matrix,
  milestone-wide privacy/compatibility audit, and archive/tag closeout belong
  to Phase 65.
- `去脂`, Demo activation, realtime/pixel-buffer local retouch, transparent/HDR/
  gain-map/multi-face expansion, external models/cloud, device performance,
  commercial review, packaging, shipping, and launch remain future.

</deferred>
