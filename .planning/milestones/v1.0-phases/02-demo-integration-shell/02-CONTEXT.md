# Phase 2: Demo Integration Shell - Context

**Gathered:** 2026-06-11T03:33:59Z
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase replaces the default SwiftUI template with a host-app-style Demo integration shell. The Demo must import `BeautySDK` only, present the planned editor taxonomy, normalize interactive slider values into `BeautyParameters`, and clearly mark unavailable controls as disabled or coming later.

Phase 2 does not implement camera capture, photo picking, still-image processing, visual effects, filters, presets, detection overlays, or real rendered output changes. Those remain in later roadmap phases.

</domain>

<decisions>
## Implementation Decisions

### First Screen Shape
- **D-01:** Build a real editor shell as the first screen, not a plain control catalog. The shell should establish the future editing experience even though the current output is no-op.
- **D-02:** Use a static portrait placeholder or clear fixture-like preview area for the main preview. Do not connect camera or photo input in this phase.
- **D-03:** Show Camera and Photo mode entries on the first screen, but keep them disabled or explicitly marked for Phase 3.
- **D-04:** Default the bottom category selection to Beauty.

### Unavailable Controls
- **D-05:** Show all top-level categories required by the roadmap: Beauty, Face Shape, Facial Features, Makeup, Filters, Stickers, Background, and Style.
- **D-06:** Present unimplemented top-level categories as visible disabled categories. Users may open them, but the panel must show disabled or coming-later content rather than active controls.
- **D-07:** Disabled panels should use a phase badge plus a short reason, such as "Coming in Phase 5" or "Requires future resource support." Avoid long developer-oriented explanations in the normal UI.
- **D-08:** Under Facial Features, show Eyes, Nose, Mouth, Eyebrows, Teeth, and Hairline. Eyes, Nose, and Mouth should have usable structure; Eyebrows, Teeth, and Hairline should be visible but disabled or coming later.
- **D-09:** Filters should be a visible disabled category in Phase 2. Filter rows and intensity controls are disabled and marked for Phase 5.

### Slider Behavior
- **D-10:** Sliders that map to existing `BeautyParameters` fields should be interactive in Phase 2 and update an app-side parameter snapshot.
- **D-11:** Resource-backed controls, advanced controls without existing `BeautyParameters` fields, and future capability controls remain disabled.
- **D-12:** Use the SDK domain table for UI ranges: enhancement controls display `0...100`, bidirectional controls display `-100...100`, and the app normalizes into `0...1` or `-1...1` before building `BeautyParameters`.
- **D-13:** When an interactive slider changes, the UI should show that parameters were applied while visual output is still pending future effect phases. Keep the copy short.
- **D-14:** Implement both single-slider reset and reset-all behavior for Phase 2.

### the agent's Discretion
No areas were delegated to the agent. Follow the decisions above and the canonical references below.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository navigation, reading order, task routing, and record/verification rules.
- `PLANS.md` — Current work ledger and tech debt, including Demo UI and test gaps.
- `.planning/PROJECT.md` — Confirmed SDK-centered product direction and Demo validation role.
- `.planning/REQUIREMENTS.md` — Phase 2 covers `SDK-08`, `DEMO-02`, `DEMO-03`, `DEMO-04`, `DEMO-05`, and `DEMO-08`.
- `.planning/ROADMAP.md` — Phase 2 goal, success criteria, and three planned plan slots.
- `.planning/STATE.md` — Current focus and known blockers.
- `.planning/phases/01-sdk-foundation-and-public-facade/01-CONTEXT.md` — Phase 1 decisions that established public facade, explicit parameters, and no-op output semantics.

### Current Contracts
- `ARCHITECTURE.md` — Demo may depend on `BeautySDK` but must not import internal SDK targets.
- `FRONTEND.md` — Demo directory structure, state ownership, category/panel rules, parameter UI ranges, reset behavior, and test contracts.
- `DESIGN.md` — `BeautyParameters` fields, value ranges, normalization rules, and parameter-state model.
- `PRODUCT_SENSE.md` — Product journeys, MVP experience contract, visible later domains, and acceptance criteria.
- `QUALITY_SCORE.md` — Current Demo score, architecture scans, and Phase 2 repair priority.

### Codebase Maps
- `.planning/codebase/CONVENTIONS.md` — Swift naming, import conventions, and future internal-target import prohibition.
- `.planning/codebase/STRUCTURE.md` — Current Demo structure and suggested locations for new Demo UI code.
- `.planning/codebase/STACK.md` — Current Xcode/iOS toolchain, deployment target, and build-path notes.

### Current Code
- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` — Current app entry point.
- `BeautyDemo/BeautyDemo/ContentView.swift` — Current default template to replace.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` — Existing Xcode target with no `BeautySDK` package dependency wired yet.
- `BeautySDK/Package.swift` — Local Swift Package and facade product to wire into the Demo project.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — Existing 31-field parameter model that Phase 2 sliders map into.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySDK` facade product exists and package tests import it successfully. Phase 2 should wire Demo through this product only.
- `BeautyParameters` already provides the public fields and clamping behavior needed for slider mapping tests.
- `BeautyDemo` currently has only `BeautyDemoApp.swift`, `ContentView.swift`, and asset catalog metadata; there is no existing Demo feature structure to preserve.

### Established Patterns
- Swift files use Xcode default formatting and PascalCase filenames.
- Root contracts keep UI in `BeautyDemo` and SDK internals in `BeautySDK`.
- Demo state should be enum/value-driven where possible, with view-state or unit tests for category visibility, disabled availability, and slider normalization.

### Integration Points
- Replace `ContentView` with an editor shell rooted from `BeautyDemoApp`.
- Add Demo feature directories under `BeautyDemo/BeautyDemo/`, following `FRONTEND.md` where useful: `App/`, `Panel/`, `State/`, and `Support/` are relevant for Phase 2.
- Wire the local `BeautySDK` Swift Package into `BeautyDemo.xcodeproj` before importing `BeautySDK` from Demo source.
- Add tests for import boundaries, category/subcategory visibility, disabled control states, slider normalization, and reset behavior.

</code_context>

<specifics>
## Specific Ideas

- The first usable Demo shell should look like a real editor: static portrait placeholder preview, disabled Camera/Photo entries, and bottom categories.
- Beauty is the default selected category.
- The UI should be honest about the current no-op pipeline: parameters can update, but visual changes wait for later effect phases.
- Disabled controls should be visible enough for roadmap validation without turning the product UI into a verbose implementation report.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 2 scope. Camera/photo input remains Phase 3, Filters and presets remain Phase 5, core effects remain Phase 6, and advanced categories remain deferred per roadmap.

</deferred>

---

*Phase: 2-Demo Integration Shell*
*Context gathered: 2026-06-11T03:33:59Z*
