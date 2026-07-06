# Phase 26: Geometry Facade and Landmark Routing Foundation - Research

**Researched:** 2026-07-06 [VERIFIED: local date]
**Domain:** iOS Swift SDK facade, internal face detection, landmark-to-geometry routing, privacy-safe diagnostics [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
**Confidence:** HIGH for codebase structure and phase constraints; MEDIUM for the exact adapter shape because the implementation name and access-control choice are intentionally left to planner discretion [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

<user_constraints>
## User Constraints (from CONTEXT.md)

Source for this copied section: [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

### Locked Decisions

### Detection Activation Rule
- **D-01:** Still-image detection inside `BeautyEngine.processResult(...)` should run only when validated parameters contain geometry-triggering work: face shape, eyes, nose, mouth, or lip-region work that needs face geometry. No-op, color, filter, and basic skin paths should preserve the current cheap/no-detection behavior.
- **D-02:** If geometry-triggered detection runs but cannot produce a usable face, `processResult(...)` should degrade and continue. It should return output with face-dependent domains skipped, keep safe color/filter work active, and attach redacted `BeautyDetectionSummary`, warnings, and numeric metrics.
- **D-03:** When no geometry-triggering parameters are present, preserve current compatibility: return `.notRun` when face tracking is enabled but detection was not needed, and `.disabled` when `enableFaceTracking == false`.
- **D-04:** Phase 26 should add an internal or SPI-only test detector seam so facade tests can deterministically simulate usable face, no-face, low-confidence, missing-landmark, and detector-failure states without depending on real Vision output. Public API should remain unchanged.

### Landmark-to-Geometry Routing
- **D-05:** Route a single selected usable face first. This matches the default `maximumFaceCount = 1`, keeps the first geometry facade foundation small, and still respects deterministic face selection.
- **D-06:** The routing bridge should expose internal `FaceGeometry` only across SDK internal targets. `BeautyFaceObservation`, landmark groups, coordinate details, control points, and provider types must stay private; public results expose only `BeautyDetectionSummary`, warnings, and redacted metrics.
- **D-07:** Build a minimal deterministic adapter from the selected detection result into internal `FaceGeometry` that is sufficient to activate existing geometry providers and tests. Full production-grade Vision landmark point extraction may be refined later as long as Phase 26 proves the facade route and keeps privacy boundaries.
- **D-08:** Preserve existing group-specific degradation after routing. Missing eyes skip only eye geometry, missing nose skips nose geometry, missing mouth skips mouth/lip behavior, stale geometry skips strong geometry, reused geometry weakens effective strengths, and no usable face skips face-dependent domains while safe face-agnostic work continues.

### Phase 26 Proof Boundary
- **D-09:** Phase 26 success evidence is intent activation through tests: public `BeautyEngine.processResult(...)` triggers detection when geometry parameters require it, routes selected-face geometry into resolver planning, activates geometry domains/control-point intent, and returns redacted public result evidence.
- **D-10:** Do not add `BeautyExampleRenderer` geometry cases in Phase 26. The Phase 24 renderer matrix stays unchanged; saved-output renderer cases and generated PNG geometry evidence belong to Phase 27.
- **D-11:** The primary gate should be focused SDK facade tests plus existing detection/resolver/provider tests. Internal or SPI seams are allowed only where necessary to keep facade tests deterministic. Internal-only tests are insufficient because the phase is specifically about the public facade.
- **D-12:** Do not mark `SHAPE_FEATURE_LEDGER.md` `脸型` rows as `implemented` in Phase 26. The phase may document that geometry routing foundation exists, but second-level `脸型` completion waits for Phase 28 saved-output evidence.

### Diagnostics and Redaction Surface
- **D-13:** Public evidence that geometry routing happened should be limited to redacted `BeautyDetectionSummary` availability/reasons/counts plus stable numeric metrics. It must not include coordinates, bounding boxes, landmarks, raw Vision objects, control points, image bytes, paths, or raw framework errors.
- **D-14:** Acceptable geometry evidence metrics are counts and flags only, such as active/skipped domain counts, geometry intent/control-point aggregate counts, capped/weakened counts, reused geometry scale, and detection count/timing. Avoid per-point coordinates or detailed geometry structure.
- **D-15:** Phase 26 raw-leak prevention should be verified with both focused tests and scoped active-source scans over `BeautySDK/Sources/BeautyCore`, `BeautySDK/Sources/BeautySDK`, detection/effects routing code, and active Demo surfaces where relevant.
- **D-16:** If planning or implementation finds that an existing metric name such as `geometryPointCount` is too revealing, rename it to a safer stable aggregate and update tests/docs together. Keep values numeric and non-coordinate rather than removing all geometry metrics.

### the agent's Discretion
The planner may choose exact internal type names, SPI/test-seam shape, adapter implementation, safe metric names, focused test filenames, scan command shapes, and evidence artifact filenames. Keep the implementation narrow: no public API expansion, no new renderer cases, no Demo UI work, no saved-output claims, and no status-ledger completion changes.

### Deferred Ideas (OUT OF SCOPE)
- Full multi-face geometry routing is deferred until after the first single selected-face facade route is proven.
- Full production-grade Vision landmark point extraction can be refined after the minimal deterministic adapter proves routing.
- `BeautyExampleRenderer` geometry cases, generated PNG evidence, and renderer invariant updates belong to Phase 27.
- `脸型` second-level tool implementation status changes belong to Phase 28 after saved-output evidence exists.
- Public debug geometry-lite data, face tokens, coordinates, bounding boxes, landmarks, control points, and detailed per-domain point structure remain out of scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| GEO-01 | SDK public facade can run geometry-enabled still-image processing through `BeautyEngine.processResult(...)`. [CITED: .planning/REQUIREMENTS.md] | `BeautyEngine.processResult(image:metadata:parameters:)` is the still-image facade entry, currently validates resources and resolves effects without face geometry; Phase 26 should insert a geometry-triggered detection/routing path before resolver planning while preserving no-op/color/filter/basic-skin behavior. [VERIFIED: codebase] |
| GEO-02 | Detection and landmark results can feed geometry render planning without exposing raw landmark payloads or sensitive diagnostics. [CITED: .planning/REQUIREMENTS.md] | `VisionFaceDetector`, `FaceSelectionPolicy`, `CoordinateMapper`, `BeautyEffectResolver.resolve(parameters:faceGeometry:)`, and redaction tests already cover the main pieces; Phase 26 should connect them through internal-only or SPI-only routing and keep public output limited to `BeautyDetectionSummary`, warnings, and aggregate metrics. [VERIFIED: codebase] |
</phase_requirements>

## Summary

Phase 26 should be planned as a narrow facade bridge, not a new geometry renderer, Demo feature, public landmark API, or visual-output phase. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] The current public `BeautyEngine.processResult(image:metadata:parameters:)` validates parameters, resolves `BeautyEffectResolver.resolve(parameters:)`, applies the color/effect pipeline, and returns `.notRun` or `.disabled` detection summaries without using metadata or face geometry. [VERIFIED: codebase] The existing internal layers already provide detector summary behavior, deterministic face selection, coordinate mapping, resolver geometry activation, degradation warnings, and redacted metric patterns. [VERIFIED: codebase]

The standard implementation path is: validate parameters, detect only when geometry-triggering parameters are non-zero, adapt one selected usable face into internal `FaceGeometry`, call the internal resolver path with that geometry, and return only redacted public evidence. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] [VERIFIED: codebase] If detection is disabled, not needed, unavailable, low-confidence, no-face, or missing required landmarks, the facade should degrade and continue with safe face-agnostic work and structured summary/warning/metric output. [CITED: DESIGN.md] [CITED: RELIABILITY.md] [VERIFIED: codebase]

The highest planning risks are access control and overclaiming. [VERIFIED: codebase] `FaceGeometry`, `BeautyFaceObservation`, `VisionDetectionObservation`, and detector provider seams are internal today, so the planner must choose a narrow internal/SPI seam that lets facade tests inject deterministic detection states without exposing raw observations publicly. [VERIFIED: codebase] Phase 26 evidence must stop at geometry intent/routing activation; saved PNG output, `BeautyExampleRenderer` geometry cases, and `SHAPE_FEATURE_LEDGER.md` `implemented` status are Phase 27/28 work. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md]

**Primary recommendation:** Add a private `BeautySDK` facade routing layer that reuses `VisionFaceDetector`/`FaceSelectionPolicy` and feeds an internal adapter-produced `FaceGeometry` into `BeautyEffectResolver.resolve(parameters:faceGeometry:)`; expose only test SPI for deterministic detectors and only public redacted `BeautyResult` evidence. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|--------------|----------------|-----------|
| Geometry-trigger detection gating | Public SDK Facade / `BeautySDK` | `BeautyEffects` for trigger classification | The public still-image entry owns deciding whether expensive detection is needed for the current request; parameter-domain knowledge may live beside resolver/effects helpers to avoid duplicating geometry-field rules. [VERIFIED: codebase] [CITED: ARCHITECTURE.md] |
| Face detection and selection | `BeautyDetection` | `BeautySDK` calls it | Detection owns Vision-facing observations, coordinate mapping, selection, and geometry-free summaries; the facade should orchestrate but not expose detection internals. [VERIFIED: codebase] [CITED: ARCHITECTURE.md] |
| Landmark-to-`FaceGeometry` adapter | Internal SDK/effects boundary | `BeautyDetection` as input owner | The adapter must translate selected internal detection facts into the existing internal geometry model while keeping observations, groups, points, and bounds private. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |
| Geometry render planning intent | `BeautyEffects` | `BeautyRender` later | `BeautyEffectResolver.resolve(parameters:faceGeometry:)` already activates/skips domains and emits aggregate metrics; production warp output remains later. [VERIFIED: codebase] [CITED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] |
| Public diagnostics/redaction | `BeautyCore` result models | `BeautySDK` assembles output | `BeautyResult`, `BeautyDetectionSummary`, and `BeautyValidationWarning` are public-safe surfaces; raw geometry objects must not cross into public API or Demo. [VERIFIED: codebase] [CITED: DESIGN.md] [CITED: SECURITY.md] |
| Saved-output geometry evidence | Phase 27 renderer path | `BeautyExampleRenderer` | Phase 26 must not add renderer geometry cases or PNG evidence; that responsibility is explicitly deferred. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] [CITED: .planning/ROADMAP.md] |

## Project Constraints (from AGENTS.md)

- Read order is `AGENTS.md`, `PLANS.md`, task-specific root docs, related code/tests, then historical docs when needed. [CITED: AGENTS.md]
- Conflict priority is code and tests, then `PLANS.md`, then specialty root docs, then historical `docs/` material. [CITED: AGENTS.md]
- Package/module responsibility and dependency direction changes require `ARCHITECTURE.md`. [CITED: AGENTS.md]
- Parameter model, render-pipeline state, and core state-machine changes require `DESIGN.md`. [CITED: AGENTS.md]
- Privacy, input validation, and untrusted-resource changes require `SECURITY.md`. [CITED: AGENTS.md]
- Error codes, logs, metrics, performance, and recovery changes require `RELIABILITY.md`. [CITED: AGENTS.md]
- User-facing/public behavior changes require `PRODUCT_SENSE.md` acceptance updates. [CITED: AGENTS.md]
- Test coverage and quality-scan changes require `QUALITY_SCORE.md`. [CITED: AGENTS.md]
- SwiftUI/Demo UI work should read `FRONTEND.md`, but Phase 26 has no UI scope, so frontend research is intentionally skipped except for facade-only boundary awareness. [CITED: AGENTS.md] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
- Do not expand task scope; record extra problems to `PLANS.md` instead of opportunistically fixing them. [CITED: AGENTS.md]
- Do not overwrite unrelated local changes; the current worktree has unrelated modified/deleted/untracked docs and planning artifacts, so Phase 26 edits should be scoped to Phase 26 artifacts until execution plans say otherwise. [VERIFIED: local command] [CITED: AGENTS.md]
- Build commands must explicitly choose an available iOS simulator when using Xcode; this host has available iOS 26.5 simulators including `iPhone 17`. [CITED: AGENTS.md] [VERIFIED: local command]

## Standard Stack

### Core

| Library / Tool | Version | Purpose | Why Standard |
|----------------|---------|---------|--------------|
| Swift Package Manager / `BeautySDK` package | `swift-tools-version: 6.0`; local Swift reports `6.3.3` [VERIFIED: codebase] [VERIFIED: local command] | Build and test SDK targets. [VERIFIED: codebase] | The package already owns `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, public `BeautySDK`, and `BeautyExampleRenderer`. [VERIFIED: codebase] |
| Xcode | 26.6 build 17F113 [VERIFIED: local command] | Xcode project listing and simulator-backed Demo verification when needed. [VERIFIED: local command] | `AGENTS.md` requires explicit simulator destinations for Xcode builds/tests. [CITED: AGENTS.md] |
| XCTest | local SwiftPM/Xcode test infrastructure [VERIFIED: codebase] | Unit/facade/integration-style tests for SDK targets. [VERIFIED: codebase] | `BeautySDK/Tests` contains XCTest cases for facade, detection, effects, resources, render, and result redaction. [VERIFIED: codebase] |
| `BeautySDK` facade target | local target [VERIFIED: codebase] | Public entry point for `BeautyEngine.processResult(...)`. [VERIFIED: codebase] | Host App and `BeautyExampleRenderer` depend on public `BeautySDK`, and Demo must not import internal targets. [VERIFIED: codebase] [CITED: ARCHITECTURE.md] |
| `BeautyDetection` | local target [VERIFIED: codebase] | Internal detector, face selection, summaries, and coordinate mapping. [VERIFIED: codebase] | It already contains `VisionFaceDetector`, `FaceSelectionPolicy`, `CoordinateMapper`, and internal observation types. [VERIFIED: codebase] |
| `BeautyEffects` | local target [VERIFIED: codebase] | Resolver planning, geometry domains, providers, caps, and degradation metrics. [VERIFIED: codebase] | It already accepts internal `FaceGeometry` and emits redacted warnings/metrics for geometry activation/degradation. [VERIFIED: codebase] |

### Supporting

| Library / Tool | Version | Purpose | When to Use |
|----------------|---------|---------|-------------|
| `rg` | available by command use [VERIFIED: local command] | Source boundary and leak scans. [VERIFIED: local command] | Use for active-source import, raw geometry, raw path/error, raw JSON, and overclaim scans. [CITED: QUALITY_SCORE.md] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |
| iOS Simulator | iOS 26.5 devices available [VERIFIED: local command] | Demo/Xcode verification only if later plans include active Demo surfaces. [VERIFIED: local command] | Phase 26 is SDK-core, so simulator work is optional unless execution changes Demo privacy/import tests. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |
| Context7 / `ctx7` | unavailable locally [VERIFIED: local command] | External library docs lookup fallback. [VERIFIED: local command] | Not needed for this phase because no new external packages or external APIs are recommended. [VERIFIED: codebase] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Reusing `VisionFaceDetector` seam | Build a new facade-only fake detector | New fake stack would duplicate existing detector summaries/selection states and could diverge from detection tests. [VERIFIED: codebase] |
| Internal/SPI adapter to `FaceGeometry` | Public landmark or geometry API | Public geometry API violates locked Phase 26 decisions and the root privacy/design boundary. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] [CITED: DESIGN.md] [CITED: SECURITY.md] |
| Aggregate metrics like active/skipped counts | Per-point/control-point diagnostics | Detailed geometry diagnostics are forbidden for public evidence; counts/flags are acceptable. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |
| Focused SDK facade tests | Renderer PNG cases | Phase 26 proof is intent/routing activation, while saved-output geometry belongs to Phase 27. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |

**Installation:**

```bash
# No external package installation is recommended for Phase 26. [VERIFIED: codebase]
```

**Version verification:** The local environment reports Swift 6.3.3 and Xcode 26.6; `BeautySDK/Package.swift` declares Swift tools 6.0 and local targets only. [VERIFIED: local command] [VERIFIED: codebase]

## Package Legitimacy Audit

No external packages are recommended or installed for Phase 26, so the Package Legitimacy Gate is not applicable. [VERIFIED: codebase]

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| none | — | — | — | — | not run | No external dependency install in this phase. [VERIFIED: codebase] |

**Packages removed due to slopcheck [SLOP] verdict:** none. [VERIFIED: codebase]
**Packages flagged as suspicious [SUS]:** none. [VERIFIED: codebase]

## Architecture Patterns

### System Architecture Diagram

```text
Host / tests call public BeautySDK facade
        |
        v
BeautyEngine.processResult(image:metadata:parameters:)
        |
        v
Validate input image + BeautySDKResources.validate(parameters:)
        |
        v
Geometry trigger gate?
   | no                                              | yes
   v                                                 v
resolve(parameters:)                          VisionFaceDetector.detect(...)
summary .notRun/.disabled                           |
   |                                                 v
   |                                          FaceSelectionPolicy selects one usable face
   |                                                 |
   |                                      usable? ---+--- no/failed/partial
   |                                       | yes          |
   |                                       v              v
   |                              internal adapter      no faceGeometry
   |                              to FaceGeometry       redacted summary
   |                                       |              |
   +-------------------------------+-------+--------------+
                                   v
               BeautyEffectResolver.resolve(parameters:faceGeometry?)
                                   |
                                   v
             active/skipped domains + redacted warnings/metrics
                                   |
                                   v
             BeautyColorEffectPipeline.apply(...) for current output
                                   |
                                   v
        BeautyResult(output, warnings, metrics, BeautyDetectionSummary)
```

This diagram reflects current source responsibilities plus the Phase 26 bridge to add. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

### Recommended Project Structure

```text
BeautySDK/
├── Sources/
│   ├── BeautySDK/
│   │   └── BeautyEngine.swift                 # facade orchestration and SPI test seam [VERIFIED: codebase]
│   ├── BeautyDetection/
│   │   ├── VisionFaceDetector.swift           # existing detector provider seam and summaries [VERIFIED: codebase]
│   │   ├── FaceSelectionPolicy.swift          # existing deterministic selected-face policy [VERIFIED: codebase]
│   │   └── CoordinateMapper.swift             # existing metadata-aware coordinate mapper [VERIFIED: codebase]
│   └── BeautyEffects/
│       ├── Planning/BeautyEffectResolver.swift # existing faceGeometry resolver path [VERIFIED: codebase]
│       └── Warp/WarpControlPoint.swift         # internal FaceGeometry model [VERIFIED: codebase]
└── Tests/
    ├── BeautyCoreTests/
    │   └── BeautyEngineTests.swift             # current facade result/redaction patterns [VERIFIED: codebase]
    ├── BeautyDetectionTests/                   # detector/selection/coordinate behavior [VERIFIED: codebase]
    ├── BeautyEffectsTests/                     # resolver/provider/degradation behavior [VERIFIED: codebase]
    └── BeautySDKTests/
        └── BeautySDKFacadeTests.swift          # public facade import/API exposure checks [VERIFIED: codebase]
```

Add no new package or target unless a planner proves existing access-control boundaries cannot support the narrow bridge. [CITED: ARCHITECTURE.md] [VERIFIED: codebase]

### Pattern 1: Geometry Trigger Gate

**What:** Detect only when validated parameters contain geometry-triggering work: face shape, eyes, nose, mouth, or lip-region work that needs face geometry. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

**When to use:** Use inside `BeautyEngine.processResult(image:metadata:parameters:)` after resource validation and before resolver planning. [VERIFIED: codebase]

**Example:**

```swift
// Source: BeautySDK/Sources/BeautySDK/BeautyEngine.swift and 26-CONTEXT.md [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
let validated = try BeautySDKResources.validate(parameters: parameters)
let shouldDetect = validated.hasGeometryTriggeredWork
let geometryRoute = shouldDetect ? detectAndAdaptGeometry(...) : nil
let plan = BeautyEffectResolver.resolve(parameters: validated, faceGeometry: geometryRoute?.faceGeometry)
```

The planner should decide the exact helper name and visibility. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

### Pattern 2: Internal Detector Seam, Public Result Evidence

**What:** Reuse `VisionFaceDetector`'s provider seam or an equivalent SPI facade wrapper so tests can simulate usable face, no-face, low-confidence, missing-landmark, and detector failure states. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

**When to use:** Use in focused facade tests that import only public `BeautySDK` plus allowed testing SPI; do not expose detector/provider types publicly. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

**Example:**

```swift
// Source: VisionFaceDetector has ObservationProvider and tests already inject outcomes. [VERIFIED: codebase]
var detector = VisionFaceDetector { _ in
    [VisionDetectionObservation(stableID: "face", confidence: 0.95, normalizedArea: 0.40)]
}
let result = detector.detect(metadata: BeautyInputMetadata(orientation: .up, source: .testFixture))
XCTAssertEqual(result.summary.availability, .usable)
```

The facade should not return `VisionDetectionObservation`, `BeautyFaceObservation`, or raw landmark groups. [CITED: SECURITY.md] [CITED: DESIGN.md] [VERIFIED: codebase]

### Pattern 3: Single Selected Face to Internal `FaceGeometry`

**What:** Use only the first selected usable face for Phase 26, then adapt to internal `FaceGeometry` sufficient for existing providers. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

**When to use:** Use after detector selection reports `.usable` and at least one selected observation. [VERIFIED: codebase]

**Example:**

```swift
// Source: FaceSelectionPolicy returns selectedFaces and public-safe counts. [VERIFIED: codebase]
let selected = detectionResult.observations.first
let faceGeometry = selected.map { observation in
    InternalFaceGeometryAdapter.makeFaceGeometry(from: observation)
}
```

The adapter can start deterministic and minimal because D-07 explicitly allows refining full production-grade Vision landmark point extraction later. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

### Pattern 4: Resolver Owns Geometry Degradation

**What:** Feed `FaceGeometry?` into the existing resolver so active/skipped domains, caps, stale/reused weakening, and redacted warnings/metrics stay centralized. [VERIFIED: codebase]

**When to use:** Use for both usable geometry and no usable face; do not replicate missing-eye/nose/mouth logic in the facade. [VERIFIED: codebase] [CITED: RELIABILITY.md]

**Example:**

```swift
// Source: BeautyEffectResolver internal overload and degradation tests. [VERIFIED: codebase]
let plan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(faceSlim: 1, eyeSize: 1, noseSlim: 1, mouthSize: 1),
    faceGeometry: faceGeometry
)
XCTAssertTrue(plan.metrics.keys.allSatisfy { !$0.contains("bounding") })
```

If `geometryPointCount` is deemed too revealing, rename it to a safer aggregate in code/tests/docs together. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] [VERIFIED: codebase]

### Anti-Patterns to Avoid

- **Detecting for every still image:** No-op, color, filter, and basic skin paths must keep cheap `.notRun` or `.disabled` behavior. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] [VERIFIED: codebase]
- **Public landmark or bounding-box API:** Public results must not expose coordinates, bounding boxes, raw Vision objects, control points, or landmarks. [CITED: SECURITY.md] [CITED: DESIGN.md]
- **Demo/internal-target imports as proof:** Phase 26 is public facade work; Demo must remain facade-only and internal-only tests are insufficient as primary evidence. [CITED: ARCHITECTURE.md] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
- **Renderer/PNG overreach:** `BeautyExampleRenderer` geometry cases and saved-output evidence belong to Phase 27. [CITED: .planning/ROADMAP.md] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
- **Status-ledger overclaim:** `SHAPE_FEATURE_LEDGER.md` `脸型` rows stay below `implemented` until Phase 28 has saved-output evidence. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Detector state simulation | A second fake detector model in facade tests | `VisionFaceDetector` provider seam or a thin SPI facade seam over it [VERIFIED: codebase] | Existing tests already cover no-face, low-confidence, missing landmarks, detector unavailable, timeout, and selection summaries. [VERIFIED: codebase] |
| Face selection | New largest-face sorting in `BeautySDK` | `FaceSelectionPolicy` [VERIFIED: codebase] | It already enforces deterministic area/stable-ID selection and `faceLimitApplied` summaries. [VERIFIED: codebase] |
| Coordinate conversion | Ad hoc Vision-to-image math in facade/effects | `CoordinateMapper` [VERIFIED: codebase] | Root design requires coordinate conversions through the mapper with orientation and mirroring inputs. [CITED: DESIGN.md] |
| Geometry degradation | Per-domain skip logic in facade | `BeautyEffectResolver.resolve(parameters:faceGeometry:)` [VERIFIED: codebase] | Existing resolver tests cover no face, missing groups, stale, reused, caps, and redaction. [VERIFIED: codebase] |
| Public diagnostics | Raw debug geometry strings or JSON | `BeautyDetectionSummary`, warning codes, and aggregate numeric metrics [VERIFIED: codebase] | Security/design docs forbid raw frames, landmarks, bounding boxes, paths, raw framework errors, and image bytes. [CITED: SECURITY.md] [CITED: DESIGN.md] |
| Saved visual geometry proof | New Phase 26 renderer cases | Phase 27 `BeautyExampleRenderer` or equivalent SDK-only path [CITED: .planning/ROADMAP.md] | Phase 26 only proves facade routing intent and redacted evidence. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |

**Key insight:** This phase is an orchestration and privacy-boundary phase; the highest-value work is connecting existing pieces without broadening public API or proof scope. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

## Common Pitfalls

### Pitfall 1: Treating `enableFaceTracking` as the Detection Trigger

**What goes wrong:** Detection runs on no-op/color/filter/basic-skin still-image paths and breaks cheap compatibility behavior. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
**Why it happens:** Current `BeautyEngine.initialDetectionSummary` depends on `enableFaceTracking`, but Phase 26 detection should depend on geometry-triggering parameters. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
**How to avoid:** Add an explicit geometry-trigger helper after validated parameters and assert `.notRun`/`.disabled` compatibility in focused tests. [VERIFIED: codebase]
**Warning signs:** Existing metadata compatibility tests start failing for default or basic-skin paths. [VERIFIED: codebase]

### Pitfall 2: Exposing Raw Geometry Through Public Evidence

**What goes wrong:** Tests or diagnostics include landmark, bounding-box, `VNFaceObservation`, control-point, path, or raw error tokens. [CITED: SECURITY.md] [VERIFIED: codebase]
**Why it happens:** Existing internal types contain geometry details, and broad stringification can leak type names or coordinates. [VERIFIED: codebase]
**How to avoid:** Return only `BeautyDetectionSummary`, warning codes/messages, and aggregate metrics; run focused redaction tests and active-source scans. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] [VERIFIED: codebase]
**Warning signs:** Public facade tests assert on raw coordinate structures or metrics containing `SIMD`, `[0.`, `bounding`, or `landmark`. [VERIFIED: codebase]

### Pitfall 3: Duplicating Resolver Domain Logic

**What goes wrong:** The facade tries to decide missing-eye/missing-nose/missing-mouth behavior itself and diverges from resolver/provider tests. [VERIFIED: codebase]
**Why it happens:** The detection layer currently reports only group availability, while the resolver owns domain activation and skip behavior once it has `FaceGeometry`. [VERIFIED: codebase]
**How to avoid:** Keep facade logic to trigger, detect, adapt, and call resolver; leave domain-specific degradation inside `BeautyEffectResolver`. [VERIFIED: codebase]
**Warning signs:** New code in `BeautyEngine.swift` mentions individual effect domains beyond trigger classification and summary merging. [VERIFIED: codebase]

### Pitfall 4: Overclaiming Geometry Completion

**What goes wrong:** Phase 26 evidence is described as saved-output geometry completion or ledger rows become `implemented`. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
**Why it happens:** Provider/resolver/control-point evidence exists, but visual saved-output evidence is still deferred. [CITED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md] [VERIFIED: codebase]
**How to avoid:** Use terms like "facade routing foundation", "geometry intent activated", and "redacted route evidence"; explicitly say saved-output evidence belongs to Phase 27. [CITED: .planning/ROADMAP.md]
**Warning signs:** Plans mention adding renderer geometry cases, generated PNGs, or marking `脸型` rows implemented. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

### Pitfall 5: Depending on Real Vision Output in Facade Tests

**What goes wrong:** Tests become nondeterministic, require real image face quality, or cannot exercise low-confidence/missing-landmark/failure states. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
**Why it happens:** `VisionFaceDetector.defaultObservationProvider` currently creates a Vision request but throws `detectorUnavailable`, so real Vision landmark extraction is not implemented in the default path. [VERIFIED: codebase]
**How to avoid:** Add an internal or SPI-only test seam and reuse existing provider-style injection. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
**Warning signs:** Facade tests require portrait fixture landmarks or skip detector failure states. [VERIFIED: codebase]

## Code Examples

Verified patterns from current source:

### Current Facade Processing Shape

```swift
// Source: BeautySDK/Sources/BeautySDK/BeautyEngine.swift [VERIFIED: codebase]
let validated = try BeautySDKResources.validate(parameters: parameters)
let plan = BeautyEffectResolver.resolve(parameters: validated)
return BeautyResult(
    output: BeautyColorEffectPipeline.apply(to: image, plan: plan),
    warnings: plan.warnings,
    metrics: plan.metrics,
    detectionSummary: initialDetectionSummary
)
```

Phase 26 should change only the plan-construction path for geometry-triggering still-image requests. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

### Existing Detector Injection Pattern

```swift
// Source: BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift [VERIFIED: codebase]
var detector = VisionFaceDetector { _ in
    [
        VisionDetectionObservation(
            stableID: "partial",
            confidence: 0.90,
            normalizedArea: 0.40,
            landmarks: .missingRequiredGeometry
        )
    ]
}
let result = detector.detect(metadata: metadata())
XCTAssertEqual(result.summary.availability, .partial)
```

Facade tests should get equivalent deterministic states without exposing these internal types publicly. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

### Existing Resolver Geometry Path

```swift
// Source: BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift [VERIFIED: codebase]
let plan = BeautyEffectResolver.resolve(
    parameters: BeautyParameters(faceSlim: 1, eyeSize: 1, noseSlim: 1, mouthSize: 1),
    faceGeometry: .reused
)
XCTAssertTrue(plan.activeDomains.contains(.eyes))
XCTAssertTrue(plan.activeDomains.contains(.nose))
XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_reduced" })
```

Phase 26 should use this resolver behavior through the public facade instead of creating new degradation rules. [VERIFIED: codebase]

### Redaction Assertion Style

```swift
// Source: BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift and BeautyEffectsTests redaction helpers [VERIFIED: codebase]
let combined = (
    result.warnings.map { "\($0.code) \($0.message)" } +
    Array(result.metrics.keys) +
    (result.detectionSummary?.reasons.map(\.rawValue) ?? [])
).joined(separator: " ")
for forbidden in ["landmark", "boundingBox", "VNFaceObservation", "/private/var", "NSError", "rawPresetJson", "image bytes"] {
    XCTAssertFalse(combined.contains(forbidden))
}
```

Phase 26 should extend this pattern to geometry-triggered facade results. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

## State of the Art

| Old Approach | Current/Phase 26 Approach | When Changed | Impact |
|--------------|---------------------------|--------------|--------|
| Public facade resolves parameters without face geometry and returns `.notRun`/`.disabled`. [VERIFIED: codebase] | Geometry-triggered still-image requests should run detection, adapt selected face to internal `FaceGeometry`, and feed resolver planning while preserving cheap no-detection paths. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] | Phase 26 planning scope on 2026-07-06. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] | GEO-01/GEO-02 can be satisfied without adding public geometry API. [CITED: .planning/REQUIREMENTS.md] |
| Provider/resolver geometry tests are partial internal evidence. [CITED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md] | Phase 26 adds public facade routing intent evidence but still does not add saved-output evidence. [CITED: .planning/ROADMAP.md] | v1.5 Phase 26/27 split. [CITED: .planning/ROADMAP.md] | Ledger rows remain `partial` until Phase 28. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] |
| Detection tests live in `BeautyDetectionTests` and facade tests do not drive detector states. [VERIFIED: codebase] | Phase 26 needs focused facade tests with deterministic detector outcomes via internal/SPI seam. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] | Phase 26. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] | Internal-only tests become supporting evidence, not primary proof. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |

**Deprecated/outdated:**

- Treating `BeautyEffectResolver.resolve(parameters:)` geometry skips as sufficient public-facade geometry proof is outdated for Phase 26 because GEO-01 requires the public facade to exercise geometry-enabled still-image processing. [CITED: .planning/REQUIREMENTS.md] [VERIFIED: codebase]
- Treating generated renderer matrix docs as geometry-completion evidence is outdated for Phase 26 because the current matrix is skin/color/filter only and geometry output is deferred to Phase 27. [CITED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] [CITED: .planning/ROADMAP.md]

## Assumptions Log

All implementation-critical codebase and project-scope claims in this research are verified from local source/commands or cited from project docs. [VERIFIED: codebase] [VERIFIED: local command] The only assumptions are template-level security taxonomy and freshness estimates that do not select packages or change implementation scope. [ASSUMED]

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | ASVS category labels and STRIDE classifications are applicable as the GSD security template frames them; current OWASP docs were not fetched in this session. [ASSUMED] | Security Domain | Planner may need to adjust category labels during security review, but Phase 26's concrete mitigations still come from verified project security docs. [CITED: SECURITY.md] |
| A2 | Research remains valid until 2026-08-05 unless Phase 26/27 source changes land earlier. [ASSUMED] | Metadata | Planner should refresh source scans if code changes before execution. [ASSUMED] |

## Open Questions (RESOLVED)

Resolved: no blocking questions remain. [VERIFIED: codebase] Exact internal type names, SPI/test-seam shape, adapter implementation, metric names, test filenames, scan command shapes, and evidence filenames are intentionally delegated to planner discretion by the Phase 26 context. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Swift toolchain | SwiftPM SDK tests and builds | yes [VERIFIED: local command] | Apple Swift 6.3.3 [VERIFIED: local command] | none needed [VERIFIED: local command] |
| Xcode | Xcode project listing and optional Demo simulator tests | yes [VERIFIED: local command] | Xcode 26.6 build 17F113 [VERIFIED: local command] | SwiftPM SDK tests for Phase 26 core verification [VERIFIED: codebase] |
| iOS Simulator | Optional Demo/import/privacy checks | yes [VERIFIED: local command] | iOS 26.5 devices including `iPhone 17` [VERIFIED: local command] | Skip Demo work unless execution changes active Demo surfaces; Phase 26 is SDK-core. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |
| `ctx7` | Documentation lookup fallback | no [VERIFIED: local command] | — | Use codebase/root docs because no external package docs are needed. [VERIFIED: codebase] |
| SwiftPM test discovery | Test infrastructure audit | yes [VERIFIED: local command] | `swift test --package-path BeautySDK --list-tests` returned SDK XCTest names [VERIFIED: local command] | Direct source scan of `BeautySDK/Tests` [VERIFIED: codebase] |

**Missing dependencies with no fallback:**
- None for Phase 26 research/planning. [VERIFIED: local command]

**Missing dependencies with fallback:**
- `ctx7` is missing; codebase/root-doc verification is sufficient because Phase 26 recommends no new third-party package or external API. [VERIFIED: local command] [VERIFIED: codebase]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | XCTest via SwiftPM/Xcode; tests are Swift files under `BeautySDK/Tests`. [VERIFIED: codebase] |
| Config file | `BeautySDK/Package.swift`; no separate XCTest plan or test config was found in the SDK package scan. [VERIFIED: codebase] |
| Quick run command | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineTests` [VERIFIED: codebase] |
| Full suite command | `swift test --package-path BeautySDK` [VERIFIED: codebase] |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|--------------|
| GEO-01 | Geometry-triggering still-image parameters call public `BeautyEngine.processResult(image:metadata:parameters:)`, run deterministic detection, activate geometry planning, and return output. [CITED: .planning/REQUIREMENTS.md] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] | facade unit/integration | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineTests` or a new focused `BeautyEngineGeometryFacadeTests` filter [VERIFIED: codebase] | Existing file yes; focused geometry facade tests likely Wave 0/new file. [VERIFIED: codebase] |
| GEO-01 | No-op/color/filter/basic-skin still-image paths preserve `.notRun` or `.disabled` and do not trigger detection. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] | regression unit | `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineMetadataCompatibilityTests` [VERIFIED: codebase] | yes [VERIFIED: codebase] |
| GEO-02 | No-face, low-confidence, missing-landmark, detector unavailable, and timeout states degrade with redacted summaries. [CITED: .planning/REQUIREMENTS.md] | detector unit plus facade regression | `swift test --package-path BeautySDK --filter BeautyDetectionTests.VisionFaceDetectorTests` [VERIFIED: codebase] | yes [VERIFIED: codebase] |
| GEO-02 | Selected usable face routes to resolver planning without exposing raw geometry. [CITED: .planning/REQUIREMENTS.md] | effects/facade unit | `swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests` and a focused facade geometry test [VERIFIED: codebase] | effects file yes; facade geometry test likely new. [VERIFIED: codebase] |
| GEO-02 | Missing eye/nose/mouth, stale, reused, and no-face degradation stays group-specific and redacted. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] | effects regression | `swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests` [VERIFIED: codebase] | yes [VERIFIED: codebase] |
| GEO-02 | Active-source scans find no raw landmark/bounding/path/error/image-byte leaks in public/core/facade and relevant Demo surfaces. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] | source scan | `rg -n "VNFaceObservation|boundingBox|landmark|NSError|AVError|/private/var|rawPresetJson|raw JSON|image bytes" BeautySDK/Sources/BeautyCore BeautySDK/Sources/BeautySDK BeautyDemo/BeautyDemo/Camera BeautyDemo/BeautyDemo/Editor \|\| true` [CITED: .planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md] | scan command pattern exists in prior evidence. [CITED: .planning/phases/25-security-distribution-review-and-closeout/25-SECURITY-CLOSEOUT.md] |

### Sampling Rate

- **Per task commit:** Run the narrowest changed-area tests, usually facade geometry tests plus one supporting detector/effects filter. [VERIFIED: codebase]
- **Per wave merge:** Run `swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineTests`, `BeautyEngineMetadataCompatibilityTests`, `VisionFaceDetectorTests`, `FaceSelectionPolicyTests`, `BeautyEffectResolverTests`, and `MissingLandmarkDegradationTests` as applicable. [VERIFIED: codebase]
- **Phase gate:** Run full `swift test --package-path BeautySDK` plus raw-leak scans and, if Demo files changed, focused Demo import/privacy xcodebuild using explicit iOS simulator destination. [CITED: AGENTS.md] [VERIFIED: codebase]

### Wave 0 Gaps

- [ ] Add focused public-facade geometry routing tests if planner chooses not to extend `BeautyEngineTests`; current tests do not prove detector-driven geometry activation through `BeautyEngine.processResult(image:metadata:parameters:)`. [VERIFIED: codebase]
- [ ] Add an internal/SPI test detector seam before facade tests depend on deterministic detection states; current detector injection lives inside `BeautyDetection` tests. [VERIFIED: codebase] [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
- [ ] Add or expose a narrow internal adapter from selected detection result to `FaceGeometry`; current source has internal `BeautyFaceObservation` and internal `FaceGeometry` but no bridge between them in the facade path. [VERIFIED: codebase]

## Security Domain

Security enforcement is enabled because `.planning/config.json` has `"security_enforcement": true`. [VERIFIED: codebase]

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|------------------|
| V2 Authentication | no [ASSUMED] | Phase 26 adds no account, auth, login, or entitlement behavior. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |
| V3 Session Management | no [ASSUMED] | Phase 26 adds no user session, token, or persistence behavior. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |
| V4 Access Control | yes [ASSUMED] | Enforce target/API boundaries: public `BeautySDK` facade only, no Demo internal-target imports, no public raw geometry types. [CITED: ARCHITECTURE.md] [CITED: SECURITY.md] |
| V5 Input Validation | yes [ASSUMED] | Validate images/pixel buffers/parameters before expensive work and keep finite/clamped parameter behavior. [CITED: SECURITY.md] [VERIFIED: codebase] |
| V6 Cryptography | no [ASSUMED] | No cryptography, network, upload, or external resource integrity change is scoped. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |

### Known Threat Patterns for Swift SDK Geometry Routing

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Raw landmark or bounding-box leakage through public result/log/test output | Information Disclosure [ASSUMED] | Public surface limited to `BeautyDetectionSummary`, warning codes/messages, and aggregate numeric metrics; run redaction tests/scans. [CITED: SECURITY.md] [VERIFIED: codebase] |
| Raw framework error/path leakage on detector failure | Information Disclosure [ASSUMED] | Map failures to structured reason codes such as `.detectorUnavailable` or `.detectionTimedOut`; avoid raw `NSError`, `VNError`, and local paths. [CITED: RELIABILITY.md] [VERIFIED: codebase] |
| Unbounded or unnecessary detection work on non-geometry still images | Denial of Service [ASSUMED] | Gate detection on geometry-triggering parameters and preserve cheap paths. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] |
| Demo or host access to internal detection/effects targets | Elevation of Privilege / Information Disclosure [ASSUMED] | Keep Demo facade-only and avoid public/SPI misuse outside tests. [CITED: ARCHITECTURE.md] [VERIFIED: codebase] |
| Overclaiming saved-output completion from routing tests | Integrity [ASSUMED] | Keep renderer cases, PNG evidence, and ledger `implemented` changes out of Phase 26. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] [CITED: .planning/ROADMAP.md] |

## Sources

### Primary (HIGH confidence)

- `AGENTS.md` - repository workflow, root-doc routing, scope, verification, and Xcode destination rules. [CITED: AGENTS.md]
- `.planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md` - locked Phase 26 decisions D-01 through D-16, discretion, deferred ideas, and canonical references. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md]
- `.planning/REQUIREMENTS.md` - GEO-01 and GEO-02 definitions. [CITED: .planning/REQUIREMENTS.md]
- `.planning/ROADMAP.md` - Phase 26/27/28 split and success criteria. [CITED: .planning/ROADMAP.md]
- `.planning/STATE.md` and `PLANS.md` - current v1.5 focus and Phase 26 discussion outcomes. [CITED: .planning/STATE.md] [CITED: PLANS.md]
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `QUALITY_SCORE.md` - SDK boundaries, detection/geometry/privacy/reliability contracts, and current evidence gates. [CITED: ARCHITECTURE.md] [CITED: DESIGN.md] [CITED: SECURITY.md] [CITED: RELIABILITY.md] [CITED: PRODUCT_SENSE.md] [CITED: QUALITY_SCORE.md]
- `BeautySDK/Package.swift` and `BeautySDK/Sources/**` - target dependencies and current facade/detection/effects implementation. [VERIFIED: codebase]
- `BeautySDK/Tests/**` - existing facade, detector, resolver, degradation, redaction, and import-boundary test patterns. [VERIFIED: codebase]

### Secondary (MEDIUM confidence)

- `.planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md`, `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md`, and `.planning/phases/25-security-distribution-review-and-closeout/25-CONTEXT.md` - prior locked constraints around degradation, renderer non-claims, privacy/security scans, and evidence wording. [CITED: .planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md] [CITED: .planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md] [CITED: .planning/phases/25-security-distribution-review-and-closeout/25-CONTEXT.md]
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, `EXAMPLE_IMAGE_VALIDATION.md`, and `shared/IMPLEMENTATION_PRINCIPLES.md` - blueprint status and saved-output evidence rules. [CITED: docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md] [CITED: docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md] [CITED: docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md]

### Tertiary (LOW confidence)

- ASVS category mapping in the Security Domain is marked `[ASSUMED]` because this research did not fetch current OWASP ASVS documentation and uses the GSD template categories only. [ASSUMED]

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - the package uses local SwiftPM targets and no external dependencies; local Swift/Xcode versions were probed. [VERIFIED: codebase] [VERIFIED: local command]
- Architecture: HIGH - target boundaries, current facade path, detector/effects internals, and root contracts were verified from source/docs. [VERIFIED: codebase] [CITED: ARCHITECTURE.md]
- Pitfalls: HIGH - pitfalls derive from locked Phase 26 decisions and existing tests that already guard redaction/degradation behavior. [CITED: .planning/phases/26-geometry-facade-and-landmark-routing-foundation/26-CONTEXT.md] [VERIFIED: codebase]
- Security/ASVS mapping: MEDIUM - project security boundaries are verified, but ASVS category labels are template-level and marked assumed. [CITED: SECURITY.md] [ASSUMED]

**Research date:** 2026-07-06 [VERIFIED: local date]
**Valid until:** 2026-08-05 for codebase-specific planning unless Phase 26/27 source changes land earlier. [ASSUMED]
