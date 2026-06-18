# Phase 5: Filters, Presets, and Resource Flow - Context

**Gathered:** 2026-06-18T12:48:34Z
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase turns color controls, filter selection, built-in presets, and the first resource registry into a testable SDK and Demo slice. It covers `EFFECT-02`, `EFFECT-03`, and `EFFECT-08`: Demo users can adjust color parameter controls, select a metadata-backed filter and intensity, and apply five bundled preset definitions.

Phase 5 is a resource and parameter-flow phase, not a visual-quality phase. It does not need to implement visible color rendering, real LUT assets, LUT parsing, real filter styles, core skin/face geometry effects, makeup, stickers, segmentation, export, JSON import/export, dedicated QA debug surfaces, or final preset workflow polish.

</domain>

<decisions>
## Implementation Decisions

### Color Control Scope
- **D-01:** Phase 5 prioritizes the parameter chain for color controls. Brightness, contrast, saturation, temperature, tint, exposure, highlight, and shadow must be editable in Demo, captured in `BeautyParameters`, covered by tests, represented in presets, and documented as part of the SDK contract.
- **D-02:** Phase 5 does not require visible color output. The current no-op/copy rendering behavior may remain for visual output, with honest Demo copy where needed. Visible color adjustment quality belongs to Phase 6.
- **D-03:** Color sliders should be added to the existing `Beauty` panel. Do not add a top-level `Color` category and do not change the Phase 2 top-level category order.
- **D-04:** Color controls should use the existing Demo range model: enhancement controls use `0...100`, bidirectional controls use `-100...100`, and values normalize into the documented `BeautyParameters` ranges before SDK calls.

### Filter Resource Scope
- **D-05:** Phase 5 should add a `BeautyResources` manifest and metadata-only built-in filter registry. Do not add real LUT assets, identity LUT assets, LUT parsing, or real style resources in this phase.
- **D-06:** Demo should expose `None` plus two metadata-backed filters. This is enough evidence for `filterId` selection, `filterIntensity`, preset references, unknown-filter failures, and UI availability without expanding into visual filter design.
- **D-07:** `filterId == nil` remains the no-filter state. Built-in metadata filters are valid resource IDs but may still render as no-op placeholders until a later visual filter implementation exists.
- **D-08:** Unknown `filterId` values are not accepted as valid resource references. Resource resolution must distinguish known metadata filters from missing or invalid IDs.

### Built-In Preset Shape
- **D-09:** The five required built-in presets must be bundled JSON resources loaded through `BeautyResources`, not Swift-only static definitions.
- **D-10:** The required built-in presets are Natural, Clear, Refined, Male Natural, and ID Photo Natural. They are complete `BeautyParameters` bundles, not hidden algorithms or separate effect code paths.
- **D-11:** Preset JSON should include an outer `schemaVersion` field with strict v1 support. Unknown fields may be ignored only when forward-compatible; unsupported schema versions must be rejected with a typed preset error.
- **D-12:** Preset content versions and JSON schema versions should not be conflated. Existing `version` may remain the preset content/version field while `schemaVersion` owns JSON format compatibility.
- **D-13:** Applying the same built-in preset must produce the same `BeautyParameters` value every time. Presets must pass parameter validation and resource reference validation before reaching rendering.

### Demo UI Entry
- **D-14:** Keep Phase 5 UI changes inside the existing editor shell and parameter panel. Do not add a separate preset page, independent preset/filter rail, or new top-level Presets category.
- **D-15:** Add lightweight preset chips or an equivalent compact picker inside the existing `Beauty` panel, near the color and beauty controls.
- **D-16:** Change the `Filters` panel from Phase 2's disabled state into an enabled lightweight filter picker with `None`, two metadata filters, and `filterIntensity`.
- **D-17:** Applying a preset replaces the current parameter snapshot and synchronizes all relevant slider display values. It is not only a selected-preset marker and it is not layered on top of the current parameters.
- **D-18:** Demo should remain facade-only. It may import `BeautySDK` but must not import `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources` directly.

### Missing Resource Policy
- **D-19:** SDK/resource loading is strict. Unknown `filterId`, invalid preset resource references, missing required registries, unsupported preset schema versions, and invalid manifests must return typed, redacted errors rather than silently succeeding.
- **D-20:** Demo behavior is friendly. It should only present available registry entries as selectable; unavailable preset or filter entries should be visibly disabled or explained without exposing raw paths, raw framework errors, or internal target details.
- **D-21:** Missing optional real LUT files are not a Phase 5 concern because Phase 5 does not include real LUT assets. Future LUT implementation must follow `SECURITY.md` and `RELIABILITY.md` for type, size, checksum, decode, and degradation behavior.

### the agent's Discretion
- **D-22:** The planner and executor may choose conservative preset numeric values, stable preset IDs, two metadata filter IDs/names, manifest field names, UI microcopy, and test file organization, as long as they follow the root contracts and decisions above.
- **D-23:** Preset values should stay conservative and natural. Product copy must not promise identity-changing results.
- **D-24:** Filter IDs and preset IDs should be stable, ASCII, and test-friendly, using the existing conservative ID character rules.
- **D-25:** Plans should prefer small, testable SDK and Demo seams over broad visual refactors. If a choice would require camera preview rendering overhaul, real LUT processing, or full visual QA, defer it.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Current work ledger, completed Phase 1-4 evidence, dirty-worktree caution, and tech debt rules.
- `.planning/PROJECT.md` — SDK-centered product direction, local-first privacy posture, and Demo validation role.
- `.planning/REQUIREMENTS.md` — Phase 5 covers `EFFECT-02`, `EFFECT-03`, and `EFFECT-08`.
- `.planning/ROADMAP.md` — Phase 5 goal, success criteria, and planned plan slots `05-01` through `05-04`.
- `.planning/STATE.md` — Current focus, session continuity, and known blockers/concerns.

### Prior Phase Context
- `.planning/phases/02-demo-integration-shell/02-CONTEXT.md` — Locks editor shell shape, top-level category order, slider normalization, disabled-state behavior, and facade-only Demo imports.
- `.planning/phases/03-realtime-and-still-input-slice/03-CONTEXT.md` — Locks Camera/Photo entry flow, local-first processing, compare continuity, bounded realtime processing, and parameter snapshot ownership.
- `.planning/phases/04-detection-and-coordinate-safety/04-CONTEXT.md` — Locks metadata/result summary boundaries, no raw geometry/framework leakage, and safe degradation behavior.

### Root Contracts
- `ARCHITECTURE.md` — SDK target boundaries, `BeautyResources` ownership, resource/effects dependency direction, and Demo facade-only import invariant.
- `DESIGN.md` — `BeautyParameters`, `BeautyPreset`, resource IDs, render/effect model, `ColorPass`/`LUTPass` ordering, and serialization rules.
- `FRONTEND.md` — Demo panel/category state ownership, slider UI ranges, preset/filter UI responsibilities, disabled states, and app-side parameter ownership.
- `SECURITY.md` — Preset validation, resource ID trust boundary, no arbitrary path resolution, local-first privacy boundary, and external resource prohibition.
- `RELIABILITY.md` — Missing resource policy, preset decode failure behavior, degradation matrix, and resource reliability rules.
- `PRODUCT_SENSE.md` — Preset product contract, MVP experience evidence, color/filter acceptance, UI sync, naturalness, and anti-goals.
- `QUALITY_SCORE.md` — Current gaps for Presets, Filters, `BeautyResources`, resource validation, and effect/render evidence.

### Current Code
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Existing 31-field parameter model with color fields and `filterId`/`filterIntensity`.
- `BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift` — Existing Codable preset type and typed validation path to extend for `schemaVersion` and bundled loading.
- `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift` — Existing typed and redacted errors, including `resourceNotFound`, `presetDecodeFailed`, and `lutDecodeFailed`.
- `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` — Current metadata-aware no-op/copy engine; Phase 5 may keep visual output no-op while validating parameters/resources.
- `BeautySDK/Sources/BeautyResources/BeautyResources.swift` — Current empty resource module that Phase 5 expands into manifest/registry loading.
- `BeautySDK/Package.swift` — Current package target/resource declarations; Phase 5 may need `BeautyResources` processed resources and resource tests.
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` — App-side parameter snapshot owner that must learn color fields, filter selection, and preset application.
- `BeautyDemo/BeautyDemo/Panel/BeautyCategoryModels.swift` — Current Filters disabled state to change for Phase 5 while preserving other top-level categories.
- `BeautyDemo/BeautyDemo/Panel/BeautyControlDescriptor.swift` — Existing descriptor/range model to extend for color controls and enabled filter controls.
- `BeautyDemo/BeautyDemo/Panel/BeautyPanelView.swift` — Existing panel composition point for lightweight preset and filter pickers.
- `BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift` — Current store and disabled-filter tests to update for color/filter/preset sync.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` — Current view-state tests that lock category and filter disabled behavior; Phase 5 should update them to the new enabled filter contract.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyParameters` already has every Phase 5 parameter field: brightness, contrast, saturation, temperature, tint, exposure, highlight, shadow, `filterId`, and `filterIntensity`.
- `BeautyPreset.decode(from:availableFilterIds:)` already validates IDs and unknown filter references through `BeautyError.resourceNotFound`; it is the natural extension point for `schemaVersion` and bundled preset loading.
- `BeautyError` already redacts string payloads and exposes stable `code` values, matching strict SDK and friendly Demo behavior.
- `BeautyParameterStore` already owns app-side slider display values and normalized public `BeautyParameters` snapshots.
- `BeautyControlDescriptor` and `BeautyDisplayRange` already encode enhancement and bidirectional slider ranges.
- `BeautyPanelView.viewState` and current Demo tests provide a stable place to verify preset/filter picker state without simulator UI automation.

### Established Patterns
- Demo source and tests import only `BeautySDK`; import-boundary scans are part of phase verification.
- Demo state is value/enum driven and covered through XCTest view-state and pipeline tests.
- User-facing copy stays short and avoids raw framework errors, file paths, landmarks, or internal implementation details.
- Realtime Camera work is bounded and Photo processing preserves previous visuals; Phase 5 should not introduce unbounded work or main-thread blocking.
- Root contracts treat resources as IDs and validated manifests, never as arbitrary paths from UI or preset JSON.
- Previous phases prefer narrow public facade additions and testing SPI only when needed for package internals.

### Integration Points
- Add manifest, filter metadata, and built-in preset loading under `BeautyResources`.
- Expose only host-appropriate preset/filter APIs through the public `BeautySDK` facade; keep lower-level resource internals out of Demo imports.
- Update `BeautyPreset` or add a companion schema wrapper so bundled JSON supports `schemaVersion`.
- Update `BeautyParameterStore` to apply presets, sync color/filter display values, and preserve reset behavior.
- Update `BeautyCategoryModels`, `BeautyControlDescriptor`, and `BeautyPanelView` to enable Filters and add compact preset/filter pickers.
- Add or update SDK tests for manifest parsing, bundled preset loading, schema rejection, missing resources, unknown filter IDs, deterministic preset application, and facade exposure.
- Add or update Demo tests for Beauty panel color controls, filter panel enabled state, filter selection/intensity mapping, preset chip state, preset-to-slider sync, reset behavior after preset application, and facade-only imports.

</code_context>

<specifics>
## Specific Ideas

- Built-in preset names are fixed by product contract: Natural, Clear, Refined, Male Natural, and ID Photo Natural.
- Phase 5 can use metadata-only filter names and IDs chosen by the planner/executor, provided they are stable, conservative, and test-friendly.
- Demo should keep existing category order: Beauty, Face Shape, Facial Features, Makeup, Filters, Stickers, Background, Style.
- The user explicitly approved agent discretion for preset numeric values, metadata filter IDs/names, manifest fields, UI copy, and test organization.

</specifics>

<deferred>
## Deferred Ideas

- Visible color rendering and real color adjustment quality remain Phase 6.
- Real LUT assets, LUT parsing, LUT decode tests, and visual filter style quality remain outside Phase 5 unless explicitly promoted later.
- Dedicated preset workflows, JSON import/export, richer QA/debug surfaces, and final Demo polish remain Phase 7.

</deferred>

---

*Phase: 5-Filters, Presets, and Resource Flow*
*Context gathered: 2026-06-18T12:48:34Z*
