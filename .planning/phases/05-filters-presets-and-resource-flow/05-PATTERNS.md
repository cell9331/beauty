# Phase 05 - Pattern Map

**Mapped:** 2026-06-19
**Scope:** Filters, presets, resource flow, Demo color/filter/preset state

## Source Inputs

- `.planning/phases/05-filters-presets-and-resource-flow/05-CONTEXT.md`
- `.planning/phases/05-filters-presets-and-resource-flow/05-RESEARCH.md`
- `.planning/phases/05-filters-presets-and-resource-flow/05-UI-SPEC.md`
- `BeautySDK/Sources`
- `BeautySDK/Tests`
- `BeautyDemo/BeautyDemo`
- `BeautyDemo/BeautyDemoTests`

## Implementation Pattern Map

| New / Changed Area | Closest Existing Analog | Pattern to Preserve |
| --- | --- | --- |
| `BeautySDK/Package.swift` `BeautyResources` resources | `BeautyRender` target processing `Shaders` | Add `.process("Resources")` only to `BeautyResources`; add a focused `BeautyResourcesTests` target without changing facade product shape. |
| Bundled manifest and preset JSON | `BeautyPreset.decode(from:availableFilterIds:)` | Decode through typed Swift values, ignore forward-compatible unknown fields, validate IDs and referenced filter IDs before use. |
| Resource and filter metadata values | `BeautyParameters` and `BeautyPreset` public model style | Prefer `struct`, `enum`, `Codable`, `Equatable`, and `Sendable`; keep host-visible metadata path-free. |
| Resource loading API | `BeautyResourcesModule` module marker | Expand the module with a small catalog/registry facade; use `Bundle.module`, never absolute paths or UI-provided paths. |
| Public facade exposure | `BeautySDK/Sources/BeautySDK/BeautySDK.swift` | Demo imports only `BeautySDK`; expose host-facing wrappers or public Core values through the facade, not direct Demo imports of `BeautyResources`. |
| Color parameter mapping | `BeautyParameterStore.parametersSnapshot` switch over `BeautyParameterKey` | Extend the existing switch with the eight color fields; keep UI display ranges separate from SDK ranges. |
| Filter selection | Existing disabled `filterControls` placeholders | Make `filterId` categorical picker state, not a slider; keep `filterIntensity` as the only filter slider. |
| Preset application | `BeautyParameterStore.resetAll()` and slider status behavior | Rebuild the complete display snapshot from a `BeautyPreset.parameters` value, including skin, color, selected filter, and intensity. |
| Compact chips | `BeautyCategoryRailView` and `BeautyPanelView.subcategoryRail` | Use 13 px labels, 8 px radius, 44 px minimum height, horizontal scrolling, selected accent state, and accessibility labels. |
| View-state tests | `BeautyDemoViewStateTests` and `BeautyParameterStoreTests` | Keep tests deterministic and value-driven; avoid simulator UI automation for Phase 5 picker/content assertions. |
| Import/privacy scans | `BeautyDemoImportBoundaryTests` and `InputPipelinePrivacyTests` | Scan Demo app/tests for internal SDK imports and public surfaces for raw paths/framework errors. |

## Concrete Existing Details

### SDK Package

- `BeautySDK/Package.swift` already defines `BeautyResources` as a target depending on `BeautyCore`.
- `BeautyRender` already shows the resource declaration pattern: `resources: [.process("Shaders")]`.
- Existing test target style is one test target per internal domain, for example `BeautyDetectionTests` and `BeautyRenderTests`.

### Presets and Parameters

- `BeautyPreset` already validates `id`, positive `version`, non-empty `displayName`, and unknown `filterId`.
- `BeautyError` already redacts associated strings and exposes stable `code` values.
- `BeautyParameters` already contains all Phase 5 color fields plus `filterId` and `filterIntensity`; no new public parameter field is required.

### Demo State

- `BeautyParameterStore` owns display values and emits `BeautyParameters` snapshots.
- `BeautyDisplayRange.enhancement` maps `0...100` to `0...1`; `.bidirectional` maps `-100...100` to `-1...1`.
- `BeautyCategory.all` locks the top-level order: Beauty, Face Shape, Facial Features, Makeup, Filters, Stickers, Background, Style.
- Current tests intentionally lock Phase 2 temporary behavior where Filters are disabled; Phase 5 must replace those assertions with enabled-filter expectations.

## Planned File Ownership

| Plan | Primary Files | Notes |
| --- | --- | --- |
| `05-01` | `BeautyResources`, bundled JSON, `BeautyPreset`, `Package.swift`, SDK resource tests | Build the resource catalog and strict preset/filter schema first. |
| `05-02` | Public `BeautySDK` resource wrappers, facade tests, engine/resource placeholder tests | Make host-visible resource validation available through `BeautySDK` while keeping visual output no-op. |
| `05-03` | Demo panel/state/view-state tests | Wire preset chips, color sliders, enabled Filters, and parameter synchronization through the facade. |
| `05-04` | Cross-cutting tests, static scans, root docs, `QUALITY_SCORE.md`, `PLANS.md` | Final evidence and contract synchronization after implementation. |

## Landmines

- Remove or replace the old Phase 1 assertion that built-in preset registry symbols must not exist.
- Do not display filter IDs as raw user-facing labels; use short metadata labels such as `Soft Clean` and `Warm Light`.
- Do not introduce LUT assets, LUT parsing, filter swatches, or visible color rendering in Phase 5.
- Do not let Demo import `BeautyResources`; resource choices must arrive through `BeautySDK`.
- Keep unknown `filterId`, unsupported preset `schemaVersion`, invalid manifest, and missing bundled resources as typed, redacted errors.
