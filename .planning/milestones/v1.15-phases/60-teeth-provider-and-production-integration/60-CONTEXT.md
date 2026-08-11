---
phase: 60
name: teeth-provider-and-production-integration
status: discussed
mode: auto
created: 2026-08-07
---

# Phase 60: Teeth Provider and Production Integration - Context

<domain>
## Phase Boundary

Implement the independently admitted still-image teeth provider behind the
existing `teethWhitening` intent. The provider consumes the one canonical RGBA8
raster and the current request's actually mapped inner/outer lip support,
constructs a conservative fail-closed owned mask, derives bounded targets only
from immutable source pixels, and contributes one unit through the existing
original-pixel composition owner.

This phase implements production behavior and its package/facade integration,
but Phase 61 still owns independent public-output verification, adversarial
closeout, product-ledger promotion, and branch closure. Phase 60 adds no Demo
activation, realtime/pixel-buffer route, sclera surface, `去脂` surface,
external model, network path, or release claim.
</domain>

<decisions>
## Implementation Decisions

### Canonical support and trust boundary

- **D-01:** Phase 59's serializer-open `teeth_whitening` decision and direct
  normalized positive `teethWhitening` admission are immutable prerequisites.
  Phase 60 does not regenerate evidence, add an alias, or create another
  admission authority.
- **D-02:** A teeth request uses the existing exact order
  `canonicalize -> one Vision detect/map -> request context -> provider ->
  compose -> render`. The provider receives the same canonical carrier and the
  selected observation already present in `BeautyStillImageRequestContext`; it
  cannot issue Vision requests, canonicalize again, cache support, or synthesize
  a polygon from face bounds or legacy `FaceGeometry`.
- **D-03:** Both actual mapped `BeautyObservedLipSupport.outer` and `.inner`
  arrays are mandatory. They remain package-only, immutable, non-Codable, and
  request-local; production diagnostics expose only allowlisted aggregate
  counts and never coordinates, polygons, masks, candidate colors, pixels, or
  stable face identity.
- **D-04:** The provider independently rejects absent, partial, non-finite,
  out-of-unit, duplicate-degenerate, self-intersecting, non-nested, collapsed,
  closed, implausibly small/large, or otherwise malformed mouth support. Every
  rejection is a local abstention, not guessed geometry or request failure.

### Conservative fixed baseline and connected growth

- **D-05:** Build a fixed strong baseline only inside the unfeathered inner-lip
  polygon. Selection combines luminance, saturation neutrality, blue-floor,
  and red-imbalance gates. The baseline is accepted only when its strong area
  is within the predeclared `1.5%...94%` plausibility interval; no synthetic
  seed is permitted.
- **D-06:** Adaptive work starts only from accepted fixed pixels above `0.15`.
  It searches within the outer-lip polygon clipped to the inner aperture's
  narrow vertical band, including the prior upper safety inset and bounded
  lower extension. Candidate limits derive from current mouth/seed color,
  eight-connected growth retains only seed-connected pixels, and failed area
  or connectivity invariants return no unit.
- **D-07:** Blur and feather are always re-clipped to the hard mouth-local
  envelope. The final mask is the maximum of the clipped adaptive mask and the
  clipped fixed baseline, so no accepted strong baseline pixel is dropped.
  Every effective proposal carries explicit hard containment and no pixel
  outside the final owned mask can change.

### Bounded immutable-source transform and composition

- **D-08:** The transform reads each accepted RGB triplet only from the
  immutable canonical source. At maximum public input it uses the previously
  accepted conservative strength scale, requires material yellow excess,
  applies the locked `1.45` yellow-neutralization factor, and limits luminance
  correction to the prior small target. The target is computed once at the
  request strength without embedding the soft-mask weight; the composition
  owner's Q16 blend applies that weight exactly once. It preserves alpha and
  never feeds a partially transformed pixel back into selection or color
  calculation.
- **D-09:** Neutral and already-light pixels, plus lightly warm pixels below the
  fixed yellow gate, are exact no-ops. Accepted yellow pixels must reduce yellow
  excess while remaining channel/luminance bounded; whitening cannot become
  global desaturation, mouth brightening, or porcelain replacement.
- **D-10:** The provider emits at most one `BeautyLocalRetouchUnit` through the
  existing request-local `BeautyLocalRetouchCompositionOwner`. The owner remains
  the only RGB writer, rechecks hard containment and source binding, preserves
  source on collision, and leaves every unowned byte unchanged.

### Production routing, failure isolation, and recovery

- **D-11:** A normalized positive teeth value invokes the provider once in the
  admitted still-image route even when the provider abstains. Missing/no-face
  support, closed or unsafe mouths, no yellow candidates, and already-light
  inputs preserve canonical local pixels while unrelated eligible color or
  geometry effects continue through the existing render plan.
- **D-12:** Provider/unit failure is teeth-local. Malformed canonical input
  retains the existing typed request failure; malformed teeth support or an
  empty proposal never suppresses valid feature-neutral testing siblings or
  unrelated production effects.
- **D-13:** Repeated, valid-invalid-valid, reset, independent-engine, parallel,
  and interrupted request tests must show no retained lip support, mask,
  proposals, output, or summary. Pixel-buffer and reset paths perform zero
  teeth-provider work.

### Genuine fixtures, scope, and closeout

- **D-14:** Reuse the already authorized ignored positive/negative teeth bundle
  only through the fixed-output private runner. Before execution, freeze
  aggregate checks for positive yellow-excess improvement, bounded luminance
  and channel movement, zero reviewed-mask escape, preserved texture/alpha and
  negative naturalness. No fixture locator, filename, digest, rights detail,
  reviewer identity, raw metric stream, or image is tracked.
- **D-15:** Preserve exactly 60 parameter fields, five neutral presets, three
  disabled local-retouch Demo rows, and exact absence of production sclera,
  `去脂`, realtime/pixel-buffer local retouch, external model/resource, network,
  persistence, or active UI routes. Renderer/output inventory may advance only
  in Phase 61's independently verified facade-output contract.
- **D-16:** Phase 60 closes only when deterministic provider, transform,
  containment, protected-tissue, recovery, private genuine-fixture, privacy,
  security, focused/full SwiftPM, and Demo compatibility gates all pass.
  Passing establishes a production provider implementation, not Phase 61
  promotion, population sufficiency, device/performance readiness, commercial
  quality, packaging, shipping, launch, or release readiness.

### The Agent's Discretion

The agent may choose private type/file names, checked rasterization helpers,
integer/Q16 conversions, and exact test fixture dimensions. The fixed baseline
must remain conservative, adaptive growth cannot weaken it, and any uncertain
support or arithmetic condition must abstain rather than broaden coverage.
</decisions>

<canonical_refs>
## Canonical References

- `.planning/ROADMAP.md` and `.planning/REQUIREMENTS.md` — Phase 60 goal,
  TEETH-09 through TEETH-14, and Phase 61/62 ordering.
- `.planning/phases/59-teeth-evidence-and-admission-contract/59-VERIFICATION.md`
  — exact-open scalar/admission prerequisite and downstream nonclaims.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` and
  `BeautyStillImageRequestContext.swift` — one canonical still-image lifecycle.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` and
  `BeautyFaceObservation.swift` — actual mapped request-local lip support.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`
  — immutable-source owner, hard re-clip, collision-to-source, and Q16 blend.
- `.codex/skills/spike-findings-beauty/references/teeth-whitening.md` — fixed
  baseline, connected adaptive growth, and bounded de-yellowing findings.
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md` —
  canonical one-request, request-local privacy, and original-pixel composition.
- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md`
  — ignored genuine fixture and sanitized review boundary.
</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautyCanonicalStillImage` already provides checked, up-oriented, explicit
  sRGB, opaque RGBA8 bytes and an unforgeable request-local source binding.
- `BeautyObservedLipSupport` already carries independently preflighted actual
  inner/outer Vision values mapped exactly once into image-normalized space.
- `BeautyLocalRetouchCompositionOwner` already owns bounded proposal issuance,
  immutable-source blending, hard re-clipping, duplicate rejection, collision
  suppression, alpha preservation, and outside-union identity.
- `BeautyEngine` already creates one stack-local request context for a positive
  opaque demand and hands the composed canonical carrier to the existing color
  and geometry renderer.

### Integration Points

- Add the provider under `BeautyEffects`, where canonical pixels, mapped lip
  support, and composition units can meet without reversing package
  dependencies.
- Invoke it in the admitted still-image branch after request-context creation
  and before composition; opaque Testing-only units may share the same owner
  but cannot activate the production teeth provider without direct teeth
  intent.
- Extend package tests first, then facade lifecycle tests, private genuine
  evaluation, boundary checker, and root owner documents.
</code_context>

<deferred>
## Deferred Ideas

- Phase 61 owns strict public-facade decoded-output cases, adversarial
  protected-region closeout, original-detail final review, `白牙` promotion, and
  branch-ledger closure.
- Sclera intent/provider/output remains blocked until teeth closes in Phase 61.
- `去脂`, Demo controls, realtime/pixel-buffer local retouch, transparent/HDR/
  gain-map/multi-face expansion, external models/cloud, device performance,
  commercial review, packaging, shipping, and launch remain out of scope.
</deferred>

---
*Context gathered: 2026-08-07*
