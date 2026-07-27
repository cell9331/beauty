# Phase 52 Eyebrow Safety Evidence

status: passed

This record captures the fresh Phase 52 gap-closure runtime and simulator
regression together with the unchanged strict renderer, gallery, and
actual-image review. It is mechanical review input for SAFE-01, SAFE-02, and
SAFE-03. Independent code review and independent final re-verification remain
pending. It does not claim commercial naturalness,
physical-device parity, long-run performance, packaging, shipping, launch,
independent milestone audit, archive, tag, or cleanup completion.

## Provenance

- Evidence date: 2026-07-27 (Asia/Shanghai)
- Gap-closure checker commit: `7748f06`
- `BeautySDK/Package.swift` repository state: `6f03b078816ad1f7a426e3f70d4f57503f3152e9`
- Output root: `example-images/output`
- Gallery root: `example-images/gallery`
- Fixture policy: `e6` is the sole promoted portrait fixture; `e1`–`e5`
  remain parked; the separate no-face fixture is degradation-only.
- The unchanged Phase 51 strict helper was run in default strict mode without
  `--measure`; frozen calibration was not rewritten.

## Fresh Runtime Results

focused_suites: 8/8
full_swiftpm_failures: 0
strict_helper_exit: 0
gallery_exit: 0
checker_default_exit: 0
checker_self_test: 130/130
demo_simulator_discovery: iPhone 17 Pro / iOS 26.5
demo_simulator_build_exit: 0
demo_simulator_test_exit: 0
demo_diff_files: 0

| Suite | Executed | Skipped | Failures |
| --- | ---: | ---: | ---: |
| `BeautySafetyCapsTests` | 7 | 0 | 0 |
| `BeautyEffectResolverTests` | 27 | 0 | 0 |
| `EyebrowWarpProviderTests` | 14 | 0 | 0 |
| `MissingLandmarkDegradationTests` | 51 | 0 | 0 |
| `GeometryConflictResolverTests` | 14 | 0 | 0 |
| `CombinedEffectSafetyTests` | 17 | 0 | 0 |
| `BeautyGeometryEffectPipelineTests` | 4 | 0 | 0 |
| `BeautyEngineGeometryFacadeTests` | 20 | 1 opt-in | 0 |

The fresh full SwiftPM run executed 450 tests with 6 expected skips and zero
failures. The fresh renderer produced 72/72 `e6` portrait cases and the
thirteen separate no-face comparisons, for 144 disposable outputs total.

The installed-simulator precheck found `iPhone 17 Pro` under the exact iOS
26.5 runtime. The unchanged `BeautyDemo` scheme then built and tested with the
explicit destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5`;
both commands exited 0 and `git diff --name-only -- BeautyDemo` was empty.

## WR-01 / WR-02 / WR-03 Closure Inputs

- **WR-01:** `EyebrowSafetyFixtures.swift:127-177` routes reusable traces
  through `BeautyFaceGeometryAdapter.validatedBrowTrace`, checks
  inner-to-outer center distance, inclusive chord bounds, and vertical span.
  `EyebrowWarpProviderTests.swift:95-142` covers exact `0.08`/`0.50`,
  adjacent excluded values, deterministic equal-projection ordering, and
  nil/empty/single/duplicate/non-finite local failure. The provider suite
  executed 14 tests with zero failures.
- **WR-02:** `BeautyEffectResolver.swift:80-100,216,338-344` owns separate
  nil-default resolver/provider entry callbacks;
  `EyebrowWarpProvider.swift:47-54` fires the provider-owned callback after
  method entry and before support lookup. The targeted cancellation test at
  `MissingLandmarkDegradationTests.swift:1348-1458` waits for both entry
  signals, holds that request on its own barrier, cancels the caller, releases,
  and verifies that the synchronous resolver completes one intact request-local
  result while 28 parallel and seven subsequent identities retain local
  warnings, counts, metrics, and results. The SDK has no asynchronous
  publication owner: host code is responsible for deciding whether a completed
  synchronous value may replace current state. The targeted test and full
  51-test degradation suite passed.
- **WR-03:** `BeautyEffectResolver.swift:644-691` invokes
  `onRetainedMaskIteration` from the real bounded loop after provider
  sanitization and records only scalar values and stable names. The seven-row
  test at `CombinedEffectSafetyTests.swift:88-240` proves pre-scale emission,
  a strictly nonzero scaled value with one-quarter-value accuracy, one
  monotone removal, no re-entry, final aggregate exclusion, and identical
  repeated traces/fixed points. The targeted test and full 17-test combined
  suite passed.

The independent `52-REVIEW.md` remains unchanged at its earlier
`issues_found` result until the separate post-Wave-8 reviewer reruns. The
independent `52-VERIFICATION.md` remains `status: gaps_found`; this executor
does not rewrite its verdict.

## Strict Output and Gallery Results

- Decode/dimension inventory: 144/144.
- Portrait visibility: 13/13 visibility checks passed.
- Signed eyebrow directions: 6/6 signed direction checks passed.
- Semantic distinction matrix: 21/21 passed.
- Portrait direct comparisons: 40/40 passed.
- Separate no-face behavior: thirteen separate no-face comparisons passed.
- Protected-region ceilings and the frozen strict calibration passed.
- Gallery publication produced exactly 144 PNG files in bijection with the
  output inventory.
- Output and gallery files were confirmed ignored, untracked, and unstaged.
- The gallery publisher's ignored `.gallery-quarantine/previous` staging
  residue was removed only after its resolved path was confirmed inside the
  declared disposable gallery root; no tracked file was removed.

## Actual-Image Review

Every file below was opened from the fresh output root at original detail. The
review checked visible direction, eyebrow-local mutation, protected-region
stability, and semantic distinction from the baseline and adjacent controls.

| File | Observation | Verdict |
| --- | --- | --- |
| `e6__geometryBaseline_noop.png` | Stable portrait baseline with natural eyebrow arcs and no geometry mutation. | PASS |
| `e6__eyebrowYPosition_plus0p25.png` | Both eyebrows move downward toward the eyes; hair, eyes, nose, mouth, and frame stay visually stable. | PASS |
| `e6__eyebrowYPosition_minus0p25.png` | Both eyebrows move upward toward the forehead, opposite to the positive control; protected regions stay stable. | PASS |
| `e6__eyebrowThickness_plus0p25.png` | Both eyebrow bands are visibly fuller while their overall placement and the rest of the portrait remain stable. | PASS |
| `e6__eyebrowThickness_minus0p25.png` | Both eyebrow bands are visibly narrower than the positive control, with no visible non-eyebrow displacement. | PASS |
| `e6__eyebrowLength_plus0p25.png` | Eyebrow spans extend outward at the tails while retaining eyebrow-local deformation. | PASS |
| `e6__eyebrowLength_minus0p25.png` | Eyebrow spans shorten at the tails, opposite to the positive control, without moving protected regions. | PASS |
| `e6__eyebrowSpacing_plus0p25.png` | The complete left/right eyebrow shapes translate farther apart; the portrait outside the eyebrow region stays stable. | PASS |
| `e6__eyebrowSpacing_minus0p25.png` | The complete eyebrow shapes move closer toward the center, opposite to the positive control. | PASS |
| `e6__eyebrowHeadSpacing_plus0p25.png` | Inner eyebrow heads separate while the tails move materially less than in whole-spacing, preserving semantic distinction. | PASS |
| `e6__eyebrowHeadSpacing_minus0p25.png` | Inner eyebrow heads move toward the center with tail-local stability, opposite to the positive head-spacing control. | PASS |
| `e6__eyebrowTilt_plus0p25.png` | Eyebrow slopes rotate in the positive direction with clear bilateral, eyebrow-local change. | PASS |
| `e6__eyebrowTilt_minus0p25.png` | Eyebrow slopes rotate in the opposite direction with visibly raised outer arches and stable protected regions. | PASS |
| `e6__eyebrowPeakDefinition_0p25.png` | The arch apex becomes more defined without the uniform band widening seen in the thickness control. | PASS |

Visual review verdict: PASS

## Source Hashes

These hashes bind the runtime evidence to the package, cap/resolver/provider
implementation, renderer, unchanged strict helper, and gallery publisher.

| Path | SHA-256 |
| --- | --- |
| `BeautySDK/Package.swift` | `504e5394fbb3f11b699e3f3237392e34d6f38653566dfb2a347a59c6b0b7b011` |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift` | `639fa96c0c3355ae7b9aac2a194a9229b7dd256f31bc0ae258c1a23a9a3bf776` |
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | `abf2c1366ef8268fc8eb11ee4e3efd75ef219e382b3ba02f1cab3fc4b37bd059` |
| `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift` | `79ca2c7d39d6b8ae5e1ceb21e08e8241ad51c2c2e9068af1ad919ae8f312d6ef` |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | `49de98f0552e1dac2a6efe616c0951c2450dcc122a05278cc39db4b2e018cc99` |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | `dd361b0d72e04cd1d74e4c40184bd79a4e47295f8f3f7960cfcea9aab37e5b13` |
| `.planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py` | `4a3723091c907d791e1ab63138e0c801142f2d2dd1eaac320382ed8986f3a9f9` |
| `example-images/generate_gallery.py` | `3e40ad73a15042ebee2ce333546bcb479079f269f59491341fff29061a21f4c8` |

## Scope and Lifecycle

The evidence confirms the final eyebrow caps, corrected local-failure and
request-isolation semantics, complete production convergence, unchanged
strict output contract, simulator regression, and disposable artifact
containment at the tested repository state. The seven rows and `眉毛` branch
remain promoted only at the previously approved SDK-core scope. This Wave 8
record authorizes no additional product mutation: independent code review,
Waves 9–10 owner synchronization, and independent final re-verification are
still pending.

## Final Owner and Planning Dispositions

- Plan 52-04 promoted exactly `上下`, `粗细`, `长短`, `间距`, `眉头间距`,
  `倾斜`, and `眉峰`, plus branch `眉毛`, at SDK-core scope across the four
  product owners after fresh evidence reauthorization.
- Plan 52-05 synchronized the two example owners and the routed architecture,
  design, security, reliability, product, and quality owners without changing
  renderer calibration or adding raw support/pixel evidence.
- Plan 52-06 closes exactly SAFE-01, SAFE-02, SAFE-03, and DOC-01 and records
  exactly six completed Phase 52 plans in requirements, roadmap, project,
  state, and PLANS owners.
- Plan 52-07 supplied command-derived closure inputs for WR-01/02/03; Plan
  52-08 refreshed focused, full SwiftPM, checker, simulator, ASVS L1, and
  exact 23-task Nyquist inputs.
- Independent post-Wave-8 code review is pending and exclusively owns
  `52-REVIEW.md`. Goal-backward `52-VERIFICATION.md` remains independently
  owned and `gaps_found` until its final rerun. Only a later passing verdict
  may hand off to the independent v1.13 milestone audit; this record is not an
  audit, archive, tag, cleanup, UI/device/commercial/performance/packaging,
  shipping, launch, or release-readiness result.
