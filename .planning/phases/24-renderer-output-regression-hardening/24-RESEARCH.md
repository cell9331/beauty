# Phase 24: Renderer Output Regression Hardening - Research

**Researched:** 2026-07-02
**Domain:** SwiftPM renderer QA, public-facade image regression, evidence hardening
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

Source for this entire section: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`. Copied verbatim for downstream planning. [VERIFIED: codebase grep]

### Locked Decisions

## Implementation Decisions

### Renderer Matrix Source
- **D-01:** `BeautyExampleRenderer` code is the primary source of truth for the renderer case matrix. The current case list in `BeautySDK/Sources/BeautyExampleRenderer/main.swift` is canonical; docs, tests, and evidence must mirror and verify it.
- **D-02:** Phase 24 should add or record a focused static inventory check for the current 9 case IDs. The check should catch added, removed, or renamed cases unless docs/evidence are updated intentionally.
- **D-03:** The durable public-facade renderer matrix should live in `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, with Phase 24 command results and regression evidence recorded under `.planning/phases/24-renderer-output-regression-hardening/`.
- **D-04:** Do not add renderer cases by default. The current 9 visible skin/color/filter cases remain the gate. Any added case must be justified as coverage for existing behavior, not new feature scope.

### No-op Tolerance
- **D-05:** The no-op regression check should target facade output before watermarking. Use `BeautyEngine.processResult(image:metadata:parameters:)` with default `BeautyParameters` against fixture images, then compare rendered output before any `BeautyExampleRenderer` watermark is drawn.
- **D-06:** Use exact rendered-pixel equality where the current CIImage no-op path is deterministic. A small fallback tolerance is allowed only if implementation records a specific platform color-management reason and documents the tolerance used.
- **D-07:** Cover all current example fixtures: `example-images/input/e1.png` through `example-images/input/e5.png`.
- **D-08:** Deterministic no-op pixel drift is a hard failure. The only acceptable non-fail path is a documented platform color-management reason plus the explicit fallback tolerance from D-06.

### Visible Output Checks
- **D-09:** For the current 45 generated visible-output PNGs, automatically verify mechanical invariants plus a change signal: output files exist, are non-empty, match input dimensions, and differ from the corresponding input for visible cases.
- **D-10:** Watermark readability should be handled by recorded factual inspection, not OCR or brittle pixel heuristics. Evidence should include representative notes that the bottom watermark is readable and does not cover the face.
- **D-11:** Store visible-output evidence in Phase 24 Markdown only. Generated PNGs stay ignored under `example-images/out/`; do not commit selected PNGs and do not introduce another generated-output location by default.
- **D-12:** Describe visible changes with factual non-quality wording only. Acceptable wording: output differs for the current case, dimensions match, watermark is readable. Forbidden wording: commercial quality, production naturalness, release readiness, all-device parity, or Meitu parity.

### Geometry Status Guard
- **D-13:** Phase 24 should guard geometry-heavy branch status only. Do not implement geometry saved-output, and do not add a geometry probe unless planning finds a narrow static scan is needed.
- **D-14:** Preserve the current strict status model: `3D塑颜` remains `blocked-by-geometry-output`; shaping branches such as `比例`, `脸型`, `眼睛`, `嘴唇`, and `鼻子` remain `partial`; `眉毛` and unpromoted branches remain `future` unless real public-facade output evidence exists.
- **D-15:** A future geometry branch may move to `implemented` only after public facade detection plus geometry rendering produces same-dimension, watermarked saved outputs through `BeautyExampleRenderer`.
- **D-16:** Phase 24 should include static overclaim scans plus explicit non-claim text in evidence/docs so geometry provider/resolver tests are not mistaken for saved-image visual completion.

### the agent's Discretion
The planner may choose exact test/helper names, scan commands, case-inventory assertion shape, image-difference implementation, evidence artifact filenames, and representative images for factual watermark inspection. Keep the phase conservative: no new feature scope, no committed PNGs, no brittle OCR, no quality overclaims, and no geometry implementation.

### Deferred Ideas (OUT OF SCOPE)

## Deferred Ideas

- Geometry saved-image output implementation is deferred until public facade detection plus geometry rendering can produce same-dimension, watermarked outputs through `BeautyExampleRenderer`.
- New renderer cases are deferred unless a later plan justifies them as existing-behavior coverage.
- Commercial visual quality, production naturalness, release readiness, all-device parity, and Meitu parity claims remain outside Phase 24.
- Committed PNG baselines, OCR-based watermark checks, and broader visual-diff infrastructure are deferred to a future explicit visual-regression phase.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| RENDER-01 | `BeautyExampleRenderer` keeps a documented public-facade matrix for all current visible skin/color/filter output cases. [VERIFIED: `.planning/REQUIREMENTS.md`] | Use `BeautySDK/Sources/BeautyExampleRenderer/main.swift` as the canonical case list, assert the current 9 IDs, and mirror the matrix in `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`. [VERIFIED: codebase grep] |
| RENDER-02 | Default/no-op processing has a regression check that verifies near-copy output within the documented tolerance for current fixture images. [VERIFIED: `.planning/REQUIREMENTS.md`] | Add a fixture-level pre-watermark test around `BeautyEngine.processResult(image:metadata:parameters:)` with default `BeautyParameters` and render comparisons using a fixed `CIContext` color-space setup. [VERIFIED: codebase grep] |
| RENDER-03 | Visible-output cases verify non-empty outputs, same dimensions as inputs, readable parameter watermarks, and factual visible changes without claiming commercial visual quality. [VERIFIED: `.planning/REQUIREMENTS.md`] | Run the renderer all-case command, verify 45 ignored PNGs for existence, non-zero size, dimensions, and input/output byte difference, then record representative factual watermark notes in Phase 24 Markdown. [VERIFIED: codebase grep] |
| RENDER-04 | Geometry-heavy branches remain `partial`, `blocked-by-geometry-output`, or `future` unless public facade detection plus geometry rendering produces saved same-dimension, watermarked outputs. [VERIFIED: `.planning/REQUIREMENTS.md`] | Preserve `FEATURE_MATRIX.md` statuses, keep geometry cases out of `BeautyExampleRenderer`, and scan docs/evidence for implemented/quality overclaims. [VERIFIED: codebase grep] |
</phase_requirements>

## Project Constraints (from AGENTS.md)

- Read `AGENTS.md`, `PLANS.md`, task-specific docs, related code/tests, and historical docs in that order before changing files. [VERIFIED: `AGENTS.md`]
- Treat code and tests as higher priority than `PLANS.md`, specialty docs, and historical `docs/` material when conflicts appear. [VERIFIED: `AGENTS.md`]
- Keep changes minimal, preserve existing naming/directories/abstractions, verify with the narrowest meaningful build/test/static check, and record what changed, why, and how it was verified. [VERIFIED: `AGENTS.md`]
- Do not overwrite user changes or expand task scope; extra issues belong in `PLANS.md`. [VERIFIED: `AGENTS.md`]
- Contract changes must update the owning document: architecture in `ARCHITECTURE.md`, design/API in `DESIGN.md`, security in `SECURITY.md`, reliability/error/performance in `RELIABILITY.md`, and public behavior/acceptance in `PRODUCT_SENSE.md`. [VERIFIED: `AGENTS.md`]
- Xcode builds must use explicit available iOS Simulator destinations; if local Xcode configuration blocks a command, record the reproducible failure instead of fabricating verification. [VERIFIED: `AGENTS.md`]

## Summary

Phase 24 is not a new renderer-feature phase; it is an evidence and regression-hardening phase for the current public-facade saved-image path. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] The current executable already imports only `BeautySDK`, owns 9 visible skin/color/filter cases, loads `example-images/input`, calls `BeautyEngine.processResult(image:metadata:parameters:)`, watermarks outputs, and writes `{source}__{case}.png` under `example-images/out`. [VERIFIED: codebase grep]

The planner should preserve the code-owned matrix and add focused checks around it rather than introduce a new manifest or broad visual-diff system. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] The likely implementation surface is one new focused XCTest file under `BeautySDK/Tests/BeautyCoreTests/`, one Phase 24 evidence Markdown artifact, and small doc updates to `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` plus closeout ledgers after evidence exists. [VERIFIED: codebase grep]

The highest-risk boundary is overclaiming: current renderer evidence proves mechanical output for skin/color/filter only, not commercial visual quality, naturalness, device parity, Meitu parity, or geometry saved-output completion. [VERIFIED: `.planning/phases/20-core-module-closeout/20-VERIFICATION.md`; VERIFIED: `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`]

**Primary recommendation:** Add `BeautyRendererOutputRegressionTests` as a focused SwiftPM XCTest gate, create `24-RENDERER-EVIDENCE.md` for command and factual inspection results, update `EXAMPLE_IMAGE_VALIDATION.md` from evidence, and close with static geometry/no-overclaim scans. [VERIFIED: codebase grep]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Renderer case matrix | SDK executable | Docs/evidence | `BeautyExampleRenderer/main.swift` contains the canonical 9 `RenderCase` entries; docs and evidence must mirror code, not replace it. [VERIFIED: codebase grep] |
| No-op fixture regression | SDK test tier | BeautySDK facade | The locked check calls `BeautyEngine.processResult(image:metadata:parameters:)` before renderer watermarking, so XCTest should exercise the public facade directly. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |
| Visible-output invariant gate | CLI/evidence tier | SDK executable | The current renderer command produces ignored PNG artifacts; invariant scripts can validate files without committing baselines. [VERIFIED: `.gitignore`; VERIFIED: `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`] |
| Watermark readability observation | Manual evidence tier | CLI/evidence tier | The user locked factual representative inspection instead of OCR or pixel heuristics. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |
| Geometry status guard | Docs/static-scan tier | SDK executable | `FEATURE_MATRIX.md` owns branch statuses, while `BeautyExampleRenderer` must not add geometry cases in this phase. [VERIFIED: codebase grep] |

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| SwiftPM / XCTest | Swift 6.3.3 in local environment; `swift-tools-version: 6.0` in `BeautySDK/Package.swift` | Build and run SDK tests. | Existing package targets and all current SDK tests use SwiftPM XCTest. [VERIFIED: command output; VERIFIED: `BeautySDK/Package.swift`] |
| `BeautySDK` facade | local package target | Public image-processing API under test. | Renderer and tests should go through `BeautyEngine` and public facade types rather than importing internal targets for Phase 24. [VERIFIED: `BeautySDK/Sources/BeautyExampleRenderer/main.swift`; VERIFIED: `ARCHITECTURE.md`] |
| `BeautyExampleRenderer` | local SwiftPM executable product | Generates current visible-output PNG matrix. | Phase 21 and Phase 20 already use this executable for renderer evidence, and Phase 24 is explicitly about promoting it into a regression gate. [VERIFIED: `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`] |
| CoreImage / ImageIO / AppKit | OS SDK frameworks | Load/render CI images, inspect/write PNGs, and draw watermark. | The current executable imports `AppKit`, `CoreImage`, `Foundation`, `ImageIO`, and `BeautySDK`. [VERIFIED: codebase grep] |

### Supporting

| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| Python 3 | 3.9.6 local environment | Small PNG header/dimension or byte-difference scripts in evidence verification. | Use for shell-side generated-output checks; do not persist generated baselines. [VERIFIED: command output] |
| `sips` | 316 local environment | Optional image dimension checks. | Use as a fallback or human-readable dimension check; Python header parsing is more portable inside scripted verification. [VERIFIED: command output] |
| `rg` | installed in local environment | Static scans for imports, case IDs, geometry cases, and forbidden wording. | Use first for fast source/doc scans per repository workflow. [VERIFIED: command output; VERIFIED: `AGENTS.md`] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Code-owned matrix check | Shared manifest generated for renderer and tests | Reduces duplication but adds implementation churn and contradicts the locked decision that `BeautyExampleRenderer` code is canonical. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |
| Exact or near-copy no-op test | Committed PNG baselines | Baselines are explicitly deferred and generated PNGs remain ignored local artifacts. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`; VERIFIED: `.gitignore`] |
| Factual watermark inspection | OCR or pixel watermark heuristics | OCR and brittle pixel heuristics are explicitly out of scope. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |

**Installation:** No new external packages are recommended. [VERIFIED: codebase grep]

```bash
# No package install step for Phase 24.
```

**Version verification:** Local tool availability was checked during research. [VERIFIED: command output]

```bash
swift --version
xcodebuild -version
python3 --version
sips --version
```

## Package Legitimacy Audit

No external packages should be installed for Phase 24, so the Package Legitimacy Gate is not applicable. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| none | n/a | n/a | n/a | n/a | n/a | No install recommended. [VERIFIED: codebase grep] |

**Packages removed due to slopcheck [SLOP] verdict:** none. [VERIFIED: codebase grep]
**Packages flagged as suspicious [SUS]:** none. [VERIFIED: codebase grep]

## Architecture Patterns

### System Architecture Diagram

```text
example-images/input/e1...e5.png
  -> BeautyExampleRenderer CLI
     -> load CIImage with orientation applied
     -> BeautyEngine.processResult(image:metadata:parameters:)
        -> BeautySDKResources.validate(parameters:)
        -> BeautyEffectResolver.resolve(parameters:)
        -> BeautyColorEffectPipeline.apply(to:plan:)
     -> CIContext renders output
     -> draw bottom watermark with case display name
     -> write ignored example-images/out/{source}__{case}.png
     -> Phase 24 scripts/tests verify matrix, no-op, dimensions, byte difference, and non-claims
```

This data flow matches the current executable path and keeps Phase 24 on the public `BeautySDK` facade. [VERIFIED: codebase grep]

### Recommended Project Structure

```text
BeautySDK/
├── Tests/
│   └── BeautyCoreTests/
│       └── BeautyRendererOutputRegressionTests.swift  # new focused facade/no-op/matrix tests
docs/
└── meitu-function-blueprint/
    └── EXAMPLE_IMAGE_VALIDATION.md                    # durable matrix and rerun rules
.planning/
└── phases/
    └── 24-renderer-output-regression-hardening/
        ├── 24-RENDERER-EVIDENCE.md                    # command output, invariant results, factual notes
        └── 24-RESEARCH.md                             # this file
```

This structure keeps automated checks in SwiftPM, durable renderer contract in existing blueprint docs, and generated-output observations in phase evidence. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`; VERIFIED: codebase grep]

### Pattern 1: Code-Owned Renderer Case Inventory

**What:** Assert the renderer source still contains exactly the 9 locked visible case IDs unless the phase intentionally updates docs/evidence. [VERIFIED: codebase grep]

**When to use:** Run as an XCTest or static scan before claiming `RENDER-01`. [VERIFIED: `.planning/REQUIREMENTS.md`]

**Example:**

```swift
// Source: BeautySDK/Sources/BeautyExampleRenderer/main.swift and Phase 24 CONTEXT.md
let expectedCaseIDs = [
    "skinSmoothing_0p50",
    "skinWhitening_0p50",
    "skinRosy_0p40",
    "skinSharpen_0p40",
    "brightness_plus0p25",
    "contrast_plus0p25",
    "filter_softClean_0p50",
    "filter_warmLight_0p50",
    "skinCombo_0p50"
]
```

The planner can implement this with a source scan in XCTest using `#filePath` to locate the repository root, or with a shell scan recorded in evidence. [VERIFIED: codebase grep]

### Pattern 2: Pre-Watermark No-Op Fixture Regression

**What:** Load each current fixture, run default `BeautyParameters` through `BeautyEngine.processResult(image:metadata:parameters:)`, render both input and output with the same `CIContext`, and compare bytes before watermarking. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

**When to use:** This is the primary automated support for `RENDER-02`. [VERIFIED: `.planning/REQUIREMENTS.md`]

**Example:**

```swift
// Source: BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift
let context = CIContext(options: [
    .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
    .outputColorSpace: CGColorSpaceCreateDeviceRGB()
])
context.render(
    image,
    toBitmap: &bytes,
    rowBytes: width * 4,
    bounds: CGRect(x: 0, y: 0, width: width, height: height),
    format: .RGBA8,
    colorSpace: CGColorSpaceCreateDeviceRGB()
)
```

Existing tests already use rendered-byte equality for no-op image output on a synthetic 1x1 image; Phase 24 should extend that style to `example-images/input/e1.png` through `e5.png`. [VERIFIED: codebase grep]

### Pattern 3: Generated Visible-Output Invariant Script

**What:** After running all renderer cases, verify expected output count, non-empty PNG files, same dimensions as the source fixture, and output bytes differ from input bytes for visible cases. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

**When to use:** This is the mechanical part of `RENDER-03`; factual watermark inspection remains a Markdown note, not automated OCR. [VERIFIED: `.planning/REQUIREMENTS.md`]

**Example:**

```bash
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/out

python3 -c '<assert 5 inputs x 9 cases, non-empty PNGs, same PNG dimensions, input/output byte difference>'
```

Phase 20 already used a Python PNG header scan for all generated output dimensions, and Phase 21 recorded the current 45-output count. [VERIFIED: `.planning/phases/20-core-module-closeout/20-VERIFICATION.md`; VERIFIED: `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`]

### Anti-Patterns to Avoid

- **Moving matrix authority into docs:** The user locked `BeautyExampleRenderer/main.swift` as canonical. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]
- **Testing no-op after watermarking:** Watermark pixels intentionally change output and would pollute no-op tolerance. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]
- **Committing generated PNGs:** `example-images/out/` is gitignored and generated outputs remain local evidence artifacts. [VERIFIED: `.gitignore`; VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]
- **Claiming geometry visual completion from provider/resolver tests:** `FEATURE_MATRIX.md` says geometry provider and resolver tests do not count as visible completion until public-facade saved-image output exists. [VERIFIED: `docs/meitu-function-blueprint/FEATURE_MATRIX.md`]
- **Using quality language in evidence:** Commercial quality, production naturalness, release readiness, all-device parity, and Meitu parity claims are forbidden for Phase 24. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Renderer CLI orchestration | A second renderer or duplicate output writer | Existing `BeautyExampleRenderer` | It already implements input loading, facade processing, watermarking, output naming, and error reporting. [VERIFIED: codebase grep] |
| Public API access for tests | Internal imports into the regression test | `import BeautySDK` | Phase 24 validates public-facade output and must not rely on internal targets for the main gate. [VERIFIED: `ARCHITECTURE.md`; VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |
| Visual quality scoring | Subjective scoring, OCR, or broad image diff baselines | Mechanical invariants plus factual representative notes | The phase is scoped to regression evidence, not commercial visual assessment. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |
| PNG dimension parsing | Custom binary parser inside production code | Test/evidence helper script or `sips` | Output inspection belongs to tests/evidence, not the SDK runtime. [VERIFIED: `AGENTS.md`; VERIFIED: codebase grep] |

**Key insight:** Phase 24 should harden evidence around the existing public-facade renderer path; creating new product/runtime abstractions increases drift risk without satisfying the locked requirements. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

## Common Pitfalls

### Pitfall 1: Comparing Watermarked Output for No-Op

**What goes wrong:** The no-op check fails because the renderer draws a watermark after facade processing. [VERIFIED: codebase grep]

**Why it happens:** `BeautyExampleRenderer` calls `drawWatermark` after `BeautyEngine.processResult`, so generated PNGs are never exact copies. [VERIFIED: codebase grep]

**How to avoid:** Run no-op comparisons directly against `BeautyEngine.processResult(image:metadata:parameters:)` before watermarking. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

**Warning signs:** A no-op regression test reads from `example-images/out/` instead of rendering facade output in-memory. [VERIFIED: codebase grep]

### Pitfall 2: Treating Existing Tiny Fixture Tests as Full Fixture Coverage

**What goes wrong:** `RENDER-02` appears covered, but only synthetic 1x1 or 2x1 images are checked. [VERIFIED: codebase grep]

**Why it happens:** Existing `BeautyEngineTests` and `SkinBasicEffectTests` already have no-op/visible byte patterns, but they do not cover `example-images/input/e1.png` through `e5.png`. [VERIFIED: codebase grep]

**How to avoid:** Add a current-fixture loop that resolves the repo root via `#filePath` and loads the five fixture PNGs. [VERIFIED: codebase grep]

**Warning signs:** No test or evidence command explicitly names all five `e1.png` through `e5.png` fixtures. [VERIFIED: codebase grep]

### Pitfall 3: Overclaiming Geometry Status

**What goes wrong:** Provider/resolver test evidence is described as saved-image visual completion. [VERIFIED: `docs/meitu-function-blueprint/FEATURE_MATRIX.md`]

**Why it happens:** Geometry providers have unit evidence, but the renderer has no geometry cases and current public facade image path has no facade-visible geometry saved-output. [VERIFIED: codebase grep]

**How to avoid:** Preserve strict statuses and run scans for geometry cases or `implemented` overclaims in Phase 24 docs and blueprint files. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

**Warning signs:** Phase 24 evidence uses terms like `implemented` near `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, or `眉毛`. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md]

### Pitfall 4: False Drift From Color Management

**What goes wrong:** A fixture-level no-op equality check fails due to render color-space differences rather than an SDK behavioral regression. [ASSUMED]

**Why it happens:** CIImage loading and rendering can be sensitive to context and color-space options; existing code uses explicit DeviceRGB options in renderer and tests. [VERIFIED: codebase grep]

**How to avoid:** Render input and output with the same `CIContext`, `RGBA8` format, bounds, row bytes, and color space; allow tolerance only with a documented platform color-management reason. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`; VERIFIED: codebase grep]

**Warning signs:** The test uses different `CIContext` settings for input and output or compares encoded PNG bytes instead of rendered pixels. [VERIFIED: codebase grep]

## Code Examples

### Existing Facade No-Op Pattern

```swift
// Source: BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift
let output = try engine.process(image: image, orientation: .up, parameters: .init())

XCTAssertEqual(output.extent, image.extent)
XCTAssertEqual(try PixelBufferFixtures.rgbaBytes(from: output), try PixelBufferFixtures.rgbaBytes(from: image))
```

This should be adapted for five fixture PNGs and `processResult(image:metadata:parameters:)` so metadata and detection summary stay visible to the regression gate. [VERIFIED: codebase grep]

### Existing Visible-Output Pattern

```swift
// Source: BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift
let result = try engine.processResult(
    image: image,
    metadata: BeautyInputMetadata(orientation: .up, source: .photo),
    parameters: parameters
)

XCTAssertEqual(result.output.extent, image.extent)
XCTAssertNotEqual(try PixelBufferFixtures.rgbaBytes(from: result.output), try PixelBufferFixtures.rgbaBytes(from: image))
```

This supports `RENDER-03` at the facade level, but the all-case generated-output gate must also verify actual `BeautyExampleRenderer` PNG files. [VERIFIED: codebase grep]

### Existing Renderer CLI Path

```swift
// Source: BeautySDK/Sources/BeautyExampleRenderer/main.swift
let result = try engine.processResult(
    image: inputImage,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: renderCase.parameters
)
let watermark = watermarkText(for: renderCase, result: result)
let watermarked = try drawWatermark(watermark, on: cgImage)
let outputName = "\(baseName)__\(renderCase.id).png"
```

This is the path to preserve; Phase 24 should test it from the outside instead of rewriting it. [VERIFIED: codebase grep]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Renderer evidence as closeout-only proof | Renderer evidence becomes a repeatable Phase 24 regression gate | Phase 24 scope on 2026-07-02 | Planner should add automated checks, not just rerun commands. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |
| Representative dimension checks | All 45 generated outputs should be checked for dimensions and change signal | Phase 24 decisions | Planner should avoid sampling-only mechanical checks. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |
| Provider/resolver geometry evidence could be misunderstood | Geometry-heavy branches require public facade detection plus geometry rendering saved output before visual completion | Current `FEATURE_MATRIX.md` and Phase 24 decisions | Planner must add static scans and explicit non-claim text. [VERIFIED: `docs/meitu-function-blueprint/FEATURE_MATRIX.md`; VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |

**Deprecated/outdated:**

- Treating `.planning/codebase/*` as current source authority is outdated for v1.4; Phase 21 classifies those maps as stale background. [VERIFIED: `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`]
- Treating renderer skin/color/filter output as geometry saved-image completion is explicitly invalid. [VERIFIED: `docs/meitu-function-blueprint/FEATURE_MATRIX.md`]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | CIImage fixture-level no-op equality may be affected by platform color-management behavior if contexts are not fixed. [ASSUMED] | Common Pitfalls | Planner may choose an overly broad tolerance or misclassify a true regression; mitigate by first trying exact equality with fixed context and documenting any fallback. |

## Open Questions

1. **Does exact rendered-pixel equality pass for all five current PNG fixtures on this local CIImage path?**
   - What we know: Exact no-op equality passes for existing synthetic image tests, and the current CI no-op path returns `image.cropped(to: image.extent)` when there is no visible color output. [VERIFIED: codebase grep]
   - What's unclear: Research did not add or run the new five-fixture no-op test, so fixture-level equality is not yet proven. [VERIFIED: codebase grep]
   - Recommendation: Planner should require a RED/GREEN test that first asserts exact equality; introduce tolerance only if the execution artifact records a specific color-management reason. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| SwiftPM / Swift | SDK tests and renderer build/run | yes | Apple Swift 6.3.3 | None needed. [VERIFIED: command output] |
| Xcode | SDK frameworks and optional Demo/simulator context | yes | Xcode 26.6 build 17F113 | SwiftPM renderer checks do not require Demo xcodebuild. [VERIFIED: command output] |
| Python 3 | PNG invariant helper scripts | yes | 3.9.6 | Use `sips` for dimensions and shell checks for counts if needed. [VERIFIED: command output] |
| `sips` | Optional image dimension inspection | yes | 316 | Python PNG header parser. [VERIFIED: command output] |
| `rg` | Static scans | yes | installed | `grep` only if `rg` is unavailable. [VERIFIED: command output] |

**Missing dependencies with no fallback:** none found for Phase 24. [VERIFIED: command output]

**Missing dependencies with fallback:** none found for Phase 24. [VERIFIED: command output]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | SwiftPM XCTest plus shell/static scans. [VERIFIED: `BeautySDK/Package.swift`; VERIFIED: command output] |
| Config file | `BeautySDK/Package.swift`; `.planning/config.json` has `workflow.nyquist_validation: true`. [VERIFIED: codebase grep] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` after the new file exists. [VERIFIED: codebase grep] |
| Full suite command | `swift test --package-path BeautySDK` plus `swift build --package-path BeautySDK --product BeautyExampleRenderer` and renderer invariant scripts. [VERIFIED: command output; VERIFIED: `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`] |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| RENDER-01 | Current 9 renderer case IDs remain documented and public-facade scoped. [VERIFIED: `.planning/REQUIREMENTS.md`] | unit/static | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests/testRendererCaseInventoryMatchesCurrentPublicFacadeMatrix` plus `rg -n 'id: "' BeautySDK/Sources/BeautyExampleRenderer/main.swift` | no, Wave 0 gap. [VERIFIED: codebase grep] |
| RENDER-02 | Default parameters preserve current fixture images before watermarking within documented tolerance. [VERIFIED: `.planning/REQUIREMENTS.md`] | unit/fixture | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests/testDefaultParametersPreserveCurrentFixturePixelsBeforeWatermark` | no, Wave 0 gap. [VERIFIED: codebase grep] |
| RENDER-03 | All current generated visible-output PNGs exist, are non-empty, same-dimension, differ from input, and have factual watermark observations. [VERIFIED: `.planning/REQUIREMENTS.md`] | CLI/evidence | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` plus Python invariant script and evidence scan | evidence file does not exist yet, Wave 0 gap. [VERIFIED: codebase grep] |
| RENDER-04 | Geometry branches remain partial/blocked/future unless facade geometry saved-output exists. [VERIFIED: `.planning/REQUIREMENTS.md`] | static scan | `rg -n '3D塑颜.*implemented|比例.*implemented|脸型.*implemented|眼睛.*implemented|嘴唇.*implemented|鼻子.*implemented|眉毛.*implemented' docs/meitu-function-blueprint .planning/phases/24-renderer-output-regression-hardening` should return no overclaims | scan not yet recorded, Wave 0 gap. [VERIFIED: codebase grep] |

### Sampling Rate

- **Per task commit:** Run the focused test or scan affected by the task plus `git diff --check` over touched files. [VERIFIED: `PLANS.md`]
- **Per wave merge:** Run `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests`, renderer build, and scoped evidence/overclaim scans. [VERIFIED: codebase grep]
- **Phase gate:** Run full `swift test --package-path BeautySDK`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, all-case renderer run, PNG invariant script, facade-only/geometry scans, no-overclaim scan, and `git diff --check`. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`; VERIFIED: `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`]

### Wave 0 Gaps

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` - covers RENDER-01 and RENDER-02. [VERIFIED: codebase grep]
- [ ] `.planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md` - records RENDER-03 command output, invariant script result, representative watermark notes, and explicit non-claims. [VERIFIED: codebase grep]
- [ ] Focused PNG invariant script or inline command - covers generated-output count, non-empty files, dimensions, and byte difference without committing PNGs. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]
- [ ] Static scan commands for renderer case inventory, geometry-case exclusion, branch-status honesty, and forbidden quality/parity wording. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no | Phase 24 has no auth surface. [VERIFIED: `.planning/REQUIREMENTS.md`] |
| V3 Session Management | no | Phase 24 has no session surface. [VERIFIED: `.planning/REQUIREMENTS.md`] |
| V4 Access Control | no | Phase 24 uses local fixtures and repository files only. [VERIFIED: codebase grep] |
| V5 Input Validation | yes | Validate fixture file existence, finite/non-empty image extents, expected renderer case IDs, output count, output dimensions, and no unknown filter IDs. [VERIFIED: `SECURITY.md`; VERIFIED: codebase grep] |
| V6 Cryptography | no | Phase 24 does not add signing, checksums, secrets, or external resource distribution. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |

### Known Threat Patterns for SwiftPM Renderer Evidence

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Sensitive image/path data leaking into evidence | Information Disclosure | Record relative paths, counts, dimensions, case IDs, warning/metric keys, and factual observations only; do not include image bytes, local absolute paths, face geometry, or raw framework errors. [VERIFIED: `SECURITY.md`; VERIFIED: `RELIABILITY.md`] |
| False capability claims in docs | Repudiation / Information Integrity | Use static no-overclaim scans and explicit non-claim text for quality, naturalness, parity, release readiness, and geometry saved-output status. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`] |
| Resource/path confusion in test helpers | Tampering | Resolve only repository fixtures under `example-images/input` and generated ignored outputs under `example-images/out`; do not load external resource URLs. [VERIFIED: `SECURITY.md`; VERIFIED: codebase grep] |
| Public facade bypass in tests | Elevation of Privilege by test-only coupling | Main Phase 24 regression should import `BeautySDK`, not internal targets, because the requirement is public-facade output. [VERIFIED: `ARCHITECTURE.md`; VERIFIED: `.planning/REQUIREMENTS.md`] |

## Sources

### Primary (HIGH confidence)

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` - current 9-case renderer matrix, facade import, input/output path, watermark, output naming, and CLI behavior. [VERIFIED: codebase grep]
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - public image processing path and default no-op path through resolver/pipeline. [VERIFIED: codebase grep]
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift` - no-visible-output CIImage path returns cropped input, visible color path changes output while preserving extent. [VERIFIED: codebase grep]
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` - existing facade no-op and visible-output byte comparison patterns. [VERIFIED: codebase grep]
- `BeautySDK/Tests/BeautyEffectsTests/SkinBasicEffectTests.swift` - fixed-color-space CIContext rendered-byte patterns and skin/color visible-output assertions. [VERIFIED: codebase grep]
- `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md` - locked Phase 24 implementation decisions. [VERIFIED: codebase grep]
- `.planning/REQUIREMENTS.md` - RENDER-01 through RENDER-04 descriptions and traceability. [VERIFIED: codebase grep]
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - durable renderer matrix and output rules. [VERIFIED: codebase grep]
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` - strict branch status model and geometry saved-output limitation. [VERIFIED: codebase grep]
- `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md` and `.planning/phases/20-core-module-closeout/20-VERIFICATION.md` - prior renderer command evidence and limitations. [VERIFIED: codebase grep]

### Secondary (MEDIUM confidence)

- Local command outputs from this research: `swift --version`, `xcodebuild -version`, `python3 --version`, `sips --version`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, and `swift test --package-path BeautySDK --list-tests`. [VERIFIED: command output]

### Tertiary (LOW confidence)

- The only low-confidence item is the color-management caveat in A1; it is marked `[ASSUMED]` and should be resolved by the Phase 24 no-op fixture test. [ASSUMED]

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH - local package, test framework, tools, and renderer product were verified in source and command output. [VERIFIED: codebase grep; VERIFIED: command output]
- Architecture: HIGH - phase decisions, renderer source, root contracts, and prior evidence all agree on public-facade, code-owned matrix, ignored-output policy, and geometry limitations. [VERIFIED: codebase grep]
- Pitfalls: HIGH for scope/overclaim/no-watermark issues because they are locked in context and source; MEDIUM for exact fixture no-op equality until the new fixture test runs. [VERIFIED: `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`; ASSUMED]

**Research date:** 2026-07-02
**Valid until:** 2026-08-01, or earlier if `BeautyExampleRenderer/main.swift`, `BeautyEngine.swift`, fixture files, or renderer output policy changes. [VERIFIED: codebase grep]
