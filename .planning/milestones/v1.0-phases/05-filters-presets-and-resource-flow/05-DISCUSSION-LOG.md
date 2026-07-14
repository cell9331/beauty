# Phase 5: Filters, Presets, and Resource Flow - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-18T12:48:34Z
**Phase:** 5-Filters, Presets, and Resource Flow
**Areas discussed:** Color control scope, Filter resource scope, Built-in preset shape, Demo UI entry, Missing resource policy, Agent discretion

---

## Color Control Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Parameter chain first | Enable Demo controls, SDK parameter snapshots, presets, tests, and docs; visible color rendering remains later. | ✓ |
| Minimal visible color output | Implement basic still-image color adjustment now; camera preview remains out of scope. | |
| Full visible output | Make still image and realtime camera display processed color output in Phase 5. | |

**User's choice:** Parameter chain first.
**Notes:** Current `BeautyEngine` is still no-op/copy. User chose not to expand Phase 5 into visible render output.

### Color UI Placement

| Option | Description | Selected |
|--------|-------------|----------|
| Place in Beauty panel | Add color sliders to the existing `Beauty` panel and preserve top-level category order. | ✓ |
| Place in Filters panel | Put color controls alongside filter selection and intensity. | |
| Add Color top-level category | Add a new semantic top-level category, changing the Phase 2 category contract. | |

**User's choice:** Place in Beauty panel.
**Notes:** This avoids changing existing category order and keeps Phase 5 UI scoped.

---

## Filter Resource Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Manifest plus metadata-only filters | Add resource manifest and built-in filter registry without real LUT files. | ✓ |
| Add one minimal no-op LUT | Include an identity LUT to test bundle resource loading without style quality. | |
| Add multiple real style LUTs | Add visible filter resources and visual filter behavior. | |

**User's choice:** Manifest plus metadata-only filters.
**Notes:** Phase 5 validates resource ID flow and missing-resource behavior without real LUT parsing or style assets.

### Filter Count

| Option | Description | Selected |
|--------|-------------|----------|
| None plus 2 metadata filters | Enough to test selection, intensity, preset references, and unknown-filter errors. | ✓ |
| None plus 5 metadata filters | More product-like, but more naming/copy surface. | |
| Only None | Minimal but weak evidence for applying a filter by `filterId`. | |

**User's choice:** None plus 2 metadata filters.
**Notes:** Planner/executor may choose stable filter IDs and names.

---

## Built-In Preset Shape

| Option | Description | Selected |
|--------|-------------|----------|
| Bundled JSON resources | Five presets are package resources loaded through `BeautyResources`. | ✓ |
| Swift static registry | Define presets directly in Swift code. | |
| JSON plus Swift fallback | Load JSON but silently fall back to Swift definitions when resources fail. | |

**User's choice:** Bundled JSON resources.
**Notes:** This matches the Phase 5 resource-flow goal and `PRODUCT_SENSE.md` preset parse acceptance.

### Preset Schema

| Option | Description | Selected |
|--------|-------------|----------|
| schemaVersion outer field with strict v1 support | Preset JSON is self-describing; unknown schema versions reject. | ✓ |
| Reuse existing version field as schema | Smaller change, but conflates content version and JSON schema. | |
| Record schema only in resource manifest | Keeps `BeautyPreset` unchanged but makes individual preset files less self-describing. | |

**User's choice:** `schemaVersion` outer field with strict v1 support.
**Notes:** Existing `version` should remain preset/content version rather than schema compatibility.

---

## Demo UI Entry

| Option | Description | Selected |
|--------|-------------|----------|
| Add lightweight picker in existing panel | Preset chips in Beauty; filter chips plus intensity in Filters. | ✓ |
| Add independent preset/filter rail under preview | More visible but adds another layout layer. | |
| Add dedicated Presets panel/category | Clear but changes top-level taxonomy and scope. | |

**User's choice:** Add lightweight picker in existing panel.
**Notes:** The Demo should remain the same editor shell and panel structure.

### Preset Application

| Option | Description | Selected |
|--------|-------------|----------|
| Replace parameter snapshot and sync sliders | Preset application updates all relevant display values and future edits start from preset values. | ✓ |
| Track selected preset without slider sync | Simpler but fails UI sync acceptance. | |
| Layer preset on top of current parameters | More compositional but conflicts with preset-as-complete-parameter-bundle. | |

**User's choice:** Replace parameter snapshot and sync sliders.
**Notes:** This preserves `PRODUCT_SENSE.md` UI sync acceptance and deterministic preset semantics.

---

## Missing Resource Policy

| Option | Description | Selected |
|--------|-------------|----------|
| Strict SDK and friendly Demo | SDK/resource loaders return typed errors; Demo only shows available entries or disabled explanations. | ✓ |
| SDK soft warning | SDK continues with output and warning when optional filter resources are missing. | |
| Demo intercepts everything, SDK does not validate | UI prevents issues but host apps lack SDK-level protection. | |

**User's choice:** Strict SDK and friendly Demo.
**Notes:** This aligns existing `BeautyPreset.decode(from:availableFilterIds:)` behavior with Demo usability.

---

## Agent Discretion

| Option | Description | Selected |
|--------|-------------|----------|
| Agent decides within repo contracts | Planner/executor chooses conservative values, stable IDs, short copy, and tests. | ✓ |
| Continue discussing all details | Keep asking about preset values, filter names, manifest fields, and copy. | |
| Pause for user-supplied parameter table | Stop context generation until the user supplies exact parameters. | |

**User's choice:** Agent decides within repo contracts.
**Notes:** The remaining details are implementation choices bounded by root docs and this context.

## the agent's Discretion

- Conservative numeric preset values.
- Stable preset IDs.
- Two metadata filter IDs and display names.
- Manifest field names and exact resource layout.
- Short Demo UI copy.
- Test file organization and focused verification commands.

## Deferred Ideas

- Visible color rendering and real color adjustment quality remain Phase 6.
- Real LUT assets, LUT parsing, LUT decode tests, and visual filter style quality remain outside Phase 5 unless promoted later.
- Dedicated preset workflows, JSON import/export, richer QA/debug surfaces, and final Demo polish remain Phase 7.
