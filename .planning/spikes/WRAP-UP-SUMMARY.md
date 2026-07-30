# Spike Wrap-Up Summary

**Date:** 2026-07-30

**Spikes processed:** 13 total; 1 added in this append

**Feature areas:** upper-eyelid fullness, teeth whitening, sclera redness, still-image integration, licensed fixture evaluation

**Skill output:** `./.codex/skills/spike-findings-beauty/`

## Processed Spikes

| # | Name | Type | Verdict | Feature Area |
| --- | --- | --- | --- | --- |
| 001a | upper-lid-tone | comparison | `PARTIAL` — comparison winner | Upper-eyelid fullness |
| 001b | upper-lid-warp | comparison | `INVALIDATED` | Upper-eyelid fullness |
| 002a | teeth-vision-color | comparison | `PARTIAL` — safe, incomplete | Teeth whitening |
| 002b | teeth-coreml | comparison | `PARTIAL` — better mask, blocked | Teeth whitening |
| 003 | sclera-redness-mask | standard | `PARTIAL` — static containment only | Sclera redness |
| 004 | local-color-retouch | standard | `PARTIAL` — transform only | Still-image integration |
| 005 | still-image-integration | standard | `VALIDATED` — isolated harness only | Still-image integration |
| 006 | licensed-fixture-review-gate | standard | `PARTIAL` — gate works, real fixtures absent | Licensed fixture evaluation |
| 009 | adaptive-teeth-mask | standard | `PARTIAL` — mechanics coverage winner | Teeth whitening |
| 010 | sclera-jitter-envelope | standard | `VALIDATED` — bounded safety grid only | Sclera redness |
| 011 | guarded-sclera-color-integration | standard | `VALIDATED` — bounded final-output grid only | Sclera redness / still-image integration |
| 012 | guarded-local-retouch-composition | standard | `VALIDATED` — composition semantics only | Still-image integration |
| 013 | normalized-input-local-retouch | standard | `PARTIAL` — EXIF/alpha mechanics pass; exact cross-profile topology fails | Still-image integration |

## Key Findings

- Do not activate `去脂`: tone/frequency remains a constrained research seed,
  while the tested warp lost 7%–8% texture energy without clearer semantic gain.
- The deterministic teeth path no longer ends at the coarse `innerLips` polygon.
  Fixed-mask-seeded growth inside a narrow outer-lip-contained envelope added
  57.0% and 74.2% strong coverage on two mechanics smiles, dropped zero fixed
  pixels, and kept closed/no-face failure. Full outer-lip growth was rejected
  after visibly selecting upper lip.
- The EasyPortrait candidate still provides a learned comparison, not a
  redistributable dependency; license/conversion, cold load, memory, and
  lifecycle ownership remain blocked.
- The original sclera pupil circle is unsafe under landmark uncertainty even
  when its final color mask looks clean. It entered protected iris in 118/120
  scenarios per fixture. A per-eye aspect/pupil guard plus inflated exclusion
  produced zero iris/highlight leakage across 360 scenarios, but failed closed
  in 270 and retained only 28.6%–32.2% of baseline geometric eligibility.
- The `0.30 / 0.14` sclera values are calibration seeds, never product constants.
  Licensed open/partial/blink, gaze, glasses/contacts, iris-color, pose,
  demographic, lighting, and real redness review is still required.
- The guarded sclera color path now has an end-to-end ordering: validate each
  eye, build the hard envelope, score color inside it, feather, re-clip to the
  same hard envelope, then apply the bounded transform. Across 360 native plus
  360 color-adversarial eye-scenarios it changed zero protected iris/highlight
  pixels; the legacy adversarial path leaked in 356/360. The guard still failed
  closed in 270/360 stress scenarios and retained only 24.6%–38.2% of the legacy
  color mask, so product coverage and threshold calibration remain open.
- Adaptive teeth and guarded sclera can share one request-local composition
  path without hidden ordering or failure coupling. On e6/e2/e3 the fused
  original-pixel output byte-matched independent standalone and sequential
  oracles, changed zero pixels outside the union or protected iris/highlights,
  and matched all teeth/whole-sclera/left-eye/right-eye failure expectations.
  Injected cross-mask collisions retained the original pixel. The tested CPU
  loop was 2.6–3.1× slower than sparse sequential loops, so this validates
  ownership semantics—not performance, memory, or a device budget.
- The encoded-input handoff now has one tested owner: validate EXIF/RGB
  metadata, orient and color-manage once into up-oriented sRGB RGBA8, then give
  the same pixels to Vision with `.up` and to rendering. Across e6/e2/e3, all
  24 lossless orientation/mirror cases byte-matched input, anchors, masks,
  alpha, and output. This is an exact orientation contract, not a claim about
  every image format.
- Exact mask identity across color-profile or background variants is a rejected
  assumption. A one-byte Display-P3 round-trip difference moved Vision anchors
  by 0.53–1.56 px and created 8/15/76 topology differences; transparent borders
  moved anchors by 0.77–4.89 px. Fixed-anchor oracles reduced P3 topology drift
  to 3/0/11 and alpha drift to zero, isolating detector sensitivity as the
  larger contributor. Product acceptance needs bounded containment/output
  stability and a declared composite-or-reject alpha policy.
- The offline review gate distinguishes `mechanics_only` from
  `approved_internal_evaluation`, requires complete positive/negative assets,
  and exports structured judgments without media, paths, rights records,
  geometry, or freeform text. Its pure core passes 9/9 checks, but no licensed
  real bundle has opened the product gate.
- The shared still-image pattern is: normalize orientation/color once, apply a
  declared transparent-input policy, issue one Vision request, keep private
  request-local support/masks, independent regional/eye failure, hard
  containment restored after filtering, one original-pixel owner per edit,
  fail-closed unexpected overlap, aggregate-only events, and no camera/pixel-
  buffer inference.
- No v1.14 milestone, public API, production source, model/weight, or device-
  performance claim is authorized by these findings.

## Generated Blueprint

Future planning and implementation conversations should load
`spike-findings-beauty`. Its five references now contain:

- the unchanged upper-eyelid landmine and constrained research seed;
- the adaptive deterministic teeth recipe plus rejected full-envelope path;
- the mandatory sclera jitter guard, post-feather hard clip, and complementary
  color-independent plus adversarial final-output safety oracles;
- the still-image integration/privacy boundary and per-eye failure ownership;
- the original-pixel composition recipe, byte-level oracles, overlap rejection,
  and explicit CPU performance nonclaim;
- the canonical EXIF/color normalization recipe, fixed-anchor sensitivity
  oracle, bounded cross-profile acceptance, and unresolved alpha/HDR/device
  boundaries;
- the rights-approved local fixture manifest, blind-review, and sanitized-export
  gate required before product planning.

Exact source for Spikes 006/009/010/011/012/013 and the current 23-test Swift
harness is preserved under the skill's `sources/` tree without media, model
weights, or build artifacts.
