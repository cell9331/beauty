# Pitfalls Research

**Domain:** Adding five mouth geometry controls to a shipped local-first iOS SDK
**Researched:** 2026-07-14
**Confidence:** HIGH

## Critical Pitfalls

### 1. Borrowed Semantics

**Failure:** `M唇` reuses mouth size/smile vectors or `丰唇` reuses `lipColor`, so the ledger says independent while the SDK output is aliased.

**Prevention:** One public field, one named provider emission, isolated facade cases, and pairwise ROI evidence against the most confusable shipped controls.

**Warning signs:** No new support model; equal control points; only aggregate mouth output tests.

**Phase:** 38 contract, 39 output.

### 2. Inner-Lip Absence Drops Valid Whole-Mouth Work

**Failure:** Missing `innerLips` skips translation, tilt, size, width, or smile even though outer lips are sufficient.

**Prevention:** Separate whole-mouth and local-shape eligibility. Sanitize only `lipPeakDefinition` and `lipPlump` when inner/upper/lower support is unavailable.

**Warning signs:** One `hasMouthGeometry` Boolean or one aggregate provider guard.

**Phase:** 38 and exhaustive Phase 40 degradation.

### 3. Provider/Conflict Drift

**Failure:** A field contributes to total, warning, scale, or weakened count but emits no final control point after scaling.

**Prevention:** Extend provider-owned preflight/final field emissions and the monotonic convergence loop to all six nose plus eight mouth geometry fields.

**Warning signs:** Effective non-zero strength with empty field emission; loop still bounded at nine.

**Phase:** 38 implementation and Phase 40 exact-matrix evidence.

### 4. Rotation/Translation Sign Loss

**Failure:** Positive and negative direction produce the same output or one direction is clamped to zero.

**Prevention:** Signed normalization/caps, vector-level direction assertions, plus/minus facade cases, and opposite-direction ROI comparison.

**Warning signs:** `abs` applied before target calculation; only positive renderer cases.

**Phase:** 38 and 39.

### 5. Lip Plump Becomes Whole-Mouth Enlargement

**Failure:** Plump changes mouth width/position or broad surrounding face regions rather than local lip thickness.

**Prevention:** Use upper/lower outer+inner supports with local radii; compare plump against baseline, mouth size, and peak definition in a fixed mouth ROI above the watermark.

**Warning signs:** Cardinal outer-lip points only; identical output to positive `mouthSize`.

**Phase:** 38 provider design and 39 output.

### 6. False Whole-Branch Completion

**Failure:** Five geometry rows pass and docs claim `嘴唇` complete even though `白牙` has no segmentation/retouch evidence.

**Prevention:** Promote exactly five rows; describe mouth geometry subset as complete; keep `白牙` future and branch partial.

**Warning signs:** Branch ledger changes to `implemented`; teeth whitening appears in geometry tests.

**Phase:** 40 closeout.

## Technical Debt Patterns

| Shortcut | Immediate benefit | Long-term cost | Acceptable? |
| --- | --- | --- | --- |
| Derive local lip controls from outer ring only | Less adapter work | Cannot distinguish lip surface from mouth opening | No for M-lip/plump |
| Add explicit zero keys to presets | Makes new schema visible | Hides missing-key compatibility | No |
| One combined mouth helper array | Small provider type | Prevents per-field eligibility and exact diagnostics | No |
| Hard-code expected output count | Fast test update | Drifts when renderer cases change | No; derive the matrix |
| Track generated PNG evidence | Easy inspection | Violates repository binary-media policy | No |

## Performance and Reliability Traps

| Trap | Symptom | Prevention |
| --- | --- | --- |
| Excessive control points/radii | Background or adjacent-feature distortion; higher warp cost | Small fixed point set, bounded radii, exact per-field output tests |
| Non-convergent conflict repair | Repeated recomputation or inconsistent totals | Monotonic mask removal with maximum fourteen changes |
| Stale gallery mixing | Helper passes against old files | Guarded clean generation, exact path bijection, bounded atomic publication |
| Reused/stale policy drift | New fields stay full-strength or leak on stale geometry | Exhaustive eight-field freshness transitions |

## Security Mistakes

| Mistake | Risk | Prevention |
| --- | --- | --- |
| Logging upper/lower/inner support coordinates | Biometric-adjacent data leakage | Stable category codes and aggregate counts only |
| Exposing internal support structs from `BeautySDK` | Public privacy/API expansion | Keep supports package-internal |
| Introducing network or third-party landmark processing | Changes local-first threat model | Use existing on-device Vision path only |
| Publishing untrusted generated paths | Filesystem/symlink risk | Reuse bounded descriptor-safe helper/gallery publication |

## Looks Done But Is Not

- [ ] Legacy 33-field payload decodes all five new fields to exact zero.
- [ ] Each new signed field has both directions in provider and facade output evidence.
- [ ] Peak/plump remain distinct from each other, mouth size, smile, and lip color.
- [ ] Missing inner lips removes only local lip-shape fields.
- [ ] Reused and stale geometry cover all eight mouth geometry fields.
- [ ] Conflict totals/counts/scales match final emitted fields exactly.
- [ ] Outputs/gallery are ignored, untracked, exact-count, and fresh-run derived.
- [ ] `白牙` and branch-level `嘴唇` remain unpromoted.

## Pitfall-to-Phase Mapping

| Pitfall | Prevention phase | Verification |
| --- | --- | --- |
| Borrowed semantics | 38-39 | Independent field/control-point and ROI comparisons |
| Support coupling | 38, 40 | Missing-inner mixed-sibling matrix |
| Conflict drift | 38, 40 | Exact totals, counts, scales, strengths, and emissions |
| Sign loss | 38-39 | Positive/negative vector and output pairs |
| Broad plump distortion | 39 | Mouth ROI and confusable-control comparison |
| False branch completion | 40 | Exact ledger/current-owner scan |

## Sources

- Phase 35 nose/mouth provider-convergence remediations in `PLANS.md` and archived evidence.
- Phase 33-34 mouth output, degradation, boundary, and gallery evidence.
- Phase 36 descriptor-safe renderer/helper/gallery remediations.
- `SECURITY.md` and `RELIABILITY.md` current contracts.

---
*Pitfalls research for: v1.10 Mouth Remaining Geometry Controls*
*Researched: 2026-07-14*
