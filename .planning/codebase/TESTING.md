# Testing Patterns

**Analysis Date:** 2026-08-13

## Test Framework

**Runner:**
- XCTest through Swift Package Manager for the SDK. `BeautySDK/Package.swift` defines six test targets: `BeautySDKTests`, `BeautyCoreTests`, `BeautyDetectionTests`, `BeautyEffectsTests`, `BeautyRenderTests`, and `BeautyResourcesTests`.
- XCTest through the shared `BeautyDemo` Xcode scheme for Demo unit/integration tests under `BeautyDemo/BeautyDemoTests/`.
- Current source inventory contains 50 SwiftPM test files with 650 `test...` methods and 11 Demo test files with 123 `test...` methods. The authoritative recorded full runs in `QUALITY_SCORE.md` are 650 SwiftPM tests and 121 Demo tests; method counts include helpers or conditionally discovered cases and must not replace executed-run totals.
- Config: `BeautySDK/Package.swift` and `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.

**Assertion Library:**
- XCTest only: `XCTAssertEqual`, `XCTAssertTrue`, `XCTAssertNil`, `XCTUnwrap`, `XCTAssertThrowsError`, `XCTFail`, expectations, and async test support.
- No Quick/Nimble, snapshot-test, or mocking library dependency is present.

**Run Commands:**

```bash
swift test --package-path BeautySDK
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFullScleraRednessProviderTests
scripts/run-no-skip-swiftpm.sh
xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=<Simulator Name>,OS=<OS Version>' test
swift test --package-path BeautySDK --enable-code-coverage
```

- Use the first command for the default SDK suite; it intentionally skips eight environment-gated native-Vision/private-fixture tests when their opt-ins are absent.
- Use `scripts/run-no-skip-swiftpm.sh` only on a host with the ignored authorized fixture bundles and Apple Vision support. It enables all eight opt-ins and fails if any test skips.
- Always use an explicit compatible iOS Simulator destination for Demo tests; the local default may choose an incompatible `My Mac` destination.

## Test File Organization

**Location:**
- Co-locate SDK tests by package target under `BeautySDK/Tests/<Module>Tests/`; production and tests remain in separate source trees.
- Place Demo tests in the Xcode test target at `BeautyDemo/BeautyDemoTests/`.
- Keep shared suite-specific fixture builders beside their tests, for example `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift`.
- Keep authorized real media outside tracked tests under ignored `example-images/local-retouch-review/`; tests consume only validated bundle paths supplied through environment variables, as in `BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift`.

**Naming:**
- Test files: `<Subject>Tests.swift` or `<Feature><Integration|AdversarialCloseout|RealFixture>Tests.swift`.
- Test classes: `final class <Subject>Tests: XCTestCase`.
- Test methods: `test<RequirementID><Scenario><ExpectedOutcome>()`, with a requirement ID when the test is direct acceptance evidence.

**Structure:**

```text
BeautySDK/
├── Package.swift
└── Tests/
    ├── BeautySDKTests/
    ├── BeautyCoreTests/
    ├── BeautyDetectionTests/
    ├── BeautyEffectsTests/
    ├── BeautyRenderTests/
    └── BeautyResourcesTests/

BeautyDemo/
└── BeautyDemoTests/
```

## Test Structure

**Suite Organization:**

```swift
import XCTest
@testable import BeautyCore

final class BeautyConfigurationTests: XCTestCase {
    func testDefaultsMatchContract() {
        let configuration = BeautyConfiguration()

        XCTAssertEqual(configuration.maximumFaceCount, 1)
        XCTAssertEqual(configuration.detectionFrameInterval, 3)
    }
}
```

This mirrors the direct arrange → act → assert style used in `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift`.

**Patterns:**
- Prefer one named behavior per test, but use table-driven loops when validating the same invariant across fields, malformed variants, feature rows, orientations, or regions; see `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyCanonicalStillImageTests.swift`.
- Assert exact values for public inventories, defaults, caps, stable error codes, deterministic output, state transitions, and no-op behavior.
- For safety-sensitive image effects, assert both positive movement and exact preservation of protected/out-of-mask pixels. Representative suites are `BeautySDK/Tests/BeautyEffectsTests/BeautyTeethWhiteningAdversarialCloseoutTests.swift` and `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift`.
- Use `try XCTUnwrap` for required optional results and `XCTAssertThrowsError` with an error-case assertion for failure paths. Avoid production `fatalError`; limited `try! XCTUnwrap` usage exists in geometry fixture-heavy tests such as `BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift`, but new tests should prefer throwing test methods.
- Keep setup local to each test or helper factory. There is little `setUp`/`tearDown` usage, which prevents shared mutable state and order dependence.

## Mocking

**Framework:**
- Hand-written fakes, injected closures, package-scoped harnesses, and testing hooks; no external mocking framework.

**Patterns:**

```swift
let processor = StillImageProcessor { image, metadata, parameters in
    BeautyResult(
        output: image,
        warnings: [],
        metrics: [],
        detectionSummary: .notRun
    )
}
let pipeline = ImageEditorPipeline(processor: processor)
```

- Follow the closure-seam pattern owned by `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` and exercised in `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift`.
- Inject Vision observations through `VisionFaceDetector.ObservationProvider` in `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`; use package test harnesses from `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` for facade flow and failure-unit coverage.
- Use small lock-protected `@unchecked Sendable` test helpers only where XCTest must coordinate concurrent callbacks, as in `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift`.

**What to Mock:**
- Camera permissions and session lifecycle, frame/photo processors, decoders/renderers, Vision observations, time/order control, resource failure, and explicit facade testing hooks.
- Mock platform availability or observations when verifying deterministic mapping, state, degradation, and recovery behavior.

**What NOT to Mock:**
- Pure parameter normalization, Codable compatibility, safety caps, geometry math, color transforms, composition ownership, resource catalog decoding, and pixel-level containment invariants.
- Do not use synthetic fixtures as product-feasibility evidence. Authorized positive/negative real-fixture gates remain distinct and opt-in under `BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift`.

## Fixtures and Factories

**Test Data:**

```swift
static let rows: [EyebrowSafetyRow] = [
    EyebrowSafetyRow(
        name: "eyebrowYPosition",
        makeParameters: { BeautyParameters(eyebrowYPosition: $0) },
        publicValue: \.eyebrowYPosition,
        effectiveValue: \.eyebrowYPosition,
        isSigned: true,
        cap: BeautySafetyCaps.eyebrowYPosition
    )
]
```

- Use typed fixture rows to drive the same safety contract across a feature family; the full pattern is in `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift`.
- Use deterministic in-memory pixel buffers, `CIImage` values, RGBA byte arrays, and semantic landmark supports for unit/adversarial tests.
- Validate fixture construction through production adapters where possible; fixture helpers in `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift` assert that their geometry satisfies production validation.

**Location:**
- Suite-local Swift fixtures: the owning `BeautySDK/Tests/<Module>Tests/` or `BeautyDemo/BeautyDemoTests/` directory.
- Public renderer inputs: `example-images/input/`, with generated output/gallery artifacts ignored.
- Private licensed pairs: ignored directories under `example-images/local-retouch-review/`, referenced only by environment variable and validated manifest/path rules.

## Coverage

**Requirements:**
- No numeric line/branch coverage percentage is enforced by configuration.
- Behavioral coverage is enforced through exact inventories, focused requirement suites, adversarial containment tests, privacy/source scans, full SwiftPM/Demo runs, and the no-skip gate documented in `QUALITY_SCORE.md`.
- Current quality authority records 650 passing SwiftPM tests with eight documented default opt-in skips and a no-skip run of the same 650 tests with all eight executed. It records 121 passing Demo tests on iPhone 17e / iOS 26.5.

**View Coverage:**

```bash
swift test --package-path BeautySDK --enable-code-coverage
xcrun llvm-cov report \
  BeautySDK/.build/debug/BeautySDKPackageTests.xctest/Contents/MacOS/BeautySDKPackageTests \
  -instr-profile BeautySDK/.build/debug/codecov/default.profdata
```

- SwiftPM can generate coverage locally, but repository CI does not publish or threshold it. The exact XCTest bundle path can vary by platform/toolchain; inspect `BeautySDK/.build/` when the sample path differs.

## Test Types

**Unit Tests:**
- Value models, validation, Codable compatibility, resource catalogs, coordinate mapping, geometry providers, caps, transforms, render passes, state reducers, and UI model mapping.
- Primary locations: `BeautySDK/Tests/BeautyCoreTests/`, `BeautySDK/Tests/BeautyDetectionTests/`, `BeautySDK/Tests/BeautyEffectsTests/`, `BeautySDK/Tests/BeautyRenderTests/`, `BeautySDK/Tests/BeautyResourcesTests/`, and `BeautyDemo/BeautyDemoTests/`.

**Integration Tests:**
- Public facade processing, canonicalization/detection/effect/render sequencing, local-retouch composition, renderer output regression, camera/photo pipeline state, and Demo import/privacy boundaries.
- Representative files: `BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`, `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift`, and `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift`.

**E2E Tests:**
- No dedicated XCUITest target is present. Simulator XCTest exercises Demo models and pipelines, while screenshot/manual/device evidence is maintained separately in planning/evidence artifacts rather than as automated UI tests.

## Common Patterns

**Async Testing:**

```swift
@MainActor
final class CameraBeautyPipelineTests: XCTestCase {
    func testLatestFrameWins() async throws {
        let started = expectation(description: "first frame started")
        // Inject a controlled processor, enqueue work, release it, then await idle.
        await fulfillment(of: [started], timeout: 1)
    }
}
```

- Put UI/pipeline suites on `@MainActor`; use async test methods, XCTest expectations, continuations, actors, and explicit wait-for-idle APIs instead of arbitrary sleeps. Patterns live in `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift`, `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift`, and `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift`.
- Bound concurrency waits with timeouts and assert latest-work-wins, stale-result suppression, backpressure counts, and reset recovery.

**Error Testing:**

```swift
XCTAssertThrowsError(try operation()) { error in
    XCTAssertEqual(error as? BeautyError, .invalidInput)
}
```

- Assert the typed error and its stable/redacted surface, not only that an error occurred. Examples are in `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyPresetTests.swift`, and `BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift`.
- For Demo recovery, assert friendly status text, preservation of the last usable preview, absence of raw codes/paths, and successful subsequent work in `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift` and `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift`.

---

*Testing analysis: 2026-08-13*
