# Architecture Research: v1.18 Upper-Eyelid Fullness Reduction

**Milestone:** v1.18
**Researched:** 2026-08-22

## Architectural Position

The feature should extend the existing still-image local-retouch pipeline without changing target direction, public GPU surface, retained `Warp.metal`, or the canonical input contract. The architecture must support a complete negative outcome: research and evidence can be accepted while the public control remains absent.

## Proposed Data Flow

```text
SDK request + image
        │
        ▼
canonical opaque sRGB RGBA8 input
        │
        ▼
one Vision face-landmark request
        │
        ▼
request-local face context
        │
        ├── left eye envelope ──► semantic support owner ──► candidate editor
        │
        └── right eye envelope ─► semantic support owner ──► candidate editor
                                            │
                                            ▼
                              bounded local color deltas
                                            │
                                            ▼
                         original-pixel collision-safe composer
                                            │
                          ┌─────────────────┴─────────────────┐
                          ▼                                   ▼
                    CPU reference                    Metal identity transport
                          └─────────────────┬─────────────────┘
                                            ▼
                               selected normalized output
```

The public SDK state and route appear upstream only after promotion. Before promotion, the implementation is reachable solely through SDK-owned evaluation/test seams.

## Component Responsibilities

### Canonical input boundary

- Reuse the existing normalized opaque sRGB RGBA8 contract.
- Reject unsupported transparent input through the current typed path.
- Preserve logical orientation, mirror behavior, pixel extent, output color metadata, and alpha.
- Do not move semantic interpretation into orientation-specific code.

### Shared Vision request

- Execute one face-landmark request per render request.
- Use eye and eyebrow landmarks only to form conservative candidate envelopes and pose checks.
- Do not convert geometry into a claim that fullness exists.
- Store derived data only in request-local context.

### Per-eye semantic support owner

The owner returns an independent result for each eye:

- supported with a conservative editable mask and confidence/rationale;
- unsupported/ambiguous with a typed local failure;
- unavailable because required semantic resources are absent.

It must reject support that intersects prohibited eye content, crosses the brow/crease safety geometry, exceeds containment bounds, or cannot be associated unambiguously with one eye. Failure on one eye must not authorize or erase the other eye.

### Candidate editor A: tone/frequency baseline

- Operate on luminance or a perceptually appropriate local tone component.
- Change the low-frequency fullness cue within conservative amplitude bounds.
- Reapply original high-frequency detail rather than synthesizing it.
- Emit a local color delta and ownership mask, not a replacement image.
- Keep geometry and alpha exact.

### Candidate editor B: additive model comparator

- Optional and isolated behind an internal protocol.
- Accept the same normalized crop/context and emit a bounded three-channel additive map plus validity.
- Require owned/licensed model and training/evaluation provenance.
- Never become a fallback that edits when support is ambiguous.
- Be removed or left unshipped if it does not outperform A under the frozen rubric.

### Original-pixel composer

- Start from source pixels.
- Apply deltas only where the selected request-local mask owns the pixel.
- Resolve collisions back to the source pixel.
- Guarantee exact source pixels outside support.
- Preserve the existing local-retouch CPU reference and Metal identity transport ownership model.

## Module Integration

| Existing area | v1.18 responsibility |
|---|---|
| `BeautyCore` | Internal state/evaluation types only until promotion; public state addition is conditional |
| `BeautyDetection` | Shared Vision context, conservative eye/brow envelopes, optional approved semantic inference adapter |
| `BeautyEffects` | Tone/frequency candidate and optional additive-map comparator |
| `BeautyRender` | Existing original-pixel composition, CPU oracle, selected-output handling |
| `BeautyResources` | Only approved, hashed, provenance-recorded local model resources if candidate B survives |
| `BeautySDK` | No public route until promotion; one field/route at most after all gates pass |
| Tests/renderer/scripts | Real-bundle gate, generated safety fixtures, sanitized summaries, exact absence/promotion assertions |

Dependencies must continue to point inward according to the current package architecture. No feature-specific shortcut may let the SDK facade own Vision requests, masks, model loading, or pixel algorithms.

## Evidence Plane

Runtime and evaluation artifacts must stay separate:

```text
private local fixtures ─► SDK-owned evaluator ─► aggregate metrics + fixture IDs
        │                         │                          │
        └── never persisted ─────┴── masks/landmarks ──────┘
```

The evidence plane should contain:

- a rights/provenance manifest and fixture taxonomy;
- frozen thresholds and review instructions;
- automated pixel/metadata/frequency metrics;
- blinded original-versus-result review records;
- an aggregate promotion report with no raw face-derived material.

## Failure and Observability

- Semantic absence, ambiguity, unsafe support, resource absence, and backend unavailability must be distinguishable typed conditions.
- User-facing SDK behavior remains fail closed and privacy safe.
- Diagnostics may include stage, aggregate counts, normalized reason codes, configuration/model hashes, and timing buckets.
- Diagnostics must exclude raw pixels, crops, masks, landmarks, private paths, and stable biometric-like descriptors.

## Promotion Boundary

Promotion is an architecture change, not a tuning flag. It is allowed only after the evidence report passes:

1. append one default-zero public state field;
2. append one effect route/case while preserving existing ordering and migration rules;
3. wire the validated internal editor through the normal renderer path;
4. prove neutral identity, legacy compatibility, CPU oracle behavior, selected-output parity, and public documentation;
5. update the taxonomy from partial only if its owner-defined criterion is truly satisfied.

If promotion fails, none of those public-surface changes occur.

---
*Research for v1.18 — upper-eyelid fullness reduction*
