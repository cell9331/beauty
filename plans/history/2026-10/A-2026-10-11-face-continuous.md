# Face slider contract and continuous contour repair

Status: completed for the bounded implementation below; complete Meitu appearance parity remains unmet. Owner explicitly requests Meitu-like slider direction and face
effect implementation, informed by the imported playbook's face/warp chapters.

- [x] Read current contract, the supplied playbook, reference disposition and
  actual geometry executors. Preserve existing unrelated local nose changes.
- [x] Add a single SDK-owned slider mapping: centered controls signed, V-face
  and contour smoothing one-sided; retain direct chin-length API polarity.
- [x] Replace summed face contour pulls in still images with a continuous,
  source-anchored local-frame field shared by CPU/GPU-selected rendering.
- [x] Independently verify opposite pixel directions, quarter-level monotonic
  amplitudes (>0.1 px per level and >1 px at endpoint), neutral/no-face/invalid
  identity, exact eye/mouth/exterior/alpha, and repeatability. Check a generated
  smooth chin for no newly introduced scallops and source-fixed metadata.
- [x] Rerender both authorized originals, inspect whole face and chin detail,
  compare reference endpoints without claiming equal unknown numeric strength.
- [x] Run only directly affected SwiftPM tests and relevant boundary/doc gates;
  record real results and remaining reference gaps. No new shader/model/UI.

Reference pixels and source-boundary algorithms do not establish proprietary
algorithm equality. Hairline requires a credible source hair/skin boundary;
bangs/ambiguous sources must abstain. No guessed hair texture reconstruction.
Do not weaken predeclared pixel criteria to label the previous failed candidate
or a no-op as a qualified repair. Media stays local/ignored, records aggregate.

## Delivered behavior

Six face fields now normalize, decode and validate as signed, preserving keys,
zero defaults and caps. The public ten-control `BeautyFaceShapeSlider` maps
0...1 over full safety caps and preserves direct positive=longer chinLength.
The CLI adds 50 explicit opt-in position cases; the 98 default and 99 canonical
batch cases retain identities/order. Current registration-source hash was
updated after checking those identities, without editing historical receipts.

Eight observed/lip-registered face/chin fields use a source-anchored continuous
Hermite contour band, pixel local axes, fixed eye/mouth boxes and their required
lattice edges. Cap/current fields enforce <=.45 gradient and <=6% contour span;
pose further attenuates. Other geometry retains its separate sampler and bounds.
New-map rejection does not restore those old pulls. Coarse positive compatibility
remains; new negatives require actual mouth registration. Small-face chin
scalloping is removed on the first reference portrait and the generated smooth
silhouette remains connected without new scallops at all four levels.

Hairline adds source-qualified distributed hair/skin transitions with coherent
columns, color/alpha, bangs-dip rejection and brow clearance. Its generated
positive is active in both directions. It still abstains on both originals;
contour smoothing also remains baseline-exact. No source segmentation, bangs
reconstruction, amplitude equality or complete Meitu appearance repair delivered.
Independent host UI/binary was not modified or installed.

## Final verification

- Related SwiftPM selection: **174 / 0 failures / 0 skips**, 153.845 s.
  A final source-guard correction then revalidated **7 overlapping hairline/head/actual-Metal cases / 0 failures / 0 skips**, 5.420 s; total distinct cases remains 174.
  Scope: BeautyParameters, resolver/backend contract, face/chin providers,
  geometry conflicts/shared stage; generated continuous-map directions and
  four quarter levels on 480x640 and 640x480, sparse/synthetic dense carriers;
  smooth generated chin, public CPU/actual Metal pixels, protected boxes,
  neutral/no-face/malformed/stale exit, JSON/caps, typed failure/recovery,
  sRGB/nonzero extent and rotation/mirror output metadata; soft and existing
  hairline/head/contour/chin compatibility; renderer process/default inventory.
- Two original sources × 19 isolated cases = **38 actual macOS/Vision outputs**.
  All retain dimensions and alpha; 30 active geometry endpoints plus eight
  exact neutral/hairline/smoothing outputs. Three whole-face comparison sheets
  inspected. The first portrait's small-face chin boundary is smooth; remaining
  width/jaw/taper/temple/cheek/chin/V changes are target-directed. Changing pixels
  are diagnostic counts, not standalone appearance qualification.
- Sixteen changed owner/guide/record documents: **306 local file links, zero missing**; git diff whitespace check passes.
- SDK boundary, exact-source test exception/mutation controls, archive verification,
  canonical inventory tests **2/0**, two actual --list-cases checks and image
  storage check pass. The new backend-selection test is hash-bound; modifying
  its allowed bytes with a new GPU declaration still rejects.
- No full SDK gate, native iOS/MediaPipe inference, UI/device regression, phone
  update or performance/thermal/endurance claim. Synthetic dense carriers are
  explicit package fixtures, not MediaPipe inference.

## Failed intermediate attempts and corrections

The earlier mirrored-point face candidate remains withdrawn in its dated
record. This implementation initially failed Swift 6 static key-path isolation;
keys now compute per use. Two old resolver tests encoded the superseded unit
negative contract; signed expectations were updated without changing pixel
thresholds. An intermediate map applied to coarse unregistered fixtures and
failed eight frozen chin assertions; requiring actual mouth registration
restored their unchanged route and all original assertions pass.

The supplementary hairline fixture initially omitted eyebrow side arguments;
the initializer was corrected. New public tests initially supplied four-point
invalid observed eyes and an unnecessary bitmap flip; valid eight-point eyes
and the SDK's raster row order fix the source/observation pair. The public test
also found device-RGB tagging on the new non-dense contour route; it now retains
source color while the coarse compatibility route stays unchanged. Direction
>1px, quarter increment >.1px, exact protection and original frozen pixel oracles
were not relaxed. A stale-support test initializer order was corrected.

Final source review additionally kept headWrap on its existing hard-edge
qualification, so new soft hairline admission does not silently expand a sibling
head effect. Nonfinite brow samples now exit before integer conversion; source
identity and headWrap abstention assertions pass in the seven-case retry.

An un-escalated final native renderer run failed with typed render_failed before
producing a new batch; existing files were not credited. The final authorized
native rerun succeeds for all 38 units and was decoded anew. Boundary initially
rejected the new actual-Metal test's backend selection; only its reviewed hash
was added, with mutation rejection exercised. No runtime auto-review rejection.

## Retained evidence and limits

The aggregate local receipt contains counts/statuses, logical IDs and bounded
pixel diagnostics only. Three metadata-stripped JPEG previews remain ignored,
within storage limits; originals in Downloads are untouched. Original-size
copies, derivatives and coordinate probes are removed after verification.
Current owners/taxonomy/guide and FACE-REF-01 distinguish the delivered signed
continuous repair from still-unmet Meitu appearance and hairline/smoothing gaps.
Existing nose edits, imported raw playbook and historical evidence are preserved.
