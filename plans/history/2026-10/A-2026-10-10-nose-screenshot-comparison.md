# 鼻部原图、手机截图与美图参考对照

Status: `completed` (comparison only). The owner reports weak root/bridge/tip
effects and asks whether Size actually controls the tip. Appearance defects
remain open under `NOSE-REF-01`; this record is not an algorithm repair.

## Scope and method

- Reviewed one owner-supplied original, eight original-resolution screenshots
  covering Size/Root/Bridge/Tip at both signed endpoints, and the previously
  owner-confirmed Meitu reference recording. No media was uploaded.
- Removed screenshot UI from the pixel comparisons. Each screenshot contains
  the same 1170×1560 photo canvas; paired endpoint photos have byte-identical
  pixels outside their changed region. Their differences are not explained by
  a whole-frame translation or different screenshot scaling.
- Resized the original for visual comparison. The video contains the same
  portrait at a larger viewing scale. A single uniform scale/translation fitted
  on unchanged eye/hair patches aligns it for display; no nasal warp or tonal
  matching was applied. Eye-template correlations exceed .995. Original versus
  preview/video comparisons remain visual, because their resampling/sharpness
  and video compression differ.
- Revisited the one-second reference samples and inspected native-resolution
  endpoint frames: Size at 3/5 s, Root at 40/42.5 s, Bridge at 49/51.5 s,
  Tip at 57.5/60 s. Signed endpoint positions/visible labels were checked.
  The fps=1 contact sheets are navigation samples, not exact original timestamps.
- Inspected current SDK providers/dense composition, separate host bindings and
  parameter retention, and the imported nose/478-point reference chapters.
  Reference prose describes proposed methods; it does not prove implementation
  in this SDK or in Meitu.

## Findings

| Item | Same-screenshot-pair pixel evidence | Original-detail judgment |
| --- | --- | --- |
| Size | 55,485 changed photo pixels; changed envelope 278×341. | Clearly active, but lower-nose shortening/lengthening dominates; negative endpoint makes the base pointed/longer. Whole-organ width and length do not look like a coordinated scale. |
| Root | 2,990 changed pixels; envelope 75×91, upper nasal region only. | Weakest visible response. Both endpoints look very similar even enlarged; a nonzero field is not sufficient appearance acceptance. |
| Bridge | 7,578 changed pixels; envelope 125×108, middle/lower dorsal sides. | Small local side changes; no convincing whole-bridge prominence adjustment. |
| Tip | 10,182 changed pixels; envelope 135×113, nasal base only. | Changes the lower arc/nostril-adjacent boundary more than the visible tip volume; endpoint distinction remains modest. |

Counts and envelope sizes are diagnostic aggregates, not perceptual pass criteria.
Root/Bridge/Tip pairs preserve the inspected eye/iris/lower-lip samples. The Size
pair changes **1,587 pixels in two conservative central red-lip sample boxes**;
a small inner-eye sample also differs (63 pixels, maximum channel delta 3).
The Tip pair has 54 changed central-upper-lip sample pixels, maximum delta 3.
These observations require a frozen isolated-field rerender/protection oracle;
they must not be relabeled an eye/lip preservation pass for this portrait.

`nose.size → noseSlim` and `nose.tip → noseTipSize` remain distinct and correctly
wired. Current dense Size uses four cardinal points of the observed nose
bounding box; its top/bottom pulls can visually dominate the lateral pulls.
Tip uses a separate local center. This explains why the owner perceives Size
as tip adjustment without establishing a binding error. Actual runtime
landmarks/admission scale for the supplied screenshots were not captured.

The same-scale Meitu comparison shows a more coordinated whole-nose size change
and a more distinguishable local tip-shape response. Root/bridge differences
are relatively subtle in the reference too; do not claim that every reference
endpoint produces a large change. The current SDK provides only 2-D surface
width changes for root/bridge. Imported chapters propose highlight/shadow or
normal-based relighting, which has not been implemented. The video does not
reveal Meitu's internal algorithm or prove that it uses that proposed method.

Host tool switching retains other field values. Whether every supplied pair
started from a neutral snapshot and whether the shown preview had settled
were not confirmed. Consequently, cross-tool/original comparisons do not prove
isolated-field causality or preview timing. No performance conclusion follows
from these still screenshots. Within-pair differences and their localization
remain observable evidence; the next SDK reproduction must freeze all fields
and the final displayed revision.

## Acceptance gaps and bounded follow-up

- Reproduce these fields independently from the same immutable source, with all
  sibling fields neutral and settled revision verified; keep combination as a
  separate case.
- Before modifying providers, define independent whole-nose width/height,
  alar/nostril shape, tip-only contour, eye/lip protection and artifact oracles.
  Size should coordinate width and height rather than maximize bottom motion.
- Measure root/bridge coverage and admitted motion at native detail. Separate
  bounded width adjustment from any separately scoped prominence/lighting work;
  larger caps or weaker protection are not acceptance substitutes.
- Preserve the prior generated-marker direction/monotonicity tests and their
  receipts. They do not cover this portrait's balanced proportions, lip leakage
  or useful root/bridge/tip appearance. No previous pass is reissued as a pass
  for this new input.
- Preview throttling addresses responsiveness; it does not repair the spatial
  field, relative proportions or missing appearance pass.

## Verification and retention

Completed native-resolution pair comparisons, original/video scale registration,
source/document/binding inspection and a metadata-stripped five-column display
preview. Only aggregate text and one bounded ignored preview are retained;
task-owned full-resolution video frames/crops are removed after inspection.

No SDK/App source or tests were changed, no SwiftPM/native tests were run, no
device was selected/installed, and no model/shader/backend or archive was changed.
Current plan/debt/taxonomy/quality limits are updated to include these findings;
historical repair receipts retain their original execution scope.
