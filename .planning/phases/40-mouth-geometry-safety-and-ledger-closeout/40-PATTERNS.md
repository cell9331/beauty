# Phase 40 Implementation Patterns

## Final Cap Table

| Field | Public range | Final effective cap | Reused exact value |
| --- | --- | --- | --- |
| `mouthYPosition` | `-1...1` | `±0.25` | `±0.125` |
| `mouthTilt` | `-1...1` | `±0.25` | `±0.125` |
| `mouthXPosition` | `-1...1` | `±0.25` | `±0.125` |
| `lipPeakDefinition` | `0...1` | `0.25` | `0.125` |
| `lipPlump` | `0...1` | `0.25` | `0.125` |

Exact-cap inputs do not increment `cappedCount`; normalized overflow inputs do. Negative/non-finite positive-only inputs remain silent zero.

## Support Matrix

- Whole-mouth fields (`mouthSize`, `mouthWidth`, `smile`, `mouthYPosition`, `mouthTilt`, `mouthXPosition`) require valid outer-lip support.
- `lipPeakDefinition` requires valid upper and inner support.
- `lipPlump` requires valid upper, lower, and inner support.
- Invalid support zeroes only dependent fields; independent valid siblings remain active.
- `lipColor` remains a separate color-domain policy and is not geometry/plump evidence.

## Retained-Set Convergence

1. Cap normalized values.
2. Apply exact reused scale once where applicable.
3. Sanitize each nose/mouth field against its own provider emission.
4. Resolve one combined geometry scale.
5. Re-sanitize at scaled values; remove only fields that become non-emitting.
6. Repeat monotonically for at most six nose plus eight mouth removals.
7. Emit totals, count, scale, warnings, effective strengths, and vectors from the same final mask.

Tests should mirror the private total using absolute magnitude for signed fields. No new public total metric is needed.

## Promotion Transaction

Before promotion: boundary checker default mode requires all five rows unimplemented/partial and branch `嘴唇` partial. After green evidence: update exactly five rows to implemented, run allow-promotion mode, update current owners, verify `白牙` remains future and branch remains partial, and hand off only to independent milestone audit.

