# Project Research Summary

**Project:** Beauty
**Domain:** Remaining mouth geometry controls in an existing local-first iOS SDK
**Researched:** 2026-07-14
**Confidence:** HIGH

## Executive Summary

v1.10 should complete the five unresolved mouth geometry rows—`上下`, `倾斜`, `左右`, `M唇`, and true `丰唇`—without including `白牙`. The first three are signed whole-mouth transforms; M-lip and plump are positive local lip-shape controls. `白牙` is a teeth-region segmentation/color-retouch feature and remains a separate future slice, so `嘴唇` stays branch-level partial even after its geometry subset is complete.

No new dependency or rendering pass is needed. The correct extension point is the existing public `BeautyParameters` → package-internal Vision availability/geometry adapter → `MouthWarpProvider` → resolver/conflict convergence → unified warp → public-facade renderer evidence chain. Apple Vision already exposes both outer- and inner-lip landmark regions; the package should record inner-lip availability and derive explicit upper/lower supports without exposing raw geometry.

The main risks are borrowed semantics, treating missing inner lips as missing all mouth geometry, losing signed direction, and allowing provider-empty work into conflict evidence. Three phases separate contract/support correctness, facade output evidence, and final safety/ledger promotion.

## Key Decisions

### Public Fields

- `mouthYPosition`: signed whole-mouth vertical translation.
- `mouthTilt`: signed whole-mouth rotation.
- `mouthXPosition`: signed whole-mouth horizontal translation.
- `lipPeakDefinition`: positive M-lip/cupid-bow peak definition, named product-neutrally.
- `lipPlump`: positive local upper/lower lip plumping, explicitly not `lipColor` or mouth size.

The stable inventory becomes 38 stored fields: 37 numeric values plus `filterId`. Old payloads and presets omit the new keys and decode all five to zero.

### Support and Degradation

- Existing outer-lip support remains sufficient for shipped mouth fields and the three whole-mouth transforms.
- Peak/plump additionally require inner-lip availability and valid explicit upper/lower supports.
- Missing support removes only dependent fields; siblings continue.
- Reused geometry applies the established exact `0.5`; stale geometry zeros all geometry fields; lip color keeps its independent color-domain policy.
- Combined conflict convergence expands to six nose plus eight mouth geometry fields with at most fourteen monotonic removals.

### Output Evidence

Add eight isolated cases to the current 36-case renderer: plus/minus for the three signed fields, one peak case, and one plump case. The derived exact matrix becomes 44 × 7 = 308 outputs. The helper must prove decode/dimensions, fixed mouth-ROI changes, signed-direction distinctions, peak/plump distinctions from confusable legacy controls, representative no-face behavior, and ignored/untracked containment.

## Roadmap Implications

### Phase 38: Public Contract and Lip-Support Geometry

**Delivers:** Five-field compatibility, `innerLips` availability, explicit upper/lower supports, eight-field mouth emissions, resolver/facade integration, and provider-eligible conflict convergence.

**Avoids:** API aliasing, support coupling, provider/conflict drift, and raw-geometry exposure.

### Phase 39: Public-Facade Mouth Geometry Output Evidence

**Delivers:** Eight isolated cases, strict 308-output helper evidence, signed and semantic distinction checks, exact ignored gallery, and output-boundary security evidence.

**Avoids:** Provider-only completion claims, stale/partial galleries, sign loss, and plump/color/size confusion.

### Phase 40: Mouth Geometry Safety and Ledger Closeout

**Delivers:** Final exact caps, exhaustive eight-field support/freshness/combined behavior, fail-closed boundaries, exact five-row promotion, and synchronized current owners.

**Avoids:** Unsupported work surviving into diagnostics/dispatch and false whole-branch completion.

## Scope Boundaries

### Included

- Five new public numeric fields and package-internal support geometry.
- SDK-core provider/resolver/facade/render evidence.
- Compatibility, caps, degradation, combined weakening, redaction, artifact, and documentation gates.

### Deferred

- `白牙`, teeth segmentation/retouch, and branch-level `嘴唇` completion.
- Demo UI, third-party dependencies, network/cloud, accounts/payments/VIP/commercial behavior.
- Physical-device parity, commercial visual approval, performance/thermal certification, packaging, shipping, and launch readiness.

## Confidence Assessment

| Area | Confidence | Reason |
| --- | --- | --- |
| Stack | HIGH | Existing path is shipped and audited; Apple documents both lip regions |
| Scope | HIGH | Milestone title plus authoritative ledger cleanly separates geometry from `白牙` |
| Architecture | HIGH | Reuses the established independent-field/provider/facade pattern from v1.9 |
| Exact artistic caps | MEDIUM | Must be finalized only after facade output evidence |
| M-lip/plump support geometry | MEDIUM | Explicit design is clear, but output naturalness needs Phase 39 calibration evidence |

## Sources

### Primary

- Current source/tests and repository root contracts.
- Archived v1.8 mouth and v1.9 nose milestone artifacts.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` and lips branch README.
- Apple Vision `VNFaceLandmarks2D`: https://developer.apple.com/documentation/vision/vnfacelandmarks2d

### Background

- `docs/06_beauty_parameters_spec.md` and `docs/09_algorithm_effects_implementation.md`.

---
*Research completed: 2026-07-14*
*Ready for roadmap: yes*
