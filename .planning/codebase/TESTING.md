---
last_mapped: 2026-06-03
last_mapped_commit: 5e20ce8ea81763f47b5194a69f90ab43a2eab675
focus: quality
mapping_mode: inline sequential fallback
---

# Testing

## Summary

The main worktree currently has no test targets, no test files, and no CI configuration. Verification is mostly documentation scans plus Xcode project inspection until the SDK package and Demo test targets are created.

## Existing Test Inventory

Current main worktree:

- No `BeautySDK/Tests/` directory.
- No `BeautyDemo/BeautyDemoTests/` directory.
- No `BeautyDemo/BeautyDemoUITests/` directory.
- No `XCTest` imports in implemented source.
- No Swift Testing imports.
- No CI workflow files observed in the main worktree scan.

`BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` defines only one native app target, `BeautyDemo`; no test targets are present.

## Verified During Mapping

The following checks were run during this map:

- `gsd-tools query init.new-project` to classify the repository as brownfield and needing a codebase map.
- `gsd-tools query init.map-codebase` to initialize mapping context.
- `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` to list targets, configurations, and schemes.
- File scans of root docs, `BeautyDemo` Swift files, asset catalogs, and Xcode project settings.

`xcodebuild -list` exited successfully and printed:

- Target: `BeautyDemo`.
- Build configurations: `Debug`, `Release`.
- Scheme: `BeautyDemo`.

It also emitted simulator-service, cache, and log-permission warnings in the local environment. This map did not run a build or test command.

## Documented Future Test Strategy

`QUALITY_SCORE.md` defines required test areas:

- Parameter tests.
- Preset tests.
- Coordinate tests.
- Detection tests.
- Render tests.
- Effect fixture tests.
- Performance tests.
- Security tests.
- UI tests.

`docs/superpowers/plans/2026-05-25-sdk-foundation.md` contains a detailed future plan for:

- `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift`.
- `BeautySDK/Tests/BeautyCoreTests/`.
- `BeautySDK/Tests/BeautyDetectionTests/`.
- `BeautySDK/Tests/BeautyRenderTests/`.
- `BeautySDK/Tests/BeautyEffectsTests/`.
- `BeautySDK/Tests/BeautyResourcesTests/`.

Those files are not present in the main worktree.

## Recommended First Verification Commands

Once `BeautySDK/Package.swift` exists:

```bash
swift test --package-path BeautySDK
```

Once Demo wiring exists:

```bash
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo build
```

Architecture scans from `QUALITY_SCORE.md`:

```bash
rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects" BeautyDemo
rg -n "fatalError|try!|as!" BeautySDK/Sources BeautyDemo/BeautyDemo 2>/dev/null
rg -n "UIImage" BeautySDK/Sources BeautyDemo/BeautyDemo 2>/dev/null
```

Documentation scans from `QUALITY_SCORE.md` should remain part of doc-gardening before any major claim of readiness.

## Testing Risks

Testing is currently the biggest implementation gap:

- The root contracts are detailed, but none of the SDK behavior is executable yet.
- Scores in `QUALITY_SCORE.md` correctly keep SDK layers and tests at 0 or 1.
- There is no automated protection for the intended package dependency graph.
- There is no runtime proof for privacy, error handling, rendering, or performance invariants.

The next code phase should create the package skeleton and the first failing tests before adding implementation.
