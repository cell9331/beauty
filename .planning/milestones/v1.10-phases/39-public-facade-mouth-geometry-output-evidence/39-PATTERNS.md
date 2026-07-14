# Phase 39 Pattern Mapping

**Mapped:** 2026-07-14  
**Scope:** MOUTH-09 through MOUTH-11; exact repository analogs and extension patterns

## File-to-Role Map

| Phase 39 file | Current role | Closest analog | Concrete extension |
| --- | --- | --- | --- |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | Ordered public-facade renderer matrix, recursive fixture discovery, flat output naming, watermark drawing | Existing Phase 33 mouth cases and archived Phase 36 two-case extension | Add exactly eight isolated public `BeautyParameters` cases; retain the one shared facade loop and `BeautySDK`-only import. |
| `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` | Exact case inventory, per-case source snippets, facade-only boundary, no-face diagnostics, default-pixel baseline | `testPhase36NOSE07...`, `testPhase36NOSE09...`, stale `testPhase33MouthCases...` | Expand inventory to 44; replace stale mouth prohibition with exact fourteen-case/nine-field assertions; add eight isolated no-face values and redaction checks. |
| new `check_mouth_remaining_renderer_outputs.py` | Phase-owned machine evidence | Archived Phase 36 self-contained helper; archived Phase 33 mouth ROI/pair grouping | Re-own bounded decoder/discovery/matrix/no-face algorithms; switch to fixed mouth ROI and exact sixteen families; do not import a sibling helper. |
| new `39-MOUTH-OUTPUT-EVIDENCE.md` | Command-backed narrative result | `36-NOSE-OUTPUT-EVIDENCE.md`; `33-MOUTH-RENDERER-EVIDENCE.md` | Record guarded measurement/strict renders, 44/7/308, fixed ROI/floors/margins, all family minima/counts, 8 no-face results, containment, and non-claims. |
| `example-images/generate_gallery.py` | Descriptor-anchored ignored gallery, duplicate/bijection gate | Current hardened Phase 36-era generator | Append eight IDs to `CASE_GROUPS["mouth"]`; preserve exact case-set validation and single-slot quarantine behavior. |
| `example-images/README.md` | Live renderer/helper/gallery instructions and artifact boundary | Current Phase 36 section | Add current Phase 39 helper command and observed matrix/family/no-face facts without final-cap or promotion language. |
| `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | Durable public-facade output evidence index | Phase 33 mouth and Phase 36 remaining-nose sections | Add eight cases and Phase 39 output-only facts; keep final promotion routed to Phase 40. |
| Phase 39 `VALIDATION`, `REVIEW`, `SECURITY`, `VERIFICATION` | Nyquist, quality, threat, and final requirement gates | Phase 36 artifacts | Record observed nonzero commands, zero-open-high threats, exact scope, and `passed` only after final evidence. |
| `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` | Active milestone traceability | Phase 38 closeout and Phase 36 closeout | Close only MOUTH-09..11 and route Phase 40; do not complete v1.10. |

## Runtime Data Flow to Preserve

```text
public BeautyParameters for one isolated case
  -> BeautyExampleRenderer shared loop
  -> BeautyEngine.processResult
  -> Phase 38 private detection/support/provider/resolver path
  -> same-extent CIImage
  -> case-label watermark
  -> <fixtureStem>__<caseID>.png
  -> strict Phase 39 decoder/mouth-ROI/no-face gates
  -> descriptor-anchored ignored gallery copy
```

The renderer is not a second facade. It is a command-line client of `BeautySDK`. New cases must remain data in the existing `cases` array; no provider, adapter, observation, raw landmark, control point, or testing SPI belongs in this target.

## Exact Renderer Pattern

The existing isolated case shape is:

```swift
RenderCase(
    id: "mouthSize_plus0p35",
    displayName: "mouthSize +0.35",
    parameters: BeautyParameters(mouthSize: 0.35)
)
```

Use the same shape for exactly:

```text
mouthYPosition_plus0p25
mouthYPosition_minus0p25
mouthTilt_plus0p25
mouthTilt_minus0p25
mouthXPosition_plus0p25
mouthXPosition_minus0p25
lipPeakDefinition_0p25
lipPlump_0p25
```

Canonical signs and literals are `0.25` and `-0.25`; do not use public-normalized `1.0` in renderer output evidence because the Phase 39 context freezes provisional effective evidence at `0.25`. Display names should contain the same public name and signed/unsigned value so saved artifacts are self-identifying.

## Exact Source-Test Pattern

### Inventory

`expectedRendererCaseIDs` is the test-owned ordered copy of the renderer inventory. Preserve all existing 36 IDs and add all eight exactly once. The test should continue to assert one `import BeautySDK`, no internal Beauty target imports, and exactly one shared `engine.processResult(` call.

### One-field-per-case

Follow `rendererCaseSnippet(for:in:)` and the Phase 36 nose assertion pattern. The current mouth/lip label set becomes:

```swift
let mouthFields = [
    "mouthSize:",
    "mouthWidth:",
    "smile:",
    "mouthYPosition:",
    "mouthTilt:",
    "mouthXPosition:",
    "lipPeakDefinition:",
    "lipPlump:",
    "lipColor:"
]
```

Expected renderer cases are fourteen: the six current cases plus the eight new cases. Compare the matching initializer label exactly, then assert the snippet contains no second member of `mouthFields`. Replace the stale broad forbidden array rather than deleting safety coverage. Continue to reject exact alias/combo/teeth case IDs or initializer labels such as `mouthCombo`, `mLip`, `teethWhitening`, and localized/product aliases while avoiding substring checks that could reject valid `lipPeakDefinition`.

### No-face facade

Follow `testPhase36NOSE09IsolatedNoseCasesPreserveNoFaceFacadeContract`, but enumerate the exact renderer values:

```swift
[
    BeautyParameters(mouthYPosition: 0.25),
    BeautyParameters(mouthYPosition: -0.25),
    BeautyParameters(mouthTilt: 0.25),
    BeautyParameters(mouthTilt: -0.25),
    BeautyParameters(mouthXPosition: 0.25),
    BeautyParameters(mouthXPosition: -0.25),
    BeautyParameters(lipPeakDefinition: 0.25),
    BeautyParameters(lipPlump: 0.25)
]
```

Reuse `fixtureImage`, `assertRedacted`, and the existing no-face availability/reason/metric/warning assertions. Add a Phase 39 field-disclosure helper that rejects field names and support/coordinate/landmark/control-point terms in aggregate metadata, without rejecting the source-level parameter construction itself.

## Helper Pattern: What to Reuse and What to Strengthen

### Reuse from archived Phase 36

The Phase 36 helper is the strongest current machine-evidence analog. Reuse its responsibilities, not its feature names:

- `Fixture`, `PNGPayload`, `ComparisonMetrics`, and `Family` immutable records;
- renderer ID and recursive fixture discovery with duplicate rejection;
- frozen inventory asserted after live inventory computation;
- bounded no-follow file acquisition and identity/size stability;
- strict PNG CRC/chunk/zlib/filter decode and bounded JPEG dimensions;
- cached RGB row decoding;
- renderer-matched `comparable_top_region_rows`;
- exact missing/unexpected matrix validation and dimension equality;
- measurement versus strict modes;
- negative self-tests for malformed inventories/files/races/decode/ROI;
- exact no-face baseline equality in a watermark-safe region;
- aggregate-only terminal output.

Retain its practical ceilings unless current outputs exceed them during observed measurement:

```text
PNG/JPEG file: 16 MiB
PNG dimensions: 4096 × 4096
decoded PNG data: 64 MiB
```

If a ceiling changes, document why; never remove bounds to accommodate a malformed file.

### Reuse from archived Phase 33

Phase 33 is the nearest feature analog. Preserve these patterns:

- decoded RGB comparisons rather than file-byte comparison;
- one normalized lower-central mouth region;
- direct positive-versus-negative comparisons;
- distinct counters for geometry and color semantics;
- explicit statement that `lipColor` is not geometry and does not prove true `丰唇`.

Strengthen Phase 33 in Phase 39:

- no sibling-phase import;
- discover live cases/fixtures instead of mutating hard-coded lists;
- require exact missing/unexpected matrix, not only expected-file presence;
- fixed changed-pixel and absolute-RGB-delta floors, not `changed > 0`;
- sixteen separately gated families rather than a few aggregate counters;
- all eight no-face comparisons, not one output presence check;
- complete helper self-tests and bounded acquisition/decode.

## Fixed ROI and Comparator Pattern

Use one function analogous to Phase 36 `nose_roi`, renamed for the mouth. Start calibration at normalized top-origin:

```text
left = 0.10
right = 0.90
top = 0.40
bottom = 0.82
```

The accepting values may differ only after one documented measurement run. Assert integer `right > left`, `bottom > top`, and `bottom <= comparable_top_region_rows(width, height)` for every portrait. No fixture-specific branches are allowed.

Represent every comparison as a `Family(name, candidate, reference, group)` or equivalent. Exact family names should remain stable in evidence, for example:

```text
y_plus_vs_baseline
y_minus_vs_baseline
tilt_plus_vs_baseline
tilt_minus_vs_baseline
x_plus_vs_baseline
x_minus_vs_baseline
peak_vs_baseline
plump_vs_baseline
y_plus_vs_minus
tilt_plus_vs_minus
x_plus_vs_minus
peak_vs_smile
peak_vs_size_plus
plump_vs_size_plus
plump_vs_lip_color
plump_vs_peak
```

Each produces six portrait metrics. Strict mode applies the already-frozen floors to every metric. Terminal/evidence reporting should include per-family count, minimum changed pixels, minimum ROI pixels, and minimum absolute RGB delta, followed by computed group totals of 48, 18, 12, and 18.

## Calibration Pattern

Phase 36 established the correct non-circular sequence:

```text
helper/self-tests
  -> guarded clean
  -> measurement render
  -> observe per-family minima
  -> freeze ROI and two floors in source/evidence
  -> guarded clean again
  -> independent strict render
  -> accept only against frozen constants
```

Never let strict mode calculate thresholds from the matrix it is accepting. Do not retain calibration output as a committed baseline. The evidence record should state the weakest observed family/fixture, its minima, the fixed floors, and the absolute/percentage safety margin.

## No-Face Pattern

Use Phase 36's watermark-safe comparison logic:

- normal images compare full rows above the computed watermark exclusion;
- the 64 × 64 fixture has zero full comparable rows because the minimum label band occupies the tiny canvas;
- its fixed fallback is the right half, 2,048 pixels, outside the observed left-origin label raster;
- require all eight new cases to have zero changed pixels and zero RGB delta versus baseline in that region;
- enforce exact `negatives/no-face-gradient.png` role and exclude it from portrait counts.

Pair this with the focused public-facade XCTest. Pixels and diagnostics are complementary evidence; neither should be used to overclaim Phase 40's exhaustive transitions.

## Gallery Pattern and Rerun Hazard

The current generator already performs the necessary source-of-truth split:

```text
flattened CASE_GROUPS IDs ─┐
                          ├─ exact duplicate-free set equality
renderer source IDs ──────┘
```

Adding the eight IDs under `mouth` gives fourteen mouth/lip cases and 44 total. The generator then copies `44 × 7 = 308` source paths into a fresh staging tree and atomically publishes it.

Do not redesign its path safety. It owns no-follow descriptors, exact allowed routes, bounded secure copies, snapshot revalidation, staging publication, and intact quarantine of the previous gallery. Because `.gallery-quarantine` is intentionally one-slot and blocks another run, publish once after the strict output matrix and use read-only exact-count/bijection/ignore/tracking validation for final verification. A repeated publish requires explicit handling of ignored staging/quarantine, not weaker generator checks.

## Documentation and Ledger Pattern

### Phase 39 may update

- output helper and Phase 39 evidence/review/security/validation/verification;
- live example-image README and validation index with observed facts;
- MOUTH-09..11 checkboxes and Phase 39 roadmap/state/PLANS status after all gates pass.

### Phase 39 must leave unchanged

- `BeautySafetyCaps` and all public/provider/resolver/effect production code;
- `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, mouth/shape branch status READMEs;
- `QUALITY_SCORE.md` and `.planning/PROJECT.md` final promotion owners;
- `Package.swift`, Demo sources/Xcode project, dependencies, network/cloud/commercial paths;
- MOUTH-12..16 and DOC-01 status.

The wording pattern is “observed public-facade output evidence at provisional 0.25.” Avoid “final cap,” “implemented row,” “branch complete,” “natural,” “production-ready,” or “release-ready.”

## Verification Command Pattern

Fast feedback:

```bash
swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests
python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py --self-test
python3 -m py_compile .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py
git diff --check
```

Live evidence:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift build --package-path BeautySDK --product BeautyExampleRenderer
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input --output example-images/output
python3 .planning/phases/39-public-facade-mouth-geometry-output-evidence/check_mouth_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift
```

Containment and closeout:

```bash
python3 example-images/generate_gallery.py \
  --input example-images/input \
  --output example-images/output \
  --gallery example-images/gallery
test "$(find example-images/output -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')" -eq 308
test "$(find example-images/gallery -type f -name '*.png' | wc -l | tr -d ' ')" -eq 308
test -z "$(git ls-files example-images/output example-images/gallery)"
test -z "$(git diff --cached --name-only -- example-images/output example-images/gallery)"
swift test --package-path BeautySDK
git diff --check
```

Every plan should record actual counts. A helper that prints literal success totals without deriving them, an uncleared output directory, a gallery with a non-bijective case set, or a tracked generated PNG is a blocking failure.

## Planning Shape Recommended by the Patterns

The repository's proven ordering is sequential:

1. renderer source and exact XCTest contract;
2. self-contained helper, measurement, threshold freeze, fresh strict render, evidence;
3. one safe gallery publication, docs, review/security/Nyquist, focused/full/final gates, and planning closeout.

This keeps source inventory stable before generated evidence, prevents thresholds from being selected by the accepting run, and preserves Phase 40's independent safety/promotion gate.
