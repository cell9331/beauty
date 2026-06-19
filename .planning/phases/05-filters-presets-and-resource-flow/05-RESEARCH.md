# Phase 5: Filters, Presets, and Resource Flow - Research

**Researched:** 2026-06-19
**Status:** Complete

## Research Goal

Answer what the planner needs to know to implement Phase 5 safely: how to add validated bundled preset resources, a metadata-only filter registry, Demo color/filter/preset controls, and missing-resource behavior without expanding into Phase 6 visual rendering or Phase 7 workflow polish.

## Source Inputs

- `.planning/phases/05-filters-presets-and-resource-flow/05-CONTEXT.md`
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/STATE.md`
- `AGENTS.md`
- `PLANS.md`
- `ARCHITECTURE.md`
- `DESIGN.md`
- `FRONTEND.md`
- `SECURITY.md`
- `RELIABILITY.md`
- `PRODUCT_SENSE.md`
- `QUALITY_SCORE.md`
- Current `BeautySDK/Sources`, `BeautySDK/Tests`, `BeautyDemo/BeautyDemo`, and `BeautyDemo/BeautyDemoTests`

## Phase Scope Findings

Phase 5 covers exactly:

- `EFFECT-02`: Demo users can adjust brightness, contrast, saturation, temperature, tint, exposure, highlight, and shadow through SDK-backed parameters.
- `EFFECT-03`: Demo users can select a filter by `filterId`, adjust `filterIntensity`, and see missing filters handled through typed SDK errors or visibly disabled UI.
- `EFFECT-08`: Demo users can apply Natural, Clear, Refined, Male Natural, and ID Photo Natural built-in presets.

The user decisions in `05-CONTEXT.md` narrow the implementation:

- Color work is parameter-chain only; visible color output remains Phase 6.
- Filters are metadata-only; no real LUT assets or LUT parsing in Phase 5.
- Built-in presets are bundled JSON resources loaded through `BeautyResources`.
- Preset JSON must have an outer `schemaVersion` with strict v1 support.
- Demo changes stay inside the existing editor shell and parameter panel.
- SDK/resource loaders are strict; Demo is friendly and only exposes available options.

## Current Codebase Findings

### SDK Package and Resource Target

`BeautySDK/Package.swift` already has targets for `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, and public facade `BeautySDK`.

Current resource-related gaps:

- `BeautyResources` has no processed resources in `Package.swift`.
- `BeautyResources` has no manifest, preset JSON, filter registry, loader, or tests.
- `BeautySDK/Tests` has no `BeautyResourcesTests` target.
- `BeautyResources` can depend on `BeautyCore`, but `BeautyCore` must not depend on `BeautyResources`.

Planning implication:

- Add package resources under `BeautySDK/Sources/BeautyResources/Resources`.
- Add `.process("Resources")` to the `BeautyResources` target.
- Add a `BeautyResourcesTests` test target depending on `BeautyCore`, `BeautyResources`, and likely `BeautySDK` for facade checks if needed.

### Existing Preset Model

`BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift` already provides:

- `BeautyPreset: Codable, Equatable, Sendable`
- `decode(from:availableFilterIds:)`
- identifier validation
- positive `version` validation
- non-empty `displayName` validation
- unknown filter reference rejection through `BeautyError.resourceNotFound(filterId)`

Current preset gaps:

- No `schemaVersion`.
- No bundled preset loading.
- No resource manifest integration.
- Phase 1 test `testD13Phase1DoesNotExposeBuiltInPresetRegistry` explicitly asserts that built-in preset registry symbols do not exist. Phase 5 must replace or delete this historical assertion because the Phase 5 contract now requires built-in presets.

Planning implication:

- Preserve `BeautyPreset` as the value model.
- Add a schema wrapper, for example `BeautyPresetResource` or `BeautyPresetEnvelope`, to decode:
  - `schemaVersion`
  - `id`
  - `version`
  - `displayName`
  - `parameters`
- Keep `version` as preset content/version and make `schemaVersion` own JSON compatibility.
- Unsupported schema versions should throw `BeautyError.presetDecodeFailed("unsupported_schema")` or another redacted stable reason.
- Continue using `availableFilterIds` to reject unknown filter references.

### Existing Parameter Model

`BeautyParameters` already includes all Phase 5 fields:

- Color: `brightness`, `contrast`, `saturation`, `temperature`, `tint`, `exposure`, `highlight`, `shadow`
- Filter: `filterId`, `filterIntensity`

All numeric color fields clamp to `-1...1`; `filterIntensity` clamps to `0...1`. Missing JSON fields decode to zero/nil defaults.

Planning implication:

- No public parameter fields need to be added.
- Demo mapping is the main missing path for color fields and filter values.
- Preset JSON can use existing `BeautyParameters` decoding after adding `schemaVersion`.

### Existing Engine Behavior

`BeautyEngine` currently normalizes parameters then returns no-op/copy output. That is consistent with Phase 5 D-02, as long as Demo and docs are honest that visual output remains pending Phase 6.

Planning implication:

- Do not implement Core Image color adjustment, `ColorPass`, `LUTPass`, or camera preview output conversion in Phase 5.
- Verification should assert parameter/resource behavior, not pixel changes.

### Existing Demo State and UI

`BeautyParameterStore` currently:

- Owns display values.
- Normalizes enabled descriptors into `BeautyParameters`.
- Does not map color fields.
- Ignores `filterId` and `filterIntensity`.
- Has no selected filter state.
- Has no preset application API.

`BeautyControlDescriptor` currently:

- Has no color control IDs or parameter keys.
- Has disabled filter controls with `availability: .filtersPhaseFive`.
- Uses `BeautyDisplayRange.enhancement` and `.bidirectional`.

`BeautyCategoryModels` currently:

- Keeps Filters visible but disabled.
- Uses `panelKind: .disabled` for Filters.

`BeautyPanelView` currently:

- Computes view state from category/subcategory/status only.
- Has no preset picker or filter picker state.
- Shows disabled filter controls only when the Filters category is disabled.

Current Demo tests lock Phase 2 behavior:

- Filters are disabled and show `Coming in Phase 5`.
- Disabled filter controls do not mutate snapshots.
- Beauty panel controls are only skin controls.

Planning implication:

- Phase 5 plans must deliberately update tests that lock Phase 2's temporary disabled Filters state.
- Prefer value-driven view-state additions, not simulator UI automation, because current Demo test pattern is XCTest view-state/pipeline coverage.
- Keep top-level category order unchanged.
- Make Filters enabled with a compact filter picker plus `filterIntensity`; do not enable Makeup/Stickers/Background/Style.

## Recommended Implementation Shape

### Resource Types

Recommended SDK-side types:

- `BeautyResourceManifest`
  - `schemaVersion`
  - `version`
  - `minimumSDKVersion` or `minimumSDK`
  - `filters: [BeautyFilterDefinition]`
  - `presets: [BeautyPresetReference]`
- `BeautyFilterDefinition`
  - `id`
  - `displayName`
  - optional metadata such as `family` or `description`
  - no LUT path required in Phase 5
- `BeautyPresetReference`
  - `id`
  - `resourceName` or relative bundled resource identifier
  - optional `displayName`
- `BeautyBuiltInResources` or `BeautyResourceCatalog`
  - load bundled manifest
  - expose `availableFilterIds`
  - expose built-in filter definitions
  - load and validate built-in presets

The exact names may vary, but the plan should force these capabilities.

### Resource Layout

Recommended package layout:

```text
BeautySDK/Sources/BeautyResources/Resources/
  manifest.json
  Presets/
    natural.json
    clear.json
    refined.json
    male-natural.json
    id-photo-natural.json
```

`Package.swift` should process `Resources` for the `BeautyResources` target.

### Facade Boundary

Demo must import only `BeautySDK`. There are two safe facade patterns:

1. Add public host-facing wrapper APIs in the `BeautySDK` target, such as `BeautySDKResources` or `BeautyBuiltIns`, that call into `BeautyResources` and return `BeautyCore` types.
2. Re-export `BeautyResources` from `BeautySDK` using the existing facade pattern, but only if tests prove Demo does not directly import internal targets.

Research recommendation: prefer wrapper APIs in `BeautySDK` when practical. They let Demo load built-in filters/presets through the facade while keeping resource internals less visible. If implementation chooses re-export for simplicity, add a facade test and import-boundary scan.

### Preset Values

The user delegated exact values to the agent. Preset values should be conservative and deterministic.

Suggested shape:

- Natural: small non-zero skin/color values; optional metadata filter at low intensity.
- Clear: slightly positive brightness/exposure/skin whitening/rosy; avoid high exposure.
- Refined: balanced skin, slight face/eye values, restrained color.
- Male Natural: sharper/cleaner, minimal reshaping, no makeup-like strong lip/rosy values.
- ID Photo Natural: neutral, low/no filter intensity, identity-preserving values.

Do not rely on visible rendering to validate these values in Phase 5. Validate via exact `BeautyParameters` snapshots and safety caps.

### Demo State Model

Recommended app-side additions:

- `BeautyFilterOption` or similar Demo view-state value sourced from facade-visible filter definitions.
- `BeautyPresetOption` or similar Demo view-state value sourced from facade-visible presets.
- `BeautyParameterStore.applyPreset(_:)` that:
  - replaces display values for every descriptor represented by `BeautyParameters`
  - updates selected filter state from `parameters.filterId`
  - updates `filterIntensity`
  - sets the existing pending-visual status
- store state for selected filter ID, with `nil` representing `None`.

Planning should account for two data forms:

- Numeric sliders map through `displayValues`.
- `filterId` is non-numeric and should not be forced through slider display ranges.

### UI Pattern

Keep UI compact and in-panel:

- `Beauty` panel: preset chips or compact picker before sliders, then skin/color sliders.
- `Filters` panel: filter chips for `None` + two metadata filters, then intensity slider.
- Existing disabled categories remain disabled.
- Existing status copy can continue to say visual update pending Phase 6, which is accurate for color/filter/preset changes.

## Risks and Landmines

| Risk | Why It Matters | Planning Mitigation |
| --- | --- | --- |
| Phase 1 test forbids built-in preset registry | It will fail once Phase 5 adds required built-ins. | Explicitly update/remove that historical test and replace it with Phase 5 built-in registry tests. |
| Demo direct import of `BeautyResources` | Violates SDK-08 and context D-18. | Add/keep static import scans over Demo source and tests. |
| Treating `filterId` like a numeric slider | Existing descriptors assume slider ranges; filter ID is categorical. | Plan a separate picker state for filter ID and keep slider only for intensity. |
| Resource IDs becoming paths | Violates `SECURITY.md`. | Use manifest references and `Bundle.module`; tests should cover traversal-like IDs. |
| Silent fallback for invalid presets | Violates strict SDK policy and hides resource issues. | Decode/load must throw typed `BeautyError` before applying partial values. |
| Accidentally implementing visual rendering | Expands Phase 5 into Phase 6 and affects camera/photo output. | Keep `BeautyEngine` output no-op unless needed only for parameter validation; test snapshots, not pixels. |
| UI-SPEC missing | Phase 5 changes Demo UI and plan-phase UI gate is enabled. | Run `$gsd-ui-phase 5` before final planning or use `--skip-ui` only with explicit acceptance. |

## Validation Architecture

### Automated Verification Targets

Use focused checks per plan, then full package/Demo verification before Phase 5 completion.

Required quick SDK checks:

```bash
CLANG_MODULE_CACHE_PATH=/private/tmp/beauty-clang-module-cache DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK
```

Required Demo simulator check:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test
```

Required import-boundary scan:

```bash
rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests
```

Expected scan result: no matches.

Required sensitive resource/path scan candidates:

```bash
rg -n "\\.\\./|/private/var|NSError|VNFaceObservation|landmark|boundingBox" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyResources BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo
```

Expected scan result: no sensitive/raw path leaks in public/Demo surfaces. Resource tests may contain malicious fixture strings such as `../` but public UI/source copy must not expose them.

### Test Matrix

| Area | Requirement | Automated Evidence |
| --- | --- | --- |
| Manifest decode | EFFECT-03, EFFECT-08 | `BeautyResourcesTests` decode bundled manifest, check schema/version, two filters, five preset refs. |
| Built-in presets | EFFECT-08 | SDK tests load Natural, Clear, Refined, Male Natural, ID Photo Natural and assert deterministic IDs/display names/parameter snapshots. |
| Preset schema | EFFECT-08 | Unsupported `schemaVersion` throws typed `presetDecodeFailed`; unknown forward-compatible fields do not break v1 decode. |
| Missing filter | EFFECT-03 | Unknown preset `filterId` throws `BeautyError.resourceNotFound` with redacted description/code. |
| Color controls | EFFECT-02 | Demo store/view-state tests prove all eight color controls exist in Beauty and map to `BeautyParameters`. |
| Filter controls | EFFECT-03 | Demo view-state tests prove Filters is enabled, exposes `None` plus two filters, and `filterIntensity` maps to SDK snapshot. |
| Preset UI sync | EFFECT-08 | Demo store tests apply each preset and assert relevant display values plus selected filter/intensity match the preset. |
| Facade boundary | SDK-08 supporting evidence | Demo import scan returns no internal target imports; facade tests prove host-visible APIs compile from `BeautySDK`. |

### Manual Verification

Manual UI inspection is useful but should not be a Phase 5 gate unless automation fails. Phase 5 is contract-heavy and can be mostly covered with XCTest and static scans.

If a manual smoke is performed:

1. Launch Demo on an explicit iOS Simulator.
2. Open `Beauty`; confirm preset picker and color sliders are visible without changing top-level category order.
3. Open `Filters`; confirm it is no longer disabled and presents `None` plus two metadata filters.
4. Apply a preset; confirm sliders visibly jump to preset values and status copy remains honest about Phase 6 visual pending behavior.

## Planning Recommendations

Preserve the roadmap's four plan slots:

1. `05-01`: Resource manifest, filter metadata, bundled preset resources, schema loading, package resource/test target setup.
2. `05-02`: Parameter mapping and SDK/facade resource placeholders, including strict typed missing-resource behavior and no-op render contract.
3. `05-03`: Demo preset/filter/color UI wiring through `BeautySDK`, store synchronization, and view-state tests.
4. `05-04`: Cross-cutting validation, root contract updates, final import/privacy/resource scans, and full SDK/Demo test runs.

Execution dependencies:

- `05-01` should run before any Demo or facade plan that needs built-in resources.
- `05-02` depends on the resource APIs from `05-01`.
- `05-03` depends on public facade APIs and filter/preset definitions.
- `05-04` depends on all previous plans and should own final verification/evidence updates.

## Research Complete

Phase 5 can be planned as a resource/parameter/UI synchronization slice. The main open procedural gate is not technical ambiguity; it is the workflow UI-SPEC gate because Phase 5 includes Demo UI changes and no `05-UI-SPEC.md` exists yet.
