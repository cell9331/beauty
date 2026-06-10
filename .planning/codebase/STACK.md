# Technology Stack

**Analysis Date:** 2026-06-10

## Languages

**Primary:**
- Swift - Current executable app code in `BeautyDemo/BeautyDemo/BeautyDemoApp.swift` and `BeautyDemo/BeautyDemo/ContentView.swift`.
- Markdown - Root contracts and long-form planning docs in `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md`, and `docs/`.

**Secondary:**
- Xcode project format - `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` defines the only buildable target.
- JSON - Asset catalog metadata in `BeautyDemo/BeautyDemo/Assets.xcassets/**/Contents.json`.

## Runtime

**Environment:**
- iOS app target named `BeautyDemo`.
- Current local toolchain observed by command output:
  - `xcodebuild -version`: Xcode 26.5, build 17F42.
  - `swift --version`: Apple Swift 6.3.2 driver, target `arm64-apple-macosx26.0`.
- Project build settings declare `IPHONEOS_DEPLOYMENT_TARGET = 26.5`.
- The target supports `iphoneos` and `iphonesimulator`.

**Package Manager:**
- No Swift Package exists in the main worktree.
- No `BeautySDK/Package.swift` exists.
- No `Package.resolved` exists.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` has an empty `packageProductDependencies` list.

## Frameworks

**Core:**
- SwiftUI - Used by both current Swift source files:
  - `BeautyDemo/BeautyDemo/BeautyDemoApp.swift`
  - `BeautyDemo/BeautyDemo/ContentView.swift`
- Xcode generated Info.plist - `GENERATE_INFOPLIST_FILE = YES`; there is no checked-in app `Info.plist`.

**Testing:**
- No test target is present in `BeautyDemo/BeautyDemo.xcodeproj`.
- No `Tests/`, `*Tests.swift`, or `.xctestplan` files were found in the main worktree.
- Root docs describe future SDK unit/render/UI tests, but those are not implemented yet.

**Build/Dev:**
- Xcode project object version 77 in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- Xcode created a file-system-synchronized root group for `BeautyDemo/`.
- Build settings include `SWIFT_VERSION = 5.0` and Xcode upcoming Swift flags:
  - `SWIFT_APPROACHABLE_CONCURRENCY = YES`
  - `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
  - `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`

## Key Dependencies

**Critical:**
- SwiftUI - Current UI framework for the demo app.
- Asset catalogs - `BeautyDemo/BeautyDemo/Assets.xcassets` provides `AccentColor` and `AppIcon` metadata.

**Infrastructure:**
- Xcode build system - The only configured build path is `BeautyDemo/BeautyDemo.xcodeproj`.
- Apple iOS SDK 26.5 - Observed through build settings `SDKROOT = .../iPhoneOS26.5.sdk`.

**Not present yet:**
- `BeautySDK` Swift Package.
- `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, or facade target sources.
- Metal shader files.
- Vision/Core ML integration code.
- AVFoundation camera pipeline code.
- Third-party dependencies.

## Configuration

**Environment:**
- No `.env`, `.env.example`, or runtime environment configuration files were found.
- `.gitignore` excludes `.DS_Store`, `.codex-backups/`, `.worktrees/`, and `*.xcuserstate`.

**Build:**
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` is the source of build configuration.
- Bundle id: `com.yakang.BeautyDemo`.
- Marketing version: `1.0`.
- Current project version: `1`.
- Targeted device family: `1,2` (iPhone and iPad).
- Code signing style: Automatic.

## Platform Requirements

**Development:**
- Full Xcode is required for reliable project inspection and builds.
- `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj` succeeds in the current environment.
- Generic `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo build` may choose an incompatible `My Mac` destination. Use an explicit iOS Simulator destination for compile evidence.

**Production:**
- No production SDK/package distribution exists yet.
- Root contracts target a future Swift Package named `BeautySDK`, but the main worktree currently ships only a demo app shell.

---
*Stack analysis: 2026-06-10*
*Update after `BeautySDK/Package.swift`, test targets, or build dependencies are added.*
