---
phase: 60
slug: teeth-provider-and-production-integration
status: complete
researched: 2026-08-07
confidence: high
---

# Phase 60: Teeth Provider and Production Integration - Research

## Summary

No new dependency or model is needed. The repository already owns the hard
parts of the production boundary: one normalized canonical RGBA8 carrier, one
Vision landmarks request, actual mapped request-local inner/outer lip support,
one stack-local request context, and an immutable-original composition owner.
Phase 60 should add one package-only teeth provider in `BeautyEffects` and one
small facade connection in the admitted still-image route.

The shared retouch lab supplies a mechanics blueprint, not a production oracle.
Its safe shape is reusable: fixed inner-aperture seeds, connected adaptive
growth inside a vertically clipped outer-lip envelope, post-blur hard re-clip,
baseline retention, material-yellow gating, and bounded source-derived RGB.
The previously authorized positive/negative pair and accepted visual
calibration allow the implementation to be checked privately without tracking
media or intake details.

## Requirement mapping

| Requirement | Implementation evidence |
| --- | --- |
| TEETH-09 | Provider accepts only both actual mapped lip arrays from the current request; exact one-request facade tests reject missing/malformed/closed/unsafe support. |
| TEETH-10 | Fixed baseline plus seed-connected adaptive selection with local Otsu/percentile limits and no synthetic seeds. |
| TEETH-11 | Separate hard envelope and soft mask, post-blur re-clip, final `max(adaptive, fixed)`, and aggregate zero-dropped-baseline proof. |
| TEETH-12 | Deterministic protected-color/mouth challenge matrix, explicit owned-union byte checks, and private reviewed-mask containment. |
| TEETH-13 | Pure source-pixel transform tests for yellow reduction, capped luminance/channel movement, alpha/detail preservation, and exact neutral no-op. |
| TEETH-14 | Deterministic no-face/missing/closed/occluded/already-light abstention, recovery matrix, and private authorized positive/negative aggregate checks. |

## Production design

### Provider boundary

Use a package-only, stateless provider under `BeautyEffects`. Its input should
be the exact `BeautyCanonicalStillImage`, current `BeautyObservedLipSupport`,
normalized public strength, and current `BeautyLocalRetouchCompositionOwner`.
Its output is optional: either one owner-issued unit plus an aggregate-only
summary, or local abstention. It must not return a public mask or accept a
second raster.

The provider should validate all checked pixel-count arithmetic before dense
scratch allocation. Lip arrays must be finite, unit-bounded, unique enough for
a polygon, simple, nested, and non-collapsed. The inner aperture must have a
minimum pixel span and height/width ratio; the outer region must contain the
inner region without becoming a whole-face envelope.

### Mask pipeline

1. Rasterize an unfeathered inner polygon and a separate unfeathered outer
   polygon using pixel centers.
2. Clip the outer polygon to the inner aperture's vertical band: a 5% upper
   safety inset (at least one pixel) and a 10% lower extension (at least one
   pixel).
3. Score the fixed inner baseline with conservative luminance, neutrality,
   blue-floor, and red-imbalance terms. Reject strong area below 1.5% or above
   94% of the inner region.
4. Use only fixed pixels above 0.15 that also fall in the adaptive region as
   seeds. Compute local Otsu luminance and seed percentiles, then score
   brightness/chroma/balance candidates.
5. Flood eight-connected candidates from seeds. Blur one pixel, re-clip to the
   adaptive hard region, take the maximum with the inner-clipped fixed mask,
   and prove final strong count never falls below fixed strong count.
6. Convert effective soft weights to Q16 proposals only for pixels inside the
   final hard union and only when the bounded transform returns a changed
   source-derived target.

The provider may abstain after any failed invariant. It must not relax geometry
or area constraints to obtain visible work.

### Transform

The accepted prior calibration is the starting production behavior:

- maximum effective transform scale `0.62 * normalizedStrength`;
- yellow excess `(r + g) / 2 - b`;
- smooth material-yellow gate from `0.08` to `0.14`;
- small red/green lift `0.018 * local`;
- blue correction `yellowExcess * 1.45 * local`;
- target luminance capped at `min(0.94, original + 0.045 * local)`.

Targets must be rounded deterministically to RGBA8, while the existing
composition owner applies the soft mask exactly once as final Q16 weight from
the immutable source and keeps source alpha. The target function therefore
uses request strength but does not multiply by mask weight itself.
Neutral/already-light/lightly-warm inputs remain exact no-ops.
These are bounded implementation constants for this phase, not population or
commercial calibration claims.

### Facade integration

The admitted branch currently canonicalizes, detects/maps, creates the request
context, optionally composes Testing-only opaque units, and renders. Replace
the Testing-only composition fork with one owner per admitted request:

- ask the production provider for its optional unit only when direct normalized
  teeth intent is positive;
- append any existing opaque Testing-only units to the same owner solely for
  feature-neutral composition tests;
- compose once even when all providers abstain;
- render unrelated color/geometry from the resulting canonical carrier.

This preserves one canonicalizer, one detector request, one mapper pass, one
request context, and one composition. Pixel-buffer and reset paths remain
structurally separate.

## Verification strategy

### Deterministic tests

- Polygon and support preflight: missing peer, non-finite, outside-unit,
  duplicate, self-intersecting, non-nested, collapsed, closed, and oversized.
- Baseline/adaptive: accepted baseline, connected side growth, disconnected
  lookalike rejection, no synthetic seeds, zero dropped strong baseline,
  post-blur hard re-clip, and area bounds.
- Protected tissue: red/pink lip, tongue, gum, dark/metallic brace, facial hair,
  and skin sentinels remain byte-identical; only known yellow enamel pixels may
  change.
- Transform: exact neutral/light/warm no-op, yellow reduction, luminance/channel
  caps, monotonic strength, immutable-source target, alpha preservation, and
  deterministic output.
- Lifecycle: process/processResult, no-face, missing support, malformed support,
  already-light, valid-invalid-valid, independent/parallel/interrupted calls,
  unrelated color continuation, pixel-buffer/reset zero work, and no second
  Vision request.

### Private genuine checks

Use the existing fixed-output private evidence runner to inject the ignored
bundle path only into an opt-in XCTest child. Resolve fixture roles and asset
bindings from the private manifest in memory. Persist no locator or raw metric.
Freeze the following aggregate acceptance before execution:

- positive: at least one reviewed-mask pixel changes, mean yellow excess
  decreases, mean luminance increase is positive and no more than `0.03`,
  maximum channel delta is at most `48/255`, texture-energy ratio remains
  `0.85...1.15`, and zero changed pixel lies outside the reviewed mask;
- negative: zero outside-mask change, mean absolute RGB delta at most `0.012`,
  mean luminance delta at most `0.006`, texture-energy ratio remains
  `0.85...1.15`, and alpha/dimensions remain exact;
- both: one canonical Vision request, no network/model/persistence path, and
  fixed-output pass/fail reporting only.

If platform Vision cannot execute, the gate is blocked rather than skipped.

## Security and privacy

The static checker should scan the complete production Swift boundary and
reject a second Vision request, face-box/synthetic lip fallback, provider cache,
raw geometry diagnostics, public/SPI/Codable masks, output-derived transforms,
pre-feather-only containment, global/realtime activation, sclera/`去脂`, model,
network, Demo activation, and private locator leakage. Mutation self-tests and
isolated HIGH modes must prove each class fails closed.

## Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| Coarse Vision lips include protected tissue | Conservative color baseline, connected growth only, narrow vertical envelope, post-filter hard re-clip, and protected sentinel tests. |
| Wide smiles place side teeth outside inner polygon | Preserve fixed inner baseline and add only seed-connected candidates within the clipped outer envelope. |
| Already-light teeth are overprocessed | Material-yellow gate and exact source-target no-op before proposal issuance. |
| Provider work contaminates legacy effects | One optional unit, original-pixel composer, local abstention, and unrelated color continuation tests. |
| Request state leaks or becomes stale | Stateless provider, stack-local arrays, valid-invalid-valid/parallel/interrupted tests, and no caches. |
| Private evidence leaks | Existing fixed-output runner, ignored media, aggregate-only assertions, tracked/staged privacy scan. |
| Phase 60 is mistaken for promotion | Keep Demo/output ledger unchanged; Phase 61 owns independent facade-output verification and promotion. |

## No new external research dependency

Planning relies on compiled repository contracts, Phase 59 evidence, the
archived Phase 53/55 foundation, and the local spike references. No current web
fact or third-party package decision is required.
