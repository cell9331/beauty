# Phase 55: Original-Pixel Composition and Failure-Isolation Core - Context

**Gathered:** 2026-08-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Build the SDK-only, feature-neutral composition core that later independently
admitted local-retouch providers can reuse. The core accepts bounded
request-local contributions derived from the one Phase 53 canonical RGBA8
raster, sanitizes hard containment and ownership, composes accepted disjoint
pixels once, preserves canonical source bytes for collisions and all unowned
pixels, and isolates malformed or absent work at the smallest anatomical unit.

Phase 54 closed the teeth, sclera, and upper-eyelid gates. Phase 55 therefore
adds no candidate field, CodingKey, preset key, named feature provider,
transform, renderer case, product admission, public/SPI mask surface, Demo/UI,
realtime/pixel-buffer route, or visible output. Production admission remains
exact-empty. Mechanics-only test inputs may prove the reusable core and its
facade-adjacent package wiring, but supply no feature-effectiveness or
naturalness evidence.

</domain>

<decisions>
## Implementation Decisions

### Admission and Package Boundary

- **D-01 / D-55-01:** Keep `BeautyEffectResolver.localRetouchAdmission(parameters:)` and
  `BeautyLocalRetouchAdmission.none` exact-empty in production. A closed Phase
  54 decision must not create an inert candidate route.
- **D-02 / D-55-02:** Implement only package-internal, feature-neutral composition values and one
  request-local owner. No type or diagnostic may expose teeth, sclera, eyelid,
  mask coordinates, pixels, landmarks, pupils, or owner identities publicly,
  through SPI, Codable, persistence, or logs.
- **D-03 / D-55-03:** Wire the core far enough that package tests prove it consumes the same
  `BeautyCanonicalStillImage` carried by `BeautyStillImageRequestContext` and
  cannot be orphaned. Any facade-path activation is opaque/testing-only and
  must remain unreachable from production parameters, presets, Demo, and
  pixel-buffer/reset routes.
- **D-04 / D-55-04:** Preserve the shipped no-admission path byte-for-byte and structurally. Local
  composition failure must never suppress unrelated existing face-agnostic
  color/filter work.

### Immutable Original-Pixel and Contribution Contract

- **D-05 / D-55-05:** Every accepted local pixel proposal is bound to the immutable canonical
  `rgba8Data` owned by the current request. The composition core reads source
  pixels only from that carrier; it never reads another contribution's output
  or a partially composed frame.
- **D-06 / D-55-06:** Each contribution represents one smallest independently rejectable unit and
  carries enough source binding for the core to prove that its proposals refer
  to the current canonical dimensions and original bytes. Exact representation
  is implementation discretion; trust-by-call-order or an unverified second
  raster is not acceptable.
- **D-07 / D-55-07:** Validate all dimensions, counts, indices, arithmetic, weights, and source
  bindings before accepting a unit. Structural failure rejects that unit as an
  abstention without throwing away valid siblings. A failure of the canonical
  carrier itself remains a request-level typed failure.
- **D-08 / D-55-08:** Keep composition deterministic and order-independent. Use an integer-defined
  RGBA8 blend/rounding contract, preserve canonical alpha, and avoid
  device-dependent color conversion or unordered reduction behavior.

### Hard Containment and Single Ownership

- **D-09 / D-55-09:** A contribution distinguishes its hard anatomical envelope from its final
  soft/feathered weight. The composition boundary clamps the weight and
  re-intersects it with the hard envelope after all provider-side growth, blur,
  or feathering; pre-filter containment is never treated as sufficient.
- **D-10 / D-55-10:** A valid pixel has zero or one effective owner. A duplicate claim within one
  unit is structurally invalid for that unit rather than silently merged.
- **D-11 / D-55-11:** If two or more accepted units claim the same pixel, suppress every local
  proposal at that pixel, copy the canonical source pixel unchanged, and
  increment one aggregate collision-pixel count. Do not select by array order,
  strength, max weight, anatomy, provider priority, or last write.
- **D-12 / D-55-12:** Every pixel outside the final owned union remains byte-identical to canonical
  source. A zero-weight proposal is unowned and cannot affect output or counts.

### Smallest-Unit Failure Isolation

- **D-13 / D-55-13:** Treat teeth, each sclera eye, and any future eyelid band as independently
  accept-or-abstain units without implementing those named providers in this
  phase.
- **D-14 / D-55-14:** A teeth-unit failure removes only teeth work. A left- or right-eye failure
  removes only that eye. A whole-sclera/provider failure is represented by both
  eye units abstaining while unrelated teeth or future eyelid units remain
  unchanged.
- **D-15 / D-55-15:** Collision suppression is pixel-local rather than a whole-unit rejection;
  noncolliding pixels from every otherwise valid unit still compose from the
  original source.
- **D-16 / D-55-16:** Deterministic failure injection must prove that standalone accepted siblings
  byte-match their portions of fused output and that valid-invalid-valid
  requests retain no prior pixels, claims, masks, or summary state.

### Verification, Privacy, and Nonclaims

- **D-17 / D-55-17:** Author Wave 0 tests before implementation for COMP-01 through COMP-05. Use
  tiny opaque mechanics-only canonical rasters and independently authored
  expected byte arrays, not captured output from the system under test.
- **D-18 / D-55-18:** Freeze byte-level oracles for standalone, explicitly merged, fused disjoint,
  duplicate-claim, cross-owner collision, outside-union identity, hard
  re-clipping, and teeth/whole-sclera/left-eye/right-eye failure scenarios.
- **D-19 / D-55-19:** Keep observations package-only and aggregate-only: accepted/rejected unit
  counts, owned/changed/outside-union/collision pixel counts, and bounded timing
  only where already allowed. Do not expose masks, coordinates, source/output
  pixels, anatomy labels, local paths, or raw errors.
- **D-20 / D-55-20:** Treat the Spike 012 whole-frame CPU measurements as mechanics baselines, not
  a performance win or device budget. Phase 55 may choose bounded sparse/ROI or
  dense implementation based on correctness and allocation safety, but claims
  no device, latency, memory, commercial, packaging, shipping, or release result.

### the agent's Discretion

- Choose the smallest dependency-correct file/type layout in `BeautyEffects`
  and the narrowest package wiring in `BeautySDK` that prevents an orphaned
  core without creating a production candidate route.
- Choose the internal hard-envelope/soft-weight/source-binding representation,
  checked allocation ceilings, stable owner token, and exact integer blend
  formula, provided every decision above is mechanically testable.
- Choose opaque test-only scenarios and aggregate counters that prove request
  integration without exposing raw support or anatomy through SPI.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautyCanonicalStillImage` already owns immutable, opaque, up-oriented,
  explicit-sRGB RGBA8 bytes with checked dimensions, row bytes, total bytes,
  and fully opaque alpha.
- `BeautyStillImageRequestContext` already owns the exact current canonical
  carrier and selected mapped observation on the stack and exposes aggregate
  support counts only.
- `BeautyEngine` already has an admitted still-image branch driven by an
  exact-empty production admission and opaque testing demand; pixel-buffer and
  reset paths are structurally separate.
- `BeautyColorEffectPipeline.apply(to: BeautyCanonicalStillImage, ...)` already
  receives the canonical carrier and explicit-sRGB render ownership after the
  single detect/map pass.

### Established Patterns

- `BeautyEffects` depends on `BeautyCore`, `BeautyDetection`, `BeautyRender`,
  and `BeautyResources`, making it the dependency-compatible owner for a
  feature-neutral local contribution/composition contract.
- Existing geometry providers fail closed per mapped support unit; the Phase 53
  lip carrier already proves malformed inner support need not erase valid outer
  support.
- Compatibility is locked by exact 59-field/CodingKey/default/preset inventory,
  unchanged no-admission output, renderer inventory, and facade regressions.
- Security and reliability owners require request-local sensitive support,
  aggregate-only diagnostics, typed/redacted errors, and safe-domain
  continuation.

### Integration Points

- Composition starts from `BeautyStillImageRequestContext.canonicalImage`; it
  must not canonicalize again or request/map Vision again.
- The feature-neutral result may feed the existing canonical still rendering
  handoff only under opaque test admission during Phase 55. Production remains
  on the unchanged legacy path until a later evidence-qualified feature exists.
- Contract changes belong in `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`,
  `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, and `PLANS.md`.

</code_context>

<specifics>
## Specific Ideas

- Reuse the wrapped Spike 012 invariant: source-pixel reads, explicit owner,
  post-feather hard re-clipping, unexpected overlap-to-source, and exact
  unaffected standalone outputs.
- Model the core around opaque units rather than candidate feature enums so
  Phase 55 cannot accidentally become a product-admission surface.
- `--auto` accepted the repository-backed recommendations above; no preference
  for a concrete mask algorithm or performance strategy was inferred.

</specifics>

<deferred>
## Deferred Ideas

- Teeth whitening algorithms, mapped-lip candidate growth, public field,
  provider, renderer/output evidence, and promotion belong to Phase 56 only if
  the independent teeth gate later passes; current closed input requires
  complete absence.
- Per-eye sclera scoring/transforms and conditional upper-eyelid work belong to
  Phase 57 only if their independent gates pass; otherwise exact absence is the
  deliverable.
- Combined public-facade output, repeated/parallel/canceled stress, final
  ledgers, and milestone closeout belong to Phase 58.
- Transparent/HDR/gain-map/multi-face policy, realtime/pixel-buffer local
  retouch, Demo UI, models/cloud, tracked media, device/performance budgets,
  packaging, shipping, launch, and release readiness remain outside v1.14.

</deferred>

---

*Phase: 55-original-pixel-composition-and-failure-isolation-core*
*Context gathered: 2026-08-03*
