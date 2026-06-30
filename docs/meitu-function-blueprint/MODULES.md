# Module Boundaries

## Target Ownership

| Module | Owns | Must not own |
| --- | --- | --- |
| `BeautyDemo/Editor` | Editor shell, preview chrome, compare/debug buttons, cancel/confirm, input routing, background-protection affordance | Effect algorithms, Metal passes, Vision detector state |
| `BeautyDemo/Panel` | Category rail, tool rail, labels, sliders, badges, visible slider mapping | Camera/session internals, SDK internal targets |
| `BeautyDemo/State` | App-side parameter store, parameter snapshot state, source state, route state | Internal SDK control points or raw landmarks |
| `BeautySDK` facade | Stable host-facing engine, resources facade, public parameter/result models | SwiftUI pages, Meitu product-specific screen state |
| `BeautyCore` | Parameters, errors, diagnostics, frame metadata, public-safe summaries | SwiftUI, Vision, Metal pass implementation |
| `BeautyDetection` | Face/landmark/segmentation/body detection internals | UI overlays, render pass ownership |
| `BeautyRender` | Metal/Core Image render graph, texture lifecycle, shader passes | Product category taxonomy |
| `BeautyEffects` | Effect resolution, safety caps, geometry providers, style effect composition | UI state, commercial/product routing |
| `BeautyResources` | Bundled resource manifests and validation when a promoted branch genuinely needs resources | Deferred product/resource UI ownership in v1.3 |

## Dependency Direction

```text
BeautyDemo
  -> BeautySDK facade
    -> BeautyEffects
      -> BeautyDetection
      -> BeautyRender
      -> BeautyResources
        -> BeautyCore
```

Demo may describe Meitu-like functions, but SDK APIs should stay product-neutral where possible. Example: `eyeSize` is public SDK language; `眼睛/大小` is Demo taxonomy language.

## Branch Ownership

| Family | Branch | Primary owner | Dependencies | Boundary |
| --- | --- | --- | --- | --- |
| Editor shell | Input routing | `BeautyDemo/Editor` | public `BeautySDK` facade | Demo selects photo/camera source and passes normalized metadata; SDK does not own route UI. |
| Editor shell | Preview chrome | `BeautyDemo/Editor` | Public result/debug summaries | Compare/debug affordances, labels, and badges stay app-side and read-only. |
| Editor shell | Bottom panel | `BeautyDemo/Panel` | `BeautyDemo/State`, `BeautyParameters` | Category rail, tool rail, labels, badges, and slider mapping are Demo-owned. |
| Editor shell | Commit flow | `BeautyDemo/State` | `BeautyParameterStore` | Cancel/confirm and parameter snapshot rollback/apply stay app-side. |
| Beauty shaping | `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, `眉毛` | `BeautyEffects` | `BeautyDetection` landmarks/pose and `BeautyRender` unified warp | Meitu branch labels stay in blueprint/Demo taxonomy; SDK domains stay product-neutral (`faceShape`, `eyes`, `nose`, `mouth`). |
| Skin retouch | Basic skin | `BeautyEffects` | `BeautyRender` color/skin path and public `BeautySDK` facade | Current skin parameters are visible through facade output and local renderer cases. |
| Skin retouch | Skin repair, Teeth/hairline | `BeautyEffects` if promoted | Future local algorithm, landmarks, segmentation, or resources as explicitly designed | No cloud repair, remote AI transfer, or active resource ownership by default. |

## Planning Rule

Each future implementation phase must declare:

1. Demo surface changed.
2. SDK target changed.
3. Public parameter/API change, if any.
4. Resource/schema change, if any.
5. Privacy/reliability risk.
6. Unit/integration verification evidence.
7. Example-image output evidence when the module has visible image output.
8. Whether provider/resolver evidence is only `partial` or public facade saved-image output can support `implemented`.

## Example Image Verification Ownership

`BeautyExampleRenderer` is a macOS-only SwiftPM executable used for local SDK verification. It imports only the public `BeautySDK` facade, reads portrait fixtures from `example-images/input/`, runs `BeautyEngine.processResult(image:metadata:parameters:)`, and writes watermarked outputs to `example-images/out/`.

The tool validates public processing behavior. It must not reach into internal SDK targets or Demo SwiftUI state.

Phase 19 strengthens `BeautyEffects` provider/resolver/degradation evidence for beauty-shaping branches through SwiftPM XCTest only. That evidence remains provider-level partial evidence until public facade detection plus geometry render integration produces saved geometry outputs through `BeautyExampleRenderer`.

Filters, makeup, stickers, templates, downloads, paid membership, checkout, and account-gated behavior remain deferred product/resource areas, not active v1.3 ownership.

## Phase 20 Editor-Shell Closeout Evidence

Editor-shell support is implemented app-side and verified through existing Demo tests and scans:

- `BeautyDemoViewStateTests` covers route state, input-state matrix, category rail, tool rail, slider mapping, disabled/future honesty, compare/debug titles, cancel restore, and editor taxonomy.
- `BeautyParameterStoreTests` covers parameter snapshot construction, preset/import/custom source state, reset behavior, and public `BeautyParameters` mapping.
- `CompareStateTests` covers compare/debug toggles, preservation of editor selection/parameters, and redacted debug rows.
- `BeautyDemoImportBoundaryTests` and `InputPipelinePrivacyTests` keep Demo code and tests on the public `BeautySDK` facade and prevent internal target imports or sensitive local payload exposure.

Phase 20 closeout must not add additional SwiftUI screens, routes, app-state behavior, public parameters, renderer cases, network transfer, checkout, paid membership, or account-gating logic.
