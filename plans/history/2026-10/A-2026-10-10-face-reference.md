# Face reference comparison and rejected signed candidate

Status: `completed` for comparison and candidate disposition. Started
2026-10-10; recorded 2026-10-11. Appearance repair remains unmet.

## Authorized scope and retained result

The owner supplied eighteen Meitu face-shape screenshots, stated that all sibling
parameters were zero, supplied the second original and referred to the first
original from the previous discussion. Both authorized originals were found
and used locally. No instructions were taken from screenshot UI text.

Comparison, an isolated signed candidate, its tests and rollback are complete.
**No production face code, new public behavior or candidate test was retained.**
Existing uncommitted nose work remains intact. New durable changes are this
record, plan/debt/quality/taxonomy limits and four ignored compressed previews.
No host/UI, shader, backend, model, dependency or archived receipt was changed.

## Reference evidence and limitations

The screenshots cover ten controls: width, small face, chin length, chin taper,
V shape, jaw angle, hairline, cheekbone, temple and contour smoothing. Most pairs
show opposite ends of center-marked sliders. The images contain no numeric
parameter labels, so bipolar polarity is an inference. Chin length, V shape
and contour smoothing each have only one supplied endpoint. The two left-end
chin-taper screenshots are not identical: 162,999 photo pixels differ even
though the selected tool and slider position look the same. They cannot be
treated as exact repeated outputs or used to infer settled preview behavior.

The original-to-reference display registration used unchanged hair/background
on the first portrait and unchanged eyes on the second. The reference and
original colors differ slightly; this is not evidence that a face geometry
control caused a color change. Registered display previews are visual aids,
not native pixel-oracle inputs or proof of exact numeric intensity equivalence.
The screenshots do not reveal Meitu's algorithms or establish SDK/UI wiring.

## Current isolated SDK reproduction

Freshly built `BeautyExampleRenderer` rendered thirteen cases on each original:
neutral, width, small face, V shape, jaw angle, both chin-length directions,
temple, cheekbone, chin taper, both hairline directions and contour smoothing.
Every case starts from the immutable original with sibling parameters zero.
All **26 distinct saved 1728 × 2304 outputs** were decoded and compared with that
portrait's SDK neutral output. Alpha was unchanged in all comparisons.

These are **macOS/Vision, CPU still-image outputs**. They do not reproduce the
current iOS/MediaPipe mesh route. The generated dense-map check below uses a
synthetic carrier, not a native MediaPipe portrait inference result. No simulator
or physical device was selected, built or run.

| Control | Reference and current implementation finding |
| --- | --- |
| Width / `faceSlim` | Reference includes widening and narrowing. Public input currently accepts positive narrowing only. Current provider uses two broad cheek pulls rather than one continuous contour profile. |
| Small face / `faceSmall` | Reference lower-face reduction looks coordinated. Current sparse contour pulls produce a visibly uneven, scalloped chin on the first portrait at the existing isolated 0.35 case. This fails the appearance challenge even though pixels change. |
| Chin length / `chinLength` | Already signed. Positive SDK values lengthen; negative shorten. The supplied reference right endpoint shortens, so a shortening-positive host slider needs explicit mapping. Do not reverse the existing SDK contract from UI polarity. |
| Chin taper / `chinTaper` | A narrow centerline-owned lower-contour change exists, but only positive tapering is accepted. Duplicate-looking left endpoints differ, and full bilateral appearance parity is unqualified. |
| V shape / `faceVShape` | Positive lower-face geometry exists. Only one reference endpoint is supplied; no bidirectional or equal-strength comparison follows. |
| Jaw angle / `jawSlim` | Reference changes are more local to the lower lateral outline. Current sparse pair has broad cheek influence and positive narrowing only. Jawline remains the existing alias, not a separate parameter. |
| Temple / `templeFullness` | Positive fullness only. On the Vision route, much of the affected domain is below the upper temple/forehead; anatomical targeting and bipolar parity remain unqualified. |
| Cheekbone / `cheekboneSlim` | Positive narrowing only. Vision contour-band changes sit largely on the mid/lower cheek, so changed bytes do not demonstrate the reference's upper-cheek target. |
| Hairline / `hairlineHeight` | Both signed outputs are entirely SDK-baseline-exact on both portraits. The source-boundary refiner abstains for these inputs; its existing high-contrast generated-domain qualification does not guarantee activity here. |
| Contour smoothing / `faceContourSmooth` | Both outputs are entirely SDK-baseline-exact. Existing bounded rough-edge admission does not imply this portrait/reference class is served. |

Inspecting the whole face and original-detail chin boundary, rather than only
pixel counts, exposes the small-face defect. No population, physical-device,
appearance-parity or performance claim is made.

## Candidate oracle and disposition

The bounded candidate made width/small-face/jaw signed through public
normalization, decoding, resolver caps and backend admission. Negative values
reversed existing positive point vectors; positive vectors and legacy budgets
were preserved, and combination accounting used absolute values. Out-of-canvas
reverse fields abstained as a unit. No cap was raised.

Before examining its outputs, the new generated-pixel case required opposite
width directions, each of four quarter-cap levels increasing measured width
change by more than 0.1 pixel, cap amplitude over 1 pixel, exact predefined
central/exterior bytes and alpha, deterministic repeats, and the existing dense
displacement/gradient bounds. Source-defined Gaussian marks measured width;
neither changed-byte counts nor re-detected landmarks were the direction oracle.
Two portrait/landscape raster shapes were checked as image-input dimensions,
not a device/font/orientation environment matrix.

Five targeted candidate cases ran: four passed (reconstruction/backend;
vector reversal/positive geometry; absolute combination budget;
neutral/missing/out-of-canvas abstention). **One dense pixel case failed**,
with repeated monotonicity and predefined center/exterior protection assertions.
For example, negative width change rose to about 23.99 pixels at half-cap,
then fell to 22.69 at three-quarter-cap and 17.81 at cap. Positive width and
jaw also failed portions of this newly defined monotonicity oracle. These
failures are a counterexample to simply enabling signed mirrored vectors;
they are not an assertion that the entire SDK or every portrait fails.

The candidate and its test were withdrawn rather than loosening the oracle.
Existing nose edits were preserved. Restored code was rebuilt and the six
existing width/small-face/jaw/V/chin provider tests passed: **6 tests,
0 failures, 0 skips**. They confirm restoration of existing contracts, not
acceptance of the new image appearance or the rejected signed candidate.

## Verification and retention

- Two original images, eighteen reference screenshots, 26 actual SDK outputs
  and original-detail display comparisons inspected locally.
- Candidate tests: 5 cases executed, 4 passed, 1 failed; candidate removed.
- Restored current tests: `swift test --package-path BeautySDK --filter
  'FaceShapeWarpProviderTests/test(FaceSlim|FaceSmall|ChinLength|Jaw|VShape)'`:
  6/0/0. No full SwiftPM gate or CPU/Metal/native iOS parity rerun.
- Archive integrity, SDK-only boundary, document links, whitespace and example
  image storage checked at completion. Full-resolution task-owned copies and
  rendered/assembled outputs were removed after analysis; original owner files
  and prior local work were preserved.
- Four bounded metadata-stripped ignored display JPEGs retain width/small/jaw,
  temple/cheek/hairline, chin/V and contour-smoothing comparisons. They are not
  acceptance fixtures. The incomplete width/small/jaw assembly was rebuilt
  sequentially using three repeat renders of the restored current code; all
  three display rows were inspected after JPEG export.

## Remaining direction

FACE-REF-01 records the gap. A later implementation must prove a stable
source-anchored, continuous contour field with distinct width/small/jaw/temple/
cheek/chin domains, bilateral direction, monotone useful amplitude, eye/mouth
and exterior protection and a non-scalloped chin. It must rerender the relevant
native provider instead of assuming Vision and MediaPipe are identical.
Do not raise caps, weaken admission or substitute more changed pixels for
these criteria. This record does not automatically authorize new model,
training, host/UI or unrelated retouch work.
