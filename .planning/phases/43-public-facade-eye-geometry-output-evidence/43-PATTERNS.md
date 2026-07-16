# Phase 43 Pattern Mapping

## Reuse

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` owns the ordered public-facade case matrix and must remain a `BeautySDK`-only client with one shared `BeautyEngine.processResult` call.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` owns source inventory, single-field construction, facade imports, no-face extent, and redacted diagnostics.
- Archived Phase 39/36 helpers provide bounded descriptor reads, complete PNG/JPEG validation, exact live inventory, fixed ROI/floors, no-face fallback, and self-tests. Phase 29 is the older eye comparator only; do not import it.
- `example-images/generate_gallery.py` owns descriptor-safe ignored gallery publication and exact renderer/gallery bijection.

## Phase 43 Extensions

1. Add eleven IDs (`eyeHeight_0p25`, `eyeLength_0p25`, `upperEyelidLift_0p25`, `pupilSize_0p25`, `gazeCorrection_0p25`, `lowerEyelidDrop_0p25`, `eyeTilt_plus0p25`, `eyeTilt_minus0p25`, `innerCornerOpen_0p25`, `outerCornerOpen_0p25`, `eyeSymmetry_0p25`) to the existing 44-case source/test inventory.
2. Build a self-contained `check_eye_geometry_renderer_outputs.py` that discovers 55 cases × seven fixtures, decodes 385 outputs with bounded standard-library code, partitions contour/pupil/symmetry eligibility, and evaluates fixed eye-local visibility, signed tilt, semantic-family, gaze-reduction, no-face, and artifact gates.
3. Extend the `eyes` gallery descriptor by those exact IDs, publish once after strict acceptance, and update only output-evidence docs/ledgers. Final caps, promotion, and boundary gates remain Phase 44.

## Required Data Flow

```text
BeautyParameters -> BeautyExampleRenderer -> BeautyEngine.processResult
 -> ignored 385-PNG matrix -> bounded decoder/dimensions
 -> eligibility partition -> fixed eye ROI families/no-face checks
 -> aggregate evidence -> ignored gallery bijection
```

