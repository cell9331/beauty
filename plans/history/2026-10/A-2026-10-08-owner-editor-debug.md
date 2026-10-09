# C-2026-10-09-owner-editor-debug

| Field | Value |
| --- | --- |
| Status | `completed` for the bounded owner-host repair; sustained simulator detection remains unmet. |
| Started / Completed | 2026-10-08 / 2026-10-09 |
| Source Request | Owner reported ineffective controls, prior effects weakening and slow adjustments; requested source/output landmarks on the page. |
| Scope | Adjacent, previously authorized `BeautyEditorApp`; bindings/ranges, cumulative parameters, in-memory debug display and preview scheduling. |
| Files | Host catalog/state/model/renderer/screen, tests and pixel helper, binding checker, README/VALIDATION; SDK FRONTEND/RELIABILITY/plan/debt navigation only. |
| SDK Build | Production SDK source unchanged. Boundary and example-storage checks pass; prior 1076/0/0 gate is not rerun or reissued. |

## Findings and changes

All 53 enabled positions reach 51 canonical SDK scalar fields; two alias pairs
share fields, and suspended upper-eyelid reduction stays unavailable. The owner
input is 1122×1402, not unusually large. The old sliders transmitted 0…1 even
where safety caps were 0.25/0.30/0.35/0.60, producing an early plateau. The reported
five-control sequence at 71 caused the SDK to scale all geometry to about 0.5556;
parameters were retained, but previous visible strengths weakened.

Sliders now map their full range to each admitted cap. Existing fields reserve
the unchanged total geometry budget of 1.0; only the currently edited field can
be limited to the remainder, with an explicit notice. Aliases count once.
The checker validates all fields, caps and total threshold against current SDK
source. No budget increase, new shader/backend/model or algorithm is introduced.

Preview is bounded to 960 px and export still decodes the original. One running
render plus one replaceable pending request provides completed frames during
dragging and ends on the latest value. Photo/worker/version guards prevent a
canceled session overwriting the new one. Eligible non-simulator inputs reuse
the existing SDK Metal backend; neutral, nasal root and simulator use CPU;
typed Metal preflight failure falls back to CPU, including nonopaque inputs.

The toolbar/menu debug toggle draws cyan source circles and yellow output points
with the actual aspect-fit rectangle. Source points are cached per imported
photo; each accepted preview gets independent Vision re-detection. Async debug
results are isolated by photo/request/image revision, and closing clears points.
The panel labels them as Vision re-detection rather than SDK warp control points,
and shows image/parameter revisions, point counts, raster size, render duration,
backend, field value, budget and typed detection/warning reasons. Debug does not
modify rendered/exported pixels, guarantee inference accuracy or persist points.

## Actual verification

Reused iPhone 15 Pro / iOS 17.5, UDID
`2CE927C9-9303-4A9B-9C03-F28C42045186`, 393×852 pt, existing portrait/font settings.
Waited for the previous project, claimed/released this device only, disabled
parallel testing, reused stable DerivedData and macOS helper scratch paths.
No simulator/runtime creation, cache cleanup, physical-device installation or
signature/account change occurred.

| Check | Actual result / scope |
| --- | --- |
| Host field/cap/resource checks | 51 canonical fields/caps and threshold agree; 60 SVG / 54 icons pass. |
| macOS independent audit | 45 of 53 enabled positions changed this input's pixels. Eight conditional abstentions remain; pixel counts establish reachability, not effect qualification. |
| macOS six nose tools | Four distinct nonzero steps each; full step repeats exactly; CPU/Metal max byte difference ≤1, root CPU. |
| macOS combination/debug/export | Prior scalars exact, no global weakening, source/output 87 aggregate points, debug pixel-inert, neutral identity, preview 768×960, export 1122×1402 sRGB PNG exact round trip/no source GPS; transparent P3 fallback equals CPU and preserves alpha. |
| Native bounded behavior | 24 tests / 0 failures / 0 skips (23 unit + 1 UI): caps/aliases/budget, continuous preview, final version, debug source cache/output refresh/off races, bounded import, EXIF/color/alpha, recovery, export and bottom layout. |
| Additional native UI | 1/0/0, waiting for matching image/parameter versions before checking nose and previous face value; debug off removes the panel. |
| Actual screenshots | Three generated-input editor/review/restored layout captures inspected; background reaches bottom and content avoids inset. Temporary portrait debug capture inspected then deleted; it exposed inference drift and does not qualify landmark accuracy. |
| Native sustained nose positive | Failed: 21 unit tests, 20 pass and one has 39 assertion failures, plus UI 1/0/0. Later requests return partial/mappingFailed and geometry safely abstains. Failure receipt and strict oracle retained. |
| Independent Vision diagnostics | Same unchanged source without SDK also drifts: rev3 request 9 has 4 out-of-image points, request 12 all 76. Rev2, legacy CPU and independent CGContext raster copies do not remove the failure. Explicit advertised GPU returns Vision code 9 immediately. Only aggregate counts retained; temporary diagnostic methods removed. |
| SDK repository checks | post-archive boundary, example-image storage and documentation/diff checks pass; no new media, raw points/masks, private source locator or full child transcript in SDK evidence. |

Host-owned aggregate receipts remain in its ignored verification directory.
Debug macOS timing diagnostics compare different backends and resolutions and
are not a benchmark or iPhone performance evidence.

## Remaining limits

Sustained Vision inference on this simulator is unresolved. The independent
reproducer rules out the editor's field binding and coordinate projection as
the sole cause; Apple's internal cause has not been identified. Invalid support
is not admitted, synthetic points are not substituted, and the failed sustained
test is not counted as a pass. Actual UI re-detection may lose groups or visibly
drift, which the new debug mode exposes. This limitation is recorded separately
in current debt and does not reopen the terminated v1.25 algorithm branches.

The earlier iOS person-segmentation positive remains failed; a no-person rejection
test passing does not qualify protection. No physical iPhone sustained detection,
responsiveness, thermal or energy result exists. Effect meanings/qualification
remain owned by the current SDK taxonomy, rather than the editor's control list.
