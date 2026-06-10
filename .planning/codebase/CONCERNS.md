# Codebase Concerns

**Analysis Date:** 2026-06-10

## Tech Debt

**SDK package missing from main worktree:**
- Issue: Root contracts define `BeautySDK/Package.swift` and multiple targets, but the main worktree has no `BeautySDK/` package.
- Files: `ARCHITECTURE.md`, `QUALITY_SCORE.md`, `docs/superpowers/specs/2026-05-25-sdk-foundation-design.md`.
- Why: The repo is still in documentation/planning plus Demo-shell state.
- Impact: Host-app integration, SDK API, unit tests, render pipeline, and Demo facade wiring cannot be verified.
- Fix approach: Create the Swift Package and targets before claiming SDK implementation progress.

**Demo app is still the Xcode template:**
- Issue: `BeautyDemo/BeautyDemo/ContentView.swift` still renders the default globe and `Hello, world!`.
- Files: `BeautyDemo/BeautyDemo/ContentView.swift`.
- Why: Demo integration has not started in the main worktree.
- Impact: Product journeys in `PRODUCT_SENSE.md` are not demonstrable; Demo does not import or exercise `BeautySDK`.
- Fix approach: After SDK facade exists, replace the template with a minimal SDK integration status UI.

**No automated tests:**
- Issue: No test target, no Swift Package tests, no UI tests, and no test plans exist.
- Files: `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`; absence of `BeautySDK/Tests/`.
- Why: Implementation has not reached the SDK package phase.
- Impact: Quality gates in `QUALITY_SCORE.md` cannot move beyond documentation evidence.
- Fix approach: Add XCTest targets with the first SDK package work.

**GSD planning was reset before this remap:**
- Issue: `.planning/PROJECT.md`, `.planning/STATE.md`, and `.planning/ROADMAP.md` are absent during this map.
- Files: `.planning/codebase/*.md`, `PLANS.md`.
- Why: Previous partial `$gsd-new-project` residue was deleted before restarting initialization.
- Impact: New project initialization must recreate project context, requirements, roadmap, and state from this map plus root contracts.
- Fix approach: Run `$gsd-new-project` after this map and preserve each required workflow gate.

## Known Bugs

**No runtime bugs recorded in current source:**
- Symptoms: Current app source is too small to expose domain behavior.
- Trigger: Not applicable.
- Workaround: Not applicable.
- Root cause: SDK and Demo feature code are not implemented yet.

## Security Considerations

**Camera/photo capability not configured:**
- Risk: Future camera or photo-library code will fail App Store/privacy review or runtime permission requirements if purpose strings are missing.
- Current mitigation: Current code does not access camera or photos.
- Files: `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `SECURITY.md`.
- Recommendations: Add `NSCameraUsageDescription` before AVFoundation camera usage, add photo-library purpose strings before PhotoKit access, and verify generated Info.plist output.

**Privacy manifest missing:**
- Risk: A distributed SDK may need `PrivacyInfo.xcprivacy` depending on data collection and required-reason APIs.
- Current mitigation: No SDK target exists yet.
- Files: `SECURITY.md`, `QUALITY_SCORE.md`.
- Recommendations: Evaluate and add privacy manifest when `BeautySDK` is created.

**Local ignored worktree can mislead analysis:**
- Risk: `.worktrees/sdk-foundation/` contains ignored implementation-like files that may be mistaken for delivered main worktree code.
- Current mitigation: `.gitignore` ignores `.worktrees/`.
- Files: `.gitignore`.
- Recommendations: Always scope implementation checks to the main worktree unless explicitly working inside that worktree.

## Performance Bottlenecks

**No implemented frame pipeline to measure:**
- Problem: Realtime/image processing does not exist.
- Measurement: No runtime metrics available.
- Cause: SDK package and render pipeline missing.
- Improvement path: Add performance tests after `BeautyRender` and Demo camera pipeline exist.

## Fragile Areas

**Xcode destination selection:**
- Why fragile: Generic build commands can select an incompatible `My Mac` destination.
- Common failures: `xcodebuild ... build` without destination may fail for an environment reason unrelated to source correctness.
- Safe modification: Use `xcodebuild -list` for scheme discovery and explicit iOS Simulator destination for compile evidence.
- Test coverage: No automated CI yet.

**Xcode project file mutation:**
- Why fragile: `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj` uses Xcode 26 file-system-synchronized groups and generated Info.plist settings.
- Common failures: Manual package-reference edits can destabilize target membership or package dependencies.
- Safe modification: Prefer Xcode-aware edits or tightly scoped pbxproj changes; verify with `xcodebuild -list` and explicit simulator build.
- Test coverage: No project-level tests beyond manual command verification.

**Documentation drift after cleanup:**
- Why fragile: Some historical docs and prior completion records still mention `.planning/PROJECT.md` from the previous partial initialization.
- Common failures: Agents may read stale docs and assume project context exists.
- Safe modification: After `$gsd-new-project` completes, update `docs/README.md`, `QUALITY_SCORE.md`, and `PLANS.md` to match the new planning state.
- Test coverage: Documentation scans exist in `QUALITY_SCORE.md`, but they need rerun after initialization.

## Scaling Limits

**Current app scope:**
- Current capacity: One local SwiftUI view.
- Limit: No SDK processing, no camera pipeline, no image handling, no tests.
- Symptoms at limit: Any SDK integration task must first create package structure.
- Scaling path: Build the SDK foundation before product features.

## Dependencies at Risk

**Xcode 26.5 project assumptions:**
- Risk: The project uses current Xcode settings such as object version 77 and generated Info.plist behavior.
- Impact: Older Xcode versions may not open/build the project cleanly.
- Migration plan: Document minimum Xcode in project requirements if supporting older environments becomes necessary.

## Missing Critical Features

**SDK facade and engine:**
- Problem: No `BeautyEngine`, `BeautyParameters`, `BeautyConfiguration`, `BeautyError`, or facade module exists in source.
- Current workaround: Root docs and historical plans describe the intended design.
- Blocks: Host app integration and all SDK tests.
- Implementation complexity: Medium for no-op foundation; high for full beauty pipeline.

**Demo integration UI:**
- Problem: Demo cannot show SDK loaded/version/init state.
- Current workaround: None in code.
- Blocks: The first host-app developer journey in `PRODUCT_SENSE.md`.
- Implementation complexity: Low after facade exists.

**Validation and diagnostics:**
- Problem: No runtime validation, typed errors, logging, metrics, or privacy manifest exist.
- Current workaround: Contract docs define expected behavior.
- Blocks: Security/reliability evidence.
- Implementation complexity: Medium.

## Test Coverage Gaps

**Everything below code-shell level:**
- What's not tested: SDK models, engine init/reset, no-op process APIs, package facade import, Demo facade wiring, validation, privacy/logging, rendering, detection, resources.
- Risk: Future implementation could drift from root contracts without automated feedback.
- Priority: High.
- Difficulty to test: Low for value models/no-op engine; medium/high for render/camera/performance paths.

---
*Concerns audit: 2026-06-10*
*Update as SDK package, Demo integration, tests, and planning artifacts are added.*
