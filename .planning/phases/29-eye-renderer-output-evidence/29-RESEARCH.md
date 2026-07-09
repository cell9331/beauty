# Phase 29: Eye Renderer Output Evidence - Research

**Researched:** 2026-07-09 [VERIFIED: environment_context]  
**Domain:** SwiftPM SDK eye-geometry renderer evidence through the public `BeautySDK` facade, Python output helper validation, ignored generated artifacts, and scoped evidence documentation [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
**Confidence:** HIGH [VERIFIED: codebase grep; VERIFIED: local command]

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
## Implementation Decisions

### Eye Renderer Case Matrix
- **D-01:** Add exactly one public-facade renderer case per existing visible eye behavior needed for Phase 29 evidence. Do not make an eye combo case a Phase 29 requirement.
- **D-02:** Use deterministic moderate-strength case IDs: `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`.
- **D-03:** Require both signed directions for `eyeDistance` and `eyeYPosition`.
- **D-04:** Do not require negative `eyeTailLift` evidence in Phase 29. Current provider behavior treats `eyeTailLift` as positive-only output behavior; signed/cap safety belongs to Phase 30 tests.
- **D-05:** Require one representative no-face eye output presence check, likely `no-face-gradient__eyeSize_0p35.png`, to prove renderer execution and safe degradation without multiplying every eye case by degradation variants.

### Helper Evidence Gate
- **D-06:** The Phase 29 helper should validate the full renderer matrix plus eye-specific checks. Every expected renderer output must exist, be non-empty, and preserve the source fixture dimensions.
- **D-07:** After the full-matrix checks, the helper must compare each Phase 29 eye case against `geometryBaseline_noop` above the watermark band for every usable portrait fixture.
- **D-08:** Required portrait evidence is 6 portrait fixtures x 6 eye cases = 36 eye-vs-baseline top-region comparisons.
- **D-09:** If any required eye-vs-baseline comparison fails, Phase 29 should fail and be fixed before completion. The planner/executor may adjust implementation, strength, or fixture handling, but must not claim Phase 29 complete with missing required comparisons.
- **D-10:** `example-images/output/` is the canonical generated output path for Phase 29 helper/docs. Older docs or commands that still say `example-images/out/` should be updated when touched.

### Output, Gallery, and Documentation Boundary
- **D-11:** Add an `eyes/` gallery group for the new eye cases in `example-images/generate_gallery.py` and docs. Generated gallery files remain ignored under `example-images/gallery/`.
- **D-12:** Phase 29 may update renderer evidence docs only: `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `example-images/README.md`, `QUALITY_SCORE.md`, phase evidence, and planning ledgers. Do not promote `SHAPE_FEATURE_LEDGER.md` eye row statuses in Phase 29.
- **D-13:** Create a dedicated `.planning/phases/29-eye-renderer-output-evidence/29-EYE-RENDERER-EVIDENCE.md` artifact with exact build/run/helper commands, output counts, dimension buckets, 36/36 eye-vs-baseline comparison results, representative no-face output presence, ignored-output checks, and factual limitations.
- **D-14:** Phase 29 status wording should be: public-facade renderer evidence exists for the existing eye parameters, but the `眼睛` rows and branch remain `partial` until Phase 30 safety/degradation/ledger closeout passes.

### the agent's Discretion
The planner may choose the exact helper filename, test method names, evidence-command formatting, scan command shapes, and whether to extend or mirror the Phase 28 helper. Keep choices consistent with the locked case IDs, `example-images/output/` path, full-matrix helper requirement, ignored generated-output policy, public-facade renderer boundary, and no-overclaim rules.

### Deferred Ideas (OUT OF SCOPE)
- Eye combo renderer output is not required for Phase 29 and can be considered later only if a future phase needs combined-eye visual review.
- Status promotion for `大小`, `上下`, `眼距`, and `眼尾上扬` belongs to Phase 30 after safety/degradation/redaction evidence passes.
- Whole-branch `眼睛` completion remains future because eye height, length, pupil/gaze, lid, redness, corners, symmetry, and eye-fat controls still need separate parameter/resource design.
- Demo UI work, new public parameters, commercial quality review, device parity, broad Meitu parity, generated PNG baselines, network/cloud behavior, and launch-readiness claims remain out of scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| EYE-01 | `BeautyExampleRenderer` can generate public-facade saved-output cases for existing public eye parameters without importing internal SDK targets. [CITED: .planning/REQUIREMENTS.md] | The renderer currently imports `BeautySDK` only and defines a 17-case matrix; Phase 29 should append exactly six locked eye `RenderCase` entries and update the renderer inventory test. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| EYE-02 | The eye helper verifies expected outputs, dimensions, non-empty PNGs, and eye-vs-baseline top-region differences on usable portraits. [CITED: .planning/REQUIREMENTS.md] | Phase 28 helper already validates fixture dimensions, generated PNG dimensions, non-empty output files, watermark-excluded top-region comparisons, and no-face output presence; mirror it with Phase 29 constants and 36 expected eye comparisons. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| EYE-03 | Generated eye output and gallery artifacts stay ignored, and no generated PNG baseline is committed. [CITED: .planning/REQUIREMENTS.md] | `.gitignore` already ignores `example-images/output/` and `example-images/gallery/`; Phase 29 should extend gallery grouping with `eyes/`, run `git check-ignore`, and record Markdown evidence rather than PNG baselines. [VERIFIED: .gitignore; VERIFIED: example-images/generate_gallery.py; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
</phase_requirements>

## Summary

Phase 29 should be planned as a public-facade saved-output evidence phase, not as an eye-algorithm, API, Demo, safety-closeout, or status-promotion phase. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] The repository already has the public still-image geometry route, a `BeautyExampleRenderer` executable, six portrait fixtures plus one no-face negative fixture, ignored generated output/gallery directories, and a Phase 28 helper that does the right watermark-excluded top-region comparison. [VERIFIED: ARCHITECTURE.md; VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: example-images/input; VERIFIED: .gitignore; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]

The current renderer matrix has 17 cases and 7 committed fixtures, producing 119 generated PNGs when fully run; adding the six locked eye cases makes the Phase 29 full-matrix expectation 23 cases x 7 fixtures = 161 generated PNGs. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: example-images/input; VERIFIED: local command; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] The eye-specific quality gate is narrower: 6 portrait fixtures x 6 eye cases = 36 top-region comparisons against each fixture's `geometryBaseline_noop`, plus one representative no-face eye output presence check. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

**Primary recommendation:** Add the six locked eye cases to `BeautyExampleRenderer`, update renderer inventory tests and gallery grouping, create a Phase 29-owned helper by mirroring Phase 28's standard-library PNG/JPEG/diff logic, then record command-backed evidence in `29-EYE-RENDERER-EVIDENCE.md` with no ledger promotion and no generated PNG baselines. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift; VERIFIED: example-images/generate_gallery.py]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Existing eye behavior | `BeautyEffects` eye provider and resolver [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift] | `BeautyRender` / geometry pipeline [VERIFIED: ARCHITECTURE.md; VERIFIED: RELIABILITY.md] | Providers/resolver own control intent, caps, active/skipped domain decisions, and internal geometry routing; Phase 29 should not expose raw geometry. [CITED: SECURITY.md; VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift] |
| Saved-output generation | `BeautyExampleRenderer` executable [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | Public `BeautySDK` facade [VERIFIED: BeautySDK/Package.swift] | Renderer imports only `BeautySDK`, calls `BeautyEngine.processResult(image:metadata:parameters:)`, watermarks, and writes flat PNG names. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] |
| Output validation | Phase 29 Python helper [ASSUMED] | Phase 28 helper pattern [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] | The helper should verify full output inventory and then compare eye cases against `geometryBaseline_noop` above the watermark band. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| Generated gallery review | `example-images/generate_gallery.py` [VERIFIED: example-images/generate_gallery.py] | Ignored `example-images/gallery/eyes/` output [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | Gallery grouping is generated from flat renderer outputs and should add an `eyes` group without committing PNGs. [VERIFIED: example-images/generate_gallery.py; VERIFIED: .gitignore] |
| Evidence and limitations | Phase evidence docs and quality/planning ledgers [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | Phase 30 owns ledger promotion [CITED: .planning/ROADMAP.md] | Phase 29 may document renderer evidence but must leave `眼睛` rows and branch partial until Phase 30 safety/degradation/ledger closeout. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] |

## Project Constraints (from AGENTS.md)

- Read `AGENTS.md`, then `PLANS.md`, then task-specific root docs and related code/tests before changing files. [CITED: AGENTS.md]
- Conflict priority is code/tests, then `PLANS.md`, then specialty docs, then historical `docs/`. [CITED: AGENTS.md]
- Do not expand scope; extra issues belong in `PLANS.md`. [CITED: AGENTS.md]
- Do not overwrite local changes the user did not request. [CITED: AGENTS.md]
- New public behavior requires `PRODUCT_SENSE.md` acceptance updates. [CITED: AGENTS.md]
- New architecture boundaries require `ARCHITECTURE.md` updates. [CITED: AGENTS.md]
- New risk boundaries require `SECURITY.md` updates. [CITED: AGENTS.md]
- New performance, logging, or error-handling behavior requires `RELIABILITY.md` updates. [CITED: AGENTS.md]
- Xcode builds should use an explicit available simulator destination, and local Xcode failures must be recorded truthfully. [CITED: AGENTS.md]
- No project-local `.codex/skills` or `.agents/skills` directories were found, so there are no additional repository skill rules to apply. [VERIFIED: local command]

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| SwiftPM local package `BeautySDK` | `swift-tools-version: 6.0`; local Swift 6.3.3 [VERIFIED: BeautySDK/Package.swift; VERIFIED: local command] | Build SDK modules, tests, and `BeautyExampleRenderer`. [VERIFIED: BeautySDK/Package.swift] | The repository already defines all relevant modules, executable product, and XCTest targets in this package. [VERIFIED: BeautySDK/Package.swift] |
| XCTest via SwiftPM | Existing test targets under `BeautySDK/Tests` [VERIFIED: BeautySDK/Package.swift; VERIFIED: local command] | Renderer inventory, facade, provider, resolver, degradation, and redaction tests. [VERIFIED: local command] | Existing Phase 27/28 evidence uses focused SwiftPM filters plus full `swift test --package-path BeautySDK`. [VERIFIED: QUALITY_SCORE.md; VERIFIED: PLANS.md] |
| `BeautyExampleRenderer` executable | Local SwiftPM executable product [VERIFIED: BeautySDK/Package.swift] | Public-facade PNG output evidence. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | It already imports only `BeautySDK`, recursively reads PNG/JPEG fixtures, calls `BeautyEngine.processResult`, watermarks, and writes deterministic flat PNG output names. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] |
| CoreImage / ImageIO / AppKit | Apple frameworks imported by renderer/tests [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] | Load/render `CIImage`, encode PNGs, and draw watermarks in the macOS example executable. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | The existing renderer evidence path already uses these frameworks without third-party dependencies. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| Python 3 standard library | Python 3.9.6 [VERIFIED: local command] | Phase helper for PNG/JPEG dimension parsing and top-region PNG comparison. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] | Use for a Phase 29 helper without adding external package dependencies. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] |
| `rg` | ripgrep 15.1.0 at `/opt/homebrew/bin/rg` [VERIFIED: local command] | Static scans for imports, generated-output policy, raw geometry leaks, stale `example-images/out/` paths, and no-overclaim wording. [CITED: AGENTS.md; VERIFIED: QUALITY_SCORE.md] | Run after source/doc changes and before phase closeout. [VERIFIED: PLANS.md] |
| Git CLI | git 2.50.1 [VERIFIED: local command] | Verify ignored generated outputs and commit docs when configured. [VERIFIED: .gitignore; VERIFIED: .planning/config.json] | Use `git check-ignore` for representative eye output/gallery files and commit only research/evidence/docs when required. [VERIFIED: .gitignore; VERIFIED: .planning/config.json] |
| Xcode toolchain | Xcode 26.6 build 17F113; Swift 6.3.3 [VERIFIED: local command] | Build SwiftPM package and renderer. [VERIFIED: BeautySDK/Package.swift] | Needed for SDK tests and renderer build/run; Demo build is not required unless implementation changes Demo files. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Phase 29-owned helper mirroring Phase 28 [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] | Extend Phase 28 helper in place [ASSUMED] | Extending old helpers can blur historical phase evidence; a Phase 29 helper keeps constants and pass text tied to EYE-01/EYE-02/EYE-03. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| Public-facade renderer output [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | SPI/internal geometry verifier [ASSUMED] | SPI can inspect internals but does not satisfy the public-facade saved-output evidence bar for visible tools. [CITED: docs/meitu-function-blueprint/FEATURE_MATRIX.md; CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] |
| Top-region non-identity against `geometryBaseline_noop` [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] | Full PNG byte diff or generated PNG baseline snapshots [ASSUMED] | Full PNG diffs can be polluted by watermark text, and committed baselines are explicitly out of scope. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |

**Installation:**

```bash
# No external package install is required for Phase 29.
# Use local SwiftPM, Xcode, Python 3 standard library, rg, and git.
```

**Version verification:** Swift 6.3.3, Xcode 26.6, Python 3.9.6, Node 26.0.0, ripgrep 15.1.0, and git 2.50.1 are available locally; `BeautySDK/Package.swift` declares Swift tools 6.0 and local targets only. [VERIFIED: local command; VERIFIED: BeautySDK/Package.swift]

## Package Legitimacy Audit

Phase 29 should not install external packages. [VERIFIED: BeautySDK/Package.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| None | — | — | — | — | Not run | Approved: no external package install is recommended. [VERIFIED: BeautySDK/Package.swift] |

**Packages removed due to slopcheck [SLOP] verdict:** none. [VERIFIED: BeautySDK/Package.swift]  
**Packages flagged as suspicious [SUS]:** none. [VERIFIED: BeautySDK/Package.swift]

## Architecture Patterns

### System Architecture Diagram

```text
example-images/input/{portraits,negatives}
  -> BeautyExampleRenderer (imports BeautySDK only)
  -> RenderCase matrix
       -> existing 17 cases
       -> eyeSize_0p35
       -> eyeDistance_plus0p25 / eyeDistance_minus0p25
       -> eyeYPosition_plus0p20 / eyeYPosition_minus0p20
       -> eyeTailLift_0p25
  -> BeautyEngine.processResult(image:metadata:parameters:)
  -> decision: eye parameter requires geometry?
       no -> geometryBaseline_noop output
       yes -> public still-image facade detection
            -> decision: usable selected face?
                 yes -> internal eye control points + geometry pipeline
                      -> same-dimension watermarked PNG
                 no -> redacted no-face degradation
                      -> same-dimension safe output
  -> Phase 29 helper
       -> verify 161 expected PNGs exist, non-empty, and match fixture dimensions
       -> compare 36 portrait eye outputs against geometryBaseline_noop above watermark
       -> verify representative no-face eye output presence
  -> generated gallery
       -> copy ignored review PNGs under example-images/gallery/eyes/
  -> evidence Markdown
       -> record commands/counts/limitations
       -> keep eye ledger rows partial for Phase 30
```

The diagram reflects the current renderer entry point, locked Phase 29 case matrix, current fixture layout, Phase 28 helper behavior, and Phase 29 status boundary. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: example-images/input; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/BeautyExampleRenderer/main.swift      # Add the six locked eye renderer cases. [VERIFIED]
└── Tests/BeautyCoreTests/
    └── BeautyRendererOutputRegressionTests.swift # Update case inventory and eye scope tests. [VERIFIED]

example-images/
├── generate_gallery.py                           # Add generated eyes/ group. [VERIFIED]
└── README.md                                     # Document ignored output/gallery contract. [VERIFIED]

.planning/phases/29-eye-renderer-output-evidence/
├── 29-RESEARCH.md                                # This artifact. [VERIFIED]
├── check_eye_renderer_outputs.py                 # Recommended helper name; exact name is planner discretion. [ASSUMED]
└── 29-EYE-RENDERER-EVIDENCE.md                   # Locked evidence artifact name. [CITED]
```

### Pattern 1: Renderer Cases Stay Public-Facade-Only

**What:** `BeautyExampleRenderer/main.swift` defines `RenderCase` entries and imports `BeautySDK` only. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift]  
**When to use:** Add the six locked Phase 29 eye rows as additional `RenderCase` values using only existing public `BeautyParameters` eye fields. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift]  
**Example:**

```swift
RenderCase(
    id: "eyeSize_0p35",
    displayName: "eyeSize 0.35",
    parameters: BeautyParameters(eyeSize: 0.35)
)
```

The exact six case IDs and strengths are locked by Phase 29 context. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

### Pattern 2: Inventory Test Mirrors Renderer Matrix

**What:** `BeautyRendererOutputRegressionTests` keeps an ordered `expectedRendererCaseIDs` list and extracts `id: "..."` values from the renderer source. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]  
**When to use:** Update expected IDs to include the six eye case IDs and preserve the import boundary check that forbids internal SDK target imports. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
**Example:**

```swift
private static let expectedRendererCaseIDs = [
    "skinSmoothing_0p50",
    "...",
    "jawSlim_0p35",
    "eyeSize_0p35",
    "eyeDistance_plus0p25",
    "eyeDistance_minus0p25",
    "eyeYPosition_plus0p20",
    "eyeYPosition_minus0p20",
    "eyeTailLift_0p25"
]
```

The current test already checks `import BeautySDK` and rejects imports of `BeautyCore`, `BeautyDetection`, `BeautyEffects`, `BeautyRender`, and `BeautyResources`. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]

### Pattern 3: Top-Region Eye Comparison

**What:** The Phase 28 helper decodes generated PNG payloads, excludes the bottom watermark band, and compares only the top region above the watermark. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]  
**When to use:** For every portrait fixture and Phase 29 eye case, compare against the same fixture's `geometryBaseline_noop` output. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
**Example:**

```python
differs = top_region_differs(
    output_dir / expected_output_name(fixture_name, "geometryBaseline_noop"),
    output_dir / expected_output_name(fixture_name, "eyeDistance_plus0p25"),
    f"output/{geometry_name}",
)
```

The expected Phase 29 comparison count is 36 because there are six portrait fixtures and six locked eye cases. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: example-images/input]

### Pattern 4: Generated Gallery Grouping

**What:** `example-images/generate_gallery.py` maps case IDs into feature groups, checks flat output files, deletes/recreates the gallery directory, and copies PNGs under group/case directories. [VERIFIED: example-images/generate_gallery.py]  
**When to use:** Add an `eyes` group containing exactly the six Phase 29 eye case IDs and leave generated files under ignored `example-images/gallery/`. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: .gitignore]  
**Example:**

```python
"eyes": [
    "eyeSize_0p35",
    "eyeDistance_plus0p25",
    "eyeDistance_minus0p25",
    "eyeYPosition_plus0p20",
    "eyeYPosition_minus0p20",
    "eyeTailLift_0p25",
],
```

### Anti-Patterns to Avoid

- **Adding new public eye parameters:** Phase 29 is limited to existing public fields `eyeSize`, `eyeDistance`, `eyeYPosition`, and `eyeTailLift`. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift]
- **Adding an eye combo renderer case as required scope:** The user locked one case per visible eye behavior and explicitly excluded an eye combo requirement. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]
- **Adding negative `eyeTailLift` renderer evidence:** Current provider output behavior is positive-only for tail lift, and signed/cap safety belongs to Phase 30. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift]
- **Comparing full watermarked PNG bytes:** Watermark labels can create differences unrelated to image geometry, so Phase 29 must compare above the watermark band. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]
- **Promoting `眼睛` ledger rows in Phase 29:** Status promotion belongs to Phase 30 after safety/degradation/redaction evidence. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md]
- **Committing generated PNG baselines:** Generated output and gallery files are ignored artifacts, and Phase 29 evidence should be Markdown commands/counts/limitations. [VERIFIED: .gitignore; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Eye output evidence | Manual visual inspection as the only gate [ASSUMED] | Renderer run plus Phase 29 helper modeled on Phase 28 [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] | Helper checks are repeatable and produce counts/dimensions/comparison totals without committing PNGs. [VERIFIED: QUALITY_SCORE.md; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| Eye algorithm changes | New eye provider or raw geometry API [ASSUMED] | Existing `EyeWarpProvider`, `BeautyEffectResolver`, and public `BeautyParameters` fields [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift] | Phase 29 is evidence for existing behavior, not new behavior. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| PNG parsing dependency | Pillow/ImageMagick dependency [ASSUMED] | Python standard-library `struct`, `zlib`, and file I/O pattern from Phase 28 [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] | The existing helper avoids third-party install risk and already handles current PNG/JPEG fixture needs. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] |
| Generated evidence persistence | Committed PNG snapshots or hash manifests [ASSUMED] | Ignored `example-images/output/`, ignored `example-images/gallery/`, and Markdown evidence [VERIFIED: .gitignore; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | Generated PNG baselines are explicitly out of scope and can create brittle repo churn. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |

**Key insight:** Phase 29 is blocked by missing public-facade saved-output evidence, not by missing eye provider behavior. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md; VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md; VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift]

## Common Pitfalls

### Pitfall 1: Full-Matrix Counts Are Updated In One Place Only
**What goes wrong:** Renderer cases are added, but `BeautyRendererOutputRegressionTests`, gallery grouping, helper constants, docs, or evidence counts still assume the 17-case matrix. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift; VERIFIED: example-images/generate_gallery.py]  
**Why it happens:** Current case IDs are hardcoded in multiple verification surfaces. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift; VERIFIED: example-images/generate_gallery.py; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]  
**How to avoid:** Plan a single renderer-matrix task that updates source, inventory test, helper constants, gallery grouping, and docs together. [VERIFIED: codebase grep]  
**Warning signs:** Evidence still reports 119 outputs instead of 161 after the six eye cases are added. [VERIFIED: local command; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

### Pitfall 2: Watermark-Only False Positives
**What goes wrong:** Helper passes because the bottom watermark label differs while the face region is unchanged. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]  
**Why it happens:** `BeautyExampleRenderer` draws a bottom watermark after rendering. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift]  
**How to avoid:** Reuse `comparable_top_region_rows` and `top_region_differs` from Phase 28 and require 36/36 eye-vs-baseline top-region comparisons. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
**Warning signs:** Helper output mentions byte differences but does not report the portrait top-region comparison count. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]

### Pitfall 3: Over-Testing Degradation In Renderer Outputs
**What goes wrong:** Planner multiplies every eye case by no-face/missing/stale/reused renderer variants. [ASSUMED]  
**Why it happens:** Degradation requirements exist for Phase 30, but Phase 29 only requires representative no-face output presence. [CITED: .planning/ROADMAP.md; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
**How to avoid:** Phase 29 helper should check `no-face-gradient__eyeSize_0p35.png` or another representative locked no-face eye output, then leave broader degradation tests for Phase 30. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
**Warning signs:** Plan adds many degradation PNG cases or new renderer case IDs beyond the six locked eye cases. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

### Pitfall 4: Status Overclaim
**What goes wrong:** `SHAPE_FEATURE_LEDGER.md` promotes `大小`, `上下`, `眼距`, or `眼尾上扬`, or `FEATURE_MATRIX.md` claims whole-branch `眼睛` completion in Phase 29. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md; VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md]  
**Why it happens:** Saved-output evidence can be mistaken for the complete safety/degradation/redaction bar. [CITED: .planning/ROADMAP.md]  
**How to avoid:** Evidence wording should say renderer evidence exists, while rows and branch remain `partial` until Phase 30. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
**Warning signs:** Changed docs contain "implemented" near `眼睛` rows or branch-level completion claims. [VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md; VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md]

### Pitfall 5: Stale `example-images/out/` Paths
**What goes wrong:** Touched docs or helper commands still use the old generated-output path. [VERIFIED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
**Why it happens:** Some historical docs still contain `example-images/out/` even though the current renderer default and ignore policy use `example-images/output/`. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .gitignore; VERIFIED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md]  
**How to avoid:** Update touched active docs and commands to `example-images/output/`; preserve historical completed ledger text when not touched. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; CITED: AGENTS.md]  
**Warning signs:** New Phase 29 evidence commands reference `example-images/out/`. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

## Code Examples

Verified patterns from repository sources:

### Renderer Case Pattern

```swift
RenderCase(
    id: "eyeDistance_plus0p25",
    displayName: "eyeDistance +0.25",
    parameters: BeautyParameters(eyeDistance: 0.25)
)
```

Source: The existing renderer uses this exact `RenderCase(id:displayName:parameters:)` shape for all current cases; the eye case ID/strength comes from locked Phase 29 context. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

### Eye Provider Behavior Pattern

```swift
if abs(strengths.eyeDistance) > Float.ulpOfOne {
    points.append(contentsOf: distancePoints(
        leftCenter: leftCenter,
        rightCenter: rightCenter,
        face: face,
        strength: strengths.eyeDistance
    ))
}
```

Source: `EyeWarpProvider` uses signed `eyeDistance` to create eye-region control points. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift]

### Positive-Only Tail Lift Pattern

```swift
if strengths.eyeTailLift > 0 {
    points.append(contentsOf: tailLiftPoints(face: face, strength: strengths.eyeTailLift))
}
```

Source: `EyeWarpProvider` treats `eyeTailLift` as a positive-output behavior, matching the Phase 29 decision to skip negative tail-lift renderer evidence. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

### Top-Region Helper Pattern

```python
expected_comparisons = len(PORTRAIT_FIXTURE_NAMES) * len(PHASE29_EYE_CASE_IDS)
if portrait_comparisons != expected_comparisons:
    failures.append(
        f"portrait eye-vs-baseline top-region comparisons: "
        f"{portrait_comparisons}/{expected_comparisons}"
    )
```

Source: Phase 28 helper already computes expected comparisons from portrait fixtures and phase-specific geometry case IDs. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Provider/resolver tests supported only `partial` geometry evidence for eyes. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md; VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] | Visible geometry tools need public-facade saved-output evidence before status promotion can be considered. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md; VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] | Phase 27/28 established the saved-output foundation and per-tool face-shape evidence pattern. [VERIFIED: QUALITY_SCORE.md; VERIFIED: PLANS.md] | Phase 29 should extend that evidence path to existing eye parameters before Phase 30 status work. [CITED: .planning/ROADMAP.md] |
| Renderer matrix stopped at 17 cases after Phase 28. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] | Phase 29 should move to 23 cases by adding exactly six eye cases. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | Phase 29 planning date 2026-07-09. [VERIFIED: .planning/STATE.md] | Helper, gallery, docs, and evidence counts must use 161 expected outputs. [VERIFIED: example-images/input; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| `example-images/out/` appears in some stale docs. [VERIFIED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] | Current renderer default, `.gitignore`, and Phase 29 context use `example-images/output/`. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .gitignore; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | Output directory was renamed before Phase 29. [VERIFIED: PLANS.md] | Touches to active evidence docs should correct stale command paths. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |

**Deprecated/outdated:**
- Treating eye provider tests alone as enough for visual completion is outdated for this milestone; public-facade saved-output evidence is required. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md; VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md]
- Using `example-images/out/` in new Phase 29 commands is outdated; use `example-images/output/`. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .gitignore; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]
- Promoting `眼睛` rows during Phase 29 is out of scope; Phase 30 owns safety/degradation/redaction and ledger closeout. [CITED: .planning/ROADMAP.md; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `check_eye_renderer_outputs.py` is a recommended helper filename, not a locked filename. | Recommended Project Structure | Low; context gives planner discretion on exact helper filename. |
| A2 | A Phase 29-owned helper is preferable to modifying Phase 28's helper in place. | Alternatives Considered | Low; planner may still extend/mirror as long as Phase 29 constants and evidence requirements are satisfied. |
| A3 | Manual visual inspection alone is insufficient as the only output evidence gate. | Don't Hand-Roll | Medium; repository precedent strongly favors helper evidence, but the exact inspection policy is not a separately locked user decision. |

## Open Questions

1. **Should the helper be named `check_eye_renderer_outputs.py`?**  
   What we know: Phase 29 context gives the planner discretion over the exact helper filename. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
   What's unclear: No locked filename exists. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
   Recommendation: Use `check_eye_renderer_outputs.py` for clarity and keep it in the Phase 29 directory. [ASSUMED]

2. **Do the locked strengths produce 36/36 top-region differences on the current fixtures without algorithm changes?**  
   What we know: Eye provider behavior exists, and the locked strengths are below current caps. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]  
   What's unclear: The renderer has not yet generated the new eye cases, so the 36 comparisons are not proven yet. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift]  
   Recommendation: Make helper failure a hard Phase 29 gate and fix implementation or fixture handling before completion if any comparison fails. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Swift | SDK build/test and renderer [VERIFIED: BeautySDK/Package.swift] | yes [VERIFIED: local command] | Apple Swift 6.3.3 [VERIFIED: local command] | None needed for planning. |
| Xcode / xcodebuild | Apple SDK toolchain [CITED: AGENTS.md] | yes [VERIFIED: local command] | Xcode 26.6 build 17F113 [VERIFIED: local command] | SwiftPM-only SDK verification is enough if no Demo files change. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| Python 3 | Renderer output helper [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] | yes [VERIFIED: local command] | 3.9.6 [VERIFIED: local command] | Swift tests can cover some behavior, but they do not replace the Phase 29 helper gate. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| `rg` | Static scans [CITED: AGENTS.md] | yes [VERIFIED: local command] | ripgrep 15.1.0 [VERIFIED: local command] | `grep`, if unavailable. [CITED: AGENTS.md] |
| Git | ignored-output checks and docs commit [VERIFIED: .gitignore; VERIFIED: .planning/config.json] | yes [VERIFIED: local command] | 2.50.1 [VERIFIED: local command] | Manual status/ignore inspection, weaker than `git check-ignore`. [ASSUMED] |
| Node GSD entrypoint | Phase init/commit support [VERIFIED: local command] | yes [VERIFIED: local command] | Node 26.0.0 [VERIFIED: local command] | Direct file edits; `gsd-tools` is not on PATH. [VERIFIED: local command] |
| Project graph | Optional semantic discovery [CITED: GSD researcher instructions] | no [VERIFIED: local command] | no `.planning/graphs/graph.json` found [VERIFIED: local command] | Direct grep/source reads were used. [VERIFIED: codebase grep] |

**Missing dependencies with no fallback:**
- None found for planning. [VERIFIED: local command]

**Missing dependencies with fallback:**
- `gsd-tools` is not on PATH, but `/Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs` works through `node`. [VERIFIED: local command]
- `.planning/graphs/graph.json` does not exist, so graph context was skipped. [VERIFIED: local command]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | SwiftPM XCTest with renderer integration command, Python helper, `rg` scans, and Git ignored-output checks. [VERIFIED: BeautySDK/Package.swift; VERIFIED: QUALITY_SCORE.md] |
| Config file | `BeautySDK/Package.swift`; no separate SDK test config is needed for existing SwiftPM tests. [VERIFIED: BeautySDK/Package.swift; VERIFIED: BeautySDK/Tests] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` plus `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests` after renderer/test changes. [VERIFIED: local command] |
| Full suite command | `swift test --package-path BeautySDK`; renderer phase gate also needs `swift build --package-path BeautySDK --product BeautyExampleRenderer`, renderer all-case run, Phase 29 helper, gallery generation, representative `git check-ignore`, no-overclaim scans, and scoped `git diff --check`. [VERIFIED: BeautySDK/Package.swift; VERIFIED: PLANS.md; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| EYE-01 | Renderer includes exactly the six locked eye cases and remains public-facade-only. [CITED: .planning/REQUIREMENTS.md; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | unit/static | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests/testRendererCaseInventoryMatchesCurrentPublicFacadeMatrix` after updating expected IDs. [VERIFIED: local command; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] | test exists; needs Phase 29 update. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] |
| EYE-01 | Existing eye behavior maps to public parameters. [CITED: .planning/REQUIREMENTS.md] | unit/provider | `swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests`. [VERIFIED: local command] | yes. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift] |
| EYE-02 | All expected generated PNGs exist, are non-empty, and preserve dimensions. [CITED: .planning/REQUIREMENTS.md] | fixture/integration | `swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output` plus `python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output`. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | helper does not exist yet; Wave 0 gap. [VERIFIED: local command] |
| EYE-02 | Six eye cases differ from `geometryBaseline_noop` above watermark on six portrait fixtures. [CITED: .planning/REQUIREMENTS.md] | fixture/integration | Same renderer run plus Phase 29 helper; pass text should report `portrait eye-vs-baseline top-region comparisons: 36/36`. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | helper does not exist yet; Wave 0 gap. [VERIFIED: local command] |
| EYE-02 | Representative no-face eye output is present and safely degraded. [CITED: .planning/REQUIREMENTS.md; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | unit + helper | Helper presence check for `no-face-gradient__eyeSize_0p35.png`; optional focused result check can follow the existing no-face summary pattern. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | no-face test pattern exists; eye-specific check needs Phase 29 work. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] |
| EYE-03 | Generated output/gallery files remain ignored and no PNG baseline is committed. [CITED: .planning/REQUIREMENTS.md] | git/static | `git check-ignore example-images/output/e1__eyeSize_0p35.png example-images/gallery/eyes/eyeSize_0p35/e1.png`; scan staged files for generated PNGs before commit. [VERIFIED: .gitignore; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] | ignore rules exist; representative files need generation. [VERIFIED: .gitignore] |

### Sampling Rate

- **Per task commit:** Run the narrowest changed XCTest filter, relevant helper command if generated-output logic changes, and scoped `git diff --check`. [CITED: PLANS.md]
- **Per wave merge:** Run `BeautyRendererOutputRegressionTests`, `EyeWarpProviderTests`, renderer build/run, Phase 29 helper, and representative `git check-ignore`. [VERIFIED: local command; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]
- **Phase gate:** Run full `swift test --package-path BeautySDK`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, renderer all-case command, Phase 29 helper, gallery generation, representative output/gallery ignore checks, stale `example-images/out/` scan over touched active docs, no-overclaim scan, generated-PNG staging scan, decision/requirement coverage, and scoped `git diff --check`. [VERIFIED: PLANS.md; VERIFIED: .gitignore; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

### Wave 0 Gaps

- [ ] `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` update for the 23-case renderer inventory and Phase 29 eye scope checks. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]
- [ ] `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` or equivalent helper for 161 full-matrix outputs, 36/36 eye top-region comparisons, and representative no-face output presence. [ASSUMED; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]
- [ ] `example-images/generate_gallery.py` update for the generated `eyes/` group. [VERIFIED: example-images/generate_gallery.py]
- [ ] `29-EYE-RENDERER-EVIDENCE.md` after renderer/helper commands pass. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]

## Security Domain

Security enforcement is enabled in `.planning/config.json`, so Phase 29 planning must include security checks. [VERIFIED: .planning/config.json] OWASP ASVS is used here as a security-category frame; the official ASVS page describes ASVS as a basis for testing application technical security controls and secure development requirements. [CITED: https://owasp.org/www-project-application-security-verification-standard/]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no [VERIFIED: .planning/ROADMAP.md] | Phase 29 adds no accounts, login, identity, VIP, payment, or entitlement behavior. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| V3 Session Management | no [VERIFIED: .planning/ROADMAP.md] | No sessions, cookies, or tokens are in scope. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| V4 Access Control | no [VERIFIED: .planning/ROADMAP.md] | Local renderer evidence has no user roles or protected server resources. [CITED: SECURITY.md] |
| V5 Input Validation | yes [CITED: SECURITY.md] | Keep public parameter normalization/caps, fixture path handling, PNG/JPEG dimension parsing, and helper failures conservative. [VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] |
| V6 Cryptography | no [VERIFIED: .planning/ROADMAP.md] | No encryption, signing, credential storage, or secrets are added. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| V7 Error Handling and Logging | yes [CITED: RELIABILITY.md] | Evidence, warnings, metrics, and helper failures must stay redacted and aggregate-only. [CITED: RELIABILITY.md; CITED: SECURITY.md] |
| V8 Data Protection / Privacy | yes [CITED: SECURITY.md] | Do not persist raw landmarks, bounding boxes, control points, image bytes, absolute local paths, or generated PNG baselines in git. [CITED: SECURITY.md; VERIFIED: .gitignore] |

### Known Threat Patterns for Swift SDK Renderer Evidence

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Raw face/eye geometry leakage in evidence docs or helper output | Information Disclosure | Output only relative fixture names, case IDs, counts, dimensions, comparison totals, and redacted warnings/metrics. [CITED: SECURITY.md; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] |
| False evidence from watermark-only differences | Spoofing / Repudiation | Compare top-region pixels above the watermark band against `geometryBaseline_noop`. [VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py] |
| Hidden public API or Demo scope expansion | Tampering | Renderer import scan, `BeautyParameters` field guard, Demo no-touch/no-internal-import scans if Demo files are touched. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| Overclaiming `眼睛` completion | Spoofing / Repudiation | No-overclaim scans and explicit wording that Phase 29 records renderer evidence while rows/branch remain `partial`. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |
| Committed generated PNGs | Information Disclosure / Repudiation | Keep outputs under ignored directories and verify representative generated paths with `git check-ignore`. [VERIFIED: .gitignore; CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md] |

## Sources

### Primary (HIGH confidence)
- `AGENTS.md` - repository workflow, routing, verification, and record constraints. [CITED: AGENTS.md]
- `.planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md` - locked Phase 29 decisions, discretion, and deferred scope. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md]
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, and `.planning/STATE.md` - Phase 29 requirements, success criteria, and current state. [VERIFIED: local file reads]
- `PLANS.md` - prior Phase 27/28 renderer/helper evidence and current ledger rules. [VERIFIED: PLANS.md]
- Root contracts: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `QUALITY_SCORE.md`. [VERIFIED: local file reads]
- Blueprint docs: `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, beauty-shaping README, and eyes README. [VERIFIED: local file reads]
- Current code/tests: `BeautyExampleRenderer/main.swift`, `BeautyParameters.swift`, `EyeWarpProvider.swift`, `BeautyEffectResolver.swift`, `BeautySafetyCaps.swift`, `BeautyRendererOutputRegressionTests.swift`, `EyeWarpProviderTests.swift`, `CombinedEffectSafetyTests.swift`, `MissingLandmarkDegradationTests.swift`, and `BeautyEngineGeometryFacadeTests.swift`. [VERIFIED: codebase grep]
- Phase 28 helper: `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py`. [VERIFIED: local file reads]
- Local commands: GSD init through node entrypoint, `swift --version`, `xcodebuild -version`, `python3 --version`, `node --version`, `rg --version`, `git --version`, `swift test --package-path BeautySDK --list-tests`, `xcodebuild -list`, fixture/output counts, and `git check-ignore`. [VERIFIED: local command]

### Secondary (MEDIUM confidence)
- Apple Developer Documentation for Swift packages and XCTest was checked for current official framing of SwiftPM package/test tooling. [CITED: https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode; CITED: https://developer.apple.com/documentation/xctest]
- OWASP ASVS project page was checked for security verification framing. [CITED: https://owasp.org/www-project-application-security-verification-standard/]

### Tertiary (LOW confidence)
- No low-confidence web-only findings were used for implementation planning. [VERIFIED: codebase grep]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all recommended tools are already local or declared in `BeautySDK/Package.swift`; no external package install is recommended. [VERIFIED: local command; VERIFIED: BeautySDK/Package.swift]
- Architecture: HIGH - Phase 27/28 established the public-facade renderer/helper pattern, and current source shows the exact renderer, provider, fixture, helper, gallery, and ignore surfaces to extend. [VERIFIED: PLANS.md; VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/check_face_shape_renderer_outputs.py]
- Pitfalls: HIGH - pitfalls come from locked Phase 29 decisions, current code/tests, current stale path docs, and prior helper patterns. [CITED: .planning/phases/29-eye-renderer-output-evidence/29-CONTEXT.md; VERIFIED: codebase grep]

**Research date:** 2026-07-09 [VERIFIED: environment_context]  
**Valid until:** 2026-08-08 for local codebase patterns, or until Phase 29 implementation changes renderer/test/evidence surfaces. [ASSUMED]
