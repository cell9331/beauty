# Phase 36 Pattern Mapping

**Mapped:** 2026-07-13  
**Scope:** NOSE-07 through NOSE-09; pattern extraction only

## Repository State That the Phase Must Extend

The active renderer is a flat public-facade matrix. `BeautySDK/Sources/BeautyExampleRenderer/main.swift` currently has 34 ordered `RenderCase` values, seven recursively discovered fixtures, and one shared processing loop. The loop is already the correct facade seam:

```swift
let result = try engine.processResult(
    image: inputImage,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: renderCase.parameters
)
```

The renderer imports `BeautySDK` and does not import `BeautyCore`, `BeautyDetection`, `BeautyEffects`, `BeautyRender`, or `BeautyResources`. A Phase 36 case therefore belongs in the `cases` array as public `BeautyParameters`; it does not need and must not introduce a second render path.

The actual committed input topology is:

```text
example-images/input/
├── negatives/
│   └── no-face-gradient.png     64×64 PNG
└── portraits/
    ├── e1.png                   675×900 PNG
    ├── e2.png                   506×900 PNG
    ├── e3.png                   506×900 PNG
    ├── e4.png                   506×900 PNG
    ├── e5.png                   506×900 PNG
    └── e6.jpg                   1728×2304 JPEG
```

All seven stems are currently unique. This matters because renderer output deliberately flattens the source tree:

```swift
let baseName = imageURL.deletingPathExtension().lastPathComponent
let outputName = "\(baseName)__\(renderCase.id).png"
```

A duplicate stem in different input subdirectories would overwrite an earlier result. Any Phase 36 inventory discovery must reject that topology before accepting an output count.

The ignored local routes currently contain the completed Phase 33 matrix:

- `example-images/output/`: 238 flat PNGs, exactly 34 cases × 7 fixtures.
- `example-images/gallery/`: 238 PNGs grouped as 56 face-shape, 42 eyes, 42 mouth, 35 skin, 35 nose, 14 color, and 14 filter.
- `.gitignore` ignores both complete directory roots.
- `git ls-files example-images/output example-images/gallery` is empty.

These 238 files are a historical local matrix, not a Phase 36 baseline. Exact 252-file evidence requires cleaning or otherwise rejecting all unexpected renderer-shaped PNGs before/while validating the regenerated 36 × 7 matrix.

## Files and Roles

### Runtime and source-contract owners

| File | Role in the existing system | Phase 36-compatible change surface |
| --- | --- | --- |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | Defines ordered case IDs, labels, public parameters, recursive fixture discovery, public-facade processing, flat output naming, and watermarking. | Add exactly the two isolated public cases. Keep the shared `BeautyEngine.processResult` loop and `BeautySDK`-only package import. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | Freezes exact case order, checks facade-only imports, extracts individual case snippets, verifies one public field per feature case, exercises no-face facade summaries, and proves default pixels before watermark. | Expand the exact inventory to 36 and replace the stale Phase 31 nose prohibition with an exact six-field/seven-case contract. A representative two-new-case no-face loop fits the existing facade test role if diagnostic degradation is asserted here. |

The existing case-test idiom is worth preserving:

```swift
let snippet = try rendererCaseSnippet(for: caseID, in: source)
XCTAssertTrue(snippet.contains(requiredParameter))
XCTAssertEqual(
    noseFields.filter { snippet.contains($0) },
    [requiredParameter.split(separator: " ").first.map(String.init) ?? ""]
)
```

For Phase 36, `noseFields` must include `noseRootNarrowing:` and `noseTipLift:`. The current broad forbidden value `"noseRoot"` cannot remain because it is a valid prefix of `noseRootNarrowing`. Alias rejection must operate on exact case IDs, initializer labels, or standalone tokens rather than unrestricted substring search.

### Phase-owned machine and narrative evidence

| File | Role | Ownership note |
| --- | --- | --- |
| `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py` | Discover renderer cases and fixtures; validate the exact matrix, full PNG decode, dimensions, nose ROI visibility/independence, no-face output, and unexpected outputs. | New, v1.9-owned, and preferably self-contained so it remains runnable after milestone archival. |
| `.planning/phases/36-public-facade-output-evidence/36-NOSE-OUTPUT-EVIDENCE.md` | Record observed commands, discovered inventories, dimensions, fixed ROI/thresholds, per-family minima/counts, no-face behavior, gallery/ignore/tracking results, and non-claims. | New factual evidence owner; generated PNGs remain local and are not embedded as committed baselines. |
| `.planning/phases/36-public-facade-output-evidence/36-VALIDATION.md` | Existing Phase 36 Nyquist map. | Modify only when execution establishes the real automated gates; do not infer passing evidence from historical matrices. |
| `.planning/phases/36-public-facade-output-evidence/36-VERIFICATION.md` and review/summary artifacts | Final NOSE-07 through NOSE-09 verdict and scope audit. | Later closeout artifacts, not substitutes for helper output. |

### Gallery and current evidence-index owners

| File | Existing role | Matching extension |
| --- | --- | --- |
| `example-images/generate_gallery.py` | Maps case IDs into safe ignored gallery groups, rejects duplicate fixture stems, deletes only within the allow-listed gallery root, and copies a complete expected matrix. | Append both IDs to `CASE_GROUPS["nose"]`; retain safe-root and overlap checks. The gallery inventory is manually grouped, so it should be checked for an exact case-ID bijection with the renderer inventory. |
| `example-images/README.md` | Documents input/output/gallery topology and current helper commands/counts. | Add the Phase 36 helper and factual current matrix after successful execution; archived Phase 33 helper routing is now stale and should not be copied as a live path. |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | Long-lived example-image evidence index. | Add output-only Phase 36 facts and the two case IDs without promoting `山根`, `提升`, or branch-level `鼻子`. |

### Completion ledgers, only after evidence passes

`.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md` are the appropriate Phase 36 status owners. Only NOSE-07, NOSE-08, and NOSE-09 may close. Product feature ledgers, branch READMEs, `.planning/PROJECT.md`, `QUALITY_SCORE.md`, public model/geometry/provider/resolver code, `Package.swift`, and Demo source are outside this phase's change surface.

## Data Flow and Gate Placement

```text
renderer source case IDs ─┐
                          ├─> discovered expected matrix
recursive input fixtures ─┘        │
                                   ├─> <fixtureStem>__<caseID>.png
BeautyParameters(case value)        │          │
  -> BeautyEngine.processResult ─────┘          ├─> full decode + extent gate
  -> watermark + PNG                           ├─> portrait nose-ROI gates
                                                ├─> no-face extent/no-op gate
                                                └─> ignored gallery copies
```

The sources of truth are deliberately split:

- Renderer source owns ordered case inventory.
- Recursive input discovery owns fixture inventory.
- The product of those observed inventories owns the expected output paths.
- The frozen Phase 36 contract independently requires 36 cases and 7 fixtures. Thus the helper should compute `len(case_ids) * len(fixtures)` first, then fail explicitly if either inventory differs; it should not merely print `252`.
- The gallery is a presentation copy and cannot establish rendering, decoding, or independence. It is downstream of a passing flat matrix.

The renderer and gallery use compatible recursive sorting today: the renderer sorts input-relative paths; Python `sorted(Path.rglob(...))` sorts full `Path` values under one common root. Both flatten by `stem`, so both require the same duplicate-stem rejection even though the current renderer itself does not perform it.

## Closest Existing Analogs

### 1. Phase 31 nose renderer source and tests

Phase 31 is the closest feature analog. It added five isolated public cases and updated the exact renderer inventory/single-field regression test. Its plan language captures the right source boundary: “exact case inventory; one public field per case,” `BeautySDK`-only import, and rejection of out-of-scope aliases.

The current renderer already provides the legacy comparison anchors Phase 36 needs:

```swift
BeautyParameters(noseTipSize: 0.30)
BeautyParameters(noseTipSize: -0.30)
BeautyParameters(noseBridge: 0.30)
```

Phase 36 should follow the same isolated construction shape for `BeautyParameters(noseRootNarrowing: 0.25)` and `BeautyParameters(noseTipLift: 0.25)`, but its independence evidence is stronger than Phase 31's source-only single-field assertion: it directly compares saved pixels with the nearest legacy cases.

### 2. Phase 29 decoder and watermark calculation

The live `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py` contains the durable standard-library primitives:

- PNG signature/chunk validation and zlib decompression;
- support for renderer RGB/RGBA, 8-bit, non-interlaced PNGs;
- PNG filter reversal including Paeth;
- PNG/JPEG fixture dimension parsing;
- output name construction from fixture stem and case ID;
- the renderer-matched watermark exclusion formula.

The watermark boundary is derived from the renderer constants, not guessed:

```python
font_size = max(34.0, min(72.0, width / 30.0))
padding = max(24.0, width / 70.0)
watermark_band = font_size * 1.75
excluded_bottom_rows = int(math.ceil(padding * 2 + watermark_band))
return max(0, height - excluded_bottom_rows)
```

This is the correct basis for an above-watermark nose ROI. Phase 29's `top_region_differs` returns on the first unequal pixel, however, so it is not sufficient by itself for Phase 36 visibility or anti-alias evidence.

### 3. Phase 33 decoded RGB ROI comparisons

Phase 33 is the newest direct-pixel pattern. Its helper caches decoded RGB rows, checks equal dimensions, and counts changed pixels in a normalized feature crop:

```python
@lru_cache(maxsize=None)
def decoded_rgb(path: Path) -> tuple[int, int, list[bytes]]:
    ...

left, right = int(width * 0.10), int(width * 0.90)
top, bottom = int(height * 0.25), helper.comparable_top_region_rows(width, height)
```

Useful aspects to carry forward are full RGB decoding, one global normalized region, caching, direct candidate-vs-candidate comparisons, and separate counters for distinct evidence families. Phase 36 must strengthen the return value beyond Phase 33's `changed/outside/total`: each nose comparison needs at least ROI changed-pixel count, ROI pixel count, and total absolute RGB delta, with fixed nonzero floors.

Phase 33 also demonstrates the correct reporting style: geometry-vs-baseline, signed-pair, and color-containment results are printed separately. For Phase 36, the corresponding independent families are:

| Family | Pair | Current portrait count |
| --- | --- | ---: |
| Root visibility | root narrowing vs baseline | 6 |
| Lift visibility | tip lift vs baseline | 6 |
| Root independence | root narrowing vs bridge | 6 |
| Lift positive independence | tip lift vs positive tip size | 6 |
| Lift negative independence | tip lift vs negative tip size | 6 |

The two visibility families total the required 12 comparisons; root independence is 6; the two signed lift families total 12. They must remain distinct gates and should record observed minima independently.

### 4. Existing no-face facade regression

`BeautyRendererOutputRegressionTests.testNoFaceFixtureProducesNoFaceSummaryForFaceShapeCombo` is the closest diagnostic analog. It asserts:

```swift
XCTAssertEqual(result.output.extent, input.extent)
XCTAssertEqual(result.detectionSummary?.availability, .noFace)
XCTAssertEqual(result.detectionSummary?.reasons, [.noFaceDetected])
XCTAssertEqual(result.metrics["beauty.detection.geometryRequired"], 1)
XCTAssertEqual(result.metrics["beauty.detection.usedFaceCount"], 0)
XCTAssertTrue(result.warnings.contains { $0.code == "face_effects_skipped_no_face" })
assertRedacted(result)
```

That pattern proves public-facade degradation state, whereas a generated PNG alone proves only existence, decode, extent, and pixels. For the saved outputs, comparing each new no-face result with `geometryBaseline_noop` only above the watermark is a useful complementary gate because the distinct display labels necessarily change the excluded watermark band.

### 5. Existing gallery containment

`generate_gallery.py` already has the relevant path-hardening pattern:

```python
if not is_relative_to(resolved_gallery, ALLOWED_GALLERY_ROOT):
    raise GalleryError("Gallery directory must be under example-images/gallery")
if paths_overlap(resolved_gallery, resolved_input) or paths_overlap(resolved_gallery, resolved_output):
    raise GalleryError("Gallery directory must not overlap input or output directories")
```

It also deletes and recreates the gallery, so gallery count evidence is naturally clean. The flat renderer output directory is not cleaned by the renderer, making unexpected-output rejection or explicit pre-render cleanup especially important there.

## Phase 36 Helper Shape Suggested by the Existing Code

This is a role map, not an execution plan. A self-contained helper naturally separates into these responsibilities:

| Responsibility | Existing source pattern | Phase 36-specific requirement |
| --- | --- | --- |
| CLI | Phase 29 `parse_args` | Require `--input`, `--output`, and `--renderer-source`. |
| Case discovery | XCTest `rendererCaseIDs(in:)` | Parse ordered `id: "..."` entries, reject duplicates, require exact 36-case frozen inventory and both new IDs once. |
| Fixture discovery | renderer `fixtureImageURLs`; gallery `discover_fixture_stems` | Recurse over PNG/JPG/JPEG regular files, sort deterministically, reject duplicate stems, require current frozen seven-fixture inventory. |
| Matrix construction | renderer flat name; Phase 29 `expected_output_name` | Compute expected names from observed inventories and reject missing and unexpected renderer-shaped PNGs. |
| Decode/extent | Phase 29 PNG/JPEG readers | Require nonzero file, complete supported PNG decode, and exact corresponding input dimensions for all expected paths. |
| RGB comparisons | Phase 33 `decoded_rgb` | Count changed pixels and absolute RGB delta inside one documented normalized nose ROI. |
| Watermark exclusion | Phase 29 `comparable_top_region_rows` | Assert ROI bottom is strictly at or above the comparable-row boundary for every dimension. |
| No-face saved output | Phase 31/33 presence checks | Require both new outputs and baseline to decode at 64×64 and require RGB identity above the watermark. Exclude this fixture from all portrait visibility totals. |
| Reporting | Phase 33 separate counters | Print discovered counts, dimension distribution, ROI/threshold constants, and each of five comparison families separately. |

Research proposes x=25–75% and y=20–70% as a calibration starting rectangle, not an already-proven acceptance constant. The final single global rectangle and fixed changed-pixel/absolute-delta floors must be recorded identically in helper code and `36-NOSE-OUTPUT-EVIDENCE.md` after observing the actual regenerated outputs. Thresholds must not be derived dynamically during an accepting run.

## Archival and Evidence Hazards

### Broken sibling imports in archived helpers

Both archived helpers calculate this path relative to their own phase directory:

```python
EYE_HELPER = PHASE_DIR.parent / "29-eye-renderer-output-evidence" / "check_eye_renderer_outputs.py"
```

After archival, their parents are `.planning/milestones/v1.7-phases/` and `.planning/milestones/v1.8-phases/`; neither contains Phase 29. The actual helper remains at `.planning/phases/29-eye-renderer-output-evidence/check_eye_renderer_outputs.py`. Consequently the archived Phase 31 and Phase 33 helpers are not runnable from their archival locations. Phase 36 should copy/re-own the small standard-library decoder algorithms or resolve a repository-root owner with an explicit availability failure. A new sibling-relative import would recreate the same failure at the next milestone archive.

### Historical helpers hard-code inventories and unconditional totals

Phase 31 mutates a hard-coded Phase 29 case list and prints literal `196/196`; Phase 33 repeats nose and mouth IDs and prints literal `238/238`. Those patterns were adequate historical evidence but do not meet the Phase 36 decision to discover cases and fixtures from actual sources. Literal expected totals are acceptable only as a separate frozen-contract assertion after observed inventory calculation.

### First-pixel inequality is not visibility evidence

Phase 29 accepts the first changed pixel above the watermark; Phase 33 accepts `changed > 0`. Phase 36 explicitly needs evidence-backed fixed floors for changed pixels and total RGB delta. Whole-file bytes, watermark text, labels, and broad whole-image/top-region inequality can all pass while intended nose geometry is invisible or aliased.

### Coordinate and watermark drift

The renderer draws the watermark from width-dependent font/padding values. The helper's exclusion formula duplicates those values, so renderer changes can silently desynchronize it. Phase 36 evidence should state the formula and validate the ROI remains wholly above the returned comparable-row boundary on every fixture dimension. A nose ROI must not extend down to Phase 33's generic `bottom = comparable_top_region_rows(...)` merely because that was appropriate for a lower-central mouth crop.

### Stale and extra generated files

`BeautyExampleRenderer` creates its output directory but never removes old files. Verifying only expected paths could accept 252 expected outputs while unrelated/stale PNGs remain. Exact inventory evidence requires clean regeneration or helper rejection of unexpected `*.png` files. Conversely, the gallery generator deletes its destination safely before copying, so its exact count has a stronger clean-generation basis.

### Gallery inventory is duplicated configuration

`CASE_GROUPS` manually repeats renderer IDs. Missing either new case would yield a smaller but internally consistent gallery unless the gallery total/case set is checked against the renderer-derived inventory. Duplicate IDs across groups could also produce misleading copy totals. Phase 36 containment evidence should compare the flattened gallery case list with the renderer case set and reject missing, extra, or duplicate group entries.

### Generated files are evidence inputs, not repository records

Ignore rules reduce accidental tracking but do not prove containment by themselves. Evidence should combine representative `git check-ignore`, empty `git ls-files` for both roots, and a staged-path scan. No generated PNG should be force-added, copied to a non-ignored route, or committed as a golden baseline. The helper and Markdown evidence are the repository-owned artifacts.

### No-face claims have two different strengths

Presence, decode, non-empty bytes, and 64×64 extent do not prove the diagnostic reason. Above-watermark equality with baseline proves saved pixel no-op but still does not expose `detectionSummary`. Public-facade XCTest is the proper owner for `.noFace`, `.noFaceDetected`, zero used faces, aggregate-only geometry-required metrics, warning category, and redaction. Neither layer should be described as Phase 37's exhaustive six-field degradation matrix.

### Evidence documents can outlive their commands

The current `example-images/README.md` points at `.planning/phases/33-mouth-renderer-output-evidence/...`, but Phase 33 has already moved under `.planning/milestones/v1.8-phases/...`; the archived helper then has the broken sibling import above. Phase 36 documentation should use its current path while active and should avoid claiming archival rerunnability unless the helper is self-contained.

## Boundaries to Preserve in Mapping and Evidence

- The new `0.25` render strengths are provisional evidence inputs, not final caps or commercial calibration.
- `noseRootNarrowing` must be compared with but never reinterpreted as `noseBridge`/`山根` legacy evidence.
- `noseTipLift` must be compared with both signed `noseTipSize` directions and never treated as either one.
- Phase 36 closes only output visibility, independence, extent, no-face representative behavior, gallery inventory, and artifact containment for NOSE-07 through NOSE-09.
- Final caps, exhaustive six-field missing/stale/reused/provider-empty behavior, exactly-once combined weakening, active-source boundary closeout, documentation promotion, and branch completion remain Phase 37.
- Renderer evidence does not establish physical-device parity, visual naturalness approval, performance readiness, packaging, shipping, launch readiness, or broad product parity.

## Compact Analog Matrix

| Phase 36 concern | Closest analog | Reuse | Strengthen or avoid |
| --- | --- | --- | --- |
| Two public cases | Phase 31 five nose cases | One isolated `BeautyParameters` field, shared facade loop | Add only two IDs; no combo or internal geometry access |
| Exact source contract | Current renderer regression test | Ordered IDs, snippet extraction, facade import guards | Six nose fields across seven cases; precise alias matching |
| Full matrix | Phase 29 helper | Standard-library image parsing and dimension map | Discover source/fixtures; reject duplicate stems and unexpected outputs |
| Nose-local diff | Phase 33 mouth ROI | Cached decoded RGB, global normalized ROI | Fixed changed-pixel and RGB-delta floors; five independent families |
| Watermark exclusion | Phase 29 formula | Width-derived comparable rows | Require the entire nose ROI above the band |
| No-face facade | Existing face-shape no-face XCTest | Extent, summary, warning, metrics, redaction | Loop only the two new isolated parameters; retain Phase 37 boundary |
| No-face saved pixels | Phase 31/33 representative output | Existence/decode/extent | Compare both new outputs with baseline above watermark |
| Gallery | Existing `nose` group and safe deletion | Group routing and ignored copies | Exact renderer/group bijection; clean 252-copy count |
| Evidence prose | Phase 33 evidence table | Command-backed counts and conservative wording | Record minima/thresholds/formula and explicit non-promotion |
| Helper reuse | Archived Phase 31/33 import | Decoder algorithm only | Do not reuse their broken sibling-relative import topology |
