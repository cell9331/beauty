# Module Boundaries

## Target Ownership

| Module | Owns | Must not own |
| --- | --- | --- |
| `BeautyDemo/Editor` | Editor shell, preview, compare/debug buttons, cancel/confirm, input mode routing | Effect algorithms, Metal passes, Vision detector state |
| `BeautyDemo/Panel` | Tool/category rails, sliders, badges, visible parameter mapping | Camera/session internals, SDK internal targets |
| `BeautyDemo/State` | App-side parameter store, source state, route state | Internal SDK control points or raw landmarks |
| `BeautySDK` facade | Stable host-facing engine, resources facade, public parameter/result models | SwiftUI pages, Meitu product-specific screen state |
| `BeautyCore` | Parameters, errors, diagnostics, frame metadata, public-safe summaries | SwiftUI, Vision, Metal pass implementation |
| `BeautyDetection` | Face/landmark/segmentation/body detection internals | UI overlays, render pass ownership |
| `BeautyRender` | Metal/Core Image render graph, texture lifecycle, shader passes | Product category taxonomy |
| `BeautyEffects` | Effect resolution, safety caps, geometry providers, style effect composition | UI state, entitlement/product routing |
| `BeautyResources` | LUT/preset/makeup/sticker/model manifests and validation | Business download/payment UI |

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

## Planning Rule

Each future implementation phase must declare:

1. Demo surface changed.
2. SDK target changed.
3. Public parameter/API change, if any.
4. Resource/schema change, if any.
5. Privacy/reliability risk.
6. Unit/integration verification evidence.
7. Example-image output evidence when the module has visible image output.

## Example Image Verification Ownership

`BeautyExampleRenderer` is a macOS-only SwiftPM executable used for local SDK verification. It imports only the public `BeautySDK` facade, reads portrait fixtures from `example-images/input/`, runs `BeautyEngine.processResult(image:metadata:parameters:)`, and writes watermarked outputs to `example-images/out/`.

The tool validates public processing behavior. It must not reach into internal SDK targets or Demo SwiftUI state.
