---
phase: 51
slug: public-facade-eyebrow-output-evidence
status: planned
nyquist_compliant: false
wave_0_complete: false
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
| 51-01-01 | 01 | 1 | OUT-01, OUT-03 | T-51-01–03 | Exact 72 public cases, e6-only portrait, no internal bypass | XCTest/static | Renderer regression + source cardinality + active fixture checks | planned |
| 51-01-02 | 01 | 1 | OUT-03 | T-51-04–05 | Local degradation and aggregate-only diagnostics | XCTest | Public facade regression | planned |
| 51-02-01 | 02 | 2 | OUT-02, OUT-03 | T-51-06–08, T-51-10 | Bounded exact inventory/decoder with retired-fixture rejection | Python self-test | Helper self-test + bytecode compilation | planned |
| 51-02-02 | 02 | 2 | OUT-02 | T-51-09–11 | Fixed non-circular locality, sign, family, and no-face contracts | Python self-test | Helper semantic adversarial tests | planned |
| 51-03-01 | 03 | 3 | OUT-02, OUT-03 | T-51-12–16 | Separate measurement/strict runs and exact denominator split | render/integration | Guarded clean render + strict helper + 144-file check | planned |
| 51-03-02 | 03 | 3 | OUT-02 | T-51-17 | Actual opened-image review blocks contradictory visual claims | visual + regression | Fourteen evidence rows + provider suite + strict helper; end-of-phase human check | planned |
| 51-04-01 | 04 | 4 | OUT-03 | T-51-18–21 | Exact descriptor-safe eyebrow gallery group | Python self-test | Gallery self-test + bytecode compilation | planned |
| 51-04-02 | 04 | 4 | OUT-03 | T-51-18–22 | Exact ignored 144-file publication with no retired portraits | integration/static | Gallery publication + bijection + artifact scans | planned |
| 51-05-01 | 05 | 5 | OUT-01, OUT-02, OUT-03 | T-51-23–27 | Fresh complete evidence and no pre-recorded green rows | full/integration/static | Focused + full + helper + strict + gallery + scans | planned |
| 51-05-02 | 05 | 5 | OUT-01, OUT-02, OUT-03 | T-51-24–26 | Owner contracts preserve count, privacy, reliability, and Phase 52 boundaries | static/docs | Owner keyword/cardinality and diff gates | planned |
| 51-05-03 | 05 | 5 | OUT-01, OUT-02, OUT-03 | T-51-24–27 | Close only OUT-01..03 and Phase 51 | static/ledger | Requirement/roadmap/state/product checks | planned |

## Wave 0 Requirements

- [x] Existing `BeautyRendererOutputRegressionTests.swift` source parser and facade/no-face patterns.
- [x] Existing request-local paired/left/right/missing/malformed/no-face testing fixtures.
- [x] Archived Phase 43/47 bounded decoder and semantic-output helper patterns.
- [x] Descriptor-safe `generate_gallery.py` self-test/publication infrastructure.
- [x] Sole active portrait `example-images/input/portraits/e6.jpg` and separate negative fixture.
- [ ] Phase 51 helper self-tests and strict semantic contract — created in Plan 51-02 before live acceptance.

## Manual/Visual Verification Contract

Automated pixel gates are necessary but not sufficient. Plan 51-03 must open `e6__geometryBaseline_noop.png` and all thirteen actual `e6__eyebrow*.png` outputs at original detail, record one observation per file, and receive the configured end-of-phase human check. A reversed direction, visible protected-region spill, imperceptible effect, collapsed spacing/head-spacing, or collapsed thickness/peak result keeps the task and phase non-passing.

## Validation Sign-Off

- [ ] Every task has an automated verification command.
- [ ] Helper self-tests exist before measurement and strict acceptance.
- [ ] Measurement and strict acceptance use separate guarded clean renders.
- [ ] Exact 72 portrait / 13 negative / 144 total terminology is preserved.
- [ ] Fourteen actual representative images are opened and reviewed.
- [ ] Full SwiftPM, strict helper, gallery, artifact, privacy/scope, and diff gates pass.
- [ ] OUT-01..03 close while SAFE-01..03 and DOC-01 remain open.
- [ ] Set `status: complete`, `wave_0_complete: true`, and `nyquist_compliant: true` only after execution evidence fills every row.

**Approval:** Not yet approved; this is the pre-execution validation contract.
