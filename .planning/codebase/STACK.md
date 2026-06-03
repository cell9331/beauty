---
last_mapped: 2026-06-03
last_mapped_commit: 5e20ce8ea81763f47b5194a69f90ab43a2eab675
focus: tech
mapping_mode: inline sequential fallback
---

# Stack

## Summary

The main worktree is currently a docs-first iOS project with one minimal SwiftUI demo app. The intended `BeautySDK` Swift Package is documented in `ARCHITECTURE.md`, `DESIGN.md`, and `docs/superpowers/plans/2026-05-25-sdk-foundation.md`, but it does not exist in the main worktree yet.

Implemented source today:

- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` defines the SwiftUI `@main` app.
- `BeautyDemo/BeautyDemo/ContentView.swift` renders the stock Xcode "Hello, world!" view.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` defines one iOS application target named `BeautyDemo`.

## Languages And Formats

| Area | Current Use | Evidence |
| --- | --- | --- |
| Swift | Demo app source only | `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`, `BeautyDemo/BeautyDemo/ContentView.swift` |
| Xcode project file | Single app target and build settings | `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` |
| Asset catalogs | Empty/default app icon and accent color metadata | `BeautyDemo/BeautyDemo/Assets.xcassets/` |
| Markdown | Root contracts, historical docs, planning specs | `AGENTS.md`, `ARCHITECTURE.md`, `docs/README.md`, `docs/superpowers/` |
| JSON | Asset catalog metadata and imported source archive | `BeautyDemo/BeautyDemo/Assets.xcassets/Contents.json`, `docs/_source/docs_total.json` |

## Apple Platform Stack

The implemented app imports only SwiftUI:

- `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` imports `SwiftUI`.
- `BeautyDemo/BeautyDemo/ContentView.swift` imports `SwiftUI`.

The Xcode project has these notable settings in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`:

- Product type: `com.apple.product-type.application`.
- Bundle identifier: `com.yakang.BeautyDemo`.
- Marketing version: `1.0`.
- Current project version: `1`.
- Swift language version setting: `SWIFT_VERSION = 5.0`.
- Deployment target: `IPHONEOS_DEPLOYMENT_TARGET = 26.5`.
- Swift upcoming settings enabled: `SWIFT_APPROACHABLE_CONCURRENCY = YES`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, and `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`.
- Info.plist generation is enabled with `GENERATE_INFOPLIST_FILE = YES`.

## Dependencies

There are no package dependencies in the main Xcode project:

- `packageProductDependencies = ();` in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- No root `Package.swift` exists in the main worktree.
- No `Podfile`, `Cartfile`, or other package manager manifest exists in the main worktree.

Future intended dependencies are documented but not implemented:

- `ARCHITECTURE.md` assigns Vision/Core ML to `BeautyDetection`.
- `ARCHITECTURE.md` assigns Metal/Core Image/MPS to `BeautyRender`.
- `FRONTEND.md` expects AVFoundation in the future Demo camera layer.
- `SECURITY.md` and `RELIABILITY.md` define future OSLog, permission, and privacy-manifest behavior.

## Build And Tooling

Confirmed by `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` on 2026-06-03:

- Target: `BeautyDemo`.
- Build configurations: `Debug`, `Release`.
- Scheme: `BeautyDemo`.

The same command emitted CoreSimulatorService and cache/log permission warnings in this environment, but it still exited successfully and printed project information.

GSD tooling is installed globally under the Codex home and is available through:

- `/Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs`

Relevant local workflow output:

- `gsd-tools query init.new-project` reported `has_existing_code: true`, `is_brownfield: true`, and `needs_codebase_map: true`.
- `gsd-tools query init.map-codebase` reported `date: 2026-06-03`, `codebase_dir: .planning/codebase`, and `has_maps: false`.

## Not In Mainline Yet

The following are not implemented in the main worktree:

- `BeautySDK/Package.swift`.
- `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, or facade `BeautySDK` targets.
- SDK unit tests, render tests, UI tests, or CI configuration.
- Camera, PhotoKit, Metal preview, Vision detection, or rendering code.
- `PrivacyInfo.xcprivacy`.

There is an ignored auxiliary git worktree at `.worktrees/sdk-foundation` with a separate branch and a `BeautySDK/` directory. Because `.worktrees/` is ignored by `.gitignore` and not part of the main worktree status, this map treats it as local auxiliary state rather than current mainline implementation.
