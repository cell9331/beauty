# Phase 27: Geometry Render Output and Verification Harness - Research

**Researched:** 2026-07-07
**Domain:** SwiftPM iOS/macOS SDK still-image geometry rendering, renderer evidence, and degradation verification [VERIFIED: .planning/ROADMAP.md; VERIFIED: BeautySDK/Package.swift]
**Confidence:** HIGH [VERIFIED: codebase grep; VERIFIED: local command]

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
## Implementation Decisions

### Saved-output Path
- **D-01:** Phase 27 should use a renderer-first hybrid. Add geometry cases to `BeautyExampleRenderer`, add focused tests and helper checks around that path, and create a separate SDK-only verifier only if the existing renderer cannot support a required degradation case.
- **D-02:** Geometry cases should be appended to the existing `BeautyExampleRenderer` matrix. Keep one executable and one ignored output directory, and expand docs/helper checks to include geometry cases.
- **D-03:** Try existing `example-images/input` fixtures with real public-facade detection first. This is the primary proof path because `GEO-03` is about public-facade saved-output evidence.
- **D-04:** If real fixture detection is not reliable enough for all required geometry/degradation cases, keep `BeautyExampleRenderer` real-facade-first and add a narrow fallback verifier only for unstable cases. Do not replace the main renderer proof with SPI-only evidence.

### First Geometry Scope
- **D-05:** Saved-output scope is face-shape first, with only supporting degradation needed to unblock Phase 28. Do not broaden saved-output claims to all geometry domains in Phase 27.
- **D-06:** Add one combined face-shape renderer case using existing `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength` at moderate strengths.
- **D-07:** Do not add lip, eye, nose, or mouth saved-output cases unless required for degradation evidence. Shared route behavior for those domains can remain test/helper evidence in Phase 27.
- **D-08:** Phase 27 is foundation only. Phase 28 still owns per-tool `脸型` saved-output evidence and any `SHAPE_FEATURE_LEDGER.md` implementation-status promotion.

### Evidence Bar
- **D-09:** A Phase 27 saved-output pass means same input/output dimensions, non-identical geometry output, and redacted geometry metrics. Do not require brittle pixel-stable hashes.
- **D-10:** Compare geometry output against a no-geometry baseline, not only against the input image, so geometry-specific output changes cannot be masked by color/filter effects.
- **D-11:** Generated PNGs stay ignored under `example-images/out/`. Record commands, output counts, dimensions, helper results, and representative evidence in Markdown instead of committing PNGs or hashes.
- **D-12:** Evidence documents may include representative factual visual notes only, such as dimensions, watermark readability, and that a geometry case changed output. They must not claim commercial quality, naturalness, device parity, release readiness, or Meitu parity.

### Degradation Matrix
- **D-13:** Phase 27 must cover no-face, missing-landmark, stale/reused, and combined-strength degradation paths for `GEO-04`.
- **D-14:** Produce renderer PNG evidence for the happy path and no-face path. Missing-landmark, stale/reused, and combined-strength degradation may use focused XCTest plus helper/evidence Markdown summaries rather than PNGs for every path.
- **D-15:** For no-face saved-output evidence, use a dedicated no-face fixture or the narrow fallback verifier. Do not depend on current portrait fixtures naturally producing no-face behavior.
- **D-16:** Missing-landmark, stale/reused, and combined-strength evidence should include focused XCTest plus helper/evidence summaries that assert redacted metrics/warnings and record exact cases.
- **D-17:** Degradation evidence must forbid raw geometry leakage and overclaim wording: no coordinates, landmarks, bounding boxes, control points, raw Vision/framework errors, local paths, image bytes, quality claims, parity claims, or release-readiness claims.

### the agent's Discretion
The planner may choose exact geometry case IDs, moderate strengths, helper filenames, test filenames, command shapes, evidence document names, and whether the fallback verifier is needed. Keep the fallback verifier narrow and explicitly labeled as fallback evidence. Preserve the public-facade renderer as the primary proof path.

### Deferred Ideas (OUT OF SCOPE)
- Per-tool `脸型` saved-output evidence and `SHAPE_FEATURE_LEDGER.md` implementation-status promotion belong to Phase 28.
- Eye, nose, mouth, and lip saved-output cases remain out of Phase 27 unless needed for degradation evidence.
- A separate SDK-only verifier is not a first-class parallel path; it is allowed only as a narrow fallback if the real-facade renderer cannot cover a required degradation case reliably.
- Committed generated PNG baselines, hash manifests, subjective visual-quality review, commercial readiness, broad device parity, and Meitu parity claims remain out of scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| GEO-03 | Geometry render output preserves input dimensions and produces deterministic saved-output evidence through `BeautyExampleRenderer` or an equivalent SDK-only path. [CITED: .planning/REQUIREMENTS.md] | Extend the public-facade `BeautyExampleRenderer` case matrix, add a geometry-vs-baseline helper, and record ignored PNG evidence under `example-images/out/`. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] |
| GEO-04 | Geometry output verification covers no-face, missing-landmark, stale/reused-landmark, and combined-strength degradation paths. [CITED: .planning/REQUIREMENTS.md] | Reuse Phase 26 facade/degradation seams, add saved no-face evidence through a deterministic fallback when needed, and keep missing/stale/reused/combined-strength checks as focused XCTest plus Markdown evidence. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift; VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift] |
</phase_requirements>

## Summary

Phase 27 should be planned as a renderer/output phase, not as another facade-routing phase. Phase 26 already proved that geometry-triggering still-image parameters run detection, route one selected face into internal geometry planning, and return redacted public summaries/warnings/metrics; Phase 26 explicitly did not add renderer geometry cases or generated PNG evidence. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md]

The main implementation gap is that `BeautyEngine.processResult(image:metadata:parameters:)` resolves a geometry-aware plan, but the still-image render call currently invokes `BeautyColorEffectPipeline.apply(to:image, plan:)` without any selected-face geometry argument or geometry render/proxy path. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift] Plan Phase 27 around adding a package-internal geometry-capable image render entry in `BeautyEffects`, then invoking it from the public `BeautySDK` facade while keeping `BeautyExampleRenderer` facade-only. [VERIFIED: BeautySDK/Package.swift; VERIFIED: ARCHITECTURE.md]

**Primary recommendation:** Add one combined face-shape `BeautyExampleRenderer` case, route selected-face geometry into an internal image render/proxy path, create a Phase 27 output helper that compares geometry output to a no-geometry baseline, and write command-backed evidence without committing generated PNGs. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md; VERIFIED: codebase grep]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Geometry saved-output rendering | SDK facade + BeautyEffects render tier [VERIFIED: ARCHITECTURE.md] | BeautyExampleRenderer executable [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | Public callers enter through `BeautyEngine.processResult`, but the geometry-aware pixel/image transformation belongs inside SDK effects/render internals. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift; VERIFIED: ARCHITECTURE.md] |
| Renderer evidence generation | SwiftPM executable tier [VERIFIED: BeautySDK/Package.swift] | Python helper + Markdown evidence [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] | `BeautyExampleRenderer` already imports only `BeautySDK`, enumerates fixtures, writes watermarked PNGs, and keeps outputs under ignored `example-images/out/`. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: git check-ignore command] |
| Degradation simulation | SDK XCTest tier [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift] | Narrow fallback verifier if saved no-face evidence cannot be real-facade deterministic [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | Missing-landmark/stale/reused/combined-strength states are already deterministic in focused effects tests; saved no-face output needs either a dedicated no-face input or the SPI fixture seam. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift; VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift] |
| Raw-geometry privacy | SDK public/SPI boundary [VERIFIED: SECURITY.md] | Static scans and redaction tests [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] | Public and SPI evidence must expose only summaries, warning codes/messages, and aggregate metrics, not coordinates or geometry payloads. [CITED: SECURITY.md; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift] |
| Ledger/status closeout | Planning/docs tier [VERIFIED: .planning/ROADMAP.md] | Phase 28 [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | Phase 27 can update renderer/evidence docs after commands pass, but it must not promote per-tool `脸型` rows to `implemented`. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] |

## Project Constraints (from AGENTS.md)

- Read `AGENTS.md`, `PLANS.md`, task-specific root docs, related code/tests, and relevant `docs/` history before edits. [CITED: AGENTS.md]
- Conflict priority is code/tests, then `PLANS.md`, then specialty docs, then historical `docs/`. [CITED: AGENTS.md]
- Do not expand scope; extra issues go to `PLANS.md`. [CITED: AGENTS.md]
- Do not overwrite local changes the user did not request. [CITED: AGENTS.md]
- Public behavior changes require `PRODUCT_SENSE.md` acceptance updates. [CITED: AGENTS.md]
- Architecture boundary changes require `ARCHITECTURE.md` invariant updates. [CITED: AGENTS.md]
- Risk boundary changes require `SECURITY.md` updates. [CITED: AGENTS.md]
- Performance, logging, or error-handling changes require `RELIABILITY.md` updates. [CITED: AGENTS.md]
- Xcode builds must specify an available iOS Simulator destination; if local Xcode configuration fails, record the exact failure instead of claiming success. [CITED: AGENTS.md]
- Current worktree already has unrelated documentation/planning changes, so Phase 27 plans should scope commits to Phase 27 files and touched SDK/doc files only. [VERIFIED: git status --short]

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| SwiftPM local package `BeautySDK` | `swift-tools-version: 6.0`; local Swift 6.3.3 [VERIFIED: BeautySDK/Package.swift; VERIFIED: local command] | Build SDK targets, executable, and XCTest suites. [VERIFIED: BeautySDK/Package.swift] | The repo already defines all SDK modules, tests, and `BeautyExampleRenderer` in one Swift package. [VERIFIED: BeautySDK/Package.swift] |
| XCTest via SwiftPM | Existing test targets under `BeautySDK/Tests` [VERIFIED: swift test --list-tests; VERIFIED: BeautySDK/Package.swift] | Focused facade/effects/render regression tests. [VERIFIED: BeautySDK/Tests] | Existing Phase 24 and Phase 26 evidence used focused SwiftPM XCTest filters plus full `swift test --package-path BeautySDK`. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md; VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] |
| `BeautyExampleRenderer` executable | Local SwiftPM product [VERIFIED: BeautySDK/Package.swift] | Public-facade saved PNG evidence. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | It already imports only `BeautySDK`, reads `example-images/input`, calls `BeautyEngine.processResult`, watermarks, and writes PNGs. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] |
| CoreImage / ImageIO / AppKit | Apple frameworks imported by renderer/tests [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] | Load/render `CIImage`, encode PNGs, and draw watermarks in the macOS example executable. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | Existing renderer evidence already uses these frameworks without third-party dependencies. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| Python 3 standard library | Python 3.9.6 [VERIFIED: local command] | PNG IHDR dimension checks and output inventory helpers. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] | Use for Phase 27 geometry output helper to avoid adding external packages. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py; CITED: SECURITY.md] |
| `rg` | Available through shell usage [VERIFIED: command output] | Static scans for imports, raw geometry leaks, overclaim wording, and status drift. [VERIFIED: AGENTS.md; VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] | Run after SDK/doc changes and before closeout evidence. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] |
| `git check-ignore` | Git CLI [VERIFIED: local command] | Prove generated PNG outputs remain ignored. [VERIFIED: git check-ignore command] | Run after adding geometry output filenames under `example-images/out/`. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| `xcodebuild -list` | Xcode 26.6 [VERIFIED: local command] | Confirm Demo project schemes if any Demo-adjacent verification is needed. [VERIFIED: xcodebuild -list command] | Phase 27 should generally not need Demo builds because no Demo UI work is scoped. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Public-facade `BeautyExampleRenderer` primary proof [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | SPI-only renderer/verifier | SPI can deterministically simulate no-face or stale states, but it cannot replace the primary GEO-03 public-facade evidence. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| Geometry-vs-no-geometry baseline helper [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | Compare geometry PNG only against input | Input comparison can be masked by unrelated color/filter effects, so Phase 27 must compare against a no-geometry baseline. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| Ignored generated PNGs + Markdown evidence [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | Committed PNG baselines or hash manifests | Baselines/hashes are explicitly out of scope and brittle across renderer/color-management changes. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| Focused XCTest for missing/stale/reused/combined degradation [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift] | Saved PNG for every degradation state | The context allows missing-landmark, stale/reused, and combined-strength degradation to be XCTest plus Markdown rather than PNG for every path. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |

**Installation:**

```bash
# No external package install is required for Phase 27.
# Use local SwiftPM, Xcode, Python 3 standard library, rg, and git.
```

**Version verification:** Swift 6.3.3, Xcode 26.6, Python 3.9.6, and Node 26.0.0 are available locally; `BeautySDK/Package.swift` declares Swift tools 6.0 and local targets only. [VERIFIED: local command; VERIFIED: BeautySDK/Package.swift]

## Package Legitimacy Audit

Phase 27 should not install external packages. [VERIFIED: BeautySDK/Package.swift; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| None | — | — | — | — | Not run | Approved: no external package install is recommended. [VERIFIED: BeautySDK/Package.swift] |

**Packages removed due to slopcheck [SLOP] verdict:** none. [VERIFIED: BeautySDK/Package.swift]
**Packages flagged as suspicious [SUS]:** none. [VERIFIED: BeautySDK/Package.swift]

## Architecture Patterns

### System Architecture Diagram

```text
example-images/input/*.png
  -> BeautyExampleRenderer (public-facade executable)
  -> BeautyEngine.processResult(image:metadata:parameters:)
  -> validate input + parameters
  -> decision: parameters require geometry?
       no -> BeautyEffectResolver.resolve(parameters:)
          -> no-geometry baseline image
       yes -> VisionFaceDetector.detect(...)
          -> decision: selected usable face?
               yes -> BeautyEffectResolver.resolve(parameters:selectedFaceObservation:)
                    -> package-internal geometry-capable image render/proxy
                    -> same-dimension geometry CIImage
               no -> degradation plan with redacted summary/warnings/metrics
                    -> safe output image for no-face evidence
  -> renderer watermark + ignored PNG under example-images/out/
  -> Phase 27 helper
       -> assert expected files exist, non-empty, same dimensions
       -> assert geometry output differs from no-geometry baseline
       -> assert evidence text avoids raw geometry and overclaim terms
```

This flow follows the existing public-facade renderer pattern and inserts geometry rendering inside SDK internals rather than in the executable. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift; CITED: ARCHITECTURE.md]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/
│   ├── BeautySDK/
│   │   ├── BeautyEngine.swift                       # call geometry-capable image render route
│   │   └── BeautyEngineGeometryDetection.swift      # carry selected-face route metadata if needed
│   ├── BeautyEffects/
│   │   └── Render/
│   │       ├── BeautyColorEffectPipeline.swift      # package geometry-aware image entry
│   │       └── BeautyGeometryEffectPipeline.swift   # reuse/extend MVP geometry proxy
│   └── BeautyExampleRenderer/
│       └── main.swift                               # append one combined face-shape case
└── Tests/
    ├── BeautyCoreTests/
    │   ├── BeautyEngineGeometryFacadeTests.swift
    │   └── BeautyRendererOutputRegressionTests.swift
    └── BeautyEffectsTests/
        └── MissingLandmarkDegradationTests.swift

.planning/phases/27-geometry-render-output-and-verification-harness/
├── check_geometry_renderer_outputs.py               # new helper; no external deps
├── 27-GEOMETRY-RENDERER-EVIDENCE.md                 # command-backed evidence
└── 27-RESEARCH.md
```

These files are the likely implementation surface because they already own facade routing, geometry planning, renderer output, degradation tests, and Phase 24 helper evidence. [VERIFIED: codebase grep]

### Pattern 1: Public-Facade Renderer Case Matrix

**What:** Keep `BeautyExampleRenderer` as the code-owned list of saved-output cases and add exactly one combined face-shape case. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

**When to use:** Use for GEO-03 happy-path saved PNG evidence and for the primary real-facade geometry proof. [CITED: .planning/REQUIREMENTS.md]

**Example:**

```swift
// Source: BeautySDK/Sources/BeautyExampleRenderer/main.swift [VERIFIED: codebase]
RenderCase(
    id: "faceShapeCombo_0p35",
    displayName: "face shape combo 0.35",
    parameters: BeautyParameters(
        faceSlim: 0.35,
        faceSmall: 0.30,
        faceVShape: 0.35,
        jawSlim: 0.30,
        chinLength: 0.20
    )
)
```

### Pattern 2: Package-Internal Geometry Render Entry

**What:** Add a package-visible `BeautyEffects` render entry that accepts `BeautyFaceObservation?`, adapts it inside `BeautyEffects`, and applies the internal image geometry render/proxy without exposing `FaceGeometry`. [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift]

**When to use:** Use from `BeautyEngine.processResult(image:metadata:parameters:)` after `resolveStillImageGeometry(...)` selects a face. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift; VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift]

**Example:**

```swift
// Source pattern: BeautyEffectResolver.resolve(parameters:selectedFaceObservation:) [VERIFIED: codebase]
package static func apply(
    to image: CIImage,
    plan: BeautyEffectPlan,
    selectedFaceObservation: BeautyFaceObservation?
) -> CIImage {
    let face = selectedFaceObservation.map(BeautyFaceGeometryAdapter.makeGeometry(from:))
    return apply(to: image, plan: plan, face: face)
}
```

### Pattern 3: Output Helper Compares Geometry Against Baseline

**What:** Mirror Phase 24's standard-library PNG helper but add a geometry-vs-baseline check. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

**When to use:** Run after the all-case renderer command, and fail if geometry output is missing, zero-byte, dimension-mismatched, byte-identical to the baseline, or prints sensitive data. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py; CITED: SECURITY.md]

**Example:**

```python
# Source pattern: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py [VERIFIED: codebase]
geometry = output_dir / f"{fixture_stem}__faceShapeCombo_0p35.png"
baseline = output_dir / f"{fixture_stem}__geometryBaseline_noop.png"
if read_png_dimensions(geometry, geometry.name) != read_png_dimensions(input_png, input_png.name):
    failures.append(f"{geometry.name}: dimension mismatch")
if geometry.read_bytes() == baseline.read_bytes():
    failures.append(f"{geometry.name}: byte-identical to no-geometry baseline")
```

### Anti-Patterns to Avoid

- **Renderer owns geometry internals:** Do not import `BeautyDetection`, `BeautyEffects`, `BeautyRender`, or raw geometry types in `BeautyExampleRenderer`; existing tests guard public-facade-only imports. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]
- **Provider-only completion claim:** Do not mark geometry branches or `脸型` tools implemented from resolver/provider evidence alone. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md]
- **Hash-baseline evidence:** Do not require committed hashes or PNG baselines; Phase 27 evidence is command-backed dimensions, existence, and non-identity against a baseline. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]
- **Quality/parity wording:** Do not claim naturalness, commercial quality, device parity, release readiness, or Meitu parity. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Test runner | Custom test harness | SwiftPM XCTest [VERIFIED: BeautySDK/Package.swift] | Existing SDK tests, filters, and phase evidence already use XCTest. [VERIFIED: swift test --list-tests] |
| PNG dimension parser | Image-processing dependency | Existing Python standard-library IHDR parser pattern [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] | Phase 24 helper already verifies PNG dimensions without external packages. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] |
| Face detection fixtures | Ad hoc public debug API | Existing SPI `SDKTestingFaceDetectionProvider` [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift] | It gives deterministic usable/no-face/low-confidence/missing/failure states without public raw geometry exports. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift] |
| Geometry planning | New public geometry API | `BeautyEffectResolver.resolve(parameters:selectedFaceObservation:)` and internal `BeautyFaceGeometryAdapter` [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift] | Existing package-only routing already preserves redaction and group-specific degradation. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] |
| Visual quality judgment | Subjective review in Phase 27 | Mechanical output checks plus factual notes [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | Phase 27 is foundation evidence, not commercial or release-like visual QA. [CITED: .planning/ROADMAP.md] |

**Key insight:** The hard part is not detecting geometry intent anymore; it is turning the internal selected-face route into deterministic, same-dimension image output while preserving the public privacy boundary. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md; VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift]

## Common Pitfalls

### Pitfall 1: Geometry Plan Exists But Output Is Still Color-Only

**What goes wrong:** Tests pass because `geometryPointCount` is present, but saved images do not change for geometry because the still-image pipeline does not consume selected-face geometry. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift]

**Why it happens:** Phase 26 returns a geometry-aware `BeautyEffectPlan`, but `BeautyColorEffectPipeline.apply(to:image, plan:)` has no face argument in the public facade call. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift]

**How to avoid:** Add a package-internal geometry-aware image render entry and a test that compares geometry output against a no-geometry baseline. [VERIFIED: BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

**Warning signs:** `beauty.effects.geometryPointCount` is positive but generated geometry PNGs are byte-identical to baseline outputs. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift; VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py]

### Pitfall 2: Treating Real Vision Fixture Detection As Deterministic Without Proof

**What goes wrong:** Planner assumes current portrait fixtures always produce usable faces or no-face states. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

**Why it happens:** `VisionFaceDetector.defaultObservationProvider` currently instantiates a Vision request and throws `detectorUnavailable`; deterministic tests rely on an injected provider. [VERIFIED: BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift; VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift]

**How to avoid:** Include an execution checkpoint that records real renderer detection summaries; use the narrow fallback verifier for no-face if real-facade fixtures cannot deterministically cover it. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift]

**Warning signs:** Renderer output evidence has `.skipped` or `.notRun` summaries for geometry cases, or no no-face saved-output path can be reproduced. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift]

### Pitfall 3: Raw Geometry Leakage In Helpful Evidence

**What goes wrong:** Evidence prints coordinates, `SIMD`, landmarks, bounding boxes, raw Vision names, paths, or raw framework errors. [CITED: SECURITY.md]

**Why it happens:** Geometry debugging is tempting during output verification, but Phase 27 evidence is restricted to summaries, reason codes, counts, warning codes, and aggregate metrics. [CITED: SECURITY.md; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

**How to avoid:** Reuse Phase 26 redaction assertions and static scans over SDK public/Core surfaces, renderer source, tests, and evidence docs. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md]

**Warning signs:** Evidence includes terms such as `VNFaceObservation`, `boundingBox`, `controlPoint`, `SIMD`, `/private/var`, `NSError`, `raw JSON`, or `image bytes`. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift]

### Pitfall 4: Advancing Face-Shape Ledger Status Too Early

**What goes wrong:** Phase 27 saved-output foundation is mistaken for per-tool `脸型` completion. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md]

**Why it happens:** The combined face-shape case covers several existing parameters, but Phase 28 owns per-tool evidence and `SHAPE_FEATURE_LEDGER.md` promotion. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

**How to avoid:** Keep Phase 27 docs limited to foundation evidence and run a ledger implemented-status guard. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md]

**Warning signs:** `SHAPE_FEATURE_LEDGER.md` or face-shape README rows change to `implemented` during Phase 27. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

## Code Examples

Verified patterns from official or project sources:

### Existing Public-Facade Renderer Loop

```swift
// Source: BeautySDK/Sources/BeautyExampleRenderer/main.swift [VERIFIED: codebase]
let result = try engine.processResult(
    image: inputImage,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: renderCase.parameters
)
```

### Existing Deterministic Facade Fixture Seam

```swift
// Source: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift [VERIFIED: codebase]
let provider = SDKTestingFaceDetectionProvider([.usableFace])
let engine = try BeautyEngine(faceDetectionProvider: provider)
```

### Existing Degradation Redaction Pattern

```swift
// Source: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift [VERIFIED: codebase]
for forbidden in [
    "VNFaceObservation",
    "boundingBox",
    "controlPoint",
    "/private/var",
    "NSError",
    "AVError",
    "rawPresetJson",
    "raw JSON",
    "image bytes",
    "landmarks=",
    "landmarkCoordinates",
    "rawLandmark",
    "SIMD"
] {
    XCTAssertFalse(metadata.contains(forbidden))
}
```

### Existing PNG Helper Pattern

```python
# Source: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py [VERIFIED: codebase]
if output_dimensions != fixture_dimensions:
    failures.append(f"{output_label}: dimensions mismatch")
if output_bytes == fixture_bytes:
    failures.append(f"{output_label}: byte-identical to {fixture_name}")
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Provider/resolver-only geometry evidence | Public still-image facade can trigger detection and route selected-face geometry planning, but saved-output geometry remains pending. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] | Phase 26, completed 2026-07-06 [VERIFIED: .planning/STATE.md] | Phase 27 can focus on render output rather than detection activation. [VERIFIED: .planning/ROADMAP.md] |
| Renderer cases limited to skin/color/filter | Add one face-shape combined geometry renderer case while keeping generated PNGs ignored. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | Phase 27 planning scope [VERIFIED: .planning/ROADMAP.md] | Geometry output can become mechanical saved-output evidence without per-tool completion claims. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] |
| Input-vs-output byte difference only | Geometry output must differ from a no-geometry baseline. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | Phase 27 locked decision [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | The helper must generate or locate baseline outputs for the same fixture before asserting geometry-specific change. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] |

**Deprecated/outdated:**
- Using `BeautyExampleRenderer` geometry-case exclusion as a pass condition is outdated after Phase 27 starts; Phase 26 used that guard only to preserve Phase 27 ownership. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]
- Provider-only geometry proxy tests remain useful but are not sufficient for GEO-03 saved-output evidence. [CITED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|

**If this table is empty:** All claims in this research were verified or cited in this session; no user confirmation is needed before planning. [VERIFIED: codebase grep; VERIFIED: local command; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

## Open Questions

1. **Will real `example-images/input` fixtures produce usable Vision output in the local renderer path?**  
   What we know: The current public facade tries real detection for geometry-triggering still-image parameters, but the default observation provider throws `detectorUnavailable` in the current source. [VERIFIED: BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift]  
   What's unclear: Whether implementation will replace/refine real still-image Vision extraction in Phase 27 or rely on the narrow fallback verifier for deterministic output. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]  
   Recommendation: Plan an early RED/GREEN checkpoint: run the geometry renderer case and inspect redacted summaries/metrics; if real-facade output cannot produce usable saved geometry, add the narrow fallback verifier only for unstable cases. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

2. **Should no-face saved-output evidence use a new fixture or the fallback verifier?**  
   What we know: `example-images/input/` currently contains `e1.png` through `e5.png` and no dedicated no-face fixture name was found. [VERIFIED: find example-images command]  
   What's unclear: Whether the planner wants to add a committed no-face input fixture or avoid fixture churn by using the SPI fallback verifier. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]  
   Recommendation: Prefer the fallback verifier for no-face saved-output evidence unless implementation deliberately adds and documents a dedicated no-face input fixture. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Swift | SDK build/test and `BeautyExampleRenderer` [VERIFIED: BeautySDK/Package.swift] | yes [VERIFIED: local command] | Apple Swift 6.3.3 [VERIFIED: local command] | None needed. |
| Xcode / xcodebuild | Demo scheme discovery and Apple toolchain [CITED: AGENTS.md] | yes [VERIFIED: local command] | Xcode 26.6 build 17F113 [VERIFIED: local command] | SwiftPM-only verification for SDK if Demo build is out of scope. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| Python 3 | Output helper scripts [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] | yes [VERIFIED: local command] | 3.9.6 [VERIFIED: local command] | Swift XCTest-only checks, but helper evidence would be weaker. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] |
| `rg` | Static scans [CITED: AGENTS.md] | yes [VERIFIED: command usage] | — | `grep`, if unavailable. [CITED: AGENTS.md] |
| Node GSD tools entrypoint | GSD init/graph commands [VERIFIED: local command] | yes [VERIFIED: local command] | Node 26.0.0 [VERIFIED: local command] | Direct file reads; `gsd-tools` is not on shell PATH. [VERIFIED: local command] |
| Project graph | Optional semantic context [CITED: GSD researcher instructions] | no [VERIFIED: find .planning/graphs command] | — | Use direct code/doc grep, which this research did. [VERIFIED: codebase grep] |

**Missing dependencies with no fallback:**
- None found for planning. [VERIFIED: local command]

**Missing dependencies with fallback:**
- `gsd-tools` is not on PATH, but `/Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs` works through `node`. [VERIFIED: local command]
- No `.planning/graphs/graph.json` exists, so graph context was skipped and direct grep/source reads were used. [VERIFIED: find .planning/graphs command]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | SwiftPM XCTest with focused shell/static scans. [VERIFIED: BeautySDK/Package.swift; VERIFIED: swift test --list-tests] |
| Config file | `BeautySDK/Package.swift`; no separate SDK test config was found. [VERIFIED: find command] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` plus changed-surface filters. [VERIFIED: swift test --list-tests] |
| Full suite command | `swift test --package-path BeautySDK`; renderer phase gate also needs `swift build --package-path BeautySDK --product BeautyExampleRenderer`, `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out`, and the Phase 27 helper. [VERIFIED: BeautySDK/Package.swift; VERIFIED: .planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md] |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| GEO-03 | Combined face-shape case exists in `BeautyExampleRenderer` and renderer remains public-facade-only. [CITED: .planning/REQUIREMENTS.md] | unit/static | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests/testRendererCaseInventoryMatchesCurrentPublicFacadeMatrix` after updating expected IDs. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] | yes, needs Phase 27 update. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] |
| GEO-03 | Geometry image output keeps input dimensions and differs from no-geometry baseline. [CITED: .planning/REQUIREMENTS.md] | fixture/integration | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out` plus `python3 .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py --input example-images/input --output example-images/out`. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] | helper does not exist; Wave 0 gap. [VERIFIED: find command] |
| GEO-03 | Still-image facade render path consumes selected-face geometry without exposing raw geometry. [CITED: .planning/REQUIREMENTS.md] | facade unit | Add/update focused test under `BeautyEngineGeometryFacadeTests` or a new geometry output test. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift] | partial; output-delta test needed. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift] |
| GEO-04 | No-face saved-output evidence exists and is redacted. [CITED: .planning/REQUIREMENTS.md] | fallback verifier or fixture integration | Renderer/fallback command plus helper/evidence scan. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] | no dedicated helper yet; Wave 0 gap. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift] |
| GEO-04 | Missing-landmark degradation remains group-specific and redacted. [CITED: .planning/REQUIREMENTS.md] | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testSelectedFaceRoutePreservesGroupSpecificDegradation`. [VERIFIED: swift test --list-tests] | yes. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift] |
| GEO-04 | Stale/reused degradation remains deterministic and redacted. [CITED: .planning/REQUIREMENTS.md] | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests/testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded`. [VERIFIED: swift test --list-tests] | yes. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift] |
| GEO-04 | Combined-strength degradation weakens/caps geometry and records aggregate metrics. [CITED: .planning/REQUIREMENTS.md] | unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests/testCombinedHighStrengthAllDomainsCapAndWeakenGeometry` and `BeautyEffectsTests.GeometryConflictResolverTests/testCombinedHighFaceShapeStrengthsAreWeakenedBelowIndependentCappedSum`. [VERIFIED: swift test --list-tests] | yes. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift; VERIFIED: BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift] |

### Sampling Rate

- **Per task commit:** Run the narrowest touched SwiftPM XCTest filter plus `git diff --check` over touched files. [VERIFIED: PLANS.md; VERIFIED: Phase 24/26 summaries]
- **Per wave merge:** Run `BeautyEngineGeometryFacadeTests`, `BeautyRendererOutputRegressionTests`, `MissingLandmarkDegradationTests`, and any new Phase 27 helper. [VERIFIED: swift test --list-tests; VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py]
- **Phase gate:** Run full `swift test --package-path BeautySDK`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, renderer run, Phase 27 helper, `git check-ignore` for geometry outputs, raw-leak scans, no-overclaim scans, ledger-status guard, and scoped `git diff --check`. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/24-RENDERER-EVIDENCE.md; VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md]

### Wave 0 Gaps

- [ ] `.planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py` — verifies geometry case output count, dimensions, non-empty files, and geometry-vs-baseline differences. [VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py]
- [ ] `BeautyRendererOutputRegressionTests` update — expected case matrix should include the new combined face-shape case. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]
- [ ] Facade/output-delta test — prove selected-face geometry changes rendered image bytes before watermarking. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift]
- [ ] No-face saved-output path — either add a documented no-face input fixture or a narrow fallback verifier using the existing SPI detection provider. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift]

## Security Domain

Security enforcement is enabled in `.planning/config.json`, so Phase 27 planning must include security checks. [VERIFIED: .planning/config.json]

### Applicable ASVS Categories

OWASP ASVS is a verification standard for application security controls, and the GSD template maps security review categories to the phase stack. [CITED: https://owasp.org/www-project-application-security-verification-standard/]

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no [VERIFIED: .planning/ROADMAP.md] | Phase 27 adds no accounts, identity, login, or entitlement behavior. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| V3 Session Management | no [VERIFIED: .planning/ROADMAP.md] | No sessions or tokens are in scope. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| V4 Access Control | no [VERIFIED: .planning/ROADMAP.md] | SDK local renderer has no user roles or protected server resources. [CITED: SECURITY.md] |
| V5 Input Validation | yes [CITED: SECURITY.md] | Keep image extent validation, parameter validation, resource ID validation, and helper path handling conservative. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift; VERIFIED: SECURITY.md] |
| V6 Cryptography | no [VERIFIED: .planning/ROADMAP.md] | No encryption, signing, or secret storage is added in this phase. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| V8 Error Handling and Logging | yes [CITED: RELIABILITY.md] | Evidence, warnings, metrics, and errors must stay redacted and typed/factual. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift; CITED: RELIABILITY.md] |
| V9 Data Protection / Privacy | yes [CITED: SECURITY.md] | Do not persist raw photos, landmarks, bounding boxes, control points, or generated debug textures; generated PNG outputs remain local ignored evidence. [CITED: SECURITY.md; VERIFIED: git check-ignore command] |

### Known Threat Patterns for Swift SDK Renderer Evidence

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Raw face geometry leakage in metrics/evidence | Information Disclosure | Redaction tests and active-source/evidence scans for Vision names, bounding boxes, control points, coordinates, raw paths/errors, JSON, and image bytes. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] |
| Fixture/output path disclosure | Information Disclosure | Helper output should print relative fixture/output names only; renderer errors currently include paths, so evidence docs should avoid copying absolute path failures unless needed as blocker facts. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .planning/phases/24-renderer-output-regression-hardening/check_renderer_outputs.py] |
| Misleading quality/parity claims | Spoofing / Repudiation | No-overclaim scans over Phase 27 evidence and docs for commercial quality, release readiness, device parity, naturalness, and Meitu parity claims. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md] |
| Hidden public API expansion | Tampering | Public/SPI raw geometry export scan and Demo internal-import scan. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] |

## Sources

### Primary (HIGH confidence)
- `AGENTS.md` - repository workflow, routing, verification, and record constraints. [CITED: AGENTS.md]
- `PLANS.md` - active Phase 27 planning ledger and Phase 26 completion evidence. [VERIFIED: PLANS.md]
- `.planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md` - locked Phase 27 decisions and deferred scope. [CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]
- `.planning/REQUIREMENTS.md` - GEO-03/GEO-04 definitions and traceability. [CITED: .planning/REQUIREMENTS.md]
- `.planning/ROADMAP.md` and `.planning/STATE.md` - Phase 27 goal, dependency on Phase 26, and current routing. [VERIFIED: .planning/ROADMAP.md; VERIFIED: .planning/STATE.md]
- `.planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md` and summaries - Phase 26 proof and non-claims. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md]
- Root contracts: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`. [CITED: root docs]
- Current implementation/test files under `BeautySDK/Sources` and `BeautySDK/Tests`. [VERIFIED: codebase grep]
- Local commands: `swift --version`, `xcodebuild -version`, `swift test --list-tests`, `xcodebuild -list`, `git check-ignore`, and file discovery commands. [VERIFIED: local command]

### Secondary (MEDIUM confidence)
- OWASP ASVS project page for security verification framing. [CITED: https://owasp.org/www-project-application-security-verification-standard/]

### Tertiary (LOW confidence)
- None. [VERIFIED: codebase grep]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all recommended tools are already present locally or declared in `BeautySDK/Package.swift`; no external package install is recommended. [VERIFIED: local command; VERIFIED: BeautySDK/Package.swift]
- Architecture: HIGH - current code clearly separates `BeautySDK`, `BeautyEffects`, and `BeautyExampleRenderer`; Phase 26 verification identifies the exact saved-output gap. [VERIFIED: BeautySDK/Package.swift; VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md]
- Pitfalls: HIGH - pitfalls are derived from current code gaps and explicit Phase 27 decisions. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift; CITED: .planning/phases/27-geometry-render-output-and-verification-harness/27-CONTEXT.md]

**Research date:** 2026-07-07
**Valid until:** 2026-08-06 for local codebase patterns, or until Phase 27 implementation changes the renderer/facade path. [VERIFIED: current date; VERIFIED: codebase grep]
