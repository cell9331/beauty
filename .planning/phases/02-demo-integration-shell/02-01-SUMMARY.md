# Plan 02-01 Summary: Demo Shell Wiring

## Result

Completed. `BeautyDemo` now links the local `BeautySDK` package facade, has a hosted `BeautyDemoTests` target, and opens through `EditorShellView` instead of the default SwiftUI template route.

## Commits

- `fc5be8a` `feat(02-01): wire demo package and test target`
- `507f698` `feat(02-01): route demo to editor shell`
- `2302fa2` `test(02-01): add demo smoke import boundary`

## Files

- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`
- `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift`
- `BeautyDemo/BeautyDemo/ContentView.swift`
- `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`
- `BeautyDemo/BeautyDemo/Support/DemoFixtures.swift`
- `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift`
- Deleted `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`

## Verification

- `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` passed and listed targets `BeautyDemo`, `BeautyDemoTests`, and scheme `BeautyDemo`.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build` passed with `** BUILD SUCCEEDED **`.
- `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' test` passed with `** TEST SUCCEEDED **`.
- `rg -n "import BeautyCore|import BeautyDetection|import BeautyRender|import BeautyEffects|import BeautyResources" BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` returned no matches.
- `rg -n "Hello, world!" BeautyDemo/BeautyDemo` returned no matches.
- `git diff --check -- BeautyDemo/BeautyDemo.xcodeproj BeautyDemo/BeautyDemo BeautyDemo/BeautyDemoTests` exited 0.

## Deviations

- The original root `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` was deleted after moving the app entry to `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift`. Keeping both files, even with the old one reduced to a comment, caused Xcode to emit duplicate `BeautyDemoApp.stringsdata`; deleting the retired root file fixed the simulator build.

## Requirements Addressed

- `SDK-08`
- `DEMO-02`
- `DEMO-03`
- `DEMO-08`

## Self-Check

Passed. The plan produced the required app route, package wiring, test target, deterministic shell fixtures, disabled Camera/Photo entries, and facade-only import evidence.
