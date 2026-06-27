# Phase 18: Skin Retouch Core Modules - Research

**Researched:** 2026-06-27
**Domain:** Swift `BeautySDK` skin-retouch implementation, resolver behavior, renderer validation
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
## Implementation Decisions

### Basic Skin Ambition
- **D-01:** Phase 18 should improve Basic skin output formulas, not merely add evidence. The work stays behind existing SDK boundaries and uses the current public skin parameters only.
- **D-02:** Do not add public skin parameters in Phase 18. Any future public parameter expansion for blemish, pore, texture, teeth, or hairline requires root contract updates before implementation.
- **D-03:** Medium strengths around `0.4...0.6` should be naturally conservative: cleaner and slightly brighter, while preserving skin texture and facial-feature edges. Renderer visibility is not allowed to override naturalness.
- **D-04:** Implementation depth is limited to the existing pipeline surface: `BeautyColorEffectPipeline`, resolver behavior, tests, renderer evidence, and related docs. Do not add a new target, do not introduce a separate render pass, and do not start a production `SkinPass` redesign in this phase.
- **D-05:** `skinSmoothing` remains a lightweight softening proxy. It must not become true blemish removal, local repair, region inpainting, segmentation, or aggressive texture removal.

### Face and No-Face Skin Behavior
- **D-06:** Public facade and renderer paths should keep Basic skin visibly effective when detection has not run or facade-visible face geometry is unavailable. In that context, Basic skin is a lightweight full-frame skin-tone improvement.
- **D-07:** Document the layering clearly: public facade no-detection paths can apply Basic skin full-frame, while explicit internal no-face resolver contexts may skip face-dependent skin for future detection-integrated flows.
- **D-08:** If a later implementation has face-quality information, low-confidence, side-face, or too-small-face states may conservatively weaken Basic skin rather than silently applying full strength. The weakening must emit redacted `BeautyResult.warnings` and/or `metrics`.
- **D-09:** Skin degradation evidence belongs in result metadata only. Do not add ordinary UI copy, new Demo banners, public geometry payloads, bounding boxes, landmarks, or raw detector details.

### Future Branch Promotion
- **D-10:** Do not promote Skin repair in Phase 18. It remains `future`; Phase 18 may clarify boundaries but must not implement blemish, pore, texture, or localized cleanup.
- **D-11:** Do not promote Teeth/hairline in Phase 18. It remains `future`; do not implement teeth whitening, hairline adjustment, segmentation, mouth-region teeth logic, or optional resource ownership.
- **D-12:** Phase 18 plans must include negative checks that prevent accidental future-branch implementation. Checks should confirm no new public parameters/API, no new skin-repair or teeth/hairline renderer cases, no resource ownership promotion, no segmentation/AI/upload dependency, and no completion claim for those future branches.
- **D-13:** Future branch docs should be explicit: Phase 18 does not implement these branches and must not claim completion. A later promotion requires independent design plus updates to the owning architecture, design, security, reliability, and product contracts as applicable.

### Verification Threshold
- **D-14:** Phase 18 completion requires focused XCTest coverage for skin parameter/resolver/engine behavior, `BeautyExampleRenderer` build/run evidence for Basic skin, same-dimension output checks, factual visual inspection, and future-branch negative scans.
- **D-15:** Renderer evidence should run all current skin cases: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, and `skinCombo_0p50`.
- **D-16:** Visual observations must stay factual: output is non-empty, watermark is readable, watermark does not cover the face, dimensions match, and skin cases show visible but natural changes. Do not claim commercial-grade naturalness, production render quality, or release-like visual QA.
- **D-17:** Full `swift test --package-path BeautySDK` is not a fixed Phase 18 completion gate. Executors may run it as extra evidence, but the required gate is focused tests plus skin renderer cases, dimension checks, factual visual review, and negative scans.

### the agent's Discretion
The planner may choose exact plan split, test file names, formula constants, warning/metric key names, and scan command details as long as the decisions above remain intact. Formula changes should be conservative, localized, and testable.

### Deferred Ideas (OUT OF SCOPE)
## Deferred Ideas

- True skin repair, blemish cleanup, pore/texture repair, inpainting, region masks, or segmentation are deferred to a later independently designed phase.
- Teeth whitening and hairline adjustment are deferred to a later phase that can define mouth/teeth or hair/forehead confidence, privacy, reliability, resource, and parameter contracts.
- A production `SkinPass`, dense face mesh, segmentation-aware skin processing, commercial-grade naturalness QA, and release-like visual validation remain outside Phase 18.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SKIN-01 | Basic skin, skin repair, and teeth/hairline branches each have branch documentation and module ownership. | Existing branch docs already define Basic skin as `implemented` and Skin repair / Teeth-hairline as `future`; Phase 18 should audit and tighten those docs without promoting future branches. [VERIFIED: repo grep] |
| SKIN-02 | Promoted skin-retouch branches implement core logic behind SDK boundaries with degradation behavior, parameter caps, and tests. | Basic skin is the only promoted branch; implementation belongs in `BeautyEffects` / `BeautyColorEffectPipeline`, with caps in `BeautySafetyCaps`, resolver evidence in `BeautyEffectResolver`, and public facade output through `BeautyEngine`. [VERIFIED: repo grep] |
| SKIN-03 | Current MVP skin controls stay separated from future local repair or region-based retouch capabilities. | `BeautyParameters` exposes only `skinSmoothing`, `skinWhitening`, `skinRosy`, and `skinSharpen`; future repair, teeth, hairline, segmentation, and resource ownership must remain absent from SDK public API and renderer cases. [VERIFIED: repo grep] |
</phase_requirements>

## Summary

Phase 18 should be planned as a narrow SDK implementation phase: audit the skin-retouch branch contracts, improve Basic skin formulas inside the existing `BeautyColorEffectPipeline`, and verify focused behavior through XCTest plus all current Basic skin renderer cases. [VERIFIED: `.planning/phases/18-skin-retouch-core-modules/18-CONTEXT.md`, `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`, `BeautySDK/Sources/BeautyExampleRenderer/main.swift`]

The only promoted Phase 18 branch is Basic skin. Skin repair and Teeth/hairline are documented future branches, so implementation plans must include negative scans that prevent public parameters, renderer cases, resources, segmentation, AI/upload flows, or completion language from being introduced for those branches. [VERIFIED: `18-CONTEXT.md`, `docs/meitu-function-blueprint/features/skin-retouch/README.md`, `docs/meitu-function-blueprint/FEATURE_MATRIX.md`]

**Primary recommendation:** Use three execution plans matching the roadmap slots: `18-01` audit branch contracts and current controls, `18-02` make localized Basic skin formula/test/doc changes, and `18-03` run focused tests, all five current skin renderer cases, same-dimension checks, factual visual review, facade/import scans, and future-branch negative scans. [VERIFIED: `.planning/ROADMAP.md`, `18-CONTEXT.md`]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Basic skin parameter model and clamping | SDK Core Model (`BeautyCore`) | Effect resolver (`BeautyEffects`) | Public fields and boundary normalization live in `BeautyParameters`; algorithm caps live separately in `BeautySafetyCaps` / resolver. [VERIFIED: `BeautyParameters.swift`, `BeautySafetyCaps.swift`, `BeautyEffectResolver.swift`] |
| Basic skin formula output | Effect/render pipeline (`BeautyEffects`) | Public facade (`BeautySDK`) | `BeautyColorEffectPipeline` owns visible color/skin transformation, and `BeautyEngine.processResult(...)` exposes it through the public facade. [VERIFIED: `BeautyColorEffectPipeline.swift`, `BeautyEngine.swift`] |
| No-detection facade-visible Basic skin | Public facade (`BeautySDK`) | Effect resolver (`BeautyEffects`) | Facade calls `BeautyEffectResolver.resolve(parameters:)`, which does not treat missing face as no-face, so skin remains active for public renderer/no-detection paths. [VERIFIED: `BeautyEngine.swift`, `BeautyEffectResolver.swift`] |
| Explicit internal no-face skin skip | Effect resolver (`BeautyEffects`) | Tests | Internal resolver overload with `faceGeometry: nil` treats missing face as no-face and skips `.skin`, preserving future detection-integrated semantics. [VERIFIED: `BeautyEffectResolver.swift`, `CombinedEffectSafetyTests.swift`] |
| Example-image validation | Public facade renderer executable | Shell/dimension/manual checks | `BeautyExampleRenderer` imports only `BeautySDK`, reads `example-images/input`, writes ignored PNGs under `example-images/out`, and includes all current Basic skin cases. [VERIFIED: `BeautyExampleRenderer/main.swift`, `EXAMPLE_IMAGE_VALIDATION.md`, `git check-ignore`] |
| Skin repair and Teeth/hairline future boundaries | Documentation contracts | Negative scans | Branch docs and feature matrix mark these branches `future`; Phase 18 must keep them non-implemented. [VERIFIED: `skin-repair/README.md`, `teeth-hairline/README.md`, `FEATURE_MATRIX.md`] |

## Project Constraints (from AGENTS.md)

- Repo text is the system of record; facts not present in repo text must not be treated as existing. [CITED: AGENTS.md]
- Read order is `AGENTS.md`, then `PLANS.md`, then task-specific docs, then code/tests/history docs. [CITED: AGENTS.md]
- Conflict priority is code and tests, then `PLANS.md`, then specialized docs, then historical `docs/` material. [CITED: AGENTS.md]
- Scope must not expand; extra problems go to `PLANS.md` instead of being fixed opportunistically. [CITED: AGENTS.md]
- Contract changes require updating the owning root contract: public behavior in `PRODUCT_SENSE.md`, architecture boundaries in `ARCHITECTURE.md`, risk boundaries in `SECURITY.md`, and performance/log/error behavior in `RELIABILITY.md`. [CITED: AGENTS.md]
- Do not overwrite unrelated local changes. [CITED: AGENTS.md]
- Xcode builds should explicitly choose an available iOS Simulator; if local Xcode configuration fails, record the reproducible failure instead of faking verification. [CITED: AGENTS.md]

## Standard Stack

### Core

| Library / Target | Version | Purpose | Why Standard |
|------------------|---------|---------|--------------|
| Swift Package Manager package `BeautySDK` | `swift-tools-version: 6.0`; local Swift is Apple Swift 6.3.3 | Builds library targets, tests, and `BeautyExampleRenderer`. | Existing package format and phase validation path use SwiftPM. [VERIFIED: `BeautySDK/Package.swift`, `swift --version`] |
| `BeautyCore` | repo target | Owns `BeautyParameters`, `BeautyResult`, `BeautyInputMetadata`, and safe public models. | Public parameters and result metadata are already centralized here. [VERIFIED: `Package.swift`, `BeautyParameters.swift`, `BeautyEngine.swift`] |
| `BeautyEffects` | repo target | Owns resolver caps, active/skipped domains, warnings, metrics, and visible skin/color formula pipeline. | Phase 18 Basic skin implementation surface is explicitly constrained to this target. [VERIFIED: `18-CONTEXT.md`, `BeautyEffectResolver.swift`, `BeautyColorEffectPipeline.swift`] |
| `BeautySDK` facade | repo target | Exposes host-facing `BeautyEngine` and validates parameters through public facade paths. | Renderer and host-like validation must import only `BeautySDK`. [VERIFIED: `BeautyEngine.swift`, `BeautyExampleRenderer/main.swift`, `MODULES.md`] |
| XCTest | SwiftPM test targets | Focused unit/integration validation. | Existing skin caps, resolver, engine, and pipeline behavior are already covered by XCTest files. [VERIFIED: `BeautySDK/Tests/**`] |
| `BeautyExampleRenderer` | SwiftPM executable product | Saves fixture outputs for visible Basic skin cases. | Phase 18 requires renderer evidence for all current skin cases. [VERIFIED: `Package.swift`, `BeautyExampleRenderer/main.swift`, `18-CONTEXT.md`] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| Core Image (`CIImage`, `CIColorControls`, `CIColorMatrix`) | Apple platform framework via Swift source | Image-path Basic skin/color transformation. | Formula changes should keep using the existing Core Image path for `CIImage` outputs. [VERIFIED: `BeautyColorEffectPipeline.swift`] |
| Core Video (`CVPixelBuffer`) | Apple platform framework via Swift source | Pixel-buffer Basic skin/color transformation. | Pixel-buffer tests should verify parity at the byte/pixel level where feasible. [VERIFIED: `BeautyColorEffectPipeline.swift`, `BeautyEngineTests.swift`] |
| `file` CLI | `file-5.41` | Confirms output dimensions. | Use for representative input/output dimension checks after renderer runs. [VERIFIED: environment probe, `EXAMPLE_IMAGE_VALIDATION.md`] |
| `rg` CLI | available in repo workflow | Static source/doc scans. | Use for facade-only imports, future-branch negative scans, and completion-claim scans. [VERIFIED: AGENTS.md usage, successful grep commands] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Existing `BeautyColorEffectPipeline` formula edits | New production `SkinPass` / new render pass | Disallowed by Phase 18 context; would expand architecture, pass ownership, performance, and validation scope. [VERIFIED: `18-CONTEXT.md`] |
| Existing public skin parameters | New blemish/pore/teeth/hairline parameters | Disallowed by Phase 18 context and root design contract unless root contracts are updated first. [VERIFIED: `18-CONTEXT.md`, `DESIGN.md`] |
| Local ignored renderer outputs | Committed PNG evidence under `.planning/evidence` | Phase 16/18 context keeps generated outputs local and ignored unless later promoted. [VERIFIED: `16-PATTERNS.md`, `18-CONTEXT.md`, `git check-ignore`] |

**Installation:** No external package installation is required for Phase 18. [VERIFIED: `Package.swift`, `.planning/config.json`]

```bash
# no new packages
```

## Package Legitimacy Audit

No external packages are recommended or installed for Phase 18, so the package legitimacy gate is not applicable. [VERIFIED: `Package.swift`, research scope]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| none | — | — | — | — | — | No external package install |

**Packages removed due to slopcheck [SLOP] verdict:** none.
**Packages flagged as suspicious [SUS]:** none.

## Current Source / Test / Doc Map

| Area | Files | Current Behavior / Planning Relevance |
|------|-------|----------------------------------------|
| Public skin fields | `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | Exposes `skinSmoothing`, `skinWhitening`, `skinRosy`, and `skinSharpen`; initializer clamps unit fields and non-finite values resolve to zero. [VERIFIED: codebase grep] |
| Algorithm safety caps | `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | Caps are `skinSmoothing=0.60`, `skinWhitening=0.50`, `skinRosy=0.40`, and `skinSharpen=0.40`. [VERIFIED: codebase grep] |
| Resolver activation / no-face | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | Public `resolve(parameters:)` keeps Basic skin active without face geometry; internal explicit no-face resolution skips `.skin` and emits redacted warning/metric evidence. [VERIFIED: codebase grep] |
| Result surface | `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` | Plans expose active/skipped domains, warnings, metrics, and effective strengths; `BeautyEngine.processResult` forwards warnings/metrics to `BeautyResult`. [VERIFIED: codebase grep] |
| Visible Basic skin formula | `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` | Current formula uses brightness/lift, contrast/sharpen, rosy red bias, whitening lift/green bias, and smoothing toward luminance in both pixel-buffer and Core Image paths. [VERIFIED: codebase grep] |
| Public renderer cases | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | Existing skin cases are `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, and `skinCombo_0p50`; executable imports only `BeautySDK`. [VERIFIED: codebase grep] |
| Renderer docs | `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | Documents build/run commands, output naming, watermark placement, current built-in cases, and geometry limitation. [CITED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] |
| Branch docs | `docs/meitu-function-blueprint/features/skin-retouch/**/README.md` | Basic skin is `implemented`; Skin repair and Teeth/hairline are `future` with no current public parameters. [CITED: skin-retouch branch docs] |
| Matrix / ownership docs | `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `MODULES.md`, `shared/IMPLEMENTATION_PRINCIPLES.md` | Matrix and module docs define branch status vocabulary, owners, dependencies, and evidence ladder. [CITED: blueprint docs] |
| Existing skin tests | `BeautyEffectResolverTests.swift`, `BeautySafetyCapsTests.swift`, `CombinedEffectSafetyTests.swift`, `BeautyParametersTests.swift`, `BeautyEngineTests.swift` | Existing coverage includes clamping, caps, active domains, no-face skip, redacted metadata, and facade-visible output, but lacks a dedicated Basic-skin formula regression file. [VERIFIED: codebase grep] |

## Likely Files To Edit / Create

| File | Expected Change | Risk Touched | Planner Guidance |
|------|-----------------|--------------|------------------|
| `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` | Localized Basic skin formula improvements for pixel-buffer and `CIImage` paths. | Visual regression, default no-op, parity between pixel-buffer and image paths. | Keep formula conservative, deterministic, cropped to input extent, and test medium strengths. [VERIFIED: `18-CONTEXT.md`, codebase grep] |
| `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift` | New focused formula tests for smoothing, whitening, rosy, sharpen, combo, no-op, and medium-strength natural caps. | Missing regression evidence for formula constants. | Prefer small fixtures and explicit channel/delta assertions over broad “bytes changed” only. [VERIFIED: existing test patterns] |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | Add/adjust tests for public facade-style skin active behavior and capped metadata. | Confusion between facade no-detection and explicit no-face resolver semantics. | Preserve public `resolve(parameters:)` active skin and internal `resolve(parameters:faceGeometry:nil)` skip behavior. [VERIFIED: `BeautyEffectResolver.swift`, `CombinedEffectSafetyTests.swift`] |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` | Add facade-visible Basic skin cases if formula changes need public-path assertions. | Public result warnings/metrics and no-detection behavior. | Use `BeautyEngine.processResult` for host-facing evidence, not internal imports. [VERIFIED: `BeautyEngineTests.swift`] |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | Usually no change because required skin cases already exist. | Accidental future-branch renderer case promotion. | Do not add skin repair, teeth, hairline, segmentation, or AI cases. [VERIFIED: `main.swift`, `18-CONTEXT.md`] |
| `docs/meitu-function-blueprint/features/skin-retouch/**` | Tighten branch wording after implementation if needed. | Overclaiming future branches or commercial-grade quality. | Keep Basic skin implemented; keep repair and teeth/hairline future. [VERIFIED: branch docs] |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | Update only if commands/cases/evidence expectations materially change. | Duplicate validation authority. | Keep renderer commands and current skin cases authoritative here. [VERIFIED: docs] |
| `PLANS.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md` | Execution closeout only after fresh evidence. | Ledger overclaiming. | Mark SKIN requirements complete only after tests, renderer cases, dimensions, visual observations, and negative scans pass. [VERIFIED: GSD patterns and current ledgers] |

## Architecture Patterns

### System Architecture Diagram

```text
Host / renderer input parameters
  -> BeautyParameters initializer
     -> clamps public normalized fields
  -> BeautySDK.BeautyEngine.processResult(...)
     -> BeautySDKResources.validate(parameters:)
     -> BeautyEffectResolver.resolve(parameters:)
        -> public facade path: no face required for Basic skin
        -> internal explicit no-face path: skip face-dependent skin
        -> caps strengths and emits redacted warnings/metrics
     -> BeautyColorEffectPipeline.apply(...)
        -> pixel-buffer path or CIImage path
        -> Basic skin formula: smoothing / whitening / rosy / sharpen
     -> BeautyResult output + warnings + metrics + detection summary
  -> BeautyExampleRenderer
     -> saves same-dimension watermarked PNGs under ignored example-images/out/
```

### Recommended Project Structure

```text
BeautySDK/
├── Sources/
│   ├── BeautyCore/Models/BeautyParameters.swift
│   ├── BeautyEffects/Planning/BeautyEffectResolver.swift
│   ├── BeautyEffects/Planning/BeautySafetyCaps.swift
│   ├── BeautyEffects/Render/BeautyColorEffectPipeline.swift
│   ├── BeautySDK/BeautyEngine.swift
│   └── BeautyExampleRenderer/main.swift
└── Tests/
    ├── BeautyCoreTests/BeautyEngineTests.swift
    ├── BeautyCoreTests/BeautyParametersTests.swift
    └── BeautyEffectsTests/
        ├── BeautyEffectResolverTests.swift
        ├── BeautySafetyCapsTests.swift
        ├── CombinedEffectSafetyTests.swift
        └── SkinBasicEffectTests.swift   # likely new focused file
```

### Pattern 1: Keep Public Range Separate From Effective Caps

**What:** Public values remain normalized `0...1`, then resolver caps effective strengths for natural output. [VERIFIED: `BeautyParameters.swift`, `BeautyEffectResolver.swift`]
**When to use:** Any Phase 18 formula or test touching strength behavior. [VERIFIED: `18-CONTEXT.md`]
**Example:**

```swift
let parameters = BeautyParameters(skinSmoothing: 1)
let plan = BeautyEffectResolver.resolve(parameters: parameters)
XCTAssertEqual(parameters.normalized().skinSmoothing, 1)
XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinSmoothing, BeautySafetyCaps.skinSmoothing)
```

### Pattern 2: Preserve Layered No-Face Semantics

**What:** `resolve(parameters:)` is facade-style and keeps Basic skin active without geometry; `resolve(parameters:faceGeometry:nil)` is explicit internal no-face and may skip skin. [VERIFIED: `BeautyEffectResolver.swift`, `CombinedEffectSafetyTests.swift`]
**When to use:** Tests and docs for D-06/D-07. [VERIFIED: `18-CONTEXT.md`]
**Example:**

```swift
let facadePlan = BeautyEffectResolver.resolve(parameters: BeautyParameters(skinSmoothing: 0.4))
XCTAssertTrue(facadePlan.activeDomains.contains(.skin))

let internalNoFacePlan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(skinSmoothing: 0.4),
    faceGeometry: nil
)
XCTAssertTrue(internalNoFacePlan.skippedDomains.contains(.skin))
```

### Pattern 3: Validate Visible Output Through Public Facade

**What:** Renderer and host-like tests should use `BeautyEngine.processResult(...)` and import public `BeautySDK` only. [VERIFIED: `BeautyExampleRenderer/main.swift`, `BeautyEngineTests.swift`, `MODULES.md`]
**When to use:** Renderer evidence and public-path skin output tests. [VERIFIED: `18-CONTEXT.md`]
**Example:**

```swift
let result = try engine.processResult(
    image: image,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: BeautyParameters(skinWhitening: 0.5)
)
```

### Anti-Patterns To Avoid

- **New `SkinPass` / new render pass:** Disallowed by Phase 18 context; use localized formula changes in `BeautyColorEffectPipeline`. [VERIFIED: `18-CONTEXT.md`]
- **Public API expansion:** New repair/teeth/hairline parameters require root contract updates and are out of Phase 18. [VERIFIED: `18-CONTEXT.md`, `DESIGN.md`]
- **Renderer overclaiming:** Do not add future-branch cases or claim release-like visual QA from local outputs. [VERIFIED: `18-CONTEXT.md`, `EXAMPLE_IMAGE_VALIDATION.md`]
- **Metadata leakage:** Warnings/metrics must not include paths, bounding boxes, landmarks, Vision objects, raw errors, image bytes, or detector details. [VERIFIED: `SECURITY.md`, existing tests]
- **Demo/UI changes:** v1.3 Phase 18 is SDK-level and no-new-UI. [VERIFIED: `.planning/ROADMAP.md`, `18-CONTEXT.md`, `AGENTS.md`]

## Existing Patterns To Reuse

| Concern | Reusable Pattern | Source |
|---------|------------------|--------|
| Effects | `BeautyEffectResolver` produces `activeDomains`, `skippedDomains`, `effectiveStrengths`, `warnings`, and `metrics`. | [VERIFIED: `BeautyEffectResolver.swift`, `BeautyEffectPlan.swift`] |
| Render cases | Static `RenderCase` values in `BeautyExampleRenderer/main.swift` map case IDs to `BeautyParameters`. | [VERIFIED: `BeautyExampleRenderer/main.swift`] |
| Warnings | Redacted `BeautyValidationWarning` codes/messages such as `beauty_strength_capped` and `face_effects_skipped_no_face`. | [VERIFIED: `BeautyEffectResolver.swift`, tests] |
| Parameter clamping | Constructor normalization clamps unit fields, signed fields, and non-finite values. | [VERIFIED: `BeautyParameters.swift`, `BeautyParametersTests.swift`] |
| Example-image validation | Build renderer, run cases, check ignored outputs, check dimensions, and record only factual visual observations. | [VERIFIED: `16-PATTERNS.md`, `18-CONTEXT.md`] |
| Future branch handling | Unsupported branches stay as docs/future or Demo-disabled taxonomy, not fake SDK behavior. | [VERIFIED: `FEATURE_MATRIX.md`, Demo grep] |

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Parameter range enforcement | Custom ad hoc clamps in render code | `BeautyParameters.normalized()` and `BeautyEffectResolver` caps | Boundary clamping and algorithm caps already exist and are tested. [VERIFIED: codebase grep] |
| Basic skin public-path validation | Internal target renderer harness | Existing `BeautyExampleRenderer` importing `BeautySDK` | Phase 16 established this as the public facade validation path. [VERIFIED: `16-PATTERNS.md`, `MODULES.md`] |
| Skin repair | Blemish/inpainting/local cleanup proxy | Future branch docs only | Phase 18 explicitly forbids implementing repair behavior. [VERIFIED: `18-CONTEXT.md`] |
| Teeth/hairline | Mouth-region teeth logic, hair segmentation, resource ownership | Future branch docs only | Phase 18 explicitly forbids teeth/hairline behavior. [VERIFIED: `18-CONTEXT.md`] |
| Visual QA scoring | Subjective beauty-grade claims | Factual observations and same-dimension checks | Phase 18 permits visible/natural observations but forbids commercial-grade or release-like claims. [VERIFIED: `18-CONTEXT.md`] |

**Key insight:** Phase 18 is a conservative formula-and-evidence phase, not a new algorithm family phase. [VERIFIED: `18-CONTEXT.md`]

## Common Pitfalls

### Pitfall 1: Collapsing Facade No-Detection And Internal No-Face Semantics
**What goes wrong:** A plan “fixes” no-face behavior by making either all skin always active or all skin always skipped. [VERIFIED: codebase grep]
**Why it happens:** `BeautyEffectResolver.resolve(parameters:)` and the internal overload with `faceGeometry` intentionally differ. [VERIFIED: `BeautyEffectResolver.swift`]
**How to avoid:** Add tests for both paths. [VERIFIED: `18-CONTEXT.md`]
**Warning signs:** Changes that remove `treatsMissingFaceAsNoFace` or rewrite `CombinedEffectSafetyTests.testNoFaceSkipsFaceDependentDomainsButKeepsColorAndFilterActive`. [VERIFIED: codebase grep]

### Pitfall 2: Making Smoothing Into Repair
**What goes wrong:** `skinSmoothing` starts behaving like blemish removal, local inpainting, segmentation, pore cleanup, or aggressive texture removal. [VERIFIED: `18-CONTEXT.md`]
**Why it happens:** Basic skin and Skin repair both sound like retouch, but Phase 18 only promotes Basic skin. [VERIFIED: `FEATURE_MATRIX.md`]
**How to avoid:** Keep `skinSmoothing` a lightweight full-frame proxy and keep repair docs future. [VERIFIED: `18-CONTEXT.md`]
**Warning signs:** New mask, region, repair, blemish, pore, or inpainting code in `BeautySDK/Sources`. [VERIFIED: negative-scan requirements]

### Pitfall 3: Pixel-Buffer / CIImage Formula Drift
**What goes wrong:** Renderer image outputs change but realtime pixel-buffer behavior diverges, or vice versa. [VERIFIED: `BeautyColorEffectPipeline.swift`]
**Why it happens:** The pipeline has separate `CVPixelBuffer` and `CIImage` transformation paths. [VERIFIED: codebase grep]
**How to avoid:** Tests should cover both path types or assert intentionally equivalent directionality for Basic skin controls. [VERIFIED: existing `BeautyEngineTests.swift` pattern]
**Warning signs:** Formula constants changed in one path only. [VERIFIED: codebase grep]

### Pitfall 4: Overclaiming Renderer Evidence
**What goes wrong:** Summary language claims production-grade naturalness, commercial quality, or completion for future branches. [VERIFIED: `18-CONTEXT.md`]
**Why it happens:** Saved PNG outputs are visually inspectable but are not release-like visual QA. [VERIFIED: `EXAMPLE_IMAGE_VALIDATION.md`]
**How to avoid:** Record factual observations only and scan docs/ledgers for future-branch completion claims. [VERIFIED: `18-CONTEXT.md`]
**Warning signs:** Phrases like “commercial-grade”, “production naturalness”, “skin repair complete”, or “teeth/hairline implemented” in Phase 18 artifacts. [VERIFIED: negative-scan requirements]

## Code Examples

### Focused Skin Formula Regression Shape

```swift
func testSkinWhiteningLiftsLuminanceConservatively() throws {
    let image = CIImage(color: CIColor(red: 0.35, green: 0.30, blue: 0.25, alpha: 1))
        .cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
    let plan = BeautyEffectResolver.resolve(parameters: BeautyParameters(skinWhitening: 0.5))
    let output = BeautyColorEffectPipeline.apply(to: image, plan: plan)

    XCTAssertNotEqual(try rgbaBytes(from: output), try rgbaBytes(from: image))
    XCTAssertLessThanOrEqual(plan.effectiveStrengths.skinWhitening, BeautySafetyCaps.skinWhitening)
}
```

Source pattern: `CombinedEffectSafetyTests.swift` and `BeautyEngineTests.swift`. [VERIFIED: codebase grep]

### Renderer Skin Case Loop

```bash
for case_id in skinSmoothing_0p50 skinWhitening_0p50 skinRosy_0p40 skinSharpen_0p40 skinCombo_0p50; do
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift run --package-path BeautySDK BeautyExampleRenderer \
    --input example-images/input \
    --output example-images/out \
    --case "$case_id"
done
```

Source pattern: `EXAMPLE_IMAGE_VALIDATION.md` plus Phase 18 D-15. [VERIFIED: docs and context]

### Future-Branch Negative Scan

```bash
! rg -n "skinRepair|skin repair|Skin repair|blemish|pore|inpainting|teeth whitening|hairline adjustment|skin-repair|teeth-hairline" \
  BeautySDK/Sources BeautySDK/Tests BeautySDK/Sources/BeautyExampleRenderer
```

This should be adjusted to allow existing docs and Demo-disabled taxonomy while preventing SDK implementation or renderer promotion. [VERIFIED: current negative scan]

## State Of The Art

| Old Approach | Current / Phase 18 Approach | When Changed | Impact |
|--------------|-----------------------------|--------------|--------|
| Coarse MVP Basic skin proxy evidence | Conservative localized formula improvements plus focused tests and all Basic skin renderer cases | Phase 18 context gathered 2026-06-27 | Plans should include implementation work, not evidence-only closeout. [VERIFIED: `18-CONTEXT.md`] |
| Single representative renderer case | All current skin cases required for Phase 18 | Phase 18 context gathered 2026-06-27 | Plans must run `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen`, and `skinCombo` cases. [VERIFIED: `18-CONTEXT.md`] |
| Broad future retouch possibility | Skin repair and Teeth/hairline explicitly future | Phase 17/18 contracts | Plans must add negative scans and avoid completion claims. [VERIFIED: `FEATURE_MATRIX.md`, `18-CONTEXT.md`] |

**Deprecated/outdated:** Treating Skin repair, Teeth/hairline, segmentation, or production `SkinPass` as Phase 18 work is outdated for this phase because the context locks them out. [VERIFIED: `18-CONTEXT.md`]

## Negative-Scan Requirements

Phase 18 plans should include these scans before claiming completion. [VERIFIED: `18-CONTEXT.md`]

| Risk | Command Pattern | Expected Result |
|------|-----------------|-----------------|
| New public repair/teeth/hairline parameters | `! rg -n "blemish|pore|texture|skinRepair|teeth|hairline" BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | No matches beyond existing allowed Basic skin fields. [VERIFIED: current codebase grep] |
| Future branch implementation in SDK | `! rg -n "skinRepair|skin repair|blemish|pore|inpainting|teeth whitening|hairline adjustment|segmentation|mask" BeautySDK/Sources/BeautyEffects BeautySDK/Sources/BeautyRender BeautySDK/Sources/BeautyResources` | No active implementation matches; existing coordinate/texture terms may need narrower exclusions. [VERIFIED: current negative scan] |
| Future renderer cases | `! rg -n "skinRepair|repair|teeth|hairline|blemish|pore" BeautySDK/Sources/BeautyExampleRenderer/main.swift` | No future-branch renderer cases. [VERIFIED: current renderer grep] |
| Resource ownership promotion | `! rg -n "skinRepair|teeth|hairline|segmentation|mask" BeautySDK/Sources/BeautyResources` | No resource manifests or resource ownership for future skin branches. [VERIFIED: current negative scan] |
| AI/upload/network dependency | `! rg -n "URLSession|http://|https://|upload|cloud|AI|segmentation" BeautySDK/Sources/BeautyEffects BeautySDK/Sources/BeautySDK BeautySDK/Sources/BeautyExampleRenderer` | No network/cloud/AI implementation for Phase 18 skin retouch. [VERIFIED: security contract and current scope] |
| Completion overclaim | `! rg -n "Skin repair.*implemented|Teeth/hairline.*implemented|teeth.*implemented|hairline.*implemented|commercial-grade|release-like|production naturalness" docs/meitu-function-blueprint .planning/phases/18-skin-retouch-core-modules .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md PLANS.md` | No future-branch or release-like completion claims. [VERIFIED: `18-CONTEXT.md`] |
| Facade-only renderer | `! rg -n "import Beauty(Core|Detection|Effects|Render|Resources)|import SwiftUI|import UIKit" BeautySDK/Sources/BeautyExampleRenderer` | Renderer remains public-facade-only and UI-free. [VERIFIED: current import scan] |

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Swift CLI | XCTest and SwiftPM renderer build/run | yes | Apple Swift 6.3.3 | None needed. [VERIFIED: environment probe] |
| Xcode toolchain | `DEVELOPER_DIR` SwiftPM build/run and simulator-oriented guidance | yes | Xcode 26.6 build 17F113 | Record local failure if toolchain configuration changes. [VERIFIED: environment probe, AGENTS.md] |
| `file` CLI | Output dimension checks | yes | file-5.41 | `sips -g pixelWidth -g pixelHeight` can supplement, but docs use `file`. [VERIFIED: environment probe, docs] |
| `sips` CLI | Optional image dimension/manual support on macOS | yes | sips-316 | Use `file` as primary because it is documented. [VERIFIED: environment probe] |
| `rg` CLI | Source/doc negative scans | yes | available through successful commands | Use `grep` only if `rg` unavailable. [VERIFIED: successful commands, AGENTS.md] |

**Missing dependencies with no fallback:** none found. [VERIFIED: environment probe]
**Missing dependencies with fallback:** none found. [VERIFIED: environment probe]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | SwiftPM XCTest plus shell renderer validation. [VERIFIED: `Package.swift`, existing tests] |
| Config file | `BeautySDK/Package.swift`. [VERIFIED: codebase grep] |
| Quick run command | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectResolverTests` [VERIFIED: existing test target names] |
| Focused skin suite command | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectsTests` [VERIFIED: existing test target names] |
| Renderer build command | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer` [CITED: `EXAMPLE_IMAGE_VALIDATION.md`] |
| Renderer run command | Run all Phase 18 skin cases individually with `--case skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, and `skinCombo_0p50`. [VERIFIED: `18-CONTEXT.md`, renderer source] |
| Full optional suite | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK` is optional extra evidence, not a fixed Phase 18 gate. [VERIFIED: `18-CONTEXT.md`] |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| SKIN-01 | Branch docs and module ownership distinguish Basic skin from future Skin repair and Teeth/hairline. | static/docs | `rg -n "Basic skin|Skin repair|Teeth/hairline|implemented|future|BeautyEffects|skinSmoothing" docs/meitu-function-blueprint/features/skin-retouch docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/MODULES.md` | yes |
| SKIN-02 | Basic skin caps, resolver warnings/metrics, and public facade output are verified. | unit/integration | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter BeautyEffectResolverTests` | yes |
| SKIN-02 | Basic skin formula changes have focused pixel/image regression coverage. | unit | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --package-path BeautySDK --filter SkinBasicEffectTests` | no, Wave 0 gap |
| SKIN-02 | Renderer saves visible Basic skin outputs for all current skin cases. | runtime/shell/manual | `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer` plus five `swift run ... --case ...` commands | yes |
| SKIN-02 | Same-dimension representative output checks pass. | shell | `file example-images/input/e2.png example-images/out/e2__skinSmoothing_0p50.png example-images/out/e2__skinWhitening_0p50.png example-images/out/e2__skinRosy_0p40.png example-images/out/e2__skinSharpen_0p40.png example-images/out/e2__skinCombo_0p50.png` | output generated at execution |
| SKIN-03 | Future repair and region-based capabilities remain absent from SDK public API, renderer cases, resources, and completion claims. | static/code/docs | Run the negative scans in this research section. | yes |

### Sampling Rate

- **Per task commit:** Run the narrowest affected XCTest filter plus relevant `rg` scan. [VERIFIED: GSD validation pattern]
- **Per wave merge:** Run all Phase 18 focused tests planned for that wave and `git diff --check` on touched files. [VERIFIED: GSD validation pattern]
- **Phase gate:** Focused XCTest, renderer build, all five skin renderer cases, dimension checks, factual visual review, facade/import scans, future-branch negative scans, and `git diff --check` must pass before `$gsd-verify-work`. [VERIFIED: `18-CONTEXT.md`]

### Wave 0 Gaps

- [ ] `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift` - focused formula regression coverage for Basic skin medium strengths and no-op preservation. [VERIFIED: no existing file in test listing]
- [ ] Optional helper reuse or local helper for `CIImage` RGBA bytes if new tests avoid duplicating fixture code. [VERIFIED: helper patterns exist in `BeautyEngineTests.swift` and `CombinedEffectSafetyTests.swift`]
- [ ] Plan-specific scan commands must be written with allowlists for docs and Demo-disabled taxonomy so negative scans do not fail on intentional future documentation. [VERIFIED: current negative scan output]

### Manual-Only Verification

| Behavior | Requirement | Why Manual | Instructions |
|----------|-------------|------------|--------------|
| Factual visual observations for renderer PNGs | SKIN-02 | Shell checks can prove existence/dimensions but cannot judge watermark readability or visible natural change. | Open generated `example-images/out/e2__*.png` skin outputs and record only factual observations allowed by D-16. [VERIFIED: `18-CONTEXT.md`] |

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no | Phase 18 has no account/auth surface. [VERIFIED: `.planning/ROADMAP.md`, `SECURITY.md`] |
| V3 Session Management | no | Phase 18 has no session surface. [VERIFIED: `.planning/ROADMAP.md`] |
| V4 Access Control | no | Phase 18 does not add server/user permissions. [VERIFIED: `.planning/ROADMAP.md`] |
| V5 Input Validation | yes | Keep `BeautyParameters` clamping, resource validation, and image/pixel validation before rendering. [VERIFIED: `SECURITY.md`, `BeautyParameters.swift`, `BeautyEngine.swift`] |
| V6 Cryptography | no | Phase 18 does not add storage, upload, or cryptographic resource verification. [VERIFIED: `.planning/ROADMAP.md`, `18-CONTEXT.md`] |
| V7 Error Handling and Logging | yes | Warnings/metrics must be redacted and result-scoped. [VERIFIED: `SECURITY.md`, `RELIABILITY.md`, `18-CONTEXT.md`] |
| V10 Malicious Code | yes, static scope | Do not add network/cloud/AI/upload or external package execution. [VERIFIED: `SECURITY.md`, `18-CONTEXT.md`] |

### Known Threat Patterns for Phase 18

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Raw image/face data leaks in warnings or metrics | Information Disclosure | Keep warnings/metrics redacted; scan for paths, landmarks, bounding boxes, raw framework objects, and image bytes. [VERIFIED: `SECURITY.md`, tests] |
| Future branch accidentally introduces segmentation or masks | Information Disclosure / Tampering | Keep Skin repair and Teeth/hairline future; negative-scan SDK sources and renderer cases. [VERIFIED: `18-CONTEXT.md`] |
| Public parameter expansion without contract update | Tampering / Design Drift | Do not add fields to `BeautyParameters`; if ever needed, update root contracts first. [VERIFIED: `DESIGN.md`, `18-CONTEXT.md`] |
| Overclaiming visual quality | Repudiation / Integrity | Restrict evidence language to factual observations and saved-output checks. [VERIFIED: `18-CONTEXT.md`] |

## Assumptions Log

All implementation-planning claims in this research are grounded in repo files, command output, or existing phase context. No `[ASSUMED]` claims are intentionally introduced. [VERIFIED: research commands]

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| — | No assumed claims. | — | — |

## Open Questions

1. **Exact Basic skin formula constants**
   - What we know: Phase 18 permits formula improvements and requires conservative medium strengths. [VERIFIED: `18-CONTEXT.md`]
   - What's unclear: Exact coefficients are intentionally left to executor/planner discretion. [VERIFIED: `18-CONTEXT.md`]
   - Recommendation: Planner should require before/after focused tests around chosen constants, not lock constants in research.

2. **Dedicated formula test file name**
   - What we know: Existing tests cover related resolver/engine behavior, but no `SkinBasicEffectTests.swift` exists. [VERIFIED: test listing]
   - What's unclear: Planner may choose the exact filename. [VERIFIED: `18-CONTEXT.md` discretion]
   - Recommendation: Use `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift` unless the planner prefers extending an existing effects test file.

3. **Visual observation workflow**
   - What we know: Phase 18 requires factual visual inspection and forbids release-like quality claims. [VERIFIED: `18-CONTEXT.md`]
   - What's unclear: Whether execution will record observations in plan summaries only or a verification artifact too. [VERIFIED: no Phase 18 plans yet]
   - Recommendation: Require observations in `18-03-SUMMARY.md` or `18-VERIFICATION.md`, with exact generated filenames.

## Sources

### Primary (HIGH confidence)

- `AGENTS.md` - project routing, verification, and record rules.
- `PLANS.md` - current active Phase 18 planning state and prior Phase 16/17 closeout evidence.
- `.planning/phases/18-skin-retouch-core-modules/18-CONTEXT.md` - locked Phase 18 decisions D-01 through D-17.
- `.planning/REQUIREMENTS.md` - SKIN-01, SKIN-02, SKIN-03 definitions and traceability.
- `.planning/ROADMAP.md` - Phase 18 goal, success criteria, and plan slots.
- `.planning/config.json` - `nyquist_validation: true` and `security_enforcement: true`.
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` - root contracts.
- `docs/meitu-function-blueprint/**` - branch docs, evidence ladder, module ownership, and renderer validation rules.
- `BeautySDK/Sources/**` and `BeautySDK/Tests/**` - current implementation and test patterns.

### Secondary (MEDIUM confidence)

- Environment probes for Swift, Xcode, `file`, and `sips` availability. These describe this machine on 2026-06-27. [VERIFIED: command output]

### Tertiary (LOW confidence)

- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all stack elements are existing repo targets or local tool probes. [VERIFIED: `Package.swift`, environment probes]
- Architecture: HIGH - ownership and dependency direction are documented in root contracts and current code. [VERIFIED: `ARCHITECTURE.md`, `MODULES.md`, codebase grep]
- Pitfalls: HIGH - derived from locked Phase 18 context and current code/test shape. [VERIFIED: `18-CONTEXT.md`, codebase grep]
- Validation: HIGH - `nyquist_validation` is enabled and required gates are locked in context. [VERIFIED: `.planning/config.json`, `18-CONTEXT.md`]

**Research date:** 2026-06-27
**Valid until:** 2026-07-27 for this repo state; rerun source/test/doc scans if Phase 18 implementation begins after major SDK changes.
