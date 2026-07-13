# Pitfalls Research

**Domain:** Independent nose-geometry parameters and evidence-backed SDK branch closeout
**Researched:** 2026-07-13
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Calling `山根` or `提升` an alias of an existing nose tool

**What goes wrong:**
The new public fields exist in name only while `山根` reuses `noseBridge`, or `提升` reuses `noseTipSize`, the same provider branch, or the same renderer evidence. The ledger can then claim two tools from one behavior even though v1.7 explicitly reserved `noseBridge` evidence for `鼻梁` and kept `山根`/`提升` unresolved.

**Why it happens:**
All nose effects share the `.nose` domain and the same landmark group. Reusing an existing strength or control-point function is easy and still produces a visible output, so ordinary baseline comparisons do not prove semantic independence.

**How to avoid:**
Define product-neutral names, public ranges, direction meanings, affected anatomical region, and displacement vectors before implementation. Give each field its own `BeautyParameters` storage, effective strength, safety cap, provider branch, isolated renderer case, and tests. In addition to baseline differences, require `山根` output to differ from `noseBridge` and `提升` output to differ from the nearest existing nose behavior at equal normalized strength. Shared helper math is acceptable; shared meaning or evidence is not.

**Warning signs:**
- A new field is assigned into `strengths.noseBridge` or `strengths.noseTipSize`.
- The provider has no new independently named control-point path.
- A ledger row cites `noseBridge_0p30` or another v1.7 case.
- The two new renderer cases produce identical control points, identical PNGs, or only watermark differences.
- Documentation uses “bridge-like,” “tip-like,” or “alias” without an explicit semantic decision.

**Phase to address:**
Proposed Phase 35, public contract and independent geometry semantics; re-prove independence in Phase 36 output evidence.

---

### Pitfall 2: Expanding `BeautyParameters` without preserving source and Codable compatibility

**What goes wrong:**
Older preset/parameter JSON fails to decode, the new fields bypass normalization, existing call sites stop compiling, or encode/decode/round-trip behavior silently omits a field. Conversely, current docs and tests may keep asserting a 31-field inventory after the intended expansion to 33 stored fields.

**Why it happens:**
`BeautyParameters` is a manually maintained public struct. A field must be threaded through stored properties, `CodingKeys`, the public initializer with a zero default, `init(from:)`, and `normalized()`. The repository also has Mirror-based field-count tests, Demo JSON import/export, bundled preset JSON, facade validation, and many source call sites using the initializer.

**How to avoid:**
Append independently labeled initializer parameters with zero defaults; add both coding keys; decode absent keys through the existing zero-default helper; include both values in `normalized()`; and test old JSON, partial JSON, new round trips, non-finite input, and default no-op behavior. Verify bundled presets without the keys still decode to zero and existing source-style initializers still compile. Treat the encoded addition of zero-valued keys as a schema behavior to document and test. Update the current public inventory to 33 only after both fields are actually public.

**Warning signs:**
- One of the new names appears in fewer places than the existing four nose fields in `BeautyParameters.swift`.
- `Mirror(...).children.count` still expects 31 in current tests.
- Old JSON fixtures fail, or missing new keys do not resolve to exact zero.
- `normalized()` returns defaults for the new fields even when input is non-zero.
- A public initializer parameter has no default or was renamed after evidence was written.
- A broad “31 → 33” replacement modifies archived v1.7/v1.8 facts.

**Phase to address:**
Proposed Phase 35. Compatibility must be complete before renderer or closeout work begins.

---

### Pitfall 3: Producing control points that are no-ops, cancel, or overlap existing nose warps

**What goes wrong:**
The provider returns points and the domain is marked active, but `RenderableWarpPoint` drops them because displacement is effectively zero; or new points overlap `noseBridge`/`noseTipSize` and sum to the same, canceled, or exaggerated warp. A count-based assertion passes while the image does not express the promised tool.

**Why it happens:**
The current still-image warp sums displacement from every point within its radius. `noseBridge` already uses upper-nose points and `noseTipSize` uses lower-nose points. The available nose landmark set is small, and clamping targets to the center or image bounds can collapse source and target. Provider point counts are therefore weaker evidence than spatial and rendered differences.

**How to avoid:**
Specify non-overlapping or intentionally composable regions and direction vectors. Unit-test source-region membership, non-zero displacement, target direction, radius bounds, deterministic order, and distinction from existing providers. Add isolated facade-visible comparisons against `geometryBaseline_noop`, plus direct new-vs-nearest-existing comparisons above the watermark in a nose-focused ROI. Add combined-nose tests to detect cancellation and excessive displacement when root, lift, bridge, and tip are active together.

**Warning signs:**
- Source equals target after clamping.
- Only `points.count > 0` is asserted.
- New and old fields select the same landmark subset and displacement formula.
- Portrait comparison passes only as full-image byte inequality or in the watermark band.
- One or more fixtures produce identical baseline/new or root/bridge outputs.
- Combined nose output is weaker than either isolated effect without a documented conflict rule.

**Phase to address:**
Proposed Phase 35 for provider geometry and focused tests; Phase 36 for facade-visible differential evidence.

---

### Pitfall 4: Leaving caps and directionality implicit

**What goes wrong:**
Negative values are accidentally accepted for a positive-only control, a signed field loses its negative direction through `abs`, `min`, reused scaling, or provider strength construction, or a high public value bypasses the natural cap. UI-neutral public semantics and effective algorithm caps become conflated.

**Why it happens:**
The current nose family mixes positive-only fields with signed `noseTipSize`. Public normalization is `0...1` or `-1...1`, while `BeautySafetyCaps` applies smaller effective ranges. Existing provider code sometimes uses `abs(strength)` for point strength while direction remains in displacement, so a superficially correct assertion can miss sign loss.

**How to avoid:**
Decide each field's public range and the exact physical meaning of positive and, if applicable, negative values before naming it. Keep public normalization separate from effective caps. Test lower/upper overflow, NaN, both infinities, exact cap values, capped-count increments, provider target direction, facade output direction, reused scaling, and combined weakening. If a field is positive-only, explicitly prove negative input becomes zero; if signed, prove both directions remain distinct end to end.

**Warning signs:**
- A cap is copied from `noseBridge` or `noseTipSize` without a geometry-specific rationale.
- Tests check only `<= cap` rather than exact effective values.
- `abs` is applied before displacement direction is computed.
- Only the positive renderer case exists for a signed contract.
- Warnings or `cappedCount` omit one new field.

**Phase to address:**
Proposed Phase 35 for semantics, normalization, and exact caps; Phase 37 for all safety-path verification.

---

### Pitfall 5: Updating the happy path but not every degradation list

**What goes wrong:**
Missing or stale nose landmarks leave one new strength active, reused geometry fails to apply exact `0.5`, or detection is not triggered when only a new parameter is set. The plan may advertise `.nose` while producing no points, or unsafe stale geometry may continue.

**Why it happens:**
Nose fields are repeated manually in `requiresFaceGeometry`, request detection, reusable-non-eye detection, `zeroNoseStrengths`, `scaleReusableNonEyeGeometryStrengths`, active-domain checks, effective strengths, provider tests, and degradation assertions. Adding the field only to `BeautyParameters` and `NoseWarpProvider` is insufficient.

**How to avoid:**
Use the existing four nose fields as a propagation checklist. For each new field, verify: geometry-required routing; no-face skip and zero; missing-nose skip and zero; stale skip and zero; reused exact `0.5`; `.nose` active only with usable non-empty provider output; unrelated color/filter continuation; and category-level warnings/metrics. Update shared `assertNoseStrengthsAreZero` helpers so omissions fail loudly.

**Warning signs:**
- A repository search shows a four-field list that excludes either new name.
- New-only parameters produce `detectionSummary == .notRun`.
- Missing/stale tests assert the domain but not every effective strength.
- Reused geometry preserves the old four fields but leaves a new field at full strength.
- A no-face request emits geometry point metrics.

**Phase to address:**
Proposed Phase 35 for routing completeness and Phase 37 for the full freshness/degradation matrix.

---

### Pitfall 6: Omitting new fields from combined-geometry weakening or weakening them more than once

**What goes wrong:**
High-strength face/eye/mouth/nose combinations weaken the four legacy nose fields but not `山根`/`提升`, producing disproportionate nose deformation. Alternatively, repeated conflict resolution scales a value twice, obscuring the intended exact behavior.

**Why it happens:**
`GeometryConflictResolver` manually enumerates fields in its total, non-zero count, and scaled output. `BeautyEffectResolver` invokes conflict resolution from more than one domain path, so list completeness and call placement both matter. A generic “combined warning exists” test does not prove each new field was counted and scaled once with direction preserved.

**How to avoid:**
Add both fields to geometry total, non-zero field count, and weakened strengths. Test each new field independently with representative face, eye, and mouth geometry, comparing isolated effective strength to combined effective strength and preserving sign where relevant. Add an all-nose and all-domain case with an explicit expected weakening count/scale, and inspect whether conflict resolution is applied once per plan rather than incidentally per active domain.

**Warning signs:**
- `combined_geometry_weakened` exists but a new effective strength equals its isolated cap.
- `weakenedCount` does not change when either new field is enabled.
- Results depend on whether a mouth or face-shape field is also non-zero.
- The same parameter is multiplied by the geometry scale in multiple resolver branches.

**Phase to address:**
Proposed Phase 37 safety and integration closeout, after isolated geometry behavior is stable.

---

### Pitfall 7: Leaking raw geometry or parameter detail through diagnostics and evidence

**What goes wrong:**
Warnings, metrics, helper output, or evidence documents expose landmark coordinates, bounding boxes, absolute paths, raw framework errors, parameter snapshots, or per-face details. A harmless-looking debug assertion can widen the public or recorded privacy surface.

**Why it happens:**
New geometry is easiest to debug by printing points and paths. This repository explicitly treats landmarks as biometric-adjacent, permits only geometry-free summaries plus category/aggregate diagnostics, and records generated output evidence in Markdown.

**How to avoid:**
Reuse fixed category-level nose reason codes and aggregate numeric metrics. Keep control points and face geometry internal/package-only. Helpers should report relative fixture names, case IDs, counts, dimensions, and comparison pass/fail only. Extend public/SPI, active-source, warning/metric, raw-path, and evidence-document scans to cover the new code and phase artifacts.

**Warning signs:**
- Warning messages interpolate field names, values, coordinates, face indices, or local URLs.
- Metrics keys contain per-point or per-fixture geometry.
- Evidence contains `/Users/`, `/private/var`, `CGPoint`, `CGRect`, raw landmark arrays, or framework error descriptions.
- The Demo or renderer imports `BeautyDetection`, `BeautyEffects`, or `BeautyRender` to inspect geometry.

**Phase to address:**
Proposed Phase 37 security and boundary scan; enforce fixed diagnostics during Phase 35 implementation.

---

### Pitfall 8: Treating generated PNGs as either disposable noise or committed baselines

**What goes wrong:**
The renderer matrix changes but the helper/gallery routing still expects the old 34-case/238-output inventory, or generated PNGs are accidentally committed. At the other extreme, outputs are regenerated and deleted without recording reproducible counts and comparisons, leaving no reviewable evidence.

**Why it happens:**
The canonical case inventory is hard-coded in the renderer regression test and helper scripts use fixed case sets/counts. v1.7 evidence was 28 × 7 = 196, while the current post-mouth matrix is 34 × 7 = 238. Archive moves also make old `.planning/phases/...` command paths stale if current docs are not updated deliberately.

**How to avoid:**
Recalculate the matrix only after the semantic decision determines how many direction cases each field needs. Keep one public field per isolated case. Update renderer inventory, helper expectations, gallery groups, no-face representative checks, and current command paths together. Verify full PNG decode, non-empty files, same dimensions, ROI differences, pairwise semantic differences, ignored status, and `git ls-files` zero tracked output/gallery artifacts. Record commands and aggregate results in evidence, not the PNGs themselves.

**Warning signs:**
- Docs still call 196 or 238 the current matrix after cases are added.
- Helpers pass while silently ignoring unexpected case IDs.
- `git status` shows files under `example-images/output` or `example-images/gallery`.
- Gallery cleanup deletes outside its safe root.
- Current docs reference pre-archive `.planning/phases/31...` paths that no longer exist.

**Phase to address:**
Proposed Phase 36 renderer/helper/gallery evidence; Phase 37 repeats artifact containment during closeout.

---

### Pitfall 9: Declaring branch-level `鼻子` complete from code or tool-row status alone

**What goes wrong:**
The branch is promoted to `implemented` before both independent tools have public-facade output, safety/degradation coverage, redaction scans, and synchronized owning docs. Claims may expand further into Demo UI, device parity, commercial naturalness, broad reference-app parity, packaging, or launch readiness without evidence.

**Why it happens:**
Once all six taxonomy rows appear implemented, the status looks mechanically complete. However, the repository's status contract requires SDK behavior, tests, facade-visible output, and same-phase ledger/branch updates. Several current owners repeat branch status and inventory, while archived milestone documents must remain historically accurate.

**How to avoid:**
Make branch promotion the last closeout action. Require both new rows to pass contract, provider, facade, output-helper, freshness, combined-safety, redaction, dependency/import, and artifact gates. Update the authoritative second-level ledger first, then nose README, branch-level `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, root contracts, quality/current planning owners, and milestone evidence. Preserve archived v1.7/v1.8 counts and non-claims as historical facts. State explicitly that SDK branch completion adds no Demo/device/commercial/packaging/launch claim.

**Warning signs:**
- `FEATURE_MATRIX.md` says `implemented` while either ledger row is partial/future.
- A row is promoted from provider tests without isolated public-facade output.
- Current owner docs disagree on 31 vs 33 fields, case counts, or branch status.
- A global replacement rewrites v1.7's exact four-row or 31-field archive.
- “Nose complete” appears without the qualifier “SDK branch” and explicit non-claims.

**Phase to address:**
Proposed Phase 37 only, after Phases 35 and 36 evidence is complete.

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Map `山根` to `noseBridge` or `提升` to `noseTipSize` | Minimal code and tests | False taxonomy completion and inseparable future API semantics | Never for v1.9's explicit independent-field goal |
| Add fields only to `BeautyParameters` and provider | Visible local prototype | Detection, degradation, weakening, Codable, and inventory drift | Only in an uncommitted spike |
| Assert control-point count instead of displacement and rendered ROI | Fast green test | Geometry no-ops and aliases pass undetected | Never as completion evidence |
| Copy an existing safety cap without direction/region evidence | Fast constants | Unnatural or ineffective behavior becomes public contract | Only as a temporary spike value, never closeout |
| Hard-code a new output total before semantics decide signed cases | Simple helper | Stale matrix and missing direction evidence | Never |
| Global replace all `31` inventory references with `33` | Quick documentation update | Corrupts historical v1.7/v1.8 archives | Never; update current owners selectively |
| Commit generated PNGs as proof | Easy visual review | Repository bloat and unreviewed binary baseline drift | Never under the current ignored-artifact contract |
| Promote branch status before the final owner scan | Makes progress appear complete | Contradictory public claims and audit repairs | Never |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `BeautyParameters` → resolver | Add storage but omit `requiresFaceGeometry`, cap, active check, zero, or reuse list | Trace each field through every legacy nose occurrence and test a new-only request |
| Resolver → `NoseWarpProvider` | Mark `.nose` active because strength is non-zero even when points collapse | Activate only after non-empty renderable control points; zero and skip otherwise |
| Nose provider → unified warp | Reuse identical landmarks/displacements or allow additive overlap to exaggerate output | Prove distinct region/vector semantics and combined composability |
| Conflict resolver → effective strengths | Add fields to scale but not total/count, or scale from multiple domain paths | Update all three enumerations and assert exact once-per-plan weakening behavior |
| Codable → old presets/Demo JSON | Make new keys required or forget normalized/round-trip plumbing | Decode missing keys as zero; preserve schema behavior; test old and new payloads |
| Renderer → helper/gallery | Add case IDs without updating expected inventory and safe gallery groups | Keep canonical IDs, helper cases, matrix math, gallery routing, and docs in one change set |
| Runtime outputs → evidence docs | Record raw paths/geometry or track PNGs | Record relative names and aggregates; keep output/gallery ignored and untracked |
| Tool ledger → branch matrix | Promote branch when rows look complete but evidence owners disagree | Run a final current-owner scan, then promote all owners atomically |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Excess overlapping nose control points | Still-image renderer slows and combined output overshoots | Reuse helper math, minimize distinct points, bound radii, test combined point inventory | Cost grows with affected pixels × renderable points; visible first on large still images |
| Duplicate points with the same radius | Stronger-than-cap visual displacement despite capped scalar strengths | De-duplicate or intentionally combine vectors before render; add max-displacement tests | As soon as two active fields influence the same ROI |
| Full-frame comparison for localized effects | Slow helpers and false positives from watermark/color changes | Restrict comparisons to a documented nose ROI above the watermark | Every fixture; worsens as matrix expands |
| Re-running all generated artifacts for a small semantic failure | Long iteration and stale mixed output directories | Run isolated cases first, clean/rerun the full matrix only for evidence closeout | At 34+ cases × 7 fixtures and increasing |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Logging new control points or landmark regions | Biometric-adjacent derived data leakage | Fixed category warnings and aggregate metrics only |
| Exposing provider/control-point types to the facade or Demo | Permanent public privacy and architecture expansion | Keep geometry internal/package-only; scan public/SPI and imports |
| Recording absolute fixture/output paths in evidence | Local user/environment disclosure | Relative fixture names and repository-relative commands only |
| Echoing raw parameter JSON on decode errors | User preference/payload leakage | Preserve stable redacted Demo import errors |
| Adding dependencies/network for a local geometry tool | Violates local-first boundary and broadens supply-chain risk | No dependency or network change; fail closed in boundary scans |
| Tracking generated face outputs | Persists sensitive portrait derivatives in git | Ignore output/gallery roots and assert zero tracked files |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Root, bridge, lift, and tip look identical | Controls feel fake or redundant | Give each a documented region/direction and pairwise visible evidence |
| Direction label and rendered motion disagree | Adjustment feels inverted | Lock positive/negative semantics from normalized coordinates through facade output |
| High combined nose settings overpower other geometry | Unnatural facial distortion | Exact caps plus once-per-plan combined weakening |
| Missing/stale face silently applies partial nose warp | Flicker or unstable deformation | Skip/zero the whole nose domain; keep safe color/filter work active |
| Branch completion is presented as app/UI parity | Host integrators expect controls or commercial quality that do not exist | Say “SDK nose branch complete” and retain explicit UI/device/commercial non-claims |

## "Looks Done But Isn't" Checklist

- [ ] **Independent semantics:** Both fields have unique neutral names, ranges, region/vector definitions, caps, and nearest-existing pairwise tests.
- [ ] **Public model:** Stored properties, coding keys, defaulted initializer, decoder, normalization, equality/round-trip, and current 33-field inventory agree.
- [ ] **Backward compatibility:** v1.8-era JSON and bundled presets decode both new fields as exact zero; existing initializer call patterns compile.
- [ ] **Routing:** A request containing only either new field triggers geometry detection and `.nose` planning.
- [ ] **Geometry:** Every emitted point has non-zero displacement after clamping and remains distinct from bridge/tip behavior across fixtures.
- [ ] **Caps/direction:** Overflow, negative policy, non-finite values, exact caps, warning, and capped-count behavior are locked.
- [ ] **Freshness:** No-face, missing-nose, and stale geometry zero all six nose strengths; reused geometry scales all six by exact `0.5` with direction preserved.
- [ ] **Combined safety:** Each new field participates in geometry total, count, and weakening exactly once; all-domain tests pass.
- [ ] **Redaction:** Public results, warnings, metrics, helper output, and evidence contain no raw geometry, raw paths, payloads, or framework errors.
- [ ] **Facade output:** Isolated cases differ from baseline in a nose ROI and differ from their nearest legacy behavior; signed cases have both directions if applicable.
- [ ] **Artifacts:** Full matrix decodes at the expected dimensions, gallery routing is safe, outputs are ignored, and zero generated files are tracked.
- [ ] **Inventory:** Renderer IDs, helper expectations, case/fixture totals, public field count, and current owner docs all match.
- [ ] **Branch closeout:** Both tool rows and branch status are promoted only after the final scan; v1.7/v1.8 archives remain unchanged.
- [ ] **Non-claims:** No Demo UI, device parity, commercial visual approval, broad Meitu parity, packaging, or launch readiness is implied.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Semantic alias discovered before release | MEDIUM | Freeze promotion, write distinct semantic contract, split field/provider/cases, regenerate evidence |
| Public field shipped with wrong name/range | HIGH | Do not silently repurpose; preserve old decoding/API, add a corrected field or versioned migration, document compatibility |
| Geometry no-op/overlap | MEDIUM | Inspect control-point vectors, separate regions/radii, add pairwise tests, regenerate only after isolated cases pass |
| Missing freshness/weakening propagation | LOW | Search all legacy nose lists, update zero/reuse/conflict helpers, add new-only degradation tests |
| Sensitive diagnostics/evidence recorded | HIGH | Remove leaked artifacts/history as policy requires, replace with aggregates, rerun scans, invalidate affected evidence |
| Generated PNG accidentally tracked | MEDIUM | Untrack without deleting needed local review files, confirm ignore rules, rescan git index, rerun artifact gate |
| Inventory/doc drift | LOW | Identify current owners vs archives, repair current owners in one batch, run link/table/count/wording scan |
| Premature branch promotion | MEDIUM | Revert current status to partial, list missing gates, finish evidence, rerun single final audit |

## Pitfall-to-Phase Mapping

How the proposed roadmap should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Semantic aliasing | Phase 35: public contract and independent geometry | Unique fields/provider paths plus new-vs-legacy control-point and output distinctions |
| Source/Codable compatibility | Phase 35 | Old JSON/defaults, new round trip, non-finite normalization, source-style compile, 33-field inventory |
| No-op/overlap geometry | Phase 35, then Phase 36 | Vector/region tests followed by isolated ROI and pairwise facade-output comparisons |
| Caps/direction | Phase 35, finalized Phase 37 | Exact normalization/caps and end-to-end direction under reuse/weakening |
| Missing/reused/stale propagation | Phase 37 | New-only no-face/missing/stale/reused matrix with all six strengths asserted |
| Combined weakening | Phase 37 | Per-field and all-domain scale/count tests, no double scaling |
| Redaction | Phase 37 | Public/SPI/import/source/evidence scans and fixed aggregate diagnostics |
| Generated artifacts and matrix drift | Phase 36, repeated Phase 37 | Full helper/gallery run, expected totals, ignore and zero-tracked checks |
| Public inventory and owner drift | Phase 35 for API owners; Phase 37 for full closeout | Selective current-owner update, archives unchanged, comprehensive final scan |
| Documentation overclaim | Phase 37 | Exact two-row plus branch promotion and explicit SDK-only non-claims |

## Sources

- `.planning/PROJECT.md` — v1.9 goal, target features, active requirements, and scope boundaries.
- `DESIGN.md` — current 31-field parameter model, nose ranges, exact caps, and v1.7 semantics.
- `SECURITY.md` — local-first posture, biometric-adjacent geometry boundary, parameter validation, redaction, and Phase 32 containment evidence.
- `RELIABILITY.md` — degradation, aggregate diagnostics, missing/stale/reused nose policy, and safe-domain continuation.
- `.planning/milestones/v1.7-REQUIREMENTS.md`, `v1.7-ROADMAP.md`, and `v1.7-MILESTONE-AUDIT.md` — exact four-row evidence, deferred `山根`/`提升`, and branch non-completion.
- `.planning/milestones/v1.7-phases/31-nose-renderer-output-evidence/31-PATTERNS.md` — renderer/helper/gallery evidence pattern.
- `.planning/milestones/v1.7-phases/32-nose-safety-ledger-and-closeout/32-PATTERNS.md`, `32-NOSE-SAFETY-EVIDENCE.md`, and `32-COMPREHENSIVE-CURRENT-OWNER-SCAN.md` — freshness, weakening, boundary, artifact, and owner-scan patterns.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift` — manual public/Codable plumbing and inventory contract.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`, `BeautyEffectPlan.swift`, and `BeautySafetyCaps.swift` — repeated field propagation, caps, active/skip routing, zeroing, and reuse scaling.
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` and `GeometryConflictResolver.swift` — existing bridge/tip regions, additive combined geometry, and weakening enumeration.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` — renderable-point filtering and additive per-pixel displacement behavior.
- `BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift`, `MissingLandmarkDegradationTests.swift`, and `CombinedEffectSafetyTests.swift` — current provider, freshness, redaction, and combined-safety patterns.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` and `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — canonical renderer matrix and one-field-per-case boundary.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, `EXAMPLE_IMAGE_VALIDATION.md`, and `features/beauty-shaping/nose/README.md` — authoritative tool/branch statuses, output protocol, and documentation ownership.
- `BeautyDemo/BeautyDemoTests/ParameterJSONCodingTests.swift` — Demo schema, deterministic export/import, and redacted decode errors.

---
*Pitfalls research for: v1.9 Nose Remaining Tools and Branch Closeout*
*Researched: 2026-07-13*
