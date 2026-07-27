---
phase: 51
slug: public-facade-eyebrow-output-evidence
status: complete
nyquist_compliant: true
wave_0_complete: true
created: 2026-07-24
---

# Phase 51 — Validation Strategy

> Planned per-task feedback and end-of-phase acceptance contract. Execution must replace planned rows with exact observed commands, counts, exit status, and failures.

## Test Infrastructure

| Property | Value |
| --- | --- |
| Frameworks | XCTest via SwiftPM; Python standard-library decoder/self-tests; local image viewer at original detail |
| Config | `BeautySDK/Package.swift`; no new dependency or target |
| Quick Swift command | `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` |
| Quick helper command | `python3 .planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py --self-test` |
| Full suite | `swift test --package-path BeautySDK --disable-sandbox --jobs 1` |
| Strict output | Phase 51 helper with `--input`, `--output`, and `--renderer-source`, without `--measure` |

## Exact Count Vocabulary

- Renderer cases: exactly 72, of which thirteen are Phase 51 eyebrow cases.
- Active portraits: exactly one, `e6.jpg`; strict portrait matrix: exactly 72 decoded outputs.
- Separate negative: `no-face-gradient.png`; strict eyebrow safety comparisons: thirteen candidates versus `geometryBaseline_noop`.
- Total generated output and gallery inventory: exactly 72 cases × 2 fixtures = 144 files. This total is never described as 144 portrait outputs.
- Retired `e1.png` through `e5.png`: parked outside `input/`; zero accepting output/gallery names.

## Sampling Rate

- After renderer edits: focused renderer regression.
- After degradation edits: focused public-facade regression.
- After helper edits: helper self-test plus bytecode compilation.
- After calibration: independent guarded clean render plus strict helper.
- Before output acceptance: open the baseline and all thirteen actual e6 eyebrow images at original detail.
- After gallery edits: generator self-test, exact publication, and artifact-containment scans.
- Before phase close: focused suites, full SwiftPM, final clean strict output, exact gallery, owner/scope/privacy scans, and diff hygiene.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command / Check | Status |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- |
| 51-01-01 | 01 | 1 | OUT-01, OUT-03 | T-51-01–03 | Exact 72 public cases, e6-only portrait, no internal bypass | XCTest/static | Renderer regression + source cardinality + active fixture checks | passed — 72 cases, 13 eyebrow, one active portrait |
| 51-01-02 | 01 | 1 | OUT-03 | T-51-04–05 | Local degradation and aggregate-only diagnostics | XCTest | Public facade regression | passed — 19 executed, 1 opt-in skip, 0 failures |
| 51-02-01 | 02 | 2 | OUT-02, OUT-03 | T-51-06–08, T-51-10 | Bounded exact inventory/decoder with retired-fixture rejection | Python self-test | Helper self-test + bytecode compilation | passed |
| 51-02-02 | 02 | 2 | OUT-02 | T-51-09–11 | Fixed non-circular locality, sign, family, and no-face contracts | Python self-test | Helper semantic adversarial tests | passed |
| 51-03-01 | 03 | 3 | OUT-02, OUT-03 | T-51-12–16 | Separate measurement/strict runs and exact denominator split | render/integration | Guarded clean render + strict helper + 144-file check | passed — frozen strict calibration |
| 51-03-02 | 03 | 3 | OUT-02 | T-51-17 | Actual opened-image review blocks contradictory visual claims | visual + regression | Fourteen evidence rows + provider suite + strict helper; end-of-phase human check | passed — 14/14 opened at original detail |
| 51-04-01 | 04 | 4 | OUT-03 | T-51-18–21 | Exact descriptor-safe eyebrow gallery group | Python self-test | Gallery self-test + bytecode compilation | passed |
| 51-04-02 | 04 | 4 | OUT-03 | T-51-18–22 | Exact ignored 144-file publication with no retired portraits | integration/static | Gallery publication + bijection + artifact scans | passed — 144/144 |
| 51-05-01 | 05 | 5 | OUT-01, OUT-02, OUT-03 | T-51-23–27 | Fresh complete evidence and no pre-recorded green rows | full/integration/static | Focused + full + helper + strict + gallery + scans | passed — evidence below |
| 51-05-02 | 05 | 5 | OUT-01, OUT-02, OUT-03 | T-51-24–26 | Owner contracts preserve count, privacy, reliability, and Phase 52 boundaries | static/docs | Owner keyword/cardinality and diff gates | passed — architecture/design/security/reliability owners synchronized |
| 51-05-03 | 05 | 5 | OUT-01, OUT-02, OUT-03 | T-51-24–27 | Close only OUT-01..03 and Phase 51 | static/ledger | Requirement/roadmap/state/product checks | passed — OUT-01..03 and five plans closed; SAFE/DOC remain open |

## Wave 0 Requirements

- [x] Existing `BeautyRendererOutputRegressionTests.swift` source parser and facade/no-face patterns.
- [x] Existing request-local paired/left/right/missing/malformed/no-face testing fixtures.
- [x] Archived Phase 43/47 bounded decoder and semantic-output helper patterns.
- [x] Descriptor-safe `generate_gallery.py` self-test/publication infrastructure.
- [x] Sole active portrait `example-images/input/portraits/e6.jpg` and separate negative fixture.
- [x] Phase 51 helper self-tests and strict semantic contract — created in Plan 51-02 before live acceptance.

## Fresh Wave 5 Evidence — 2026-07-27

All final commands ran from the repository root on the local macOS host.

### Fixture, compiled, and helper gates

- Fixture preflight passed: `e6.jpg` is the sole active portrait and is regular, nonempty, and non-symlink; `e1.png` through `e5.png` are present only under `parked-portraits/`.
- `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyRendererOutputRegressionTests` passed 16/16 with zero skips.
- `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyCoreTests.BeautyEngineGeometryFacadeTests` executed 19, passed 18, and skipped one explicitly opt-in Apple Vision integration test.
- `swift test --package-path BeautySDK --disable-sandbox --jobs 1 --filter BeautyEffectsTests.EyebrowWarpProviderTests` passed 12/12.
- Python bytecode compilation, the output-helper self-test, and the gallery-generator self-test all exited `0`.
- The first full SwiftPM attempt honestly failed 1 of 438 tests: the Phase 51 projection-order correction had stopped rejecting a zero-extent eyebrow trace. A fail-closed face-axis extent guard restored the existing invariant; `FaceObservationMappingTests` then passed 23/23. The fresh full retry passed 438 executed with 6 explicit opt-in skips and 0 failures in 56.235 seconds.

### Final guarded output and strict acceptance

The final run resolved `example-images/output` to the exact repository output root, confirmed it was ignored, deleted only its descendants, and invoked:

`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output`

The renderer exited `0` and wrote exactly 144 nonempty PNGs: 72 `e6` portrait outputs and 72 separate no-face outputs. The strict helper then exited `0` without measurement mode:

- portrait inventory and decoding: 72/72;
- eyebrow visibility: 13/13;
- signed direction: 6/6;
- semantic family distinction: 21/21;
- portrait direct comparisons: 40/40;
- separate no-face no-op comparisons: 13/13;
- frozen brow ROI: `(0.24, 0.76, 0.24, 0.43)`;
- protected-region maxima remained within fixed ceilings.

No 144-portrait claim is made: 144 is always the disposable two-fixture total.

### Actual-image and gallery gates

The committed evidence table enumerates exactly the baseline plus all thirteen `e6__eyebrow*.png` files. Every one was opened individually at original detail. The recorded observations distinguish signed pairs, whole spacing from head spacing, and thickness from peak while confirming brow-local changes and protected eyes/forehead-hair/background. `Visual review verdict: PASS` remains present and agrees with the fresh strict run.

The published gallery contains exactly 144 regular PNGs and thirteen immediate eyebrow case directories. Reconstructed fixture-and-case names are a 144/144 bijection with output. No `e1`–`e5` artifact is accepted. Output, gallery, and bounded quarantine roots are ignored, untracked, and unstaged; staging is absent and quarantine is a non-symlink directory.

### Privacy, dependency, and promotion scans

- `BeautySDK/Package.swift` retained pinned hash `6f03b078816ad1f7a426e3f70d4f57503f3152e9`.
- The Phase 51 range added zero public/open/SPI declarations and exposes zero raw eyebrow support/trace types publicly. The example renderer imports only the public `BeautySDK` product for SDK access and contains exactly one `engine.processResult` call.
- The complete Phase 51 range added no Demo source, manifest/resolution change, resource/model/Metal asset, dependency, URL/session/network/cloud path, or commercial/release-ready behavior.
- Product promotion ledgers are unchanged: all seven eyebrow rows and the `眉毛` branch remain `future`.
- Aggregate metrics and generated filenames are the only committed output evidence; raw support points, decoded pixels, and generated image bytes remain absent.
- Generated roots contain zero tracked, staged, or non-ignored files. `git diff --check` passed.

## Manual/Visual Verification Contract

Automated pixel gates are necessary but not sufficient. Plan 51-03 must open `e6__geometryBaseline_noop.png` and all thirteen actual `e6__eyebrow*.png` outputs at original detail, record one observation per file, and receive the configured end-of-phase human check. A reversed direction, visible protected-region spill, imperceptible effect, collapsed spacing/head-spacing, or collapsed thickness/peak result keeps the task and phase non-passing.

## Validation Sign-Off

- [x] Every task has an automated verification command.
- [x] Helper self-tests exist before measurement and strict acceptance.
- [x] Measurement and strict acceptance use separate guarded clean renders.
- [x] Exact 72 portrait / 13 negative / 144 total terminology is preserved.
- [x] Fourteen actual representative images are opened and reviewed.
- [x] Full SwiftPM, strict helper, gallery, artifact, privacy/scope, and diff gates pass.
- [x] OUT-01..03 close while SAFE-01..03 and DOC-01 remain open.
- [x] `status: complete` and `nyquist_compliant: true` are set after owner and lifecycle synchronization filled the final two rows.

**Approval:** Phase 51 automated, actual-image, owner, and lifecycle evidence is approved. Effective caps, seven row and branch promotion, exhaustive safety, Demo/device/commercial/performance/packaging/shipping/release claims, SAFE-01..03, and DOC-01 remain Phase 52 or later work.
