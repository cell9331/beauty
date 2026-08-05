# Phase 59 Pattern Map

**Mapped:** 2026-08-05
**Files analyzed:** Current Phase 54 evidence owners, Phase 56 closed-gate
checker, `BeautyParameters`, `BeautyEffectResolver`, `BeautyEngine`, and their
focused tests.

## Scope Boundary

Phase 59 is the transition from a feature-specific evidence decision to one
public scalar intent and one opaque admission demand. It is not a teeth
rendering implementation. The canonical Phase 54 evidence ledger remains the
single decision source, and a closed row remains a successful fail-closed
outcome.

## File and Pattern Assignments

| Planned artifact | Role | Closest analog | Required pattern |
| --- | --- | --- | --- |
| `59-EVIDENCE-ADMISSION-CONTRACT.md` | phase contract | `54-EVIDENCE-EVALUATION.md` | claim-boundary-first, independent teeth row, sanitized export |
| `59-evidence-admission.contract.test.js` | contract test | `54-evidence-core.test.js` | Node built-in tests, one mutation per case, no media/path output |
| `check_phase59_teeth_admission_boundaries.py` | policy checker | `check_phase56_teeth_boundaries.py` | exact parser/scanner, temporary live fixtures, fail-closed subprocess status |
| `59-THREAT-INVENTORY.json` | security inventory | `56-THREAT-INVENTORY.json` | exact ordered HIGH IDs and executable owners |
| `54-EVIDENCE-DECISIONS.json` | authority | Phase 54 `ReviewCore.serializeDurableExport` | update only from a real validated open result; never hand-edit a passed row |
| `BeautyParameters.swift` | public model | current append-only tail | append field after `filterIntensity`, custom decode, normalized copy, trailing default |
| `BeautyEffectResolver.swift` | admission | current literal `.none` | normalized scalar only, one opaque demand, no alias/global/sibling inputs |
| `BeautyLocalRetouchAdmission.swift` | private carrier | current opaque count | preserve package-private count and public absence of feature state |
| `BeautyParametersTests.swift` | compatibility test | Phase 53/56 inventories | exact 60-field stored/CodingKey/encoded inventory and legacy neutrality |
| `BeautyEffectResolverTests.swift` | admission test | existing resolver tests | direct positive-only matrix and forbidden-input independence |
| `BeautyResourceCatalogTests.swift` | preset test | Phase 53 resource tests | five IDs/hashes unchanged; missing teeth key decodes to zero |
| `BeautyRendererOutputRegressionTests.swift` | output boundary | Phase 56 72-case guard | no teeth renderer case/output/helper; sclera/`去脂` absent |
| `BeautyEngineLocalRetouchFoundationTests.swift` | lifecycle test | Phase 53 foundation tests | one canonical request for positive teeth demand, zero provider/output effect |
| `BeautyDemoViewStateTests.swift` | UI boundary | Phase 56 disabled row tests | `lips.teeth` remains unsupported with nil control mapping |

## Implementation Notes

### Evidence

Reuse the exact Phase 54 feature identity `teeth_whitening`, `status: open`,
and fixed review fields. Validate the complete bound asset triple before any
original-detail review. Mechanics-only rows—including `portrait_002`—are
excluded from product counts and admission. Build durable output by positive
allowlist; never spread manifest/review objects or persist raw paths, hashes,
rights records, masks, pixels, reviewer identity, or freeform text.

### Public parameter

The existing model tail is `filterId`, `filterIntensity`. The new field belongs
after `filterIntensity` in all four ordered surfaces: stored properties,
`CodingKeys`, initializer/construction order, and `normalized()`. The init
argument is trailing and defaults to zero. Legacy payloads omit the new key and
decode it as zero; existing preset files remain byte-stable and decode neutral.

### Admission

Normalize before testing effective strength. Only finite normalized
`teethWhitening > 0` produces `BeautyLocalRetouchAdmission(opaqueDemandCount: 1)`;
all zero, missing, non-finite, clamped-to-zero, global-color, lip-color,
geometry, Testing, sclera, `去脂`, and alias inputs retain `.none` with no
feature state exported. Multiple eligible teeth signals cannot multiply the
single request route.

### Verification

Use focused SwiftPM XCTest samples during implementation. Reserve full SwiftPM,
explicit iPhone 17e/iOS 26.5 Demo build/test, GSD schema/UI gates, exact
requirements/decision/task/threat equality, and owner synchronization for the
final closeout task. Every HIGH threat must have a named executable mutation
and a green result; scanner errors and missing fixtures are not clean.

## Dependency and Wave Map

```text
59-01 evidence contract/checker + real-review gate
  -> 59-02 parameter + opaque admission
    -> 59-03 compatibility/facade/Demo exact-boundary tests
      -> 59-04 final evidence, owner sync, and full regression
```

The real evidence bundle is the only external precondition. No parallel plan
is safe because the public field and admission are conditional on the exact
canonical teeth decision.
