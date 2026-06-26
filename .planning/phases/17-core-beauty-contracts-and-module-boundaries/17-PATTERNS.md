---
phase: 17
slug: core-beauty-contracts-and-module-boundaries
status: complete
created: 2026-06-26
---

# Phase 17 - Pattern Map

## Planning Pattern

Phase 17 follows the Phase 16 split:

- One wave writes or normalizes the core contract artifacts.
- A later wave verifies the contract against root docs, current code boundaries, and planning ledgers.
- Generated artifacts are Markdown only. No image output, renderer case, SwiftUI screen, or SDK algorithm change belongs in this phase.

## Contract Files

| File | Existing role | Phase 17 pattern |
| --- | --- | --- |
| `docs/meitu-function-blueprint/README.md` | Blueprint entry and reading order. | Keep as the entry point; clarify active core beauty scope and strict status vocabulary only if needed. |
| `docs/meitu-function-blueprint/MINDMAP.md` | Core taxonomy tree. | Keep branch-level taxonomy; do not expand into deferred families. |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | Branch status and ownership table. | Primary target for strict four-state status, current parameter coverage, future parameter needs, and evidence expectation. |
| `docs/meitu-function-blueprint/MODULES.md` | Module ownership and dependency direction. | Normalize to one primary owner per branch with dependency notes; keep SDK language product-neutral. |
| `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md` | Milestone deliverables, exclusions, and acceptance signals. | Update acceptance language to the four-state model and preserve no-new-UI/no-resource/no-AI exclusions. |
| `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` | Shared branch documentation rules. | Replace three-state visible-tool language with branch-level status and evidence ladder rules. |
| `docs/meitu-function-blueprint/features/editor-shell/README.md` | Demo-side editor shell contract. | Enumerate app-owned rails, labels, badges, slider mapping, compare/debug, cancel/confirm, input routing, and parameter snapshots. |
| `docs/meitu-function-blueprint/features/beauty-shaping/README.md` | Beauty shaping family contract. | List branch-level owners/dependencies and separate existing public parameters from future gaps. |
| `docs/meitu-function-blueprint/features/skin-retouch/README.md` | Skin retouch family contract. | Keep basic skin separate from future repair/teeth/hairline capabilities. |

## Current Code Patterns

| Area | File | Pattern |
| --- | --- | --- |
| Public facade | `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | Implementation phases should use public `BeautyEngine.processResult(...)` evidence when claiming visible output. Phase 17 only documents this requirement. |
| Public parameters | `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | Public parameter names are product-neutral and normalized; branch docs should cite current coverage instead of inventing Meitu-specific SDK names. |
| Effect domains | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectDomain.swift` | Product-neutral SDK domains are `skin`, `color`, `filter`, `faceShape`, `eyes`, `nose`, `mouth`, and `lipColor`. |
| Resolver evidence | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | Provider/resolver behavior can support `partial` geometry status but not saved-output visual completion. |
| Renderer evidence | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | Renderer imports public `BeautySDK` only and writes ignored local outputs. Do not add cases in Phase 17. |
| Demo taxonomy | `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift` | Meitu Chinese category names and supported/unsupported controls live in Demo taxonomy. SDK APIs stay neutral. |
| Demo state | `BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift` | Parameter snapshots, cancel/confirm, and app-side state remain Demo responsibilities. |

## Verification Patterns

Use static scans instead of builds for Phase 17 because the phase changes documentation and planning contracts only.

- Status normalization: scan active blueprint docs for old mixed labels and allowed new labels.
- Folder scope: use a Node directory check to ensure only `beauty-shaping`, `editor-shell`, and `skin-retouch` exist under active feature families.
- Import boundary: scan Demo and renderer sources for internal SDK imports.
- Code scope: check `git diff --name-only -- BeautyDemo BeautySDK/Sources` before closeout.
- Root contracts: if root docs change, cite why; otherwise record that root docs remained unchanged.
- Planning traceability: scan Phase 17 plans, summaries, requirements, roadmap, state, and `PLANS.md` for CBT-01, CBT-02, CBT-03, MOD-01, and `blocked-by-geometry-output`.

## Anti-Patterns

- Do not create a second replacement blueprint when existing docs can be normalized in place.
- Do not mark geometry-heavy branches `implemented` based only on provider or resolver tests.
- Do not add public SDK parameters without updating `DESIGN.md` and an owning acceptance contract.
- Do not let Meitu Chinese branch names leak into public SDK model/domain names.
- Do not promote `BeautyResources` into active v1.3 ownership for filters, makeup, stickers, templates, downloads, VIP, payment, or entitlements.
- Do not add SwiftUI screens, renderer cases, fixtures, or image evidence in Phase 17.
