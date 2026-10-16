# A-2026-10-12-mouth-amplitude

Status: completed for bounded algorithm and slider-response improvement.
The full reference-match targets remain unmet. The owner explicitly requested
further M-lip, negative fullness and horizontal mouth-position optimization
on 2026-10-12.
The [prior bounded implementation](A-2026-10-11-mouth-reference.md)
is historical evidence and remains unchanged.

## Scope and prospective checks

Improve the three existing source-observed fields in the shared still-image
mouth map and their slider response, using the same authorized reference and
two local portraits. Retain field keys, zero/defaults, caps, signed directions,
neutral midpoint, invertible slider state and other existing mouth behavior.
No UI layout redesign, model/dependency change or new backend/shader.

Keep the exact observed nose/eye envelope, fixed complete oral band for local
M/fullness, alpha and exterior protection, fail-closed admission, displacement
limit min(0.20 mouth span, 0.06 face pixel short side), and gradient <=0.45.
Investigate source-tissue inverse mapping, source-defined target flattening and
spatially efficient transitions instead of simply raising a cap or weakening
an oracle. Freeze comparisons before candidate output; use the prior source
registration and stable thresholds, without picking new regions for a pass.

Prospective close-reference targets on the matched photo: M paired depth at
least 4/4.8 pixels versus reference 5/6 at the two stable thresholds; negative
fullness thickness within 20% of reference 56/50 pixels (44.8..67.2/40..60);
horizontal paired displacement within 20% of reference 57 pixels (45.6..68.4).
These are task-specific comparison goals, not general perception claims.
Every retained change must improve its baseline metric without a new inverted
M, lip wave, oral crack, corner pinch or nasal-base skin step. The second photo
is an independent no-worsening check, not a matching Meitu endpoint. Source
flat-bow, thin tissue, absent/malformed support and protected-color negatives
remain required; quarter-step monotonicity and accurate neutral crossing must
hold. A missed target remains unmet, even if all engineering tests pass.

## Minimal validation and ownership

Root owns production map/helper edits and current owner/plan documentation.
Parallel agents examine X constraints, M/fullness mathematics, and independent
reference measurements; they do not concurrently mutate the map or shared
build cache. Use the stable BeautySDK/.build incrementally, with directly
related map/facade/helper tests; no complete SDK regression. Select only
changed-field/public-protection cases during iteration, then the three mouth
classes once the final source is chosen, including actual selected Metal.
Use the existing external host only for necessary slider behavior and two-photo
MediaPipe confirmation, one claimed existing simulator and its stable build
cache. Preserve older failures and caches; no new/clone device or full App.
Raw geometry/media remain local temporary/ignored; persisted evidence is
anonymous aggregate only. Review actual final pixels at original detail.

## Slider continuity hypothesis

Before candidate changes, add a source-defined near-neutral combination test:
retain an existing X/M/fullness edit and add either other field at normalized
+/-0.00001. Maximum sampled displacement change must remain below 0.01 pixel
on a 240x320 registered fixture. Current pure-field envelope switching and
full-strength sign ceilings may cause a discontinuity; preserve the actual
failing baseline if reproduced, and address only the direct mouth path.

## Actual checks

- Baseline slider-continuity regression: one executed test failed with 40
  assertions, maximum sampled jump 0.987725 px versus the predeclared 0.01 px.
  Production was still the prior v9; this is a newly reproduced defect, not
  a relabeled historical pass. The baseline log and anonymous aggregate are
  retained locally.

- First fix build stopped before test execution in the parallel nose task's new
  Metal-runtime test expression. That task independently simplified its byte
  generation; no mouth-side change to the runtime/test/threshold was made.
  Retrying the same selection executes two mouth cases, both pass (no skips):
  near-neutral continuity and existing combination/sampling bounds. This does
  not validate the separate nose GPU change or a complete SDK suite.
- Three separate component fields now retain their own source-fixed admission;
  only the actual sum is limited. Single-field formulas remain at the prior
  version at this checkpoint. Reconstructed same-source photo baselines match
  prior M 3/3, negative thickness76/71.5 and X39.5 exactly.
- M2/F4 and union-grid composition interim: six selected map tests pass,
  zero failures/skips, including flat negative M, thin upper tissue, both-sign
  quarter steps, complete oral/feature/alpha protection and near-neutral
  combinations. The first invocation was sandbox-blocked before compilation
  because the existing Clang cache was not writable; the authorized cache
  retry passed. No full SDK or native claim attaches to this checkpoint.
- Static review caught a new combination-admission error: individually
  pose-attenuated fields could sum past the reduced pose budget. One new test
  reproduced two gradient failures (.27248/.31683 versus.225 for pose.5).
  The combined limit now retains pose once; low-strength sums are not reduced
  twice. That case plus neutral continuity and the admitted flat-M negative
  control pass3/0/0 after repair. The three-class selection at that checkpoint is28 cases.
- Selected X3 first public check: the existing position/four-step width case
  and near-neutral combination case pass2/0/0, with no tolerance changes.
- First candidate source SHA256
  `a06b1e1c947f501c39450866e4e8921ad0fe11fe932c657599246f03d482a4d7`:
  `swift test --package-path BeautySDK --filter 'MouthContinuousMapTests|BeautyEngineMouthReferenceTests|BeautyMouthSliderTests'`
  passes **28 tests / 0 failures / 0 skips** (14 map,11 facade,3 helper),
  including the actual Metal runtime32-invocation assertion. The14-map count
  includes three new regression cases. No complete SDK suite was requested/run.
  `bash scripts/check-sdk-only-boundary.sh --post-archive` also passes.
- X3 arbitrary-strength shadow check: two sources/two signs/110 fractions
  each =440 requests;428 admitted and12 expected existing near-neutral no-ops.
  No unexpected nil, direction reversal, width or safety failures. Largest
  material-corner width error0.224394px remains below the unchanged.45px
  limit; minimum regular1% increment0.207127px. All four chosen endpoint
  RGBA outputs equal the frozen X3. The added actual-strength fallback was
  never needed on these samples; its triggered branch has static review,
  not a claimed dynamic exercise. This diagnostic does not replace public tests.
- First candidate public photo check independently links the same source (102 existing
  objects, module/object identity unchanged before/after), generates14 actual
  outputs, and confirms RGBA equality with the selected M2/F4/X3 candidate.
  Neutral equals source; alpha, full fixed eyes, forehead and exterior are
  exact. M pair4/4, negative thickness72/69, positive thickness113/109 and
  X pair49.5 on A/51.5 on B reproduce the selection. Original-size detail
  review again finds no definite new crack, pinch, wave or nasal-base step.
  `mouth-ref-003.jpg` is a new stripped/compressed display preview, not an oracle;
  prior001/002 are retained. The media check passes after its generation.

## Candidate comparison checkpoints

- M1 analytic tissue inverse improved one primary threshold but was not robust
  at the other. M2 retains the original positive endpoint and completes the
  same source-defined negative flattening displacement within available tissue.
  Independent shadow comparison: paired4/4 versus3/3; auxiliary subpixel
  3.7496/3.9187 versus2.8945/3.2165. Positive pixels are unchanged. First
  prospective target is met; second4.8 remains unmet. No new inverted M,
  waves or pinching in the two original-size detail reviews.
  The unchanged positive endpoint is5.5/5.5 versus reference5.5/4.5; increasing
  its amplitude merely to improve the paired score would worsen its reference
  match. Available gradient headroom is not evidence for a more accurate shape.
- Negative-fullness F2/F3 shadow candidates:75/72 versus76/71.5. They lack
  robust two-threshold improvement and are rejected, despite improved source
  geometry statistics. A measured visible lower rim lies beyond observed
  outer tissue; a thin-corner propagated ceiling also limits the first cone.
  F4 broadens no halo or protected region. Independent frozen comparison
  improves A to72/69 and B to58/54.5 (previous60/56); auxiliary A measurements
  also improve at both thresholds. Positive fullness stays byte-identical.
  Original-size review finds no definite new nasal/philtrum step, wrinkle,
  corner pinch or crack; broader nasal rectangles still differ by up to19/11
  channel levels, so only the source-defined exact boxes are claimed unchanged.
  F4 is selected for production validation; both reference targets remain unmet.
- Fixed-source RGB contour calculation, using the same100 columns, thresholds
  and observed oral band, gives ideal matched-contour minima71.037/67.588 at
  final inverse gradient.45. The target upper bounds67.2/60 require at least
  .553/.686 in that geometric model. These are inclination-corrected matched
  contour limits, not exact predictions of post-resampling integer threshold
  pixels; preserve the distinction and the unmet comparison targets.
- X p8 distance-field shadow:64.5px pair enters the prospective amplitude
  interval, but actual mouth width increases2.08..4.75%, worse than baseline
  and reference. Reject this candidate for its width regression. A revised
  field will keep horizontal displacement uniform across the mouth core before
  any further amplitude comparison; do not relax the width/no-worsening test.
- X2 rigid-row revision: fixed primary46px but independent texture windows
  give43.33..43.64, below45.6; one endpoint contracts measured width about1..2%.
  Do not accept the integer edge result alone. Source-material corner equality
  is insufficient to establish visible whole-mouth translation; it led to X3.
- X3 solves the forward material-corner positions of the admitted inverse
  field, then applies a local inverse width correction. Safety reductions act
  on the basis before solving again, avoiding width drift from post-scaling.
  Independent photo A primary pair49.5 versus39.5/ref57; three RGB windows
  yield48.761..48.923, all within the prospective interval. B pair51.5 versus34.
  Visible texture span can still change up to about1.23%; this is not exact
  rigid translation. Original-size review finds no definite new lip/crease
  damage, pinch or nasal-base step. X3 is selected; final public and
  arbitrary-strength verification pass as listed above. Native evidence below
  prevents treating the Mac amplitude result as native acceptance.

## Native candidate checkpoint and continued diagnosis

- The same a06b source passes five selected native tests, zero failures/skips,
  on one claimed existing iPhone 15 Pro/iOS 17.5 simulator: three mouth-control
  contracts and two portrait acceptance cases. All 32 signed endpoints and
  four smile-X checks retain direction/protection/repeat/alpha assertions;
  neutral/restore/source preservation, 720x960 sRGB and 478-point metadata pass.
  This is an engineering checkpoint; the claim and shared build cache were
  released after the run. No UI layout or complete App regression was run.
- Independent 34-output review finds native A M pair3.5/2.5 versus common-scale
  reference5/5.5, negative-fullness79/75.5 versus56/51, and X pair34 versus57
  after normalization to the original axis. Positive fullness111/107 remains
  near reference113/107.5. These MediaPipe results are distinct from the Vision
  measurements above; they do not inherit the Mac improvements.
- Same host direction oracle, previous native to this candidate: negative M
  A−.3445→−.830314 and B−.3430→−.436808; negative fullness A−5.875→−6.625969
  and B−5.518→−6.142864. X paired native displacement A13.718635→13.624758
  (no improvement), B14.411701→15.510175 (small improvement). The native A X
  result does not satisfy the prospective improvement condition.
- Continue diagnosing actual native source support, pose and X correction
  budget before selecting a final implementation. Do not substitute Vision
  geometry, relax width/protection/gradient checks, or mark reference parity.
  Candidate preview004 and all temporary evidence remain available; cleanup
  and final native validation declarations are on hold.

- Temporary native budget diagnostic: one additional selected case passes,
  zero failures/skips, on the same claimed/released existing simulator. Both
  fresh production detections have geometryScale1; neutral and all12 selected
  production endpoints reproduce r1 full RGBA exactly. Four X shadows and32
  M/fullness quarter-step shadows also match production pixels/gradient/
  displacement, with sampled field differences <=1e-8. Only anonymous numeric
  aggregates are retained; observations and transform matrices stay in memory.
  Temporary host test sources/project references/flags were removed after use.
  The stable host cache now contains diagnostic artifacts and requires a fresh
  selected-source build before any subsequent final native run. This diagnostic
  does not add an appearance qualification or replace the five-case checkpoint.

## Native-informed candidate hypotheses

Before inspecting new candidate pixels, retain these bounded hypotheses:

- Native X stage diagnostics show the first distance field reaches gradient.45
  with only about1% reduction. Width compensation raises intermediate gradients
  to .594...695, then the nonlinear ratio reduction leaves final gradients
  .392...409 and basis factors .644...754. Replace the compensating width field
  in one shadow candidate with a source-fixed distance cone and exact C1 cap;
  a shared plateau over both corner trajectories should retain material width
  without paying that extra gradient. Keep all original displacement, gradient,
  width, protected-pixel and same-reference checks. Reject visual width/shear
  regressions even if a center-position scalar improves.
- Native positive M has no global safety reduction. Its near-nose feather is
  only about.40...49 on A's visible upper boundary; its whole-mouth weight is1.
  One candidate shortens only thin-source positive-M transition smoothly from
  .25span toward.20span, using the existing source tissue/amplitude-cap ratio.
  Exact nasal/oral protection and target peak displacement remain unchanged.
  Thick-source Mac positive outputs must remain byte-identical, and native
  single-end shape must improve without relying only on the paired score.
- Native negative-fullness matched-contour minima at gradient.45 are
  77.39965/74.00152 versus current geometric78.94121/75.41781. The fixed oral
  envelope is34.00394 canonical pixels (not the Mac13.31), with pose1.
  Reaching reference56/51 would need gradients1.8571/2.4124 in this matched
  contour model; even the20% upper interval needs.8944/1.1325. The comparison
  target therefore remains unmet. These are geometric contour bounds, not an
  exact theorem about resampled integer-color thresholds.
- The continuous negative-fullness p8 distance cone is1-Lipschitz, but the
  admitted bilinear lattice has raw gradients1.12359/1.10476 on native inputs.
  One F5 shadow candidate doubles only this field's grid from96x72 to192x144,
  retaining every formula, anchor and actual-cell.45 test. This may recover
  limited discretization loss; it cannot remove the oral constraint. Do not
  apply this argument to M−, whose source profile has no matching bound.

- A generated near-nose regression was frozen before the X4 output: the
  existing480x600 anatomy moves only its nose contour down.04 normalized Y.
  The original-grid distance cone and fixed anchors give a corner-motion lower
  bound18.2238px; require at least18.20px with the unchanged.45px width tolerance,
  quarter-step monotonicity, .45 gradient, displacement cap and feature zeros.
  Running the new single SDK case against unchanged a06b reproduces two failed
  endpoint assertions (17.407268px in both signs), with all other assertions
  passing. The threshold is for independently inverted source material corners;
  it is not substituted for the separate actual-pixel width/reference oracles.

## Native-informed selection

- The temporary native M3/F5/X4 shadow case passes1/0/0. Its48 signed quarter
  steps retain direction, monotonicity, complete oral protection for M/fullness,
  feature/exterior/alpha zeros, repeatability and the original gradient/radius
  bounds. All14 control frames equal the a06b native checkpoint; candidate
  neutral, negative M and positive fullness are byte-identical. This is a
  separate schema1 diagnostic, not a production schema4 acceptance receipt.
  Temporary test sources/references/flags are removed and the device released.
- Independent native original-size review: A M pair3.5/2.5→4/3.5; positive
  endpoint4.5/3.5→5/4.5 against common-scale reference5.5/4.5. Negative fullness
  79/75.5→78/75 (auxiliary79.7217/76.5097→79.1536/75.9732); B63.5/59→63/59.
  X A34→37.5, B36→39.5; all three fixed RGB windows confirm improvement,
  while A remains below45.6. One B negative-end window retains one-pixel
  matching ambiguity; material-corner equality does not imply texture rigidity.
  No definite new pinches, waves, oral cracks or nasal-base steps are seen.
- The same fixed Mac oracles give M4/4 (positive M byte-identical to a06b),
  negative thickness72/69 with roughly.5px auxiliary improvement, X50 on A
  and51.5 on B. A RGB windows49.5489..49.5734 remain within the original
  ±20% interval, with texture-span changes about−.306..+.386%. Mac and native
  use different source observations and remain separately reported.
- One last native X feasibility diagnostic passes1/0/0; all four X4 endpoints
  equal the prior shadow in full RGBA and field bounds. With the same fixed
  zero anchors, gradient.45 and .45px material-corner width tolerance, solve
  t<=.45*distance(destination,anchors) for both corners and each sign. A mean
  corner-motion necessary upper bounds are9.469678/8.854677 native pixels,
  paired43.97845 in original-axis units, versus the45.6 target lower limit;
  B bounds are10.454195/9.211745. The weak anchor is the nose in all cases.
  These are necessary bounds only for the current mouth-axis horizontal
  material-corner model, not general texture, rotation/vertical-field or
  universal appearance impossibility proofs. Raw geometry remains in memory;
  only anonymous scalars were saved. Temporary host code/flags are removed.
- Select M3/F5/X4 for their actual improvements, with all original protection
  and width limits retained. No further parameter sweep or cap increase.
  The prospective native X, negative fullness and full M paired targets remain
  unmet; this selection is a bounded implementation improvement, not reference
  qualification. Negative M retains the already improved M2 target/ramp.

## Final selected production checks

- Production SHA256
  `dbbe5d135ec95edc4d416633985432fa762badacb2ac02773bd47622ee1022f7`
  contains the minimal X4/M3/F5 changes with the existing M2, independent-field
  composition and once-only pose budget retained. Independent static review
  finds no new actionable defect; research diagnostics/API are not copied.
- `swift test --package-path BeautySDK --filter 'MouthContinuousMapTests|BeautyEngineMouthReferenceTests|BeautyMouthSliderTests'`
  passes **29 tests / 0 failures / 0 skips**:15 map,11 public facade,3 helper,
  85.755 seconds. The new near-nose case is green after its retained two-assert
  failing baseline; all four new regressions and previous actual pixel tests
  pass. The actual selected Metal case asserts32 runtime invocations. Build
  completes incrementally. No complete SDK regression is claimed.
- `bash scripts/check-sdk-only-boundary.sh --post-archive` passes for the same
  source. Unrelated concurrent nose/A10 changes are not covered by this scope.

- Final public dbbe5d rendering links102 stable existing objects, whose hashes
  remain unchanged. All14 outputs equal the selected M3/F5/X4 candidate in
  full RGBA; neutral/source, alpha, eyes, forehead and exterior are exact.
  Fixed review reproduces M4/4, negative thickness72/69 (auxiliary
  72.9896/69.8197), X50 on A and51.5 on B. New stripped/compressed preview005
  is labelled Vision final; earlier previews001..004 remain unchanged.
  The example-media check passes after publication. The review does not turn
  missed M/fullness targets into passes or infer native performance.

- Fresh final native build succeeds after removal of diagnostic target sources
  and flags. The same dbbe5d production source passes **5 tests / 0 failures /
  0 skips**: three MouthControlContractTests and both MouthPortraitAcceptanceTests,
  50.694 seconds, one claimed existing iPhone15Pro/iOS17.5 simulator. All32
  signed endpoints and four smile-X checks retain direction, source/neutral/
  restore/repeat, feature/oral/alpha protection and720x960 sRGB/478-point
  metadata assertions. The claim releases after testing. No complete App,
  UI-layout matrix or physical-device/performance validation is implied.

- Final production native inventory contains34 PNGs (17 per source), with
  dimensions and all16 signed-frame schema4 receipts per source crosschecked.
  The selected14 neutral/M/fullness/X frames equal the prior schema1 candidate
  in full RGBA, with receipt identities kept separate. Independent fixed
  measurements therefore retain the selected native values above. Other
  controls retain the five-case production assertions; they were not relabelled
  as a new independent reference-metric measurement.

## Checklist

- [x] Confirm explicit renewed scope, shared modifications and prior limits.
- [x] Diagnose and test source-registered candidate mechanisms.
- [x] Implement selected algorithms and justified slider response changes.
- [x] Run final scoped SDK and applicable native/pixel verification.
- [x] Update current contracts, comparison previews, debt and completion record.

## Completion

| Field | Value |
| --- | --- |
| Completed | 2026-10-12 |
| Status | `completed` for the bounded changes; complete reference appearance remains unmet. |
| Scope | Source-defined M flattening/thin-tissue positive transition, negative fullness distance field/refined lattice, shared X trajectory plateau, and cross-neutral/pose slider composition. |
| Rationale | Improve visible mouth response while preserving the complete oral band, exact source nose/eye protections and original safety budgets. |
| Files | BeautyContinuousMouthMap.swift; MouthContinuousMapTests.swift; mouth guide, DESIGN, RELIABILITY, taxonomy, QUALITY_SCORE, current debt and plan indexes. External host temporary diagnostics were restored; no new UI layout. |
| Verification | Final29 SDK and fresh5 native cases, all zero failures/skips; actual selected Metal32 calls; public14 and native selected14 full-RGBA candidate identity,34 native inventory/receipt checks; fixed reference oracles and original-size review. Boundary and local documentation/media checks pass. |
| Build | Incremental SwiftPM and fresh host test build pass using stable caches. One existing simulator claimed and released. |
| Limits | Complete M paired range, negative thinning and native X reference goals remain unmet. The two source-observation paths differ. No full SDK/App, physical-device performance, general portrait/teeth naturalness or distribution qualification. |

The actual source code contains no temporary diagnostic fields, geometry dump,
new model/backend or raised threshold. Negative-fullness refinement increases
that field's lattice cost; measured test duration is not an interaction-FPS
claim. New compressed previews005/006 identify Vision and native separately.
All earlier previews and dated failures retain their original meanings.

After all readers completed, one guarded explicit manifest removed355 owned
reproducible derived-media files (1,235,596,319 bytes). Each file's identity and
hash were rechecked first. The118 direct non-media files in touched directories,
all six mouth previews and18 original photos/reference inputs remain SHA-exact.
Original inputs, uncertain staging, program/build caches and xcresults were
not deleted. Anonymous receipts, source programs and logs remain available;
no raw geometry, pixels or private fixture locators are copied into this record.

Final documentation verification checks208 local link targets and7 anchors
without errors; `git diff --check` and untracked mouth source/test whitespace
checks pass. The final media check reports44 images/18 previews within policy.
The production map SHA remains the exact dbbe5d source tested above.
