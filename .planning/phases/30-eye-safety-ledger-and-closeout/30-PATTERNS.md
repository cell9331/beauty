# Phase 30: Eye Safety, Ledger, and Closeout - Pattern Map

**Mapped:** 2026-07-10  
**Planned files classified:** 29 required or likely files, including 1 conditional shared-fixture edit  
**File-role analogs found:** 29 / 29  
**New behavior without an exact prior analog:** eye-only `.reused` skip while face shape, nose, and mouth retain reuse reduction

## Authoritative Current-State Notes

Current source and tests are the implementation authority. Several current tests and documents describe the behavior that Phase 30 intentionally replaces:

- `BeautyParameters.swift` currently applies `clampSigned` to all four eye fields. Only `eyeSize` and `eyeTailLift` must move to the existing `clampUnit`; the public model stays at 31 stored fields.
- `BeautyEffectResolver.swift` currently applies `capSigned` to all four eye fields and scales every geometry field by `0.5` for `.reused`. Phase 30 must split eye policy from non-eye reuse policy.
- `MissingLandmarkDegradationTests.testReusedLandmarksReduceEyeAndNoseGeometry` and the reused assertions in `testPERF03NoFaceMissingStaleAndReusedGeometryRemainRedactedAndDegraded` are obsolete target assertions, not patterns to preserve.
- `QUALITY_SCORE.md` currently says eyes use reused/stale reduction, and the eye branch docs still say facade output is missing. Phase 29 already proved facade output; Phase 30 must replace those stale statements only after its safety and boundary gates pass.
- Phase 29's renderer source, case inventory, helper, and generated-output policy are already canonical. Phase 30 reruns them unchanged and expects `161/161` outputs and `36/36` comparisons.
- `.planning/codebase/*` remains stale background and is not an implementation analog.

## File Classification

| New/Modified File | Role | Data Flow | Closest Current or Prior-Phase Analog | Match |
| --- | --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` | public model | public input -> normalized parameter snapshot | Existing skin/face-shape `clampUnit` and signed `chinLength` patterns in the same file | exact structural |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | planner/orchestrator | normalized parameters + optional geometry -> effective strengths/domains/warnings/metrics | Existing domain branches and reuse/stale handling in the same file | structural; new eye policy |
| `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` | unit test | abnormal public values -> normalized stored values | `testSDK05NormalizationClampsRangesAndZerosNonFiniteValues` | exact structural |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | unit test | parameter/geometry fixture -> exact effect plan | Existing skin cap warning/count test and geometry-trigger tests | exact structural |
| `BeautySDK/Tests/BeautyEffectsTests/EyeWarpProviderTests.swift` | provider unit test | complete/incomplete eye geometry + effective strengths -> points or skip | Existing missing-left-eye test and direction tests | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | degradation unit test | freshness/landmark variants -> domain continuation/skip metadata | Existing missing eye, reused, stale, and redaction cases | exact structural; assertions change |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | conflict-safety unit test | normal vs multi-domain parameters -> weakened plan | Existing all-domain weakening test; `GeometryConflictResolverTests` signed-pattern reference | exact structural |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | facade integration test | detector fixture + public request -> same-extent redacted result | `testNoFaceGeometryRequestPreservesDimensionsAndRedactedDegradation` | exact |
| `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` | shared test fixture owner, conditional | named `FaceGeometry` fixtures -> provider/resolver test inputs | Existing `.missingLeftEye`, `.reused`, and `.stale` fixtures | exact |
| `.planning/phases/30-eye-safety-ledger-and-closeout/30-EYE-SAFETY-EVIDENCE.md` | evidence artifact | observed commands/tests/scans -> requirement proof | `29-EYE-RENDERER-EVIDENCE.md` and `28-FACE-SHAPE-RENDERER-EVIDENCE.md` | exact role |
| `.planning/phases/30-eye-safety-ledger-and-closeout/30-VERIFICATION.md` | final verification | requirements/decisions + observed gates -> verdict | `29-VERIFICATION.md` | exact |
| `.planning/phases/30-eye-safety-ledger-and-closeout/30-VALIDATION.md` | validation ledger | planned validation rows -> observed pass/fail rows | Existing draft `30-VALIDATION.md`; final form follows `29-VALIDATION.md` | exact |
| `.planning/phases/30-eye-safety-ledger-and-closeout/30-REVIEW.md` | code-review artifact | frozen changed source/tests -> findings and dispositions | `29-REVIEW.md` | exact |
| `.planning/phases/30-eye-safety-ledger-and-closeout/30-SECURITY.md` | threat/security artifact | trust boundaries + scan/test evidence -> threat closure | `29-SECURITY.md` | exact |
| `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` | authoritative second-level ledger | passed evidence -> atomic four-row status transition | Phase 28 six-row face-shape promotion in the same file | exact |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | branch-level ledger | scoped subtool evidence -> branch note, status stays partial | Phase 28 `脸型` branch-partial closeout | exact |
| `docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md` | branch contract | public semantics/dependencies/evidence -> eye branch truth | `features/beauty-shaping/face-shape/README.md` after Phase 28 | exact |
| `docs/meitu-function-blueprint/features/beauty-shaping/README.md` | family contract | scoped eye evidence -> family status summary | Phase 28 face-shape evidence section in the same file | exact |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | output-evidence contract | Phase 29 rerun facts + Phase 30 gates -> durable validation summary | Phase 28 and Phase 29 evidence-summary sections | exact |
| `DESIGN.md` | owning design contract | implemented input/freshness semantics -> parameter and resolver invariants | Face-shape range/evidence and Phase 6 degradation entries | exact role |
| `SECURITY.md` | owning security contract | redaction/boundary evidence -> allowed and forbidden surfaces | Phase 25/26 active-source security evidence sections | exact role |
| `RELIABILITY.md` | owning reliability contract | freshness/skip outcomes -> degradation matrix and warning rules | Phase 27/28 saved-output/degradation sections | exact role |
| `PRODUCT_SENSE.md` | owning product acceptance | scoped behavior/evidence -> acceptance and non-claims | Phase 28 face-shape acceptance section | exact role |
| `QUALITY_SCORE.md` | quality ledger | observed test/renderer/scan results -> score evidence and next work | `3.14 Phase 29 Eye Renderer Output Evidence` | exact |
| `.planning/PROJECT.md` | milestone contract | verified Phase 30 outcome -> v1.6 implementation/verification state | Phase 29 closeout entries | exact |
| `.planning/REQUIREMENTS.md` | requirement ledger | verification links -> EYE-04...08 and DOC-01 completion | EYE-01...03 Phase 29 rows | exact |
| `.planning/ROADMAP.md` | phase ledger | completed plans/criteria -> Phase 30 completion state | Phase 29 completed plan checklist | exact |
| `.planning/STATE.md` | workflow state | completed evidence -> current/next workflow focus | Phase 29 completion notes | exact |
| `PLANS.md` | repository work ledger | exact files/commands/results -> completed work entry | `C-2026-07-09-gsd-execute-phase-29-eye-renderer-output-evidence` | exact |

`ARCHITECTURE.md`, `FRONTEND.md`, `example-images/README.md`, and `example-images/generate_gallery.py` are not normal Phase 30 edits. Add them only if their owned contract or implementation unexpectedly changes. No such change is indicated by current source or research.

## Implementation Patterns

### 1. Public normalization stays in `BeautyParameters`

**Current analog:** `BeautyParameters.swift` lines 107-143 and 183-231.

Use the existing helpers and keep all initializer, decoding, and `normalized()` paths converged through the designated initializer:

```swift
self.eyeSize = Self.clampUnit(eyeSize)
self.eyeDistance = Self.clampSigned(eyeDistance)
self.eyeYPosition = Self.clampSigned(eyeYPosition)
self.eyeTailLift = Self.clampUnit(eyeTailLift)
```

Do not add a new clamp function, property wrapper, public enum, stored field, or secondary validation layer. `normalized()` already reconstructs `BeautyParameters`, so it also re-normalizes values mutated after initialization.

The inventory guard remains the existing test shape:

```swift
let parameters = BeautyParameters()
XCTAssertEqual(Mirror(reflecting: parameters).children.count, 31)
```

Add exact eye matrices beside `testSDK05NormalizationClampsRangesAndZerosNonFiniteValues`:

- finite overflow: size/tail `+2 -> 1`, distance/Y `+2 -> 1` and `-2 -> -1`;
- positive-only negative input: size/tail `-1 -> 0`;
- every field with `.nan`, `.infinity`, and `-.infinity` -> `0`;
- signed distance/Y retain direction.

### 2. Resolver cap families mirror the public ranges

**Current analog:** face-shape cap assignment in `BeautyEffectResolver.swift` lines 74-93 and exact cap warning/count assertions in `BeautyEffectResolverTests.testSkinValuesKeepPublicRangeButResolveToCappedEffectiveStrengths`.

```swift
strengths.eyeSize = capUnit(
    normalized.eyeSize,
    cap: BeautySafetyCaps.eyeSize,
    cappedCount: &cappedCount
)
strengths.eyeDistance = capSigned(
    normalized.eyeDistance,
    cap: BeautySafetyCaps.eyeDistance,
    cappedCount: &cappedCount
)
strengths.eyeYPosition = capSigned(
    normalized.eyeYPosition,
    cap: BeautySafetyCaps.eyeYPosition,
    cappedCount: &cappedCount
)
strengths.eyeTailLift = capUnit(
    normalized.eyeTailLift,
    cap: BeautySafetyCaps.eyeTailLift,
    cappedCount: &cappedCount
)
```

The cap constants remain reference-only: size `0.45`, distance `0.30`, Y position `0.25`, tail lift `0.30`.

A table-driven resolver test should key directly into `BeautyEffectiveStrengths` so zero and wrong-sign results cannot satisfy a relational assertion:

```swift
struct EyeCapCase {
    let name: String
    let parameters: BeautyParameters
    let strength: KeyPath<BeautyEffectiveStrengths, Float>
    let expected: Float
}

for testCase in cases {
    let plan = BeautyEffectResolver.resolve(
        parameters: testCase.parameters,
        faceGeometry: .fixture
    )
    XCTAssertEqual(
        plan.effectiveStrengths[keyPath: testCase.strength],
        testCase.expected,
        accuracy: 0.0001,
        testCase.name
    )
    XCTAssertTrue(plan.activeDomains.contains(.eyes), testCase.name)
    XCTAssertTrue(plan.warnings.contains { $0.code == "beauty_strength_capped" }, testCase.name)
    XCTAssertEqual(plan.metrics["beauty.effects.cappedCount"], 1, testCase.name)
    XCTAssertFalse(plan.warnings.contains { $0.code == "combined_geometry_weakened" }, testCase.name)
}
```

Cases are size `+1 -> +0.45`, distance `+1 -> +0.30` and `-1 -> -0.30`, Y `+1 -> +0.25` and `-1 -> -0.25`, and tail `+1 -> +0.30`.

Negative size/tail and non-finite cases are no-op cases, not cap cases. Assert effective zero, no active or skipped `.eyes`, no `eye_inputs_missing`, no `beauty_strength_capped`, capped count `0`, and `requiresFaceGeometry == false` for negative positive-only input.

### 3. Preserve requested-eye intent before freshness zeroing

**Current integration seam:** `BeautyEffectResolver.swift` lines 95-139 and 209-233.

There is no exact current analog for eye-only reused skipping. Preserve a request boolean after normalization/capping but before any zeroing:

```swift
let hasRequestedEyeValues = anyNonZero(
    strengths.eyeSize,
    strengths.eyeDistance,
    strengths.eyeYPosition,
    strengths.eyeTailLift
)
let hasRequestedNonEyeGeometryValues = anyNonZero(
    strengths.faceSlim,
    strengths.faceSmall,
    strengths.faceVShape,
    strengths.jawSlim,
    strengths.chinLength,
    strengths.noseSlim,
    strengths.noseWingSlim,
    strengths.noseTipSize,
    strengths.noseBridge,
    strengths.mouthSize,
    strengths.mouthWidth,
    strengths.smile
)
```

Then split reuse policy:

```swift
if faceGeometry?.freshness == .reused {
    if hasRequestedNonEyeGeometryValues {
        scaleReusableNonEyeGeometryStrengths(&strengths, by: 0.5)
        metrics["beauty.effects.reusedGeometryScale"] = 0.5
        extraWarnings.append(Self.reusedGeometryWarning)
    }
    if hasRequestedEyeValues {
        zeroEyeStrengths(&strengths)
    }
}
```

The eye-domain branch must use `hasRequestedEyeValues`, not `anyNonZero` over already-zeroed strengths. Apply a single zeroing helper on all eye-specific skip paths:

```swift
private static func zeroEyeStrengths(_ strengths: inout BeautyEffectiveStrengths) {
    strengths.eyeSize = 0
    strengths.eyeDistance = 0
    strengths.eyeYPosition = 0
    strengths.eyeTailLift = 0
}
```

Required state flow:

```text
fresh + both eye groups     -> eyes active, provider points present
fresh + either eye missing  -> eyes skipped, all eye strengths zero, eye_inputs_missing
reused + requested eyes     -> eyes skipped, all eye strengths zero, reused-eye reason
stale + requested eyes      -> eyes skipped, all eye strengths zero, stale-eye reason
reused + non-eye geometry   -> non-eye domains retain 0.5 reduction and geometry_stale_reduced
```

Use stable static warnings in the resolver. Exact reused/stale code names remain planner discretion, but one consistent pattern is:

```swift
private static var reusedEyeSkippedWarning: BeautyValidationWarning {
    BeautyValidationWarning(
        code: "eye_geometry_reused_skipped",
        message: "Eye geometry was skipped because reused eye geometry is not applied."
    )
}

private static var staleEyeSkippedWarning: BeautyValidationWarning {
    BeautyValidationWarning(
        code: "eye_geometry_stale_skipped",
        message: "Eye geometry was skipped because stale eye geometry is not applied."
    )
}
```

Keep `beauty.effects.skippedEyeDomains = 1` as the aggregate metric. Do not encode eye side, landmark names, coordinates, bounds, point counts, or detector details into warning text or metric keys.

### 4. Provider behavior is already correct; extend either-eye evidence

**Current analog:** `EyeWarpProvider.swift` lines 6-10 and `EyeWarpProviderTests.testMissingEyeInputsReturnSkipReason`.

The provider already requires centers for both eyes and returns no points with `eye_inputs_missing`; production provider changes are not indicated. Add the right-eye fixture beside `.missingLeftEye` if the shared extension remains the fixture owner:

```swift
static let missingRightEye = FaceGeometry(
    bounds: fixture.bounds,
    faceContour: fixture.faceContour,
    leftEye: fixture.leftEye,
    rightEye: [],
    nose: fixture.nose,
    outerLips: fixture.outerLips
)
```

Prefer making `.missingLeftEye` equally complete outside its missing group if tests use mouth/lip continuation. Test both fixtures through one loop and assert identical empty-point and reason behavior.

`FaceShapeWarpProviderTests.swift` is a shared fixture owner, not a face-shape behavior target. If the fixture is moved to a dedicated test-support file instead, update every importing effects test in one task; do not duplicate divergent `FaceGeometry.fixture` definitions.

### 5. Degradation tests extend the current matrix but replace reused-eye assertions

**Current analog:** `MissingLandmarkDegradationTests` missing-eye, stale, reused, safe-domain, and `assertRedacted` patterns.

For missing left and missing right, use all four eye fields plus at least nose, color, and filter inputs. Assert:

```swift
XCTAssertFalse(plan.activeDomains.contains(.eyes))
XCTAssertTrue(plan.skippedDomains.contains(.eyes))
XCTAssertTrue(plan.activeDomains.isSuperset(of: [.nose, .color, .filter]))
XCTAssertEqual(plan.effectiveStrengths.eyeSize, 0)
XCTAssertEqual(plan.effectiveStrengths.eyeDistance, 0)
XCTAssertEqual(plan.effectiveStrengths.eyeYPosition, 0)
XCTAssertEqual(plan.effectiveStrengths.eyeTailLift, 0)
XCTAssertEqual(plan.metrics["beauty.effects.skippedEyeDomains"], 1)
XCTAssertTrue(plan.warnings.contains { $0.code == "eye_inputs_missing" })
```

For reused and stale eyes, assert the same domain and four-zero invariants, no `beauty.effects.geometryPointCount` for an eye-only request, and the distinct exact reason for that state. For mixed reused input, preserve the current non-eye contract:

```swift
XCTAssertFalse(plan.activeDomains.contains(.eyes))
XCTAssertTrue(plan.activeDomains.isSuperset(of: [.faceShape, .nose, .mouth]))
XCTAssertEqual(plan.effectiveStrengths.eyeSize, 0)
XCTAssertLessThan(plan.effectiveStrengths.noseSlim, BeautySafetyCaps.noseSlim)
XCTAssertTrue(plan.warnings.contains { $0.code == "geometry_stale_reduced" })
```

Update, rather than coexist with, the two current tests that expect reused eyes to remain active.

### 6. Combined weakening must cross the existing conflict seam

**Current analogs:** `CombinedEffectSafetyTests.testCombinedHighStrengthAllDomainsCapAndWeakenGeometry`, `GeometryConflictResolverTests.testSignedChinLengthCapsAndWeakeningStayScopedToFaceShape`, and `GeometryConflictResolver.swift`.

`GeometryConflictResolver` is invoked by the face-shape and mouth branches, not by an eye-only branch. Pair every eye behavior with both `faceSlim: 1` and `faceSmall: 1`; their capped sum is `1.05`, so the conflict threshold is crossed before adding the eye field.

Per-behavior test flow:

```swift
let normal = BeautyEffectResolver.resolve(
    parameters: eyeParameters,
    faceGeometry: .fixture
)
let combined = BeautyEffectResolver.resolve(
    parameters: eyeAndFaceShapeParameters,
    faceGeometry: .fixture
)

let normalValue = normal.effectiveStrengths[keyPath: testCase.strength]
let combinedValue = combined.effectiveStrengths[keyPath: testCase.strength]

XCTAssertTrue(combined.activeDomains.isSuperset(of: [.eyes, .faceShape]))
XCTAssertEqual(combinedValue.sign, normalValue.sign, testCase.name)
XCTAssertGreaterThan(abs(combinedValue), 0, testCase.name)
XCTAssertLessThan(abs(combinedValue), abs(normalValue), testCase.name)
XCTAssertTrue(combined.warnings.contains { $0.code == "combined_geometry_weakened" })
XCTAssertGreaterThan(combined.metrics["beauty.effects.weakenedCount"] ?? 0, 0)
XCTAssertLessThan(combined.metrics["beauty.effects.geometryStrengthScale"] ?? 1, 1)
```

The six cases mirror Phase 29 exactly: size positive, distance positive/negative, Y positive/negative, and tail positive.

The aggregate case should use all four eye fields plus at least face shape and nose, for example `faceSlim: 1` and `noseSlim: 1`. Because face shape invokes the resolver, the chosen six nonzero geometry fields can support an exact weakened-count assertion of `6`; preserve the chosen signed directions and assert the stable warning and scale.

No production change to `GeometryConflictResolver.swift` is indicated unless these focused tests expose a real defect.

### 7. Public no-face evidence reuses the deterministic facade seam

**Current analog:** `BeautyEngineGeometryFacadeTests.testNoFaceGeometryRequestPreservesDimensionsAndRedactedDegradation` and `testGeometryTriggeredDetectionDegradesAndKeepsSafeDomainsActive`.

Use `SDKTestingFaceDetectionProvider([.noFace])`, an eye request, `brightness`, and a filter. Assert exactly:

- detector invocation count `1`;
- output extent equals input extent;
- detection availability `.noFace`, reason `.noFaceDetected`, used-face count `0`;
- safe active-domain count remains at least `2` for color and filter;
- no geometry-point metric;
- generic `face_effects_skipped_no_face` warning;
- existing `assertRedacted(result)` passes.

This test is facade evidence only. Missing/reused/stale zero-strength and no-point facts belong to resolver/provider tests, so do not add public raw geometry fields merely to observe them.

## Evidence and Boundary Patterns

### Phase 30 evidence artifact

**Closest analog:** `29-EYE-RENDERER-EVIDENCE.md` frontmatter and sections, combined with the safety sections in `28-FACE-SHAPE-RENDERER-EVIDENCE.md`.

Recommended structure for `30-EYE-SAFETY-EVIDENCE.md`:

```markdown
---
phase: 30-eye-safety-ledger-and-closeout
status: in_progress
verified: YYYY-MM-DD
requirements:
  - EYE-04
  - EYE-05
  - EYE-06
---

# Phase 30 Eye Safety Evidence

## Scope
## Requirement Mapping
## Focused Test Evidence
## Input and Cap Matrix
## Degradation Matrix
## Combined-Weakening Matrix
## Phase 29 Renderer Regression
## Active-Source Boundary Results
## Evidence Field Allowlist
## Non-Claims
## Rerun Protocol
```

Task 30-03-01 creates this artifact as `status: in_progress` with EYE-04 through EYE-06 only. Task 30-03-02 adds EYE-07 and sets `status: passed` only after every active-source and classification gate succeeds. Record the observed final full-suite count rather than planning one.

Persist that observed count exactly once as `full_suite_tests: {observed integer}`. Use one shell-safe integer extractor for this canonical line and require the identical value in `30-VERIFICATION.md`, `30-VALIDATION.md`, the bounded Phase 30 `QUALITY_SCORE.md` section, and the bounded Phase 30 `PLANS.md` execution section.

`30-VERIFICATION.md` should follow Phase 29's `Verdict`, `Requirement Coverage`, `Decision Traceability`, `Automated Checks`, `Static Boundary Results`, `Non-Claims`, and `Result` sections. Map all D-01 through D-21 and EYE-04 through EYE-08 plus DOC-01.

Finalize the existing draft `30-VALIDATION.md`; do not replace its task IDs or lose its Wave 0 trace. `30-REVIEW.md` follows the Phase 29 review frontmatter and includes only files actually reviewed. `30-SECURITY.md` follows the Phase 29 trust-boundary/threat-register/accepted-risk/audit-trail format and must end with `status: verified` and `threats_open: 0` before promotion.

### Command-backed regression sequence

Use the focused commands named by the existing validation strategy, then the full gate:

```bash
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyParametersTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyEffectResolverTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.EyeWarpProviderTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.MissingLandmarkDegradationTests
swift test --package-path BeautySDK --filter BeautyEffectsTests.CombinedEffectSafetyTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests
swift test --package-path BeautySDK --filter BeautyCoreTests.BeautyRendererOutputRegressionTests
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 .planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py --input example-images/input --output example-images/output
git ls-files example-images/output example-images/gallery
```

The last command must return no tracked generated files. Gallery generation is not part of the normal Phase 30 gate because gallery logic is unchanged.

### Active-source scan set and commands

Scan explicit shipping roots, not build output, generated images, ignored worktrees, docs, or historical evidence:

```text
BeautySDK/Sources/BeautySDK
BeautySDK/Sources/BeautyCore
BeautySDK/Sources/BeautyDetection
BeautySDK/Sources/BeautyEffects
BeautySDK/Sources/BeautyExampleRenderer/main.swift
BeautyDemo/BeautyDemo
```

The following regexes are pattern definitions, not safe control-flow examples. Executor commands must redirect candidate output and explicitly handle ripgrep status `0` as matches, `1` as no match, and any status greater than `1` as a hard error. The Phase 29 Python helper must likewise redirect first, propagate its own nonzero status, and only display/parse output after success.

Public/SPI raw geometry guard:

```bash
rg -n "public .*FaceGeometry|public .*BeautyFaceObservation|public .*[Ll]andmark|public .*bounding|@_spi.*FaceGeometry|@_spi.*BeautyFaceObservation" \
  BeautySDK/Sources/BeautySDK \
  BeautySDK/Sources/BeautyDetection \
  BeautySDK/Sources/BeautyEffects
```

Demo/renderer internal-target import guard:

```bash
rg -n "^import Beauty(Core|Detection|Effects|Render|Resources)$" \
  BeautyDemo/BeautyDemo \
  BeautyDemo/BeautyDemoTests \
  BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Network and commercial execution-path guards should be API-shaped:

```bash
rg -n "URLSession|NWConnection|^import Network$|uploadTask|downloadTask|https?://" \
  BeautySDK/Sources BeautyDemo/BeautyDemo

rg -n "^import StoreKit$|Product\.products|Transaction\.|purchase\(|subscription|receipt|paywall|entitlement" \
  BeautySDK/Sources BeautyDemo/BeautyDemo
```

Classify every match. A real active-source match is a hard promotion blocker. A broader `VIP|vip` scan is classification evidence only because the Demo already has a static `vipChip`; it is not permission to waive an executable StoreKit/entitlement path.

Keep the 31-field XCTest as the public parameter guard. Also inspect the Phase 30 source diff for declarations beyond the existing four eye fields. Test guard literals and documentation examples are outside the zero-match active-source rule and must be classified rather than reported as leaks.

### Redaction pattern

Reuse the existing `assertRedacted` helpers and expand only if a locked forbidden category is missing. Durable evidence may contain warning codes, aggregate metric names/counts, relative fixture names, dimensions, test names, command text, and pass/fail totals. It must not contain raw landmarks, eye side payloads, coordinates, bounds, control points, detector objects, framework errors, absolute local paths, image bytes, pixel dumps, hashes, or generated PNG baselines.

## Atomic Promotion and Documentation Patterns

### Evidence before status

**Closest analog:** Phase 28 face-shape evidence plan followed by its closeout plan.

The promotion task must depend on passing/clean/verified versions of:

- `30-EYE-SAFETY-EVIDENCE.md`;
- `30-VERIFICATION.md`;
- `30-VALIDATION.md` in `status: in_progress` with every executed row through 30-03 passed and every downstream closeout row pending; final passed/Nyquist status necessarily follows the closeout rows;
- `30-REVIEW.md` with `status: clean`;
- `30-SECURITY.md` with `status: verified` and `threats_open: 0`;
- Phase 29 helper rerun at `161/161` and `36/36`;
- all EYE-07 active-source and public-inventory gates.

If any prerequisite fails, leave all four scoped rows `partial`.

### Ledger row shape

**Closest analog:** the six Phase 28 `脸型` rows already marked `implemented` in `SHAPE_FEATURE_LEDGER.md`.

Update only these four rows in one edit/task:

```markdown
| `眼睛` | 大小 | implemented | Existing positive-only `eyeSize` coverage plus Phase 29 renderer evidence and Phase 30 safety/degradation/boundary evidence. | Complete for the v1.6 scoped SDK slice; broader quality/device review remains separate. |
| `眼睛` | 上下 | implemented | Existing signed `eyeYPosition` coverage plus positive/negative Phase 29 renderer evidence and Phase 30 safety/degradation/boundary evidence. | Complete for the v1.6 scoped SDK slice; broader quality/device review remains separate. |
| `眼睛` | 眼距 | implemented | Existing signed `eyeDistance` coverage plus positive/negative Phase 29 renderer evidence and Phase 30 safety/degradation/boundary evidence. | Complete for the v1.6 scoped SDK slice; broader quality/device review remains separate. |
| `眼睛` | 眼尾上扬 | implemented | Existing positive-only `eyeTailLift` coverage plus Phase 29 renderer evidence and Phase 30 safety/degradation/boundary evidence. | Complete for the v1.6 scoped SDK slice; broader quality/device review remains separate. |
```

Final wording may cite exact Phase 30 filenames, but must not imply the remaining eye tools or branch are implemented.

Read-only atomicity guards:

```bash
test "$(awk -F'|' '$2 ~ /`眼睛`/ && $4 ~ /implemented/ {gsub(/^[ `\t]+|[ `\t]+$/, "", $3); print $3}' docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md | paste -sd, -)" = "大小,上下,眼距,眼尾上扬"

! rg -n '^\| `眼睛` \| (大小|上下|眼距|眼尾上扬) \| partial \|' \
  docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md

rg -n '^\| Beauty shaping \| 眼睛 \| partial \|' \
  docs/meitu-function-blueprint/FEATURE_MATRIX.md
```

The first guard proves both the exact count and exact names because it compares the complete implemented-eye-row list.

### Owning-document update patterns

Historical ledgers and long-lived root documents must be verified through an exact Phase 30 row or an exact Phase 30 heading bounded by the next heading of equal or higher level. For each required file, keep changed-file, owning-invariant, `30-EYE-SAFETY-EVIDENCE.md` link, and no-overclaim checks independent so Phase 28/29 or discussion history cannot satisfy the closeout.

| File | Concrete update pattern after the gate |
| --- | --- |
| `SHAPE_FEATURE_LEDGER.md` | Four rows only; cite Phase 29 visible-output plus Phase 30 safety/degradation/boundary evidence. Keep all other eye rows unchanged. |
| `FEATURE_MATRIX.md` | Keep `Beauty shaping | 眼睛 | partial`; state four implemented subtools and list future gaps. Replace the stale claim that facade output is still missing. |
| `features/beauty-shaping/eyes/README.md` | State size/tail positive-only, distance/Y signed; both eyes required; missing/reused/stale skip the eye domain; four subtools implemented; branch partial; raw eye geometry remains private. |
| `features/beauty-shaping/README.md` | Add a Phase 30 eye evidence section parallel to the Phase 28 face-shape section; retain family and eye branch partial. |
| `EXAMPLE_IMAGE_VALIDATION.md` | Add Phase 30 closeout summary and evidence links; keep the 23 cases, 7 fixtures, 161 outputs, and 36 comparisons unchanged. |
| `DESIGN.md` | Replace the `Eyes | ... | mixed` range with explicit size/tail unit and distance/Y signed ranges; record missing/reused/stale eye skip and exact aggregate evidence contract. |
| `RELIABILITY.md` | Replace global “reused landmarks reduce geometry” wording with the eye exception: eyes skip reused/stale; face shape/nose/mouth retain reused reduction. Record distinct stable eye reasons. |
| `SECURITY.md` | Add Phase 30 input validation, redaction, active-source boundary, public-inventory, and zero-open-threat evidence. |
| `PRODUCT_SENSE.md` | Add acceptance for the scoped four rows and explicit no-claims for whole-branch, quality/device, parity, commercial, and readiness status. |
| `QUALITY_SCORE.md` | Add a Phase 30 evidence section with observed counts; correct the Eyes row from reused reduction to reused/stale skip; retain future eye-tool limitations. |
| `.planning/PROJECT.md` | Mark the existing-parameter eye slice verified without changing SDK-only/no-public-expansion boundaries. |
| `.planning/REQUIREMENTS.md` | Check EYE-04 through EYE-08 and DOC-01 only with Phase 30 verification/evidence links; update traceability rows from Pending to Complete. |
| `.planning/ROADMAP.md` | Mark Phase 30 status/plans/success criteria complete from observed evidence. |
| `.planning/STATE.md` | Record completion, evidence facts, and the next workflow state; remove stale “ready to discuss” routing. |
| `PLANS.md` | Add one Completed entry with Scope, Requirements, Files, Verification, Build, Commit, Outcome, and Next step. Record any unrun Demo build explicitly as unnecessary because Demo source stayed unchanged. |

Do not copy full evidence tables into every contract. Each owning document should state its invariant and link to Phase 30 evidence; `30-EYE-SAFETY-EVIDENCE.md` and `30-VERIFICATION.md` own detailed commands/results.

## Ownership and Concurrency

| Work Unit | Primary Ownership | Overlap / Ordering Rule |
| --- | --- | --- |
| Public semantics and exact caps | `BeautyParameters.swift`, resolver cap lines, `BeautyParametersTests`, `BeautyEffectResolverTests` | Must precede degradation work because `BeautyEffectResolver.swift` is shared. |
| Eye degradation and combined weakening | Resolver freshness/domain lines plus provider/degradation/combined/facade tests | Depends on public semantics. Do not run a second writer against `BeautyEffectResolver.swift`. |
| Shared right-eye fixture | `FaceShapeWarpProviderTests.swift` extension or one dedicated shared test-support file | Single owner; provider and degradation tests consume it. Avoid duplicate fixture declarations. |
| Review and security | `30-REVIEW.md` and `30-SECURITY.md` | May be produced in parallel only after source/tests are frozen; they write distinct files. |
| Evidence and promotion-ready verification | `30-EYE-SAFETY-EVIDENCE.md`, `30-VERIFICATION.md`, in-progress `30-VALIDATION.md` | Consume the same frozen command results. Wave 3 closes only executed rows; final verification/validation belongs to the last GSD/work closeout. |
| Renderer/helper regression | Existing renderer and Phase 29 helper; generated `example-images/output/` | Runtime writes only to ignored output. Serialize with any other renderer/gallery run; do not edit or commit generated PNGs. |
| Atomic ledger promotion | `SHAPE_FEATURE_LEDGER.md` | One owner and one gated edit after all evidence passes. No independent row promotion. |
| Blueprint closeout | Five blueprint/status docs | Keep with the atomic promotion plan; verify each file independently. |
| Root contract closeout | `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, Phase security | Run after promotion as a dependent plan with per-file invariant/privacy/no-overclaim gates. |
| Quality/project closeout | `QUALITY_SCORE.md`, `.planning/PROJECT.md` | Run after root contracts as a small dependent plan using observed evidence only. |
| Final GSD/work closeout | `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md`, final verification/validation | One final consistency owner after every document gate; record the observed count and explicit no-Demo-build rationale. |

Recommended dependency chain:

```text
public normalization/caps
  -> eye degradation + combined/facade tests
  -> full evidence + review + security + boundary gate
  -> atomic four-row promotion + five blueprint owners
  -> root design/security/reliability/product contracts
  -> quality + project contracts
  -> final requirements/roadmap/state/work/verification/validation closeout
```

## Reference-Only Surfaces

| File/Surface | Reuse | Expected Action |
| --- | --- | --- |
| `BeautySafetyCaps.swift` and `BeautySafetyCapsTests.swift` | Exact four eye constants already exist and are covered. | Run/reference; do not change constants. |
| `EyeWarpProvider.swift` | Both-eye guard, positive size/tail output, signed distance/Y output. | Test both missing sides; production edit only if a focused test finds a real gap. |
| `GeometryConflictResolver.swift` | Includes all eye strengths in total, weakening, warning, and aggregate metrics. | Exercise through resolver tests; no planned math change. |
| `BeautyEngine.swift` and `BeautyEngineGeometryDetection.swift` | Public facade, detection trigger, selected-face routing, redacted result. | Use existing testing SPI seam; no planned production change. |
| `BeautyGeometryEffectPipeline.swift` | Aggregates internal control points. | Assert result metrics/plan behavior; do not expose points publicly. |
| `BeautyExampleRenderer/main.swift` | Canonical 23-case public-facade renderer. | Build/run unchanged. |
| `BeautyRendererOutputRegressionTests.swift` | Locks renderer inventory and internal-import boundary. | Rerun unchanged unless an unexpected regression requires correction. |
| `check_eye_renderer_outputs.py` | Canonical 161/161 and 36/36 helper. | Rerun unchanged; do not fork a Phase 30 helper. |
| `example-images/generate_gallery.py` and `example-images/README.md` | Existing ignored gallery/output contract. | No edit or gallery rerun unless gallery logic changes. |

## No Exact Behavioral Analog

Every planned file role has a close analog, but the combined resolver rule “eyes skip on `.reused` while face shape, nose, and mouth remain reduced” is new. Implement it at the existing resolver freshness seam, lock it with replacement tests, and document it as a narrow eye exception. Do not generalize it into a new freshness model or a global skip policy.

## Metadata

**Analog search scope:** current `BeautySDK/Sources`, focused `BeautySDK/Tests`, Phase 28/29 artifacts and plans, blueprint ledgers, root contracts, and current planning ledgers.  
**Authority order applied:** source/tests > `PLANS.md` > current contracts/planning > historical phase docs > stale codebase maps.  
**Pattern extraction date:** 2026-07-10
