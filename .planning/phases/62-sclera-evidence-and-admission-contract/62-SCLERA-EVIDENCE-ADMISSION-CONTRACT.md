---
phase: 62
feature: sclera_redness
status: open
review_frozen: true
security_standard: OWASP ASVS Level 1
block_on: HIGH
---

# Phase 62 Sclera Evidence and Admission Contract

## Current authority

The Phase 54 ReviewCore and `54-EVIDENCE-DECISIONS.json` remain the sole
evidence and admission authority. The current canonical state is:

| Feature | Status | Reasons | Eligible / reviewed / accepted / rejected | Naturalness |
| --- | --- | --- | --- | ---: |
| `teeth_whitening` | open | none | 2 / 2 / 2 / 0 | 2 |
| `sclera_redness` | open | none | 2 / 2 / 2 / 0 | 2 |
| `upper_eyelid_fullness` | closed | both missing-genuine reasons; non-warp design unqualified | 0 / 0 / 0 / 0 | 0 |

The earlier zero-intake closed branch remains the fail-closed fallback. The
current open row comes only from two independently accepted genuine rows and a
fresh Phase 54 serializer run; it does not yet authorize a provider, output,
Demo route, synthetic substitute, teeth reuse or hand-edited decision.

## Exact eligible pair

An open attempt requires exactly two independently authorized genuine rows:

| Polarity | Target | Minimum semantics |
| --- | --- | --- |
| positive | visible scleral redness/bloodshot appearance | bounded reduction remains visible and natural |
| negative | normal or already-low-redness sclera | target is absent and output remains stable |

The rows may show different people. Each owns a distinct opaque fixture ID,
`sclera_redness` feature, predeclared polarity and target, approved internal-
evaluation rights, opaque rights record, and an exact original/mask/after
triple. Duplicate IDs, duplicate polarities, ambiguous basenames, missing or
substituted assets, unapproved rights, absolute/traversing keys, symlinks and
unsupported rows fail closed.

AI-generated, mechanics-only, authorization-only, historical, rejected,
candidate-only, teeth and upper-eyelid rows contribute zero sclera product,
naturalness or admission weight.

## Frozen derivative and review criteria

Private derivatives use the isolated guarded sclera path only. Each eye is
validated independently; iris, pupil and highlights are excluded before color
scoring; local feathering is re-clipped to the same hard envelope. The legacy
unguarded sclera mask and its post-blur expansion are ineligible.

Review is local, blinded and original-detail. The criteria are frozen before
any real original is opened:

- Positive target is present and bounded redness reduction is visible.
- Negative target is absent and the result is stable/no-op in appearance.
- Mask coverage is useful for the intended sclera and scored from 1 through 5.
- Protected leakage is false for iris, pupil, highlight, lash, skin, makeup and
  eye-aperture exterior.
- Vessel/detail variation, luminance, structure and non-porcelain natural color
  are preserved.
- Naturalness is scored from 1 through 5; structure change is false.
- Decision is `accept` only when all applicable criteria pass; otherwise it is
  `reject` with one fixed Phase 54 reason code.

The durable review schema is exactly:

`fixture_id`, `feature`, `polarity`, `target_present`, `mask_coverage`,
`protected_leakage`, `naturalness`, `structure_changed`, `decision`,
`reason_code`.

Mechanics metrics, overlays, raw support, reviewer prose and aggregate scores
cannot override an original-detail rejection or supply admission weight.

## Exact open result

Only ReviewCore-issued reviews and `serializeDurableExport` may open the row.
The exact accepted result is:

```json
{
  "feature": "sclera_redness",
  "status": "open",
  "reasons": [],
  "eligible_count": 2,
  "reviewed_count": 2,
  "accepted_count": 2,
  "rejected_count": 0,
  "naturalness_weight": 2
}
```

Both rows must pass rights, binding, review issuance, validation and
acceptance. Any rejected, missing, malformed, ambiguous, substituted or
incomplete row keeps sclera closed. Serialization must independently reproduce
the existing teeth open input and the upper-eyelid closed input; neither sibling
may change.

Durable equality means exact UTF-8 bytes from the Phase 54 serializer: two-space
JSON indentation, LF line endings and one final newline. A status-only or
hand-edited match is not authority.

## Durable privacy allowlist

Tracked evidence contains only:

- schema version;
- opaque fixture, feature and polarity IDs;
- the ten fixed review judgments;
- exact fixed decisions, reasons and aggregate counts.

It contains no media, filenames, paths, locators, digests, rights or
documentation records, retention text, reviewer identity, raw support, masks,
geometry, coordinates, pixels, vessel-like descriptors, raw metrics, scanner
matches, error payloads or free-form text. Private paths and exact asset
digests may exist only in bounded child-process memory.

## Conditional runtime contract

The runtime branch is forbidden while sclera is closed or malformed. After and
only after the exact open result:

- append one trailing positive-only `Float` named
  `scleraRednessReduction`, default zero, finite-normalized to `0...1`;
- preserve the exact 61-field inventory of 60 numeric fields plus `filterId`,
  legacy missing-key neutrality, labeled source calls and five preset bytes;
- let only direct normalized positive sclera intent contribute one feature-
  neutral opaque demand in addition to an independently requested teeth demand;
- retain exactly 73 renderer cases and three disabled nil-mapped Demo rows.

No global color/whitening, skin, geometry, Testing hook, teeth intent, alias,
Demo ID/title or `去脂` proxy may activate sclera demand. This phase adds no
production eye support, guard, mask, provider, transform, renderer output,
saved-image route, realtime/pixel-buffer work, model, network behavior or Demo
activation.

## Failure isolation and nonclaims

A closed or malformed sclera decision produces exact sclera absence and does
not roll back the completed teeth field, provider, renderer output, `白牙` or
`嘴唇` product state. A later valid request cannot inherit stale state from an
invalid request.

Phase 62 does not prove visible public sclera output, population coverage,
production guard thresholds, target-device performance, commercial approval,
packaging, shipping, launch or release readiness. `祛红血丝` and `去脂` remain
future and the eye product branch remains partial.

## Blocking rule

T-62-01 through T-62-08 are all HIGH. A missing real pair, changed criterion,
unissued review, sibling mismatch, privacy leak, scanner/tool error, skipped
private gate, premature runtime surface, compatibility drift or downstream
implementation keeps Phase 62 incomplete and Phase 63 blocked.
