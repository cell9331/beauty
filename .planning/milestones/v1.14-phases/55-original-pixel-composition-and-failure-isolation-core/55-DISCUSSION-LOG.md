# Phase 55: Original-Pixel Composition and Failure-Isolation Core - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution
> agents. Decisions are captured in CONTEXT.md.

**Date:** 2026-08-03
**Phase:** 55-original-pixel-composition-and-failure-isolation-core
**Areas discussed:** Admission boundary, original-pixel ownership, containment
and collisions, failure granularity, verification and privacy

---

## Admission boundary

| Option | Description | Selected |
| --- | --- | --- |
| Feature-neutral core with exact-empty production admission | Add only package-internal reusable mechanics and opaque test wiring. | ✓ |
| Add inert candidate routes | Introduce fields/providers that remain zero or disabled. | |
| Promote spike feature output | Turn mechanics masks/transforms into visible SDK behavior. | |

**Auto choice:** Feature-neutral core with exact-empty production admission.
**Notes:** Phase 54 closed all three feature gates. Phase 55 can build their
shared composition prerequisite but cannot create a candidate surface.

## Original-pixel ownership

| Option | Description | Selected |
| --- | --- | --- |
| Canonical-source-bound contributions | Every accepted proposal is checked against and blended from the current immutable canonical bytes. | ✓ |
| Sequential provider feedback | Let each provider read the previous provider's output. | |
| Caller-trusted output raster | Accept an unverified transformed frame and mask. | |

**Auto choice:** Canonical-source-bound contributions.
**Notes:** This is the only option that makes COMP-02 and fused/standalone byte
oracles independent of provider order.

## Containment and collisions

| Option | Description | Selected |
| --- | --- | --- |
| Re-clip hard envelope; collision returns source | Clamp/re-clip final weights and suppress every conflicting local proposal at that pixel. | ✓ |
| Priority rule | Teeth, sclera, strength, or array order wins an overlap. | |
| Reject both complete units | Any one overlap discards every pixel from both otherwise valid units. | |

**Auto choice:** Re-clip hard envelope; collision returns source.
**Notes:** Spike 012 and COMP-03/04 require pixel-local source preservation,
not implicit priority or unnecessarily broad failure.

## Failure granularity

| Option | Description | Selected |
| --- | --- | --- |
| Smallest-unit abstention | Reject malformed teeth/eye/band work locally while valid siblings survive. | ✓ |
| All-local-work failure | One invalid unit disables the entire local composition. | |
| Repair invalid claims | Guess missing indices, weights, source binding, or ownership. | |

**Auto choice:** Smallest-unit abstention.
**Notes:** COMP-01/05 require independent teeth, whole-sclera, left-eye, and
right-eye failure evidence with unchanged unaffected output.

## Verification and privacy

| Option | Description | Selected |
| --- | --- | --- |
| Mechanics-only byte oracles plus aggregate diagnostics | Use tiny opaque inputs and fixed expected bytes; expose counts only. | ✓ |
| Track mask/output artifacts | Commit or log local masks, pixels, or coordinates. | |
| Use Spike visuals as product proof | Treat isolated macOS outputs as rights/naturalness evidence. | |

**Auto choice:** Mechanics-only byte oracles plus aggregate diagnostics.
**Notes:** Phase 55 proves composition semantics only. Phase 54 evidence
decisions and privacy boundaries remain authoritative.

## the agent's Discretion

- Internal type/file layout, mask storage, checked caps, exact integer blend
  formula, and opaque test injection shape.
- Sparse/ROI versus dense mechanics implementation, without a performance claim.

## Deferred Ideas

- Feature-specific providers and visible product output in Phases 56-57 only
  after independent admission.
- Combined stress, public-facade output, exact ledgers, and audit closeout in
  Phase 58.
