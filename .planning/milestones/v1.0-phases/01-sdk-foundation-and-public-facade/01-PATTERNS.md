# Phase 01: SDK Foundation and Public Facade - Pattern Map

**Mapped:** 2026-06-10
**Purpose:** Ground Phase 1 plans in the current main-worktree codebase.

## Current Implementation Surface

The main worktree has no SDK package implementation:

- No `BeautySDK/Package.swift`.
- No `BeautySDK/Sources/**`.
- No `BeautySDK/Tests/**`.
- No package product dependency in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`; `packageProductDependencies = (` is empty.
- Current Swift source is only a minimal SwiftUI Demo shell:
  - `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`
  - `BeautyDemo/BeautyDemo/ContentView.swift`

## Closest Existing Analogs

| Planned file / area | Closest existing analog | Use / constraint |
|---------------------|-------------------------|------------------|
| `BeautySDK/Package.swift` | None in main worktree | Create from root contracts, not from existing code. |
| `BeautySDK/Sources/BeautySDK/**` facade | None in main worktree | Must be new and host-app-facing. |
| `BeautySDK/Sources/BeautyCore/**` models | `DESIGN.md`, `RELIABILITY.md`, `SECURITY.md` | Contracts define types and validation; no source analog exists. |
| `BeautySDK/Sources/BeautyRender/**` no-op path | `ARCHITECTURE.md`, `docs/superpowers/specs/2026-05-25-sdk-foundation-design.md` | Historical design is background; root contracts and context decisions win. |
| `BeautySDK/Tests/**` | `.planning/codebase/TESTING.md` | No test style exists; use XCTest and `swift test --package-path BeautySDK`. |
| Demo import-boundary scan | `BeautyDemo/BeautyDemo/*.swift` | Current Demo imports only SwiftUI; Phase 1 should not require Demo UI changes. |

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
packageProductDependencies = (
);
IPHONEOS_DEPLOYMENT_TARGET = 26.5;
SWIFT_VERSION = 5.0;
PRODUCT_BUNDLE_IDENTIFIER = com.yakang.BeautyDemo;
```

## Planner Guidance

- Treat `BeautySDK/` as a new package root.
- Do not rely on ignored `.worktrees/` content as implementation evidence.
- Keep Demo Xcode project wiring optional unless explicitly needed for Phase 1 verification; Phase 2 owns Demo integration shell.
- If a plan touches `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, it must include a narrow verification command and should avoid broad project churn.
- Every plan should include a source-read step for `AGENTS.md`, `PLANS.md`, and the specific root contracts it changes or implements.

## Pattern Risks

- Because no SDK code exists yet, overusing historical long-form docs can resurrect old names or stale environment assumptions.
- Because the Xcode project uses file-system-synchronized groups, manual `.pbxproj` editing can become noisy; prefer package-first verification unless Demo package wiring is explicitly planned.
- Because root contracts are already authoritative, implementation plans should update root docs only when code contracts intentionally change.

