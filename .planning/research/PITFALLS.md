# Pitfalls Research

**Domain:** Public-facade mouth geometry and lip-color evidence for the existing-parameter iOS beauty SDK slice
**Researched:** 2026-07-13
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Signed mouth controls are proved only at the provider layer

**What goes wrong:** `mouthSize` or `mouthWidth` accepts negative input, but a later normalization, conflict-resolution, render, or evidence step folds it through `abs`, so positive and negative public-facade outputs are indistinguishable or move in the same direction.

**Why it happens:** Current provider tests correctly assert expand/contract and widen/narrow, but provider evidence does not prove that the public `BeautySDK` facade preserves direction through detection, planning, unified warp, image rendering, and saving. A visible difference from no-op also does not prove opposite directions.

**How to avoid:** Keep signed caps and sign preservation explicit at every boundary. Add paired positive/negative renderer cases for both fields, direct positive-versus-negative output comparisons, and focused tests that combined weakening reduces magnitude without changing sign.

**Warning signs:** Renderer inventory has only one sign; assertions use only `abs`; tests compare each signed output only with baseline; positive and negative output hashes/pixel deltas are identical.

**Phase to address:** Phase 33 renderer/output evidence, then Phase 34 safety closeout.

---

### Pitfall 2: Skipped mouth geometry remains non-zero in the effective plan

**What goes wrong:** Missing, no-face, or stale mouth geometry is marked skipped, yet `mouthSize`, `mouthWidth`, or `smile` remains non-zero in `effectiveStrengths`. Downstream code or future refactors can accidentally render a domain that the plan claims was disabled.

**Why it happens:** The current resolver explicitly zeroes skipped eye and nose strengths, but the mouth branches only update `skippedDomains` and metrics. Existing tests mostly assert domain membership, not fail-closed values.

**How to avoid:** Add one mouth-domain zeroing helper and invoke it for stale geometry, missing outer lips, and no usable face. Assert all three geometry fields are exactly zero while safe color/filter domains continue. Keep reused usable geometry active at the established exact `0.5` scale and assert signed values retain direction.

**Warning signs:** A plan contains `.mouth` in `skippedDomains` and a non-zero mouth effective strength; stale/no-face tests omit strength assertions; degradation behavior differs depending on entry route.

**Phase to address:** Phase 34 safety closeout.

---

### Pitfall 3: Geometry freshness and lip-color containment are conflated

**What goes wrong:** Either lip color is weakened as if it were a warp strength, or stale mouth coordinates continue driving a color mask simply because outer-lip points are non-empty. Conversely, fixing mouth geometry by zeroing all mouth-adjacent values can incorrectly suppress a safe color-domain path.

**Why it happens:** Geometry and `lipColor` depend on the same outer-lip landmarks but belong to different render domains. Current reusable-geometry scaling includes only mouth geometry, while current lip-color activation checks landmark presence but not freshness. The correct policy must therefore be stated and tested rather than inherited accidentally.

**How to avoid:** Treat `.mouth` and `.lipColor` as separate domains with a shared input-validity contract. Geometry gets signed caps, conflict weakening, and reuse scaling; color remains unsigned and must never enter geometry weakening. Explicitly decide and lock stale/reused color-mask behavior, with fail-closed behavior for absent or unusable mouth ROI and safe-domain continuation.

**Warning signs:** `lipColor` appears in geometry weakened-count expectations; a stale geometry plan leaves `.lipColor` active without an explicit contract; mouth skip logic zeros or scales `lipColor`; tests activate both domains but assert only one.

**Phase to address:** Phase 34 safety closeout, with separate Phase 33 output cases.

---

### Pitfall 4: Combined weakening is incomplete or direction-destroying

**What goes wrong:** Some mouth geometry fields escape multi-domain weakening, `smile` is counted inconsistently, signed fields cross zero, or `lipColor` is mistakenly included in the geometry weakened count.

**Why it happens:** Generic combined-effect tests commonly sample one representative mouth field. Mouth has two signed fields, one positive-only geometry field, and one non-geometry color field, so representative coverage hides classification errors.

**How to avoid:** Use a table-driven test for `mouthSize+`, `mouthSize-`, `mouthWidth+`, `mouthWidth-`, and `smile`. For each, assert non-zero reduced magnitude, exact sign preservation where signed, the warning and redacted numeric metrics, and the expected weakened count. Add an all-mouth case proving `lipColor` remains outside geometry scaling.

**Warning signs:** Only `mouthSize: 1` is tested; weakened count is asserted with `> 0` rather than an exact value; no negative combined case exists; changing `lipColor` changes geometry scale.

**Phase to address:** Phase 34 safety closeout.

---

### Pitfall 5: Output evidence uses an ROI that cannot distinguish the claimed effect

**What goes wrong:** Whole-image or central-face comparison passes because of watermark, lip color, another active effect, resampling noise, or changes outside the mouth. A signed pair can also differ without proving that the difference is localized to the intended mouth region.

**Why it happens:** Earlier nose/eye helpers establish dimension and watermark-exclusion patterns, but their central-feature ROI should not be copied blindly. Mouth geometry and lip color need a lower-central-face ROI, and mixed cases cannot attribute the change to one domain.

**How to avoid:** Keep cases single-parameter except for one explicitly labeled mouth combo. Exclude the watermark band, use a documented lower-central mouth ROI on usable portrait fixtures, compare geometry cases against the geometry no-op baseline, compare both signs directly, and validate `lipColor` independently. Keep representative no-face checks extent-preserving and fail-closed.

**Warning signs:** Comparisons include the bottom watermark; only full-frame byte inequality is asserted; geometry and lip color are enabled together; the ROI is copied from nose/eye evidence without coordinates; no positive-negative comparison exists.

**Phase to address:** Phase 33 renderer/output evidence.

---

### Pitfall 6: `lipColor` evidence is promoted as true `丰唇` geometry

**What goes wrong:** The ledger marks `丰唇` implemented because lip pixels visibly change, or branch-level `嘴唇` becomes implemented after only the existing four public parameters are evidenced.

**Why it happens:** The Demo historically maps `丰唇` to `lipColor`, while the authoritative ledger already says color evidence is not plump-lip geometry. Marketing labels and product-neutral SDK parameters are not a 1:1 semantic match.

**How to avoid:** Promote exactly `大小`, `宽度`, and `微笑` when facade-visible geometry plus safety evidence passes. Record `lipColor` as distinct color-domain evidence, not a promotion basis for `丰唇`. Keep `丰唇` partial, all unmapped rows future, and branch-level `嘴唇` partial.

**Warning signs:** More than three rows change to `implemented`; `丰唇` cites a `lipColor` renderer case; documentation says four implemented mouth rows; branch status loses `partial`.

**Phase to address:** Phase 34 ledger/document closeout.

---

### Pitfall 7: Evidence leaks face-derived data or generated artifacts

**What goes wrong:** Warnings, metrics, gallery manifests, filenames, or committed PNGs expose landmarks, boxes, paths, face observations, image bytes, or fixture-derived artifacts. Ignored output may also be accidentally force-added.

**Why it happens:** Mouth evidence naturally tempts developers to log ROI coordinates and landmark availability while debugging. Gallery generation creates a large set of plausible-looking artifacts that can escape containment even when the main output directory is ignored.

**How to avoid:** Keep warnings categorical and metrics numeric/count-only; never serialize raw points or boxes through public/SPI types. Use established ignored output/gallery directories, static case IDs without user data, and finish with tracked/untracked/ignore scans. Evidence documents should contain counts and commands, not sensitive coordinates or image payloads.

**Warning signs:** Metadata contains `landmark`, `controlPoint`, bounding coordinates, private paths, observation types, or numeric point arrays; `git status` lists generated PNGs; evidence links generated images as tracked baselines.

**Phase to address:** Both phases; final enforcement in Phase 34.

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
| --- | --- | --- | --- |
| Reuse provider tests as facade evidence | No renderer/helper work | Cannot prove detection-to-saved-output wiring or signed direction | Never for ledger promotion |
| Copy nose/eye ROI unchanged | Fast helper reuse | False positives or missed mouth changes | Never; reuse decoder/invariant machinery only |
| Skip a domain without zeroing strengths | Smaller resolver diff | Plan state becomes internally contradictory and unsafe to consume | Never |
| Treat all outer-lip consumers as one domain | Simple degradation branch | Geometry scaling contaminates color, or stale color masks remain active | Never |
| Promote by public-field count | Easy documentation update | Overclaims `丰唇` and whole-branch completeness | Never |
| Commit visual baselines | Easy review | Repository growth and unapproved artistic golden files | Only under a separately approved baseline policy; out of scope here |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
| --- | --- | --- |
| Public facade -> resolver -> unified warp | Prove only `MouthWarpProvider` movement | Run public-facade saved-output cases and focused facade tests |
| Detection -> outer-lip geometry | Treat non-empty points as fresh/usable | Apply explicit absence, reuse, and stale policy before either dependent domain activates |
| Mouth geometry -> conflict resolver | Weaken one representative field or include `lipColor` | Cover every geometry field and exclude color from geometry counts/scales |
| Lip color -> render mask | Use geometry output as color evidence | Give `lipColor` its own isolated output and containment checks |
| Renderer -> helper/gallery | Compare raw full frame | Decode dimensions, exclude watermark, use mouth ROI, direct signed pairs, and keep outputs ignored |
| Evidence -> feature ledger | Map `lipColor` to `丰唇` | Promote only the three semantically matching geometry rows |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
| --- | --- | --- | --- |
| Separate warp passes per mouth control | Redundant sampling and inconsistent combined output | Preserve one unified geometry pass with merged control points | As soon as multiple mouth/face controls are enabled together |
| Whole-frame evidence scans for every assertion | Slow gallery validation with weak attribution | Decode once per file and calculate bounded mouth/watermark-safe regions | Across the full fixture-by-case matrix |
| Extra detection solely for lip color | Duplicate work and divergent face selection | Reuse facade-selected face geometry under the same validity contract | Still-image matrix and especially realtime preview |

## Security Mistakes

| Mistake | Risk | Prevention |
| --- | --- | --- |
| Logging mouth ROI or raw outer-lip points | Face-derived biometric geometry leakage | Categorical warnings and aggregate numeric metrics only |
| Returning geometry through public/SPI evidence helpers | Expands privacy-sensitive API surface | Keep helpers image/count based and geometry internal |
| Committing gallery/output PNGs | Persists fixture-derived face images | Ignore directories and verify zero tracked generated artifacts |
| Adding network/dependency paths for validation | Violates local-first SDK boundary | Use standard-library/local test helpers and bundled fixtures only |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
| --- | --- | --- |
| Negative size/width behaves like positive | Slider direction feels broken and unpredictable | Lock opposite facade-visible directions |
| Stale geometry continues moving/coloring lips | Mouth jumps or mask drifts off the face | Fail closed or apply the explicitly tested conservative reuse policy |
| Lip color labeled as plump lips | User expects shape/volume but receives tint | Keep color and true plump geometry named and evidenced separately |
| Missing mouth disables unrelated effects | Brightness/filter unexpectedly disappear | Skip only `.mouth`/`.lipColor` as applicable; continue safe domains |

## "Looks Done But Isn't" Checklist

- [ ] **Signed geometry:** Both signs render and differ from each other in the mouth ROI, not merely from no-op.
- [ ] **Facade wiring:** Evidence runs through `BeautySDK`, not only resolver/provider internals.
- [ ] **Fail-closed state:** Missing/no-face/stale skipped mouth strengths are exactly zero.
- [ ] **Reuse policy:** Geometry stays at the exact established `0.5` scale with sign preserved; color behavior is independently explicit.
- [ ] **Domain separation:** `lipColor` is absent from geometry weakening and has isolated evidence.
- [ ] **Output validity:** Every output is non-empty, same-dimension, watermark-safe, and attributable to its case.
- [ ] **Ledger honesty:** Exactly `大小`, `宽度`, and `微笑` become implemented; `丰唇` and branch-level `嘴唇` do not.
- [ ] **Containment:** Warnings/metrics are redacted and zero generated PNG/gallery files are tracked.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
| --- | --- | --- |
| Signed outputs collapse | MEDIUM | Trace sign through normalization/resolver/provider, add paired tests, regenerate ignored evidence |
| Skipped strengths remain live | LOW | Add mouth zeroing helper, cover every skip route, rerun focused facade/degradation suites |
| Lip color and geometry are conflated | MEDIUM | Split policy/tests/metrics by domain and rewrite evidence claims before promotion |
| Wrong ROI produces false evidence | MEDIUM | Invalidate counts, define mouth ROI, rerun helper and gallery, update evidence document |
| Ledger overpromotion | LOW | Revert unsupported rows/status, run exact-row guards and current-owner documentation scan |
| Generated/private artifacts leak | HIGH | Remove artifacts from index/history as appropriate, rotate unsafe fixtures if needed, strengthen ignore/redaction scans |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
| --- | --- | --- |
| Signed facade direction | Phase 33 + 34 | Paired positive/negative output comparisons and sign-preserving combined tests |
| Non-zero skipped strengths | Phase 34 | Exact-zero assertions for missing, no-face, and stale routes |
| Geometry/color conflation | Phase 34 | Separate active/skipped-domain, freshness, scale, and weakened-count assertions |
| Incomplete combined weakening | Phase 34 | Table-driven five-direction geometry matrix plus color exclusion |
| Invalid output ROI | Phase 33 | Mouth-region comparisons excluding watermark; isolated cases and no-face invariants |
| Ledger overclaim | Phase 34 | Exact three-row guard, `丰唇` partial guard, branch partial guard |
| Redaction/artifact leakage | Phase 33 + 34 | Forbidden-token scans, public/SPI boundary scans, ignore checks, zero tracked PNGs |

## Sources

- `.planning/PROJECT.md` — v1.8 goal, scope, and exact promotion boundary.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — current caps, activation, degradation, combined weakening, and the mouth zeroing gap.
- `BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift` and `MouthWarpProviderTests.swift` — current signed geometry semantics and provider-only evidence.
- `BeautySDK/Tests/BeautyEffectsTests/MissingLandmarkDegradationTests.swift` and `CombinedEffectSafetyTests.swift` — existing absence/reuse/stale and combined-effect coverage.
- `docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md`, `features/beauty-shaping/README.md`, and `features/beauty-shaping/lips/README.md` — authoritative row status and `lipColor`/`丰唇` distinction.
- v1.6 eye and v1.7 nose milestone artifacts — established public-facade evidence, signed comparison, degradation, redaction, documentation, and artifact-containment patterns.
- `$HOME/.codex/get-shit-done/templates/research-project/PITFALLS.md` — research structure.

---
*Pitfalls research for: v1.8 Broader 美型 / 五官 SDK Slice - Mouth*
*Researched: 2026-07-13*
