# Spike Wrap-Up Summary

**Date:** 2026-07-29  
**Spikes processed:** 7  
**Feature areas:** upper-eyelid fullness, teeth whitening, sclera redness, still-image integration  
**Skill output:** `./.codex/skills/spike-findings-beauty/`

## Processed Spikes

| # | Name | Type | Verdict | Feature Area |
| --- | --- | --- | --- | --- |
| 001a | upper-lid-tone | comparison | `PARTIAL` — comparison winner | Upper-eyelid fullness |
| 001b | upper-lid-warp | comparison | `INVALIDATED` | Upper-eyelid fullness |
| 002a | teeth-vision-color | comparison | `PARTIAL` — safe, incomplete | Teeth whitening |
| 002b | teeth-coreml | comparison | `PARTIAL` — better mask, blocked | Teeth whitening |
| 003 | sclera-redness-mask | standard | `PARTIAL` — containment only | Sclera redness |
| 004 | local-color-retouch | standard | `PARTIAL` — transform only | Still-image integration |
| 005 | still-image-integration | standard | `VALIDATED` — isolated harness only | Still-image integration |

## Key Findings

- Do not activate `去脂`: tone/frequency is only a constrained future research
  seed, while the tested warp lost 7%–8% texture energy without clearer benefit.
- Teeth and sclera color transforms are bounded, texture-preserving, and changed
  zero pixels outside their masks in retained experiments.
- Deterministic Vision/color teeth masking is a fail-closed baseline but misses
  darker side teeth. EasyPortrait improved coverage but is blocked by its
  unapproved license/conversion chain, cold load, and resource cost.
- Eye-contour plus pupil/iris exclusion is the correct sclera foundation, but
  real redness positives, occlusions, blink, pose, contacts, and lighting remain
  product gates.
- The proven integration pattern is one still-image Vision request, private
  request-local masks, independent regional degradation, one bounded composite,
  and aggregate-only logs.
- Production implementation remains blocked on licensed real positive/negative
  fixtures and an owned or explicitly approved teeth mask provider. No v1.14
  milestone, public API, camera path, or device-performance claim is authorized.

## Generated Blueprint

Future planning and implementation conversations should load
`spike-findings-beauty`. Its four references contain feature-specific build
steps, rejected paths, hard constraints, measured baselines, privacy rules, and
links to preserved source.
