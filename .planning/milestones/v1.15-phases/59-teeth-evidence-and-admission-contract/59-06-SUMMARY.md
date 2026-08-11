---
phase: 59
plan: 06
status: completed-open-intent
---

# Plan 59-06 Summary

Implemented the first production-facing seam unlocked by the Phase 54 open
teeth decision. `BeautyParameters` now has one trailing public
`teethWhitening: Float`; it is finite-normalized to `0...1`, defaults to zero,
and missing legacy keys decode to zero. The existing source labels, stored
order, Codable order, five preset resources, filter behavior, and unrelated
effects remain compatible.

## Contract

- Stored/CodingKey inventory: exactly 60 fields, with 59 numeric values plus
  the optional filter ID; `teethWhitening` is last.
- Default encoded shape: 59 keys because a nil filter ID is omitted; a
  non-nil-filter object encodes 60 keys and preserves unequal teeth values.
- Legacy labeled construction and legacy payloads decode with
  `teethWhitening == 0`.
- Negative, zero, NaN, and both infinities normalize to zero; positive finite
  values clamp to the unit interval.

## Admission

`BeautyEffectResolver.localRetouchAdmission(parameters:)` is the sole
production authority. Only normalized `teethWhitening > 0` returns one
package-private opaque demand; all other values return `.none`. The carrier
contains no feature name, evidence, support, mask, provider, or output state.
Global color, skin, lip, geometry, filter, sibling, Testing-only, and alias
inputs remain neutral for teeth admission.

No teeth provider, mask/transform/composition logic, renderer case, saved
output, realtime path, model, network dependency, or Demo mapping was added.

## Verification

- `BeautyParametersTests`: 49/49.
- `BeautyEffectResolverTests`: 29/29.
- `BeautyEngineLocalRetouchFoundationTests`: 25/25.
- `BeautyResourceCatalogTests`: 15/15.
- Combined focused seam: 118/118.
- Production absence scan and `git diff --check`: passed.

This is an admitted intent and request demand only. It does not claim visible
whitening, effectiveness, protected-tissue safety, naturalness, or promotion.
