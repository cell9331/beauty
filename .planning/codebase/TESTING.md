# Testing Patterns

**Analysis Date:** 2026-06-10

## Test Framework

**Runner:**
- No test runner is configured in the main worktree.
- `BeautyDemo/BeautyDemo.xcodeproj` has only one target: `BeautyDemo`.
- No XCTest target, Swift Package test target, `.xctestplan`, or `Tests/` directory exists.

**Assertion Library:**
- None currently in code.
- Future Swift Package tests should likely use XCTest unless a different framework is explicitly introduced.

**Run Commands:**

```bash
xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj
```

The command above currently verifies target/scheme discovery only.

```bash
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' build
```

Use an explicit simulator destination for compile evidence. Generic build can select an incompatible `My Mac` destination locally.

Future SDK command from root planning docs:

```bash
swift test --package-path BeautySDK
```

This command cannot run until `BeautySDK/Package.swift` exists.

## Test File Organization

**Location:**
- No current test files.
- Future SDK tests should follow the target layout in `ARCHITECTURE.md`:
  - `BeautySDK/Tests/BeautyCoreTests/`
  - `BeautySDK/Tests/BeautyDetectionTests/`
  - `BeautySDK/Tests/BeautyRenderTests/`
  - `BeautySDK/Tests/BeautyEffectsTests/`
  - `BeautySDK/Tests/BeautyResourcesTests/`

**Naming:**
- No current pattern.
- Existing planning docs use names such as `BeautyConfigurationTests.swift`, `RenderGraphTests.swift`, and `PresetLoaderTests.swift` as future examples.

**Structure:**

```text
Current:
BeautyDemo/
  BeautyDemo.xcodeproj/
  BeautyDemo/
    BeautyDemoApp.swift
    ContentView.swift
    Assets.xcassets/

Expected future SDK:
BeautySDK/
  Tests/
    BeautyCoreTests/
    BeautyRenderTests/
    BeautyDetectionTests/
    BeautyEffectsTests/
    BeautyResourcesTests/
```

## Test Structure

**Suite Organization:**

No implemented tests exist to infer concrete suite style.

Recommended baseline for future XCTest files:

```swift
import XCTest
@testable import BeautyCore

final class BeautyParametersTests: XCTestCase {
    func testDefaultsAreZeroEffect() {
        let parameters = BeautyParameters()
        XCTAssertEqual(parameters.skinSmoothing, 0)
    }
}
```

**Patterns:**
- Add tests alongside the first SDK implementation rather than after feature accumulation.
- Use focused XCTest methods for model defaults, clamping, Codable round trips, reset behavior, and no-op processing.
- Keep current Demo build verification separate from SDK unit tests.

## Mocking

**Framework:**
- None currently.

**Patterns:**
- No current mocking pattern.
- Future rendering/detection tests should avoid depending on camera hardware.
- Use protocol seams from `ARCHITECTURE.md` and `DESIGN.md` for detector, resource, and render dependencies.

**What to Mock:**
- Future detector outputs, resource lookup failures, render pass failures, and metrics sinks.

**What NOT to Mock:**
- Pure value-model behavior such as `BeautyParameters` defaults and Codable round trips.

## Fixtures and Factories

**Test Data:**
- No fixtures exist.
- Future fixture categories should include:
  - Parameter presets.
  - Invalid preset JSON.
  - Pixel buffer/image edge cases.
  - Face observations with missing landmarks.

**Location:**
- Future shared fixtures can live under `BeautySDK/Tests/<TargetName>Tests/Fixtures/` or a package test-support target if needed.

## Coverage

**Requirements:**
- No enforced coverage target exists.
- `QUALITY_SCORE.md` scores Tests as 0 and lists parameter, preset, coordinate, detection, render, effect fixture, performance, security, and UI test gaps.

**Configuration:**
- No coverage configuration exists.

**View Coverage:**
- No command exists yet.

## Test Types

**Unit Tests:**
- Not present.
- First priority should be SDK value models and no-op engine behavior.

**Integration Tests:**
- Not present.
- Future Demo integration should verify that `BeautyDemo` imports only `BeautySDK` and can initialize the facade.

**E2E/UI Tests:**
- Not present.
- Future UI smoke tests should cover launch, permission-denied state, slider mapping, preset sync, and compare toggle after those features exist.

## Common Patterns

**Async Testing:**
- No current async code.
- Future realtime pipeline tests should verify off-main-thread processing and in-flight/drop behavior once implemented.

**Error Testing:**
- No current error paths.
- Future tests should assert typed `BeautyError`, not raw framework errors or release-path crashes.

**Snapshot Testing:**
- Not used.

---
*Testing analysis: 2026-06-10*
*Update when XCTest targets, Swift Package tests, UI tests, or coverage tooling are added.*
