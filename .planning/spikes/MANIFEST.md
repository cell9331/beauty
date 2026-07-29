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
