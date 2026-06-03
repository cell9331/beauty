---
last_mapped: 2026-06-03
last_mapped_commit: 5e20ce8ea81763f47b5194a69f90ab43a2eab675
focus: arch
mapping_mode: inline sequential fallback
---

# Architecture

## Summary

The current mainline architecture has two layers:

1. A small implemented iOS SwiftUI demo app under `BeautyDemo/`.
2. A much richer root documentation system that defines the intended SDK architecture.

There is no implemented `BeautySDK` package in the main worktree yet. Treat root docs as contracts and the Swift code as the current minimal executable shell.

## Implemented Runtime Architecture

The implemented runtime flow is:

```text
BeautyDemoApp
-> WindowGroup
-> ContentView
-> VStack
-> Image(systemName: "globe") + Text("Hello, world!")
```

Evidence:

- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` declares `@main struct BeautyDemoApp: App`.
- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` creates a `WindowGroup` containing `ContentView()`.
- `BeautyDemo/BeautyDemo/ContentView.swift` defines `struct ContentView: View`.
- `BeautyDemo/BeautyDemo/ContentView.swift` uses only local SwiftUI view composition.

There is no implemented camera, editor, SDK facade, detection pipeline, render graph, or parameter store in the main worktree.

## Xcode Project Architecture

`BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` defines:

- One `PBXProject`.
- One native target named `BeautyDemo`.
- One product, `BeautyDemo.app`.
- File-system synchronized root group for `BeautyDemo/BeautyDemo`.
- Build phases for sources, frameworks, and resources.
- Empty `packageProductDependencies`.
- Debug and Release build configurations.

`xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` confirmed the single target and scheme `BeautyDemo`.

## Intended SDK Architecture

`ARCHITECTURE.md` defines the intended first-version package as one root Swift Package named `BeautySDK` with multiple targets:

- `BeautyCore`.
- `BeautyDetection`.
- `BeautyRender`.
- `BeautyEffects`.
- `BeautyResources`.
- Facade target `BeautySDK`.

The intended dependency direction is:

```text
BeautyCore
    ^
    |-- BeautyResources
    |-- BeautyDetection
    |-- BeautyRender
           ^
BeautyEffects uses detection models and render primitives
    ^
BeautySDK
    ^
BeautyDemo
```

That architecture is contractual but not implemented in the main worktree. Downstream planning should create `BeautySDK/Package.swift` before assuming these modules exist.

## Domain Boundaries

Root contracts assign ownership as follows:

- `ARCHITECTURE.md` owns target boundaries and dependency direction.
- `DESIGN.md` owns public data models, state machines, render graph, parameters, and coordinate systems.
- `FRONTEND.md` owns Demo SwiftUI composition, camera/editor UI state, and presentation rules.
- `SECURITY.md` owns input validation, privacy posture, resource trust boundaries, permissions, and logging redaction.
- `RELIABILITY.md` owns typed errors, degradation, observability, frame dropping, reset, and performance budgets.
- `PRODUCT_SENSE.md` owns user journeys and acceptance criteria.
- `QUALITY_SCORE.md` owns quality gates and scan commands.
- `PLANS.md` owns active, completed, and tech debt tracking.

`AGENTS.md` is only the navigation entry and explicitly says not to put deep business rules there.

## Data Flow Status

Implemented data flow is only SwiftUI view rendering.

Planned but not implemented data flows are documented:

- Realtime camera path in `ARCHITECTURE.md` and `PRODUCT_SENSE.md`.
- Offline image path in `ARCHITECTURE.md` and `PRODUCT_SENSE.md`.
- Parameter path from Demo controls to `BeautyParameters` in `DESIGN.md` and `FRONTEND.md`.
- Detection and frame-processing state machines in `DESIGN.md`.

No current source file processes `CMSampleBuffer`, `CVPixelBuffer`, `CVMetalTexture`, `UIImage`, or `CGImage`.

## Architectural Invariants To Preserve

Important invariants from the root contracts:

- SDK code must not contain UI pages.
- Demo must depend on the public `BeautySDK` facade, not internal targets.
- Realtime rendering must not use `UIImage` as an intermediate.
- Detection and rendering must stay decoupled.
- Geometry effects must merge into unified `WarpControlPoint` values and a single `FaceWarpPass`.
- Public parameters must use normalized ranges.
- Diagnostics start in `BeautyCore/Diagnostics`, not a separate package.

These are not yet enforceable through code because the SDK package is absent. They should become compile-time and test-time checks as the package is created.

## Architectural Risk

The repository has strong intended architecture but very little executable architecture. The main risk for planning is accidentally treating docs as implemented state. For code work, first establish the Swift Package skeleton and tests, then wire the Demo to the facade.
