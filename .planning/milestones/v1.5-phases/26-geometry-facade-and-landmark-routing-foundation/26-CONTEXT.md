# Phase 26: Geometry Facade and Landmark Routing Foundation - Context

**Gathered:** 2026-07-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 26 makes public `BeautySDK` still-image processing capable of activating geometry render intent from detection and landmarks through `BeautyEngine.processResult(...)`, while keeping raw face geometry private. It covers `GEO-01` and `GEO-02`.

This is a facade and routing foundation phase. It should connect geometry-triggering parameters to detection, selected-face landmark routing, internal geometry planning, and redacted public result evidence. It must prove that geometry intent can be activated through the public facade, but it must not claim saved-image geometry output completion.

Phase 26 must not add SwiftUI or Demo UI work, new public `BeautyParameters`, new public landmark/bounding/control-point APIs, new `BeautyExampleRenderer` geometry cases, network/cloud behavior, raw landmark persistence, raw diagnostic logging, or implementation-status changes for `脸型` tools. Saved-output geometry evidence belongs to Phase 27, and `脸型` tool completion belongs to Phase 28.

</domain>

<decisions>
## Implementation Decisions

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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Workflow and Project State
- `AGENTS.md` - Repository reading order, task routing, verification, and record rules.
- `PLANS.md` - Work ledger and requirement to record verifiable changes.
- `.planning/PROJECT.md` - Defines v1.5 as SDK geometry output foundation plus the `脸型` existing-parameter slice, with no UI/product breadth expansion.
- `.planning/REQUIREMENTS.md` - Defines `GEO-01` and `GEO-02` for Phase 26, plus downstream `GEO-03`/`GEO-04` and `FACE-*` boundaries.
- `.planning/ROADMAP.md` - Defines Phase 26 goal, success criteria, and no dependencies.
- `.planning/STATE.md` - Records current focus as Phase 26.
- `.planning/phases/25-security-distribution-review-and-closeout/25-CONTEXT.md` - Locks local-first privacy, raw-leak scan boundaries, and conservative evidence wording.
- `.planning/phases/24-renderer-output-regression-hardening/24-CONTEXT.md` - Locks renderer matrix ownership, no new renderer cases by default, generated-output policy, and geometry saved-output deferral.
- `.planning/phases/23-performance-and-reliability-gates/23-CONTEXT.md` - Locks degradation, redacted metrics, reset, stale/reused geometry, and no release-grade overclaim rules.

### Root Contracts
- `ARCHITECTURE.md` - Owns target dependency direction, public `BeautySDK` facade, internal detection/effects/render boundaries, and no UI in SDK targets.
- `DESIGN.md` - Owns `BeautyInputMetadata`, `BeautyDetectionSummary`, internal detection/geometry models, coordinate model, geometry state machine, and degradation contracts.
- `SECURITY.md` - Owns local-first privacy, face landmark/bounding box sensitivity, public summary privacy, logging/metric redaction, and no raw geometry leakage.
- `RELIABILITY.md` - Owns typed errors, degrade-before-fail behavior, detection degradation matrix, metrics/log redaction, and reset/recovery rules.
- `PRODUCT_SENSE.md` - Owns SDK integration acceptance, detection/coordinate acceptance, geometry-heavy branch evidence requirements, and anti-overclaim constraints.
- `QUALITY_SCORE.md` - Records current quality/security evidence and active scan patterns; current source/root docs override stale `.planning/codebase/*` maps.

### Blueprint and Evidence Contracts
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` - Defines current renderer case matrix and states geometry saved-output remains unavailable until public facade detection plus geometry rendering produce saved outputs.
- `docs/meitu-function-blueprint/FEATURE_MATRIX.md` - Defines branch-level `implemented`, `partial`, `blocked-by-geometry-output`, and `future` statuses.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` - Owns second-level `美型 / 五官` tool status and prevents marking provider-only or routing-only evidence as implemented.
- `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md` - Defines the evidence ladder and SDK-core/no-UI principles for beauty-shaping work.
- `docs/meitu-function-blueprint/features/beauty-shaping/README.md` - Defines geometry branch ownership, dependencies, and facade-visible output expectation.

### Current Code and Test Surfaces
- `BeautySDK/Package.swift` - Declares internal target dependencies and confirms `BeautySDK` can depend on detection/effects/render while `BeautyExampleRenderer` depends only on the public facade.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` - Current public facade processing path; presently ignores metadata and resolves parameters without face geometry.
- `BeautySDK/Sources/BeautySDK/BeautySDK.swift` - Public facade export surface and SPI testing aliases.
- `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift` - Owns `enableFaceTracking`, `maximumFaceCount`, detection cadence, quality, and debug/log configuration.
- `BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift` - Owns public per-input orientation, mirror, source, and timestamp metadata.
- `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift` - Owns the geometry-free public detection summary shape.
- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` - Owns public output, warnings, metrics, and detection summary.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` - Current internal detector, injectable observation provider, selection, summary, and redacted failure behavior.
- `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift` - Current internal observation and landmark group availability model.
- `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift` - Current orientation/mirroring coordinate mapping utility.
- `BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift` - Deterministic selected-face policy and public-safe summary counts.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` - Existing resolver path with internal `faceGeometry`, active/skipped domains, caps, reused/stale handling, warnings, and metrics.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` - Current geometry control-point aggregation and MVP proxy evidence helper.
- `BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift` - Internal `FaceGeometry`, freshness, bounds, and control-point model.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineTests.swift` - Existing facade output, warning, metric, redaction, and reset test patterns.
- `BeautySDK/Tests/BeautyCoreTests/BeautyEngineMetadataCompatibilityTests.swift` - Existing compatibility tests for metadata-aware APIs and `.notRun`/`.disabled` summaries.
- `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift` - Existing detector summary, failure, no-face, low-confidence, and missing-landmark evidence.
- `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` - Existing resolver evidence for active/skipped domains and redacted metrics.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` - Existing no-face, missing-landmark, stale, reused, and redacted degradation evidence.
- `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift` - Existing public facade import and API exposure evidence.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `VisionFaceDetector` already has an injectable `ObservationProvider` and returns redacted `BeautyDetectionSummary`, making it a natural basis for deterministic internal/SPI facade tests.
- `FaceSelectionPolicy` already selects deterministic faces and emits public-safe face counts, which supports the single selected-face Phase 26 route.
- `CoordinateMapper` already maps Vision-normalized rectangles into canonical image-normalized coordinates using `BeautyInputMetadata` orientation and mirror inputs.
- `BeautyEffectResolver.resolve(parameters:faceGeometry:)` already activates geometry domains, caps strengths, handles missing/stale/reused geometry, and emits redacted warnings/metrics when internal geometry is present.
- `BeautyGeometryEffectPipeline.controlPoints(...)` already aggregates existing face, chin, eye, nose, and mouth provider control-point intent for tests.
- Existing tests cover metadata compatibility, detector degradation summaries, resolver no-face/missing/stale/reused behavior, and redaction assertions that Phase 26 can extend.

### Established Patterns
- Public `BeautySDK` APIs expose processed output, warnings, metrics, and `BeautyDetectionSummary`; they must not expose internal detection observations, landmark coordinates, bounding boxes, or control points.
- Geometry-heavy docs remain below `implemented` until public facade saved-image evidence exists. Provider/resolver/routing evidence is foundation evidence, not visual completion.
- Current source, root contracts, and `.planning` ledgers override stale `.planning/codebase/*` maps, which still describe an older pre-SDK tree.
- Evidence wording should stay conservative: current-environment pass/fail/blocker facts, no commercial quality, no release readiness, and no full Meitu parity claims.

### Integration Points
- `BeautyEngine.processResult(image:metadata:parameters:)` is the primary Phase 26 integration point because `GEO-01` targets still-image public facade processing.
- `BeautyEngine.processResult(pixelBuffer:metadata:parameters:)` should preserve current compatibility unless planning deliberately scopes parity tests; realtime saved-output evidence is not Phase 26's core target.
- `BeautySDK` target can integrate internal `BeautyDetection` and `BeautyEffects` while keeping `BeautyExampleRenderer` and `BeautyDemo` facade-only.
- Verification should include focused `swift test --package-path BeautySDK` filters for facade/detection/effects plus scoped raw-leak scans. Full SDK test pass is useful if local time/tooling permits.

</code_context>

<specifics>
## Specific Ideas

- Use geometry-triggering parameters as the switch for still-image detection, not `enableFaceTracking` alone.
- Keep the first routing foundation single-face and internal-only.
- Let Phase 26 prove geometry intent and redacted routing evidence; let Phase 27 prove saved PNG geometry output.
- Keep `SHAPE_FEATURE_LEDGER.md` rows as `partial` until Phase 28 can attach tool-specific saved-output evidence.

</specifics>

<deferred>
## Deferred Ideas

- Full multi-face geometry routing is deferred until after the first single selected-face facade route is proven.
- Full production-grade Vision landmark point extraction can be refined after the minimal deterministic adapter proves routing.
- `BeautyExampleRenderer` geometry cases, generated PNG evidence, and renderer invariant updates belong to Phase 27.
- `脸型` second-level tool implementation status changes belong to Phase 28 after saved-output evidence exists.
- Public debug geometry-lite data, face tokens, coordinates, bounding boxes, landmarks, control points, and detailed per-domain point structure remain out of scope.

</deferred>

---

*Phase: 26-Geometry Facade and Landmark Routing Foundation*
*Context gathered: 2026-07-06*
