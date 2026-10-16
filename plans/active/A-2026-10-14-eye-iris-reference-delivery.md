# A-2026-10-14-eye-iris-reference-delivery

## 2026-10-16 当前终止决定

所有者明确要求即使未完成也保留现有实现并统一合入main，本次到此结束。
本轮未实现的外观/保护目标按`closed_with_unmet_objectives`结清，不改写旧失败、
阈值、历史限定通过或照片证据。以下旧下一步、待授权模型和候选计划不再自动执行；
换思路需要新的明确范围。统一整合记录见[本轮收尾](../history/2026-10/A-2026-10-16-integrate-retained-effects.md)。


| Field | Value |
| --- | --- |
| Status | `closed_with_unmet_objectives`（2026-10-16 所有者结束本轮） |
| Owner | SDK iris map / separately authorized owner editor |
| Started | 2026-10-14 |
| Source Request | Owner requested remaining five eye tools, then clarified: implement only those with Meitu references; gray buttons for tools without references. |
| Scope | Optimize signed pupilSize against the supplied iris-size reference pair; extend the established centered reference slider to iris; disable four visible host entries without reference (lift, gaze, symmetry, sclera redness). |
| Expected Behavior | Iris left shrinks/right enlarges within the observed aperture with eyelid/brow/face protection; frozen source-defined reference response/detail oracle passes. Four unavailable tools remain visible grey and cannot change selection/parameters/history. Prior ten reference fields remain unchanged. |
| Current Step | 现有代码按新授权合入main，本轮到此结束；未达标缺口保留，不继续旧候选或模型评估。 |
| Verification Policy | Relevant pupil map/public engine tests and exact unaffected eye checks; one existing claimed compatible simulator for renderer/UI, plus owner-selected existing iPad7 delivery (latest explicit selection). No full SDK/App run or wider device/font/orientation matrix; no new model/device/runtime/account/ID. |

| Step | Status | Evidence |
| --- | --- | --- |
| Scope and reference inventory | `completed` | Supplied folder has 23 frames, 11 paired geometry effects. Iris has the remaining paired reference; four others have no paired on/off/strength response. Owner confirmed absence and explicitly requested grey entries. |
| Freeze oracle / baseline | `completed` | Source C32 map hash and old receipts retained; same already-edited portrait and fixed display normalization. Define source-fixed iris response/protection/artifact acceptance before candidate outputs. Unknown original neutral/numeric/reference quarters remain limits. |
| SDK implementation | `active` | Only pupilSize admitted dense-iris component; cap/API/sparse fail-closed behavior and other fields preserve their contracts. |
| External host | `active` | Existing reference-style slider extended to iris; four non-reference buttons disabled. No App/UI code inside SDK repository. |
| Focused verification | `active` | Execute direct pupil source/public protection/negative/composition tests; one native reference protocol and focused grey/slider UI tests. |
| Delivery and records | `planned` | Signed same-ID owner App on selected iPhone13Pro, preserving data and current other-task ready artifacts; dated aggregate/managed preview, precise owned media cleanup and owner docs. |

Preserve SDK-only boundary and retained GPU APIs/shader, current parallel nose/mouth edits
and the pending mouth R13 App/test/runfile, all frozen eye receipts/history, original
references, and stable build caches. Four disabled host entries do not change SDK
implemented/suspended taxonomy or remove public APIs. 去脂 remains suspended and
v1.25 EYE/SEG remains closed; neither is reopened. No external distribution.

Hypothesis: source-supported dense iris resizing has a meaningful reference response
but aperture taper/grid sampling may attenuate the visible boundary. First measure
current reference and baseline under the same source-fixed protocol; change only a
falsifiable registered-iris transform if a target failure is demonstrated. Do not
select a weaker threshold after observing candidate output, widen the eye aperture,
or use whole-eye/eyelid scaling as an iris proxy. Any rejected hypothesis retains
its source and numeric/detail failures.


## Frozen oracle and C32 baseline

The independent source/reference-only iris oracle was frozen before any new output;
helper SHA256 `1c53f05f5279144bcf8b836bfc5f9fef112ca240d2e0835483c9bbe14feee51e`,
protocol SHA256 `c94a649e3e92d67fce512c5fa0f7934a958298303e1862ab851dd0ef23f1121b`.
Image-left/right diameter endpoint spans are **24.4761/24.6998 source pixels**,
tolerances **2.4476/2.4700**. Fixed-band dark texture spans **26.4550/27.0026 pp**,
tolerances **5.2910/5.4005 pp** under valid frozen photometric gates. Each eye must
shrink/enlarge, and each signed quarter must increase diameter excursion by at least
.15 source px. Neutral/repeat, full conservative eye-box exterior and all finite
lid/lash/brow/nose/lip cores require source-exact RGBA; source/core/threshold and
original-detail artifact predicates are unchanged after freezing. This is finite
image-space iris evidence, not semantic segmentation or a measured Meitu quarter curve.

Existing C32 source on one claimed iPhone15Pro/iOS17.5 simulator passes six focused
host contract/session/layout tests, then production-photo original iris quarters,
preview iris quarters and prior-ten original caps each run one method **1/0/0**.
Actual MediaPipe single face/478 points, CPU backend, source/neutral/repeat/metadata
checks pass. Original measured iris diameter spans **10.3603/10.5052**, preview
**10.2820/10.3914**, both fail the original frozen amplitude gates. Dark-area spans
also fail (original10.7143/11.3695pp). Direction and quarter monotonicity pass.
Complete exterior stays exact, but the left inner-lid finite core changes up to20
pixels and the left outer-lid negative cap changes2 pixels. These are retained
failures, not completion. No algorithm had been edited during baseline capture.

## First falsifiable iris profile (C33)

The multiplicative contour ramp has slope up to1.5/(.35R); multiplying it by a
radial vector contributes a large rank-one derivative near an occluded boundary,
so the global pupil cap admission can uniformly attenuate both visible irises.
Increasing the coefficient alone would be canceled by the same gradient limit.
Use a source-local **minimum-distance displacement magnitude** instead:
`min(a*r, beta*(distanceToContour-rim), beta*(L-r))`, clipped nonnegative,
along the observed pupil's radial direction. Fixed `a=.21`, `beta=.35`,
`L=1.05R*(1+a/beta)` and `rim=max(1 pixel,R/8)`; only a valid observed dense ring
permits this branch. The ideal inverse-scale endpoint span for .21 is .4394 of
source diameter, consistent with the independent supplied reference ratio.
On a distance-active branch, the unweighted radial field's Frobenius norm is
bounded by sqrt(.21²+.35²)<.45; actual grid admission/joint pose/displacement
limits remain mandatory. A source-fixed destination rim re-clips/feathers only
the iris component to prevent bilinear node leakage into the lid neighborhood.
No zero-strength iris arrays/frame changes, new support/radius, cap increase,
sparse-route change, other-field coefficient change, or acceptance relaxation.

Run the directly affected SDK pupils/protection/composition tests before native
candidate scoring; retain any failure and repair its demonstrated cause. Candidate
output must pass the same frozen oracle and original-detail artifact review.


C33's new 11 direct SDK cases pass /0/0, including two independent generated
rim/invalid-ring regressions. Its original/preview iris and prior-ten captures each
run1/0/0 mechanically, but unchanged frozen iris response still FAILS: original
width spans11.4387/10.8930 and preview11.4184/10.8088; left inner-lid core up to4
pixels remains changed. Outer core is fixed, other cores/exterior exact; prior-ten
canonical PNG20/20 exactly equals C32 baseline. C33 is not selected.

Temporary anonymous diagnostic confirms C33 cap admission1, pose1, actual signed
strength/cap±1 and grid gradient.44309; the observed aperture half-height is only
.619/.628 of the observed iris radius. Amplitude is constrained by the per-node
contour-clearance branch, not global strength or pose. No raw coordinates/masks
were logged; production C33 source is restored exact. Earlier conditional compile
attempt did not activate inside the package; a runtime-guarded temporary build
produced the actual1/0/0 diagnostic. Concurrent shared-cache main changes stopped
preflight before mutation; original pending R13 is retained separately and current
as-found main/test/profile/runfile is preserved with only5 changed-file overlays.
No old App is restored over the newer current cache.

## Second falsifiable iris profile (C34)

Keep the same .21 radial response, .35 peripheral distance slope, observed radius,
1.05R plateau, source-fixed mesh nodes, original grid/joint .45/.15 and pose bounds.
Remove only the contour-clearance term from the smooth grid iris field: it limits
visible width before the existing per-pixel containment rule. Enforce contour and
an enlarged fixed lid neighborhood in that existing iris-only raster rule, with
`rim=max(1,R/5)` and source-scaled narrow feather `max(1,.04R)`. Source contours are
not expanded; iris offsets remain zero outside them. The documented grid gradient
never claimed the derivative of the per-pixel iris gate; do not extend that claim.
Rendered seam/lid/core/artifact and unchanged oracle gates remain mandatory.
Sparse behavior and zero-pupil/other ten fields remain unchanged. Reject C34 if
its stronger visible response changes the frozen protected cores or adds artifacts.


C34 direct SDK executes8 cases but FAILS22 assertions in the two new generated
positive/valid-peer cases: cap diameter excursions only .2171/.2256 vs>1.2284px,
quarter increments also insufficient. Protection, existing dense area, epsilon,
public engine/failure cases retain their own passes. No C34 native photo scoring
or delivery is performed. Inspection finds an implementation defect in C34's
hypothesis: the dense grid branch still has the old `contains(p,eye.contour)`
entry guard, causing the supposedly smooth exterior radial field to drop tozero
at contour nodes and therefore encounter the original large grid gradient.
C35 corrects this guard for dense only; sparse keeps its old inside-only guard,
while dense per-pixel contour/rim containment remains mandatory. Same .21/.35,
radius/R/5/narrow-feather and all oracle predicates; no parameter sweep.


C35 source `f56b9a5e3567a21e0375581747ad80be6fa9f019bf9c516195720ec3d9295cbb`
executes8 direct SDK cases /0/0. Native original quarters, preview quarters and
prior-ten caps each execute1/0/0 mechanically, and the20 prior-ten canonical PNGs
remain byte-exact to C32. Frozen original diameter spans18.0626/18.5054 and preview
17.5530/17.7721 still FAIL amplitude. All14 finite cores and complete exterior,
neutral, repeated caps and metadata are exact; quarters/direction pass. Native
original-detail review also FAILS: iris upper/lower transitions produce clipped
horizontal contours and white/double-edge seams. C35 is rejected, not delivered.
The narrow per-pixel feather is not bounded by the reported lattice gradient;
destination containment alone does not establish source-stencil containment.
Keep this failure; any next hypothesis must repair demonstrated clipping without
weakening source-fixed targets, changing old-ten paths or widening the eye aperture.


## Third falsifiable profile (C36)

C35 original review demonstrates a thin horizontal warp transition crossing the
visible iris. Use a broad source-radius transition (.40R), a1.5px sampling collar,
and separate observed canthus neighborhoods (R/5) instead of freezing an entire
R/5 upper/lower band then switching within .04R. Keep the same .21 radial target
and .35 peripheral slope. The dense compact field is bounded by its own radius;
remove the unrelated orbital/feature product from this dense-only grid component
so an exterior transition cannot uniformly attenuate the visible iris. Source
aperture/rim/canthus raster containment remains; original grid/joint bounds remain
mandatory, and do not claim a .45 final raster derivative. Other10/sparse unchanged.
Accept only the unchanged frozen amplitude, protection, quarters and native detail
gates; no threshold relaxation or hidden acceptance-dependent coordinates.


C36 executes11 distinct direct SDK cases /0/0; original/preview/prior-ten native
configs each1/0/0 mechanically. Frozen diameter spans19.0871/19.1204 original and
17.7886/17.4003 preview FAIL. Left canthal cores change up to8px original and1px
preview; other cores remain exact. Wider transition visibly removes C35 straight
clipping, but no numeric/protection acceptance or delivery is claimed.

## C37 plateau correction and source shoulder protection

Inspection identifies another dimensional defect: `.21r` meets the peripheral
branch at1.05R, while the positive inverse-scale limbus lies atR/(1-.21)=1.2658R.
Thus the enlarged iris leaves its scale plateau before the endpoint, independently
of cap admission. Set the plateau analytically toR/(1-response)+1.5 sampling px;
keep .21/.35 response/slope and ordinary lattice/joint admission. Keep C36 broad
.40R feather. The source collar grows continuously from1.5px toR/5 beyond the
expanded-iris plateau over .30R, protecting the entire outer aperture shoulder
rather than only a tip point. No new detector evidence, oracle weakening, direct
private pixel coordinates, cap increase, other10 or sparse changes. C37 must pass
the same source-defined original/preview response/protection/detail gates.


C37 source `c43d41f917e678101ea1b2aa5346d625d5c7faa429d61712e189f869961c2fe2`
executes13 distinct direct SDK cases /0/0. Native original/preview/prior-ten
configs each1/0/0 mechanically, and old-ten20/20 canonical PNG exact. Frozen
original diameter20.99697/21.03006,
preview17.81459/17.27422; width and some dark-area gates FAIL. Left canthal
cores up to21px original and5px preview FAIL protection. No delivery.
Anonymous original diagnosis confirms cap gradient.40758, admission1, pose1,
actual±1; not global attenuation. Temporary diagnostic source restored exact.


C37 anonymous preview diagnosis executes1/0/0: gradient.496221 and admission
.906853 with pose1/actual±1, while original admission1. Source-only .21/.35
radial field would have norm≤.408; the retained old weight/shape/spacing early
guard hard-clips an otherwise continuous dense component in preview. C38 removes
that dense-only guard and addresses the demonstrated raster mechanism.

## C38 immutable-source color composition hypothesis

A feathered inverse coordinate compresses the visible limbus response near lids.
For dense iris only, keep the unfeathered radial component and blend its sampled
color with a shape-only sample, both from the same immutable original RGBA. No
sequential resampling or mutable output-as-input; pupil0 and sparse retain the
original sampler path. This changes the dense iris raster composition contract
to two independent bounded original-source samples, not two geometry stages.
Use a uniform R/5 source-defined contour/canthal collar with .25R smooth color
transition. Full sample requires its four source pixel centers inside its own
dense aperture and outside preserved feature boxes; failure falls back to shape
only, retaining active sibling fields. Destination feature boxes also remain
protected. Current grid/joint bounds, .21/.35, analytical plateau, radius/evidence,
cap, alpha/dimensions and all frozen acceptance predicates remain. Numeric gates
do not replace native double-edge/texture/lid review. Reject any ghosting or
failed source/protection response. Implementation currently in progress.


C38 source `3841a5218632420bf3ea4e2a6798f2f81c1dd88ce8a2b996f9810be814e3e013`
executes13 direct SDK cases /0/0. Three native photo configs each1/0/0 and
2 real UI tests2/0/0. Original/preview protection all14cores/exterior, neutral
and cap-repeat exact; old-ten20/20 PNG exact. Frozen original diameter
19.16401/17.74828 and preview19.13902/17.42870 still FAIL. Native original
negative cap shows irregular double/white fringes; C38 not accepted/delivered.
Actual tap/drag±100/0/undo/redo and grey4 reachability/selection/history/silence
passed on the same claimed iPhone15Pro/iOS17.5 simulator. Owner now explicitly
requests iPhone13Pro for final physical delivery; iPad disconnected. Connected
iPhone13Pro/iOS26.4.2 inspected read-only; no install/test/claim yet.


C38 source-only diagnostic records only dimensionless dark-band/ring and boundary
clearance ratios (no private points/radii/masks): cap gradient.40758/admission1.
Four source rows show dark-width/(2R) about.916 left/.563 right; right samples
include source highlights, so they do not justify inventing a new iris radius.
Dark-edge contour clearance/R is about.386–.505, explaining that a uniform
R/5 collar leaves little alpha transition for the expanded limbus. SDK radius
criteria are unchanged. A temporary diagnostic literal typo failed compile only,
was repaired in a fresh build, actual diagnostic1/0/0, production restored exact.

## C39 outer-shoulder and occlusion projection hypothesis

Retain C38 original-source color composition/4point checks and .21/.35. A narrow
source shoulder transition (.10R beyond the analytically expanded plateau)
returns the contour collar toR/5 before the canthal shoulder; central iris keeps
the1.5px sampling collar. For a full source sample outside an occluding aperture,
project only its vertical iris component toward the shape-only vertical sample
if both source pixel columns provide one unambiguous common interior interval.
No aperture expansion, unknown texture synthesis or private pixel coordinates;
ambiguous/infeasible/alpha/protected samples retain shape-only. Bound the additional
owned horizontal-full/vertical-shape hybrid field with the same .45/.15 lattice
limits, so projected vectors are convex blends of bounded fields. Frozen negative
texture/white/double-edge, amplitude/protection and quarter criteria still decide.
Worker implementation in progress; no acceptance or delivery declared.


C39 source `6a82247280fb2c5ab99e865b795b2a5e730279ceee011f5557f1a761501d1a0d`
executes13 SDK cases /0/0; three native photo configs1/0/0 each. Frozen diameter
25.09074/25.96489 original and24.74171/25.52273 preview PASS amplitude, direction,
quarters and14core/exterior/neutral/repeat checks. Dark-area spans also fit, but
photometric validity FAILS: negative bright-anchor median luma drops36.466/22.787
original and39.149/25.813 preview vs original frozen16.159/20.365 allowances.
Core luma changes≤3.5; positive anchors remain valid. These are retained failures,
not accepted dark-area evidence. C39 cannot be delivered as reference-qualified.

## C40 observed iris material ownership hypothesis

Negative iris shrinking should replace the old iris region, while retaining
already-exterior sclera; the current radial peripheral field also pulls exterior
sclera into canthal/lid colors. Add dense-only immutable-source color ownership
within the original observedR plus two1.5px AA/bilinear footprint buffers. Positive
ownership stays within the analytically expanded cap plateau plus1.5px. Smooth
the1.5px outer coverage, combine with existing aperture/protection color mask,
and leave shape-only color outside it. No private ROI, new luma threshold/model,
radius refinement, coefficient/cap/node change, or relaxed acceptance predicate.
C39 source projection and all bounding/failure gates remain. C40 in progress.


C40 source `8d3feb4b0bd39f0f546e28e9b0de94cb157973402e6b93a5819e6959ee0c832a`
executes14 distinct SDK cases /0/0 (13 direct plus1new source-stencil ownership
metamorphic case; outside-only RGB/alpha perturbation cannot affect either iris
aperture, both eyes active at±four quarters). Three native simulator configs each
1/0/0. Frozen original and preview numeric/protection/photo gates all PASS;
original diameter25.09074/25.96489, dark-area29.7619/30.1034pp; preview
24.74171/25.52273, dark-area29.6154/29.0566pp. Neutral/cap repeats, all14finite
cores and complete exterior exact. The initial native-detail/weak-identity PASS judgment is withdrawn after owner
review: the iris is visibly distorted/non-round. Numeric and finite-core passes
are retained as actual measurements, not appearance acceptance. Old-ten20/20 canonical PNG exact.
C40 does not qualify for delivery. The earlier claim that the supplied portrait
was appearance-qualified was an erroneous visual judgment. Signed same-ID App was
updated on iPhone13Pro, original Metal/CPU method1/0/0 with numeric/protection
PASS; preview runner failed to connect and the device became unavailable. Owner
then selected iPad7/iOS18.7.10: install/launch and source roundtrip exit0; original
Metal/CPU, preview CPU and hosted panel each1/0/0, both photo numeric/protection
gates PASS. These mechanical results do not override the owner's visual rejection.


## Owner rejection and iris-only correction (2026-10-14)

Owner observed that C40 makes the iris non-round and explicitly requires only iris
size to change, with surrounding regions protected. Withdraw the C40 visual PASS
and any final-delivery qualification. Keep original source/reference/oracle hashes
and measured passes/failures unchanged; add a stricter independent shape/material
acceptance rather than relaxing existing amplitude/photometric/core gates.

Investigate negative vertical source projection, anisotropic/hybrid sampling and
wide aperture color feather: a numeric horizontal-diameter match does not prove a
concentric uniform iris scale. New acceptance must independently measure circular
(or source-perspective-consistent) iris contour and retained texture under uniform
scale, and require source-exact eye white/lid/corner/face outside the old/new iris
material support including necessary antialias footprint. Negative newly exposed
annulus must not borrow eyelid/eyelash or other iris colors. A circle naturally
occluded by the unchanged lid is different from a deformed iris contour.

No new model/download, cap expansion, private output-tuned coordinates, old-ten
change or reopening suspended/closed research. SDK-only boundary, signed same-ID
App/data and all parallel work remain preserved. Current C40 App on devices is
rejected and will be replaced only by a new verified candidate; final records,
managed preview and owned media cleanup remain pending.
