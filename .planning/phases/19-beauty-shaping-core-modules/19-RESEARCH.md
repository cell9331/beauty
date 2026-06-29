# Phase 19: Beauty Shaping Core Modules - Research

**Researched:** 2026-06-29 [VERIFIED: current_date]
**Domain:** SwiftPM iOS SDK beauty-shaping providers, resolver/degradation behavior, and blueprint status evidence [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
**Confidence:** HIGH [VERIFIED: local repo grep + SwiftPM test listing]

<user_constraints>
## User Constraints (from CONTEXT.md)

All text in this section is copied from `.planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md`; treat it as locked planning input. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]

### Locked Decisions

#### SDK-Only Scope
- **D-01:** Phase 19 is limited to `BeautySDK` core module logic, SDK tests, and blueprint/planning documentation. Do not add or redesign SwiftUI screens, Demo routes, category rails, tool panel UI, or app-side interaction state.
- **D-02:** Demo and editor-shell behavior remains app-owned and out of Phase 19 except for static docs that describe existing ownership. Any UI work belongs to another explicit phase.
- **D-03:** Automated verification can run directly against `BeautySDK` with SwiftPM. Phase 19 completion should not depend on launching Demo UI or simulator UI tests.

#### Geometry Output Status
- **D-04:** Do not attempt to wire public facade geometry saved-image output in Phase 19. The phase should not make `BeautyEngine.processResult(image:)` feed face detection plus geometry render integration into `BeautyExampleRenderer`.
- **D-05:** Geometry-heavy branches must keep honest status. Provider/unit/control-point/MVP proxy evidence can support `partial`, but does not count as public facade saved-image visual completion.
- **D-06:** The blocker must be explicit in docs and summaries: public facade detection plus geometry render integration must produce same-dimension, watermarked renderer outputs before face-shape, eye, nose, mouth, eyebrow, proportion, or 3D sculpt branches can claim visible completion.

#### Public Parameter Boundary
- **D-07:** Do not add public `BeautyParameters` fields in Phase 19. Use only existing public fields:
  `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, `chinLength`,
  `eyeSize`, `eyeDistance`, `eyeYPosition`, `eyeTailLift`,
  `noseSlim`, `noseWingSlim`, `noseTipSize`, `noseBridge`,
  `mouthSize`, `mouthWidth`, `smile`, and `lipColor`.
- **D-08:** Advanced subtools such as forehead, mid-face, philtrum, cheekbone, double chin, eye height/length, pupil/gaze, nose lift/root split, M-lip, teeth, and eyebrow controls remain future parameter needs.
- **D-09:** Any future public parameter expansion requires updates to `DESIGN.md`, product acceptance criteria, compatibility tests, and Demo mapping before implementation can claim support.

#### Branch Status and Promotion Scope
- **D-10:** `脸型` remains `partial`. Phase 19 may strengthen face/chin provider evidence, resolver behavior, degradation behavior, docs, and tests for existing parameters only.
- **D-11:** `眼睛` remains `partial`. Phase 19 may strengthen eye provider, missing-eye, stale/reused, cap, and redaction evidence for existing parameters only.
- **D-12:** `鼻子` remains `partial`. Phase 19 may strengthen nose provider, missing-nose, stale/reused, cap, and redaction evidence for existing parameters only.
- **D-13:** `嘴唇` remains `partial`. Mouth geometry remains partial; `lipColor` may continue to be described as existing visible color evidence, but it does not make the full lips branch implemented.
- **D-14:** `比例` remains `partial`. Only `faceSmall` indirect coverage may be claimed; advanced proportion controls remain future needs.
- **D-15:** `3D塑颜` remains `blocked-by-geometry-output`. Do not implement pose-aware 3D sculpt, symmetry, vertical, horizontal, or tilt controls in Phase 19.
- **D-16:** `眉毛` remains `future`. Do not implement eyebrow geometry, texture synthesis, makeup/resource overlays, or public eyebrow parameters in Phase 19.

#### Verification Threshold
- **D-17:** Phase 19 completion requires `swift test --package-path BeautySDK`.
- **D-18:** Focused verification should include shaping-related tests: `FaceShapeWarpProviderTests`, `EyeWarpProviderTests`, `NoseWarpProviderTests`, `MouthWarpProviderTests`, `GeometryConflictResolverTests`, `MissingLandmarkDegradationTests`, and `BeautyEffectResolverTests`.
- **D-19:** Plans must include scans proving branch docs did not overclaim `implemented`, no public parameters were added, no UI/SwiftUI work was added, no renderer geometry cases or fake saved-image claims were added, and warnings/metrics do not expose landmarks, control points, bounding boxes, raw Vision objects, local paths, or image bytes.
- **D-20:** Renderer build or current skin/color/filter renderer cases may be run as optional regression evidence, but they are not required Phase 19 gates because this phase deliberately does not promote geometry saved-image output.

### the agent's Discretion
The planner may choose the exact plan split, test grouping, scan commands, and wording updates as long as the decisions above remain intact. Implementation should be conservative: strengthen existing SDK/provider behavior and evidence without expanding public API or pretending geometry output is visually complete.

### Deferred Ideas (OUT OF SCOPE)
- Public facade geometry saved-image output is deferred until face detection plus geometry render integration can produce same-dimension, watermarked renderer outputs through `BeautyExampleRenderer`.
- New public shaping parameters for advanced proportion, 3D sculpt, eyebrow, detailed eye, detailed nose, M-lip, teeth, and advanced face-shape controls are deferred.
- Production-grade Metal warp, dense mesh/pose-aware 3D sculpt, eyebrow resource/texture synthesis, teeth whitening, hairline adjustment, and release-readiness visual naturalness QA are deferred.
</user_constraints>

## Summary

Phase 19 should plan a conservative SDK-only hardening pass around existing `BeautyEffects` shaping providers, `BeautyEffectResolver`, safety caps, missing-landmark degradation, and blueprint branch-status documentation. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md; BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift] The phase should not add UI, public parameters, new renderer geometry cases, or saved-image geometry completion claims. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]

The codebase already contains internal `FaceGeometry`, `WarpControlPoint`, provider protocols, face/chin/eye/nose/mouth providers, conflict weakening, redacted warnings/metrics, MVP geometry proxy tests, and branch docs for all required shaping branches. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift; BeautySDK/Sources/BeautyEffects/Warp/WarpControlPointProvider.swift; BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift; docs/meitu-function-blueprint/features/beauty-shaping/README.md] Planning should focus on gap audit, targeted provider/resolver/test/doc improvements, and negative scans that prevent overclaiming. [VERIFIED: .planning/ROADMAP.md; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]

**Primary recommendation:** Use the existing SwiftPM `BeautySDK` target graph and XCTest suites; strengthen only current public-parameter shaping evidence and keep all geometry-heavy branch statuses below `implemented` until public facade geometry rendering exists. [VERIFIED: BeautySDK/Package.swift; docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md]

## Project Constraints (from AGENTS.md)

| Directive | Planning Impact |
| --- | --- |
| Read `AGENTS.md`, `PLANS.md`, task-specific docs, then related code/tests before changes. [VERIFIED: AGENTS.md] | Plans must include read-first steps for root contracts, blueprint docs, provider code, and tests. [VERIFIED: AGENTS.md] |
| Do not expand task boundaries; record unrelated issues in `PLANS.md`. [VERIFIED: AGENTS.md] | Plans should not opportunistically implement public facade geometry output, UI, or future parameters. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| Do not overwrite unrequested local changes. [VERIFIED: AGENTS.md] | Current worktree is dirty; plans and commits must keep file scopes explicit. [VERIFIED: git status --short] |
| Contract changes require updates to the owning root doc. [VERIFIED: AGENTS.md] | Any real architecture/design/security/reliability/product contract change must update `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, or `PRODUCT_SENSE.md`. [VERIFIED: AGENTS.md] |
| Verify with the narrowest meaningful build/test/static check and record failures honestly. [VERIFIED: AGENTS.md] | Phase 19 plans need SwiftPM tests plus negative scans; no fabricated renderer evidence. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| No project-local `.codex/skills` or `.agents/skills` were found. [VERIFIED: find .codex/skills .agents/skills -maxdepth 2 -name SKILL.md] | No additional local skill rules apply beyond root docs and Phase 19 context. [VERIFIED: find .codex/skills .agents/skills -maxdepth 2 -name SKILL.md] |

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
| --- | --- | --- |
| BSHAPE-01 | `3D塑颜`, `比例`, `脸型`, `眼睛`, `嘴唇`, `鼻子`, and `眉毛` each have branch documentation and module ownership. [VERIFIED: .planning/REQUIREMENTS.md] | Branch docs and matrix already enumerate all seven branches, ownership, public parameter coverage, future needs, and evidence expectations; Plan 19-01 should audit and Plan 19-03 should rescan them. [VERIFIED: docs/meitu-function-blueprint/features/beauty-shaping/README.md; docs/meitu-function-blueprint/FEATURE_MATRIX.md; docs/meitu-function-blueprint/MODULES.md] |
| BSHAPE-02 | Promoted beauty-shaping branches implement core logic behind SDK boundaries with safety caps, degradation behavior, and tests. [VERIFIED: .planning/REQUIREMENTS.md] | Existing providers, `BeautySafetyCaps`, `BeautyEffectResolver`, `GeometryConflictResolver`, and focused tests are the implementation surface; plans should strengthen gaps inside `BeautyEffects` only. [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift; BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; BeautySDK/Sources/BeautyEffects/Warp; BeautySDK/Tests/BeautyEffectsTests] |
| BSHAPE-03 | Branch status is honest: implemented, partial, blocked by geometry visual output, or future. [VERIFIED: .planning/REQUIREMENTS.md] | Evidence ladder states provider/resolver geometry evidence is not saved-image completion; plans must keep `3D塑颜` blocked, `眉毛` future, and current geometry branches partial. [VERIFIED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
</phase_requirements>

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
| --- | --- | --- | --- |
| Shaping provider control-point generation | `BeautyEffects` | `BeautyRender` | Providers produce control intent and `BeautyRender` owns the eventual unified warp pass. [VERIFIED: ARCHITECTURE.md; DESIGN.md; BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift] |
| Public shaping parameters | `BeautyCore` | `BeautySDK` facade | `BeautyParameters` is the sole public parameter model and is exposed through the facade. [VERIFIED: DESIGN.md; BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift; BeautySDK/Sources/BeautySDK/BeautyEngine.swift] |
| Detection/landmark dependency | `BeautyDetection` | `BeautyEffects` | Detection owns internal face/landmark models; effects consume internal geometry and must not expose it publicly. [VERIFIED: ARCHITECTURE.md; DESIGN.md] |
| Safety caps, combined weakening, degradation warnings/metrics | `BeautyEffects` | `BeautyCore` diagnostics models | Resolver/caps own effective strengths, skipped domains, warnings, and metrics; warnings use `BeautyValidationWarning` from core. [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift] |
| Public saved-image validation | `BeautySDK` facade | `BeautyExampleRenderer` | Renderer imports only `BeautySDK` and validates public facade output; Phase 19 must not add geometry cases. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] |
| Branch status and ownership docs | Blueprint docs | Root contracts | Branch docs/matrix own taxonomy; root docs own public boundaries, privacy, reliability, and product acceptance. [VERIFIED: docs/meitu-function-blueprint/FEATURE_MATRIX.md; AGENTS.md] |

## Standard Stack

### Core

| Library / Target | Version | Purpose | Why Standard |
| --- | --- | --- | --- |
| Swift Package Manager package `BeautySDK` | Swift tools 6.0; local Apple Swift 6.3.3 available [VERIFIED: BeautySDK/Package.swift; swift --version] | Builds internal targets and XCTest suites. [VERIFIED: BeautySDK/Package.swift] | Existing repo packaging and Phase 19 verification threshold are SwiftPM-based. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| `BeautyCore` | local target [VERIFIED: BeautySDK/Package.swift] | Public parameters, result/detection summaries, errors, diagnostics values. [VERIFIED: ARCHITECTURE.md; DESIGN.md] | Shared value models must remain public-safe and product-neutral. [VERIFIED: ARCHITECTURE.md; DESIGN.md] |
| `BeautyEffects` | local target [VERIFIED: BeautySDK/Package.swift] | Effect resolution, safety caps, geometry providers, conflict weakening, shaping tests. [VERIFIED: ARCHITECTURE.md; BeautySDK/Sources/BeautyEffects] | Phase 19 core logic belongs here, not Demo/UI. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md; ARCHITECTURE.md] |
| `BeautyDetection` | local target [VERIFIED: BeautySDK/Package.swift] | Internal detection/landmark/coordinate models. [VERIFIED: ARCHITECTURE.md; DESIGN.md] | Shaping depends on landmarks but Phase 19 must not expose geometry publicly. [VERIFIED: ARCHITECTURE.md; SECURITY.md] |
| `BeautyRender` | local target [VERIFIED: BeautySDK/Package.swift] | Render graph, copy pass, `Warp.metal`, future unified geometry output. [VERIFIED: BeautySDK/Package.swift; ARCHITECTURE.md] | Geometry providers should flow to a unified warp path, but saved-image geometry output is deferred. [VERIFIED: DESIGN.md; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| XCTest | from Swift/Xcode toolchain [VERIFIED: swift test --package-path BeautySDK --list-tests; xcodebuild -version] | Unit/integration verification for providers, resolver, caps, redaction, facade behavior. [VERIFIED: BeautySDK/Tests] | Existing focused tests are XCTest and SwiftPM lists them successfully. [VERIFIED: swift test --package-path BeautySDK --list-tests] |

### Supporting

| Tool / Target | Version | Purpose | When to Use |
| --- | --- | --- | --- |
| `rg` | local command used successfully [VERIFIED: rg --files] | Static scans for branch status, public parameter additions, UI imports, renderer cases, sensitive tokens. [VERIFIED: QUALITY_SCORE.md; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] | Use in Plan 19-01 and 19-03 negative scan gates. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| `BeautyExampleRenderer` | local SwiftPM executable [VERIFIED: BeautySDK/Package.swift] | Public facade saved-image evidence for already-visible skin/color/filter cases. [VERIFIED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] | Optional regression only in Phase 19; do not add geometry cases. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
| --- | --- | --- |
| Existing `BeautyEffects` providers | New public API or Demo-side logic | Rejected by locked decisions and architecture boundary; Phase 19 is SDK-only and no new `BeautyParameters`. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md; ARCHITECTURE.md] |
| Internal provider/resolver evidence | Public renderer geometry cases | Rejected for Phase 19 because public facade detection plus geometry render integration is deferred. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| XCTest/SwiftPM verification | Simulator UI tests | Rejected as required gate because Phase 19 has no UI scope. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |

**Installation:**

```bash
# No external packages to install for Phase 19. [VERIFIED: BeautySDK/Package.swift]
```

## Package Legitimacy Audit

No external packages are recommended or installed for Phase 19. [VERIFIED: BeautySDK/Package.swift] `BeautySDK/Package.swift` declares local targets and Apple platform dependencies only, so slopcheck and registry verification are not applicable. [VERIFIED: BeautySDK/Package.swift]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
| --- | --- | --- | --- | --- | --- | --- |
| none | n/a | n/a | n/a | n/a | n/a | Approved: no external install. [VERIFIED: BeautySDK/Package.swift] |

**Packages removed due to slopcheck [SLOP] verdict:** none. [VERIFIED: BeautySDK/Package.swift]
**Packages flagged as suspicious [SUS]:** none. [VERIFIED: BeautySDK/Package.swift]

## Architecture Patterns

### System Architecture Diagram

```text
Host App / Demo parameters
  -> public BeautyParameters snapshot
  -> BeautySDK facade validates resources and input
  -> BeautyEffectResolver normalizes strengths, applies caps, checks face geometry state
      -> no public face geometry path: facade image output remains color/skin/filter only
      -> internal face geometry path in tests: providers generate control points
          -> GeometryConflictResolver weakens unsafe combined geometry
          -> BeautyGeometryEffectPipeline aggregates points / MVP proxy evidence
  -> BeautyEffectPlan warnings and metrics use redacted codes/counts
  -> Blueprint docs record partial / blocked / future status honestly
```

This data flow is verified by `BeautyEngine.processResult(...)` resolving facade parameters without face geometry and by internal tests invoking resolver overloads with `FaceGeometry`. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift; BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; BeautySDK/Tests/BeautyEffectsTests]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/BeautyCore/Models/BeautyParameters.swift      # existing public shaping parameters only [VERIFIED]
├── Sources/BeautyEffects/Planning/                       # resolver, caps, effect plan [VERIFIED]
├── Sources/BeautyEffects/Warp/                           # face/chin/eye/nose/mouth providers [VERIFIED]
├── Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift # internal aggregation/MVP proxy [VERIFIED]
└── Tests/BeautyEffectsTests/                             # focused shaping, degradation, redaction tests [VERIFIED]

docs/meitu-function-blueprint/
├── FEATURE_MATRIX.md
├── MODULES.md
├── EXAMPLE_IMAGE_VALIDATION.md
└── features/beauty-shaping/**/README.md
```

The structure above is the existing layout and should be reused in Phase 19. [VERIFIED: rg --files BeautySDK/Sources BeautySDK/Tests docs/meitu-function-blueprint]

### Pattern 1: Public Facade Stays Geometry-Free For Phase 19

**What:** Public image/pixel-buffer processing validates inputs/resources, resolves effects with `BeautyEffectResolver.resolve(parameters:)`, and applies color/effect output without passing public face geometry. [VERIFIED: BeautySDK/Sources/BeautySDK/BeautyEngine.swift]
**When to use:** All Phase 19 public facade and renderer reasoning. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
**Example:**

```swift
// Source: BeautySDK/Sources/BeautySDK/BeautyEngine.swift
let validated = try BeautySDKResources.validate(parameters: parameters)
let plan = BeautyEffectResolver.resolve(parameters: validated)
return BeautyResult(
    output: BeautyColorEffectPipeline.apply(to: image, plan: plan),
    warnings: plan.warnings,
    metrics: plan.metrics,
    detectionSummary: initialDetectionSummary
)
```

### Pattern 2: Internal Provider Evidence Uses `FaceGeometry`

**What:** Tests and internal planning can pass `FaceGeometry` into resolver/provider paths to prove caps, skip behavior, control-point counts, and deterministic MVP proxy bytes. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift; BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift]
**When to use:** Provider/unit evidence for `partial` status only. [VERIFIED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md]
**Example:**

```swift
// Source: BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift
FaceShapeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    ChinWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    EyeWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    NoseWarpProvider().makeControlPoints(face: face, strengths: strengths).points +
    MouthWarpProvider().makeControlPoints(face: face, strengths: strengths).points
```

### Pattern 3: Redacted Degradation Metadata

**What:** Resolver emits stable warning codes and metric counters for caps, skipped domains, reused geometry scale, stale skips, and geometry point counts; tests scan these strings for sensitive terms. [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift]
**When to use:** Any Phase 19 degradation or new test evidence. [VERIFIED: SECURITY.md; RELIABILITY.md]
**Example:**

```swift
// Source: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
metrics["beauty.effects.activeCount"] = Double(activeDomains.count)
metrics["beauty.effects.cappedCount"] = Double(cappedCount)
if geometryPointCount > 0 {
    metrics["beauty.effects.geometryPointCount"] = Double(geometryPointCount)
}
```

### Anti-Patterns to Avoid

- **Adding public `BeautyParameters` fields:** Phase 19 explicitly forbids new public shaping fields. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
- **Claiming provider evidence as saved-image completion:** The evidence ladder forbids treating internal geometry evidence as facade-visible completion. [VERIFIED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md]
- **Adding SwiftUI/Demo work:** Phase 19 is SDK-only and no-UI. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
- **Adding geometry renderer cases:** Phase 19 must not wire facade geometry output or fake saved-image evidence. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
- **Logging raw landmarks/control points/paths:** Security and reliability docs forbid geometry/path/image payloads in logs, metrics, and public summaries. [VERIFIED: SECURITY.md; RELIABILITY.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
| --- | --- | --- | --- |
| Shaping parameter model | New public parameter structs or branch-specific SDK APIs | Existing `BeautyParameters` fields only | Public boundary is locked and current fields cover the promoted partial work. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md; BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift] |
| Geometry evidence | Fake saved PNGs or renderer geometry cases | Provider/resolver/control-point/unit evidence labeled `partial` | Saved-image geometry output is explicitly deferred. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| Combined shape safety | Per-provider ad hoc weakening | `GeometryConflictResolver` plus `BeautySafetyCaps` | Existing tests already cover combined high-strength weakening and cap metadata. [VERIFIED: BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift; BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift] |
| Missing landmark behavior | Throw/crash or skip all effects | Resolver domain-specific skip warnings and metrics | Existing behavior skips affected domains while preserving safe color/filter domains. [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift; BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift] |
| Redaction scanning | Manual visual inspection of logs | XCTest string scans plus `rg` scans | Existing tests and Phase 19 decisions require sensitive token scans. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |

**Key insight:** The hard problem is not generating more controls; it is preserving an honest evidence ladder while the public facade cannot yet render geometry-heavy outputs. [VERIFIED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]

## Common Pitfalls

### Pitfall 1: Overclaiming `implemented`
**What goes wrong:** Branch docs or summaries mark face/eye/nose/mouth/proportion/3D/eyebrow work as visually complete from provider tests alone. [VERIFIED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md]
**Why it happens:** Internal provider evidence exists, but public facade saved-image geometry output does not. [VERIFIED: BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift; BeautySDK/Sources/BeautySDK/BeautyEngine.swift]
**How to avoid:** Keep statuses partial/blocked/future and add scans for unexpected `implemented` in shaping docs. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
**Warning signs:** New renderer cases such as `faceSlim_*`, `eyeSize_*`, `noseSlim_*`, or `mouthSize_*` appear in `BeautyExampleRenderer`. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift]

### Pitfall 2: Public Parameter Drift
**What goes wrong:** A plan adds advanced controls like forehead, philtrum, eyebrow, M-lip, teeth, or nose-lift fields. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
**Why it happens:** Branch docs list future needs, but Phase 19 forbids promoting them. [VERIFIED: docs/meitu-function-blueprint/features/beauty-shaping/README.md]
**How to avoid:** Compare `BeautyParameters` fields before/after and scan for future control names in `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`. [VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift]
**Warning signs:** New coding keys or initializer fields appear in `BeautyParameters`. [VERIFIED: BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift]

### Pitfall 3: Degradation Collapses Too Much
**What goes wrong:** Missing one landmark group disables unrelated safe domains. [VERIFIED: RELIABILITY.md]
**Why it happens:** Domain-specific skip behavior is bypassed or generalized incorrectly. [VERIFIED: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift]
**How to avoid:** Preserve tests where missing eye/nose/mouth skips only the affected domain and keeps safe color/filter or other geometry domains active. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift]
**Warning signs:** `skippedDomains` equals all face-dependent domains for a missing-eye or missing-nose fixture. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift]

### Pitfall 4: Sensitive Metadata Leakage
**What goes wrong:** Warnings or metrics include raw points, bounding boxes, Vision objects, file paths, or image bytes. [VERIFIED: SECURITY.md; RELIABILITY.md]
**Why it happens:** Debug evidence is added from provider internals instead of stable codes/counts. [VERIFIED: SECURITY.md]
**How to avoid:** Reuse warning codes and numeric metrics; keep XCTest and `rg` redaction scans. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
**Warning signs:** Strings like `SIMD`, `[0.`, `VNFaceObservation`, `bounding`, `/private/var`, or `image bytes` appear in active warning/metric surfaces. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift]

## Code Examples

Verified patterns from local sources:

### Resolve Face Geometry Branch With Stale Skip

```swift
// Source: BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift
if hasFaceShapeValues {
    if staleGeometry {
        skippedDomains.insert(.faceShape)
        metrics["beauty.effects.skippedFaceDomains"] = 1
        appendStaleGeometryWarningIfNeeded()
    } else if let faceGeometry {
        let conflict = GeometryConflictResolver().resolve(strengths: strengths)
        strengths = conflict.strengths
        extraWarnings.append(contentsOf: conflict.warnings)
        metrics.merge(conflict.metrics) { _, new in new }
    }
}
```

### Provider Result With Redacted Skip Reason

```swift
// Source: BeautySDK/Sources/BeautyEffects/Warp/WarpControlPointProvider.swift
struct WarpControlPointResult: Equatable, Sendable {
    let points: [WarpControlPoint]
    let skipReason: String?
}
```

### Renderer Case Boundary

```swift
// Source: BeautySDK/Sources/BeautyExampleRenderer/main.swift
let cases = [
    RenderCase(
        id: "skinSmoothing_0p50",
        displayName: "skinSmoothing 0.50",
        parameters: BeautyParameters(skinSmoothing: 0.50)
    )
]
```

The renderer currently lists skin/color/filter cases and imports only `BeautySDK`; Phase 19 should scan that no geometry cases were added. [VERIFIED: BeautySDK/Sources/BeautyExampleRenderer/main.swift; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]

## State of the Art

| Old / Risky Approach | Current Approach | When Changed | Impact |
| --- | --- | --- | --- |
| Treat internal provider evidence as visible output | Evidence ladder separates `partial` provider evidence from facade-visible saved-image completion | Phase 17/19 context [VERIFIED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] | Plans must keep geometry-heavy branches below `implemented`. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| Demo/UI owns shaping behavior | `BeautyEffects` owns promoted effect logic; Demo is out of Phase 19 | Root architecture + Phase 19 context [VERIFIED: ARCHITECTURE.md; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] | Plans should touch SDK/provider/tests/docs, not SwiftUI screens. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |
| Public parameter expansion for every Meitu subtool | Existing public fields only; future needs remain documented | Phase 19 context [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] | Plans must add no new `BeautyParameters` fields. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |

**Deprecated/outdated:**
- Treating `BeautyExampleRenderer` geometry output as required in Phase 19 is outdated by locked D-04 and D-20. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
- Treating eyebrow or 3D sculpt as Phase 19 implementation work is out of scope by D-15 and D-16. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
| --- | --- | --- | --- |
| A1 | If `rg` were unavailable, `find`/`grep` could substitute for static scans. [ASSUMED] | Environment Availability | Low; `rg` is currently available, so the fallback is not needed for this machine. [VERIFIED: rg --files] |
| A2 | Research remains valid for about 30 days unless Phase 19 source or blueprint contracts change first. [ASSUMED] | Metadata | Low; planner should reread changed files if source/docs move before execution. [VERIFIED: AGENTS.md] |

## Open Questions

1. **Which exact provider gaps should Plan 19-02 improve?**
   - What we know: Phase 19 may strengthen provider, resolver, degradation, docs, and tests for existing public parameters only. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
   - What's unclear: Research does not mandate a specific code change if audit finds coverage already sufficient. [VERIFIED: BeautySDK/Tests/BeautyEffectsTests]
   - Recommendation: Plan 19-01 should produce a concrete audit checklist; Plan 19-02 should implement only gaps found by that audit. [VERIFIED: .planning/ROADMAP.md]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
| --- | --- | --- | --- | --- |
| SwiftPM / Swift toolchain | Build and tests | yes [VERIFIED: swift --version] | Apple Swift 6.3.3, swift-driver 1.148.6 [VERIFIED: swift --version] | none needed [VERIFIED: swift --version] |
| Xcode developer tools | Apple SDKs / SwiftPM builds | yes [VERIFIED: xcodebuild -version] | Xcode 26.6, build 17F113 [VERIFIED: xcodebuild -version] | none needed [VERIFIED: xcodebuild -version] |
| `rg` | Static scans | yes [VERIFIED: rg --files] | version not probed [VERIFIED: rg --files] | use `find`/`grep` if missing [ASSUMED] |
| `BeautyExampleRenderer` | Optional renderer regression | yes, declared executable target [VERIFIED: BeautySDK/Package.swift] | local target [VERIFIED: BeautySDK/Package.swift] | optional in Phase 19 [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |

**Missing dependencies with no fallback:** none found. [VERIFIED: swift --version; xcodebuild -version; BeautySDK/Package.swift]

**Missing dependencies with fallback:** none blocking Phase 19 planning. [VERIFIED: swift --version; xcodebuild -version]

## Validation Architecture

### Test Framework

| Property | Value |
| --- | --- |
| Framework | XCTest through SwiftPM [VERIFIED: BeautySDK/Package.swift; swift test --package-path BeautySDK --list-tests] |
| Config file | `BeautySDK/Package.swift` [VERIFIED: BeautySDK/Package.swift] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyEffectsTests` [VERIFIED: swift test --package-path BeautySDK --list-tests] |
| Full suite command | `swift test --package-path BeautySDK` [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
| --- | --- | --- | --- | --- |
| BSHAPE-01 | Branch docs and ownership remain complete/honest | static docs scan | `rg -n "3D塑颜|比例|脸型|眼睛|嘴唇|鼻子|眉毛|blocked-by-geometry-output|partial|future" docs/meitu-function-blueprint/features/beauty-shaping docs/meitu-function-blueprint/FEATURE_MATRIX.md docs/meitu-function-blueprint/MODULES.md` | yes [VERIFIED: docs/meitu-function-blueprint/features/beauty-shaping/README.md] |
| BSHAPE-02 | Provider logic, caps, degradation, and tests exist for promoted partial branches | unit/integration | `swift test --package-path BeautySDK --filter BeautyEffectsTests` | yes [VERIFIED: BeautySDK/Tests/BeautyEffectsTests] |
| BSHAPE-02 | Focused face/chin provider evidence | unit | `swift test --package-path BeautySDK --filter FaceShapeWarpProviderTests` | yes [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift] |
| BSHAPE-02 | Focused eye provider evidence | unit | `swift test --package-path BeautySDK --filter EyeWarpProviderTests` | yes [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift] |
| BSHAPE-02 | Focused nose provider evidence | unit | `swift test --package-path BeautySDK --filter NoseWarpProviderTests` | yes [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift] |
| BSHAPE-02 | Focused mouth provider and lip degradation evidence | unit | `swift test --package-path BeautySDK --filter MouthWarpProviderTests` | yes [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MouthWarpProviderTests.swift] |
| BSHAPE-02 | Combined geometry weakening and MVP proxy evidence | unit | `swift test --package-path BeautySDK --filter GeometryConflictResolverTests` | yes [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift] |
| BSHAPE-02 | Missing eye/nose/mouth/lip, reused, stale, and redaction degradation | unit | `swift test --package-path BeautySDK --filter MissingLandmarkDegradationTests` | yes [VERIFIED: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift] |
| BSHAPE-03 | No branch status overclaim, no new public params/UI/renderer geometry/sensitive metadata | static + full suite | `swift test --package-path BeautySDK` plus `rg` negative scans from D-19 | yes [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md] |

### Sampling Rate

- **Per task commit:** Run the focused test or scan for the touched surface. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
- **Per wave merge:** Run `swift test --package-path BeautySDK --filter BeautyEffectsTests` and relevant docs/static scans. [VERIFIED: swift test --package-path BeautySDK --list-tests]
- **Phase gate:** Run `swift test --package-path BeautySDK` and all D-19 negative scans before `$gsd-verify-work`. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]

### Wave 0 Gaps

- None for framework setup; SwiftPM XCTest infrastructure exists and test listing succeeded. [VERIFIED: BeautySDK/Package.swift; swift test --package-path BeautySDK --list-tests]
- Plan 19-01 should still audit whether each branch has enough focused assertions before Plan 19-02 changes code. [VERIFIED: .planning/ROADMAP.md]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
| --- | --- | --- |
| V2 Authentication | no [VERIFIED: .planning/ROADMAP.md] | No auth surface in Phase 19. [VERIFIED: .planning/ROADMAP.md] |
| V3 Session Management | no [VERIFIED: .planning/ROADMAP.md] | No session surface in Phase 19. [VERIFIED: .planning/ROADMAP.md] |
| V4 Access Control | no [VERIFIED: .planning/ROADMAP.md] | No entitlement or account surface in Phase 19. [VERIFIED: .planning/ROADMAP.md; docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md] |
| V5 Input Validation | yes [VERIFIED: SECURITY.md] | Clamp public parameters, cap effective strengths, skip unsafe geometry domains. [VERIFIED: SECURITY.md; BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift; BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift] |
| V6 Cryptography | no [VERIFIED: .planning/ROADMAP.md] | No crypto or remote resource distribution in Phase 19. [VERIFIED: docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md] |
| V9 Communications | no [VERIFIED: SECURITY.md] | Local-only behavior; no network/upload introduced. [VERIFIED: SECURITY.md; docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md] |
| V14 Configuration | yes [VERIFIED: SECURITY.md; RELIABILITY.md] | Warnings/metrics must be redacted and optional; no raw geometry/path/image data. [VERIFIED: SECURITY.md; RELIABILITY.md] |

### Known Threat Patterns for Swift iOS Beauty SDK

| Pattern | STRIDE | Standard Mitigation |
| --- | --- | --- |
| Raw landmark/control-point leakage in warnings or metrics | Information Disclosure | Emit stable codes/counts only and run redaction tests/scans. [VERIFIED: SECURITY.md; BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift] |
| Public parameter expansion without compatibility contract | Tampering / API misuse | Keep `BeautyParameters` unchanged; future fields require design/product/test updates. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md; DESIGN.md] |
| Untrusted resource or network behavior added for eyebrow/makeup-like shaping | Information Disclosure / Tampering | Keep `BeautyResources` as future-only dependency for shaping unless a resource design is explicitly approved. [VERIFIED: docs/meitu-function-blueprint/features/beauty-shaping/README.md; SECURITY.md] |
| Geometry over-strength distortion | Integrity / Safety | Apply public normalization, safety caps, and combined geometry weakening. [VERIFIED: SECURITY.md; BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift; BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift] |

## Sources

### Primary (HIGH confidence)
- `.planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md` - locked user decisions and Phase 19 constraints. [VERIFIED: local file]
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` - phase requirements, roadmap slots, current state, active plan ledger. [VERIFIED: local files]
- `AGENTS.md`, `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` - project workflow and root contracts. [VERIFIED: local files]
- `BeautySDK/Package.swift` - target graph, executable, and XCTest targets. [VERIFIED: local file]
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` - public parameter boundary. [VERIFIED: local file]
- `BeautySDK/Sources/BeautyEffects/**` - resolver, caps, providers, conflict resolver, geometry MVP proxy. [VERIFIED: local files]
- `BeautySDK/Tests/BeautyEffectsTests/**` - focused provider/degradation/redaction evidence. [VERIFIED: local files]
- `docs/meitu-function-blueprint/**` - branch status, ownership, evidence ladder, renderer limitation. [VERIFIED: local files]
- Command output: `swift --version`, `xcodebuild -version`, `swift test --package-path BeautySDK --list-tests`, `rg --files`, `git status --short`. [VERIFIED: local command output]

### Secondary (MEDIUM confidence)
- None used. [VERIFIED: research process]

### Tertiary (LOW confidence)
- None used. [VERIFIED: research process]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - SwiftPM package and local tool versions were verified. [VERIFIED: BeautySDK/Package.swift; swift --version; xcodebuild -version]
- Architecture: HIGH - Root contracts and Package target graph agree that `BeautyEffects` owns shaping logic and Demo/UI is out of scope. [VERIFIED: ARCHITECTURE.md; BeautySDK/Package.swift; .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md]
- Pitfalls: HIGH - Pitfalls are directly tied to locked Phase 19 decisions, security/reliability contracts, and existing tests. [VERIFIED: .planning/phases/19-beauty-shaping-core-modules/19-CONTEXT.md; SECURITY.md; RELIABILITY.md; BeautySDK/Tests/BeautyEffectsTests]

**Graph context:** `.planning/graphs/graph.json` is absent, so no graph relationships were injected. [VERIFIED: test -f .planning/graphs/graph.json]

**Research date:** 2026-06-29 [VERIFIED: current_date]
**Valid until:** 2026-07-29 for local code/doc planning unless Phase 19 source or blueprint contracts change first. [ASSUMED]
