# Spike Manifest

## Idea

Determine whether a local-first, still-image retouch foundation can support
three proposed v1.14 capabilities without proxy behavior: upper-eyelid
fullness reduction (`去脂`), sclera redness reduction (`祛红血丝`), and teeth
whitening (`白牙`). The spikes compare deterministic Apple Vision/color
techniques with a research-only Core ML segmentation candidate, then measure
protected-region leakage, visible output, privacy, and integration cost.

## Requirements

- Production source and public API remain unchanged during spiking.
- Results are limited to the still-image path; no realtime/pixel-buffer claim.
- `去脂` means upper-eyelid fullness reduction, not eye-bag or dark-circle removal.
- `去脂` must not alias `eyeHeight`, `upperEyelidLift`, brow movement, or global smoothing.
- Missing, malformed, closed, blinking, occluded, or low-confidence support fails closed per region.
- Raw masks, landmarks, pupil positions, teeth geometry, and vein patterns are request-local and absent from public or persisted diagnostics.
- Existing AI-generated fixtures can prove mechanics only. Product-feasibility validation requires licensed real positive/negative fixtures and human original-detail review.
- The EasyPortrait Core ML port is research-only until the original data, checkpoint, conversion, and redistribution licenses are independently approved and pinned.
- If only teeth whitening and redness reduction validate, the next milestone must keep `去脂` future and the eye branch partial.

## Spikes

| # | Name | Type | Validates | Verdict | Tags |
| --- | --- | --- | --- | --- | --- |
| 001a | upper-lid-tone | comparison | Given an upper-lid band, when low-frequency luminance variation is compressed, then eyelid fullness appears reduced without moving protected geometry. | PARTIAL ⚠ — comparison winner; real positive fixtures absent | eyelid, deterministic, still-image |
| 001b | upper-lid-warp | comparison | Given the same band, when pixels redistribute inside fixed eye/brow boundaries, then the result is distinct from eye-opening geometry and remains natural. | INVALIDATED ✗ — texture loss without clearer semantic gain | eyelid, warp, still-image |
| 002a | teeth-vision-color | comparison | Given actual Vision inner-lip support, when color-gated candidates are extracted, then teeth are isolated without leaking into lips, tongue, gums, or skin. | PARTIAL ⚠ — safe/fail-closed; side-tooth coverage incomplete | teeth, vision, deterministic |
| 002b | teeth-coreml | comparison | Given the same portraits, when the EasyPortrait Core ML teeth head runs locally, then its mask improves useful coverage without creating a redistributable-model claim. | PARTIAL ⚠ — mask winner; license/cold-load gate | teeth, coreml, license-gate |
| 003 | sclera-redness-mask | standard | Given actual eye contours and pupils, when sclera/redness candidates are extracted, then iris, lashes, skin, and specular highlights remain protected. | PARTIAL ⚠ — containment passes; real redness coverage unproven | eyes, redness, privacy |
| 004 | local-color-retouch | standard | Given accepted teeth and redness masks, when bounded chroma correction runs, then yellow/red excess falls while luminance and texture remain stable. | PARTIAL ⚠ — transform passes; product masks remain gated | color, compositing, safety |
| 005 | still-image-integration | standard | Given all accepted local work, when the combined pipeline repeats, then degradation, logs, latency, memory, and SDK ownership stay within the still-image boundary. | VALIDATED ✓ — isolated still-image harness only | integration, performance, privacy |
| 006 | licensed-fixture-review-gate | standard | Given licensed positive/negative fixtures with rights metadata, when a local blinded reviewer consumes before/mask/after assets, then coverage, protected leakage, and naturalness judgments export without media, paths, or sensitive geometry. | PARTIAL ⚠ — offline gate passes; no licensed real fixtures supplied | evaluation, fixtures, privacy, licensing |
| 009 | adaptive-teeth-mask | standard | Given wide smiles with darker side teeth, when adaptive local scoring and connected candidates are compared with the fixed Vision/color baseline, then useful coverage increases without lip/tongue/gum leakage and closed-mouth behavior remains fail-closed. | PARTIAL ⚠ — mechanics coverage wins; licensed protected-tissue review absent | teeth, deterministic, comparison, coverage |
| 010 | sclera-jitter-envelope | standard | Given perturbed pupil and eye-contour support including blink-like collapse, when sclera masks are recomputed across a deterministic scenario grid, then iris/highlight leakage remains zero or the affected eye fails closed before leakage. | VALIDATED ✓ — bounded grid safe; conservative coverage/calibration remains gated | sclera, safety, perturbation, privacy |
| 011 | guarded-sclera-color-integration | standard | Given Spike 010's per-eye guard and Spike 003/004 redness scoring and transform, when native and color-adversarial eye candidates are recomputed across the deterministic perturbation grid, then the final feathered mask and transform change zero protected iris/highlight pixels, fail closed per affected eye, and retain measurable redness candidates on accepted open eyes. | VALIDATED ✓ — final guarded transform safe on bounded grid; real coverage/calibration remains gated | sclera, integration, color, safety, privacy |
| 012 | guarded-local-retouch-composition | standard | Given Spike 009's adaptive teeth mask and Spike 011's guarded per-eye sclera masks, when both bounded transforms are composed once from the original image and region failures or mask overlap are injected, then the fused output byte-matches the disjoint standalone oracle, changes no pixel outside the sanitized union or protected eye regions, suppresses ambiguous overlap, and preserves every unaffected region. | VALIDATED ✓ — composition semantics pass; product evidence and optimized performance remain gated | integration, teeth, sclera, compositing, safety, privacy |
