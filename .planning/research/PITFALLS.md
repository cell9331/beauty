# Pitfalls Research

**Domain:** Remaining face-shape geometry and local semantic regions
**Researched:** 2026-07-21
**Confidence:** HIGH

## Critical Pitfalls

### 1. Synthetic face-box geometry masquerades as observation

**Failure:** New controls pass against the adapter's current seven-point proxy although no real contour was mapped.
**Prevention:** Add actual private Vision contour/median-line payloads, validate them, and require observed-support fixtures for every new geometry row.
**Phase:** 45.

### 2. Existing fields are relabeled as remaining tools

**Failure:** `faceSlim`, `jawSlim`, `faceVShape`, or `chinLength` evidence is reused for smooth contour, cheekbone, double chin, or pointed chin.
**Prevention:** Seven new public values, named emissions, vector/locality comparisons, and active-source alias scans.
**Phase:** 45-48.

### 3. Person matte is mistaken for hairline or double-chin segmentation

**Failure:** A person/background mask is treated as a hair/skin boundary or submental fold.
**Prevention:** Require semantic fixture evidence for the exact support class; block promotion if the support source cannot distinguish it.
**Phase:** 45 and 47.

### 4. “Pro” silently becomes commercial behavior

**Failure:** Account, entitlement, payment, remote inference, or gated code appears merely because the reference row has a Pro badge.
**Prevention:** Use independent neutral `doubleChinRefinement` semantics; scan for commercial/network paths and keep pricing out of SDK behavior.
**Phase:** all, final gate in 49.

### 5. Region effects alter protected surroundings

**Failure:** Hairline warps eyes/eyebrows or double-chin refinement changes lips, neck clothing, background, or watermark.
**Prevention:** Fixed containment/extent/locality checks, mask confidence thresholds, bounded feathering, and exact no-op outside eligible regions.
**Phase:** 47-48.

### 6. Coordinate order and mirror direction reverse semantics

**Failure:** Temple/cheek sides or signed hairline direction flip under orientation/mirroring.
**Prevention:** One mapper boundary; canonical centerline/contour order; orientation/mirror tests; direct positive/negative output evidence.
**Phase:** 45 and 48.

### 7. Provider accounting claims unsupported work

**Failure:** Missing masks or empty vectors remain in effective strengths, totals, counts, warnings, or metrics because sibling face work exists.
**Prevention:** Named seven-field emissions/operations, preflight and post-scale sanitization, monotonic bounded convergence, and exact final-emission assertions.
**Phase:** 46-49.

### 8. Model/resource trust is deferred until the end

**Failure:** Implementation depends on an unlicensed, mutable, oversized, or runtime-downloaded asset.
**Prevention:** Make provenance, license, version, hash, package placement, supported platforms, and failure behavior Phase 45 exit criteria.
**Phase:** 45.

## “Looks Done But Isn’t” Checklist

- [ ] Exact 55-field model and legacy 48-field neutrality both pass.
- [ ] Actual observed contour/median line is used for every new geometry claim.
- [ ] Basic and refined double-chin controls produce distinct eligible behavior.
- [ ] Hairline positive/negative directions are direct, local, and mask-contained.
- [ ] Missing/malformed/reused/stale support degrades only dependent fields.
- [ ] All seven controls are isolated through the public facade and decoded output.
- [ ] Final totals/counts/scales equal provider-emitted work after removals.
- [ ] Raw supports, asset paths, model internals, and generated images do not leak.
- [ ] Exactly seven rows and branch-level `脸型` are promoted; no readiness overclaim is made.

## Sources

- [Apple `faceContour`](https://developer.apple.com/documentation/vision/vnfacelandmarks2d/facecontour) — exact cheek-to-chin boundary.
- [Apple person segmentation](https://developer.apple.com/documentation/vision/vngeneratepersonsegmentationrequest) — person/background matte scope and quality trade-off.
- `SECURITY.md` — local-first and resource-trust boundary.
- `.planning/milestones/v1.5-phases/28-*` — previous anti-alias and promotion requirements.
- v1.9-v1.11 provider/convergence evidence — prior failures and proven gating patterns.

---
*Pitfalls research for: Beauty v1.12 Face Shape Remaining Capabilities*
