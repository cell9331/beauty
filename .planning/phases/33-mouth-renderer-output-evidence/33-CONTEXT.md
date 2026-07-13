# Phase 33: Mouth Renderer Output Evidence - Context

**Gathered:** 2026-07-13
**Status:** Ready for planning
**Mode:** Autonomous `--auto`; recommended decisions accepted

<domain>
Add public-`BeautySDK`-facade renderer, decoded helper, and ignored gallery evidence for the four existing mouth/lip parameters. Safety policy and ledger promotion remain Phase 34 scope.
</domain>

<decisions>
- Add exactly six isolated cases: signed `mouthSize`, signed `mouthWidth`, `smile`, and `lipColor`; each sets one existing public field.
- Preserve seven fixtures, expanding 28 cases to 34 and 196 outputs to 238.
- Require 238/238 decoded, non-empty, same-dimension PNGs; 30/30 portrait geometry-vs-baseline mouth-ROI comparisons; 12/12 signed-pair comparisons; and representative no-face extent evidence.
- Treat `lipColor` only as color evidence: require 6/6 changes in the documented lower-central mouth ROI, never count it as geometry displacement or true `丰唇`.
- Route all six cases to ignored `example-images/gallery/mouth/`; commit no generated output/gallery PNG.
- Preserve facade-only imports, local-only behavior, public inventory, and current package boundaries.
</decisions>

<code_context>
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` owns the public case matrix.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` owns exact inventory and one-field guards.
- `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` provides the proven standard-library PNG decoder.
- `example-images/generate_gallery.py` owns safe ignored-gallery routing.
</code_context>

<canonical_refs>
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/PROJECT.md`
- `ARCHITECTURE.md`
- `DESIGN.md`
- `RELIABILITY.md`
- `PRODUCT_SENSE.md`
- `example-images/README.md`
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`
</canonical_refs>

<deferred>
Caps, freshness/degradation, combined weakening, redaction, row promotion, and milestone closeout belong to Phase 34. `上下`, `倾斜`, `左右`, `M唇`, true `丰唇`, and `白牙` remain future.
</deferred>
