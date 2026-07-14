# Phase 02: Demo Integration Shell - Pattern Map

**Mapped:** 2026-06-11
**Purpose:** Ground Phase 2 plans in the current main-worktree codebase and approved Phase 2 contracts.

## Current Implementation Surface

The SDK foundation exists, but the Demo app is still the default SwiftUI shell:

- `BeautySDK/Package.swift` exposes a library product named `BeautySDK`.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` defines the 31-field public parameter model that Phase 2 sliders map into.
- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` launches `ContentView()`.
- `BeautyDemo/BeautyDemo/ContentView.swift` contains the default "Hello, world!" template.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` has no local Swift Package reference, no `BeautySDK` product dependency, no Demo test target, and an empty app Frameworks build phase.
- The Xcode project uses `PBXFileSystemSynchronizedRootGroup` for `BeautyDemo/BeautyDemo`, so new app Swift files should live under that directory instead of requiring broad source-build-phase churn.

## Closest Existing Analogs

| Planned file / area | Closest existing analog | Use / constraint |
|---------------------|-------------------------|------------------|
| Demo app entry | `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` | Keep `@main` in one app entry and route `WindowGroup` to the editor shell. |
| Template route removal | `BeautyDemo/BeautyDemo/ContentView.swift` | Replace or retire the template route; the final shell must not contain `Hello, world!`. |
| Local package wiring | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` | Add only the package reference, product dependency, framework build file, and test target objects needed for Phase 2. |
| App feature directories | `FRONTEND.md` recommended directory | Use `Editor/`, `Panel/`, `State/`, and `Support/` for Phase 2; do not introduce `Camera/` implementation in this phase. |
| Parameter state | `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | Map UI display values into existing SDK fields only; normalize `0...100` to `0...1` and `-100...100` to `-1...1`. |
| Unit tests | `BeautySDK/Tests/**` | Use XCTest style with deterministic value assertions and import-boundary checks. |
| Planning format | Phase 1 `01-*.md` plans | Keep frontmatter, `<tasks>`, `<threat_model>`, `<verification>`, and explicit acceptance criteria. |

## Concrete Existing Code Excerpts

`BeautyDemo/BeautyDemo/BeautyDemoApp.swift`:

```swift
import SwiftUI

@main
struct BeautyDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

`BeautyDemo/BeautyDemo/ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}
```

`BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` facts:

```text
/* Begin PBXFileSystemSynchronizedRootGroup section */
BeautyDemo = {
    isa = PBXFileSystemSynchronizedRootGroup;
    path = BeautyDemo;
}

Frameworks = {
    isa = PBXFrameworksBuildPhase;
    files = (
    );
}

packageProductDependencies = (
);

targets = (
    BeautyDemo,
);
```

`BeautySDK/Package.swift` facade product:

```swift
products: [
    .library(name: "BeautySDK", targets: ["BeautySDK"])
]
```

`BeautyParameters` field groups for Phase 2 mapping:

```text
Skin: skinSmoothing, skinWhitening, skinRosy, skinSharpen
Color: brightness, contrast, saturation, temperature, tint, exposure, highlight, shadow
Face Shape: faceSlim, faceSmall, faceVShape, jawSlim, chinLength
Eyes: eyeSize, eyeDistance, eyeYPosition, eyeTailLift
Nose: noseSlim, noseWingSlim, noseTipSize, noseBridge
Mouth: mouthSize, mouthWidth, smile, lipColor
Filter: filterId, filterIntensity
```

## Planner Guidance

- Treat `BeautyDemo` as a real host app: it may import `BeautySDK`, SwiftUI, and app frameworks, but must not import `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, or `BeautyResources` (D-01, SDK-08).
- Preserve Phase 2 media boundaries: show disabled Camera and Photo entries marked `Coming in Phase 3`; do not add permission prompts, photo picking, capture sessions, or image processing (D-02, D-03).
- Keep the first screen an editor shell with a static portrait-fixture preview, Beauty selected by default, and the approved bottom category order (D-01, D-04, D-05).
- Model categories, subcategories, controls, ranges, and availability as Swift values so tests can assert visible labels and disabled states without relying on UI automation (D-05 through D-09).
- Keep Filters visible but disabled for Phase 5 even though `filterId` and `filterIntensity` already exist in `BeautyParameters` (D-09).
- Interactive controls must map only to existing `BeautyParameters` fields and use app-side display values normalized before snapshot construction (D-10 through D-12).
- Include single-control reset and reset-all behavior in the state store and tests (D-14).
- The UI can show short status copy such as `Parameters applied` and `Visual update pending Phase 6`; it must not claim visual effects are active in Phase 2 (D-13).

## Pattern Risks

- Manual `.pbxproj` edits can break project parsing; each plan that touches the project file must run `xcodebuild -list` and an explicit simulator build or test.
- File-system-synchronized groups reduce source file churn, but test target creation still requires explicit project objects and build settings.
- Descriptor IDs can drift from visible labels; tests should assert the rendered descriptor labels and ordering, not only internal enum cases.
- Filters can become accidentally active because SDK fields exist; availability tests must lock the Phase 5 disabled state.
- Existing repository worktree changes are broad; planning and execution commits must use explicit file lists.
