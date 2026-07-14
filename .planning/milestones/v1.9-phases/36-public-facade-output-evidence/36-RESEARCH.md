# Phase 36: Public-Facade Output Evidence — Research

**Researched:** 2026-07-13  
**Status:** Ready for planning  
**Scope:** NOSE-07, NOSE-08, NOSE-09 only

## Executive Summary

Phase 36 should be a renderer-and-evidence phase, not another geometry or safety phase. Phase 35 already proves that `noseRootNarrowing` and `noseTipLift` are independent public values, route through `BeautyEngine.processResult`, use explicit package-only supports, emit non-aliased provider vectors, fail closed, and preserve redacted facade diagnostics. Phase 36 needs to make those two paths observable in saved public-facade output and prove that the resulting artifacts are complete, local, ignored, and distinct from their nearest legacy nose effects.

The smallest sound implementation surface is:

- two isolated `BeautyExampleRenderer` cases at the current provisional `0.25` values;
- exact renderer-source regression coverage for a 36-case public-facade matrix and one nose field per case;
- one self-contained v1.9 helper that discovers the renderer case list and fixture files, decodes the entire case-by-fixture matrix, and performs nose-local comparisons above the watermark;
- the existing gallery generator extended with the two case IDs;
- command-backed Phase 36 evidence and only the Phase 36 planning/requirements status updates.

The expected current result is 36 cases × 7 fixtures = 252 output PNGs, 12 new-case-vs-baseline portrait comparisons, 6 root-vs-bridge comparisons, and 12 lift-vs-signed-tip comparisons. These counts must be computed from observed cases and fixtures and then checked against the frozen Phase 36 expectation; they must not be printed unconditionally.

## Current Repository Baseline

### Renderer and fixtures

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` currently contains 34 `RenderCase` entries.
- It imports `BeautySDK` as its only Beauty package and invokes `BeautyEngine.processResult(image:metadata:parameters:)` for every case.
- Existing comparison anchors are already present:
  - `geometryBaseline_noop`
  - `noseBridge_0p30`
  - `noseTipSize_plus0p30`
  - `noseTipSize_minus0p30`
- `example-images/input/` currently contains seven supported images: six portrait fixtures and `negatives/no-face-gradient.png`.
- `example-images/output/` and `example-images/gallery/` currently each contain 238 files from the 34 × 7 mouth-era matrix. Both routes are ignored by `.gitignore`.

### Existing automated ownership

- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` owns the exact renderer case order and the public-facade-only import boundary.
- Its Phase 31 nose test currently recognizes only `noseSlim`, `noseWingSlim`, `noseTipSize`, and `noseBridge`, and deliberately rejects strings such as `noseRoot`. Phase 36 must replace that stale prohibition with exact acceptance for `noseRootNarrowing` and `noseTipLift` while continuing to reject aliases and extra nose cases.
- The current gallery generator has one `nose` group containing the five Phase 31 cases. Adding the two Phase 36 IDs to that existing group should produce all 252 review copies without adding UI.

### Reusable historical patterns and an archival hazard

- Phase 31 established public-facade nose cases, full PNG decoding, dimension preservation, portrait comparisons, signed-tip comparison, no-face presence, gallery routing, and no-promotion wording.
- Phase 33 improved the comparison pattern by decoding RGB and counting differences inside a documented normalized ROI above the watermark.
- Both archived Phase 31 and Phase 33 helpers import a sibling Phase 29 helper by a relative path. After milestone archival that sibling path no longer exists, so those archived helpers are not currently runnable from their archived locations. Phase 36 should reuse their algorithms, not their fragile path topology.
- A self-contained standard-library PNG/JPEG dimension and PNG RGB decoder in the v1.9 helper is the most durable option. If code reuse is preferred, resolve the live Phase 29 helper from repository root and add an explicit import-availability failure, but this remains less archive-safe.

## Requirement Interpretation

### NOSE-07 — exact isolated public cases

Add exactly these cases, with no combined case:

| Case ID | Display label | Public construction |
| --- | --- | --- |
| `noseRootNarrowing_0p25` | `noseRootNarrowing 0.25` | `BeautyParameters(noseRootNarrowing: 0.25)` |
| `noseTipLift_0p25` | `noseTipLift 0.25` | `BeautyParameters(noseTipLift: 0.25)` |

The case test should prove all of the following together:

- the renderer has exactly 36 ordered case IDs;
- each of the seven nose cases contains exactly one of the six public nose fields (`noseTipSize` has two signed cases);
- the two new cases contain their exact public initializer labels and `0.25` values;
- the renderer still imports only `BeautySDK` and does not mention package-internal geometry, adapters, resolvers, providers, observations, landmarks, or control points;
- no alias/combo case such as `noseCombo`, `noseRoot`, `noseLift`, `shanGen`, or `tiSheng` is added, while matching must avoid falsely rejecting the valid prefix in `noseRootNarrowing`.

The provisional `0.25` strength is evidence input, not final cap approval. Phase 37 remains free to calibrate the exact cap.

### NOSE-08 — decoded visibility and independence

The helper should discover rather than duplicate the runtime matrix:

1. Parse ordered `id: "..."` entries from the actual renderer source, reject duplicate IDs, and require the frozen Phase 36 inventory of 36 including each new ID exactly once.
2. Recursively discover regular `.png`, `.jpg`, and `.jpeg` fixtures under the supplied input directory using the same sort semantics as the renderer.
3. Reject duplicate fixture stems because the renderer flattens outputs to `<stem>__<case>.png`; otherwise two source paths could overwrite one another.
4. Compute `expected_output_count = len(case_ids) * len(fixtures)` and report observed case, fixture, and output counts. Separately fail with an explicit inventory message unless the current Phase 36 expectation is 36 × 7 = 252.
5. Require every expected output to exist, be nonzero, fully decode as a supported PNG, and match its corresponding input dimensions.

Comparisons must operate on decoded RGB pixels, not file bytes. Use one documented normalized central nose rectangle expressed from output dimensions, with its bottom clamped strictly above `comparable_top_region_rows(width, height)`. A reasonable initial calibration window for the centered committed fixtures is x = 25%–75% and y = 20%–70% from the decoded top edge. The implementation run should record actual per-comparison minima and lock the final rectangle in both helper constants and the evidence document. If any portrait falls outside that common deterministic rectangle, adjust the one global rectangle from observed output; do not add fixture-specific crops.

Required comparison families are independent gates:

| Family | Pairing | Current expected count |
| --- | --- | --- |
| Root visibility | `noseRootNarrowing_0p25` vs `geometryBaseline_noop` | 6 |
| Lift visibility | `noseTipLift_0p25` vs `geometryBaseline_noop` | 6 |
| Root independence | `noseRootNarrowing_0p25` vs `noseBridge_0p30` | 6 |
| Lift positive-tip independence | `noseTipLift_0p25` vs `noseTipSize_plus0p30` | 6 |
| Lift negative-tip independence | `noseTipLift_0p25` vs `noseTipSize_minus0p30` | 6 |

Report all five families separately. Do not collapse root and lift into a single 30-comparison success counter.

For each pair, record at least changed-pixel count, ROI pixel count, and total absolute RGB delta. A one-pixel inequality is too weak to support visibility. Thresholds should be fixed constants selected after the first current-output measurement and documented with the observed minimum and safety margin. A practical starting floor is at least 16 changed pixels and total absolute RGB delta of at least 64, but these are research starting values rather than evidence-backed final constants. Do not calculate the acceptance threshold dynamically from the same outputs being accepted.

### NOSE-09 — no-face and containment

For `negatives/no-face-gradient.png`, both new outputs must exist, decode, be non-empty, and match the 64 × 64 input extent. Stronger fail-closed evidence is available by requiring each new output to be RGB-identical to `geometryBaseline_noop` above the excluded watermark band; label differences are then confined to the watermark and cannot masquerade as geometry.

Output files alone cannot prove the no-face diagnostic state. If NOSE-09 is to include machine-verifiable degradation rather than extent-only inference, extend the existing renderer regression suite with a public-facade loop for the two new isolated parameters and assert:

- output extent equals input extent;
- detection availability is `.noFace` with `.noFaceDetected`;
- used-face count is zero and geometry-required remains aggregate-only;
- the existing category warning is present;
- metadata passes the existing redaction assertion.

This remains Phase 36 no-face facade evidence; it must not expand into Phase 37's exhaustive six-field missing/stale/reused/provider-empty matrix.

Gallery and containment gates should require:

- both new case IDs in `example-images/generate_gallery.py` under `nose`;
- 252 expected gallery PNGs after a clean generation from the exact output matrix;
- representative `git check-ignore` success for new output and gallery paths;
- empty `git ls-files example-images/output example-images/gallery` output;
- no staged or tracked generated PNG anywhere under those routes.

## Suggested Files and Ownership

### Runtime/test files

- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` — add only the two isolated cases.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` — exact 36-case inventory, one-field nose assertions, internal-import prohibition, and optionally the representative two-case no-face public-facade loop.

### Phase-owned evidence files

- `.planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py` — v1.9-owned discovery, decode, dimension, ROI, no-face, and count gate.
- `.planning/phases/36-public-facade-output-evidence/36-NOSE-OUTPUT-EVIDENCE.md` — observed commands, exact inventories, rectangle, thresholds, per-family minima/counts, dimensions, no-face result, gallery count, and non-claims.
- `.planning/phases/36-public-facade-output-evidence/36-VALIDATION.md` — Nyquist map finalized only after execution.
- `.planning/phases/36-public-facade-output-evidence/36-VERIFICATION.md` and review evidence — final requirement verdict and scope review.

### Gallery/local validation owners

- `example-images/generate_gallery.py` — add both IDs to `nose`.
- `example-images/README.md` — add the current helper command and factual 36 × 7 evidence after it passes.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` — add the two cases and Phase 36 output-only evidence without promotion.

### Closeout ledgers

- `.planning/REQUIREMENTS.md` — close only NOSE-07 through NOSE-09 after final evidence.
- `.planning/ROADMAP.md`, `.planning/STATE.md`, and `PLANS.md` — record Phase 36 completion and hand off Phase 37.

No architecture, parameter, safety-cap, provider, resolver, package, Demo, product-status, feature-ledger, `QUALITY_SCORE.md`, or branch README change is needed for this phase.

## Exact Suggested Commands

Run from `/Users/yakangwang/codes/beauty`. Record actual XCTest counts rather than copying historical counts.

```bash
swift test --package-path BeautySDK --filter BeautyRendererOutputRegressionTests

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift build --package-path BeautySDK --product BeautyExampleRenderer

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
swift run --package-path BeautySDK BeautyExampleRenderer \
  --input example-images/input \
  --output example-images/output

python3 .planning/phases/36-public-facade-output-evidence/check_nose_remaining_renderer_outputs.py \
  --input example-images/input \
  --output example-images/output \
  --renderer-source BeautySDK/Sources/BeautyExampleRenderer/main.swift

python3 example-images/generate_gallery.py \
  --input example-images/input \
  --output example-images/output \
  --gallery example-images/gallery

find example-images/output -type f -name '*.png' | wc -l
find example-images/gallery -type f -name '*.png' | wc -l

git check-ignore \
  example-images/output/e1__noseRootNarrowing_0p25.png \
  example-images/output/e1__noseTipLift_0p25.png \
  example-images/gallery/nose/noseRootNarrowing_0p25/e1.png \
  example-images/gallery/nose/noseTipLift_0p25/e1.png

test -z "$(git ls-files example-images/output example-images/gallery)"
git diff --check
swift test --package-path BeautySDK
```

Before claiming an exact 252-file matrix, regenerate into a clean ignored output directory so stale files cannot inflate the count. `example-images/README.md` defines output and gallery contents as disposable generated artifacts, but the execution record should state that cleanup occurred. The helper should also reject unexpected renderer-shaped PNGs in the output directory, not merely verify that expected files exist.

Useful scope scans:

```bash
rg -n 'import (BeautyCore|BeautyDetection|BeautyEffects|BeautyRender|BeautyResources)|FaceGeometry|WarpControlPoint|Landmark|Observation|Provider|Resolver' \
  BeautySDK/Sources/BeautyExampleRenderer/main.swift

git diff --name-only -- \
  BeautySDK/Sources/BeautyCore \
  BeautySDK/Sources/BeautyDetection \
  BeautySDK/Sources/BeautyEffects \
  BeautySDK/Sources/BeautyRender \
  BeautySDK/Package.swift \
  BeautyDemo \
  docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md \
  docs/meitu-function-blueprint/FEATURE_MATRIX.md \
  docs/meitu-function-blueprint/features/beauty-shaping/nose/README.md \
  QUALITY_SCORE.md \
  .planning/PROJECT.md
```

The first scan should return no matches after accounting for benign display text; the second must remain empty for Phase 36.

## Validation Architecture

Phase 36 can be fully automated with SwiftPM/XCTest plus the standard-library Python output helper. No new dependency, fixture, test target, browser, simulator, physical device, or manual visual approval is required.

### Nyquist layers

| Layer | Failure caught | Automated owner | Required cadence |
| --- | --- | --- | --- |
| Renderer source contract | missing/extra/combined cases, wrong strength, internal import, aliasing | `BeautyRendererOutputRegressionTests` | immediately after renderer/test edit |
| Build contract | renderer no longer compiles against public facade | `swift build --product BeautyExampleRenderer` | same wave as source contract |
| Matrix integrity | stale case/fixture counts, missing/extra files, corrupt PNG, zero bytes, extent drift, stem collision | Phase 36 Python helper | after every all-case render |
| Output visibility | new field aliases baseline or changes only watermark | decoded RGB nose ROI comparisons | after every all-case render |
| Output independence | root aliases bridge or lift aliases either signed tip path | three separately reported direct-pair families | after every all-case render |
| No-face degradation | unsafe geometry on no-face or extent/diagnostic drift | helper above-watermark equality plus focused facade XCTest | after renderer evidence changes |
| Artifact containment | output/gallery becomes tracked, staged, incomplete, or escapes ignore routes | gallery generation, `git check-ignore`, `git ls-files`, exact counts | before phase verification |
| Regression | collateral SDK behavior changes | full `swift test --package-path BeautySDK` | final phase gate |
| Scope/no-promotion | Phase 37 files or claims change early | name-only diff and status-text scans | every wave and final gate |

### Feedback timing

- Focused renderer regression tests and `git diff --check` should run after the source/test edit.
- Renderer build should run before spending time on the full output matrix.
- The all-case render, helper, and gallery are one inseparable evidence gate; a renderer run without the helper is not accepted evidence.
- Full SwiftPM, containment scans, no-promotion scans, and final helper rerun are the phase-close gate.
- `nyquist_compliant: true` must be set only after the final generated matrix and post-documentation rerun pass.

### Validation assertions that must not be weakened

- Case and fixture counts are discovered, then checked against 36 and 7; `252` is never an unconditional success string.
- Every comparison is above the watermark and inside the same normalized ROI.
- Root and lift results are reported separately, including lift-vs-positive-tip and lift-vs-negative-tip.
- Thresholds are fixed before the accepting rerun and supported by recorded observed minima.
- No-face outputs are excluded from portrait visibility totals.
- Generated PNGs are never used as committed test baselines.
- A clean output directory or unexpected-output rejection is required before exact inventory claims.

## Risks and Mitigations

| Risk | Consequence | Mitigation |
| --- | --- | --- |
| Historical helper imports break after archival | Phase evidence cannot be rerun | make the Phase 36 helper self-contained or resolve repository-root canonical code explicitly |
| Hard-coded `252` masks case/fixture drift | incomplete evidence prints success | discover both inventories, compute total, then fail explicitly on frozen-count mismatch |
| Duplicate fixture stems overwrite flat outputs | fewer unique files than source fixtures | reject duplicate stems before matrix validation |
| Watermark labels create false differences | invisible/aliased effect appears valid | decode pixels and compare only within ROI wholly above the watermark band |
| Whole-image or broad top-region diff hides aliasing | another changed region satisfies test | use one deterministic central nose ROI and direct legacy pair comparisons |
| A zero-or-one-pixel threshold is too weak | numerical noise is called visible | lock changed-pixel and total-delta floors from observed minima with margin |
| Dynamic threshold derived from accepted run is circular | any weak output can lower its own bar | hard-code thresholds after calibration, then rerun from clean outputs |
| Stale PNGs remain in output | exact 252 claim is inflated | clean generated routes before render and reject unexpected PNGs |
| No-face presence alone is overclaimed as safety | unsafe diagnostics or geometry could be missed | assert above-watermark no-op plus focused public-facade no-face summary/redaction |
| Phase 31 test's `noseRoot` prohibition is removed too broadly | aliases or extra cases can enter | replace it with exact allowed-case/field assertions and precise forbidden tokens |
| Renderer evidence is mistaken for naturalness | premature cap or commercial claim | label `0.25` provisional and keep all quality/readiness claims deferred |

## No-Promotion Boundary

Phase 36 may close only NOSE-07, NOSE-08, and NOSE-09. It must not:

- change or declare final `noseRootNarrowing` or `noseTipLift` safety caps;
- add exhaustive six-nose-field missing/stale/reused/provider-empty or exactly-once conflict claims;
- promote `山根`, `提升`, or branch-level `鼻子` in `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, nose/shape branch READMEs, `QUALITY_SCORE.md`, or `.planning/PROJECT.md`;
- reinterpret `noseBridge` as `山根` or either signed `noseTipSize` direction as `提升`;
- change public raw geometry, provider/resolver behavior, dependencies, package targets, Demo UI, network/cloud, or commercial paths;
- claim physical-device parity, visual naturalness approval, performance readiness, packaging, shipping, broad product parity, or launch readiness.

The correct handoff is: both new public fields have deterministic saved-output visibility, direct non-alias evidence, no-face extent/no-op evidence, and ignored artifact containment; Phase 37 still owns cap calibration, exhaustive safety, active-source boundary closeout, atomic row/branch promotion, and DOC-01 synchronization.

## Planning Guidance

Keep renderer contract work, output-helper evidence, and gallery/closeout evidence independently verifiable. The dependency is inherently sequential: the helper needs the final case inventory, and gallery/closeout needs a passing clean matrix. Avoid mixing Phase 37 tests or production geometry edits into any Phase 36 work unit. A final evidence pass should occur after documentation/ledger synchronization so that the recorded verdict describes the actual repository state, while the product ledgers remain deliberately unpromoted.

