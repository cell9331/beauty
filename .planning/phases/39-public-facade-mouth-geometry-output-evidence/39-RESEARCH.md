# Phase 39: Public-Facade Mouth Geometry Output Evidence — Research

**Researched:** 2026-07-14  
**Status:** Ready for planning  
**Scope:** MOUTH-09, MOUTH-10, and MOUTH-11 only

## Executive Summary

Phase 39 should extend the existing public-facade renderer and its generated-evidence harness; it should not change mouth geometry, caps, conflict behavior, public parameters, or product status. Phase 38 already proves five source/JSON-compatible public values, private outer/upper/lower/inner lip supports, eight independent provider emissions, provider-eligible resolver convergence, and redacted facade routing. The remaining Phase 39 obligation is to make each new path observable in saved output and to prove visibility, signed-direction separation, semantic independence, no-face no-op behavior, and ignored artifact containment.

The smallest complete change surface is:

- eight isolated `BeautyExampleRenderer` cases using the provisional `0.25` evidence value;
- an exact 44-case renderer regression contract and eight-case public-facade no-face loop;
- one self-contained, standard-library-only Phase 39 helper that discovers the live matrix, strictly decodes every PNG, applies one fixed mouth ROI and fixed post-calibration floors, and reports each comparison family separately;
- the eight IDs added to the existing hardened gallery generator's `mouth` group;
- factual example-image/evidence documentation and Phase 39 verification artifacts that close only MOUTH-09 through MOUTH-11.

With the current seven fixtures, the frozen expectation is 44 × 7 = 308 output PNGs. Six portraits yield exactly 48 new-case-to-baseline comparisons, 18 signed-pair comparisons, 12 peak-independence comparisons, and 18 plump-independence comparisons. The 64 × 64 no-face fixture yields eight separately gated baseline-identical comparisons outside the watermark raster. These counts must be derived from discovered inventories and successful comparisons before they are reported.

## Current Repository Inventory

### Renderer and facade seam

`BeautySDK/Sources/BeautyExampleRenderer/main.swift` currently owns 36 ordered `RenderCase` values. It imports only `BeautySDK`, creates one `BeautyEngine`, and routes every case through the same public call:

```swift
engine.processResult(
    image: inputImage,
    metadata: BeautyInputMetadata(orientation: .up, source: .testFixture),
    parameters: renderCase.parameters
)
```

The existing mouth anchors are:

- `mouthSize_plus0p35`
- `mouthSize_minus0p35`
- `mouthWidth_plus0p35`
- `mouthWidth_minus0p35`
- `smile_0p50`
- `lipColor_0p50`
- shared `geometryBaseline_noop`

The renderer recursively sorts regular PNG/JPG/JPEG fixtures by input-relative path and flattens every output to `<fixtureStem>__<caseID>.png`. This makes duplicate fixture stems an overwrite hazard even when their source paths differ.

### Committed fixtures

The live input inventory is seven files with unique stems:

| Role | Relative path | Decoded extent |
| --- | --- | ---: |
| no-face | `negatives/no-face-gradient.png` | 64 × 64 |
| portrait | `portraits/e1.png` | 675 × 900 |
| portrait | `portraits/e2.png` | 506 × 900 |
| portrait | `portraits/e3.png` | 506 × 900 |
| portrait | `portraits/e4.png` | 506 × 900 |
| portrait | `portraits/e5.png` | 506 × 900 |
| portrait | `portraits/e6.jpg` | 1728 × 2304 |

The ignored local output and gallery routes currently each contain the previous 36 × 7 = 252 matrix. Those files are disposable local evidence, not a Phase 39 baseline. An accepting 308-file claim requires a guarded clean output regeneration and exact missing/unexpected-file rejection.

### Existing automated owners

- `BeautyRendererOutputRegressionTests.swift` freezes case order, checks the `BeautySDK`-only import boundary, extracts case snippets, verifies one public field per feature case, and already contains a Phase 36 no-face facade loop plus redaction assertions.
- Its Phase 33 mouth method currently allows only the six shipped mouth/lip cases and explicitly forbids several now-valid Phase 38 field names. Phase 39 must replace that stale prohibition with an exact current mouth contract rather than merely deleting the guard.
- `example-images/generate_gallery.py` already discovers renderer IDs, rejects duplicate renderer/gallery IDs and fixture stems, requires an exact case-set bijection, securely reads output PNGs, and publishes a descriptor-anchored ignored gallery. Only the eight mouth IDs need to be added to its existing group.
- Phase 38's focused facade test proves route activation for the five semantic fields, but does not decode pixels or exercise the committed no-face fixture; it remains supporting evidence, not a substitute for Phase 39.

## Exact MOUTH-09 Renderer Contract

Add exactly these eight cases, after the existing mouth/lip cases or in another single documented deterministic location while preserving all existing case order:

| Case ID | Display label | Public construction |
| --- | --- | --- |
| `mouthYPosition_plus0p25` | `mouthYPosition +0.25` | `BeautyParameters(mouthYPosition: 0.25)` |
| `mouthYPosition_minus0p25` | `mouthYPosition -0.25` | `BeautyParameters(mouthYPosition: -0.25)` |
| `mouthTilt_plus0p25` | `mouthTilt +0.25` | `BeautyParameters(mouthTilt: 0.25)` |
| `mouthTilt_minus0p25` | `mouthTilt -0.25` | `BeautyParameters(mouthTilt: -0.25)` |
| `mouthXPosition_plus0p25` | `mouthXPosition +0.25` | `BeautyParameters(mouthXPosition: 0.25)` |
| `mouthXPosition_minus0p25` | `mouthXPosition -0.25` | `BeautyParameters(mouthXPosition: -0.25)` |
| `lipPeakDefinition_0p25` | `lipPeakDefinition 0.25` | `BeautyParameters(lipPeakDefinition: 0.25)` |
| `lipPlump_0p25` | `lipPlump 0.25` | `BeautyParameters(lipPlump: 0.25)` |

The exact source contract should assert:

1. ordered renderer inventory is 44 and contains each new ID exactly once;
2. each of the fourteen mouth-group cases uses exactly one of the nine public mouth/lip fields (`mouthSize`, `mouthWidth`, and three new signed fields each have two cases; `smile`, `lipPeakDefinition`, `lipPlump`, and `lipColor` each have one);
3. each new ID has the exact initializer label, sign, and `0.25` literal shown above;
4. the renderer still imports no internal package and has one shared `processResult` call;
5. aliases/combinations and out-of-scope `白牙`/teeth behavior remain absent.

`0.25` is a provisional Phase 39 evidence input. It must not be described as the final cap until Phase 40 calibration and exact-cap evidence passes.

## Strict MOUTH-10 Helper Architecture

### Ownership and archival durability

Create a Phase 39-owned helper such as:

```text
.planning/phases/39-public-facade-mouth-geometry-output-evidence/
  check_mouth_remaining_renderer_outputs.py
```

It should copy/re-own the hardened algorithms from archived Phase 36 rather than import a sibling phase helper. Archived Phase 33 demonstrates why: its helper resolves a Phase 29 sibling relative to its own directory and is no longer runnable after archival. The Phase 39 helper should use only the Python standard library and paths supplied by `--input`, `--output`, and `--renderer-source`.

### Inventory and matrix gates

The helper should:

1. parse `RenderCase` IDs from the actual renderer source, preserve order, and reject duplicates;
2. require the baseline, all eight new IDs, and every comparator ID used below;
3. recursively discover regular PNG/JPG/JPEG fixtures in renderer-compatible relative-path order;
4. reject duplicate fixture stems before matrix construction;
5. compute `len(caseIDs) × len(fixtures)` from discovered values, then separately enforce the frozen current contract of 44 × 7 = 308 and six portraits plus one exact no-face fixture;
6. construct every expected flat output name, reject missing outputs and unexpected `*.png` outputs, and reject expected paths that are symlinks or non-regular files;
7. require every expected PNG to be non-empty, completely decoded, within bounded file/dimension/decompressed-size budgets, and exactly the dimensions of its corresponding input fixture.

The Phase 36 decoder is the current security baseline: single-descriptor no-follow reads, regular-file and size checks before allocation, identity/size stability through bounded reading, PNG signature/chunk CRC validation, IHDR/IDAT/IEND validation, bounded zlib decode, supported 8-bit RGB/RGBA non-interlaced formats, all five PNG scanline filters, and bounded JPEG dimension parsing. Its negative-path self-tests cover duplicate IDs/stems, missing/extra/corrupt output, oversized dimensions, replacement/growth races, compressed-data expansion, trailing streams, and ROI/watermark rejection. Phase 39 should retain those gates and rename feature-specific routines/messages.

### One deterministic mouth ROI

Every portrait comparison should use one normalized, top-origin mouth rectangle; no fixture-specific crops and no whole-image comparison are acceptable. A sound calibration starting rectangle is:

```text
x = [0.10 × width, 0.90 × width)
y = [0.40 × height, 0.82 × height)
```

This is a research starting point, not a pre-approved accepting rectangle. It is narrower vertically than the archived Phase 33 lower-central crop, includes the proxy lip region and bounded translations, and remains wholly above the current watermark boundary for all six portrait dimensions. The implementation must measure actual regenerated outputs and adjust one global rectangle if necessary.

The helper must duplicate and document the renderer-matched bottom exclusion:

```text
fontSize = max(34, min(72, width / 30))
padding = max(24, width / 70)
excludedBottomRows = ceil(padding × 2 + fontSize × 1.75)
comparableRows = max(0, height - excludedBottomRows)
```

Before any comparison, assert `roiBottom <= comparableRows`. A watermark-only change must never satisfy visibility or independence.

### Exact comparator families

Each pair should report `changed_pixels`, total `roi_pixels`, and `absolute_rgb_delta`. Keep all sixteen families separate so a strong transform cannot mask an invisible or aliased local effect.

| Group | Candidate | Reference | Portrait count |
| --- | --- | --- | ---: |
| visibility | `mouthYPosition_plus0p25` | `geometryBaseline_noop` | 6 |
| visibility | `mouthYPosition_minus0p25` | `geometryBaseline_noop` | 6 |
| visibility | `mouthTilt_plus0p25` | `geometryBaseline_noop` | 6 |
| visibility | `mouthTilt_minus0p25` | `geometryBaseline_noop` | 6 |
| visibility | `mouthXPosition_plus0p25` | `geometryBaseline_noop` | 6 |
| visibility | `mouthXPosition_minus0p25` | `geometryBaseline_noop` | 6 |
| visibility | `lipPeakDefinition_0p25` | `geometryBaseline_noop` | 6 |
| visibility | `lipPlump_0p25` | `geometryBaseline_noop` | 6 |
| signed direction | `mouthYPosition_plus0p25` | `mouthYPosition_minus0p25` | 6 |
| signed direction | `mouthTilt_plus0p25` | `mouthTilt_minus0p25` | 6 |
| signed direction | `mouthXPosition_plus0p25` | `mouthXPosition_minus0p25` | 6 |
| peak independence | `lipPeakDefinition_0p25` | `smile_0p50` | 6 |
| peak independence | `lipPeakDefinition_0p25` | `mouthSize_plus0p35` | 6 |
| plump independence | `lipPlump_0p25` | `mouthSize_plus0p35` | 6 |
| plump independence | `lipPlump_0p25` | `lipColor_0p50` | 6 |
| plump independence | `lipPlump_0p25` | `lipPeakDefinition_0p25` | 6 |

Expected aggregate counts are therefore exactly:

- visibility: 48/48;
- signed direction: 18/18;
- peak independence: 12/12;
- plump independence: 18/18;
- all portrait direct pairs: 96/96.

`lipColor_0p50` is only a nearest non-alias comparator. It remains color-domain behavior and cannot itself prove true plumping.

### Non-circular calibration

Use a two-render protocol:

1. Implement the decoder, ROI, families, and measurement mode with deliberately conservative nonzero starting constants.
2. Guard and clean only the exact physical `example-images/output` root, build/run the renderer, and invoke `--measure` so every family reports its per-fixture values and family minima without accepting them.
3. Select one fixed changed-pixel floor and one fixed absolute-RGB-delta floor below the weakest observed passing family with an explicit safety margin. Record the observed minima, chosen floors, and margins in the evidence document.
4. Commit/freeze those constants.
5. Repeat the guarded clean and full render, then run strict mode. The accepting run must not derive or lower its own thresholds and must not reuse the calibration matrix.

One global pair of floors applied to all sixteen families is simplest and makes the weakest local effect visible in the evidence. If calibration demonstrates that a global floor would be meaningless, any family-specific floors must be committed, justified independently, and still frozen before the accepting rerun; dynamic percentile or observed-minimum calculations in strict mode are prohibited.

## MOUTH-11 No-Face and Artifact Containment

### Saved-output no-face gate

For `negatives/no-face-gradient.png`, require all eight new outputs and baseline to exist, fully decode, remain non-empty, and preserve 64 × 64 extent. Compare each new output with `geometryBaseline_noop` only in a watermark-safe region and require exact zero changed pixels and zero RGB delta.

The renderer's minimum label geometry consumes the full height of the 64 × 64 fixture, so the Phase 36 deterministic fallback is appropriate: compare all 2,048 pixels in the right half, outside the observed left-origin label raster. The fallback must be fixed and asserted non-empty; it is not a general portrait ROI. No-face is excluded from all 96 portrait comparison totals.

Saved pixels prove extent and no-op behavior, not detection diagnostics. Extend `BeautyRendererOutputRegressionTests` with the exact eight isolated public parameter values and assert for each:

- output extent equals input extent;
- detection availability is `.noFace` with reason `.noFaceDetected`;
- face/used-face counts remain zero as currently exposed;
- `beauty.detection.geometryRequired == 1` and used-face metric is zero;
- category warning `face_effects_skipped_no_face` is present;
- existing redaction checks pass and no new field/support/coordinate/landmark/control-point term is disclosed.

This is representative committed-fixture evidence, not Phase 40's exhaustive missing-inner/outer, stale, reused, provider-empty, and transition matrix.

### Gallery and generated-artifact gate

Append the eight IDs to `CASE_GROUPS["mouth"]`, producing fourteen mouth/lip cases and a total 44-case gallery inventory. Preserve the generator's existing duplicate-free exact bijection with discovered renderer IDs. A successful publication must contain exactly 308 regular PNGs at:

```text
example-images/gallery/<group>/<caseID>/<fixtureStem>.png
```

Important operational detail: the hardened generator moves an existing gallery intact into one ignored `.gallery-quarantine/previous` slot and intentionally blocks repeated publication while staging/quarantine remains. Plan one final publication after the strict matrix, then validate that published tree without needlessly invoking the generator again. If a rerun is genuinely required, inspect and remove the ignored quarantine/staging slot through an explicit allow-listed operator step before rerunning; do not weaken the generator or recursively traverse the old gallery.

Containment evidence should require:

- physical output/gallery roots equal their exact repository allow-list;
- output and gallery roots plus representative new paths pass `git check-ignore`;
- exact flat-output and recursive-gallery counts are 308;
- gallery case inventory is a duplicate-free bijection with renderer source;
- `git ls-files example-images/output example-images/gallery` is empty;
- `git diff --cached --name-only -- example-images/output example-images/gallery` is empty;
- no generated PNG is copied into a tracked route;
- helper/evidence documents contain only aggregate counts/minima, not pixels, landmarks, face bounds, fixture contents, or raw geometry.

## Validation Architecture

| Layer | Failure caught | Automated owner | Cadence |
| --- | --- | --- | --- |
| Renderer source contract | missing/extra/combined cases, wrong sign/value, stale Phase 33 prohibition, internal import | `BeautyRendererOutputRegressionTests` | immediately after renderer/test edit |
| Public no-face facade | diagnostic, extent, warning, or redaction drift for eight isolated values | focused renderer regression XCTest | same wave as source contract |
| Build contract | renderer no longer compiles against public facade | `swift build --product BeautyExampleRenderer` | before matrix generation |
| Helper integrity | duplicate IDs/stems, malformed files, races, decode budgets, ROI/watermark drift | helper self-tests and `py_compile` | before live render |
| Matrix integrity | stale counts, missing/extra outputs, corrupt/zero PNG, extent mismatch | strict helper | every full render |
| Visibility | any new signed direction or local effect is baseline-identical/too weak | eight baseline families | measurement and strict render |
| Direction | positive and negative signed paths collapse | three signed-pair families | measurement and strict render |
| Semantic independence | peak aliases size/smile or plump aliases size/color/peak | five direct comparator families | measurement and strict render |
| No-face saved output | geometry modifies no-face pixels or extent | eight helper no-op comparisons | strict render |
| Gallery containment | incomplete/mismatched/tracked generated review tree | gallery bijection/count/ignore/tracked/staged gates | once after strict matrix |
| Regression | unrelated SDK behavior regresses | full `swift test --package-path BeautySDK` | phase-close gate |
| Scope and promotion | caps/safety/product rows/branch change early | name-only and status scans | every wave and final gate |

Phase 39 can be fully automated with SwiftPM/XCTest and standard-library Python. It needs no simulator, Demo build, physical device, browser, new fixture, dependency, package target, or manual artistic approval.

## Suggested Plan Decomposition

### Plan 39-01 — Exact public renderer and no-face source contract

Files:

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift`

Work:

- add exactly eight isolated cases;
- freeze the ordered 44-case inventory and exact fourteen-case mouth group;
- prove one public mouth/lip field per case and facade-only imports;
- add the exact eight-case no-face public-facade/redaction loop.

Gate: focused renderer regression tests, source scans, diff hygiene, no production geometry/cap/product-ledger changes.

### Plan 39-02 — Self-contained helper, calibration, and strict 308-output evidence

Files:

- new `check_mouth_remaining_renderer_outputs.py`
- new `39-MOUTH-OUTPUT-EVIDENCE.md`

Work:

- implement discovered inventory, bounded decoder, matrix/ROI/family/no-face gates and self-tests;
- run guarded measurement regeneration;
- freeze ROI/floors from observed minima with margins;
- run a second guarded strict regeneration and document exact facts/non-claims.

Gate: helper self-tests/compile, renderer build, 308/308 strict decode/extent, 48/18/12/18 portrait groups, 8/8 no-face no-op.

### Plan 39-03 — Gallery, review/security, documentation, and phase closeout

Files:

- `example-images/generate_gallery.py`
- `example-images/README.md`
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`
- Phase 39 validation/review/security/verification artifacts
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md`

Work:

- extend the existing mouth gallery group and publish one exact 308-file ignored gallery;
- update current evidence indexes with observed helper results and provisional/no-promotion wording;
- run focused/full tests, strict helper against the accepted matrix, gallery validation, containment/privacy/scope scans, and final diff hygiene;
- close only MOUTH-09 through MOUTH-11 and hand Phase 40 all cap/safety/promotion/DOC-01 ownership.

Three sequential plans mirror the proven Phase 36 structure and avoid making generated evidence depend on uncommitted source inventory.

## Exact Suggested Commands

Run from `/Users/yakangwang/codes/beauty`; record observed XCTest counts rather than copying Phase 38 totals.

```bash
swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests
python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py --self-test
python3 -m py_compile .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift build --package-path BeautySDK --product BeautyExampleRenderer

OUTPUT_ROOT="$(cd example-images/output && pwd -P)"
EXPECTED_ROOT="$(pwd -P)/example-images/output"
test "$OUTPUT_ROOT" = "$EXPECTED_ROOT"
git check-ignore -q example-images/output
find "$OUTPUT_ROOT" -mindepth 1 -type f -delete

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input --output example-images/output

python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift \
  --measure
```

After freezing thresholds, repeat the guarded cleanup and render, then omit `--measure` for strict acceptance:

```bash
python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift

test "$(find example-images/output -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')" -eq 308

python3 example-images/generate_gallery.py \
  --input example-images/input \
  --output example-images/output \
  --gallery example-images/gallery

test "$(find example-images/gallery -type f -name '*.png' | wc -l | tr -d ' ')" -eq 308
git check-ignore -q \
  example-images/output/e1__mouthYPosition_plus0p25.png \
  example-images/output/e1__lipPeakDefinition_0p25.png \
  example-images/output/e1__lipPlump_0p25.png \
  example-images/gallery/mouth/mouthYPosition_plus0p25/e1.png \
  example-images/gallery/mouth/lipPeakDefinition_0p25/e1.png \
  example-images/gallery/mouth/lipPlump_0p25/e1.png
test -z "$(git ls-files example-images/output example-images/gallery)"
test -z "$(git diff --cached --name-only -- example-images/output example-images/gallery)"

swift test --package-path BeautySDK
git diff --check
```

Useful phase-boundary scans:

```bash
rg -n 'import (BeautyCore|BeautyDetection|BeautyEffects|BeautyRender|BeautyResources)|FaceGeometry|WarpControlPoint|Landmark|Observation|Provider|Resolver' \
  BeautySDK/Sources/BeautyExampleRenderer/main.swift

git diff --name-only <phase-39-base> -- \
  BeautySDK/Sources/BeautyCore \
  BeautySDK/Sources/BeautyDetection \
  BeautySDK/Sources/BeautyEffects \
  BeautySDK/Sources/BeautyRender \
  BeautySDK/Package.swift \
  BeautyDemo \
  docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md \
  docs/meitu-function-blueprint/FEATURE_MATRIX.md \
  docs/meitu-function-blueprint/features/beauty-shaping/mouth/README.md \
  QUALITY_SCORE.md \
  .planning/PROJECT.md
```

The first scan should have no internal-renderer matches. The second should remain empty in Phase 39.

## Risks and Mitigations

| Risk | Consequence | Mitigation |
| --- | --- | --- |
| Stale 252-file matrix survives | false 308 completeness | physical allow-list cleanup before both renders plus unexpected-output rejection |
| Duplicate fixture stems | flat-name overwrite | reject before matrix construction |
| Archived sibling helper import | evidence cannot rerun after milestone archival | self-contained Phase 39 standard-library helper |
| Label/watermark creates differences | invisible geometry passes | fixed ROI wholly above watermark; fixed no-face fallback |
| One-pixel or dynamic threshold | noise or circular evidence | changed-pixel plus RGB-delta floors frozen before fresh accepting render |
| Strong translation masks weak peak/plump | aggregate counter overclaims | sixteen separately gated pair families and per-family minima |
| Peak aliases smile/size | M-lip row borrows shipped behavior | direct peak-vs-smile and peak-vs-size pairs |
| Plump aliases color/size/peak | true plumping is not established | direct plump-vs-size/color/peak pairs; keep lip color explicitly non-geometry |
| No-face output presence is called safety | diagnostics or pixels may still drift | eight saved no-op pairs plus eight public-facade diagnostic/redaction assertions |
| Repeated gallery generation blocks on quarantine | final workflow fails or weakens safe publication | publish once after strict matrix; validate in place; handle quarantine only by explicit allow-listed operator step |
| Output evidence becomes product approval | premature caps/promotion/readiness | provisional `0.25` wording; no product-ledger/branch/cap edits; explicit Phase 40 handoff |

## Explicit Phase Boundary

Phase 39 may close only MOUTH-09, MOUTH-10, and MOUTH-11. It must not:

- declare final natural caps or change public/provider/resolver cap constants;
- implement exhaustive eight-field no-face/missing outer/missing inner/stale/reused/provider-empty/transitions;
- alter combined weakening or fourteen-removal conflict semantics;
- promote `上下`, `倾斜`, `左右`, `M唇`, true `丰唇`, or branch-level `嘴唇`;
- add or imply `白牙`, teeth segmentation, or teeth retouch behavior;
- change Demo UI, package targets, dependencies, network/cloud/commercial paths, packaging, shipping, or launch readiness;
- claim subjective naturalness, device parity, performance certification, commercial approval, milestone audit, archive, tag, or completion.

The correct handoff is: all eight isolated renderer cases are facade-visible, directionally distinct where signed, peak/plump are non-aliased in a fixed mouth ROI, representative no-face outputs are exact safe no-ops outside labels, and the 308 output/gallery artifacts are ignored and untracked. Phase 40 still owns exact caps, exhaustive safety/boundaries, atomic five-row promotion, current-owner synchronization, and DOC-01.
