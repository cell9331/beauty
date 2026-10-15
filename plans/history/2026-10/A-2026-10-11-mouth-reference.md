# A-2026-10-11-mouth-reference

Status: completed for bounded mouth algorithm/slider implementation and scoped
validation. Complete Meitu appearance equality remains unmet. Owner requested
improvements against sixteen local reference screenshots and the corresponding
external-host sliders.

## Scope and prospective acceptance

Eight paired geometry endpoints: size, width, vertical position, tilt,
horizontal position, Cupid's bow, fullness and smile. Screenshots show centered
sliders but no numeric values or confirmed isolated neutral; they guide direction
and visual shape, not pixel-equivalence claims. Teeth whitening remains the
existing independent one-way color control; no new whitening reference supplied.

Use actual outer/inner lips with a continuous pixel-space map. Preserve direct
size-positive enlargement, Y-positive downward and clockwise-positive rotation.
Host sliders reverse size and Y to match smaller/upward at the right endpoint.
M/fullness/smile become signed with unchanged keys, neutral and absolute caps.

Before candidate execution, require source-defined generated positives and
negative/missing-support cases: width/size change whole-mouth span, size also
changes height, X/Y translate center while preserving span, rotation preserves
pixel distances, M changes two upper peaks relative to their center, fullness
changes outer thickness with inner opening protected, and smile moves both
corners relative to center. Four quarter steps must progress monotonically;
neutral/repeat, nose/eye/exterior/alpha, dimensions/extent/color, EXIF/mirroring,
typed failure and selected CPU/Metal parity are independent checks. Inspect
actual portrait outputs for pinching, discontinuities, stretched teeth and
unintended nose/eye changes; changed-pixel totals are not an appearance oracle.

## Work and validation

- [x] Inspect all sixteen owner reference screenshots and current implementation.
- [x] Identify template-lip, point-density and non-square rotation defects.
- [x] Implement and integrate source-observed continuous mouth fields.
- [x] Update SDK and external-host slider contracts without layout changes.
- [x] Execute narrow new and directly affected SwiftPM tests.
- [x] Render actual local portraits and validate existing host controls.
- [x] Complete independent review of the final calibrated portrait outputs.
- [x] Record actual results, remaining visual limits and contract owner changes.

## Executed checks and corrections (2026-10-11)

The initial 22 new map/public-pixel/slider tests pass after calibration. They
exercise eight signed fields at four quarter steps, two aspect ratios, separate
size/width behavior, rotation distances, inner-opening protection, feature
directions, neutral/repeat/recovery, missing support, metadata and actual Metal.
Direct regression covers 61 existing or adjusted parameter/planning/provider/
conflict/backend/pipeline/stage/legacy-mouth cases; corrected cases are rerun
separately. Together, 83 distinct related cases ultimately pass, zero skips.
Two new thin-upper-lip cases bring the related inventory to 85. After the
visibility correction below, all 24 map/public-pixel/slider cases pass again,
zero failures/skips; the unrelated suite is not rerun.

First compilation failed on test-only import visibility. Initial execution
found three signed fields still rejected by backend admission and an overwide
transition band changing a protected region; production was corrected without
relaxing the pixel oracle. Direct regression exposed missing absolute values
in the three-field conflict budget, then a test-helper sum retaining the old
unsigned assumption; both were corrected. The old partial-lip-only corner test
now explicitly selects its legacy sampler and retains its original target,
exterior, alpha, neutral and repeat assertions. The default observed route is
separately required to abstain when eye/nose support is absent.

The external owner editor completed 10 distinct native cases on the existing
iPhone 15 Pro / iOS 17.5 simulator: six contract/history cases, two actual
MediaPipe portrait cases, one independent patch-matching calibration and one
UI interaction case. The first bundle has 9 passes/1 UI accessor failure/0
skips; corrected UI-only rerun has 1 pass/0 failures/0 skips. No passed case was
rerun solely to obtain a clean bundle. Two portraits provide 32 signed endpoints,
exact repeats, source/neutral identity, alpha/dimensions/sRGB and fixed nose/
eye/exterior protection. UI screenshots use a generated no-face input and
prove control interaction/container behavior separately from portrait effects.

macOS/Vision also produced 34 neutral/single-field final outputs on both
authorized originals. Initial reference-aligned review identified mismatched
vertical/smile strength and weaker horizontal/tilt/fullness amplitude. A
single calibrated candidate reduces Y/smile, increases X/tilt/fullness, narrows
the halo and extends nasal exclusion toward the mouth; gradient/displacement
thresholds, field caps and independent assertions are unchanged. Its 22 new
tests and native portrait cases pass. Independent final review found M-lip
almost imperceptible in the native portraits, fullness about half the reference
pair's thickness change, X about 69% of its pair displacement, and smile without
the reference's horizontal widening. Those results do not establish parity.

The admitted thin-upper-lip fixture reproduces the M/fullness over-attenuation:
six new visibility assertions fail on the old production map. Removing only
M's repeated thin-layer multiplier resolves its assertions; two fullness
assertions still fail. The final candidate keeps a smooth fullness availability
weight with a 2%-mouth-span knee instead of 4%, for both upper and lower lip.
It does not alter the complete inner-opening band, field caps, halo, gradient
or displacement admission. Thin M negative endpoint improves 0.356→1.022 px;
upper-fullness positive endpoint 0.355→1.123 px. Four signed steps, actual
opening/nose/eye/exterior/alpha/repeat and map safety assertions all pass.
An initial over-dense test contour exceeded the existing 64-point admission;
the generated fixture was corrected, without changing production admission.
The 24-case run for this candidate passes. Two original photos have ten fresh
Vision outputs for neutral/M/fullness review. Independent review finds the M
outputs byte-identical to the first calibrated Vision outputs, and the primary
portrait's fullness pair decreases from 26 to 22 px across three fixed chroma
thresholds. Passing the thin fixture does not establish stronger real-photo
effect. This candidate is not credited as appearance improvement.

A subsequent bounded hypothesis saturates exterior fullness depth at the
nominal transformed outer edge, rather than allowing distant skin depth to
amplify the availability derivative and dominate global gradient attenuation.
It retains both signed coefficients, inner-opening band, caps, halo, feature
protection, gradient/displacement limits and four-step assertions. Added actual
inverse-source-spacing assertions examine continuity through lip/skin at the
two peaks and center. Its three-case execution has two passes and one failing
case (three unchanged visibility assertions): the negative endpoint saturates
before the actual outer edge after global safety attenuation. The corrected
final candidate covers at least the source tissue thickness as well as the
nominal transformed thickness. Both signs now cover their attenuated outer
edge before saturating; no gain, protection or admission threshold is raised.
Three focused cases pass, then all **24** map/public-pixel/slider cases pass
again (**0 failures / 0 skips**), including actual selected Metal. Thin upper
fullness negative/positive gains are 0.576/0.687 px, total thickness gains
2.409/2.948 px; these are generated-fixture measurements, not portrait results.
The first final-test invocation fails during sandboxed cache access before
test execution; the successful invocation reuses the existing cache with the
required permission. Ten fresh Vision outputs on both originals are awaiting
independent actual-photo review. Updated native verification also awaits the
selected simulator's existing nose-task claim release.

Independent Vision review of that corrected-depth candidate measures the
primary portrait's fullness pair at 28–29 px, versus first calibration 26,
the intermediate candidate 22 and reference 56–57.5. Its M outputs remain
byte-identical to first calibration. No visible lip pinching, seams, waves or
opening cracks are found on either portrait; these closed-mouth photos do not
prove exposed-teeth behavior. Fixed eye/forehead/exterior/alpha and neutral
are exact. A broader hand-selected nasal-base region is exact for the primary
portrait and differs at most 1/255 for the other, distinct from the exact
source-observed protected region.

A final amplitude hypothesis increases only positive fullness gain to 0.80,
retaining negative 0.50 and the final corrected-depth rule; ideal positive
inverse slope is 4/9, but the complete weighted map remains subject to the
unchanged 0.45 global admission. Positive peak amplitude is separately tested
with a larger source-relative ceiling; negative flattening remains unchanged.
The same three cases pass, without changed thresholds. Thin positive fullness
gains increase to 1.079 px upper / 4.628 px total; thin peak pixels remain
unchanged after safety attenuation. Ten fresh Vision outputs show a small
positive M improvement on the primary portrait: three fixed chroma threshold
pair depths change from [4, 2, 2] to [5.5, 2.5, 3] px, against reference
[5, 5, 6]. Later source-detail review finds the first threshold catches skin
rather than the lip edge; its 5.5 px delta is retained only as a sensitivity
diagnostic, not evidence of approaching the reference. The two stable levels
remain 2.5/3 px versus reference 5/6. Negative peak output is unchanged. The other portrait's positive
peak pixels change slightly, but remain visually subtle. Fullness central
thickness stays 28–29 px, so no additional Vision thickness gain is claimed.
Protection, alpha/neutral and visual inspection remain as above. This candidate
is selected for its actual peak and thin-lip improvements, while preserving
the remaining reference mismatch. Final **24-case/public checks pass again,
0 failures / 0 skips**, with actual Metal execution. The nose task explicitly
released the simulator and host cache before mouth native claimed them.

The v5 native two-photo run has **1 pass / 1 failure / 0 skips**. The primary
portrait passes 16/16 directions; the second passes 15/16, with positive M's
unrestricted RGB patch-registration score -0.561683 px failing the unchanged
>0.02 threshold. All 32 repeats, alpha/neutral/dimensions/color and fixed
feature/exterior protections pass. The failed bundle/aggregate are retained;
this is not recorded as current native all-pass. Independent five-threshold
upper-lip boundary review finds positive peak depth increases 0.044–0.322
preview px and negative relaxes 0.037–0.229 px on that portrait, with no visible
inverted bow or new artifacts. The 5×5 patch may span fixed oral pixels and
moving outer edge; whole-window 2D translation is not necessarily peak motion.

A host-only normal-constrained whole-window measurement candidate fails its
independent fixed-opening curvature control: known -0.5 px outer-edge motion
measures -0.1875 px, outside the unchanged ±0.25 control tolerance. It is
rejected before simulator/photo execution, without weakening either threshold.
This reproduces the window's mixture of fixed oral band and moving outer lip.
The subsequent source-defined outer-lip boundary profile measures edge height
rather than rigid patch motion, with fixed source contrast thresholds and
source-corner normal; old 2D/window results remain diagnostics. Independent
known positive/negative/neutral subpixel and fixed-opening curvature controls
must pass before using it on the portraits. The SDK source is unchanged.
The first boundary-control attempt also abstains because an output-edge
look-ahead incorrectly requires the moving edge's following half pixel to keep
the lip color despite the fixed oral band. Source-edge stability retains that
requirement; the output now requires the corresponding upward crossing within
the same source-defined ROI. The exact host measurement code independently
passes 35 numerical controls (known subpixel translations, three palettes of
straight edges and fixed-opening curvature), flat-source rejection and 21,600
fixed-opening channel equality assertions. Truth tolerances and portrait
direction threshold remain unchanged. The rejected attempts and original
native failure remain separate receipts. A fresh native run is now limited to
the two portrait cases and the new measurement-control case; current native
completion remains pending.

The fresh native boundary run executes exactly **3 cases / 0 failures / 0
skips**: both original-portrait cases and the new independently generated
measurement-control case. The same existing iPhone 15 Pro / iOS 17.5 is
atomically claimed at 11:16:19 UTC and released at 11:18:13 UTC; the stable
host build directory is also released. The control and both portraits pass
without SDK changes or lowered tolerances. All 32 endpoint directions pass;
repeats, alpha, observed nose/complete eye/exterior regions are exact, warnings
are empty, and both neutral/source/restored identity plus 720×960/sRGB
assertions pass. Boundary M negative/positive scores are -0.344490/+0.721494 px
and -0.343046/+0.536213 px. The second portrait's old 2D diagnostic remains
-0.561683 px; the independent normal-window diagnostic is +0.515625 px.
Source boundary contrast minima are 41.562/33.351, at least 5/4 source-derived
levels match, and maximum within-point threshold spreads are 0.383595/0.342654
px. These are bounded preview measurements, not reference appearance equality.
Including the new control, 11 distinct external mouth cases ultimately pass;
the earlier 10-case candidate, UI retry, failed two-photo run and latest
three-case run keep their separate scopes. Independent visual/detail review
finds no inverted M, new seams or lip waves, with remaining subtle M/fullness
amplitude as above. All 34 fresh native images are byte-identical to the failed
two-photo run: the measurement changed, not the rendered candidate.

The reference implementation remains active. A specific smile gap is still
actionable: the map bends corners vertically but has no horizontal corner
component, while the reference widens them. A bounded candidate adds signed
symmetric outward/inward corner displacement using the same source corner
weight and vertical envelope. Its center remains fixed, and the existing
whole-map protection, 0.45 gradient and displacement limits stay unchanged.
Before admission require generated actual-pixel horizontal and vertical
four-step directions/monotonicity, central seam/protection, distinction from
whole-mouth width, and comparison with the prior vertical amplitude. Independent
reference corner measurements will calibrate the coefficient before final
SDK/photo verification. Existing v5 receipts do not prove this new change.
Fixed source-corner matching independently measures reference smile widening
at 32.33/33.84 px with 19/23-pixel RGB windows, versus v5 1.28/1.59 px; the
green-window pair is 35 versus 1 px. A small 15-pixel RGB window is ambiguous
and retained only as a diagnostic. Reference mean vertical pair is
-23.51/-23.60 px, versus v5 -25.40/-25.34. The selected starting horizontal
coefficient is 0.030 of observed span: an ideal symmetric two-endpoint width
pair is four times span times the coefficient, subject to unchanged admission.
The new generated marker test first executes against v5 and has 36 expected
horizontal assertion failures, with its vertical/central-seam/width-distinction
assertions passing. The candidate's new test plus existing whole-mouth and
actual protection cases execute **3 / 0 failures / 0 skips**. Horizontal and
vertical quarter steps are independently monotone; vertical endpoint amplitude
changes -3.51% to +1.04% versus the measured v5 marker baseline. Six fresh Vision
neutral/smile-only outputs are generated for independent reference review.
The first sandboxed renderer attempt fails before producing outputs; the
successful run uses the same compiled objects and authorized Core Image
resources. Independent fixed-projection photo review measures width pair
34 px versus reference 35 and v5 1; the 19/23-pixel RGB windows give
33.447/33.622 versus reference 32.329/33.844. The vertical center pair remains
-25 px versus reference -24.5 and v5 -25.5. Both portraits show no new lip
seams, waves or corner pinching. Vision neutral/alpha/dimensions, eyes, forehead
and the large perioral exterior remain exact. A wider nasal-base rectangle
that includes the philtrum has maximum differences 4/255 and 10/255 (v5 already
4/255 and 9/255); it is separate from the exact source-observed nasal envelope.
The coefficient is retained for this measured improvement. Final SDK/native
checks subsequently pass for the smile candidate: **25 SDK cases / 0 failures /
0 skips**, with the actual selected Metal test executing, and **2 native portrait
cases / 0 failures / 0 skips**. The native cases retain all 32 previous signed
directions and add four signed smile-horizontal assertions at the unchanged
>0.02 px threshold. Horizontal negative/positive scores are -7.001478/+6.501994
and -7.857456/+6.987270 preview px; the existing vertical scores also pass.
Neutral and the seven unchanged controls' PNGs are byte-identical to the prior
native run. The same simulator is claimed 11:36:42 UTC and released 11:38:34 UTC;
both stable build caches are released. The cumulative SDK inventory is now 86
distinct related cases, and native remains 11 distinct related cases. These
are smile-candidate checkpoints, not evidence for subsequent source changes.

Production-matching transient Vision geometry analysis investigates the remaining
fullness amplitude. Reconstructed nodes match the selected production field
within 5.24e-14 px, and cell-gradient maxima agree with the actual 0.45 value.
The complete fixed inner band leaves central source tissue medians 70.936/68.044
px. Including displacement/nearest-zero boundaries gives necessary pair upper
bound medians 58.912/62.697 px, so the reference 56–57.5 is not ruled out by
insufficient tissue. Both positive raw-gradient maxima (0.986/0.984) are on
the lower exterior, reducing the entire field to about 45.7%. Exact factor
differences assign about 0.74 to exterior taper, 0.24 to whole/corner weighting,
0.05 to depth, and zero to availability/protection at the hotspot. The earlier
hard-depth-shoulder hypothesis is therefore not selected.

A narrow positive-fullness candidate replaces its exterior smooth taper at
0.22 mouth span with the existing C1 softLinear taper at 0.26 span, and avoids
the second whole-mouth vertical taper; the same horizontal weighting remains.
Each local zero boundary remains inside the unchanged global halo. Negative
fullness, M, smile, fixed oral band, nasal/eye protection, gain/depth rule, gradient
and displacement caps remain unchanged. Existing thin M/fullness and actual
protection cases execute **3 / 0 failures / 0 skips** without changed assertions.
Thin positive total/upper gains are 4.625/1.079 px, essentially unchanged; no
generated thin-lip strength improvement is claimed. Independent review of six
fresh neutral/fullness Vision outputs finds real positive improvement: at the
two stable primary-portrait chroma thresholds, positive central thickness changes
108/104 to 113/109 px, against reference 113/107.5. The pair difference improves
29/29 to 34/34 px, against reference 57/57.5; negative thickness remains 79/75,
against reference 56/50. The second portrait's fixed-source chroma diagnostic
also increases 4/4 px, without a matching reference for that portrait. Neutral
and negative outputs are byte-identical to the preceding candidate. Eyes,
forehead, exterior, dimensions and alpha are exact; broader nasal-base maximum
differences are 2/255 and 3/255. Full-detail inspection finds no new lip waves,
cracks, pinching or unnatural skin bulges. This candidate is retained for its
observed positive improvement; its public/Metal/native checks remain pending.

An independent production-matching positive-M diagnostic locates the remaining
gradient hotspot inside the upper-lip depth ramp. Maximum raw gradients are
0.400/0.637 for the two portraits; the first is not attenuated and the second
is reduced to 70.6%. Reconstructed node error is at most 5.46e-14 px. A narrow
positive-only candidate replaces the existing smooth body ramp with the C1
softLinear ramp, retaining amplitude, negative flattening, exterior weights,
opening/feature protection and admission bounds. The same three focused cases
pass without changed tests or thresholds. Thin positive M response increases
1.270 to 1.592 px; negative M and both fullness directions retain identical
measurements. Six fresh neutral/M Vision outputs await independent review;
the first portrait's already-unattenuated outer edge is not assumed to improve.
Independent review subsequently finds its stable pair depths improve only
2.5/3 to 3/3 px, against reference 5/6. Positive absolute depths are 5.5/5.5,
against reference 5.5/4.5, so the remaining pair gap does not justify blindly
increasing the positive peak. The second portrait's fixed-source five-threshold
positive boundary increment increases 0.54–0.77 original pixels. Both neutral
and negative files remain byte-identical; eyes, forehead, broader nasal base,
alpha, dimensions and exterior are exact. Detail review finds no new lip
waves, oral cracks, pinching or nasal-base skin steps. The candidate is retained
as a modest improvement pending final same-source checks; no earlier native
receipt proves it. Remaining negative-fullness compression and negative-M
flattening receive read-only production-matching diagnosis before final choice.

The negative-fullness diagnostic finds the same exterior/whole double-taper
hotspot: raw maximum gradients 1.365/1.406, uniform admission 0.330/0.320,
with exterior contributions 1.038/1.063 and whole/corner 0.316/0.333. Lip-body
maxima are lower at 1.130/1.169. Production node error is at most 7.55e-14 px,
and gradient reconstruction agrees. Fixed-opening central compression-bound
medians are 22.015/21.117 px; current actual compression is 14.769/15.913, so
the bound does not yet prohibit improvement. A narrow negative-fullness
candidate reuses positive fullness's single softLinear exterior/whole-horizontal
transition, retaining negative gain, depth, availability, fixed opening,
feature protection and 0.45 admission. Its focused tests and actual-photo review
must precede retaining it; earlier positive-only checks do not cover this change.
The same three focused cases subsequently pass (0 failures/skips), with thin
M and both fullness measurements exactly unchanged. Six fresh Vision outputs
show actual negative improvement: stable primary-portrait thickness 79/75 to
76/71.5 px and pair difference 34/34 to 37/37.5, against reference negative
56/50 and pair 57/57.5. The second portrait's fixed-contour negative diagnostic
changes 62/57 to 60/56 px. Positive and neutral files are byte-identical to the
positive-only candidate; positive thickness stays 113/109 and 95/89 px. Eyes,
forehead, alpha, dimensions and exterior are exact; broader negative nasal-base
differences change 0 to 2/255 and 1 to 2/255, separate from exact observed nasal
protection. Full-detail inspection finds no new opening cracks, pinching or
lip/skin waves. The candidate is retained for this limited real improvement.
The selected source receives a fresh 14-output Vision render of M/fullness/smile
on both originals, followed by final 25-case SDK and two-case native checks.

Negative-M diagnosis finds raw/admitted gradients 0.137/0.259 with no safety
attenuation. Neither the 42%-tissue correction ceiling nor the fixed-opening
compression bound is active at the primary flattening band; its source-derived
flat-line correction maxima are only 2.594/2.486 px. A read-only target-thickness
ramp hypothesis improves reconstructed outer-edge displacement by less than
0.035 px, so it is not implemented or credited as a visible improvement.
Current negative M, positive peak amplitude and the source-derived flattening
target remain unchanged rather than introducing an unsupported target shape.

SwiftPM's test target could not compile a concurrent eye test's complex
stride/filter expressions. Final candidate compilation later encounters the
same timeout in its new stride/reduce RGB-count helper, before any mouth case
executes; that failed invocation remains a zero-execution compilation receipt.
Equivalent for-loops with separately typed RGB
comparisons resolve that compiler-only dependency; their pixel-count assertions
and threshold are unchanged, and no eye regression is credited here.

Selected-map SDK verification executes exactly **25 / 0 failures / 0 skips**
with filter `BeautyEngineMouthReferenceTests|BeautyMouthSliderTests|MouthContinuousMapTests`:
11 public facade/pixel cases (including actual selected Metal), three mapping
cases and 11 continuous-map cases. The source digest is
`3c5d0c3d2bd0d398758bae96fc70a07c976ce9e1f21f4a8832ab3ac90a0dee14`.
The corresponding 14 fresh Vision files exactly match each previously reviewed
selected isolated-field candidate, including neutral bytes, dimensions, alpha
and sRGB. A narrow independent static review finds no defect in the single
fullness taper, fixed opening/feature boundaries or same-sign safety budgets;
it is not an additional test execution. Incremental external-host
`build-for-testing` succeeds. The final native run executes exactly **two
portrait cases / 0 failures / 0 skips**, without rerunning controls/UI/full App.
The new fixed-state claim CLI selects the existing booted idle iPhone 15 Pro /
iOS 17.5 (`2CE927C9-9303-4A9B-9C03-F28C42045186`), claims at 15:20:30.726 UTC
and reports automatic release (wrapper stderr final-write timestamp
15:22:15.409 UTC); shared status then has no claims
and the host build cache is released. All 32 signed directions, four smile-X
assertions, repeat/alpha/neutral/source/restored identity, fixed observed nasal
envelope plus complete eye/exterior protection, 720×960/sRGB, 478-point use
and empty warnings pass. M negative/positive boundary scores are
-0.344490/+0.721494 and -0.343046/+0.532942 preview px; fullness scores are
-5.875463/+5.999950 and -5.518233/+5.625973. Smile-X scores remain
-7.001478/+6.501994 and -7.857456/+6.987270. These are source-defined direction
measurements, not cross-provider or reference amplitude equality. Independent
final-detail review and selected-preview publication subsequently complete as
recorded below.

Two legacy archives, mouth-test exact backend registration and its modification
rejection self-test pass. An earlier global live scan rejects the unrelated
concurrent eye test's unregistered backend reference; that task has now added
its registration. Updated mutation self-test and live boundary both pass.
No full SDK gate is run.

No full-suite run, new simulator, model, retained shader, archived UI, suspended
retouch route or physical-device performance claim is part of this change.
Parallel eye/nose edits are preserved and are not credited as mouth work.


## Completion record

| Field | Value |
| --- | --- |
| Completed | 2026-10-11 |
| Status | `completed`, limited to the implemented code/sliders and scoped validation. |
| Scope | Eight source-observed continuous mouth fields, signed M/fullness/smile, nine-control SDK/authorized-host mapping and measured calibration. |
| Rationale | Replace template point pulling, correct non-square rotation and signed admission, and remove measured M/fullness attenuation plus missing smile widening. |
| Files | Mouth map/helper; parameter, planning, observed-inner support, legacy provider and shared still-image integration; related SDK tests and contract owners; separately authorized external-host slider/tests/validation records. |
| Verification | 86 distinct related SDK cases ultimately pass during the task; final same-source three classes 25/0/0 including actual selected Metal. Eleven distinct native cases ultimately pass; final same-source portraits 2/0/0. Fresh Vision14/native34 outputs, independent reference/detail review, live boundary, both legacy archives, local links/whitespace and selected-preview storage check pass. Earlier failures retain their own scopes. |
| Build | Filtered SwiftPM compilation/test and stable external-host incremental build-for-testing succeed. No standalone duplicate build or complete SDK/App regression. |
| Limits | Stable M pair3/3 versus reference5/6, negative fullness76/71.5 versus56/50 and pair37/37.5 versus57/57.5, X about69%; screenshots have unknown numeric strengths/isolated neutral. Closed mouths do not establish exposed-teeth naturalness; no general portrait/physical-device performance or distribution claim. |

Independent same-source review confirms all 32 native directions plus four
smile-X assertions, repeat/neutral/alpha, fixed observed nose/complete-eye/
exterior protection, 478-point use, 720×960/sRGB and empty warnings. Six native
endpoint files change versus the prior smile candidate (both portraits' M
positive and fullness both signs); the other 26 endpoints plus two neutrals are
byte/pixel identical. No new inverted M, lip waves, oral cracks, pinching or
nasal-base skin steps are found. Native M's first positive boundary score is
unchanged and the second changes +0.536213 to +0.532942, so the Vision/thin-lip
M improvement is not described as stronger native M amplitude. The old negative
2D diagnostic and failed photo bundle are preserved.

Two metadata-sanitized, ignored compressed previews are retained as
`mouth-ref-001.jpg` (reference comparison) and `mouth-ref-002.jpg` (same-source
native comparison). Storage check observes 38 images, eight inputs and 12
previews, total 34,655,187 bytes, including independent concurrent previews.
After both reviewers' final media use, exact-list cleanup removes 334 owned
media files / 820,914,902 logical bytes from the two mouth temporary roots.
Same-volume available bytes increase 821,088,256 during the operation; concurrent
APFS accounting means this is distinct from logical deleted bytes. Original
Downloads, selected previews, analysis sources/executables, logs, sanitized
aggregates, latest/failed xcresults and both stable build caches remain.

Final links and current evidence are routed through the mouth guide, QUALITY,
PLANS and MOUTH-REF-01. This is a bounded implementation completion, not a full
SDK milestone closeout or a declaration that all reference appearance objectives
have been achieved.
