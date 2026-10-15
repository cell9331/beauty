# 鼻部参考效果实现与实际输出验收

Status: `verifying`. Owner explicitly requests improving algorithms/implementation
against the supplied Meitu reference and repository guidance, with documents
updated to actual behavior. Scope is the six nose controls in this conversation.

## Frozen evaluation intent (before candidate output)

- Use the authorized original and same-portrait reference video. Isolate each
  field at neutral and ±25/50/75/100; all siblings zero. Reference endpoint
  extraction/registration and feature measurement are independent of candidates.
- Independent reference measurements, completed before any candidate edits or
  output, correct the initial uniform width/height hypothesis: Size primarily
  changes lateral span (about 8% each direction); reference base-height change
  is below one display pixel. Require the expected ≥3% full-strength lateral
  span change on generated features and preserve axial base height. Do not
  retain the contradicted width/height-ratio requirement.
  Tip must change the tip contour/diameter while leaving the upper root fixed.
  Root/bridge must have distinct upper/middle support and meaningful lateral
  response (≥3% of the generated local span at full strength).
- Wing moves alar width with the intended sign; lift moves lower-nose/tip
  support vertically. Six fields must progress monotonically at four settings.
  Check the actual rendered marker/contour positions, not point proposals or
  changed-pixel counts. No-op/opposite-direction outputs fail the same oracle.
- Complete source-defined eye, eyebrow and outer-lip envelopes, alpha and
  exterior remain byte-exact for isolated nose edits. Preserve neutral,
  deterministic repeat, dimensions/extent/color and invalid-support abstention.
  Inspect original detail for seams, pointed/scalloped bases, nostril collapse,
  lip movement and halos; numeric amplitude cannot override visible artifacts.
- Compare stable original/reference nasal features at one viewing scale.
  Record compression/texture uncertainty rather than inventing subpixel
  precision. Reference magnitude/direction targets are frozen independently
  before inspecting candidates. A bounded visible geometry improvement alone
  does not establish general Meitu quality or 3-D reconstruction.
- At the fixed 1170-pixel reference display width, independently matched stable
  alar features move about 6.3–6.5 px for Size, 3.0–3.3 px for Bridge; stable
  lower nose-side features move 4.4–4.7 px for Bridge. Root upper-side features
  move 2.8–3.3 px with negligible axial motion. Lift moves lower-nose features
  about 6–7 px up and 4–5 px down. Tip predominantly changes the nasal bulb's
  lateral texture distribution, with smaller nostril motion and asymmetry
  between signed endpoints; ambiguous tip/high-root texture is not a precise
  landmark. Freeze reliable endpoint matching to correct direction and error
  ≤max(1 display px, 35% of reference displacement). Low-texture/ambiguous
  patches require visual and support checks instead of fabricated precision.

## Implementation hypothesis

Replace registered nasal point pulls with an anatomy-aligned, source-fixed
continuous inverse field in the existing CPU-owned shared still-image stage.
Use nose width/length to scale each contribution and explicit eye/lip exclusion
with smooth exterior falloff. Keep field values independent and preserve actual
map gradient/displacement admission; do not obtain stronger results by raising
caps or removing protection. Keep incomplete legacy-only compatibility separate.
Evaluate reference root/bridge shading residuals before adding any bounded
appearance pass; imported relighting proposals are not already implemented or
proof of Meitu's method.

## Work and narrow verification

- [x] Freeze reference feature measurements and native baseline outputs.
- [x] Implement shared continuous nose field and registered-path suppression.
- [x] Verify independent generated pixel directions/proportions/protection,
  absent/malformed support, rotation/aspect/alpha and selected composition.
- [x] Evaluate actual iOS MediaPipe outputs on the authorized original.
  Baseline used the existing iPhone 15 Pro / iOS 17.5 simulator, UDID
  `2CE927C9-9303-4A9B-9C03-F28C42045186` (released). The owner then explicitly
  requested the connected physical iPhone 13 Pro, UDID
  `00008110-0001453E21B9801E`, iOS 26.4.2; follow-up rendering and bounded timing
  use that one device. Only root owns native build/device operations.
  After the iPhone completed candidate 2, the owner connected and requested an
  iPad (7th generation), iOS 18.7.9, UDID
  `f4ef3f178ce25d79e7f963ff6fe0261b127f4865`. The iPhone claim was released.
  Existing provisioning excludes the new device; automatic registration cannot
  proceed because Xcode reports `No Accounts`. The owner will recover the
  account later and explicitly requested continuing algorithm work meanwhile.
  No new application identifier or alternate account was created.
  Subsequent algorithm iteration reuses the original iPhone 15 Pro simulator
  after its other owner's explicit claim release; no new simulator/runtime or
  test matrix is created. Its outputs do not substitute for iPad timing.
- [x] Run directly affected SDK/shared-stage/CPU-Metal and native pipeline tests.
  No automatic full-suite or multi-device/font/orientation regression.
- [x] Update current owners/taxonomy/debt with actual results and limitations;
  retain prior receipts. Keep one bounded comparison preview, delete temporary
  raw media after inspection; persist no raw landmarks or private input paths.

Existing model, shader/backend surface, archived UI/evidence and unrelated
face-feature changes remain under their existing contracts. The owner's later
explicit device request authorizes installation with the existing Personal Team
and main application identifier, preserving data. External distribution remains
outside scope.

## Pre-candidate baseline result

The original production preview (720×960, fresh 478-point MediaPipe, every
field isolated) confirms the screenshot defect: Size moves the base by about
15 display pixels vertically versus the reference's 0.3; upper Root and long
Bridge side features move less than 0.3 where the reference moves 3–5.
Tip changes nostrils/base too much while its upper-bulb width proxy remains
near identity. This rejects the hypothesis that all fields only need gain.
Across 48 signed settings, all 8 Size, Wing, Lift and Tip settings alter some
complete source-defined protected pixels; Root/Bridge preserve them. Baseline
XCTest passing only certifies capture/metadata/repeat checks, not appearance or
protection acceptance. The independent reference oracle matches 24/90 stable
endpoint feature targets; 20 template tracks are unstable and not precise
motion evidence. No private media, coordinates or masks are retained here.

## Executed calibration checkpoints

Candidate 1 raised reliable endpoint matches from 24/90 to 60/90, with four
unstable template tracks. All 48 signed settings preserved complete native
eye/brow/lip envelopes exactly. It remained too weak at the upper root, too
strong at the lower Bridge and too coupled between Tip and nostrils.

Candidate 2 on the physical iPhone 13 Pro matched 89/90 frozen reliable
features; all 90 were conclusive without changing thresholds. The remaining
Bridge negative right-nostril displacement missed its frozen tolerance by
0.17 display pixel. The Tip positive bulb-width proxy was 0.765–0.785 versus
the independently measured reference 0.71–0.73; this qualitative/profile gap
was kept separate from reliable point matches. All 48 native settings had zero
changed protected pixels, with exact neutral recovery and deterministic repeats.
Twelve actual Metal endpoints matched CPU byte-for-byte. Release bounded
render median/p95 were CPU 7.39/8.72 ms and selected Metal 9.04/9.71 ms at
720×960, with four warmups and 24 measured renders. These belong to candidate
2, not to later source, input-to-display latency, FPS or sustained operation.

The fixed display protection rectangles separately retain tiny inequality flags
after scaling; they cover surrounding skin and resampling beyond the native
envelopes. They are not silently relabeled exact. Protection claims refer to
the complete native source-defined eye/brow/lip regions and rim.

Candidate 3 changes only negative Bridge inner lower continuation and positive
Tip support/fade. It retains the other fields, unchanged safety bounds and
unchanged oracle. The host start interval is now 16 ms, retaining serial/latest
preview scheduling and release flush. A scoped simulator run is evaluating
actual preview, original-size PNG export and four scheduling/revision guards.

Candidate 3 capture/export and all four scheduling checks passed on that same
simulator. Original-size exports are 1728×2304, with complete native protection,
neutral/recovery, repeat, alpha, sRGB and lossless upright PNG round-trip checks.
It is not accepted: two unchanged generated Tip outer-wing isolation assertions
fail (1.041 px motion against the fixed <0.8 limit). The independent photographic
oracle is still evaluated to diagnose the candidate. A prepared-preview check
also failed before rendering because its separate temporary input was absent;
that authorized local input was supplied for the next scoped run. Earlier
sandbox cache, concurrent source modification and Release x86_64 model-link
build failures ran no tests; stable caches were retained, the current simulator
architecture was selected, and no test threshold was weakened.

Candidate 4's lower outside positive-Tip taper reduced the generated wing
motion to 0.829 px, still failing the unchanged <0.8 isolation threshold.
Candidate 5 strengthens only that lower outside taper; the bulb core and upper
span retain their support. The isolation case and then all **13 continuous-nose
map/integration tests passed, zero failures/skips**, with actual Metal parity
required and executed. No safety bound or test/oracle threshold changed.

Candidate 5's final Release native run on the same existing simulator passed
**7 tests / 0 failures / 0 skips**: isolated 48-setting preview capture,
original-resolution 12 endpoints with neutral/recovery/PNG round trip,
prepared/fresh snapshots and replacement, and four serial/latest/release/debug
scheduling guards. Complete outputs await independent reference/profile review;
test success alone is not appearance acceptance. Its device claim and stable
host build directory were released after execution, retaining caches and result
bundles for the queued owner task. No iPad installation/timing was performed.

Independent candidate 5 review confirms **90/90** frozen reliable endpoint
checks at both preview and original dimensions, all conclusive; all 48 preview
and 12 original settings retain zero changed native protected pixels. The Tip
positive bulb-width proxy is still 0.755–0.770 preview / 0.760–0.770 original,
versus reference 0.71–0.73, with visible slightly wider/rounder appearance.
Display rectangle inequalities remain separate failures (maximum channel delta
5/255 preview, 13/255 original); those wider rectangles are not the native
source-envelope oracle. An extra alar patch has subpixel-to-one-pixel residual
vertical drift outside the frozen 90-feature set. No new threshold masks it.

Candidate 6 adds a 12% smooth positive upper-bulb shoulder gain with unchanged
central slope and zero gain at or below the nostril-side band. Numerical field
predictions alone do not qualify it. Re-run the same 13 nose SDK cases and only
the two directly changed preview/original photo cases; the five unchanged
prepared/scheduling cases retain their candidate 5 execution scope. No full-suite
or expanded device matrix is needed for this local shape change.

Candidate 6 passed **13 SDK / 2 directly changed native photo cases**, zero
failures/skips and actual Metal. Its two-size endpoint oracle remained 90/90;
all native protection remained exact. Upper/whole positive-Tip width improved
to 0.745–0.755 preview and 0.750–0.760 original but remained broader than the
reference. Candidate 7 broadens only the upper positive-Tip width shoulder and
reduces its local gain to preserve admission. The lower support and all other
controls remain unchanged. It passed the same **13 SDK / 2 photo cases**, zero
failures/skips and actual Metal; independent appearance review is pending.

Candidate 7's independent review retains 90/90 at both dimensions and exact
native protection, but its positive Tip profile improves only about 0.005 with
larger extra alar vertical residual. It is not accepted as superior to candidate
6 merely because the fixed feature checks pass. Numerical upper-support and
lower-window variants were also examined: the frozen bulb bands already have
full upper weight, broader lower fade overmoves nostrils, and other variants
spend their gain on global gradient attenuation. None of those unrendered
variants is an implemented or validated result.

The owner's updated simulator policy now uses the fixed local claim CLI/state
directory for any subsequent device operation; earlier claims were released
under the then-current mechanism. Stable cache, single-device, nonparallel and
related-test scope are retained.

## Selected implementation and current result — 2026-10-11

| Field | Result |
| --- | --- |
| Status | `verifying`: implementation and scoped checks complete; the full reference-appearance objective remains open. |
| Selected source | Candidate 6 restored byte-exact after independent comparison; SHA-256 `9cbcf610a3bc6688b108cbbbc3f5c39a01a603b87b1f49fd021fc24e5c0c42dc`. Candidate 7 is rejected as a replacement, not rewritten as a success. |
| Rationale | The upper-bulb gain improves positive Tip without candidate 7's larger outer-alar vertical residual. Size controls broad lateral nose width; Tip independently controls the nasal bulb. Short Root and longer Bridge no longer depend on sparsely sampled point pulls. |
| SDK final execution | Incremental SwiftPM filter selecting `BeautyContinuousNoseMapTests` and `NoseContinuousIntegrationTests`: **13 / 0 failures / 0 skips**, actual CPU/Metal endpoint parity executed. The earlier 40 direct compatibility/shared-stage cases retain their earlier checkpoint scope; they were not rerun as a final full suite. |
| Native final scope | Selected candidate 6's two changed photo cases passed **2/0/0**; five unchanged prepared/scheduling guards retain candidate 5's **5/0/0** execution. **7 distinct relevant host cases**, not a single seven-case final-source run. Stable `.build`, existing iPhone 15 Pro/iOS 17.5, no expanded matrix. |
| Pixel/reference result | One authorized generated portrait, six isolated fields: 48 signed preview settings and 12 original-resolution endpoints preserve complete native eye/brow/outer-lip envelopes plus 2-pixel rim. Preview 720×960 and original 1728×2304 each pass **90/90** independently frozen reliable endpoint checks. Exact neutral/recovery/repeat, alpha, sRGB and lossless upright PNG round trip pass. |
| Responsiveness | 16 ms start throttle, one running worker plus latest pending snapshot, completed drag frames accepted in order, release flush and obsolete-result rejection retained. No final-version input-to-display/FPS/device-performance claim. |
| Presentation | One metadata-stripped bounded Chinese comparison preview, `example-images/previews/nose-reference-20261011-final.jpg`, kept ignored; it is not an oracle input. |
| Remaining limits | Positive Tip still slightly wider/rounder: width proxy 0.745–0.755 preview / 0.750–0.760 original versus reference 0.710–0.730. Additional outer-alar drift and fixed-display-rectangle inequalities remain reported. This is not general Meitu appearance parity or a depth/relighting reconstruction. |
| Device follow-up | Candidate 2 was tested on iPhone 13 Pro; its dated timing is not transferred to final source. The 2026-10-12 iPad follow-up below now passes three Release cases after an A10 runtime dispatch repair; current app updated in place and launched, with data preserved. No sustained-device or actual touch-latency/FPS result. |

The rejected Gaussian/support/window variants were numerical predictions only;
no claim is made that every possible 2-D method has been exhausted. A follow-up
should separate bulb contour contraction from outer-alar motion and reapply the
unchanged direction, protection and gradient oracles. The broader objective
therefore remains active under this plan and NOSE-REF-01, rather than being
marked complete from point-feature success alone.

Final directly affected SDK command (not the complete gate):

```bash
swift test --package-path BeautySDK --filter 'BeautyContinuousNoseMapTests|NoseContinuousIntegrationTests'
```

Documentation/storage checks for this scoped result: **217 local links/anchors,
zero failures** across the changed nose owners/current plan and new host section;
`git diff --check`, both archived bundles, post-archive SDK-only boundary and
example-image storage check passed. The boundary scan covers the current shared
tree without claiming the other agents' algorithms verified by this task.
No SDK-only scanner or frozen rule was weakened for the nose implementation.

After output measurements and selected-preview inspection, **196 owned temporary
media files / 452,608,697 logical bytes** were removed. Same-volume free-space
increase at that instant was 452,710,400 bytes; concurrent/APFS effects mean
this is not a general storage guarantee. The single new ignored compressed
preview remains; frozen reference oracle, aggregate outcomes, failure/success
logs and native result bundles remain for review. Shared utility inputs, user
Downloads media, device data, stable build caches and frozen `.build` receipts
were not deleted. Any next photo iteration must freshly rerender outputs from
its matching source; the removed media cannot be counted as a new execution.

## iPad follow-up — 2026-10-12

The owner has connected/unlocked the same iPad and explicitly continued device
verification. Existing Personal Team/main identifier provisioning now succeeds;
the selected Release app was updated in place with data preserved. The three
existing physical-device opt-ins use the app Documents container, rather than
Mac temporary paths. Current original-input handling and retained shader/public
GPU boundary remain unchanged.

First device run: the 48-setting preview test passed, while original-resolution
and actual Metal parity tests raised `NSException APINotSupported`; the complete
three-test run therefore failed and is not an appearance/performance pass.
The exception is in the retained runtime's unconditional nonuniform
`dispatchThreads`. Apple A10 has Apple3 support; Apple's documented nonuniform
threadgroup minimum is Apple4. Swift typed-error catches cannot intercept this
Objective-C exception. [Dispatch contract](https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/dispatchthreads(_:threadsperthreadgroup:)),
[feature table](https://developer.apple.com/metal/capabilities/).

Direct fix/verification scope: use uniform `dispatchThreadgroups` in the two
existing runtime sites with rounded-up groups. All four existing kernels already
check image bounds; do not change the frozen shader, public configuration/API,
backend selection, field admission, thresholds or CPU fallback semantics.
Add an actual Metal pixel test of odd/short/exact/over-group widths on empty,
neutral-color, zero-geometry, retouch and combined passes, including alpha and
resource cleanup. Run only the runtime class and six nose integration cases
that depend on dispatch, then incrementally rebuild and rerun the three physical
preview/export/CPU-Metal cases. No full SDK or expanded device/layout matrix.
The earlier iPad failure bundle remains evidence of the compatibility bug.

| Field | Actual outcome |
| --- | --- |
| Status/scope | Device follow-up complete; overall nose plan remains `verifying` because full reference appearance is still unmet. One existing iPad, one authorized portrait, Release, stable caches, nonparallel execution. |
| Fix | Two existing runtime sites now use uniform rounded-up threadgroups. Retained shader SHA-256 `f61703372fdad885abbdb45644b5770c417b264431b02c59eaca8d813865fd88`, public GPU API, backend selection and nose candidate 6 are unchanged. |
| SDK verification | Filter selects `BeautyMetalRuntimeTests` and `NoseContinuousIntegrationTests`: **16 / 0 failures / 0 skips** (10 runtime + 6 nose integration), actual Metal required and executed. The new edge test renders five widths × six graphs = 30 actual Metal cases with exact row ends, alpha and cleanup assertions. |
| Native verification | Three existing `PhotoPipelineTests` owner opt-ins: isolated preview, original-resolution export/recovery and CPU/actual-Metal parity/timing. **3 / 0 failures / 0 skips**, independently parsed from the new `nose-ipad-uniform-20261012.xcresult`; installed app uses the tested source. |
| Fresh pixels | 48 CPU preview settings at 720×960, 12 selected-Metal original endpoints at 1728×2304; fresh 478-point observations, zero warnings, complete source-defined eye/brow/outer-lip protection plus 2 native pixels exact. Neutral/recovery/repeat, dimensions/alpha/sRGB and lossless upright PNG pass. Twelve preview CPU/Metal endpoint pairs have max-channel and mean-RGB difference 0. |
| Independent reference | Same frozen oracle/templates/global registration and tolerances, 7/7 evaluator/reference digests unchanged. Both dimensions pass **90/90**, all conclusive. Compared only with prior saved simulator measurements, maximum feature-axis difference is 0.004/0.129 display pixel (preview/original); no old raw-image byte-equality claim. |
| Appearance limits | Positive Tip width proxy remains 0.745–0.755 preview / 0.750–0.760 original versus reference 0.710–0.730. Extra outer-alar vertical residual and fixed-display-rectangle inequalities persist (10/12 endpoints unequal per size; max channel 5/13, max MAE 0.0574/0.1430). Original detail shows no obvious new seam or broken nostril edge, but this is not general Meitu parity. |
| Bounded timing | Four preparatory renders total, then **12 different endpoints per backend**, 24 measured renders total at 720×960. CPU median/p95 30.404/38.733 ms; selected Metal 37.293/50.715 ms. With 12 samples, the stated p95 equals maximum. This includes the shared CPU-owned nasal stage and Metal staging; it is not 12 repeated samples per endpoint, gesture-to-display delay, FPS, thermal/energy or long-run evidence. No routing policy changed based on this small sample. |
| Presentation/device | New metadata-stripped 1320×1600 ignored preview `example-images/previews/nose-ipad-reference-20261012.jpg`, independently reviewed at original detail and viewed after publication. Existing main application updated in place and successfully launched; device claim released. No iPad UI/layout or actual drag automation was run. |

Failed attempts are retained with their actual scope. The first physical bundle
has **1 passed / 2 failed / 0 skipped**, due to unsupported dispatch, and is not
re-signed as passing. The first new runtime test did not compile (zero tests).
Its second attempt executed 16 tests but produced 57 assertions in the new
identity fixture: a zero-strength central geometry point still enters retained
legacy resampling. The fixture was moved outside every pixel's support while
still binding and dispatching geometry; exact output assertions, source runtime
and shader were not relaxed. The third SDK run above passes all 16. These
fixture corrections do not claim a repair to legacy zero-point resampling.

The scoped SDK command, rather than the complete gate, was:

```bash
swift test --package-path BeautySDK --filter 'BeautyMetalRuntimeTests|NoseContinuousIntegrationTests'
```

Verification receipts remain in the existing ignored native result bundles and
task-local aggregate/log files. The current nose-map, runtime, PhotoRenderer and
EditorModel hashes were checked against the device-build snapshot after testing;
all four match. The frozen shader hash also matches. Other agents' eye/mouth
changes are preserved and are not certified by these nose checks.

After measurement and publication, **47 newly created local media files /
122,879,785 logical bytes** were precisely removed. Instant same-volume free
space increased by 122,945,536 bytes; APFS/concurrent activity limits that
observation. Current aggregate/profile JSON, frozen reference oracle/evaluator,
failure/success logs, compressed previews and native result bundles remain.
Shared task inputs, user Downloads and both stable build trees were untouched.

The dedicated device test directory was inventoried before precise cleanup.
The first cleanup invocation missed a required CLI boolean and did not execute;
the corrected CoreDevice copy returned a file-node error after removing its
destination. This is **not** reported as successful file transfer. Subsequent
read-only parent metadata confirms that `OwnerNoseReference` is absent; app data
outside that task-owned directory was not targeted. A permission-review timeout
on one read-only check was retried once successfully; no approval block remains.
The installed application remains available for ordinary owner editing.

Final documentation/control checks: eight directly changed owner/plan/host
documents have **158 local links + 5 anchors** valid, with no whitespace or
conflict markers. Post-archive SDK-only boundary and both archive verifications
pass. Repository `git diff --check` passes; the separate host is not a Git
checkout, so its two changed documents were checked at file level instead of
calling its unsupported Git command a pass. Example-image check passes:
40 images, 8 inputs, 14 compressed previews, 35,261,194 bytes. These are control
and storage checks only; no new full SDK/App, layout or device-matrix run.
