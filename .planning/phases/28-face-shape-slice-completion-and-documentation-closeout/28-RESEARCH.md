# Phase 28: Face Shape Slice Completion and Documentation Closeout - Research

**Researched:** 2026-07-07 [VERIFIED: environment_context]  
**Domain:** SwiftPM SDK face-shape geometry evidence, public-facade renderer output, XCTest degradation coverage, and documentation ledger closeout [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**Confidence:** HIGH [VERIFIED: codebase grep; VERIFIED: local command]

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
## Implementation Decisions

### Jawline Alias Handling
- **D-01:** `下颌线` remains a v1.5 alias of the existing product-neutral `jawSlim` SDK behavior. Phase 28 should not add a new public parameter or a distinct implementation for it.
- **D-02:** `下颌线` and `下颌角` share `jawSlim` tests, renderer output evidence, safety/degradation evidence, and verification records.
- **D-03:** `SHAPE_FEATURE_LEDGER.md`, the face-shape branch README, and Phase 28 verification must explicitly label `下颌线` as alias-backed by `jawSlim`.
- **D-04:** If `jawSlim` evidence passes, both `下颌角` and alias-backed `下颌线` should be promoted to `implemented`.
- **D-05:** Phase 28 must not add separate `下颌线` Demo behavior, entitlement/pro handling, or an algorithm split.

### Per-Tool Evidence Bar
- **D-06:** Require one renderer case per distinct existing SDK face-shape parameter: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength`. `下颌线` shares the `jawSlim` renderer evidence.
- **D-07:** Each per-parameter renderer case must preserve input dimensions and show a geometry-vs-`geometryBaseline_noop` delta above the watermark band on usable portrait fixtures.
- **D-08:** `chinLength` needs both positive and negative output/test evidence because `下巴长短` is bidirectional.
- **D-09:** Degradation and safety evidence should use focused XCTest/scans rather than renderer output for every degradation variant. Required coverage includes caps, missing contour or no-face degradation, signed `chinLength`, combined weakening, redaction, and no raw geometry leakage.
- **D-10:** Renderer output does not need separate no-face, missing-landmark, stale, or reused cases for every Phase 28 tool. Phase 27 already owns shared no-face and degradation foundation evidence; Phase 28 should add only the per-tool evidence needed to support status promotion.

### Status and Documentation Closeout
- **D-11:** If all five distinct SDK parameters pass evidence, promote only the six scoped `脸型` rows: `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线`.
- **D-12:** Keep unscoped `脸型` tools such as `面部流畅`, `太阳穴`, `颧骨`, `去双下巴`, `去双下巴 Pro`, `尖下巴`, and `发际线` at their existing future/partial status unless direct evidence exists in this phase.
- **D-13:** Keep branch-level `脸型` status in `FEATURE_MATRIX.md` as `partial`, with a scoped completion note for the six implemented rows. Do not promote the entire `脸型` branch to `implemented`.
- **D-14:** After evidence passes, do full scoped synchronization across `SHAPE_FEATURE_LEDGER.md`, the face-shape branch README, branch-level `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, root docs/quality ledger, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md`.
- **D-15:** Phase 28 wording must avoid claims about Demo UI completion, commercial visual quality, device parity, broad Meitu parity, new geometry groups, or release readiness.

### the agent's Discretion
The planner may choose exact renderer case IDs, moderate strengths, helper filenames, per-tool delta thresholds, test filenames, scan command shapes, evidence document names, and final wording. Keep those choices consistent with Phase 27's public-facade renderer pattern, ignored generated-output policy, redaction constraints, and no-overclaim rules.

### Deferred Ideas (OUT OF SCOPE)
- A distinct `下颌线` SDK behavior or product-neutral parameter can be considered in a future phase after v1.5.
- Whole-branch `脸型` completion remains future because unscoped tools such as smooth face contour, temple, cheekbone, double-chin removal, pointed chin, and hairline still need separate design/evidence.
- Demo UI work, commercial quality review, device parity, broad Meitu parity, new geometry groups, and release-readiness claims remain out of scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FACE-01 | `脸宽` is SDK-complete through existing `faceSlim`. [CITED: .planning/REQUIREMENTS.md] | Existing provider behavior moves cheek control points inward; Phase 28 needs a per-tool `faceSlim` renderer case, helper top-region diff, focused cap/degradation/redaction evidence, and ledger promotion only after evidence passes. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift; VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-02 | `小脸` is SDK-complete through existing `faceSmall`. [CITED: .planning/REQUIREMENTS.md] | Existing provider behavior moves contour points toward face center; Phase 28 needs per-tool renderer evidence and status/document synchronization. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift; VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-03 | `下巴长短` is SDK-complete through existing `chinLength`. [CITED: .planning/REQUIREMENTS.md] | Existing chin provider supports signed positive/negative movement; Phase 28 must require positive and negative renderer/test evidence. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift; VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-04 | `V脸` is SDK-complete through existing `faceVShape`. [CITED: .planning/REQUIREMENTS.md] | Existing provider produces lower-face points; Phase 28 needs a distinct renderer case and helper evidence. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift; VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-05 | `下颌角` is SDK-complete through existing `jawSlim`. [CITED: .planning/REQUIREMENTS.md] | Existing provider produces lower-face jaw points; Phase 28 should pair `jawSlim` renderer/test evidence with the alias-backed `下颌线` row. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| FACE-06 | `下颌线` is explicitly handled as either a documented `jawSlim` alias or a separate SDK behavior decision, with ledger evidence. [CITED: .planning/REQUIREMENTS.md] | The user locked the alias path, so planning should document `下颌线` as alias-backed by `jawSlim` and must not add a new public parameter or algorithm. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| DOC-01 | `SHAPE_FEATURE_LEDGER.md` marks only verified `脸型` tools as `implemented`. [CITED: .planning/REQUIREMENTS.md] | Current rows for scoped tools are `partial`; unscoped face-shape rows remain `future`; planner must include a ledger guard and targeted promotion after command evidence passes. [VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] |
| DOC-02 | Beauty-shaping branch docs, `FEATURE_MATRIX.md`, and `EXAMPLE_IMAGE_VALIDATION.md` match the new SDK evidence. [CITED: .planning/REQUIREMENTS.md] | Current branch docs and matrix still describe `脸型` as `partial`; Phase 28 should update branch docs with scoped row completion while keeping branch-level matrix status `partial`. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md; VERIFIED: docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md] |
| DOC-03 | Phase verification records exact test, renderer, scan, and blocker evidence without claiming UI, commercial, or full Meitu parity. [CITED: .planning/REQUIREMENTS.md] | Phase 27 evidence documents show the exact command table, allowlist, ignored-output, redaction, and non-claim pattern to reuse. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md] |
</phase_requirements>

## Summary

Phase 28 should be planned as an evidence-completion and documentation-closeout phase, not as a new geometry architecture phase. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] Phase 27 already proves the shared public-facade saved-output foundation with `geometryBaseline_noop`, `faceShapeCombo_0p35`, 66 ignored PNG outputs, same-dimension checks, 5/5 portrait top-region geometry-vs-baseline comparisons, no-face output presence, and focused degradation tests. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py]

The current implementation has five distinct public face-shape parameters: `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and signed `chinLength`. [VERIFIED: DESIGN.md; VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift] `下颌线` is a locked alias of `jawSlim`, so the planner should not create a new public `BeautyParameters` field, new Demo behavior, entitlement/pro path, or separate algorithm. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

**Primary recommendation:** Add or verify one public-facade renderer case for `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and both positive and negative `chinLength`, extend the renderer inventory tests and a Phase 28 geometry helper to check per-tool top-region deltas against `geometryBaseline_noop`, run focused safety/degradation/redaction tests and scans, then promote only the six scoped `脸型` ledger rows after evidence passes. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Per-tool face-shape behavior | `BeautyEffects` providers/resolver [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift] | `BeautyRender` geometry pipeline [VERIFIED: ARCHITECTURE.md] | Providers generate internal control intent and resolver owns caps/degradation; public SDK should not expose raw geometry. [CITED: ARCHITECTURE.md; CITED: SECURITY.md] |
| Saved-output evidence | `BeautyExampleRenderer` executable [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | Python helper plus Markdown evidence [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] | Renderer imports only `BeautySDK`, runs public `BeautyEngine.processResult`, writes ignored PNGs, and helper verifies dimensions and geometry-vs-baseline differences. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md] |
| Safety/degradation evidence | SwiftPM XCTest under `BeautyEffectsTests` and `BeautyCoreTests` [VERIFIED: swift test --list-tests] | Static scans [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] | No-face, missing contour, stale/reused, combined weakening, caps, and redaction are deterministic in tests and should not require PNGs for every degradation variant. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| Alias decision for `下颌线` | Documentation/status tier [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] | `jawSlim` SDK behavior [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift] | The user locked `下颌线` as alias-backed by `jawSlim`; implementation should document shared evidence rather than split behavior. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| Ledger and root closeout | Planning/docs tier [VERIFIED: .planning/REQUIREMENTS.md; VERIFIED: .planning/ROADMAP.md] | `PLANS.md` and root contracts [CITED: AGENTS.md] | Repository rules require durable decisions and verification evidence in the owning docs and work ledger. [CITED: AGENTS.md; VERIFIED: PLANS.md] |

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
- No project-local `.codex/skills` or `.agents/skills` were found, so there are no additional repository skill rules to apply. [VERIFIED: find .codex/skills .agents/skills]

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| SwiftPM local package `BeautySDK` | `swift-tools-version: 6.0`; local Swift 6.3.3 [VERIFIED: BeautySDK/Package.swift; VERIFIED: local command] | Build SDK modules, tests, and `BeautyExampleRenderer`. [VERIFIED: BeautySDK/Package.swift] | The repository already defines all relevant targets and test suites in this package. [VERIFIED: BeautySDK/Package.swift] |
| XCTest via SwiftPM | Existing test targets under `BeautySDK/Tests` [VERIFIED: BeautySDK/Package.swift; VERIFIED: swift test --list-tests] | Focused provider, resolver, facade, renderer, degradation, and redaction tests. [VERIFIED: swift test --list-tests] | Phase 26 and Phase 27 evidence use focused SwiftPM filters plus full `swift test --package-path BeautySDK`. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] |
| `BeautyExampleRenderer` executable | Local SwiftPM executable product [VERIFIED: BeautySDK/Package.swift] | Public-facade saved PNG evidence. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | It imports only `BeautySDK`, enumerates fixtures and cases, calls `BeautyEngine.processResult`, watermarks, and writes PNGs. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] |
| CoreImage / ImageIO / AppKit | Apple frameworks imported by renderer/tests [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift] | Load/render `CIImage`, encode PNGs, and draw watermarks in the macOS example executable. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | Existing renderer evidence already uses these frameworks without third-party dependencies. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| Python 3 standard library | Python 3.9.6 [VERIFIED: local command] | PNG dimension and top-region comparison helper. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] | Use for a Phase 28 helper or a Phase 27-helper extension without adding dependencies. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] |
| `rg` | `/opt/homebrew/bin/rg` [VERIFIED: local command] | Static scans for imports, raw geometry leaks, overclaim wording, and ledger drift. [CITED: AGENTS.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] | Run after source/doc changes and before closeout. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] |
| Git CLI | Local command available through repository use [VERIFIED: local command] | Verify ignored generated PNGs and commit docs when configured. [VERIFIED: .planning/config.json; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md] | Use `git check-ignore` for representative Phase 28 outputs and `gsd-tools query commit` if available through the node entrypoint. [VERIFIED: .planning/config.json; VERIFIED: node /Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs query init.phase-op 28] |
| Xcode toolchain | Xcode 26.6, Swift 6.3.3 [VERIFIED: local command] | Build SwiftPM package and renderer. [VERIFIED: BeautySDK/Package.swift] | Needed for SDK tests and renderer build/run; Demo build is not required unless implementation changes Demo files. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Extend `BeautyExampleRenderer` case matrix [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | SPI-only per-tool verifier | SPI can force deterministic geometry states, but it would not satisfy the public-facade saved-output evidence bar for status promotion. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| New Phase 28 helper or carefully extended Phase 27 helper [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] | Manual inspection of generated PNGs only | Manual notes cannot mechanically prove output count, dimensions, and per-tool top-region deltas. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md] |
| `下颌线` as `jawSlim` alias [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] | Separate public parameter or algorithm | Separate behavior is explicitly deferred and would expand public API/algorithm scope. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |

**Installation:**

```bash
# No external package install is required for Phase 28.
# Use local SwiftPM, Xcode, Python 3 standard library, rg, and git.
```

**Version verification:** Swift 6.3.3, Xcode 26.6, Python 3.9.6, Node 26.0.0, and `rg` are available locally; `BeautySDK/Package.swift` declares Swift tools 6.0 and local targets only. [VERIFIED: local command; VERIFIED: BeautySDK/Package.swift]

## Package Legitimacy Audit

Phase 28 should not install external packages. [VERIFIED: BeautySDK/Package.swift; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| None | — | — | — | — | Not run | Approved: no external package install is recommended. [VERIFIED: BeautySDK/Package.swift] |

**Packages removed due to slopcheck [SLOP] verdict:** none. [VERIFIED: BeautySDK/Package.swift]  
**Packages flagged as suspicious [SUS]:** none. [VERIFIED: BeautySDK/Package.swift]

## Architecture Patterns

### System Architecture Diagram

```text
example-images/input/*.png
  -> BeautyExampleRenderer (public BeautySDK facade only)
  -> RenderCase parameters
       -> geometryBaseline_noop
       -> faceSlim per-tool case
       -> faceSmall per-tool case
       -> faceVShape per-tool case
       -> jawSlim per-tool case
       -> chinLength positive case
       -> chinLength negative case
  -> BeautyEngine.processResult(image:metadata:parameters:)
  -> decision: geometry-triggering parameter?
       no -> no-geometry baseline output
       yes -> public still-image facade detection
            -> decision: usable selected face?
                 yes -> internal FaceGeometry planning + CIImage geometry proxy
                      -> same-dimension watermarked PNG
                 no -> redacted degradation summary/warnings/metrics
                      -> same-dimension safe output
  -> Phase 28 helper
       -> verify expected outputs exist and are non-empty
       -> verify input/output dimensions match
       -> compare each per-tool portrait output top region against geometryBaseline_noop
       -> verify representative no-face output presence without requiring per-tool no-face cases
  -> evidence Markdown and status ledgers
       -> promote only evidence-backed scoped rows
       -> keep branch-level 脸型 partial
```

The diagram reflects current renderer entry, Phase 27 helper behavior, and Phase 28 locked evidence requirements. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/BeautyExampleRenderer/main.swift      # Add per-tool public-facade renderer cases. [VERIFIED]
├── Tests/BeautyCoreTests/                        # Renderer inventory and facade output/redaction tests. [VERIFIED]
└── Tests/BeautyEffectsTests/                     # Provider, resolver, caps, degradation, weakening tests. [VERIFIED]

.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/
├── 28-RESEARCH.md                                # This research artifact. [VERIFIED]
├── check_face_shape_renderer_outputs.py          # Recommended helper name; exact name is planner discretion. [ASSUMED]
├── 28-FACE-SHAPE-RENDERER-EVIDENCE.md            # Recommended evidence artifact; exact name is planner discretion. [ASSUMED]
└── 28-VERIFICATION.md                            # Final exact command/scan evidence. [CITED]
```

### Pattern 1: Renderer Cases Stay Public-Facade-Only

**What:** `BeautyExampleRenderer/main.swift` defines `RenderCase` entries and imports `BeautySDK` only. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift]  
**When to use:** Add Phase 28 per-tool cases as additional `RenderCase` rows with only existing `BeautyParameters` fields. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**Example:**

```swift
RenderCase(
    id: "faceSlim_0p45",
    displayName: "faceSlim 0.45",
    parameters: BeautyParameters(faceSlim: 0.45)
)
```

The exact IDs and strengths are planner discretion, but each distinct SDK parameter needs a renderer case and `chinLength` needs both signs. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

### Pattern 2: Inventory Test Mirrors Renderer Matrix

**What:** `BeautyRendererOutputRegressionTests` keeps an ordered `expectedRendererCaseIDs` list and scans the renderer source for `id: "..."`
values. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]  
**When to use:** Update expected IDs whenever renderer cases change; keep the public-import boundary assertion. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]  
**Example:**

```swift
private static let expectedRendererCaseIDs = [
    "skinSmoothing_0p50",
    "skinWhitening_0p50",
    "...",
    "geometryBaseline_noop",
    "faceShapeCombo_0p35",
    "faceSlim_0p45"
]
```

The current test also forbids internal SDK target imports in the renderer source. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]

### Pattern 3: Top-Region Geometry Comparison

**What:** Phase 27 decodes PNG pixels and compares only the comparable top region above the watermark band. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py]  
**When to use:** For every Phase 28 portrait fixture and per-tool case, compare against the same fixture's `geometryBaseline_noop` output and ignore the watermark band. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md]  
**Example:**

```python
differs = top_region_differs(
    output_dir / expected_output_name(fixture_name, "geometryBaseline_noop"),
    output_dir / expected_output_name(fixture_name, "faceSlim_0p45"),
    "output faceSlim_0p45",
)
```

The Phase 27 review records that full watermarked-image comparisons were insufficient because different bottom labels could create false positives. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md]

### Pattern 4: Alias Documentation Without API Expansion

**What:** `下颌线` should be documented as alias-backed by `jawSlim` and share the same evidence as `下颌角`. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**When to use:** Update `SHAPE_FEATURE_LEDGER.md`, face-shape README, and verification evidence after `jawSlim` evidence passes. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**Example wording:** "`下颌线` is implemented for v1.5 as an alias-backed `jawSlim` behavior and shares `jawSlim` renderer, test, safety, and degradation evidence." [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

### Anti-Patterns to Avoid

- **Adding a new `BeautyParameters` field for `下颌线`:** This contradicts the locked alias decision and expands public API scope. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]
- **Marking the entire `脸型` branch `implemented`:** Unscoped tools remain future or partial, so `FEATURE_MATRIX.md` should keep branch-level `脸型` as `partial`. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md; VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md]
- **Counting provider-only evidence as complete:** The ledger requires facade-visible saved-output evidence for visible geometry tools. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md]
- **Comparing full watermarked PNGs:** Different labels can produce false positives; compare the top region above the watermark. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md]
- **Committing generated PNG outputs:** Generated outputs belong under ignored `example-images/out/`; repository evidence should be Markdown commands/counts/dimensions/helper results. [VERIFIED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Raw geometry exposure for evidence | Public landmarks, bounding boxes, control points, or Vision object dumps [CITED: SECURITY.md] | Redacted `BeautyResult`, warning codes, aggregate metric keys, and helper summaries [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift] | Raw geometry is sensitive and forbidden across public/SPI evidence surfaces. [CITED: SECURITY.md] |
| Per-tool image validation | Manual eyeballing as the only evidence [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md] | Renderer run plus Python helper checks [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] | Helper evidence is repeatable and records counts/dimensions/deltas without PNG baselines. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md] |
| Separate jawline algorithm | New `jawLine` provider or parameter [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] | Existing `jawSlim` provider plus alias documentation [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift] | The alias decision is locked for v1.5 and separate behavior is deferred. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| Fragile pixel hashes | Committed PNG baselines or exact hash manifests [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] | Same-dimension checks and top-region non-identity against `geometryBaseline_noop` [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] | Phase 27 deliberately avoided brittle hashes and committed baselines. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] |

**Key insight:** Phase 28 completion is evidence-led; the SDK behavior largely exists, but status promotion is blocked until each scoped tool has facade-visible saved-output evidence plus safety/degradation/redaction support. [VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md; VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift]

## Common Pitfalls

### Pitfall 1: False Positive Geometry Deltas From Watermark Labels
**What goes wrong:** A helper compares full PNG bytes and passes because `faceSlim 0.45` and `geometry baseline noop` labels differ in the watermark band. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md]  
**Why it happens:** The renderer draws a bottom watermark after the engine output. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift]  
**How to avoid:** Reuse Phase 27's `comparable_top_region_rows` and `top_region_differs` pattern for Phase 28 cases. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py]  
**Warning signs:** Helper output reports differences but no top-region comparison count or label. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md]

### Pitfall 2: Promoting Unscoped Face-Shape Rows
**What goes wrong:** `面部流畅`, `太阳穴`, `颧骨`, `去双下巴`, `去双下巴 Pro`, `尖下巴`, or `发际线` get promoted without Phase 28 evidence. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**Why it happens:** They share the `脸型` branch label but do not share existing public parameter coverage. [VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md]  
**How to avoid:** Add a ledger guard that allows only `脸宽`, `小脸`, `下巴长短`, `V脸`, `下颌角`, and alias-backed `下颌线` to become `implemented`. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**Warning signs:** `FEATURE_MATRIX.md` branch status changes to `implemented` or future rows move without direct evidence. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md]

### Pitfall 3: Treating `chinLength` as One-Directional
**What goes wrong:** Only positive `chinLength` is tested/rendered, leaving `下巴长短` half-proved. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**Why it happens:** `chinLength` is signed while most scoped face-shape parameters are unit-positive. [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift]  
**How to avoid:** Plan positive and negative renderer case IDs and focused tests for opposite movement direction. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md; VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift]  
**Warning signs:** Evidence names only `chinLength_plus` or only one `chinLength` output case. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

### Pitfall 4: Raw Geometry Leakage in Evidence
**What goes wrong:** Verification docs or tests include coordinates, `SIMD`, bounding boxes, raw landmarks, Vision object names, local paths, raw JSON, or image-byte payloads. [CITED: SECURITY.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md]  
**Why it happens:** Geometry evidence is tempting to explain with control-point details. [CITED: SECURITY.md]  
**How to avoid:** Use stable warning codes, aggregate metric names, counts, dimensions, case IDs, and relative paths only. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md]  
**Warning signs:** Evidence contains `VNFaceObservation`, `FaceGeometry`, `boundingBox`, `controlPoint`, `landmarkCoordinates`, `/private/var`, `raw JSON`, or `image bytes`. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]

### Pitfall 5: Overclaiming Product Readiness
**What goes wrong:** Docs claim Demo UI completion, commercial quality, broad Meitu parity, device parity, release readiness, or full face-shape branch completion. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**Why it happens:** Implemented scoped rows can be mistaken for broader product parity. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]  
**How to avoid:** Add no-overclaim scans over Phase 28 evidence and touched docs before closeout. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md]  
**Warning signs:** Phrases such as "commercial-ready", "full Meitu parity", "device parity", "release-ready", or branch-level "`脸型` implemented" appear in changed docs. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

## Code Examples

Verified patterns from repository sources:

### Renderer Case Pattern

```swift
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

Source: `BeautySDK/Sources/BeautyExampleRenderer/main.swift` currently uses this pattern for Phase 27 geometry foundation. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift]

### Provider Behavior Pattern

```swift
if strengths.jawSlim > 0 {
    points.append(contentsOf: lowerFacePoints(
        face: face,
        strength: strengths.jawSlim,
        maxStrength: BeautySafetyCaps.jawSlim,
        horizontalScale: 0.07,
        verticalScale: 0
    ))
}
```

Source: `FaceShapeWarpProvider` uses existing `jawSlim` behavior that should back both `下颌角` and alias-backed `下颌线`. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

### Signed Chin Pattern

```swift
let direction: Float = strengths.chinLength < 0 ? -1 : 1
let strength = min(abs(strengths.chinLength), BeautySafetyCaps.chinLength)
let target = SIMD2<Float>(chin.x, chin.y + direction * displacement)
```

Source: `ChinWarpProvider` makes `chinLength` bidirectional, so Phase 28 needs positive and negative evidence. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

### Top-Region Helper Pattern

```python
def top_region_differs(baseline_path: Path, geometry_path: Path, label: str) -> bool:
    baseline = read_png_rgba_pixels(baseline_path, f"output/{baseline_path.name}")
    geometry = read_png_rgba_pixels(geometry_path, f"output/{geometry_path.name}")
    comparable_rows = comparable_top_region_rows(baseline.width, baseline.height)
    row_bytes = baseline.width * 4
    comparable_bytes = comparable_rows * row_bytes
    return baseline.rgba[:comparable_bytes] != geometry.rgba[:comparable_bytes]
```

Source: Phase 27 helper decodes PNGs with the Python standard library and compares only the image region above the watermark. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Provider/resolver tests were enough only for `partial` geometry evidence. [VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] | Visible geometry tools require public-facade saved-output evidence before `implemented`. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] | Ledger rule existed before Phase 28 and Phase 27 provided the shared foundation on 2026-07-07. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] | Phase 28 must add per-tool renderer/helper evidence before promotion. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| No geometry renderer cases were present before Phase 27. [VERIFIED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-VERIFICATION.md] | Renderer now has `geometryBaseline_noop` and `faceShapeCombo_0p35`. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift] | Phase 27 completed on 2026-07-07. [VERIFIED: .planning/STATE.md] | Phase 28 should append distinct per-tool cases instead of rebuilding the path. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| Full watermarked PNG comparison could create false positives. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md] | Top-region comparison excludes the watermark band. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] | Phase 27 review/fix. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md] | Phase 28 helper should preserve this comparison method. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] |

**Deprecated/outdated:**
- Treating `下颌线` as undecided is outdated for Phase 28; the user locked it as a `jawSlim` alias. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]
- Keeping scoped `脸型` rows `partial` after passing per-tool evidence is outdated only after Phase 28 command evidence exists; before evidence, current `partial` rows are correct. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]
- Promoting branch-level `脸型` to `implemented` remains out of date and out of scope because unscoped tools still lack behavior. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Recommended names such as `check_face_shape_renderer_outputs.py` and `28-FACE-SHAPE-RENDERER-EVIDENCE.md` are examples, not locked names. | Recommended Project Structure | Low; planner can choose exact filenames under the phase directory. |

## Open Questions

1. **Should Phase 28 create a new helper or extend the Phase 27 helper?**  
   What we know: Phase 27's helper is located under the Phase 27 directory and hardcodes current 11 cases plus a single `faceShapeCombo_0p35` geometry case. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py]  
   What's unclear: Whether the planner prefers a Phase 28-owned helper for per-tool closeout or a backward-compatible helper extension. [ASSUMED]  
   Recommendation: Prefer a Phase 28-owned helper or a clearly Phase 28-scoped copy so Phase 27 evidence remains historically stable. [ASSUMED]

2. **What per-tool strengths should be used?**  
   What we know: Phase 28 allows the planner to choose moderate strengths, and current caps are `faceSlim 0.60`, `faceSmall 0.45`, `faceVShape 0.50`, `jawSlim 0.45`, and `chinLength 0.35`. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md; VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift]  
   What's unclear: The exact strength values that maximize reliable top-region deltas without looking like quality claims. [ASSUMED]  
   Recommendation: Use moderate values at or below Phase 27's existing 0.20-0.35 range for renderer evidence, and keep cap evidence in focused tests. [ASSUMED]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Swift | SDK build/test and renderer [VERIFIED: BeautySDK/Package.swift] | yes [VERIFIED: local command] | Apple Swift 6.3.3 [VERIFIED: local command] | None needed for planning. |
| Xcode / xcodebuild | Apple SDK toolchain [CITED: AGENTS.md] | yes [VERIFIED: local command] | Xcode 26.6 build 17F113 [VERIFIED: local command] | SwiftPM-only SDK verification if no Demo files change. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| Python 3 | Renderer output helper [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] | yes [VERIFIED: local command] | 3.9.6 [VERIFIED: local command] | Swift XCTest can verify some behavior, but helper evidence would be weaker. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md] |
| `rg` | Static scans [CITED: AGENTS.md] | yes [VERIFIED: local command] | `/opt/homebrew/bin/rg` [VERIFIED: local command] | `grep`, if unavailable. [CITED: AGENTS.md] |
| Node GSD tools entrypoint | GSD init/commit support [VERIFIED: local command] | yes [VERIFIED: local command] | Node 26.0.0 [VERIFIED: local command] | Direct file reads; `gsd-tools` is not on PATH. [VERIFIED: local command] |
| Project graph | Optional semantic discovery [CITED: GSD researcher instructions] | no [VERIFIED: local command] | disabled/no graph file [VERIFIED: local command] | Direct grep/source reads were used. [VERIFIED: codebase grep] |

**Missing dependencies with no fallback:**
- None found for planning. [VERIFIED: local command]

**Missing dependencies with fallback:**
- `gsd-tools` is not on PATH, but `/Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs` works through `node`. [VERIFIED: local command]
- `.planning/graphs/graph.json` does not exist and graphify reports disabled, so graph context was skipped. [VERIFIED: local command]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | SwiftPM XCTest with renderer integration command, Python helper, `rg` scans, and Git ignored-output checks. [VERIFIED: BeautySDK/Package.swift; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] |
| Config file | `BeautySDK/Package.swift`; no separate SDK test config was found during research. [VERIFIED: BeautySDK/Package.swift; VERIFIED: rg --files] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` plus changed-surface `BeautyEffectsTests` filters. [VERIFIED: swift test --list-tests] |
| Full suite command | `swift test --package-path BeautySDK`; renderer gate also needs `swift build --package-path BeautySDK --product BeautyExampleRenderer`, renderer run, Phase 28 helper, ignored-output checks, redaction scans, no-overclaim scans, and ledger guards. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| FACE-01 | `faceSlim` has provider behavior, renderer output, and safety/degradation evidence. [CITED: .planning/REQUIREMENTS.md] | unit + renderer/helper | `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests/testFaceSlimCreatesSymmetricCheekPointsMovingInward`; renderer run + Phase 28 helper after case is added. [VERIFIED: swift test --list-tests] | test exists; renderer case/helper need Phase 28 work. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-02 | `faceSmall` has provider behavior, renderer output, and safety/degradation evidence. [CITED: .planning/REQUIREMENTS.md] | unit + renderer/helper | `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests/testFaceSmallMovesMultipleContourPointsTowardFaceCenter`; renderer run + helper after case is added. [VERIFIED: swift test --list-tests] | test exists; renderer case/helper need Phase 28 work. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-03 | signed `chinLength` has positive and negative behavior/output evidence. [CITED: .planning/REQUIREMENTS.md] | unit + renderer/helper | `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests/testChinLengthMovesOppositeDirectionsAndCapsStrength`; renderer run + helper for positive and negative cases. [VERIFIED: swift test --list-tests] | test exists; two renderer cases/helper checks need Phase 28 work. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-04 | `faceVShape` has lower-face provider behavior and renderer evidence. [CITED: .planning/REQUIREMENTS.md] | unit + renderer/helper | `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests/testVShapeAndJawSlimProduceOnlyLowerFacePoints`; renderer run + helper after case is added. [VERIFIED: swift test --list-tests] | shared test exists; renderer case/helper need Phase 28 work. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-05 | `jawSlim` has lower-face provider behavior and renderer evidence. [CITED: .planning/REQUIREMENTS.md] | unit + renderer/helper | `swift test --package-path BeautySDK --filter BeautyEffectsTests.FaceShapeWarpProviderTests/testVShapeAndJawSlimProduceOnlyLowerFacePoints`; renderer run + helper after case is added. [VERIFIED: swift test --list-tests] | shared test exists; renderer case/helper need Phase 28 work. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| FACE-06 | `下颌线` is documented as `jawSlim` alias with shared evidence. [CITED: .planning/REQUIREMENTS.md] | doc/static scan | Scan `SHAPE_FEATURE_LEDGER.md`, face-shape README, and verification for `下颌线`, `jawSlim`, and alias wording after docs update. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] | docs exist; scan needs Phase 28 work. [VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md; VERIFIED: docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md] |
| DOC-01 | Only verified scoped `脸型` rows become `implemented`. [CITED: .planning/REQUIREMENTS.md] | doc/static scan | Ledger guard over `SHAPE_FEATURE_LEDGER.md` to allow only six scoped implemented rows and preserve unscoped rows. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] | ledger exists; guard needs Phase 28 command. [VERIFIED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] |
| DOC-02 | Branch docs, feature matrix, and example validation match evidence. [CITED: .planning/REQUIREMENTS.md] | doc/static scan | `rg` scans for Phase 28 case IDs, scoped completion wording, branch-level `partial`, and no unscoped promotion. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] | docs exist; updates/scans need Phase 28 work. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md; VERIFIED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] |
| DOC-03 | Verification records exact command/test/scan/blocker evidence without overclaims. [CITED: .planning/REQUIREMENTS.md] | doc/static scan | Final `28-VERIFICATION.md` plus no-overclaim and raw-leak scans. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] | verification file does not exist yet; Wave 0 gap. [VERIFIED: node /Users/yakangwang/.codex/get-shit-done/bin/gsd-tools.cjs query init.phase-op 28] |

### Sampling Rate

- **Per task commit:** Run the narrowest touched XCTest filter plus scoped `git diff --check`. [CITED: PLANS.md]
- **Per wave merge:** Run `BeautyRendererOutputRegressionTests`, relevant `FaceShapeWarpProviderTests`, `GeometryConflictResolverTests`, `CombinedEffectSafetyTests`, and any Phase 28 helper after renderer changes. [VERIFIED: swift test --list-tests]
- **Phase gate:** Run full `swift test --package-path BeautySDK`, `swift build --package-path BeautySDK --product BeautyExampleRenderer`, renderer all-case command, Phase 28 helper, representative `git check-ignore`, raw-leak scans, no-overclaim scans, ledger guard, requirement/decision coverage, and scoped `git diff --check`. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md; CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

### Wave 0 Gaps

- [ ] Add/update renderer case inventory tests for Phase 28 per-tool case IDs. [VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift]
- [ ] Create or update a Phase 28 helper that verifies expected outputs, dimensions, top-region per-tool geometry-vs-baseline deltas, and no-face output presence. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py]
- [ ] Add focused tests if existing provider/resolver tests do not explicitly prove Phase 28's selected per-tool safety/degradation bar, especially signed `chinLength`, missing contour/no-face, caps, combined weakening, and redaction. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md; VERIFIED: swift test --list-tests]
- [ ] Create Phase 28 renderer/evidence and verification Markdown artifacts after command evidence exists. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]

## Security Domain

Security enforcement is enabled in `.planning/config.json`, so Phase 28 planning must include security checks. [VERIFIED: .planning/config.json] OWASP ASVS is a verification standard for application technical security controls and is used here as a GSD security-category frame rather than as a claim that this local SDK phase is a web application. [CITED: https://owasp.org/www-project-application-security-verification-standard/]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no [VERIFIED: .planning/ROADMAP.md] | Phase 28 adds no accounts, login, identity, VIP, payment, or entitlement behavior. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| V3 Session Management | no [VERIFIED: .planning/ROADMAP.md] | No sessions, cookies, or tokens are in scope. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| V4 Access Control | no [VERIFIED: .planning/ROADMAP.md] | SDK-local renderer evidence has no user roles or protected server resources. [CITED: SECURITY.md] |
| V5 Input Validation | yes [CITED: SECURITY.md] | Keep parameter normalization/caps, image extent checks, and helper path handling conservative. [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/check_geometry_renderer_outputs.py] |
| V6 Cryptography | no [VERIFIED: .planning/ROADMAP.md] | No encryption, signing, credential storage, or secrets are added in this phase. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| V7 Error Handling and Logging | yes [CITED: RELIABILITY.md] | Evidence, warnings, metrics, and errors must stay redacted and aggregate-only. [CITED: RELIABILITY.md; VERIFIED: BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift] |
| V8 Data Protection / Privacy | yes [CITED: SECURITY.md] | Do not persist raw landmarks, bounding boxes, control points, image bytes, local paths, or generated PNG baselines in git. [CITED: SECURITY.md; VERIFIED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] |

### Known Threat Patterns for Swift SDK Renderer Evidence

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Raw face geometry leakage in public result, tests, or docs | Information Disclosure | Redaction tests and scans for Vision names, geometry types, bounding boxes, control points, landmarks, local paths, raw JSON, and image bytes. [CITED: SECURITY.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] |
| False evidence from watermark-only differences | Spoofing / Repudiation | Top-region geometry-vs-baseline comparison above the watermark band. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md] |
| Hidden public API expansion | Tampering | Public/SPI raw geometry export scans and Demo internal-import scans. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md] |
| Overclaiming parity/readiness | Spoofing / Repudiation | No-overclaim scans over Phase 28 evidence and touched ledgers/docs. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md] |
| Committed generated PNGs | Information Disclosure / Repudiation | Keep outputs under ignored `example-images/out/` and prove representative Phase 28 outputs with `git check-ignore`. [VERIFIED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-GEOMETRY-RENDERER-EVIDENCE.md] |

## Sources

### Primary (HIGH confidence)
- `AGENTS.md` - repository workflow, routing, verification, and record constraints. [CITED: AGENTS.md]
- `.planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md` - locked Phase 28 decisions and deferred scope. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md]
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `.planning/PROJECT.md` - Phase 28 requirements, status, and v1.5 scope. [VERIFIED: local file reads]
- `PLANS.md` - prior Phase 27 completion and verification ledger. [VERIFIED: PLANS.md]
- Root contracts: `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `QUALITY_SCORE.md`. [CITED: root docs]
- Blueprint docs: `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, beauty-shaping README, face-shape README, and shared implementation principles. [VERIFIED: local file reads]
- Current code/tests: `BeautyExampleRenderer/main.swift`, `FaceShapeWarpProvider.swift`, `ChinWarpProvider.swift`, `BeautyEffectResolver.swift`, `BeautySafetyCaps.swift`, `BeautyRendererOutputRegressionTests.swift`, `FaceShapeWarpProviderTests.swift`, `CombinedEffectSafetyTests.swift`, `GeometryConflictResolverTests.swift`, `MissingLandmarkDegradationTests.swift`, and `BeautyEngineGeometryFacadeTests.swift`. [VERIFIED: codebase grep]
- Phase 27 artifacts: `27-VERIFICATION.md`, `27-GEOMETRY-RENDERER-EVIDENCE.md`, `27-VALIDATION.md`, `27-REVIEW.md`, and `check_geometry_renderer_outputs.py`. [VERIFIED: local file reads]
- Local commands: GSD init through node entrypoint, graphify status, `swift --version`, `xcodebuild -version`, `python3 --version`, `node --version`, `command -v rg`, and `swift test --package-path BeautySDK --list-tests`. [VERIFIED: local command]

### Secondary (MEDIUM confidence)
- OWASP ASVS project page - security verification framing only. [CITED: https://owasp.org/www-project-application-security-verification-standard/]

### Tertiary (LOW confidence)
- None. [VERIFIED: codebase grep]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all recommended tools are already local or declared in `BeautySDK/Package.swift`; no external package install is recommended. [VERIFIED: local command; VERIFIED: BeautySDK/Package.swift]
- Architecture: HIGH - Phase 27 completed the shared renderer/facade foundation and current source shows the exact provider/resolver/renderer/test surfaces to extend. [VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-VERIFICATION.md; VERIFIED: codebase grep]
- Pitfalls: HIGH - pitfalls come from locked Phase 28 decisions, current ledger rules, and Phase 27 review findings. [CITED: .planning/phases/28-face-shape-slice-completion-and-documentation-closeout/28-CONTEXT.md; VERIFIED: .planning/phases/27-geometry-render-output-and-verification-harness/27-REVIEW.md]

**Research date:** 2026-07-07 [VERIFIED: environment_context]  
**Valid until:** 2026-08-06 for local codebase patterns, or until Phase 28 implementation changes the renderer/test/evidence surfaces. [ASSUMED]
