# Feature Research

**Domain:** Remaining SDK-core mouth geometry controls
**Researched:** 2026-07-14
**Confidence:** HIGH

## Scope Resolution

The source ledger has six unresolved mouth rows. The milestone title narrows scope to geometry controls, so v1.10 includes five rows and deliberately excludes `白牙`:

| Ledger row | Public semantic | Range | Geometry support | v1.10 |
| --- | --- | --- | --- | --- |
| `上下` | `mouthYPosition` | signed `-1...1` | Whole outer-lip support | Include |
| `倾斜` | `mouthTilt` | signed `-1...1` | Whole outer-lip support around mouth center | Include |
| `左右` | `mouthXPosition` | signed `-1...1` | Whole outer-lip support | Include |
| `M唇` | `lipPeakDefinition` | positive `0...1` | Explicit upper-lip plus inner-lip support | Include |
| `丰唇` | `lipPlump` | positive `0...1` | Explicit upper/lower plus inner-lip support | Include |
| `白牙` | Separate teeth-retouch contract | positive if later designed | Teeth region/mask, not mouth warp | Defer |

## Table Stakes

| Feature | Why required | Complexity | Acceptance direction |
| --- | --- | --- | --- |
| Independent public semantics | Each ledger row must be controllable without borrowing shipped mouth fields | MEDIUM | One new field per row; legacy payloads decode zero |
| Distinct signed transforms | Up/down, clockwise/counter-clockwise, and left/right must not collapse | MEDIUM | Positive/negative provider and output evidence |
| Local lip-shape controls | M-lip and plump must change lip shape, not color or whole-mouth size | HIGH | Explicit upper/lower and inner-lip support; isolated outputs differ from legacy controls |
| Fail-closed support policy | Missing inner lips must not fabricate local shape work | HIGH | Whole-mouth fields may remain; peak/plump zero independently |
| Facade-visible output evidence | Provider vectors alone do not prove public SDK output | MEDIUM | Eight isolated cases over seven fixtures; strict helper and ignored gallery |
| Conservative combination | Five new fields join all existing geometry without diagnostics drift | HIGH | Provider-eligible convergence and exact totals/counts/emissions |

## Differentiators

| Feature | Value | Complexity | Boundary |
| --- | --- | --- | --- |
| Per-field support degradation | Supported siblings continue when one field lacks geometry | HIGH | No aggregate all-mouth false skip |
| Evidence-backed semantic separation | True plump is proven distinct from `lipColor`, size, and M-lip | MEDIUM | ROI comparisons and no aliasing |
| Exact geometry-slice closeout | Five rows promote atomically without overstating whole-branch completion | LOW | `白牙` stays future; `嘴唇` remains partial |

## Anti-Features

| Feature | Why tempting | Why problematic | Alternative |
| --- | --- | --- | --- |
| Map `丰唇` to `lipColor` | Existing visible mouth effect | Tint is not structural geometry | Independent `lipPlump` |
| Implement M-lip as `mouthSize` | Existing radial control points | Cannot prove lip-peak definition | Explicit upper/inner-lip points |
| Treat missing inner lips as missing all mouth | Simple domain switch | Incorrectly drops valid translation/tilt/smile/size work | Per-field sanitization |
| Include `白牙` to claim branch completion | One unresolved row remains | Requires segmentation/color safety and different evidence | Separate future milestone |
| Add UI now | Makes rows visible in Demo | Expands frontend/product scope and validation burden | SDK facade cases only |

## Dependencies

```text
Public field compatibility
    └──> Detection records inner-lip availability
          └──> Adapter builds explicit upper/lower lip supports
                └──> Provider emits five independent field vectors
                      └──> Resolver/facade/conflict integration
                            └──> Isolated renderer/helper evidence
                                  └──> Final caps, safety, and ledger promotion
```

## Milestone Definition

### Must Have

- [ ] Five independent public parameters with compatibility and normalization tests.
- [ ] Outer/inner and upper/lower support ownership with malformed/missing support rejection.
- [ ] Provider, resolver, facade, degradation, conflict, redaction, and exact-emission evidence.
- [ ] Eight isolated facade cases: positive/negative for three signed fields plus one peak and one plump case.
- [ ] Exact promotion of five geometry rows while `白牙` and branch-level `嘴唇` remain partial.

### Future

- [ ] `白牙` segmentation, local retouch, caps, output containment, privacy, and ownership.
- [ ] Demo UI controls, device/commercial visual review, packaging, and launch evidence.
- [ ] Independent upper- versus lower-lip thickness controls if product scope later asks for them.

## Sources

- `.planning/milestones/v1.8-REQUIREMENTS.md` future requirements MOUTH-F01 through MOUTH-F03.
- `docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md`.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`.
- `docs/06_beauty_parameters_spec.md` advanced mouth parameter background.
- Current source/tests under `BeautySDK/Sources/BeautyEffects` and `BeautySDK/Tests`.

---
*Feature research for: v1.10 Mouth Remaining Geometry Controls*
*Researched: 2026-07-14*
