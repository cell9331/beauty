# Phase 52 Eyebrow Safety Evidence

status: passed

This record captures the fresh Phase 52 pre-promotion runtime, strict renderer,
gallery, and actual-image review. It is mechanical acceptance evidence for
SAFE-01, SAFE-02, and SAFE-03. It does not claim commercial naturalness,
physical-device parity, long-run performance, packaging, shipping, launch,
independent milestone audit, archive, tag, or cleanup completion.

## Provenance

- Evidence date: 2026-07-27 (Asia/Shanghai)
- Safety checker commit: `ed4d8c2`
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
| `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` | `118517a0299025af80d849222edb5e364da6ea890afa4149c9db13622bb88fac` |
| `BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift` | `eaf716a12a82a9c3e1c599a8b2458e479ee50586f2e5699966c95d41c8963122` |
| `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift` | `49de98f0552e1dac2a6efe616c0951c2450dcc122a05278cc39db4b2e018cc99` |
| `BeautySDK/Sources/BeautyExampleRenderer/main.swift` | `dd361b0d72e04cd1d74e4c40184bd79a4e47295f8f3f7960cfcea9aab37e5b13` |
| `.planning/phases/51-public-facade-eyebrow-output-evidence/check_eyebrow_renderer_outputs.py` | `4a3723091c907d791e1ab63138e0c801142f2d2dd1eaac320382ed8986f3a9f9` |
| `example-images/generate_gallery.py` | `3e40ad73a15042ebee2ce333546bcb479079f269f59491341fff29061a21f4c8` |

## Scope and Lifecycle

The evidence confirms the final eyebrow caps, local-failure semantics,
aggregate-only diagnostics, complete geometry convergence, strict output
contract, and disposable artifact containment at the tested repository state.
All seven eyebrow status rows and the `眉毛` branch remain unpromoted here.
Promotion requires the clean review, ASVS L1 record, complete validation
precondition, and a fresh default checker run in Plan 52-04.
