# Phase 3: Realtime and Still Input Slice - Context

**Gathered:** 2026-06-12T01:26:55Z
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase turns the Phase 2 Demo shell into a usable input surface for realtime camera frames and still images. The Demo must activate Camera and Photo mode switching, request protected-resource access from the app layer, send camera pixel buffers and still images through the public `BeautySDK` no-op processing paths, and show stable permission, loading, compare, and recoverable-error states.

Phase 3 does not implement real beauty effects, Vision face detection, coordinate/mirroring correction beyond passing explicit metadata, filters, presets, debug overlays, export, stickers, makeup, segmentation, or video output. Those remain in later roadmap phases.

</domain>

<decisions>
## Implementation Decisions

### Camera and Photo Entry Flow
- **D-01:** Keep the current editor shell as the first screen. Do not launch directly into Camera and do not request camera permission on app launch.
- **D-02:** Turn the Phase 2 disabled Camera and Photo entries into clickable mode switches.
- **D-03:** Camera permission is requested only after the user taps Camera.
- **D-04:** The Camera mode replaces the existing shell preview fixture area with live camera preview while keeping the top Camera/Photo entries, bottom category rail, and parameter panel visible.
- **D-05:** The Photo mode supports the system Photo picker for the real user path and a deterministic test fixture path for tests and previews.

### Permission and Unavailable States
- **D-06:** If Camera permission is denied or restricted, keep the editor shell visible, leave Camera selected, and show a permission explanation plus a Settings action in the preview area. Photo remains available.
- **D-07:** If Camera is unavailable or session setup fails, show the unavailable state in the preview area and keep Photo as the fallback path.
- **D-08:** Photo picker cancellation is not an error. Reading or decoding failures show a non-blocking message and preserve the current image or fixture.
- **D-09:** Info.plist purpose strings should use short product copy that explains camera/photo access for local or on-device preview and editing. Do not imply upload or remote processing.

### Compare, Loading, and Error Behavior
- **D-10:** Camera and Photo share the same before/after compare toggle. It switches between input and output without resetting parameters or changing crop/orientation.
- **D-11:** While Photo processing is loading, keep the previous image or fixture visible and overlay a loading state in the preview area. On success, replace the processed output. On failure, keep the previous result.
- **D-12:** Camera and Photo share a lightweight error banner/status surface. Preserve the last usable visual state: Camera keeps the last successful frame or current live input, and Photo keeps the previous result or fixture.
- **D-13:** Internal error mapping may use `BeautyError.code`, but UI copy must be user-friendly and must not expose raw framework errors or sensitive paths.
- **D-14:** Slider values update immediately while processing is active. The pipeline uses the latest parameter snapshot: Camera drops stale frames/snapshots, and Photo cancels or marks stale work before reprocessing.

### the agent's Discretion
No areas were delegated to the agent. Follow the decisions above and the canonical references below.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository reading order, task routing, verification, and record rules.
- `PLANS.md` — Current work ledger, Phase 1/2 completion evidence, and open tech debt.
- `.planning/PROJECT.md` — SDK-centered product direction, local-first privacy posture, and Demo validation role.
- `.planning/REQUIREMENTS.md` — Phase 3 covers `PIPE-01`, `PIPE-02`, `PIPE-03`, `PIPE-04`, `PIPE-06`, `PIPE-08`, and `DEMO-01`.
- `.planning/ROADMAP.md` — Phase 3 goal, success criteria, and four planned plan slots.
- `.planning/STATE.md` — Current focus, progress, and known blockers.
- `.planning/phases/01-sdk-foundation-and-public-facade/01-CONTEXT.md` — Locks public facade, explicit `BeautyParameters`, no-op output semantics, and typed error behavior.
- `.planning/phases/02-demo-integration-shell/02-CONTEXT.md` — Locks editor shell shape, visible Camera/Photo entries, disabled-state copy, category/panel behavior, and parameter snapshot ownership.

### Current Contracts
- `ARCHITECTURE.md` — Demo may depend on `BeautySDK` only; SDK internals must stay UI-free.
- `DESIGN.md` — `BeautyEngine.process(pixelBuffer:orientation:parameters:)`, `BeautyEngine.process(image:orientation:parameters:)`, `BeautyFrame`, parameter snapshots, and realtime caller responsibilities.
- `FRONTEND.md` — Camera/Photo directory expectations, preview responsibilities, async UI states, backpressure, compare behavior, and Demo UI test expectations.
- `SECURITY.md` — Camera/photo protected-resource rules, Info.plist purpose strings, permission states, local-first boundary, and no-upload posture.
- `RELIABILITY.md` — Synchronous SDK process call constraints, realtime backpressure, forbidden realtime `UIImage`, error handling, and memory/performance rules.
- `PRODUCT_SENSE.md` — Realtime camera and still-image user journeys, compare acceptance, loading/error acceptance, and responsiveness expectations.
- `QUALITY_SCORE.md` — Current quality gates and Phase 3 repair priorities.

### Codebase Maps
- `.planning/codebase/STRUCTURE.md` — Historical map of directory conventions; treat as partially stale after Phase 1/2 and verify against current code.
- `.planning/codebase/INTEGRATIONS.md` — Historical integration map; useful for protected-resource gaps but partially stale after Phase 1/2.
- `.planning/codebase/TESTING.md` — Historical testing map; useful for command conventions but partially stale after Phase 1/2.

### Current Code
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` — Generated Info.plist build settings currently lack Camera/Photo usage description keys.
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` — Current shell layout to preserve while activating Camera/Photo modes.
- `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift` — Current Camera/Photo disabled entries and preview fixture copy to replace or evolve.
- `BeautyDemo/BeautyDemo/Panel/BeautyModeEntryView.swift` — Current disabled mode entry component to make interactive.
- `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` — App-side parameter snapshot owner that Phase 3 pipelines should read from.
- `BeautySDK/Sources/BeautyCore/Engine/BeautyEngine.swift` — Public no-op pixel-buffer and image processing APIs for Phase 3 integration.
- `BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift` — Existing frame metadata model with source, orientation, mirroring, timestamp, and extent.
- `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift` — Typed error codes and redacted descriptions for UI-friendly mapping.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `EditorShellView` already owns the first-screen shell, preview region, panel, and category rail. Phase 3 should evolve this shell rather than replace it with a separate first screen.
- `DemoFixtures.disabledModes` and `BeautyModeEntryView` provide the current Camera/Photo entry surface. They are the natural integration point for mode switching.
- `BeautyParameterStore.parametersSnapshot` already provides normalized public `BeautyParameters` values for SDK calls.
- `BeautyEngine` already exposes public no-op pixel-buffer and image paths through `BeautySDK`.
- `BeautyError.code` and redacted descriptions exist for recoverable error mapping.

### Established Patterns
- Demo view state is tested with XCTest rather than simulator UI automation in Phase 2. Phase 3 can continue with view-state and pipeline tests, and add simulator checks only where permission or Xcode integration requires it.
- Demo source and tests must import `BeautySDK` only, never internal SDK targets.
- Public SDK APIs are synchronous today; realtime callers must run them off the main actor with bounded in-flight work.
- Current generated Info.plist settings live in `project.pbxproj`; purpose strings must be added before protected-resource access.

### Integration Points
- Add Camera-specific app code under `BeautyDemo/BeautyDemo/Camera/`, matching `FRONTEND.md`.
- Add still-image input/editor pipeline code under `BeautyDemo/BeautyDemo/Editor/`, `State/`, or a narrow new image-input folder according to planner judgment.
- Connect Camera/Photo mode state to the existing shell preview area.
- Connect realtime and still-image pipelines to `BeautyParameterStore.parametersSnapshot` without making the SDK own app UI state.
- Add tests for mode switching, permission/unavailable state, Photo cancellation/failure semantics, compare state, loading state, stale-result behavior, and facade-only imports.

</code_context>

<specifics>
## Specific Ideas

- The Demo should feel like the same editor becoming live, not a new app flow.
- Camera permission is user-intent driven: tapping Camera is the moment to ask.
- Photo should be real enough for users through the system picker and deterministic enough for tests through a fixture path.
- Permission and unavailable states should live in the preview area so the top mode switcher, bottom category rail, and parameter panel remain stable.
- Compare, loading, and error behavior should preserve continuity: keep old visuals when possible, avoid clearing the preview, and avoid surprising mode switches.
- User-facing error copy should be friendly; implementation may keep `BeautyError.code` for stable test assertions and mapping.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 3 scope. Detection overlays and no-face/partial-face handling remain Phase 4, filters and presets remain Phase 5, real beauty effects remain Phase 6, and richer debug/export/demo QA flows remain Phase 7.

</deferred>

---

*Phase: 3-Realtime and Still Input Slice*
*Context gathered: 2026-06-12T01:26:55Z*
