# A-2026-10-11-eye-reference

| Field | Value |
| --- | --- |
| Status | `completed` for the bounded algorithm/slider implementation; complete Meitu appearance and sparse-iris amplitude remain unmet. |
| Owner | SDK / owner editor task |
| Started / Completed | 2026-10-11 / 2026-10-12 |
| Scope | Reference-guided eye geometry and centered host sliders; exclude upper-eyelid fullness and sclera redness as explicitly requested. |
| Source Request | Owner's 23 eye-control screenshots, algorithm improvement plus slider wiring, and instruction to complete the confident controls first. |
| Expected Behavior | Distinct signed eye-shape fields, source-fixed continuous deformation, protected unrelated features, separate height/iris controls and correct reference tilt polarity. |
| Current Step | Bounded implementation and scoped verification complete; input/appearance limits retained below. |
| Verification Policy | Direct parameter/resolver/provider/geometry/public CPU+Metal pixel tests, actual local portrait comparison, existing single-device host unit/UI checks. No full SDK/App suite or new simulator. |

| Step | Status | Evidence |
| --- | --- | --- |
| Inspect reference and code | `completed` | Eleven endpoint pairs establish distinct directions; eight fields needed signed reconstruction, and the host lacked five entries. Screenshot endpoints do not establish numeric values or a neutral baseline. |
| Implement algorithms and sliders | `completed` | Source-fixed observed-eye map, eleven centered helper mappings, separate height/iris entries, two cross-zero repairs and aperture-contained sparse positive pupil safety repair; keys/defaults/caps retained. |
| Verify | `completed` within stated domains | 89 distinct direct SDK tests and 10 host tests pass, zero failures/skips. Twenty actual shape endpoints pass direction/separation and source-defined protection; sparse pupil safety passes after repair, while its appearance-amplitude predicate remains failed. |
| Record outcome | `completed` | Contract owners updated; complete appearance, actual dense portrait inference and the unrelated combination-fixture failure remain explicit. |

## Change and rationale

The measured-eye route replaces competing legacy point pulls with independent
size, position, height, length, spacing, lower-lid, tail, tilt and corner
components on source-fixed pixel axes. Dense visible-ring support admits both
iris signs. Per-field cap admission and actual-combination limits avoid an
infinitesimal sibling unexpectedly shrinking an existing edit. The iris
component remains inside the source aperture even when a sibling crosses zero.
CPU and Metal still-image execution share this CPU-owned sampler; other
geometry stages retain their independent ordering and limits.

Actual sparse-Vision inspection found that the previous positive pupil point
route moved eyebrows. Valid measured sparse eyes now use a positive-only
aperture-contained compatibility transform with a soft edge; an interior pupil
center is required, and no measured iris radius is claimed. Negative sparse
iris and invalid dense-ring evidence exit without borrowing a peer or restoring
old points. Completely unobserved coarse positive compatibility is retained.
The lattice gradient bound does not include the final raster gate/feather's
derivative. Feature-path protection also does not establish complete semantic
nose/lip boundaries. See the [current contract](../../../docs/sdk/EYE_SHAPE_SLIDERS.md).

`BeautyEyeShapeSlider` maps 0...1 around exact neutral .5, preserves normalized
siblings and supports inverse selection/undo mapping. Tilt reverses the direct
API polarity to match the reference; tail lift retains its opposite direction.
The external owner editor adds size, position, length, spacing and iris entries,
keeps `eye.eyelidSize` as height, and uses a distinct `eye.irisSize` binding.
Native SF Symbols and the existing panel layout remain in the separate host.

SDK source changes are limited to the eye helper/parameters, signed planner,
combination/backend validation, eye provider, continuous eye map and shared
stage's eye integration. Eye tests and the exact reviewed public-test hash were
added to the existing boundary check. Shared files also contain concurrent
nose/mouth edits; those edits are not this task's delivered or verified scope.

## Executed verification

SDK and native test runs below are dated 2026-10-11; the final documentation,
preview/media containment and completion checks finished on 2026-10-12.

| Check | Observed result and scope |
| --- | --- |
| `swift test --package-path BeautySDK --filter 'BeautyContinuousEyeWarpTests'` | Final **11 / 0 failures / 0 skips**, including three sparse-pupil additions. Two generated aspects, eleven signed dense directions/four steps, iris area, feature/alpha/exterior protection, invalid/missing/stale admission, cross-zero continuity and stage suppression. |
| Initial final direct contract filter below | **77 / 0 / 0**. Together with the earlier eight-map final run this established 85 distinct passing cases. |
| `swift test --package-path BeautySDK --filter 'BeautyEngineEyeSliderTests\|BeautyStillImageGeometryStageTests\|EyeWarpProviderTests\|BeautyDenseSupportTests'` | Sparse repair follow-up **33 / 0 / 0**, including one new public sparse-pupil case. Actual CPU/Metal equality, source-derived exterior protection, four-step response, repeat/neutral/failure/recovery and metadata; existing dense and provider paths rechecked. The union of the direct runs is **89 distinct cases**, not 121. |
| External host selected tests | **10 / 0 / 0**, existing iPhone 15 Pro / iOS 17.5, one claimed simulator subsequently released: seven control-contract cases, one session case, one panel-layout case and one UI case. Actual eleven-control dragging/selection/undo-redo/reset/reachability and four native screenshots inspected. Generated nonportrait input proves bindings/layout, not algorithm appearance. |
| `bash scripts/check-sdk-only-boundary.sh --post-archive` and `--self-test` | Final live boundary and mutation controls pass with the updated exact public-eye test hash. No new GPU API or shader. |
| `python3 -B scripts/archive-legacy-ui.py verify --output archives/legacy-ui` | Both existing archives verified; archives unchanged. |
| `python3 -B scripts/manage-example-images.py check` | Passed before and after the selected compressed preview; raw full-resolution temporary media removed after inspection. |
| Markdown target/anchor and `git diff --check` | Eye contract/completion navigation and whitespace pass. |

Initial final direct contract filter:

```sh
swift test --package-path BeautySDK --filter 'BeautyEyeSliderContractTests|BeautyParametersTests/testEYE|BeautyEffectResolverTests/testEYE|EyeWarpProviderTests|BeautyDenseSupportTests|BeautyEngineEyeSliderTests|GeometryConflictResolverTests|BeautyBackendContractTests|BeautyStillImageGeometryStageTests|BeautyDenseCombinationTests/testDenseMappedFields|BeautyDenseCombinationTests/testSourceRasterBudget'
```

SwiftPM compiled the relevant sources/tests through these targeted commands and
reused its existing cache. No complete SDK or App gate, physical-device matrix,
performance, thermal, power or sustained-use check was run.

## Actual portrait evidence

The input is an owner-supplied Meitu endpoint portrait, **not an untreated
original**. A temporary production macOS/Vision renderer processed neutral plus
22 single-field endpoints at 1170×1550. Each endpoint used one detected face and
passed extent, alpha and exact repeat checks. Display-P3 input and sRGB PNG
output were compared through the same canonical CIContext sRGB raster; neutral
was byte-exact to the canonical source. Differently encoded raw PNG bytes were
not used to waive protection failures.

Source-defined texture patches and eight protected regions were fixed before
endpoint analysis. Direction required >.3 px per eye; independent height/length
axes and fixed opposite corners allowed at most 1.5 px. Twenty shape outputs
pass these predicates with zero changed pixels in the tested brow/nose/lip and
exterior regions. Native-size eye crops were inspected for cracks, hard edges,
ghosting and unrelated feature pulls; none were found in these twenty outputs.
This is one input's limited visual inspection, not general appearance quality.

| Control | Right-minus-left measured endpoint difference, two-eye range |
| --- | --- |
| Size | Width +7.943…10.556 px; height +3.614…3.929 px |
| Vertical position | Down +10.284…11.063 px |
| Height | Height +7.288…7.725 px; independent width change .350….732 px |
| Length | Width +7.919…10.254 px; independent height change .026….031 px |
| Spacing | Each eye outward +5.164…7.833 px |
| Lower lid | Outer-half downward +.435…1.637 px; direction only, no reference-amplitude pass |
| Tail lift | Outer corner up +9.336…11.466 px; inner-corner change 0 |
| Tilt | Outer corner down +7.913…8.875 px; inner corner up +3.529…3.565 px |
| Inner corner | Toward nose +3.236…4.546 px; opposite-corner change 0 |
| Outer corner | Outward +2.477…6.573 px; opposite-corner change 0 |

Sparse iris was rerendered after the safety repair. Both endpoints then passed
the eight protected regions, extent/alpha/repeat/neutral checks; negative size
remained entirely baseline-exact. Positive lid-feature drift was at most .002 px.
The frozen finite-ROI dark-texture area predicate required >3% enlargement per
eye; actual changes were **+2.344% / +1.982%, so it failed**. Native-size review
found the positive change weak with stable lids/lashes and no visible sampling
cracks or ghosts. The predicate is a dark-texture proxy, not iris segmentation;
neither it nor its failure qualifies the dense-ring route's actual portrait
appearance. The threshold and source regions were not relaxed or fitted to the
new output. A small metadata-stripped shape preview is retained only for display.

After native-size review, forty-three task-local temporary files (including all
thirty PNG media copies and the private runner/annotation sources) were removed.
Only six aggregate/log files remain in transient storage. User source files,
other tasks' media and the existing SwiftPM cache were not removed. The retained
shape preview is 1600×529 and 166,910 bytes; the final image-budget check passes.
Final navigation validation covers fourteen affected documents, 333 local link
targets and six anchors, with zero errors.

## Failed attempts and limits

- The first contract run failed six assertions that still expected unit-only
  values or negative support from a coarse fixture; signed expectations and a
  measured fixture were corrected.
- A public generated fixture originally supplied three eyebrow points, below
  the adapter's four-point admission. Thirty-seven protection assertions failed;
  five points preserving the same source envelope repaired the fixture, without
  changing any protection threshold.
- Independent regressions found an infinitesimal sibling re-budgeting an active
  shape (one case/eight assertions) and an infinitesimal shape disabling iris
  containment (one case/one assertion). Both implementation defects were fixed;
  the original tests pass in the final map run.
- Actual sparse positive pupil initially changed **2,059 protected eyebrow
  pixels**. Aperture-contained compatibility now passes exact protection, but the
  new positive-amplitude predicate above remains failed. It is not an appearance
  delivery claim.
- One added Swift test expression hit a compiler type-check timeout, executing
  zero tests. An equivalent explicit loop compiled and the eleven-case run
  passed. Initial sandbox/cache and export attempts also supplied no usable test
  or portrait-pass evidence; permitted retries produced the results above.
- An earlier additional forty-case integration run passed thirty-nine and failed
  `BeautyDenseCombinationTests.testResolvedDenseHighCombinationHasRealBoundedRepeatablePixelsAndProtectedBorder`
  on two nose/mouth strength assertions. It requests no eye field and uses a
  fixture lacking those concurrent changes' required regional observations.
  This task did not change that fixture or rerun a full combination suite; the
  directly mapped eye-combination cases pass. The separate failure is retained
  in [current debt](../../debt/current.md).

No same-original/neutral/numeric-state Meitu comparison, broad portrait
qualification or native iOS/MediaPipe portrait rerender was performed. The dense
iris pixel evidence is source-defined generated input; sparse positive pupil
amplitude remains limited and negative pupil needs dense evidence. Complete
Meitu equality, lower-lid reference amplitude and general semantic protection
are unverified. These limits are tracked as EYE-REF-01 rather than activating
closed retouch work. Going further requires a separately scoped hypothesis and
appropriate input evidence; no new model, collection, training or distribution
was introduced. Upper-eyelid fullness, redness, unrelated concurrent edits,
frozen failures and historical receipts remain unchanged.
