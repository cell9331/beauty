# Phase 1: SDK Foundation and Public Facade - Research

**Researched:** 2026-06-10
**Domain:** iOS Swift Package SDK foundation, public facade API, no-op image/frame processing, validation, and package tests
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Use overloaded `process(...)` APIs: `process(pixelBuffer:orientation:parameters:)` and `process(image:orientation:parameters:)`.
- Primary processing APIs return media objects directly: `CVPixelBuffer` and `CIImage`.
- `BeautyEngine` must not own caller parameter state; every process call receives an explicit `BeautyParameters` snapshot.
- Expose a lightweight public `BeautyResult` model, but do not make primary `process(...)` APIs return it in Phase 1.
- No-op processing returns a new SDK-created or SDK-owned output, not the same input reference.
- Unsupported no-op copy/output inputs return typed `BeautyError` values; do not silently return the original input.
- No-op tests must prove pixel-level equality or fixed documented tolerance against fixtures.
- Output lifecycle must be documented as SDK-created and readable for the current processing result lifecycle.
- Ordinary out-of-range numeric parameters clamp to documented public ranges.
- `NaN` and infinity reset to no-op defaults and become validation warning/diagnostic candidates.
- Unknown preset JSON fields are ignored for forward compatibility and must not trigger behavior.
- Presets with unknown `filterId` or resource IDs fail validation with typed errors; no partial application.
- Phase 1 implements `BeautyPreset` model, decoding, and validation only. Built-in preset registry belongs to Phase 5.

### the agent's Discretion
- No user-delegated discretion areas. Planner may choose execution ordering and file granularity as long as it preserves all locked decisions and repository contracts.

### Deferred Ideas (OUT OF SCOPE)
- Visual beauty effects, Demo UI replacement, camera/photo input, Vision detection, LUT resources, built-in preset packs, makeup, segmentation, body shaping, stickers, style effects, and video export.
</user_constraints>

<architectural_responsibility_map>
## Architectural Responsibility Map

| Capability | Primary Owner | Secondary Owner | Rationale |
|------------|---------------|-----------------|-----------|
| Swift Package and target graph | `BeautySDK/Package.swift` | `ARCHITECTURE.md` | The package manifest is the source of buildable target boundaries. |
| Public facade imports | `BeautySDK` target | `BeautyCore` models | Host apps import only `BeautySDK`; internals can live in lower targets. |
| Public value models | `BeautyCore` | `BeautySDK` facade re-export | Shared models are stable, `Codable`, `Equatable`, and `Sendable`. |
| Parameter normalization and validation | `BeautyCore` | Tests | Validation must happen before render/effects and is pure model behavior. |
| Preset decoding and schema validation | `BeautyCore` initially | `BeautyResources` later | Phase 1 does model/decode/validate only; resource registries come later. |
| No-op processing | `BeautyCore` engine + `BeautyRender` copy primitives | `BeautySDK` facade | Engine owns public process/reset surface; render owns output allocation/copy mechanics. |
| Typed errors and redacted diagnostics | `BeautyCore/Diagnostics` | `RELIABILITY.md`, `SECURITY.md` | Public failures cross as `BeautyError`; logs and warnings must be redacted. |
| Foundation tests | `BeautySDK/Tests/**` | Existing `QUALITY_SCORE.md` scans | Phase completion is test evidence, not just compile evidence. |
</architectural_responsibility_map>

<research_summary>
## Summary

Phase 1 should be planned as a buildable SDK foundation, not a visual feature slice. The standard approach is a single Swift Package with multiple internal targets and one facade product named `BeautySDK`. Public host-facing types can be implemented in `BeautyCore` and re-exported or wrapped by the `BeautySDK` target, but tests must prove a host-style import needs only `import BeautySDK`.

The safest no-op processing strategy is to implement a deterministic output path that creates SDK-owned outputs for supported `CVPixelBuffer` and `CIImage` inputs. `CVPixelBuffer` no-op should support a documented first format, preferably BGRA, with explicit typed errors for unsupported formats or invalid dimensions. `CIImage` no-op can create a new `CIImage` value from the original image data or a copied/rendered backing depending on what is practical, but tests must assert preservation by pixels or fixed tolerance.

Validation should be test-first because it is pure and has a stable contract: parameter ranges, non-finite values, preset schema, unknown fields, unknown resources, typed errors, and redacted diagnostics. The plan should separate package/facade scaffolding, value-model validation, no-op engine/render behavior, and final verification so each step can compile and test independently.

**Primary recommendation:** Implement the SDK as four executable plan slices matching the roadmap: package/facade skeleton, value models and validation, no-op engine/output path, and foundation verification.
</research_summary>

<standard_stack>
## Standard Stack

### Core

| Library / Framework | Version | Purpose | Why Standard |
|---------------------|---------|---------|--------------|
| Swift Package Manager | Apple Swift toolchain | Local package, target graph, package tests | Native way to build reusable Swift modules and run `swift test --package-path BeautySDK`. |
| XCTest | Apple SDK | Unit and integration-style package tests | Native Swift test runner available without adding third-party dependencies. |
| Foundation | Apple SDK | `Codable`, value models, errors, dates, JSON decoding | Baseline dependency for public model and preset behavior. |
| CoreGraphics | Apple SDK | `CGSize`, geometry primitives, image dimensions | Already used in design contracts for processing size and model geometry. |
| CoreVideo | Apple SDK | `CVPixelBuffer`, pixel buffer lifecycle, format inspection | Required for realtime/frame-style no-op path. |
| CoreImage | Apple SDK | `CIImage` still-image input/output path | Fits the public image path without introducing UIKit into the SDK. |
| ImageIO | Apple SDK | `CGImagePropertyOrientation` | Keeps orientation explicit without exposing UIKit. |
| OSLog | Apple SDK | Redacted local diagnostics | Matches `RELIABILITY.md` observability direction. |

### Supporting

| Library / Framework | Version | Purpose | When to Use |
|---------------------|---------|---------|-------------|
| Metal | Apple SDK | Future render/copy foundation and shader resource layout | Add only as needed for `BeautyRender` primitives; do not force real effects in Phase 1. |
| CoreMedia | Apple SDK | Future frame timestamps and realtime metadata | Keep out of public Phase 1 API unless a concrete type needs it. |
| Vision | Apple SDK | Future detection target | Stub protocols only in Phase 1; Vision implementation belongs to Phase 4. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| XCTest | Swift Testing | Modern syntax, but existing docs and package examples expect XCTest and XCTest is sufficient. |
| SPM package-first | Xcode framework target | Xcode integration is useful later, but Phase 1 success criteria require a local Swift Package. |
| Direct media returns | `BeautyResult` primary return | Result envelope helps diagnostics, but user locked direct `CVPixelBuffer` / `CIImage` returns for Phase 1. |
</standard_stack>

<architecture_patterns>
## Architecture Patterns

### System Architecture Diagram

```text
Host app / host-style test
  -> import BeautySDK
  -> BeautyEngine(configuration:)
  -> process(pixelBuffer:orientation:parameters:)
       -> validate pixel buffer + parameters
       -> BeautyRender no-op/copy output path
       -> CVPixelBuffer output OR BeautyError
  -> process(image:orientation:parameters:)
       -> validate image + parameters
       -> no-op/copy image output path
       -> CIImage output OR BeautyError

Preset JSON
  -> BeautyPreset decode
  -> schema/version/id/range/resource validation
  -> BeautyParameters snapshot OR BeautyError
```

### Recommended Project Structure

```text
BeautySDK/
├── Package.swift
├── Sources/
│   ├── BeautyCore/
│   │   ├── Diagnostics/
│   │   ├── Engine/
│   │   └── Models/
│   ├── BeautyDetection/
│   ├── BeautyRender/
│   │   └── Shaders/
│   ├── BeautyEffects/
│   ├── BeautyResources/
│   └── BeautySDK/
└── Tests/
    ├── BeautyCoreTests/
    ├── BeautyRenderTests/
    └── BeautySDKTests/
```

Phase 1 can create only the test targets it needs immediately, but `Package.swift` should declare enough target structure to satisfy `SDK-01`.

### Pattern 1: Facade target as the only host import

**What:** Implement public types in stable lower targets where appropriate, then expose them through the `BeautySDK` target.
**When to use:** Public types must be accessible to host code while keeping target boundaries visible internally.
**Planner implication:** Include a facade import test that imports `BeautySDK` only and references `BeautyEngine`, `BeautyConfiguration`, `BeautyParameters`, `BeautyPreset`, `BeautyResult`, and `BeautyError`.

### Pattern 2: Value models before engine behavior

**What:** Implement `BeautyConfiguration`, `BeautyRenderQuality`, `BeautyLogLevel`, `BeautyParameters`, `BeautyPreset`, `BeautyResult`, and `BeautyError` before process behavior.
**When to use:** Engine APIs depend on validated model contracts and typed errors.
**Planner implication:** Put model tests before engine tests so failures are localized.

### Pattern 3: Copy/no-op path with explicit supported input envelope

**What:** Support a small documented set of pixel formats and image conditions, then fail typed for everything else.
**When to use:** Foundation phase needs deterministic behavior without hiding unsupported render cases.
**Planner implication:** Tests should include supported BGRA fixture output equality and at least one unsupported-format or invalid-input error path.

### Anti-Patterns to Avoid

- **Returning the original input as success:** Violates the locked no-op output semantics and future render lifecycle.
- **Leaking internals through the facade:** Host-style tests should not import lower targets.
- **Turning Phase 1 into visual effects:** Any real smoothing, filters, face detection, or built-in named preset pack belongs to later phases.
- **Adding UIKit or SwiftUI to SDK targets:** UI remains in `BeautyDemo` or host apps.
- **Logging raw paths, pixels, JSON, or facial data:** Diagnostics must stay redacted even in debug-friendly foundation code.
</architecture_patterns>

<common_pitfalls>
## Common Pitfalls

### Pitfall 1: SPM target visibility does not equal facade-only API
**What goes wrong:** Internal targets are public enough for tests or downstream packages to import directly, and Demo/host tests accidentally depend on `BeautyCore`.
**Why it happens:** Swift Package target boundaries are not the same as a product-level integration policy.
**How to avoid:** Create a `BeautySDKTests` host-style test target that imports only `BeautySDK`; add an import scan for Demo and tests where appropriate.
**Warning signs:** Tests import `@testable import BeautyCore` for facade behavior, or Demo code imports internal targets.

### Pitfall 2: Parameter clamping hides non-finite values
**What goes wrong:** `NaN` or infinity survives in a `Float`, reaches render uniforms, and creates undefined GPU behavior later.
**Why it happens:** Ordinary `min(max(value))` clamp code does not handle `NaN` safely.
**How to avoid:** Centralize finite checks before range clamping; reset non-finite values to `0` and record validation diagnostics where supported.
**Warning signs:** Tests cover `1.5` and `-2` but not `.nan`, `.infinity`, and `-.infinity`.

### Pitfall 3: Preset validation partially applies broken resources
**What goes wrong:** A preset changes model values while silently dropping unknown `filterId`, causing UI and render state to disagree.
**Why it happens:** Decoder treats unknown resource references as optional instead of invalid.
**How to avoid:** Separate unknown JSON fields from unknown resource IDs: ignore unknown fields, but reject unknown resource IDs.
**Warning signs:** A preset with `filterId: "missing"` still produces a successful `BeautyPreset`.

### Pitfall 4: No-op tests only verify shape
**What goes wrong:** The no-op path compiles and returns a buffer, but pixel content is changed, uninitialized, or format-corrupted.
**Why it happens:** Tests only check non-nil output, dimensions, or pixel format.
**How to avoid:** Use deterministic fixture buffers/images and compare output pixels with equality or a documented tolerance.
**Warning signs:** No test reads output bytes or compares against input fixtures.

### Pitfall 5: Xcode build evidence uses the wrong destination
**What goes wrong:** `xcodebuild` selects `My Mac` and fails for reasons unrelated to SDK validity.
**Why it happens:** Generic builds do not force an iOS Simulator destination.
**How to avoid:** Use `xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj -scheme BeautyDemo -destination 'platform=iOS Simulator,name=<Simulator Name>,OS=<OS Version>' build` when verifying Demo project integration.
**Warning signs:** Build failure says the target does not support the selected destination.
</common_pitfalls>

<implementation_recommendations>
## Implementation Recommendations for Planning

### Plan 01-01: Swift Package and Facade Skeleton
- Create `BeautySDK/Package.swift` with a library product named `BeautySDK`.
- Declare targets for `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, and `BeautySDK`.
- Keep the first target files minimal but buildable.
- Add at least one facade smoke test that imports `BeautySDK`.

### Plan 01-02: Public Models and Validation
- Implement model files before engine logic.
- Cover all 31 `BeautyParameters` fields from `DESIGN.md`.
- Include initializer or normalization helpers that clamp ordinary values and zero non-finite values.
- Implement `BeautyPreset` decoding and validation with schema version, conservative `id` validation, unknown-field tolerance, unknown-resource rejection, and typed errors.

### Plan 01-03: No-op Engine and Output Path
- Implement `BeautyEngine.init(configuration:) throws`, direct-media `process(...)` overloads, and idempotent `reset()`.
- Validate inputs before expensive work.
- Produce SDK-owned outputs for supported no-op paths.
- Return typed errors for unsupported pixel formats, invalid dimensions, output allocation failures, and render/copy failures.

### Plan 01-04: Verification and Boundary Tests
- Run `swift test --package-path BeautySDK`.
- Run import-boundary scans for forbidden internal imports.
- Run crash-shortcut scans for `fatalError`, `try!`, and forced casts in SDK sources.
- Run `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj`.
- If package wiring into the Demo project is added, run an explicit iOS Simulator build; otherwise record that Demo project integration remains Phase 2 scope.
</implementation_recommendations>

<validation_architecture>
## Validation Architecture

### Automated Test Stack
- Primary framework: XCTest package tests under `BeautySDK/Tests/**`.
- Quick command: `swift test --package-path BeautySDK`.
- Static architecture scans:
  - `rg -n "import BeautyCore|import BeautyRender|import BeautyDetection|import BeautyEffects|import BeautyResources" BeautyDemo BeautySDK/Tests`
  - `rg -n "SwiftUI|UIKit" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyDetection BeautySDK/Sources/BeautyEffects`
  - `rg -n "fatalError|try!|as!" BeautySDK/Sources BeautyDemo/BeautyDemo`
- Project discovery command: `xcodebuild -list -project BeautyDemo/BeautyDemo.xcodeproj`.

### Required Coverage
| Requirement | Evidence |
|-------------|----------|
| SDK-01 | `Package.swift` declares required targets and `swift test --package-path BeautySDK` builds them. |
| SDK-02 | Host-style test imports only `BeautySDK` and references all facade types. |
| SDK-03 | `BeautyParameters` has 31 documented fields, defaults, `Codable`, `Equatable`, `Sendable`, and range tests. |
| SDK-04 | Pixel fixture tests prove no-op preservation for frame and image paths within fixed tolerance. |
| SDK-05 | Validation tests cover ordinary clamping, non-finite zeroing, preset unknown fields, and unknown resource failures. |
| SDK-06 | Error mapping tests assert typed `BeautyError` and redacted associated values. |
| SDK-07 | Package test suite includes facade imports, model tests, validation tests, preset decoding, no-op processing, and error mapping. |

### Manual Verification
- No required manual verification for Phase 1 foundation behavior.
- If local Xcode lacks a matching simulator, record the exact `xcodebuild` failure instead of claiming Demo build evidence.
</validation_architecture>

<risk_summary>
## Risk Summary

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Package target graph overbuilds beyond foundation | Medium | Medium | Keep visual effects and resource registries out of Phase 1. |
| No-op copy path becomes too Metal-heavy | Medium | Medium | Plan direct deterministic copy first; use typed errors where unsupported. |
| `BeautyResult` scope expands into debug API | Medium | Low | Expose lightweight model only; defer result-returning process APIs. |
| Existing dirty docs obscure plan commits | High | Low | Stage and commit only explicit Phase 1 plan files, STATE, and ROADMAP. |
| Tests depend on unavailable simulator | Low | Medium | Keep core verification in `swift test`; use simulator builds only for Xcode project evidence. |
</risk_summary>

---

## RESEARCH COMPLETE
