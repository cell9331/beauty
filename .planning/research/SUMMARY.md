# Research Summary: v1.18 Upper-Eyelid Fullness Reduction

**Milestone:** v1.18
**Researched:** 2026-08-22
**Recommendation:** Proceed, conditionally

## Executive Conclusion

The effect can be attempted responsibly, but it is not yet a proven product feature. The repository already has the right architectural foundation—canonical still-image input, one Vision request, request-local masks, original-pixel composition, per-region failure behavior, deterministic tests, and privacy-safe evidence—but public research does not provide a production-ready “upper-eyelid fullness reduction” model with suitable semantics and a clearly safe distribution path.

The best route is a gated vertical slice:

1. define the cosmetic effect and prohibited aliases precisely;
2. obtain a rights-approved genuine positive/negative bundle;
3. build per-eye semantic support that fails closed;
4. implement a deterministic tone/frequency editor that preserves source detail;
5. optionally compare a small licensed additive-map model;
6. promote exactly one public control only if every frozen efficacy, safety, privacy, rights, and compatibility gate passes.

If a gate fails, v1.18 still closes cleanly with the public control absent and `eyes` remaining partial.

## What the Research Established

### Strong evidence

- Periorbital segmentation can provide useful anatomical support regions, but published labels describe the lid rather than fullness.
- Local Laplacian and band-sifting work support controlled local tone/frequency manipulation without requiring pixel reconstruction.
- Additive blend maps are a plausible small-model architecture because they predict bounded color corrections rather than a replacement image.
- Apple Vision and Core ML can host the localization/inference path on supported platforms.
- The repository's tone/frequency spike preserves texture substantially better than its invalidated vertical-warp candidate.

### Unresolved evidence

- No public benchmark defines success for cosmetic upper-eyelid fullness reduction.
- No exact public model/repository with verified product-compatible data and weight rights was found.
- Genuine positive-case efficacy has not been demonstrated in this repository.
- Safe semantic support across pose, occlusion, makeup, crease anatomy, and identity variation remains unproven.

## Recommended Technical Shape

```text
Vision envelope + approved semantics
               │
               ▼
      conservative per-eye mask
               │
               ▼
 deterministic low-frequency tone correction
   + original high-frequency detail carry
               │
               ▼
 original-pixel, collision-safe composition
               │
               ▼
 automated metrics + blinded genuine review
               │
       pass ───┴─── fail
        │             │
 public control   exact absence
```

The optional learned branch is a comparator, not a dependency. It may proceed only with owned/licensed model provenance and must outperform the deterministic baseline under the same frozen rubric.

## Proposed Phase Structure

| Phase | Outcome | Promotion dependency |
|---|---|---|
| 75. Semantics and Evidence Contract | Effect definition, prohibited aliases, frozen thresholds, rights-approved bundle manifest, sanitized review protocol | Mandatory |
| 76. Per-Eye Support Ownership | One-request Vision context, semantic support adapter, pose/ambiguity guards, independent fail-closed results | Mandatory |
| 77. Deterministic Editor | Tone/frequency candidate, exact geometry/alpha, texture retention, original-pixel local composition | Mandatory |
| 78. Genuine Evaluation and Candidate Decision | Automated bundle gate, blinded review, optional additive comparator, signed aggregate decision | Mandatory |
| 79. Conditional Productization and Closeout | Passing branch adds one control/route and compatibility proof; failing branch proves exact absence | Mandatory |

## Non-Negotiable Gates

- Product semantics are cosmetic and do not claim fat measurement or diagnosis.
- The genuine bundle has approved rights and covers positives, negatives, ambiguity, pose, identity, and protected structures.
- Unsupported eyes are exact no-ops; one eye cannot authorize another.
- Pixels outside owned support are source-exact; protected structures and texture meet frozen tolerances.
- Results are deterministic and preserve canonical metadata.
- Persistent evidence contains no raw images, masks, landmarks, private paths, or biometric-like descriptors.
- Existing public state/effect counts remain unchanged until promotion.
- No new app/UI, realtime/video, transparent-input, HDR/gain-map, Metal/backend, device, commercial, packaging, shipping, launch, or release-readiness claim enters scope.

## Source Highlights

- [Periorbital semantic segmentation dataset](https://pmc.ncbi.nlm.nih.gov/articles/PMC12417369/) — useful region taxonomy; not a fullness label.
- [Eyelid Fold Consistency](https://arxiv.org/abs/2410.13760) — reinforces identity/diversity sensitivity around eyelid folds.
- [Head-tilt confound study](https://pmc.ncbi.nlm.nih.gov/articles/PMC8830303/) — supports explicit pose controls in appearance judgments.
- [Local Laplacian filters](https://people.csail.mit.edu/sparis/publi/2011/siggraph/) and [band-sifting filters](https://www.cs.cornell.edu/projects/band_sifting_filters/) — basis for bounded local tone/frequency work.
- [Lightweight Additive Blend Maps](https://ojs.aaai.org/index.php/AAAI/article/view/41481) — plausible optional delta-map architecture, not direct evidence for this effect.
- [CelebAMask-HQ](https://github.com/switchablenorms/CelebAMask-HQ), [LaPa](https://github.com/jd-opensource/lapa-dataset), and [FFHQR](https://github.com/skylab-tech/ffhqr-dataset) — useful research references with licensing/label limitations that prevent casual SDK adoption.
- [AniEyelid](https://github.com/StoryMY/AniEyelid) and [RetouchFormer](https://github.com/Davidcoach/RetouchFormer_AAAI_24) — adjacent techniques, not selected product dependencies.

## Confidence

| Area | Confidence | Reason |
|---|---|---|
| Architectural fit | High | It follows already-validated local-retouch ownership and normalization contracts |
| Deterministic editor feasibility | Medium-high | Strong synthetic spike behavior, but no genuine efficacy gate yet |
| Semantic support feasibility | Medium | Anatomical localization exists; exact fullness semantics require owned evidence |
| Off-the-shelf model suitability | Low | No exact, clearly licensed model/weights found |
| Productization | Conditional | Depends on genuine bundle results and frozen review gates |

## Final Recommendation

Start v1.18 as a conditional productization milestone. Do not promise the control in advance. Treat the genuine evidence bundle and the per-eye fail-closed support owner as the critical path; treat the deterministic tone/frequency implementation as the default candidate; and make exact public absence an explicitly successful closeout branch.

---
*Research for v1.18 — upper-eyelid fullness reduction*
