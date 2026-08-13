# Coding Conventions

**Analysis Date:** 2026-08-13

## Naming Patterns

**Files:**
- Use PascalCase Swift filenames matching the primary declaration: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`, and `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift`.
- Name XCTest files `<Subject>Tests.swift`; use a descriptive qualifier for integration or adversarial suites, as in `BeautySDK/Tests/BeautyCoreTests/BeautyEngineScleraRednessIntegrationTests.swift` and `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift`.
- Keep feature implementations grouped by responsibility under directories such as `BeautySDK/Sources/BeautyEffects/Warp/`, `BeautySDK/Sources/BeautyEffects/Planning/`, and `BeautySDK/Sources/BeautyEffects/LocalRetouch/`.

**Functions:**
- Use lowerCamelCase and verb-led names for operations: `processResult`, `canonicalize`, `resolveStillImageGeometry`, `makeControlPoints`, and `validate` in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` and related SDK sources.
- Use `make...` for factories that may abstain or return an optional result, for example `BeautyTeethWhiteningProvider.makeResult` in `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningProvider.swift`.
- Name XCTest methods `test<RequirementOrBehavior><ExpectedOutcome>`; requirement IDs may prefix the behavior, for example `testPIPE03InFlightWorkIsBoundedAndStalePendingFramesAreDropped` in `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift`.
- Use `is`, `has`, `can`, or `requires` prefixes for Boolean queries and state, as demonstrated by `hasDirectTeethIntent`, `hasOpaqueCompositionScenario`, and `requiresLocalSupport` in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.

**Variables:**
- Use lowerCamelCase for values and properties: `maximumInputPixelCount`, `localRetouchTestingHooks`, and `resetGeneration` in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.
- Give units or representation in names when ambiguity matters: `rgba8Data`, `maximumInputByteCount`, `changedPixelCount`, and `maximumRadiusFraction` in `BeautySDK/Sources/BeautyCore/Models/` and `BeautySDK/Tests/BeautyEffectsTests/EyebrowSafetyFixtures.swift`.
- Use named constants instead of unexplained literals for public limits and algorithm caps, such as `BeautyConfiguration.defaultMaximumInputPixelCount` in `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` and values in `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift`.

**Types:**
- Use PascalCase for structs, classes, enums, actors, and protocols.
- Prefix public SDK/domain types with `Beauty`: `BeautyEngine`, `BeautyConfiguration`, `BeautyParameters`, `BeautyError`, and `BeautyResult` under `BeautySDK/Sources/`.
- Name internal feature types for both domain and role: `BeautyFullScleraRednessProvider`, `BeautyLocalRetouchCompositionOwner`, and `BeautyEffectResolver` under `BeautySDK/Sources/BeautyEffects/`.
- Use `...State`, `...Snapshot`, `...Summary`, `...Support`, and `...Context` suffixes consistently for state machines and data carriers, as in `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift` and `BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift`.

## Code Style

**Formatting:**
- No SwiftFormat, SwiftLint, or `.editorconfig` configuration is present. Match the checked-in Xcode/Swift style rather than introducing a formatter in a feature change.
- Use 4-space indentation, opening braces on the declaration line, trailing commas in multiline argument and collection lists, and one declaration or logical clause per line. Representative files are `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift`.
- Break long calls by placing each labeled argument on its own line; align chained guard conditions vertically and put `else` on its own line, as in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.
- Use Swift shorthand returns in computed properties and switch cases where the expression is clear, as in `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift`.

**Linting:**
- No dedicated lint tool or lint command is configured. Treat Swift compilation, XCTest, repository `rg` policy scans, and `git diff --check` as the effective static gates.
- Preserve strict Swift 6 package compatibility declared in `BeautySDK/Package.swift`; the Xcode project currently records `SWIFT_VERSION = 5.0` for Demo configurations in `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- Do not suppress concurrency warnings casually. Use `Sendable`, `@Sendable`, actors, `@MainActor`, and narrowly justified `@unchecked Sendable` wrappers as in `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` and its tests.

## Import Organization

**Order:**
1. Import only modules actually used by the file.
2. Keep imports in one block at the top, followed by `@testable import` lines in tests.
3. Prefer a stable alphabetical grouping when editing a file; current files mix project-first and Apple-first ordering, so preserve the local file's established ordering unless normalizing the whole file.

**Examples:**
- SDK facade implementation imports Apple frameworks plus internal targets in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.
- Tests import `XCTest` and then expose only the internal modules needed through `@testable import`, as in `BeautySDK/Tests/BeautyEffectsTests/BeautyTeethWhiteningProviderTests.swift`.
- Demo production code imports only the public `BeautySDK` product, never `BeautyCore`, `BeautyDetection`, `BeautyEffects`, `BeautyRender`, or `BeautyResources`; `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift` demonstrates the facade boundary.

**Path Aliases:**
- Not applicable. Swift Package target names and Xcode module imports provide module boundaries; there are no source path aliases.

## Error Handling

**Patterns:**
- Throw stable typed `BeautyError` cases across SDK boundaries rather than raw `NSError` or framework-specific failures. The canonical public error vocabulary and redacted descriptions live in `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift`.
- Validate inputs before allocation or processing and fail with `BeautyError.invalidInput` or `BeautyError.unsupportedPixelFormat`; see `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` and `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`.
- Use `guard` for preconditions and early abstention. Local feature providers return `nil` or empty per-region results for missing, malformed, stale, or unsafe support rather than fabricating geometry; see `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningProvider.swift` and `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyFullScleraRednessProvider.swift`.
- Use `defer` for request lifecycle cleanup, as in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.
- Map SDK failures to stable, friendly UI state without exposing error codes, paths, or framework strings; this behavior is implemented in `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift` and `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`.

## Logging

**Framework:** Aggregate diagnostics through SDK result metadata and redacted error/warning models; there is no third-party logging dependency.

**Patterns:**
- Emit stable codes and aggregate counts only. `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyErrorContext.swift`, `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyValidationWarning.swift`, and `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` own diagnostic shapes.
- Never log or persist image bytes, paths, raw JSON, landmarks, masks, pupil positions, teeth geometry, vein patterns, or other request-local support. Tests enforce these boundaries in `BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift` and SDK integration suites.
- Redact free-form associated values to a short allowlisted character set before presenting them; use the pattern in `BeautySDK/Sources/BeautyCore/Models/BeautyError.swift`.

## Comments

**When to Comment:**
- Comment public lifecycle or ownership guarantees that a signature cannot express; `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` documents output lifecycle semantics.
- Explain non-obvious safety, geometry, color, concurrency, or platform invariants near their owner. Avoid narrating straightforward assignments.
- Keep durable cross-module rules in root contracts (`DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `FRONTEND.md`) and implementation-specific spike constraints in `.codex/skills/spike-findings-beauty/`; do not duplicate those contracts in source comments.

**JSDoc/TSDoc:**
- Not applicable. Use Swift `///` documentation comments for public API guarantees when needed; most internal declarations rely on expressive names and tests.

## Function Design

**Size:**
- Keep value-model validation and pure transforms small and deterministic, as in `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` and local-retouch transform files under `BeautySDK/Sources/BeautyEffects/LocalRetouch/`.
- Large orchestration functions may sequence the explicit canonicalize → detect/map → request-context → compose → render flow, but extract validation, geometry, provider, transform, and composition ownership into their existing modules instead of growing `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.

**Parameters:**
- Prefer labeled parameters and immutable value carriers. Use closure-based dependency injection for testable platform seams, as in `VisionFaceDetector.ObservationProvider` in `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `StillImageProcessor` in `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`, and `CameraFrameProcessor` in `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`.
- Mark cross-concurrency closures `@Sendable`; isolate UI state on `@MainActor`.
- Keep internal test hooks at `package` or internal visibility. Do not widen public API solely to make tests possible; see `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`.

**Return Values:**
- Return `BeautyResult<Output>` when callers need warnings, metrics, and detection summary alongside output; convenience facade methods return the output alone in `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`.
- Use optionals or empty collections for deliberate feature abstention and throws for invalid request-level input. Tests distinguish these behaviors throughout `BeautySDK/Tests/BeautyEffectsTests/` and `BeautySDK/Tests/BeautyCoreTests/`.

## Module Design

**Exports:**
- Keep public host integration in the `BeautySDK` product declared by `BeautySDK/Package.swift`. The Demo must depend on the facade only.
- Use Swift access control deliberately: `public` for supported facade/value APIs, `package` for cross-target implementation/testing seams, internal by default, and `private`/`fileprivate` for local helpers.
- Place new behavior with its owner: models/diagnostics in `BeautyCore`, observation/mapping in `BeautyDetection`, render primitives in `BeautyRender`, effects/planning in `BeautyEffects`, resources in `BeautyResources`, and facade orchestration in `BeautySDK`.

**Barrel Files:**
- Minimal module marker files exist (`BeautySDK/Sources/BeautyCore/BeautyCore.swift`, `BeautySDK/Sources/BeautyDetection/BeautyDetection.swift`, `BeautySDK/Sources/BeautyEffects/BeautyEffects.swift`, `BeautySDK/Sources/BeautyRender/BeautyRender.swift`, and `BeautySDK/Sources/BeautyResources/BeautyResources.swift`), but APIs are declared in their owning files rather than re-exported through large barrel files.

---

*Convention analysis: 2026-08-13*
