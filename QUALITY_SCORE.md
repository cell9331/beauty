# QUALITY_SCORE.md

## Current evidence and scope

The SDK-only SwiftPM quality contract uses real assertions, scoped receipts
and current code rather than accumulated phase prose. Effect status belongs
to [SDK_EFFECT_TAXONOMY.md](docs/SDK_EFFECT_TAXONOMY.md); generated inputs are
eligible under [IMAGE_EFFECT_ACCEPTANCE.md](docs/IMAGE_EFFECT_ACCEPTANCE.md).
API compatibility, safety mechanics and useful effect qualification are distinct.
No score or complete engineering gate overrides a frozen effect failure.

| Area | Current evidence | Limit |
| --- | --- | --- |
| SDK engineering | Last recorded complete SDK gate, 2026-10-08: **1076 tests / 0 failures / 0 skips, 9 opt-ins**, archive/boundary/backend/consumer/CPU-oracle checks. [Record](plans/history/2026-10/A-2026-10-08-owner-ios-editor.md). | Simulator face-compute compatibility only; no new effect/device qualification. This document cleanup does not rerun or re-sign that gate. |
| Control qualification | 63 legacy taxonomy rows: 62 bounded `implemented`, one upper-eyelid `suspended`; 77 parameter fields, 99 registered/98 default cases. | Each row's stated input domain applies; no generic portrait, 3D or population claim. |
| Additional 15 shape controls | [Final source-defined positive/negative/direction/protection table](plans/history/2026-10/A-2026-09-27-remaining-effect-qualification.md). | Qualified generated-image 2D domains, not general anatomy/segmentation. |
| Teeth/sclera retouch | Independent public-facade/fixture pixel, protection, metadata and failure oracles in the mandatory gate. | Opaque still-image scope; no realtime/end-to-end-GPU promise. |
| Upper-eyelid correction | Retained compatibility, reconstruction/quantization/protection and calibrated Vision checks. [Failure/research](docs/UPPER_EYELID_AND_SKIN_SEMANTICS_RESEARCH.md). | Natural-appearance target failed; no provisional available-effect claim remains. |
| v1.25 automatic EYE/SEG | Each branch exhausted two methods/four versions; 5 requirements verified, 11 `closed_unmet`, no active phase. [Final disposition](docs/RETOUCH_FINAL_DISPOSITION_2026-10-03.md). | Neither automatic branch delivered; no full EYE G0, candidate holdout or production integration. |
| Host texture assistance | Object + complete-lip union regression **4/0/0**, original object-mask combination **8/0/0**. [Guide/evidence](docs/HOST_TEXTURE_PROTECTION.md). | Requires independent correct host pixels; does not repair automatic coarse-lip/object failures. |
| Current batch tool | Regression **17/0/0**; 98 cases twice: 7 passed/91 abstained; missing-oracle control exits 3. [Evidence](docs/CURRENT_BATCH_VALIDATION.md). | Default input has no face; color-only metrics do not qualify geometry/texture/appearance. Old 75-case wrapper stays historical. |
| Owner editor | Separately scoped external-host tests/repairs recorded in [PLANS.md](PLANS.md). | Sustained iOS 17.5 simulator Vision and segmentation positive failures remain; no real-device speed claim. |

These are previously executed, dated observations. Current document-only
verification is recorded separately in PLANS. The simulator sustained failure
does not retroactively change unrelated bounded gates; it remains an unresolved
finding in [current debt](plans/debt/current.md). Historical receipts, original
failed predicates and archived milestone evidence remain unchanged.

## Dated inventory

Static working-tree inventory measured 2026-10-09, excluding `.build` and
historical archives: **85 Swift source files / 23,499 lines; 140 SwiftPM test
files / 53,897 lines**. This includes uncommitted source/test files if present;
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
Frozen thresholds, failures, archives, snapshots and receipts retain their
original bytes and scope. Unreferenced proposals or duplicate imports may be
removed after confirming no current code/gate dependency and recording the
reason; they do not create a new algorithm or model task.
