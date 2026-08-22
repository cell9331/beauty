# Pitfall Research: v1.18 Upper-Eyelid Fullness Reduction

**Milestone:** v1.18
**Researched:** 2026-08-22

## Critical Pitfalls

### 1. Calling generic eyelid segmentation “fullness detection”

Public periorbital datasets define anatomical regions such as lid, iris, sclera, caruncle, and brow. They do not label cosmetic upper-eyelid fullness. A lid mask can constrain where an edit may occur but cannot establish that the requested condition exists.

**Prevention:** Freeze a separate fullness rubric and require genuine positive/negative evidence. Landmarks and lid segmentation are envelopes only.
**Phase:** semantics/evidence, then support ownership.

### 2. Shipping a semantic alias

Eye enlargement, crease deepening, brow lifting, whitening, smoothing, and local warping can make the eye area look different while failing the named effect. Such proxies create a misleading API even when screenshots look superficially favorable.

**Prevention:** Include alias-specific negatives and reviewer questions. The effect must reduce fullness without changing eye aperture, crease topology, brow geometry, or global skin texture.
**Phase:** semantics and blinded review.

### 3. Treating Vision landmarks as a classifier

Eye and eyebrow points vary with expression, makeup, occlusion, head tilt, and landmark quality. They cannot identify tissue fullness or a safe edit region by themselves.

**Prevention:** Use them only for envelopes, pose guards, and ownership association; require approved semantics and fail closed otherwise.
**Phase:** support owner.

### 4. Tuning on generated or non-genuine positives

Generated fixtures are excellent for containment and metadata but can accidentally encode the expected algorithm. They cannot prove that real upper-eyelid fullness is visibly reduced while identity and detail remain natural.

**Prevention:** Make a rights-approved genuine bundle mandatory and keep generated fixtures as safety oracles. Freeze thresholds before final evaluation.
**Phase:** evidence foundation.

### 5. Ignoring data and weight licenses

MIT inference code does not grant rights to its training data or published weights. CelebAMask-HQ, LaPa, CFD, FFHQR, and related datasets carry noncommercial, attribution, share-alike, or redistribution constraints that may be incompatible with a distributable SDK.

**Prevention:** Gate code, data, weights, derived artifacts, redistribution, and commercial use separately. Default to no model dependency.
**Phase:** evidence/model gate.

### 6. Mistaking pose or identity cues for fullness

Head tilt, eyelid crease anatomy, epicanthal folds, eye closure, expression, lashes, makeup, shadows, and demographic variation can dominate local appearance. A detector may learn identity or capture conditions instead of the target cue.

**Prevention:** Stratify positive/negative evidence, include paired or repeated-identity cases where rights allow, and require pose/occlusion negatives. Do not persist biometric descriptors.
**Phase:** bundle design and semantic evaluation.

### 7. Using warp or blur because it is easy to see

Strong geometry and smoothing produce obvious demos but damage texture and structure. The repository's vertical-warp spike already showed lower texture retention (`0.9305` and `0.9188`) without clearer target benefit.

**Prevention:** Keep geometry exact; edit bounded low-frequency tone and carry source high-frequency detail. Reject global smoothing.
**Phase:** editor implementation.

### 8. Reconstructing pixels with inpainting/generation

Soft inpainting and image-to-image retouch models can invent crease, lash, highlight, and identity details. Their output conflicts with exact outside-region and original-pixel ownership guarantees.

**Prevention:** Permit only source-derived tone/frequency deltas or a bounded additive map. Compose against the original source and route collisions to source.
**Phase:** editor and composer verification.

### 9. Selecting thresholds after seeing results

Post-hoc thresholds turn the final bundle into a tuning set and make the promotion decision impossible to audit.

**Prevention:** Version the rubric, tolerances, bundle taxonomy, and review protocol before candidate evaluation. Any later threshold change invalidates and reruns the decision.
**Phase:** evidence foundation.

### 10. Letting one eye authorize the other

Shared masks or whole-face confidence can edit an unsupported eye when only one eye is visible or semantically valid.

**Prevention:** Allocate support, confidence, reason codes, masks, and composition ownership independently per eye.
**Phase:** support/composition.

### 11. Claiming GPU or device readiness from simulator/CPU evidence

CPU correctness does not prove selected Metal output, device performance, thermal behavior, or production readiness.

**Prevention:** Keep CPU as oracle, verify selected-output parity through current SDK gates, and preserve explicit nonclaims. Do not add a backend or modify retained `Warp.metal`.
**Phase:** integration/closeout.

### 12. Persisting face-derived review material

Debug crops, masks, landmarks, fixture paths, and detailed per-image descriptors can leak private or biometric-like information into logs and milestone artifacts.

**Prevention:** Keep the bundle local; export only aggregate metrics, opaque fixture IDs, hashes, reason counts, and reviewer decisions.
**Phase:** all phases, audited at closeout.

## Failure Signals That Must Stop Promotion

- No rights-approved genuine positive bundle is available.
- Reviewers cannot reliably distinguish the effect from smoothing, whitening, crease editing, or eye enlargement.
- Any protected eye/brow/crease geometry changes outside tolerance.
- Texture preservation falls below the frozen threshold.
- Negative or ambiguous cases edit instead of failing closed.
- One eye's result affects the other eye's ownership or pixels.
- A required model lacks commercial/redistribution provenance.
- The candidate needs a public API, Metal change, or generative fallback before evidence passes.
- Sanitized evidence cannot reproduce the aggregate promotion result.

## Recovery Strategy

The safe recovery from any failed gate is exact absence: retain the public state and effect counts, keep the control undocumented and unreachable, record the failed requirement, and preserve only generic evidence/safety infrastructure that does not imply the feature exists.

---
*Research for v1.18 — upper-eyelid fullness reduction*
