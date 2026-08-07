# AI-SPEC — Phase 64: Sclera Output, Adversarial Safety, and Independent Closeout

> AI design contract generated for the active autonomous workflow. Phase 64
> evaluates the existing on-device Apple Vision-assisted deterministic pipeline;
> it adds no learned model, prompt, agent framework, service or network call.

## 1. System Classification

**System Type:** Hybrid deterministic on-device vision-assisted image pipeline

The public facade receives a still image and `scleraRednessReduction`. Existing
Apple Vision support is mapped once; deterministic guards and source-only color
composition produce the result. Phase 64 evaluates saved output, adversarial
anatomical containment and naturalness, then updates product status only on a
complete conjunction.

### Critical failure modes

1. Iris, pupil, highlight, lash, skin or aperture-exterior pixels are claimed or changed.
2. Native protected colors hide unsafe geometry until adversarial recoloring.
3. A normal eye is visibly whitened, flattened or recolored.
4. Private support, masks, pixels, paths or reviewer data escape local evaluation.
5. Product status advances on skipped, partial, synthetic or sibling evidence.

## 2. Framework Decision

Use the repository's existing native Vision detector and deterministic Swift
pipeline. Do not add or configure another model. The example renderer must
import only `BeautySDK` and invoke the same `BeautyEngine.processResult` path as
an SDK integrator.

## 3. Evaluation Dimensions

| Dimension | Required result | Method |
| --- | --- | --- |
| Public output | One exact active case, same dimensions/alpha, visible bounded positive change | Strict decoded six-output matrix |
| Geometry safety | Zero candidate overlap with protected truth under bounded support perturbations | Color-independent XCTest oracle |
| Final-output safety | Zero protected/exterior RGBA changes after the complete production path | Recolored-protected XCTest oracle |
| Per-eye isolation | Unsafe eye abstains while an accepted peer continues | Facade/provider challenge matrix |
| Naturalness | Positive improves; normal negative remains natural; texture and highlights remain | Frozen metrics plus original-detail review |
| Privacy | Only fixed aggregates and categorical review are durable | Fixed-output runner and tracked/staged scans |
| Lifecycle | Exact single-row promotion after all gates, then independent verification | Pre/post checker |

## 4. Dataset and Evidence Contract

- Product evidence: exactly one authorized ignored positive and one authorized
  ignored negative from the canonical Phase 62 bundle.
- Controls: one deterministic no-face input and synthetic challenge fixtures.
- Synthetic fixtures have zero product or naturalness weight.
- Private originals, masks and generated media never enter tracked artifacts.
- Durable evidence contains bounded counts, fixed decisions and reason codes only.

## 5. Frozen Acceptance

- Positive: nonzero reviewed-sclera change, reduced red excess in at least one
  reviewed eye, maximum channel delta at most 44, absolute mean luminance delta
  at most 0.018, texture ratio within 0.82...1.18, zero mask-exterior and alpha changes.
- Negative: mean absolute RGB delta at most 0.010, absolute mean luminance delta
  at most 0.006, texture ratio within 0.82...1.18, zero exterior and alpha changes.
- No face: active output byte-identical to baseline.
- Adversarial truth: exactly zero protected candidate overlap and exactly zero
  protected/exterior final RGBA changes.
- Visual contradiction overrides numeric success and blocks promotion.

## 6. Privacy, Safety and Fallback

No coordinates, pupils, masks, candidate colors, vein-like descriptors, image
bytes, fixture paths, digests, identity or reviewer data may be public, Codable,
persisted, logged, networked or tracked. Missing evidence, malformed output,
ambiguous roles, skipped native execution or any HIGH failure is terminal for
this phase. There is no retry that relaxes anatomy, score or acceptance bounds.

## 7. Nonclaims

Passing Phase 64 establishes the bounded still-image SDK-core standalone sclera
slice only. It does not establish population sufficiency, diagnosis/treatment,
Demo activation, realtime support, transparent/HDR/multi-face coverage, device
performance, commercial approval, packaging, shipping, launch or release readiness.
