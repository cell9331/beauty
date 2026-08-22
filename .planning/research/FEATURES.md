# Feature Research: v1.18 Upper-Eyelid Fullness Reduction

**Milestone:** v1.18
**Researched:** 2026-08-22
**Product posture:** Prove the effect first; expose it publicly only if all gates pass.

## Product Definition

“去脂” is defined as a cosmetic still-image effect that visually reduces upper-eyelid fullness while preserving identity, eyelid structure, eyebrow geometry, eye content, skin texture, and all pixels outside a conservative per-eye support. It is not fat measurement, anatomy inference, medical diagnosis, or a promise to reproduce a surgical procedure.

The public control is conditional. The milestone may finish successfully with the control absent when efficacy, safety, rights, or implementation gates fail.

## Table-Stakes Capabilities

| Capability | Expected behavior | Evidence |
|---|---|---|
| Exact effect semantics | A reviewer can distinguish reduced upper-eyelid fullness from whitening, smoothing, eye enlargement, crease creation, or generic reshaping | Written rubric plus genuine positive/negative review set |
| Per-eye support | Each eye is evaluated independently and unsupported eyes remain unchanged | Pixel-exact isolation tests and typed diagnostics |
| Conservative local edit | Only owned support pixels may change; protected eye, brow, crease, and exterior regions remain unchanged or within predeclared tolerances | Mask/geometry oracles and pixel diffs |
| Texture preservation | Original high-frequency skin detail survives the edit | Frequency/texture metrics plus blinded original-detail review |
| Negative no-op | Non-full, ambiguous, occluded, extreme-pose, or unsupported inputs fail closed | Negative bundle and adversarial fixtures |
| Determinism | Same input, state, and resources produce identical output | Repeated-render hashes and pixel equality |
| Compatibility | Default state stays neutral and existing state/case counts remain unchanged until promotion | ABI/state/case-count tests |
| Metadata integrity | Extent, orientation, mirror state, color space, and alpha contract remain correct | Generated input matrix and metadata assertions |

## Differentiators Worth Preserving

- Original-pixel color composition instead of local image reconstruction.
- Collision-to-source behavior when local masks overlap.
- Request-local mask ownership and no cross-request mutable state.
- Independent left/right failure rather than rejecting the whole face.
- A deterministic baseline that can be explained and tested without model opacity.
- An optional learned comparator that predicts only bounded additive deltas and is discarded unless it materially improves genuine positive cases without worsening negatives or protected areas.
- An exact “absence is the correct result” closeout branch when productization is not justified.

## Anti-Features

The milestone must not introduce:

- medical fat classification, anatomical diagnosis, or surgery simulation claims;
- public API placeholders that exist without a validated effect;
- inferred fullness from eye/brow landmarks alone;
- crease invention, eye enlargement, brow lifting, lid warping, or global skin smoothing;
- full-pixel generation, soft inpainting, or identity reconstruction;
- cloud inference, telemetry containing face-derived data, or persistent raw review artifacts;
- application/UI work, realtime/video support, transparent-input expansion, HDR/gain-map claims, or a new GPU API/backend;
- device, thermal, battery, commercial-quality, packaging, shipping, launch, or release-readiness claims.

## MVP Feature Set

### Required research/evaluation slice

1. Freeze semantics and quantitative safety/efficacy rubrics before viewing final results.
2. Build a rights-approved local bundle with genuine positives, negatives, ambiguous cases, protected-structure stress cases, and pose/identity diversity.
3. Implement a fail-closed per-eye support owner using one Vision request plus approved semantics.
4. Implement and tune the deterministic tone/frequency baseline.
5. Run automated metrics and blinded original-detail review.
6. Make a recorded promotion decision.

### Optional comparison slice

Evaluate a small additive blend-map model only when its model and data rights are already approved. It is not required to complete the milestone and cannot relax any baseline safety gate.

### Conditional product slice

If every gate passes:

- add exactly one default-zero SDK control and one supported effect route;
- preserve state migration, neutral identity, CPU/GPU selected-output parity, and all existing local-retouch ownership rules;
- update the effect taxonomy and public SDK documentation.

If any gate fails:

- keep the public field and route absent;
- retain only reusable test/evidence infrastructure that has independent value;
- record which gate failed and keep `eyes` classified as partial.

## Feature Dependencies

```text
Semantics + rights-approved bundle
              │
              ▼
Per-eye semantic support ──► deterministic editor ──► safety/efficacy review
              │                         │                         │
              └──────── fail closed ────┴──────────────┬──────────┘
                                                       ▼
                                           promotion / exact absence
```

## Research Implication

Public research provides useful lid segmentation, local tone-processing techniques, and additive retouch architectures, but no production-ready model was found that directly detects or reduces upper-eyelid fullness under a commercially safe license. The product feature therefore depends on owned evidence and a repository-specific safety contract, not on integrating an off-the-shelf repository.

---
*Research for v1.18 — upper-eyelid fullness reduction*
