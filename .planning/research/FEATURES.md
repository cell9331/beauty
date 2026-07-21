# Feature Research

**Domain:** Exact seven unresolved SDK-core `脸型` rows
**Researched:** 2026-07-21
**Confidence:** HIGH for scope and semantics; MEDIUM for final region-model implementation

## Feature Scope

| Ledger row | Product-neutral public semantic | Range | Required support | Independent behavior to prove |
| --- | --- | --- | --- | --- |
| `面部流畅` | `faceContourSmooth` | `0...1` | Ordered observed face contour | Reduces local contour irregularity without globally shrinking the face. |
| `太阳穴` | `templeFullness` | `0...1` | Upper lateral contour plus face centerline | Bounded outward temple fill, distinct from `faceSmall` and `faceSlim`. |
| `颧骨` | `cheekboneSlim` | `0...1` | Mid-lateral observed contour | Cheekbone-local inward movement, distinct from whole-cheek slimming. |
| `去双下巴` | `doubleChinReduction` | `0...1` | Lower contour plus eligible submental region | Basic bounded lower-face geometry/containment, not a `jawSlim` alias. |
| `去双下巴 Pro` | `doubleChinRefinement` | `0...1` | Validated local semantic mask | Higher-fidelity mask-contained refinement, independently testable and not an entitlement. |
| `尖下巴` | `chinTaper` | `0...1` | Chin apex and adjacent lower-contour points | Narrows toward the apex without changing signed chin length. |
| `发际线` | `hairlineHeight` | `-1...1` | Validated hair/skin boundary mask | Both directions move the boundary locally while protecting face/hair surroundings. |

## Table Stakes

- Seven independent, finite-normalized, default-zero, Codable/source-compatible public fields.
- Actual request-scoped observed face-contour/median-line support; no synthetic box proxy for new rows.
- Field-local eligibility: missing submental or hairline masks remove only dependent fields.
- Distinct basic and refined double-chin outputs; no payment, VIP, account, or remote-service behavior.
- Isolated public-facade output for every field, both hairline directions, safe no-face/missing-support cases, and ignored artifact containment.
- Final caps/dead zones, reused/stale rules, provider-eligible combined weakening, fixed diagnostics, and exact seven-row promotion.

## Explicit Exclusions

| Feature | Reason |
| --- | --- |
| Demo sliders or new SwiftUI screens | v1.12 is SDK-core and facade-output evidence only. |
| Runtime download or cloud segmentation | Breaks local-first and resource-trust boundaries. |
| Entitlement/payment semantics for “Pro” | The reference badge does not define SDK commercial behavior. |
| Rebranding existing fields as new rows | Each unresolved row needs independent behavior and evidence. |
| Device/commercial visual/performance/packaging readiness | Separate evidence scope after functional completion. |
| Broader `比例`, `3D塑颜`, `眉毛`, eye retouch, or teeth work | Outside exact `脸型` branch closeout. |

## Dependencies

```text
48-field shipped compatibility
  -> seven default-zero public controls
  -> private observed contour + median line
       -> smooth / temple / cheekbone / pointed chin
       -> lower-contour anchor for basic double chin
  -> approved local semantic-region support
       -> refined double chin
       -> signed hairline
  -> named provider emissions + field-local eligibility
  -> facade output and strict comparisons
  -> final safety, boundaries, exact promotion, branch closeout
```

## Completion Definition

Exactly the seven unresolved rows become `implemented` only when the public contract, private support, provider/refinement behavior, public-facade output, safety/degradation, security/resource boundaries, and owning documentation all agree. At that point `脸型` becomes `implemented` at SDK-core scope, while device/commercial/release claims remain excluded.

## Sources

- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` — authoritative exact row inventory and status.
- `docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md` — current branch boundary.
- `docs/06_beauty_parameters_spec.md` — prior neutral names for `cheekboneSlim`, `templeFullness`, and `hairlineHeight`.
- `.planning/milestones/v1.5-*` — immutable shipped evidence and anti-alias boundary for existing face rows.
- [Apple face landmarks](https://developer.apple.com/documentation/vision/vnfacelandmarks2d) — available contour and centerline inputs.

---
*Feature research for: Beauty v1.12 Face Shape Remaining Capabilities*
