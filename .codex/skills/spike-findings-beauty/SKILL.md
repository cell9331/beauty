---
name: spike-findings-beauty
description: Implementation blueprint from beauty's local-retouch spike experiments. Auto-load when planning or implementing still-image upper-eyelid fullness, teeth whitening, sclera redness reduction, request-local masks, bounded color transforms, Vision/Core ML integration, privacy-safe diagnostics, or their model/license and real-fixture gates.
---

<context>
## Project: beauty

This skill packages experiments that tested whether a local-first still-image
retouch foundation can support upper-eyelid fullness reduction (`去脂`), sclera
redness reduction (`祛红血丝`), and teeth whitening (`白牙`) without proxy
behavior. The experiments compared Apple Vision/color and adaptive deterministic
techniques with a research-only Core ML candidate, built a rights-gated local
review path, and measured protected-region leakage, landmark uncertainty,
texture, luminance, privacy, latency, memory, and integration ownership.

Spike sessions wrapped: 2026-07-29 (001a–005, then 006/009/010 append)
</context>

<requirements>
## Requirements

- Production source and public API remain unchanged during spiking.
- Results are limited to the still-image path; no realtime/pixel-buffer claim.
- `去脂` means upper-eyelid fullness reduction, not eye-bag or dark-circle
  removal.
- `去脂` must not alias `eyeHeight`, `upperEyelidLift`, brow movement, or global
  smoothing.
- Missing, malformed, closed, blinking, occluded, or low-confidence support fails closed per region.
- Raw masks, landmarks, pupil positions, teeth geometry, and vein patterns are request-local and absent from public or persisted diagnostics.
- Existing AI-generated fixtures can prove mechanics only. Product-feasibility validation requires licensed real positive/negative fixtures and human original-detail review.
- The EasyPortrait Core ML port is research-only until the original data, checkpoint, conversion, and redistribution licenses are independently approved and pinned.
- If only teeth whitening and redness reduction validate, the next milestone must keep `去脂` future and the eye branch partial.
</requirements>

<findings_index>
## Feature Areas

| Area | Reference | Key Finding |
| --- | --- | --- |
| Upper-eyelid fullness | `references/upper-eyelid-fullness.md` | Preserve the tone/frequency experiment only; reject the tested warp and do not ship `去脂` without real positives. |
| Teeth whitening | `references/teeth-whitening.md` | Seeded adaptive growth improves side-tooth mechanics without dropping the fixed baseline, but licensed protected-tissue review remains mandatory. |
| Sclera redness | `references/sclera-redness.md` | The original iris circle is unsafe under landmark jitter; use a per-eye fail-closed/inflated guard and calibrate its severe coverage tradeoff on real data. |
| Still-image integration | `references/still-image-integration.md` | Detect once, keep masks request-local, compose bounded transforms once, and log only aggregate metrics. |
| Licensed fixture evaluation | `references/licensed-fixture-evaluation.md` | Product evidence opens only for complete rights-approved positive/negative bundles reviewed locally with a sanitized structured export. |

## Source Files

Original spike READMEs, review tools, and the external-model audit are preserved
in `sources/<spike-id>-<name>/`. The current exact shared Swift package is in
`sources/shared-retouch-lab/`; local review sources are under their owning spike
directories.
</findings_index>

<metadata>
## Processed Spikes

- 001a-upper-lid-tone
- 001b-upper-lid-warp
- 002a-teeth-vision-color
- 002b-teeth-coreml
- 003-sclera-redness-mask
- 004-local-color-retouch
- 005-still-image-integration
- 006-licensed-fixture-review-gate
- 009-adaptive-teeth-mask
- 010-sclera-jitter-envelope
</metadata>
