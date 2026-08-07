# Phase 61 Pattern Map

## Closest analogs

| Phase 61 role | Existing analog | Reuse |
| --- | --- | --- |
| Public renderer case and exact inventory | `BeautySDK/Sources/BeautyExampleRenderer/main.swift`; `BeautyRendererOutputRegressionTests.swift` | Flat case ID, one public facade call, source-parsed exact inventory, same-dimension output. |
| Bounded strict PNG decoder | `.planning/milestones/v1.13-phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py` | No-follow reads, CRC/chunk/decode budgets, scanline unfilter, exact inventory, mutation self-test. |
| Private fixture discovery | `.planning/phases/59-teeth-evidence-and-admission-contract/59-private-evidence-runner.js` | NUL-safe ignored-file discovery, child-only environment, fixed output, tracked/staged privacy scan. |
| Genuine decoded metrics | `BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift` | Canonical dimensions, reviewed-mask containment, yellow/luminance/channel/texture/alpha metrics. |
| Adversarial provider/facade safety | `BeautyTeethWhiteningProviderTests.swift`; `BeautyEngineTeethWhiteningIntegrationTests.swift` | Literal protected sentinels, table-driven support failures, production facade lifecycle. |
| Pre/post promotion checker | `.planning/milestones/v1.12-phases/48-face-safety-and-scoped-closeout/check_face_safety_boundaries.py` | Default unpromoted mode, allow-promotion mode, exact owner and threat gates. |

## Data flow

`authorized ignored originals -> private staging -> BeautyExampleRenderer -> public BeautyEngine -> ignored six PNGs -> bounded strict helper -> aggregate evidence -> blinded original-detail review -> pre-promotion conjunction -> exact product transaction -> post-promotion verification`

The reviewed mask participates only after rendering as private evaluation truth.
It never enters `BeautyEngine`, provider selection, composition, or public API.

## Landmines

- Default renderer watermark differs by case and would create false outside-mask
  changes; strict runs need the opt-in presentation-free path.
- The recursive renderer would process `mask.png` and `after.png` if pointed at
  the bundle directly; the private runner must stage originals only.
- Multiple legacy tests hard-code 72 and teeth absence; update exact counts and
  narrow historical prohibitions while retaining sclera/upper-eyelid absence.
- Duplicate fixture basenames and symlinks must fail rather than silently
  overwrite flat output names.
- A generated montage or review mapping is private ignored media and must not be
  committed, logged with paths, or used as evidence authority.
- Product owners change only after all pre-promotion gates and must be checked
  again in a separate post-promotion mode.

