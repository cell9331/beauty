# Phase 2: Demo Integration Shell - Research

**Researched:** 2026-06-11
**Domain:** SwiftUI Demo host-app shell, local Swift Package integration, view-state tests, slider normalization, disabled roadmap controls
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Build a real editor shell as the first screen, not a plain control catalog.
- Use a static portrait placeholder or fixture-like preview area. Do not connect camera or photo input in this phase.
- Show Camera and Photo mode entries on the first screen, but keep them disabled or explicitly marked for Phase 3.
- Default the bottom category selection to Beauty.
- Show top-level categories: Beauty, Face Shape, Facial Features, Makeup, Filters, Stickers, Background, and Style.
- Present unimplemented top-level categories as visible disabled categories. Users may open them, but the panel must show disabled or coming-later content rather than active controls.
- Disabled panels should use a phase badge plus a short reason.
- Under Facial Features, show Eyes, Nose, Mouth, Eyebrows, Teeth, and Hairline.
- Eyes, Nose, and Mouth should have usable structure; Eyebrows, Teeth, and Hairline should be visible but disabled or coming later.
- Filters should be a visible disabled category in Phase 2. Filter rows and intensity controls are disabled and marked for Phase 5.
- Sliders that map to existing `BeautyParameters` fields should be interactive and update an app-side parameter snapshot.
- Resource-backed controls, advanced controls without existing `BeautyParameters` fields, and future capability controls remain disabled.
- Use SDK domain ranges: `0...100` for enhancement controls, `-100...100` for bidirectional controls, normalized into `0...1` or `-1...1` before building `BeautyParameters`.
- Slider changes should show that parameters were applied while visual output is still pending future effect phases.
- Implement single-slider reset and reset-all behavior.

### Explicit Out of Scope
- Camera capture, photo picking, still-image processing, visual effects, filters, presets, detection overlays, and real rendered output changes.
- Any Demo import of `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources`.
</user_constraints>

<current_state>
## Current Repository State

### Build and Project Facts
- `BeautySDK/Package.swift` now exists and exposes a library product named `BeautySDK`.
- `BeautySDK/Sources/BeautySDK/BeautySDK.swift` re-exports public core models through the facade.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` already defines the 31-field parameter model needed for Phase 2 slider mapping.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` has an empty `packageProductDependencies` list and an empty Frameworks build phase. The Demo target is not wired to the local package yet.
- The Xcode project uses `PBXFileSystemSynchronizedRootGroup` for `BeautyDemo/BeautyDemo`, so new Swift files under that directory can be picked up without explicit `PBXSourcesBuildPhase` entries.
- `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` succeeds and lists target/scheme `BeautyDemo`.
- Available simulator evidence includes `iPhone 17` on iOS 26.5.

### Demo Source Facts
- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` still launches `ContentView()`.
- `BeautyDemo/BeautyDemo/ContentView.swift` is still the default "Hello, world!" SwiftUI template and imports only `SwiftUI`.
- There is no `BeautyDemoTests` target, no UI test target, and no Demo test files.

### Documentation Drift Note
- `.planning/codebase/STACK.md`, `STRUCTURE.md`, and `TESTING.md` still describe the pre-Phase-1 state in places. For Phase 2 planning, prefer current files and Phase 1 summaries over those older maps where they conflict.
</current_state>

<architectural_responsibility_map>
## Architectural Responsibility Map

| Capability | Primary Owner | Secondary Owner | Rationale |
|------------|---------------|-----------------|-----------|
| Demo package dependency | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | `BeautySDK/Package.swift` | The app target must link the local `BeautySDK` product before Demo source can import it. |
| App shell entry | `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift` | existing app target | The app entry should route to the new editor shell and remain app-only SwiftUI code. |
| Editor shell UI | `BeautyDemo/BeautyDemo/Editor/**` | `FRONTEND.md` | Phase 2 is a host-app-style first screen with static preview and disabled input modes. |
| Category and control model | `BeautyDemo/BeautyDemo/Panel/**` | view-state tests | Data-driven descriptors make exact category visibility, disabled states, and range mapping testable without UI automation. |
| Parameter snapshot state | `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` | `BeautyParameters` | The Demo owns UI values and constructs immutable SDK parameter snapshots. |
| Preview/test fixtures | `BeautyDemo/BeautyDemo/Support/**` | tests/previews | Phase 2 should use deterministic placeholder state, not camera/photo assets. |
| Demo tests | `BeautyDemo/BeautyDemoTests/**` | Xcode project test target | Phase 2 requirements allow view-state tests; a unit test target is cheaper and more stable than UI automation for this shell. |
</architectural_responsibility_map>

<research_summary>
## Summary

Phase 2 should be planned as a thin, testable host-app integration slice: wire the local package into the Demo, replace the template view with a static editor shell, and make the planned category taxonomy executable through value-driven view state.

The safest implementation shape is to keep business facts in small Swift value types that the UI renders:
- top-level category descriptors,
- facial-feature subcategory descriptors,
- slider/control descriptors,
- availability states with phase badges and short reasons,
- display-to-SDK range conversion helpers,
- a parameter store that resets one field or all fields and produces `BeautyParameters`.

This avoids making visual layout the only source of truth. Tests can assert exact category ordering, disabled status, slider normalization, reset behavior, and forbidden imports before later phases add camera, image input, or real effects.

**Primary recommendation:** Use the roadmap's three plan slots, but let Plan 02-01 include the Xcode test-target foundation so Plan 02-02 and Plan 02-03 can verify view-state behavior without waiting for UI automation.
</research_summary>

<integration_patterns>
## Integration Patterns

### Pattern 1: Local Swift Package dependency in Xcode

The Demo project needs a local package reference to `../BeautySDK`, a `BeautySDK` product dependency, and a framework build file in the app target's Frameworks phase.

Expected project-file concepts:
- `XCLocalSwiftPackageReference` with `relativePath = ../BeautySDK`
- `XCSwiftPackageProductDependency` with `productName = BeautySDK`
- `PBXBuildFile` for `BeautySDK` in the Frameworks build phase
- app target `packageProductDependencies = (... BeautySDK ...)`
- project `packageReferences = (... local BeautySDK package ...)`

After wiring, Demo source should compile with:

```bash
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
```

### Pattern 2: Keep UI facts in descriptors

Recommended descriptor model:

```text
DemoCategory
  id: beauty | faceShape | facialFeatures | makeup | filters | stickers | background | style
  title: visible label
  availability: available | comingLater(phase, reason)
  panel: controls | subcategories | disabledMessage

DemoControl
  id: stable test identifier
  title: visible label
  parameterKey: BeautyParameterKey?
  range: unit0To100 | signedMinus100To100 | resource
  availability: available | comingLater(phase, reason)
```

This lets `BeautyPanelView` render the state and tests assert the state directly.

### Pattern 3: Normalize at the app boundary

The Demo should store display values and convert to SDK values when building a snapshot:

| Display Range | SDK Range | Conversion |
|---------------|-----------|------------|
| `0...100` | `0...1` | `display / 100` |
| `-100...100` | `-1...1` | `display / 100` |

The `BeautyParameters` initializer already clamps final values, but the Demo should still clamp display values before conversion so UI state and SDK state stay consistent.

### Pattern 4: View-state tests before UI tests

The Phase 2 requirements can be met with unit/view-state tests:
- exact top-level category labels and order,
- exact Facial Features subcategory labels and disabled states,
- filter category is visible but disabled for Phase 5,
- Camera and Photo mode entries are disabled for Phase 3,
- slider display values normalize into the expected `BeautyParameters` fields,
- single reset and reset-all restore no-op defaults,
- static scans reject internal SDK target imports.

UI tests can come later when camera/photo flows exist.
</integration_patterns>

<parameter_mapping>
## Parameter Mapping for Phase 2

### Interactive Controls

Enhancement range `0...100` -> SDK `0...1`:
- Skin: `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen`
- Face Shape: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`
- Nose: `noseSlim`, `noseWingSlim`, `noseBridge`
- Mouth: `smile`, `lipColor`

Bidirectional range `-100...100` -> SDK `-1...1`:
- Color: `brightness`, `contrast`, `saturation`, `temperature`, `tint`, `exposure`, `highlight`, `shadow`
- Face Shape: `chinLength`
- Eyes: `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`
- Nose: `noseTipSize`
- Mouth: `mouthSize`, `mouthWidth`

### Visible But Disabled Controls

- Filters: `filterId` and `filterIntensity` are existing SDK fields, but user decision D-09 says Filters remain visible disabled and marked Phase 5.
- Makeup, Stickers, Background, and Style are visible disabled top-level categories.
- Eyebrows, Teeth, and Hairline are visible disabled Facial Features subcategories.
- Any resource-backed or advanced control without a current `BeautyParameters` field remains disabled.

### Status Copy

Use short UI status text such as:
- `Parameters applied`
- `Visual update pending Phase 6`
- `Coming in Phase 3`
- `Coming in Phase 5`
- `Requires future resource support`

Avoid long developer explanations in normal UI.
</parameter_mapping>

<implementation_recommendations>
## Implementation Recommendations for Planning

### Plan 02-01: Demo project wiring and shell structure
- Add the local `BeautySDK` package product to the `BeautyDemo` app target.
- Add a `BeautyDemoTests` XCTest target hosted by `BeautyDemo` or otherwise configured to test app module view-state.
- Move the app entry into `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift` or keep a compatibility entry that launches the new shell.
- Replace the default `ContentView` route with an editor shell entry point.
- Verify `import BeautySDK` compiles from Demo source and forbidden internal imports are absent.

### Plan 02-02: Category, control, slider, and parameter state
- Create data-driven category, subcategory, availability, slider-range, and parameter-key models.
- Create a `BeautyParameterStore` or equivalent app-side state that owns display values and builds `BeautyParameters`.
- Implement single reset and reset-all on the store.
- Include testable status for "parameter applied, visual pending".
- Keep filters visible disabled even though `filterId` and `filterIntensity` exist.

### Plan 02-03: Editor shell UI and verification
- Render a static preview/editor shell with disabled Camera and Photo entries.
- Render bottom categories and panels from descriptors.
- Render interactive sliders only for available mapped controls.
- Render disabled panels/rows with phase badges and short reasons.
- Add view-state tests and static scans for requirements `SDK-08`, `DEMO-02`, `DEMO-03`, `DEMO-04`, `DEMO-05`, and `DEMO-08`.
</implementation_recommendations>

<validation_architecture>
## Validation Architecture

### Automated Test Stack
- SDK health: XCTest through Swift Package Manager.
- Demo compile and tests: Xcode build/test with explicit iOS Simulator destination.
- Static architecture scans: ripgrep checks over Demo source and tests.

### Commands

```bash
swift test --package-path BeautySDK
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test
rg -n "import BeautyCore|import BeautyDetection|import BeautyRender|import BeautyEffects|import BeautyResources" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests
rg -n "Hello, world!" BeautyDemo/BeautyDemo
```

The import scan should return no matches. The `Hello, world!` scan should return no matches after the shell replaces the template.

### Required Coverage

| Requirement | Evidence |
|-------------|----------|
| SDK-08 | Demo source imports `BeautySDK`; forbidden internal-import scan has no matches in app and Demo tests. |
| DEMO-02 | View-state test asserts exact top-level categories: Beauty, Face Shape, Facial Features, Makeup, Filters, Stickers, Background, Style. |
| DEMO-03 | View-state test asserts unavailable categories/controls are disabled or coming-later, not active. |
| DEMO-04 | View-state test asserts Facial Features contains Eyes, Nose, Mouth, Eyebrows, Teeth, Hairline and disabled states for unimplemented items. |
| DEMO-05 | Unit test asserts `0...100` and `-100...100` display values normalize to expected `BeautyParameters` values. |
| DEMO-08 | `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` plus static import scan cover category visibility, disabled controls, slider normalization, and import boundaries. |

### Manual Verification
- Visual layout review can confirm the shell reads like an editor, but Phase 2 should not rely on manual inspection for category coverage or slider conversion.
- If a simulator destination changes locally, use an available simulator from `xcrun simctl list devices available` and record the exact command.
</validation_architecture>

<risk_summary>
## Risk Summary

| Risk | Impact | Mitigation |
|------|--------|------------|
| Manual `.pbxproj` package/test-target edits break Xcode parsing. | Demo cannot build or test. | Keep edits minimal, run `xcodebuild -list`, then build/test with an explicit simulator. |
| Descriptor names drift from UI labels. | Tests pass on internal IDs but UI violates roadmap labels. | Store visible labels in the same descriptors the UI renders and tests assert. |
| Filters become accidentally interactive because fields exist in `BeautyParameters`. | Violates user decision D-09 and Phase 5 boundary. | Mark the whole Filters category disabled in Phase 2 tests. |
| Tests require UI automation too early. | Phase 2 slows down and becomes brittle before camera/photo flows exist. | Prefer deterministic view-state unit tests for Phase 2; defer UI automation to richer flows. |
| Existing dirty worktree causes accidental broad commits. | Unrelated files enter Phase 2 history. | Use scoped commits with only `.planning/phases/02-demo-integration-shell/**` for planning artifacts and later scoped code commits. |
| UI-SPEC is missing for a frontend phase. | GSD plan-phase gate should block final planning. | Run `$gsd-ui-phase 2` before final `PLAN.md` unless intentionally using `--skip-ui`. |
</risk_summary>

## RESEARCH COMPLETE
