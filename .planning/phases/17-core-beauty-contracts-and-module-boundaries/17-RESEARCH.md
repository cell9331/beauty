---
phase: 17
slug: core-beauty-contracts-and-module-boundaries
status: complete
created: 2026-06-26
requirements: [CBT-01, CBT-02, CBT-03, MOD-01]
---

# Phase 17 - Research

## Objective

Finalize the v1.3 core beauty contract layer before implementation phases start. Phase 17 is documentation and boundary planning only: normalize the Meitu-style core beauty taxonomy, branch status vocabulary, Demo-vs-SDK ownership, module dependencies, deferred-family exclusions, and verification evidence gates.

## Source Findings

### Blueprint docs

- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` already lists the active Phase 17 families and branches, but its status vocabulary is mixed: `static/future`, `partial/future`, `static`, `planned-doc`, and `future`. It must be normalized to the strict four-state model from context decision D-01: `implemented`, `partial`, `blocked-by-geometry-output`, or `future`.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` still says every visible tool has one of three states: supported, static/unavailable, or future. That conflicts with the Phase 17 decision and should become a branch-status rule using the four allowed terms.
- `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` acceptance text says docs expose implemented, static, partial, or future. This should become implemented, partial, blocked-by-geometry-output, or future.
- `docs/meitu-function-blueprint/README.md`, `MINDMAP.md`, and `FEATURE_MATRIX.md` are already the right entry points for CBT-01. They should stay in place rather than being replaced by a new contract document.
- `docs/meitu-function-blueprint/features/` currently has only three family folders: `beauty-shaping`, `editor-shell`, and `skin-retouch`. This matches CBT-02 and should remain the only active folder set for v1.3.
- The family README files already separate editor shell, beauty shaping, and skin retouch. They need tighter ownership notes: one primary owner per branch, dependency notes, current `BeautyParameters` coverage, future parameter needs, and evidence expectations.

### Demo taxonomy and mappings

- `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift` already exposes the Meitu-style category order: `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛`.
- Supported Demo tools map to existing `BeautyControlID` values, including `faceSmall`, `faceSlim`, `chinLength`, `faceVShape`, `jawSlim`, `eyeSize`, `eyeYPosition`, `eyeDistance`, `eyeTailLift`, `mouthSize`, `mouthWidth`, `lipColor`, `smile`, `noseSlim`, `noseWingSlim`, `noseBridge`, and `noseTipSize`.
- Unsupported Demo tools are explicit static UI states from prior milestones. Phase 17 should not turn them into SDK capabilities; it should document them as branch-level future notes or subtool gaps.
- Demo shell ownership is already present in `BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift` and `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift`. The contract should enumerate category rails, labels, badges, slider mapping, compare/debug, cancel/confirm, input routing, and parameter snapshots as app-side responsibilities.

### SDK public contract

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` currently covers:
  - Skin: `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen`.
  - Color/filter-adjacent controls: brightness, contrast, saturation, temperature, tint, exposure, highlight, shadow, filter ID, and filter intensity.
  - Face shape: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`.
  - Eyes: `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`.
  - Nose: `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`.
  - Mouth/lips: `mouthSize`, `mouthWidth`, `smile`, `lipColor`.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectDomain.swift` uses product-neutral domains: `skin`, `color`, `filter`, `faceShape`, `eyes`, `nose`, `mouth`, and `lipColor`. The SDK should keep this naming style instead of adopting Meitu-specific branch names.
- `BeautyEffectResolver` and existing tests provide provider/resolver evidence for geometry domains, but Phase 17 context decision D-11 says that evidence is only partial until public-facade saved-image geometry output exists.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` is the public facade path. The local renderer can already produce visible output for existing non-geometry cases, but current face geometry does not yet flow through public facade detection plus render integration into saved output.

### Boundary evidence

- `BeautySDK/Package.swift` declares `BeautyExampleRenderer` as an executable depending on public `BeautySDK`.
- Phase 16 established the renderer path, ignored output directory, and geometry-output limitation. Phase 17 should consume that boundary but should not add renderer cases, fixtures, or generated PNG evidence.
- Demo and renderer boundary checks should scan for forbidden imports of internal SDK targets: `BeautyCore`, `BeautyDetection`, `BeautyEffects`, `BeautyRender`, and `BeautyResources`.
- No new SwiftUI screens are required. A Phase 17 execution should have an empty code diff under `BeautyDemo` and `BeautySDK/Sources` unless the executor records an explicit, contract-level reason.

## Implementation Considerations

- Keep edits in the existing blueprint files. Creating a replacement contract would make future agents compare two sources of truth.
- Use branch-level rows in `FEATURE_MATRIX.md`. Put unsupported subtools and future parameter needs in notes instead of making a row for every visible Demo tool.
- Use one primary owner per branch with dependencies, for example: beauty shaping primarily `BeautyEffects`, depending on `BeautyDetection` landmarks and `BeautyRender` warp output.
- Use `BeautyResources` only as a dependency or future owner where resources are genuinely needed. Do not promote filters, makeup, stickers, templates, downloads, VIP, or entitlement systems into v1.3.
- Do not update root contracts unless Phase 17 execution changes an actual architecture, design, frontend, security, reliability, product, or quality contract. If the execution only clarifies existing boundaries, root docs can remain unchanged.

## Recommended Plan Split

### 17-01: Normalize blueprint contracts

- Normalize `FEATURE_MATRIX.md`, `DELIVERY_BOUNDARY.md`, and `shared/IMPLEMENTATION_PRINCIPLES.md` to the four allowed status terms.
- Tighten `README.md`, `MINDMAP.md`, `MODULES.md`, and family README files so every active branch has a primary owner, dependency notes, current public parameter coverage, future parameter needs, and evidence expectations.
- Preserve the existing feature-folder set: `editor-shell`, `beauty-shaping`, and `skin-retouch`.

### 17-02: Verify contracts and planning ledgers

- Verify status vocabulary, branch/family scope, Demo and renderer import boundaries, no new SwiftUI screens, and root-contract consistency.
- Update requirement traceability and planning ledgers only after the contract checks pass.
- Record that implementation phases inherit the evidence ladder and geometry-output limitation.

## Validation Architecture

Phase 17 validation should sample documentation and boundary evidence rather than image output.

| Area | Validation |
| --- | --- |
| Status vocabulary | Scan active blueprint status docs for removed labels such as `static/future`, `partial/future`, `static/unavailable`, and `planned-doc`; scan for the allowed four statuses. |
| Active families | Verify `docs/meitu-function-blueprint/features/` contains only `beauty-shaping`, `editor-shell`, and `skin-retouch`. |
| Deferred families | Scan blueprint delivery docs for explicit exclusion of Home/discovery, resource/style systems, AI/background, video/body, gallery/account, search, VIP, payment, and entitlement behavior. |
| Demo boundary | Scan Demo sources and tests for imports of internal SDK targets. |
| Renderer boundary | Scan `BeautySDK/Sources/BeautyExampleRenderer` for imports beyond public `BeautySDK`; no SwiftUI/UIKit imports should be introduced. |
| Code scope | Verify no Phase 17 code diff exists under `BeautyDemo` or `BeautySDK/Sources` unless a root-contract change explicitly justifies it. |
| Root contracts | If root docs change, require the execution summary to cite the specific changed contract; otherwise verify root docs are untouched. |
| Traceability | Plans and execution summaries must cover CBT-01, CBT-02, CBT-03, MOD-01, and decisions D-01 through D-12. |

## Research Conclusion

Phase 17 can be completed as a targeted contract normalization and verification phase. No implementation spike is needed. The main ambiguity is geometry status language: provider/resolver evidence should remain `partial`, while visible saved-output completion remains blocked until public facade detection plus geometry render integration exists.
