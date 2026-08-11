---
phase: 59
feature: teeth_whitening
decision: open
status: admitted-intent-only
requirements: [SEQ-01, EVID-07, TEETH-07, TEETH-08]
---

# Phase 59 — Teeth Evidence and Admission Contract

## Authority and exact decision

The Phase 54 evidence core remains the sole evidence authority. The Phase 54 serializer
has emitted one exact open `teeth_whitening` decision: two eligible,
two reviewed, two accepted, zero rejected, and naturalness weight two. Its two
structured reviews are the opaque positive and negative rows accepted under
criteria frozen before review. The decision has no reasons.

`sclera_redness` remains closed at zero weight with the two missing-genuine-row
reasons. `upper_eyelid_fullness` remains closed at zero weight with those two
reasons plus `non_warp_design_unqualified`. Sibling, mechanics-only, synthetic,
historical, or candidate evidence cannot contribute to the teeth decision.

The canonical ledger is an aggregate allowlist. It contains only schema version,
opaque fixture and feature identities, polarity, fixed judgments, fixed reason
codes, decisions, and aggregate counts. `mask_coverage` and
`protected_leakage` are allowed fixed judgments. Media, local locators, hashes,
rights details, raw masks, geometry, pixels, coordinates, reviewer identity,
free text, scanner matches, and raw errors are prohibited.

## Runtime admission boundary

The open row authorizes exactly one append-only SDK intent seam:

- `BeautyParameters.teethWhitening` is the trailing 60th stored/CodingKey/
  initializer field, defaults to zero, decodes missing legacy input as zero, and
  normalizes non-finite or negative input to zero and finite positive input to
  `0...1`.
- Only direct `normalized.teethWhitening > 0` creates one
  `BeautyLocalRetouchAdmission(opaqueDemandCount: 1)`; every other input returns
  `.none`.
- Global whitening/color, lips, geometry, Testing hooks, aliases, siblings, and
  `去脂` cannot create this demand.

The scalar represents qualified intent, not pixels. Phase 59 makes the explicit
nonclaims: no provider, no renderer output, no Demo mapping, and no product promotion.
It also adds no mask owner, transform, saved-image behavior,
realtime/pixel-buffer route, model, network route, visible-effectiveness claim,
provider-safety claim, or release claim.

## Compatibility and privacy

All five preset resources retain their baseline bytes and omit the new key, so
they decode to zero. The public example renderer remains exactly 72 cases with
no local-retouch case. The Demo keeps `lips.teeth`, `eyes.redness`, and
`eyes.fat` as disabled taxonomy rows with nil controls.

Local evidence is rediscovered only by the private runner. It injects the local
bundle into one child process, reproduces the canonical serializer bytes, and
returns fixed aggregate status. Tracked and staged privacy scanning must pass
without emitting paths, matched text, local evidence identifiers, or evidence
digests.

## Lifecycle

Every T-59-01 through T-59-08 HIGH gate is blocking. Phase 60 may begin only
after the exact open ledger, trailing scalar, one-demand route, compatibility
inventories, privacy scan, owner synchronization, and final regression all pass.
Any missing file, parse error, scanner ambiguity, unknown threat mode, extra
surface, or contract drift fails closed.
