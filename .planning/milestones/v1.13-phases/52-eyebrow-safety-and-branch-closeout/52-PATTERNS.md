# Phase 52: Eyebrow Safety and Branch Closeout - Pattern Map

**Mapped:** 2026-07-27
**Files analyzed:** 31 new/modified surfaces
**Analogs found:** 31 / 31

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | config | transform | same file's finalized face/eye cap blocks; archived Phase 48 cap freeze | exact |
| `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift` | provider | transform | existing seven-field implementation plus `BeautySafetyCaps` use in other providers | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautySafetyCapsTests.swift` | test | transform | existing cap tables; Phase 44/48 exact-cap matrices | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift` | test | request-response | existing cap/accounting tests; Phase 44/48 resolver matrices | exact |
| `BeautySDK/Tests/BeautyEffectsTests/EyebrowWarpProviderTests.swift` | test | transform | existing named provider tests; Phase 48 provider safety matrix | exact |
| `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` | test | event-driven lifecycle | existing `testBROW07...`; Phase 48 nine-field descriptor | exact |
| `BeautySDK/Tests/BeautyEffectsTests/GeometryConflictResolverTests.swift` | test | transform/accounting | existing 44-field `13.45` oracle | exact |
| `BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift` | test | transform/accounting | existing `testBROW06...` final-mask equality | exact |
| `BeautySDK/Tests/BeautyEffectsTests/BeautyGeometryEffectPipelineTests.swift` | test | transform/dispatch | existing unified provider-order tests | exact |
| `BeautySDK/Tests/BeautyCoreTests/BeautyEngineGeometryFacadeTests.swift` | test | request-response | existing eyebrow facade/redaction tests | exact |
| `.planning/phases/52-eyebrow-safety-and-branch-closeout/check_eyebrow_safety_boundaries.py` | utility | batch/file-I/O | archived Phase 48 `check_face_safety_boundaries.py` | exact |
| `52-EYEBROW-SAFETY-EVIDENCE.md` | evidence ledger | batch record | archived `48-FACE-SAFETY-EVIDENCE.md` | exact |
| `52-SECURITY.md` | security record | batch record | archived `48-SECURITY.md` | exact |
| `52-VALIDATION.md` | validation ledger | batch record | current draft plus archived `48-VALIDATION.md` | exact |
| `52-REVIEW.md` | review record | batch record | archived Phase 48 review artifact | role-match |
| `52-VERIFICATION.md` | verification record | batch aggregation | archived Phase 48 verification artifact | exact |
| `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` | product owner | documentation transaction | archived Phase 44/48 row promotions | exact |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` | product owner | documentation transaction | archived Phase 44/48 branch promotions | exact |
| `docs/meitu-function-blueprint/features/beauty-shaping/eyebrows/README.md` | product owner | documentation transaction | archived eye/face feature README promotions | exact |
| `docs/meitu-function-blueprint/features/beauty-shaping/README.md` | product owner | documentation transaction | archived parent shaping README promotions | exact |
| `EXAMPLE_IMAGE_VALIDATION.md`, `example-images/README.md` | evidence owner | documentation | Phase 51 exact output/gallery closeout; Phase 48 owner sync | exact |
| `ARCHITECTURE.md`, `DESIGN.md` | contract owner | documentation | Phase 48 routed owner sync | exact |
| `SECURITY.md`, `RELIABILITY.md` | risk/reliability owner | documentation | Phase 48 routed owner sync | exact |
| `PRODUCT_SENSE.md`, `QUALITY_SCORE.md` | product/quality owner | documentation | Phase 48 routed owner sync | exact |
| `PLANS.md`, `.planning/PROJECT.md` | planning owner | documentation | Phase 48 Plan 06 closeout | exact |
| `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md` | planning owner | documentation | Phase 48 Plan 06 closeout | exact |

No new package target, public type, renderer, fixture, dependency, Demo surface, model/resource, network path, or generated media file belongs in this phase.

## Pattern Assignments

### `BeautySafetyCaps.swift` and `EyebrowWarpProvider.swift` (config/provider, transform)

**Analogs:** existing eyebrow route, then the archived Phase 48 rule “retain exact constants; replace provisional ownership wording only after tests pass.”

**Single cap-owner pattern** (`BeautySafetyCaps.swift` lines 37-44):

```swift
// Provisional Phase 50 eyebrow caps; Phase 52 owns final calibration.
static let eyebrowYPosition: Float = 0.25
static let eyebrowThickness: Float = 0.25
static let eyebrowLength: Float = 0.25
static let eyebrowSpacing: Float = 0.25
static let eyebrowHeadSpacing: Float = 0.25
static let eyebrowTilt: Float = 0.25
static let eyebrowPeakDefinition: Float = 0.25
```

Freeze these values and finalise the comment. Replace the provider-local `provisionalCap` at `EyebrowWarpProvider.swift:32` and every formula/maximum check with the corresponding named cap; do not introduce a generic renderer range.

**Named emission and field-local sanitization pattern** (`EyebrowWarpProvider.swift` lines 13-27):

```swift
var points: [WarpControlPoint] {
    eyebrowYPosition + eyebrowThickness + eyebrowLength + eyebrowSpacing +
        eyebrowHeadSpacing + eyebrowTilt + eyebrowPeakDefinition
}

func sanitizing(_ strengths: BeautyEffectiveStrengths) -> BeautyEffectiveStrengths {
    var sanitized = strengths
    if strengths.eyebrowYPosition != 0, eyebrowYPosition.isEmpty { sanitized.eyebrowYPosition = 0 }
    // Repeat by named field; never zero the whole eyebrow domain.
    if strengths.eyebrowPeakDefinition != 0, eyebrowPeakDefinition.isEmpty { sanitized.eyebrowPeakDefinition = 0 }
    return sanitized
}
```

**Dead-zone, bounds, and redacted failure pattern** (`EyebrowWarpProvider.swift` lines 35-45, 226-241, 278-280):

```swift
let requestedWork = strengths.contains {
    $0.isFinite && abs($0) > Float.ulpOfOne
}
return WarpControlPointResult(
    points: emissions.points,
    skipReason: requestedWork && emissions.points.isEmpty ? "eyebrow_inputs_missing" : nil
)

guard radius.isFinite, radius > epsilon, radius <= 1,
      strength.isFinite, strength > Float.ulpOfOne, strength <= fieldCap,
      sources.indices.allSatisfy({ isUnitPoint(sources[$0]) && isUnitPoint(targets[$0]) })
else { return [] }
```

Keep six signed predicates as `abs(strength) > Float.ulpOfOne && abs(strength) <= cap`; peak is positive-only and requires `strength > Float.ulpOfOne && strength <= BeautySafetyCaps.eyebrowPeakDefinition`.

---

### Cap, resolver, and provider test files (tests, transform/request-response)

**Files:** `BeautySafetyCapsTests.swift`, `BeautyEffectResolverTests.swift`, `EyebrowWarpProviderTests.swift`.

**Analog:** Phase 44/48 table-driven exact-cap contract and the current resolver route (`BeautyEffectResolver.swift` lines 159-165):

```swift
strengths.eyebrowYPosition = capSigned(
    normalized.eyebrowYPosition,
    cap: BeautySafetyCaps.eyebrowYPosition,
    cappedCount: &cappedCount
)
// five more signed rows
strengths.eyebrowPeakDefinition = capUnit(
    normalized.eyebrowPeakDefinition,
    cap: BeautySafetyCaps.eyebrowPeakDefinition,
    cappedCount: &cappedCount
)
```

Copy the archived closeout matrix shape: one seven-row inventory, exactly seven unique names, constructor/key path/emission accessor/semantics/cap/reused/radius/unavailable fixture. Drive zero, `±Float.ulpOfOne`, first meaningful magnitude above the geometric epsilon, exact cap, overflow, NaN, and infinities from it. Exact cap has capped count zero; overflow has effective `0.25`, capped count one, and exactly one aggregate `beauty_strength_capped` warning.

`EyebrowWarpProviderTests.swift` lines 127-161 are the closest prerequisite/direction analog: whole spacing is pair-only, per-side arrays continue, tilt compares both signs, and peak requires an interior apex and rejects negative input.

---

### `MissingLandmarkDegradationTests.swift` and `BeautyEngineGeometryFacadeTests.swift` (tests, lifecycle/request-response)

**Analog:** current eyebrow stateless sequence (`MissingLandmarkDegradationTests.swift` lines 1115-1146):

```swift
let fresh = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: freshFace)
let reused = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: reusedFace)
let stale = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: staleFace)
let missing = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: missingFace)
let noFace = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: nil)
let freshAgain = BeautyEffectResolver.resolve(parameters: allEyebrows, faceGeometry: freshFace)

for (keyPath, expected) in zip(keyPaths, [-0.125, 0.125, -0.125, 0.125, -0.125, 0.125, 0.125]) {
    XCTAssertEqual(reused.effectiveStrengths[keyPath: keyPath], Float(expected))
    XCTAssertEqual(stale.effectiveStrengths[keyPath: keyPath], 0)
    XCTAssertEqual(missing.effectiveStrengths[keyPath: keyPath], 0)
    XCTAssertEqual(noFace.effectiveStrengths[keyPath: keyPath], 0)
    XCTAssertEqual(freshAgain.effectiveStrengths[keyPath: keyPath],
                   fresh.effectiveStrengths[keyPath: keyPath])
}
XCTAssertEqual(reused.metrics["beauty.effects.reusedGeometryScale"], 0.5)
```

Extend this through the shared seven-row descriptor instead of creating a second inventory. Cover fresh, reused, stale, no-face, narrow missing, malformed, provider-empty, positive→negative, negative→positive, valid→invalid→valid, sibling continuation, and unrelated face/eye/nose/mouth/color/filter continuation. Facade assertions should copy its existing aggregate-redaction helpers (lines 924-976): forbid side names, endpoints, centers, apexes, axes, coordinates, support arrays, provider names, and image bytes while keeping output extent stable.

---

### Convergence and dispatch test files (tests, transform/accounting)

**Files:** `GeometryConflictResolverTests.swift`, `CombinedEffectSafetyTests.swift`, `BeautyGeometryEffectPipelineTests.swift`.

**Exact arithmetic analog** (`GeometryConflictResolverTests.swift` lines 250-308):

```swift
let rows = Array(faceAndEyeRows) + eyebrowRows + Array(noseAndMouthRows)
let expectedTotal = Float(rows.reduce(0.0) { $0 + Double(abs($1.unscaled)) })
let expectedScale: Float = 1 / expectedTotal

XCTAssertEqual(rows.count, 44)
XCTAssertEqual(Set(rows.map(\.name)).count, 44)
XCTAssertEqual(expectedTotal, 13.45, accuracy: 0.000_001)
XCTAssertEqual(resolved.metrics["beauty.effects.weakenedCount"], 44)
XCTAssertEqual(resolved.metrics["beauty.effects.geometryStrengthScale"] ?? 0,
               Double(expectedScale), accuracy: 0.000_000_1)
XCTAssertEqual(resolved.warnings.map(\.code), ["combined_geometry_weakened"])
XCTAssertEqual(resolved.strengths.geometryTotal, 1, accuracy: 0.000_001)
```

Preserve the domain subtotals `3.35 + 4.10 + 1.75 + 1.80 + 2.45`, signs, and stable 9/14/7/6/8 ordering. Rename provisional test vocabulary only after final evidence.

**One-baseline convergence analog** (`BeautyEffectResolver.swift` lines 615-647):

```swift
var retainedBaseline = strengths
for _ in 0..<44 {
    let resolution = GeometryConflictResolver().resolve(strengths: retainedBaseline)
    var nextBaseline = faceProvider.fieldEmissions(
        face: faceGeometry, strengths: resolution.strengths
    ).sanitizing(retainedBaseline)
    // Chin -> Eye -> Eyebrow -> Nose -> Mouth
    if nextBaseline == retainedBaseline { return resolution }
    retainedBaseline = nextBaseline
}
return GeometryConflictResolver().resolve(strengths: retainedBaseline)
```

Do not add a second conflict pass, scale an already scaled baseline, permit re-entry, or increase the 44-removal bound.

**Final-mask/dispatch equality analog** (`CombinedEffectSafetyTests.swift` lines 81-170):

```swift
var sanitized = faceEmissions.sanitizing(plan.effectiveStrengths)
sanitized = chinEmissions.sanitizing(sanitized)
sanitized = eyeEmissions.sanitizing(sanitized)
sanitized = eyebrowEmissions.sanitizing(sanitized)
sanitized = noseEmissions.sanitizing(sanitized)
sanitized = mouthEmissions.sanitizing(sanitized)
XCTAssertEqual(sanitized, plan.effectiveStrengths)

let expectedPoints =
    faceEmissions.points + chinEmissions.points + eyeEmissions.points +
    eyebrowEmissions.points + noseEmissions.points + mouthEmissions.points
XCTAssertEqual(BeautyGeometryEffectPipeline.controlPoints(
    for: plan.effectiveStrengths, face: face
), expectedPoints)
```

Extend this exact oracle with late eyebrow provider-empty loss, pair-only loss, per-side continuation, reused input, and mixed signed domains. Metrics, final nonzero strengths, nonempty named arrays, point count, and unified dispatch must all derive from the same mask.

---

### `check_eyebrow_safety_boundaries.py` (utility, batch/file-I/O)

**Analog:** `.planning/milestones/v1.12-phases/48-face-safety-and-scoped-closeout/check_face_safety_boundaries.py`.

**Fail-closed command and path pattern** (lines 111-150):

```python
def run(command, root):
    try:
        return subprocess.run(list(command), cwd=root, text=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              check=False)
    except OSError as error:
        return subprocess.CompletedProcess(command, 127, "", str(error))

def safe_path(root, relative, *, directory=False):
    relative_path = Path(relative)
    if relative_path.is_absolute() or ".." in relative_path.parts:
        raise RuntimeError("unsafe repository-relative path")
    # reject symlinks, missing/non-regular targets, and repository escape
```

**Exact active-source and final-source pattern** (lines 180-214):

```python
completed = runner(command, root)
if completed.returncode not in (0, 1):
    return Result("eyebrow active-source ownership", False,
                  f"command_error={completed.returncode}")
observed = {line.strip() for line in completed.stdout.splitlines() if line.strip()}
ok = completed.returncode == 0 and observed == SOURCE_EYEBROW_OWNERS

for field in FIELD_TOKENS:
    if len(re.findall(rf"static let {field}: Float = 0\.25\b", caps)) != 1:
        failures.append(f"{field}:cap")
if "provisional" in active_source.lower():
    failures.append("provisional-wording")
if resolver.count("0..<44") != 1:
    failures.append("convergence-loop")
```

**Mode pattern** (lines 544-578): retain `--self-test`, default pre-promotion, `--check-promotion`, `--check-owners [--owner]`, and final/allow-promotion behavior. Every exception, tool error, unclassified match, owner mismatch, premature promotion, missing evidence, artifact drift, or lifecycle overclaim returns nonzero. Add at least one adversarial mutation per failure branch; do not copy an old self-test count.

Compose the Phase 49/50 classified source/privacy checks and invoke Phase 51 strict/gallery machinery unchanged. Do not duplicate or recalibrate their output logic.

---

### Evidence, security, review, validation, and verification artifacts (records, batch aggregation)

**Analogs:** archived Phase 48 evidence/security/validation/verification and current `52-VALIDATION.md`.

- `52-EYEBROW-SAFETY-EVIDENCE.md`: requirement-named commands, fresh result counts, dates, artifact containment, unchanged Phase 51 output vocabulary, and no inferred pass.
- `52-SECURITY.md`: Phase 52 STRIDE/ASVS L1 register; promotion requires `threats_open: 0`.
- `52-REVIEW.md`: standard review result and unresolved severity counts.
- `52-VALIDATION.md`: update Wave 0, task rows, and `nyquist_compliant` only from real evidence.
- `52-VERIFICATION.md`: goal-backward SAFE-01..03/DOC-01 verdict plus explicit audit/archive/tag/cleanup handoff.

Use repository-relative links and exact command/result facts. Never copy predecessor result counts as Phase 52 evidence.

---

### Four blueprint owners (product owners, documentation transaction)

**Analogs:** archived Phase 44 Plan 04 and Phase 48 Plan 04.

Run the default pre-promotion checker immediately before one atomic patch. Touch only:

1. `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`
2. `docs/meitu-function-blueprint/FEATURE_MATRIX.md`
3. `docs/meitu-function-blueprint/features/beauty-shaping/eyebrows/README.md`
4. `docs/meitu-function-blueprint/features/beauty-shaping/README.md`

Promote exactly `上下`, `粗细`, `长短`, `间距`, `眉头间距`, `倾斜`, and `眉峰`, then branch `眉毛`, at SDK-core scope. Cite Phase 49 support, Phase 50 provider/pipeline, Phase 51 output, and Phase 52 safety. Preserve all v1.14-v1.16 and UI/device/commercial/performance/packaging/shipping/launch nonclaims. Run post-promotion mode immediately.

---

### Example, root, and planning owners (documentation)

**Analogs:** archived Phase 48 Plans 05-06.

- `EXAMPLE_IMAGE_VALIDATION.md` and `example-images/README.md`: retain exactly 72 `e6` portrait outputs, 13 separate no-face comparisons, and 144 disposable two-fixture files; record only unchanged fresh rerun evidence.
- `ARCHITECTURE.md` / `DESIGN.md`: own SDK-core route, one cap authority, seven named fields, one 44-field conflict mask, and dispatch order.
- `SECURITY.md`: own package-only observed support, privacy/redaction, no substitution/persistence/network, and final gate.
- `RELIABILITY.md`: own local failure, stateless freshness transitions, bounded monotone convergence, aggregate diagnostics, and recovery.
- `PRODUCT_SENSE.md`: own exact seven-control SDK journey and acceptance/nonclaims.
- `QUALITY_SCORE.md`: own focused/full/output/security/Nyquist evidence.
- `PLANS.md`, `.planning/{PROJECT,ROADMAP,REQUIREMENTS,STATE}.md`: close SAFE-01..03 and DOC-01 only after owner/evidence gates; retain independent milestone audit as pending.

Apply checker owner modes after each bounded owner group. Do not duplicate one owner's invariant verbatim into every document.

## Shared Patterns

### Authentication

Not applicable. Phase 52 adds no identity, entitlement, account, session, or remote service.

### Error Handling

**Sources:** `EyebrowWarpProvider.swift` lines 35-45 and archived Phase 48 checker lines 111-150, 180-194.

Runtime geometry fails locally to empty named emissions and fixed aggregate reasons. Tool/path/status errors fail the checker closed. Neither path exposes raw geometry or silently interprets an operational failure as a clean scan.

### Validation

One typed seven-field descriptor is the source of truth for cap, semantics, provider emission, lifecycle, and unavailable fixtures. The 44-field inventory is separately the only combined arithmetic/mask oracle. Cardinality and uniqueness assertions precede value assertions.

### Privacy and diagnostics

Use fixed warning codes/messages and aggregate counts only. Tests must assert absence of raw sides, points, endpoints, centers, apexes, axes, arrays, coordinates, provider internals, and image bytes.

### Evidence-first promotion

All blueprint statuses remain `future` through executable safety, full SwiftPM, unchanged Phase 51 output/gallery, artifact containment, review, Nyquist, and ASVS gates. Promotion is one four-file transaction; owner synchronization follows it.

### Disposable artifact containment

Generated output/gallery PNGs remain ignored, untracked, unstaged, descriptor-safe, and disposable. No generated media belongs in the Phase 52 commit.

## No Analog Found

None. Every permitted Phase 52 surface has an exact or strong archived/current analog. Any proposed new package target, public geometry carrier, renderer/facade, fixture, dependency, resource/model, network/cloud path, Demo UI, or generated binary is out of scope rather than a no-analog implementation opportunity.

## Metadata

**Analog search scope:** `BeautySDK/Sources`, `BeautySDK/Tests`, `.planning/milestones/v1.11-phases/44-*`, `.planning/milestones/v1.12-phases/48-*`, Phase 49-51 artifacts, blueprint/root/planning owners
**Primary analogs read:** archived `44-PATTERNS.md`, archived `48-PATTERNS.md`, Phase 48 checker, active cap/provider/resolver and nearest test seams
**Pattern extraction date:** 2026-07-27
