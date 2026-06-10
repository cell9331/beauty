# Phase 1: SDK Foundation and Public Facade - Context

**Gathered:** 2026-06-10
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase creates the host-app-importable SDK foundation: a local `BeautySDK` Swift Package, required internal targets, public facade models, typed errors, a no-op processing path, and package tests. It does not deliver visual beauty effects, Demo UI replacement, camera/photo input, Vision detection, LUT resources, built-in preset packs, makeup, segmentation, body shaping, stickers, style effects, or video export.

</domain>

<decisions>
## Implementation Decisions

### Public API Shape
- **D-01:** Use overloaded `process(...)` APIs for the two foundation processing paths: `process(pixelBuffer:orientation:parameters:)` and `process(image:orientation:parameters:)`.
- **D-02:** The primary processing APIs return media objects directly: `CVPixelBuffer` for realtime/frame-style input and `CIImage` for still-image input.
- **D-03:** `BeautyEngine` does not own caller parameter state. Every process call receives an explicit immutable `BeautyParameters` snapshot.
- **D-04:** Expose a lightweight public `BeautyResult` model through the facade for future warnings/metrics/result metadata, but do not make the Phase 1 primary `process(...)` APIs return it.

### No-op Output Semantics
- **D-05:** Even in the no-op foundation, return a new SDK-created or SDK-owned output object rather than the exact same input reference.
- **D-06:** If the no-op copy/output path cannot support an input format or copy operation, return a typed `BeautyError` such as `.unsupportedPixelFormat` or `.invalidInput`; do not silently return the original input.
- **D-07:** Tests must prove no-op preservation with pixel-level equality or a fixed documented tolerance against fixtures, not only dimensions, format, or non-empty output.
- **D-08:** Document and test that the output is SDK-created and readable for the current processing result lifecycle without exposing internal buffer-pool details.

### Parameter and Preset Validation Strategy
- **D-09:** Clamp ordinary out-of-range numeric parameters to their documented public ranges before rendering.
- **D-10:** Reset `NaN` and infinity values to the documented no-op default and surface them as validation warnings or diagnostics candidates; non-finite values must not enter rendering.
- **D-11:** Preset JSON decoding ignores unknown fields for forward compatibility, and unknown fields must not trigger any behavior.
- **D-12:** Presets that reference unknown `filterId` or resource IDs fail validation with a typed error such as `.resourceNotFound(id)` or `.presetDecodeFailed(...)`; do not partially apply those presets.
- **D-13:** Phase 1 implements `BeautyPreset` model, decoding, and validation only. Built-in Natural/Clear/Refined/Male Natural/ID Photo Natural preset registry and resource-backed preset delivery belong to Phase 5.

### the agent's Discretion
No areas were delegated to the agent. Follow the decisions above and the canonical references below.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` — Repository navigation, reading order, task routing, and record/verification rules.
- `PLANS.md` — Current execution ledger and existing tech debt, including `BeautySDK` package/test gaps.
- `.planning/PROJECT.md` — Active GSD project definition and confirmed SDK + rich Demo direction.
- `.planning/REQUIREMENTS.md` — v1 requirements; Phase 1 covers `SDK-01` through `SDK-07`.
- `.planning/ROADMAP.md` — Phase 1 goal, success criteria, and four plan slots.
- `.planning/STATE.md` — Current project focus and known blockers.

### Current Codebase Facts
- `.planning/codebase/STACK.md` — Current toolchain and the fact that no Swift Package or tests exist yet.
- `.planning/codebase/ARCHITECTURE.md` — Main-worktree architecture map and missing target SDK layer.
- `.planning/codebase/TESTING.md` — Current absence of tests and expected future `swift test --package-path BeautySDK` command.

### Current Contracts
- `ARCHITECTURE.md` — Package boundaries, target dependency direction, facade responsibility, and SDK/Demo import invariants.
- `DESIGN.md` — `BeautyConfiguration`, `BeautyParameters`, `BeautyPreset`, `BeautyFrame`, `BeautyResult`, and `BeautyEngine` design decisions.
- `SECURITY.md` — Public input validation, preset/resource trust boundaries, redaction, and no-network privacy posture.
- `RELIABILITY.md` — `BeautyError` surface, typed recoverable failures, diagnostics, and no-crash reliability policy.
- `PRODUCT_SENSE.md` — Host app integration acceptance criteria and default no-op behavior.

### Historical Background
- `docs/03_architecture_spm_skeleton.md` — Background SPM skeleton and rationale for one package with multiple targets.
- `docs/05_public_api_design.md` — Background public API draft for `BeautyEngine`, `BeautyConfiguration`, and processing calls.
- `docs/06_beauty_parameters_spec.md` — Background 31-field parameter model and UI/SDK range mapping.
- `docs/superpowers/specs/2026-05-25-sdk-foundation-design.md` — Prior SDK foundation design; useful for implementation sequencing, but root contracts and this context are authoritative on current decisions.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautyDemo/BeautyDemo.xcodeproj` — Existing buildable iOS app project and scheme named `BeautyDemo`; Phase 1 may use it for import-boundary scans or later package wiring, but the SDK package is the primary deliverable.
- Root contract documents — Already define target names, dependency direction, public type names, parameter fields, errors, validation, and acceptance criteria.

### Established Patterns
- The main worktree currently has no `BeautySDK/Package.swift`, no SDK targets, and no tests. Planning must not assume any SDK implementation already exists.
- The repository uses documentation-first contracts. When implementation changes public API, architecture, safety, reliability, or product behavior, update the owning root document rather than duplicating rules in `AGENTS.md`.
- Builds should use explicit iOS Simulator destinations for Xcode evidence because generic `xcodebuild` may select an incompatible destination.

### Integration Points
- Create the new package at `BeautySDK/Package.swift` with source under `BeautySDK/Sources/**` and tests under `BeautySDK/Tests/**`.
- Verify package behavior with `swift test --package-path BeautySDK` after the package exists.
- Keep Demo code from importing `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources`; host-app-style tests should import only `BeautySDK`.

</code_context>

<specifics>
## Specific Ideas

- The user confirmed that the product should be SDK-centered, split into modules, and demonstrated from the Demo through the public facade.
- The broad Meitu/Xingtu-style feature set remains the product direction, but Phase 1 is intentionally foundation-only.
- Existing historical docs are useful background and should be mined where relevant, but conflicts resolve to root contracts, roadmap requirements, and the decisions in this context.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 1 scope. Built-in preset registry and named v1 presets are not a new deferred idea; they are already planned for Phase 5.

</deferred>

---

*Phase: 1-SDK Foundation and Public Facade*
*Context gathered: 2026-06-10*
