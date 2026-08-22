---
phase: 75
artifact: semantic-contract
version: 1
status: frozen
authority: phase-owned-evidence-only
security_standard: OWASP ASVS Level 1
---

# Phase 75 Semantic Contract

This is the sole Phase-75 authority for the meaning of upper-eyelid fullness
reduction. It describes a cosmetic still-image visual outcome and does not
authorize a production SDK surface. Productization remains conditional on the
later evidence, safety, and implementation gates; exact public absence is the
correct result when those gates do not pass.

## Canonical definition

The target is a reviewer-recognizable visual reduction of upper-eyelid fullness
within a conservative, per-eye still-image support. The observation must remain
cosmetic and visual: it must not be translated into tissue composition,
anatomical status, health status, diagnosis, or a surgical result.

The positive review asks whether the upper-eyelid appearance is visually less
full while eye content, lid/crease and lash structure, eyebrow geometry,
identity detail, local texture, and exterior pixels remain preserved. The
negative review asks whether the target is absent, ambiguous, unsupported, or
confounded by pose, occlusion, expression, makeup, crease form, lighting, or
capture quality; those cases must be an exact no-op.

<!-- CANONICAL_RECORDS_BEGIN -->
```json
{
  "version": 1,
  "effect": {
    "id": "upper-eyelid-fullness-reduction",
    "medium": "still-image",
    "intent": "cosmetic-visual-reduction-of-upper-eyelid-fullness",
    "authority": "visual-review-only"
  },
  "landmark_role": "envelope-and-pose-guard-only",
  "nonclaims": [
    "physical-fat",
    "anatomy",
    "health",
    "diagnosis",
    "surgical-outcome"
  ],
  "predicates": {
    "authorization_inputs": [
      "approved-semantic-evidence",
      "visual-fullness-reduction",
      "protected-structure-preserved"
    ],
    "observations_without_authority": [
      "landmark-only",
      "brow-only",
      "eye-aperture-only",
      "crease-only",
      "texture-only",
      "color-only"
    ],
    "ambiguous_outcome": "exact-no-op"
  },
  "prohibited_proxies": [
    {
      "id": "smoothing",
      "negative": {
        "accepts": false,
        "reason": "proxy.smoothing"
      }
    },
    {
      "id": "whitening",
      "negative": {
        "accepts": false,
        "reason": "proxy.whitening"
      }
    },
    {
      "id": "eye-enlargement",
      "negative": {
        "accepts": false,
        "reason": "proxy.eye-enlargement"
      }
    },
    {
      "id": "brow-movement",
      "negative": {
        "accepts": false,
        "reason": "proxy.brow-movement"
      }
    },
    {
      "id": "crease-invention",
      "negative": {
        "accepts": false,
        "reason": "proxy.crease-invention"
      }
    },
    {
      "id": "upper-eyelid-lift",
      "negative": {
        "accepts": false,
        "reason": "proxy.upper-eyelid-lift"
      }
    },
    {
      "id": "warp",
      "negative": {
        "accepts": false,
        "reason": "proxy.warp"
      }
    }
  ],
  "protected_structures": [
    "eye-content",
    "lash-and-crease-structure",
    "brow-geometry",
    "identity-detail",
    "exterior-pixels"
  ]
}
```
<!-- CANONICAL_RECORDS_END -->

## Roles and boundaries

- Vision eye and eyebrow landmarks may define a conservative envelope, associate
  support with one eye, and reject implausible pose or occlusion. They cannot
  establish fullness, infer tissue, or authorize an edit by themselves.
- A lid, eye-aperture, crease, or texture observation may constrain a later
  owner, but none is a semantic classifier. Color-only evidence is likewise
  insufficient and cannot be promoted through a visual alias.
- A qualified result must preserve the protected structures listed in the
  canonical record. Implementations must retain raw geometry, pixels, masks,
  landmarks, and fixture locators only in request-local/private evaluation
  scope; durable evidence is aggregate-only.
- Generated or mechanics-only fixtures can test containment, determinism,
  metadata, and failure mechanics. They cannot establish genuine fullness or
  satisfy the evidence gate.

## Review and handoff

Reviewers use fixed positive/negative predicates and the seven independent
proxy questions before any candidate result can be considered. An ambiguous,
unsupported, or proxy-shaped observation returns the typed semantic outcome
`semantic_gate_failed` and exact no-op. Changing any canonical record requires
a new version and invalidates downstream evidence; there is no post-result
threshold tuning.

Semantic qualification is an evidence-plane result only. It never creates a
BeautyParameters field, renderer case, preset, route, resource, dependency,
provider, production output, Testing SPI, or public documentation claim.

## Nonclaims

This contract makes no claim about device performance, population coverage,
commercial visual approval, model quality, physical-device behavior,
packaging, shipping, launch, or release readiness. No genuine efficacy claim
exists without the separate rights-approved bundle and blinded review contract.

