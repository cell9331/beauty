# QUALITY_SCORE.md

## Current evidence and scope

The SDK-only SwiftPM quality contract uses real assertions, scoped receipts
and current code rather than accumulated phase prose. Effect status belongs
to [SDK_EFFECT_TAXONOMY.md](docs/SDK_EFFECT_TAXONOMY.md); generated inputs are
eligible under [IMAGE_EFFECT_ACCEPTANCE.md](docs/validation/IMAGE_EFFECT_ACCEPTANCE.md).
API compatibility, safety mechanics and useful effect qualification are distinct.
No score or complete engineering gate overrides a frozen effect failure.

| Area | Current evidence | Limit |
| --- | --- | --- |
| Prepared fixed-photo editing | SDK **65 distinct direct tests / 0 failures / 0 skips**, including nine new source/lifecycle/purpose/pixel/Metal cases; native App **13/0/0** on the existing iPhone15Pro/iOS17.5, including actual 478-point reuse/fresh pixel equality, replacement/export, session guards and UI interaction. macOS production host control/alpha/export helper passes. [Record](plans/history/2026-10/A-2026-10-10-prepared-photo-editing.md). | Scoped paths only; no full SDK/App rerun, video, new effect, grey-entry unlock or physical-device speed claim. |
| Bounded playbook SDK refactor | **134 distinct direct regression tests / 0 failures / 0 skips** across geometry/support/combination, source-raster/metadata/protection, facade routing and canonical local-retouch composition. Four new stage/diagnostic cases pass. CPU/Metal live parity gate **14/0/0**, with actual Metal execution; parity/neutral and SDK-only mutation controls pass. [Record](plans/history/2026-10/A-2026-10-09-playbook-sdk-refactor.md). | Related paths only. No full SDK/App rerun, native iOS/physical-device or timing claim; existing effect qualification and grey entries unchanged. The new parity self-test repairs a pre-existing test-order dependency rather than relaxing its oracle. |
| Latest bounded combination/disabled-entry repair | SDK **25 tests / 0 failures / 0 skips**: dense independent values, source/legacy limits, fresh admission, actual pixels, border/alpha/repeat and positive triangles. External editor's **12 distinct related tests ultimately passed** (10 unit + 2 UI), including full-range composition and disabled-entry screenshots/clicks. [Record](plans/history/2026-10/A-2026-10-09-combination-ui.md). | Native first bundle has 11 passes/1 test-accessor failure; corrected test's one-case retry passes, and the final fresh-policy pixel case separately passes. No full SDK/App rerun, new device or phone installation. |
| Bounded owner-overlay repair | SDK diagnostic **3 tests / 0 failures / 0 skips**; actual external editor **4/0/0** (3 unit + 1 UI) on the same iPhone 15 Pro / iOS 17.5. Ordered/redacted points, no-face/error recovery, source/output 478, debug pixel-inert, six nose tools/four steps, composition and revision/UI guards. | Only these directly affected paths were run; the complete SDK and native integration suites below are earlier checkpoints, not rerun for this repair. Phone installation remains unverified. |
| SDK engineering | Complete SDK gate, 2026-10-09: **1098 tests / 0 failures / 0 skips, 9 opt-ins**, archive/boundary/backend/consumer/CPU-oracle checks. [Record](plans/history/2026-10/A-2026-10-09-dense-face-refactor.md). | macOS retains Vision. This engineering gate does not qualify general appearance or physical-device performance. |
| MediaPipe iOS integration | Same existing iPhone 15 Pro / iOS 17.5: **24 native tests / 0 failures / 0 skips**, comprising 9 original probe and 15 SDK adapter/provider/consumer tests. Two authorized portraits, mesh/pose/visible iris, actual combination pixels, CPU/GPU maximum channel difference≤2, 20 exact repeats, no-face/reset/recovery/cadence. | Synchronous CPU image mode with shared CPU-owned dense geometry; two portrait inputs, no broad accuracy/occlusion/appearance or physical-device speed claim. |
| Dense still-image mechanics | Final targeted geometry/support **12/0/0**, included in the complete gate: source-fixed ring/impulse direction, actual iris-area change, dark-skin noise, protection, extent/color/alpha/repetition, invalid supports and extreme composed-map orientation. Independent smoothing/sharpening combination oracle also passes. [Guide](docs/sdk/DENSE_FACE_REFACTOR.md). | Source-defined generated domains plus native integration; no population, semantic segmentation, video or end-to-end-GPU claim. Existing taxonomy qualification remains scoped. |
| Control qualification | 63 legacy taxonomy rows: 62 bounded `implemented`, one upper-eyelid `suspended`; 77 parameter fields, 99 registered/98 default cases. | Each row's stated input domain applies; no generic portrait, 3D or population claim. |
| Additional 15 shape controls | [Final source-defined positive/negative/direction/protection table](plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md). | Qualified generated-image 2D domains, not general anatomy/segmentation. |
| Teeth/sclera retouch | Independent public-facade/fixture pixel, protection, metadata and failure oracles in the mandatory gate. | Opaque still-image scope; no realtime/end-to-end-GPU promise. |
| Upper-eyelid correction | Retained compatibility, reconstruction/quantization/protection and calibrated Vision checks. [Failure/research](docs/history/upper-eyelid/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md). | Natural-appearance target failed; no provisional available-effect claim remains. |
| v1.25 automatic EYE/SEG | Each branch exhausted two methods/four versions; 5 requirements verified, 11 `closed_unmet`, no active phase. [Final disposition](docs/history/retouch/RETOUCH_FINAL_DISPOSITION_2026-10-03.md). | Neither automatic branch delivered; no full EYE G0, candidate holdout or production integration. |
| Host texture assistance | Object + complete-lip union regression **4/0/0**, original object-mask combination **8/0/0**. [Guide/evidence](docs/sdk/HOST_TEXTURE_PROTECTION.md). | Requires independent correct host pixels; does not repair automatic coarse-lip/object failures. |
| Current batch tool | Regression **17/0/0**; 98 cases twice: 7 passed/91 abstained; missing-oracle control exits 3. [Evidence](docs/validation/CURRENT_BATCH_VALIDATION.md). | Default input has no face; color-only metrics do not qualify geometry/texture/appearance. Old 75-case wrapper stays historical. |
| Owner editor | Separately scoped external-host tests/repairs recorded in [PLANS.md](PLANS.md). | Sustained iOS 17.5 simulator Vision and segmentation positive failures remain; no real-device speed claim. |

These rows are executed, dated checkpoints for their linked evidence scopes.
Subsequent independent source changes do not make those checkpoints a new
execution for the current working tree. Active refactors keep their own scoped
verification in [PLANS](PLANS.md); the inventory below is not test evidence.

The simulator sustained Vision failure does not retroactively change unrelated
bounded gates; its provider limitation
remains in [current debt](plans/debt/current.md), while the default iOS SDK route
now uses MediaPipe. Historical receipts, original
failed predicates and archived milestone evidence remain unchanged.

## Dated inventory

Static working-tree inventory sampled at **2026-10-10 09:50 +08:00**, excluding `.build`
and historical archives: **95 Swift source files / 24,424 lines;
149 SwiftPM test files / 55,287 lines**. This includes uncommitted source/test files if present;
it is not an executed-test denominator. Previous audits retain their own dates.

| Contract inventory | Value | Authority |
| --- | ---: | --- |
| Parameter stored fields | 77 | `BeautyParameters` / taxonomy |
| Configuration stored fields | 11 | `BeautyConfiguration` |
| Neutral presets / LUT filters | 5 / 2 | Bundled resource manifest |
| Renderer registered / default identities | 99 / 98 | Renderer registration, normative tests and current-batch inventory |
| Mandatory opt-in test identities | 9 | `expected_opt_in_tests` in the complete wrapper |
| Explicitly assigned wrapper child environment inputs | 5 | Three opt-in switches and two bundle selectors; separate from inherited fixture overrides |
| Library / executable products | 1 / 1 | `BeautySDK/Package.swift` |
| Library / test targets | 6 / 6 | `BeautySDK/Package.swift` |
| Pinned iOS binary targets | 3 | MediaPipe 1.1.0 Common/Graphs/Vision; fixed official URLs/SHA-256 and Detection-owned iOS conditions |
| Legacy archive bundles / intentional files | 2 / 45+26 | Code-owned archive anchors |

Recompute dynamic source/test totals rather than copying old counts into owners:

```bash
python3 - <<'PY'
from pathlib import Path
for root in ('BeautySDK/Sources', 'BeautySDK/Tests'):
    files = sorted(Path(root).rglob('*.swift'))
    lines = sum(len(p.read_text().splitlines()) for p in files)
    print(root, 'files=', len(files), 'lines=', lines)
PY
```

## Verification gates

For document-only work, check local links/anchors and claims against source,
verify archive/boundary and wrapper controls, check preservation hashes and
`git diff --check`. Report that SwiftPM was not rerun when code/tests did not
change; do not present an old receipt as new execution.

For SDK behavior, run the narrow relevant public/target tests first. Complete
owner-local milestone closeout requires:

```bash
bash scripts/run-no-skip-swiftpm.sh
```

The script owns exact order: archive integrity, boundary self-test/live scan,
example storage, archived v1.18 binding self-test/live check, sequential
backend/runtime/feature/configuration/parity checks, public consumer, generated
CPU oracle, fixture admission and one bounded full SwiftPM child. Transcript
capture is limited to 16 MiB/200,000 lines. The parser requires all nine opt-in
identities exactly once, one nonzero zero-failure XCTest aggregate, no skips/
disabled events and a passed Swift Testing aggregate when that runner starts.
Tool/fixture/summary/oversize/zero-execution failures cannot earn completion.
Separate Metal available/unavailable accounting must not merge typed unavailability
with executed parity success.

The five retained backend gates share `scripts/validate-sdk-dependencies.py`.
It admits only the three specifically authorized fixed binaries, in Detection
and on iOS only, rejecting other source/binary dependencies. Its 11 mutation
checks and the backend-neutral gate's dependency mutations passed. Native iOS
source/consumer setup is documented in [IntegrationTests/MediaPipeIOS](IntegrationTests/MediaPipeIOS/README.md);
media and application sources remain outside the repository.

Plain `swift test --package-path BeautySDK` can leave established opt-ins
skipped and is not full closeout. Current wrapper fixture overrides and exact
eligibility are documented in the acceptance policy. A generated portrait is
not rejected for its provenance; its rights and pixel/metadata oracle must pass.
Physical-iPhone feedback is optional, not an implicit gate or progress blocker.

## Image, privacy and archive checks

Image tests inspect actual input/output pixels and applicable dimensions/extent,
orientation/mirroring, color/alpha, neutral identity, direction, negative/no-
worsening behavior, target/protection, tolerance, determinism and typed recovery.
An independent source-defined oracle must fail wrong/no-op/leaking controls;
process completion, safe output or changed-pixel totals alone are insufficient.
Visual claims additionally need original-detail inspection against declared rules.

Archive verification binds exact ZIP/manifest identities, inventory/count/size,
CRC, path safety and bounded extraction. The two retired roots never return
to active source. Raw generated/real media, masks, geometry, private fixture
paths and child transcripts stay local/ignored and out of durable evidence.
Storage/cleanup must preserve required fixtures and frozen `.build` receipts.

The last engineering gate does not establish device latency, thermals, battery,
endurance, population behavior, commercial visual quality, packaging, launch
or distribution. Reproducible new findings enter PLANS/debt without rewriting
historical qualification. See [SECURITY.md](SECURITY.md) and
[RELIABILITY.md](RELIABILITY.md) for the owning bounds and failure contracts.

## Documentation maintenance

Each contract has one owner; current prose replaces superseded claims rather
than stacking patches. Keep current source/test inventory here, effect/control
status in the taxonomy, work/debt in PLANS and its links. The
[docs index](docs/README.md) separates current guides from historical context.
Current implementation/integration guides belong in `docs/sdk/`, acceptance and
batch guides in `docs/validation/`, Git guidance in `docs/operations/`, and dated
design/audit/closed-research material in `docs/history/`. Learning references keep
their existing playbook directories. New current citations point directly to
the classified document; compatibility pages contain navigation only and do not
own a second contract. The taxonomy and three hash-bound R2/G0 documents retain
their fixed paths. [Old path mappings](docs/history/README.md#旧路径对照) support
immutable historical citations.

The `.planning/codebase/` maps are dated analyses; their live navigation headers
point to current owners rather than making their old inventories current.
For drift repair, confirm each changed claim against code/tests or its dated
receipt, and separate implemented behavior, authorized work, unexecuted
proposals and historical outcomes. Compare existing link/anchor failures before
and after editing; report any remaining historical failures. Use the narrow
checks warranted by the document change, preserving concurrent local work.

Frozen thresholds, failures, archives, snapshots and receipts retain their
original bytes and scope. Unreferenced proposals or duplicate imports may be
removed after confirming no current code/gate dependency and recording the
reason; they do not create a new algorithm or model task.
