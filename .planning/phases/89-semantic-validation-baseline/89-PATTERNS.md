# Phase 89: Semantic Validation Baseline - Pattern Map

**Mapped:** 2026-08-26
**Files analyzed:** 6 likely new/modified files
**Analogs found:** 6 / 6

Phase 89 should extend the existing user-owned batch harness in place. It should
not create a second renderer inventory, second portrait runner, or tracked
evidence store. No `89-RESEARCH.md` exists; assignments below are grounded in
the current CONTEXT/ROADMAP/REQUIREMENTS, live code, and uncommitted batch work.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `scripts/face-feature-batch-manifest.json` | config | batch | same file's v1 65-case inventory | exact/current |
| `scripts/compare-face-feature-batches.swift` | utility | file-I/O + transform + batch | same file's mechanical comparator; archived `check_face_geometry_renderer_outputs.py` for fixed ROI gates | exact/current + role-match |
| `scripts/run-face-feature-batches.sh` | utility/orchestrator | batch + file-I/O | same file's renderer orchestration; `scripts/run-no-skip-swiftpm.sh` for fail-closed accounting | exact/current |
| `example-images/README.md` | documentation | request-response | same file's Face-feature batch validation section | exact/current |
| `QUALITY_SCORE.md` | documentation/config | transform | current scorecard's generated pixel-oracle evidence | exact |
| `PLANS.md` | documentation/ledger | event-driven | existing completed batch-validation ledger | exact |

The existing `.gitignore` addition for `example-images/local-test-records/` is
already the correct boundary. Treat it as preserved input, not a file that needs
further Phase-89 edits unless the final output location changes.

## Pattern Assignments

### `scripts/face-feature-batch-manifest.json` (config, batch)

**Analog:** the current user-owned manifest.

**Inventory pattern** (`scripts/face-feature-batch-manifest.json` lines 1-23):

```json
{
  "schemaVersion": "beauty.face-feature-batch-manifest.v1",
  "control": {
    "id": "geometryBaseline_noop",
    "label": "neutral geometry control"
  },
  "batches": [
    {
      "id": "face-shape",
      "label": "脸型",
      "cases": [
        "faceShapeCombo_0p35",
        "faceSlim_0p35",
        "faceSmall_0p35",
        "chinLength_plus0p30",
        "chinLength_minus0p30",
        "faceVShape_0p35",
        "jawSlim_0p35",
        "faceContourSmooth_0p25"
```

Keep the five batches and all 65 live cases. Extend this schema with a frozen
semantic contract only for the eight in-scope directions: case id, comparison
siblings, normalized ROI/protected ROIs, polarity/locality metric, and fixed
minimum signal. The six affected controls are visible at lines 19/22, 39,
62-63, 77-78, and 89. Do not place fixture paths, landmarks, masks, pixels, or
per-portrait geometry in the manifest.

**Validation pattern** (`scripts/run-face-feature-batches.sh` lines 74-89):

```python
with open(sys.argv[1], encoding="utf-8") as handle:
    manifest = json.load(handle)
with open(sys.argv[2], encoding="utf-8") as handle:
    live = set(json.load(handle)["cases"])
control = manifest["control"]["id"]
listed = [case for batch in manifest["batches"] for case in batch["cases"]]
if control in listed or len(listed) != len(set(listed)):
    raise SystemExit("manifest has duplicate cases or includes the control case")
missing = [case for case in [control, *listed] if case not in live]
if missing:
    raise SystemExit("manifest cases absent from live renderer: " + ",".join(missing))
```

Expand this fail-closed preflight to require exactly the eight directions and
reject missing/duplicate/unknown metric types, invalid normalized rectangles,
non-finite or negative thresholds, empty protection sets, and thresholds that
are not frozen in the manifest.

---

### `scripts/compare-face-feature-batches.swift` (utility, file-I/O + transform)

**Analog:** the current comparator is the implementation base; do not replace
its canonical decode, opaque fixture IDs, atomic JSON write, or source/neutral
comparison.

**Canonical sRGB decode pattern** (lines 113-149):

```swift
guard let image = CIImage(contentsOf: url, options: [.applyOrientationProperty: true]) else {
    throw CompareError.imageDecodeFailed(url.path)
}
let extent = image.extent.integral
let width = Int(extent.width.rounded(.toNearestOrAwayFromZero))
let height = Int(extent.height.rounded(.toNearestOrAwayFromZero))
guard width > 0, height > 0,
      let cgImage = context.createCGImage(image, from: extent) else {
    throw CompareError.imageDecodeFailed(url.path)
}
var rgba = Array(repeating: UInt8(0), count: width * height * 4)
let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
```

Keep EXIF application and one explicit sRGB rasterization. Semantic ROI helpers
should operate on this canonical pixel buffer and normalized rectangles, not
decode or orient images again.

**Watermark exclusion and aggregate metric pattern** (lines 151-189, 260-271):

```swift
let startRow = min(excludedRowsPerEdge, lhs.height)
let endRow = max(startRow, lhs.height - excludedRowsPerEdge)
for y in startRow..<endRow {
    for x in 0..<lhs.width {
        let index = (y * lhs.width + x) * 4
        // RGB deltas only; alpha is not counted as effect signal.
    }
}

let watermarkFontSize = max(34.0, min(72.0, Double(width) / 30.0))
let watermarkPadding = max(24.0, Double(width) / 70.0)
let watermarkRows = Int(ceil(watermarkPadding + watermarkFontSize * 1.75 + 6.0))
```

Generalize the pixel iterator to intersect the semantic ROI with comparable
rows and explicitly subtract watermark rows. Apply the same exclusion to
target, sibling, and protected-region measurements. Fail if a configured ROI
has no comparable pixels.

**Current anti-pattern to replace** (lines 329-342):

```swift
let effectDetected = neutralMetric.changedPixels >= minimumChangedPixels &&
    neutralMetric.meanAbsoluteRGBDelta >= minimumMeanDelta
// ... "changed_vs_neutral" / "no_detectable_change"
```

This whole-frame arbitrary-difference gate is baseline evidence only. Phase 89
must compute each configured direction's polarity/locality metric inside its
semantic ROI, compare against both source and neutral, require minimum signal,
and independently bound every protected ROI. A changed pixel count alone cannot
produce an `effective` verdict.

**Privacy-safe deterministic report pattern** (lines 375-405):

```swift
let report = ComparisonReport(
    schemaVersion: "beauty.face-feature-batch-report.v1",
    generatedAtUTC: ISO8601DateFormatter().string(from: Date()),
    fixtureIDs: fixtures.indices.map { String(format: "portrait_%03d", $0 + 1) },
    // aggregate summaries only
)
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
try FileManager.default.createDirectory(
    at: reportURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try encoder.encode(report).write(to: reportURL, options: .atomic)
```

Preserve opaque IDs and aggregate-only rows. For deterministic reruns, separate
volatile run metadata from the semantic payload (or exclude it from equality),
sort all case/metric arrays, and report a stable contract/schema version. Do not
emit paths, raw pixels, masks, landmarks, pupil positions, or per-fixture
geometry. A semantic failure should write the reconciled report and exit
nonzero; malformed input/report state should remain a typed fail-closed error.

---

### `scripts/run-face-feature-batches.sh` (utility/orchestrator, batch + file-I/O)

**Analog:** current batch runner.

**Safe path and unique-run pattern** (lines 4-8, 54-71):

```bash
readonly repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly manifest="${repo_root}/scripts/face-feature-batch-manifest.json"
input_dir="${repo_root}/example-images/input"
output_root="${repo_root}/example-images/output/face-feature-batches"
report_path="${repo_root}/example-images/local-test-records/face-feature-batch-report.json"

[[ -d "$input_dir" ]] || { echo "input directory missing: $input_dir" >&2; exit 2; }
[[ -f "$manifest" ]] || { echo "manifest missing: $manifest" >&2; exit 2; }
run_id="$(date -u +%Y%m%dT%H%M%SZ)"
run_root="${output_root}/${run_id}"
[[ ! -e "$run_root" ]] || { echo "refusing to reuse existing run directory" >&2; exit 2; }
```

Retain ignored owner-local output/report defaults and refusal to reuse output.
If determinism requires two renders, create two distinct request-local run
roots, compare semantic payloads, and never persist a child transcript.

**One renderer, explicit case, CPU reference pattern** (lines 91-111):

```bash
render_case() {
  local batch_id="$1"
  local case_id="$2"
  mkdir -p "${run_root}/${batch_id}/${case_id}"
  if ! "$renderer" \
      --input "$input_dir" \
      --output "${run_root}/${batch_id}/${case_id}" \
      --case "$case_id" \
      --backend cpu \
      >"${run_root}/${batch_id}/${case_id}/render.log" 2>&1; then
    render_failures=$((render_failures + 1))
  fi
}
```

Continue using the compiled public `BeautyExampleRenderer` and live inventory.
Do not introduce a private render path or alter the 75-case renderer contract.

**Fail-closed accounting analog** (`scripts/run-no-skip-swiftpm.sh` lines
100-114):

```bash
parity_record="$(mktemp "${TMPDIR:-/tmp}/beauty-backend-parity-record.XXXXXX")"
if ! bash "${repository_root}/scripts/check-backend-parity.sh" >"${parity_record}" 2>/dev/null; then
  rm -f -- "${parity_record}"
  echo "no_skip_backend_parity_failed"
  exit 1
fi
if ! parity_result="$(bash "${repository_root}/scripts/check-backend-parity.sh" --validate-record "${parity_record}" 2>/dev/null)"; then
  rm -f -- "${parity_record}"
  exit 1
fi
```

Adopt the same producer-then-independent-reconciliation shape: require 65/65
outputs, exact five-batch counts, exactly eight semantic verdicts, zero missing
outputs, neutral identity, source/neutral comparisons, and identical repeated
semantic results before returning success.

---

### `example-images/README.md` (documentation, request-response)

**Analog:** lines 74-91 already own the command and privacy boundary.

```markdown
bash scripts/run-face-feature-batches.sh
```

Update this section rather than creating another how-to. Document the stable
semantic report schema, the eight direction gates, the repeated-run
determinism rule, nonzero failure behavior, and the ignored output/report
locations. Preserve the explicit nonclaims: automated owner-local evidence is
not naturalness, device, commercial quality, packaging, shipping, launch, or
release-readiness evidence.

---

### `QUALITY_SCORE.md` (documentation/config, transform)

**Analog:** lines 51-57 distinguish generated mechanics from genuine efficacy.

```markdown
New pixel oracles cover strict brow/eye exclusion, typed missing/crossed support,
... target change, exact protected/exterior/alpha/extent/metadata behavior,
peer isolation, collision-to-source, and determinism. These generated tests
qualify mechanics only.
```

Record Phase 89 only after the repeatable gate is verified. State exact counts,
the eight semantic directions, source+neutral comparison, watermark exclusion,
protection/locality checks, and deterministic reconciliation. Do not upgrade
the repaired controls themselves: Phase 89 establishes acceptance machinery;
Phases 90-94 establish repaired behavior.

---

### `PLANS.md` (documentation/ledger, event-driven)

**Analog:** lines 512-532 are the direct predecessor ledger.

```markdown
| Interpretation | `changed_vs_neutral` is mechanical pixel-change evidence,
not semantic correctness, naturalness, device parity, commercial quality, or
release readiness. |

Known follow-up: cases with `no_detectable_change` require semantic/ROI-specific
review ... this batch is an automated mechanical screen, not a product-quality gate.
```

Add/update a Phase-89 active/completed record that explicitly closes this known
follow-up at the validation-contract level. Record commands and reconciled
counts only after execution. Never paste raw report rows containing private
fixture information, child transcripts, paths, masks, landmarks, or pixels.

## Shared Patterns

### Generated Region and Protection Oracles

**Source:** `BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureFactory.swift`
lines 8-34 and 88-116.

```swift
/// The factory deliberately returns byte arrays and support values rather than
/// writing an image fixture. This keeps the evidence reproducible in a clean
/// clone and keeps raw pixels request-local to one test invocation.
struct CPUReferenceRGBA8Fixture: Equatable {
    enum Region: Hashable { case protected, outside, safe }
    let regions: [Region: Set<Int>]
    func indices(in region: Region) -> Set<Int> { regions[region, default: []] }
}
```

Use code-generated, deterministic buffers for comparator/contract self-tests.
Authorized portraits validate the live command but must not become committed
fixtures. Keep semantic target, protected, and outside regions independently
addressable.

### Locality and Protected-Region Assertions

**Source:** `BeautySDK/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift`
lines 33-40.

```swift
let output = try BeautyBackendParityFixtureFactory.rgbaBytes(from: result.output)
let changed = try CPUReferenceMetrics.changedIndices(before: fixture.rgba8, after: output)
XCTAssertTrue(changed.isSubset(of: envelope))
XCTAssertTrue(changed.isDisjoint(with: fixture.indices(in: .outside)))
XCTAssertTrue(changed.isDisjoint(with: fixture.indices(in: .protected)))
XCTAssertEqual(CPUReferenceMetrics.alphaValues(in: output), fixture.alphaValues)
```

The batch report should mirror these concepts as aggregate counts/ratios:
target signal must meet its floor while each protected region remains within
its own ceiling. Do not collapse both into one whole-image difference score.

### Privacy Boundary

Apply the project and `spike-findings-beauty` rules to every file above:

- detect/render owner-local inputs only;
- keep output images, logs, and reports ignored;
- keep raw pixels, masks, landmarks, pupil positions, fixture locators, and
  child transcripts out of durable evidence;
- use opaque IDs and aggregate metrics only;
- fail closed when semantic support or a configured ROI is missing/malformed;
- do not treat local-retouch controls as Phase-89 repair targets.

## No Analog Found

None. The current user-owned harness is the exact implementation base, and the
repository already contains strong generated-fixture, locality, deterministic
reporting, and fail-closed accounting patterns. Planner should prefer compatible
in-place edits over new parallel infrastructure.

## Metadata

**Analog search scope:** `scripts/`, `BeautySDK/Sources/BeautyExampleRenderer/`,
`BeautySDK/Tests/`, current root owners, and archived renderer/qualification
pattern maps under `.planning/milestones/`.

**Files scanned:** current six likely owners plus renderer CLI/execution,
generated fixture/safety tests, no-skip orchestration, and archived renderer
evidence maps.

**Pattern extraction date:** 2026-08-26
