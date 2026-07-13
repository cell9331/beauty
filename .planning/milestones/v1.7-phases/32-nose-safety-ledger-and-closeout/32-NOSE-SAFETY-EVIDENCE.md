# Phase 32 Nose Safety Evidence

**Observed:** 2026-07-13
**Verdict:** Passed

## Runtime Evidence

- Required focused suites passed: `BeautyParametersTests` 8, `BeautyEffectResolverTests` 14, `NoseWarpProviderTests` 7, `MissingLandmarkDegradationTests` 14, `CombinedEffectSafetyTests` 8, `BeautyEngineGeometryFacadeTests` 10, and `BeautyRendererOutputRegressionTests` 8.
- Full `swift test --package-path BeautySDK` passed 186 tests with zero failures.
- `BeautyExampleRenderer` built and ran 28 cases across seven fixtures.
- `check_nose_renderer_outputs.py` passed 196/196 outputs, 30/30 portrait comparisons, 6/6 positive-vs-negative tip comparisons, and representative no-face output.
- Gallery generation wrote 196 ignored files.

## Contract Evidence

- Positive-only exact caps: `noseSlim=0.35`, `noseWingSlim=0.35`, `noseBridge=0.30`; signed `noseTipSize=±0.30`.
- Missing and stale geometry skip nose and zero all four strengths; reused geometry retains every field at exact `0.5`, including negative tip direction.
- No-face preserves extent and continues color/filter domains.
- Combined face/eye/mouth geometry weakens every nose field while preserving sign.

## Boundary and Ledger Evidence

- Fail-closed scans found no raw public geometry, forbidden internal import, network/cloud path, commercial execution path, sign-loss call, dependency drift, new public field, or tracked generated artifact.
- The public inventory remains 31 fields; generated roots contain zero tracked files.
- Exactly `大小`, `鼻翼`, `鼻梁`, and `鼻尖` are implemented. `山根` remains partial without borrowed `noseBridge` evidence; `提升` remains future; branch-level `鼻子` remains partial.

## Non-Claims

No Demo UI, device parity, commercial visual approval, broad Meitu parity, packaging readiness, launch readiness, or whole-branch completion is claimed.
