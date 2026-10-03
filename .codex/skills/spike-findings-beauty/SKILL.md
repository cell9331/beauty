---
name: spike-findings-beauty
description: Implementation blueprint from beauty's local-retouch spike experiments. Auto-load when planning or implementing still-image upper-eyelid fullness, teeth whitening, guarded sclera redness reduction, normalized EXIF/color-space input, transparent-input handling, request-local masks, original-pixel color composition, fail-closed mask ownership, Vision/Core ML integration, privacy-safe diagnostics, adversarial safety oracles, or their model/license and real-fixture gates.
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

Spike sessions wrapped: 2026-07-29 (001a–005, then 006/009/010); 2026-07-30 (011, 012, and 013 appends)

The current owner policy in `docs/IMAGE_EFFECT_ACCEPTANCE.md` supersedes the
spikes' old requirement for genuine human photographs. Authorized generated
portrait positives and negatives can complete an SDK effect qualification if
their own frozen direction, protection, visual/pixel, and metadata oracle passes.
Spike results and their original fixture outcomes remain historical.
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
- The old AI-generated spike fixtures proved only the checks they actually ran.
  New authorized generated portraits can provide full positive/negative effect
  evidence; genuine photos are optional. Review output at original detail when
  the effect claim requires visual judgment.
- The EasyPortrait Core ML port is research-only until the original data, checkpoint, conversion, and redistribution licenses are independently approved and pinned.
- Current `去脂` status is `suspended` (2026-10-01): default discovery/batches
  hide it, while the scalar and explicit calls retain compatibility. Natural-
  appearance effect qualification has failed. Do not treat the 2026-08-25
  provisional acceptance or this spike recipe as a current effect claim or
  instruction to continue research. Restart requires an explicit owner request
  and a new testable approach under `docs/IMAGE_EFFECT_ACCEPTANCE.md`.
- API compatibility, mechanical safety and effect qualification are separate
  evidence categories. A luminance proxy does not establish eyelid fullness;
  neither more tests nor safer output alone establishes useful effect.
</requirements>

<findings_index>
## Feature Areas

| Area | Reference | Key Finding |
| --- | --- | --- |
| Upper-eyelid fullness | `references/upper-eyelid-fullness.md` | Historical tone/frequency safety findings; current去脂 is suspended and hidden by default, with explicit API compatibility only. No automatic improvement task. |
| Teeth whitening | `references/teeth-whitening.md` | Seeded adaptive growth improves side-tooth mechanics without dropping the fixed baseline, but licensed protected-tissue review remains mandatory. |
| Sclera redness | `references/sclera-redness.md` | Guard each eye before scoring, feather then re-clip to the hard envelope, and verify the final transform with a color-adversarial oracle; generated positive/negative effect calibration is eligible. |
| Still-image integration | `references/still-image-integration.md` | Normalize orientation/color once before Vision and rendering, detect once, fail locally, preserve hard containment, derive every accepted edit from the original pixel under one explicit mask owner, reject unexpected overlap, and use bounded—not topology-identical—cross-profile criteria. |
| Licensed fixture evaluation | `references/licensed-fixture-evaluation.md` | Historical reviewer required a complete approved bundle; current generated-image effect acceptance can use an equivalent feature-specific oracle without a genuine-human requirement. |

## Source Files

Original spike READMEs, review tools, and the external-model audit are preserved
in `sources/<spike-id>-<name>/`. The current exact shared Swift package is in
`sources/shared-retouch-lab/`; local review sources are under their owning spike
directories. The current harness includes 24 deterministic self-tests.
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
- 011-guarded-sclera-color-integration
- 012-guarded-local-retouch-composition
- 013-normalized-input-local-retouch
</metadata>
