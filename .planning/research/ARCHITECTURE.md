# Architecture Research

**Domain:** v1.9 SDK-core nose root/lift parameter expansion and nose-branch closeout
**Researched:** 2026-07-13
**Confidence:** HIGH for repository integration; MEDIUM for final visual tuning values

## Architectural Recommendation

Extend the existing nose domain in place. Add two independent public, positive-only parameters—recommended names `noseRootHeight` for `山根` and `noseTipLift` for `提升`—and route both through the shipped `BeautyParameters` → `BeautyEffectResolver` → `NoseWarpProvider` → unified geometry pipeline. Do not alias either field to `noseBridge` or `noseTipSize`, add a new package/target, expose geometry publicly, create a nose-specific render pass, or involve the SwiftUI Demo.

The product-neutral semantics should be fixed before implementation:

| Public field | Normalized contract | Exact semantic boundary | Explicit non-semantic |
| --- | --- | --- | --- |
| `noseRootHeight` | `0...1`, default `0`; suggested initial effective cap `0.25` | Increases the visible vertical extent/definition of the upper nasal root by moving only upper-root anchors toward the glabella. | Not whole-bridge narrowing, depth/projection, highlight/shadow, or an alias of `noseBridge`. |
| `noseTipLift` | `0...1`, default `0`; suggested initial effective cap `0.25` | Lifts the lower nose/tip region upward around a stable nose center. | Not whole-nose Y position, tip scale, rotation exposed in both directions, or an alias of signed `noseTipSize`. |

Both are enhancement-only controls because the milestone names are positive actions and the established Demo slider convention for such controls is unit-normalized. If product requirements actually need lowering/deprojection, that is a different signed public contract and must be decided before code; it should not be inferred from the Chinese labels during implementation.

```text
Committed portrait / negative fixtures
                    │
                    ▼
 BeautyExampleRenderer (imports BeautySDK only)
                    │ BeautyParameters (33 fields after expansion)
                    ▼
 BeautyEngine.processResult(image:metadata:parameters:)
                    │ geometry-required detection; package-only observation
                    ▼
 BeautyFaceGeometryAdapter → internal FaceGeometry.nose
                    │
                    ▼
 BeautyEffectResolver
   normalize → cap → freshness policy → one combined-geometry resolution
                    │ `.nose` + redacted plan evidence
                    ▼
 NoseWarpProvider
   existing slim/wing/tip-size/bridge + new root-height/tip-lift methods
                    │ local WarpControlPoint values
                    ▼
 BeautyGeometryEffectPipeline → bounded same-dimension CIImage warp
                    │
                    ▼
 Public BeautyResult (image + summary/warnings/aggregate metrics only)
                    │
                    ▼
 Ignored output/gallery + milestone-owned black-box checker
```

This keeps the shipped layering intact: `BeautyCore` owns public values, `BeautyDetection` owns observations, `BeautyEffects` owns semantics/planning/control points, `BeautyRender` remains the unified rendering boundary, and `BeautySDK` remains the only facade used by renderer and host-style tests.

## Component Impact

### Modified production components

| Component | Required change | Boundary preserved |
| --- | --- | --- |
| `BeautyCore/Models/BeautyParameters.swift` | Add stored fields, coding keys, defaulted initializer arguments, decoding defaults, normalization, and normalized-copy propagation for `noseRootHeight` and `noseTipLift`. | Public values only; no landmark or provider type. |
| `BeautyEffectPlan.BeautyEffectiveStrengths` | Add the two internal effective fields. | Effective caps/degradation stay internal and do not narrow the public normalized range. |
| `BeautySafetyCaps` | Add independent conservative caps. Start with `0.25` each and make exact values evidence-backed before closeout. | Natural-output policy remains centralized. |
| `BeautyEffectResolver` | Include both fields in geometry detection, cap resolution, requested-nose checks, reused scaling, stale/missing zeroing, active-domain planning, and aggregate metrics. | Existing category-only warnings remain sufficient; do not emit field names with coordinates or geometry payloads. |
| `GeometryConflictResolver` | Add both magnitudes to total/count/scale. Prefer applying the resolver exactly once after caps/freshness and before per-domain provider checks. | Every active geometry field is weakened consistently; positive-only fields stay nonnegative. |
| `NoseWarpProvider` | Add independent `rootHeightPoints` and `tipLiftPoints`; keep current bridge and tip-size methods unchanged. | Same internal provider/domain and unified control-point output. |

`BeautyEngine`, `BeautyEngineGeometryDetection`, `BeautyFaceGeometryAdapter`, and `BeautyGeometryEffectPipeline` should require no new public or package boundary. They already detect for nonzero nose geometry, map a usable nose group to internal `FaceGeometry.nose`, activate `.nose`, and apply provider points. Their tests must nevertheless prove the new fields reach those existing seams.

### New verification components

| Component | Purpose | Notes |
| --- | --- | --- |
| Milestone-owned nose-remaining output checker | Decode all expected PNGs, verify dimensions/inventory, compare each new case with baseline, and prove it differs from the nearest old effect. | Reuse parsing concepts, not archived mutable evidence. Do not edit Phase 31/32 helpers. |
| Ignored nose-root/lift gallery routing | Deterministic review paths for each case/fixture. | Review convenience only; not a committed baseline or commercial approval. |
| Focused contract/evidence records | Exact normalization, caps, geometry direction, freshness, conflict, facade, privacy, and status evidence. | Promotion is blocked until all records agree. |

No new production type is justified. Separate `NoseRootWarpProvider` or `NoseLiftWarpProvider` types would add dispatch and ownership with no new landmark domain; private methods inside `NoseWarpProvider` make independence testable without fragmenting the unified nose provider.

## Geometry Design

The current internal face model exposes one normalized `nose` point set. The adapter's deterministic shape has an upper anchor, a center anchor, and lower side anchors. That is enough for two distinct 2D effects without adding `noseCrest` to the public or package model.

### `noseRootHeight`

1. Compute the nose center and select a small upper-root subset (points above the center, with the uppermost anchor required).
2. Move those anchors vertically upward by a bounded displacement derived from face height, e.g. `face.bounds.height * coefficient * strength / cap`.
3. Keep horizontal target coordinates unchanged. This is the critical distinction from current `bridgePoints`, which moves upper points horizontally onto `center.x`.
4. Use a local radius no larger than the bridge radius and clamp source, target, radius, and strength through the existing helper/make-point path.
5. Return no points if an upper root cannot be derived; do not substitute `noseBridge` points.

This is a 2D visual-height proxy, not a claim of true nose projection or lighting. A real depth/highlight implementation would be a separate future effect and possibly a different render domain.

### `noseTipLift`

1. Select lower-nose anchors at or below the nose center.
2. Move them upward with a small vertical displacement, optionally weighted so the lowest/central tip anchor moves more than wing anchors.
3. Keep horizontal coordinates stable so lift does not silently become wing slimming.
4. Do not call `tipPoints`: current signed `noseTipSize` moves lower points radially toward/away from center and has different semantics.
5. Fail closed when no lower subset exists.

Provider tests should assert affected subset, axis/direction, deterministic output, caps/radii/bounds, and direct non-equivalence to `bridgePoints`/`tipPoints`. Renderer evidence then proves those independent provider paths survive the public facade.

## Public Model and Codable Compatibility

The current custom decoder already defaults absent float keys to zero. Adding both keys through that same path gives the required backward compatibility:

- Old 31-field JSON decodes to a 33-field value with both new fields at `0`.
- Unknown future keys remain ignored by Swift's keyed decoder.
- Default construction and all old source calls retain no-op behavior because the new initializer arguments have defaults.
- New JSON round-trips both values and clamps negative, overflow, NaN, and infinity using the same positive-only normalization as other unit fields.
- Existing bundled presets require no JSON edits for behavior; decode tests must prove they retain zero new effects.

Auto-synthesized encoding will include the two zero keys, so serialized output shape changes from 31 to 33 fields even when effects are off. That is expected public schema expansion and must be documented and tested. This approach preserves source and decode compatibility for this source-distributed Swift package; changing the explicit initializer changes its binary symbol, so it does **not** establish binary ABI compatibility for already compiled clients. If binary framework stability becomes a release requirement, it needs a separately designed compatibility initializer/factory policy before shipping.

All field-inventory guards, preset/parameter Codable tests, JSON examples that are current contracts, and security scans hard-coded to 31 must move atomically to 33. Archived milestone evidence must remain unchanged.

## Resolver and Data Flow Details

### Request flow

1. A host or `BeautyExampleRenderer` creates `BeautyParameters` with one new field nonzero.
2. `requiresFaceGeometry` includes both fields, so the still-image facade requests detection. No-op/default/preset paths remain `.notRun` as before.
3. A usable selected observation becomes internal `FaceGeometry`; absent or unusable observations are resolved as no-face without public raw geometry.
4. The resolver normalizes and caps both fields, then applies the nose freshness contract:
   - fresh: retain capped values;
   - reused: multiply both by exact `0.5` with the existing aggregate warning/metric;
   - stale, missing nose, or no usable face: zero the complete six-field nose domain and skip `.nose`;
   - independent color/filter domains continue.
5. Combined geometry resolution includes the two fields and runs once. This is important because the current resolver calls the conflict resolver conditionally from face-shape and mouth branches; that can omit some nose-only combinations or weaken a plan twice when both branches are active.
6. `NoseWarpProvider` emits independent points. Empty output zeros all six nose strengths and records the existing `nose_inputs_missing` category evidence.
7. The unified local warp returns an extent-preserving output. Public diagnostics contain fixed warnings, counts, and scales only.

### Combined-geometry invariant

The resolver should establish one global effective-strength snapshot before asking providers for points:

```swift
normalized public values
    → per-field caps
    → domain freshness reduction/zeroing
    → GeometryConflictResolver.resolve(...) exactly once
    → provider validation / active-domain decisions
    → render plan
```

This avoids field-dependent call order and makes tests for face + eyes + all six nose fields + mouth deterministic. The refactor touches existing behavior, so regression tests must lock prior caps, signs, reused/stale rules, and facade outputs. If the implementation phase declines this refactor, it must still prove the two new fields are weakened in every supported combination and that no plan is weakened twice; simply appending fields to `geometryTotal` is insufficient.

## Renderer and Helper Evidence

The current matrix is 34 cases across seven fixtures. Add exactly two isolated cases, for example:

- `noseRootHeight_0p25`
- `noseTipLift_0p25`

That yields 36 × 7 = **252 ignored outputs** while the fixture inventory remains unchanged. Counts should be derived from the case/fixture lists in the checker rather than copied into multiple scripts.

Required black-box evidence:

| Evidence | Expected matrix |
| --- | --- |
| Full decode/non-empty/same-dimension inventory | 252/252 |
| New effect vs `geometryBaseline_noop` above watermark | 12/12 across 2 cases × 6 portraits |
| Root independence | 6/6 `noseRootHeight` vs `noseBridge_0p30` portrait differences |
| Lift independence | 6/6 `noseTipLift` vs `noseTipSize_plus0p30` portrait differences |
| No-face degradation | Both representative no-face outputs exist, preserve extent, contain no fatal error, and expose only redacted degradation evidence |
| Artifact containment | All output/gallery files are ignored and no generated PNG is tracked |

Image difference alone does not prove semantics. Provider/resolver tests prove anchor subset, direction, caps, and degradation; facade/helper evidence proves the effect is observable through public APIs. Both are required before ledger promotion.

`BeautyRendererOutputRegressionTests` should update the exact case inventory, assert one new public nose field per case, keep `import BeautySDK` as the only SDK import, and replace the old `noseRoot`/`noseLift` exclusion with exclusions for aliases, localized names, combo cases, or accidental reuse—not exclusions for the new canonical names.

## Documentation Ownership

| Owner | Required v1.9 update |
| --- | --- |
| `DESIGN.md` | Canonical public names, ranges, no-op defaults, exact semantics, caps, and complete nose-domain freshness/conflict state. This is the primary semantic owner. |
| `ARCHITECTURE.md` | Record that the 33-field expansion stays in `BeautyCore`, reuses the internal nose provider/unified warp/facade route, and adds no public geometry or package. |
| `SECURITY.md` | Re-run public/raw-geometry, diagnostics, generated-artifact, network/cloud, and dependency scans; record that new fields reveal no biometric coordinates. |
| `RELIABILITY.md` | Expand the Phase 32 nose freshness contract from four to six fields; record exact caps, one-pass combined weakening, safe-domain continuation, and rerunnable evidence. |
| `PRODUCT_SENSE.md` | Add user-observable acceptance criteria and exact non-claims for the two rows and SDK-only branch closeout. |
| `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md` | Promote `山根`, `提升`, then branch-level `鼻子` only after code, tests, outputs, and boundaries pass. |
| Nose branch README, shaping README, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md` | Synchronize current public coverage, evidence commands/counts, branch status, and exclusions. |
| `QUALITY_SCORE.md` | Update coverage/quality claims and 31→33 inventory guards only from observed results. |
| `.planning` milestone artifacts and `PLANS.md` | Record requirements, phases, verification commands, decisions, and final closeout. Do not rewrite archived v1.7 evidence. |

`FRONTEND.md` and SwiftUI source are not owners for this SDK-only milestone. The existing Demo model maps visible `山根` to `.noseBridge`; v1.9 evidence must not use that alias. Because the milestone excludes Demo UI changes, closeout wording must explicitly say the new public SDK fields have facade evidence but are not newly wired into the Demo. Branch-level `鼻子` can only be promoted as an SDK-core branch, not as Demo parity.

## Recommended Build Order

1. **Freeze the semantic/API contract.** Choose the canonical field names, positive-only ranges, caps, exact root/tip regions, and non-semantics in `DESIGN.md` planning artifacts before editing implementation. Resolve signed-vs-unit ambiguity here.
2. **Expand the public value model.** Add 33-field construction, normalization, Codable defaults/round-trip, old-JSON decode, preset no-op, and inventory tests. This unblocks all downstream code while proving backward-compatible decoding first.
3. **Thread effective strengths and global safety.** Add safety caps, effective fields, all resolver predicates/helpers, complete-domain zeroing/reused scaling, and both fields to one-pass conflict resolution. Run resolver/conflict/degradation tests before provider visuals.
4. **Implement independent provider geometry.** Add root-height and tip-lift point methods plus deterministic direction/non-alias/bounds/missing-input tests. Reuse `FaceGeometry.nose`; do not expand detection/public geometry unless tests show the current subset cannot meet the fixed contract.
5. **Prove facade routing.** Add host-style facade tests showing either field triggers detection, returns same extent, produces `.nose` points on usable geometry, fails closed on no-face/missing/stale, scales reused geometry at `0.5`, preserves safe domains, and emits redacted diagnostics.
6. **Extend renderer and checker.** Add the two isolated cases, 252-output inventory, 12 baseline comparisons, root-vs-bridge and lift-vs-tip-size comparisons, ignored gallery, and no-face checks.
7. **Run broad gates.** Focused suites, full SwiftPM tests, renderer build/run/helper, raw-geometry/import/network/commercial/dependency/generated-file scans, and `git diff --check` must pass from clean inputs.
8. **Promote atomically.** Update all current owners in one closeout after evidence passes. Promote exactly `山根`, `提升`, and SDK-core branch `鼻子`; preserve no Demo/device/commercial/packaging/launch/broad-parity claim.

This order prevents renderer scaffolding from defining semantics accidentally and prevents ledger promotion before public-model, safety, geometry, facade, and artifact gates all agree.

## Architectural Risks and Mitigations

| Risk | Consequence | Mitigation |
| --- | --- | --- |
| Root silently reuses bridge points | `山根` is an undocumented alias and violates the milestone goal. | Separate field/method/cap/case; assert vertical-only root targets and direct inequality from bridge provider/output. |
| Lift silently reuses tip-size points | `提升` becomes resize behavior. | Assert lower-subset upward displacement with stable X; compare provider points and public outputs with positive tip-size. |
| 2D warp is described as 3D height/projection | Product claim exceeds architecture. | Define root as visible vertical extent/definition only; reserve projection/lighting for future work. |
| Old JSON or presets activate a new effect | Backward compatibility/no-op regression. | Missing-key default-zero and bundled-preset tests before provider work. |
| Public initializer expansion is mistaken for ABI stability | Precompiled clients may fail to link. | State source/JSON compatibility explicitly; do not claim binary compatibility. |
| New fields omitted from one resolver helper | Detection, zeroing, reused scale, or conflict behavior diverges. | Table-driven/all-six nose tests for every helper path and effective snapshot. |
| Conditional conflict resolution omits or double-scales fields | Combination behavior depends on active domains/order. | Resolve exactly once globally, or prove equivalent exhaustive behavior if refactor is declined. |
| Watermark/global changes count as geometry | False facade evidence. | Compare above watermark, require local nose-region differences, provider direction tests, and independence comparisons. |
| Branch completion is read as Demo parity | Existing Demo still aliases root to bridge and has no lift control. | Label promotion SDK-core only; explicitly exclude Demo wiring and broad Meitu parity. |
| Archived evidence is modified to make counts pass | v1.7 audit history loses integrity. | Add a v1.9-owned helper/evidence record; treat archived phases as immutable inputs. |

## Anti-Patterns

- **Aliasing `noseRootHeight` to `noseBridge`:** the existing bridge path is horizontal centralization and cannot prove upper-root vertical semantics.
- **Naming the public field `noseLift`:** it is ambiguous between whole-nose translation, root height, and tip rotation. Prefer `noseTipLift` unless the chosen geometry truly moves the entire nose.
- **Adding a depth/highlight claim to a 2D control-point warp:** visible output does not prove projection or lighting.
- **Calling `NoseWarpProvider` from the renderer:** that bypasses facade detection/routing and invalidates integration evidence.
- **Adding a separate Metal/CI pass:** both effects fit the unified local warp and should share its extent/performance/degradation behavior.
- **Changing public normalized limits to equal safety caps:** public values stay `0...1`; internal effective caps remain conservative and independently testable.
- **Leaving skipped nose strengths nonzero:** the plan, diagnostics, and actual render must agree for missing/stale/no-face conditions.
- **Promoting the whole product surface from SDK-only evidence:** no Demo, device, commercial visual, packaging, or launch readiness follows from this milestone.

## Integration Boundaries

| Boundary | Communication | Constraint |
| --- | --- | --- |
| Host/renderer → `BeautySDK` | Public `BeautyParameters`, `BeautyEngine`, `BeautyResult` | No internal imports or raw geometry. |
| `BeautySDK` → Detection/Effects | Package-only selected observation | Detection runs only for nonzero geometry; public summary stays geometry-free. |
| Detection → Effects | Internal `BeautyFaceGeometryAdapter` / `FaceGeometry.nose` | No Vision object, bounds, or landmark coordinates cross the public facade. |
| Resolver → provider | `BeautyEffectiveStrengths` + internal face geometry | Caps/freshness/conflict are settled before provider generation. |
| Provider → geometry pipeline | Local `WarpControlPoint` list | Root/lift share render infrastructure but not semantics or point-generation methods. |
| Public outputs → checker/gallery | Deterministic PNG names and redacted results | Outputs/gallery ignored; no tracked generated baseline or local-path diagnostics. |
| Current docs → archived evidence | References only | v1.9 adds evidence; it does not rewrite Phase 31/32 facts. |

## Sources

- `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md`
- `ARCHITECTURE.md`, `DESIGN.md`, `SECURITY.md`, `RELIABILITY.md`, `PRODUCT_SENSE.md`, and `QUALITY_SCORE.md`
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`, `BeautyEffectPlan.swift`, and `BeautySafetyCaps.swift`
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift`, `GeometryConflictResolver.swift`, `WarpControlPoint.swift`, and `LandmarkGeometryHelper.swift`
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` and `BeautyEngineGeometryDetection.swift`
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- Current parameter, provider, resolver, conflict, facade, and renderer regression tests under `BeautySDK/Tests/`
- Archived v1.7 Phase 31 renderer helper/evidence and Phase 32 safety evidence
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, and nose/shaping READMEs
- `docs/09_algorithm_effects_implementation.md` historical naming suggestions (`noseBridgeHeight`, `noseTipLift`) as background only; current code/root contracts remain authoritative

---
*Architecture research for: v1.9 Nose Remaining Tools and Branch Closeout*
*Researched: 2026-07-13*
