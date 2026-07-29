---
name: spike-findings-beauty
description: Implementation blueprint from beauty's local-retouch spike experiments. Auto-load when planning or implementing still-image upper-eyelid fullness, teeth whitening, sclera redness reduction, request-local masks, bounded color transforms, Vision/Core ML integration, privacy-safe diagnostics, or their model/license and real-fixture gates.
---

<context>
## Project: beauty

This skill packages experiments that tested whether a local-first still-image
retouch foundation can support upper-eyelid fullness reduction (`去脂`), sclera
redness reduction (`祛红血丝`), and teeth whitening (`白牙`) without proxy
behavior. The experiments compared Apple Vision/color techniques with a
research-only Core ML candidate and measured protected-region leakage, texture,
luminance, privacy, latency, memory, and integration ownership.

Spike sessions wrapped: 2026-07-29
</context>

<requirements>
## Requirements

- Production source and public API remained unchanged during spiking; findings
  are inputs to planning, not authorization to add behavior.
- Results are limited to the still-image path. Do not infer realtime or
  pixel-buffer support.
- `去脂` means upper-eyelid fullness reduction, not eye-bag or dark-circle
  removal.
- `去脂` must not alias `eyeHeight`, `upperEyelidLift`, brow movement, or global
  smoothing.
- Missing, malformed, closed, blinking, occluded, or low-confidence support
  fails closed per region.
- Raw masks, landmarks, pupil positions, teeth geometry, and vein patterns are
  request-local and absent from public or persisted diagnostics.
- AI-generated fixtures prove mechanics only. Product-feasibility validation
  requires licensed real positive/negative fixtures and human review at
  original detail.
- The EasyPortrait Core ML port remains research-only until the original data,
  checkpoint, conversion, and redistribution licenses are independently
  approved and pinned.
- If only teeth whitening and redness reduction validate, keep `去脂` future
  and the eye branch partial in the next milestone.
</requirements>

<findings_index>
## Feature Areas

| Area | Reference | Key Finding |
| --- | --- | --- |
| Upper-eyelid fullness | `references/upper-eyelid-fullness.md` | Preserve the tone/frequency experiment only; reject the tested warp and do not ship `去脂` without real positives. |
| Teeth whitening | `references/teeth-whitening.md` | Bounded whitening works, but Vision/color coverage is incomplete and the better Core ML mask is license/cold-load blocked. |
| Sclera redness | `references/sclera-redness.md` | Eye-aperture plus pupil/iris exclusion is a sound local mask foundation; real redness coverage remains unproven. |
| Still-image integration | `references/still-image-integration.md` | Detect once, keep masks request-local, compose bounded transforms once, and log only aggregate metrics. |

## Source Files

Original spike READMEs and the external-model audit are preserved in
`sources/<spike-id>-<name>/`. The exact shared Swift package is preserved in
`sources/shared-retouch-lab/`; the local visual review source is under
`sources/005-still-image-integration/`.
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
</metadata>
