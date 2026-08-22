---
phase: 76
slug: per-eye-semantic-support-ownership
status: validated
nyquist_compliant: true
wave_0_complete: true
requirements: [SUP-01, SUP-02]
---

# Phase 76 validation: per-eye semantic support ownership

Phase 76 proves the package-internal, request-local support boundary only. It
does not add a public field, preset, renderer case, resource, provider route,
SPI, or genuine efficacy claim. The Phase-75 rights-approved evidence bundle is
still absent; this phase therefore preserves typed source-exact no-op behavior.

## Task ownership

| Task | Evidence command | Pass rule |
| --- | --- | --- |
| 76-01-01 | `swift build --package-path BeautySDK` | Package-only request, approval, outcome, and resolution types compile with no conversion or persistence surface. |
| 76-01-02 | `swift test --package-path BeautySDK --filter BeautyDetectionTests.UpperEyelidSemanticSupportTests` | 10 deterministic adversarial tests pass; each rejection is typed source-exact no-op and peer isolation remains intact. |
| 76-02-01 | `swift test --package-path BeautySDK --filter 'BeautyDetectionTests.StillImageRequestSupportTests\|BeautyDetectionTests.VisionFaceDetectorTests\|BeautyDetectionTests.UpperEyelidSemanticSupportTests\|BeautyEffectsTests.BeautyUpperEyelidSupportCompositionTests'` | One provider call and one owner call are asserted; selected observation identity is reused; accepted/rejected eye output and overlap source bytes are asserted. |
| 76-02-02 | `python3 check_phase76_support_boundaries.py --self-test --repo-root .` and `python3 check_phase76_support_boundaries.py --live --repo-root .` | Eight isolated mutations are rejected and the live compatibility/privacy/route inventory passes. |

## Threat ownership

| Threat | Guard and pass rule |
| --- | --- |
| T-76-01 | Shared-observation reuse: the route contains exactly one existing `detect(...)` call and selects `observations.first`. |
| T-76-02 | Side coupling: `[left, right]` resolution and independent per-eye no-op assertions reject peer suppression or authorization. |
| T-76-03 | Semantic approval bypass: `approval.approved` and provider-owned `.approved` reason are mandatory. |
| T-76-04 | Typed no-op fallback: every rejected path returns `.sourceExactNoOp`, and the composition oracle emits no proposal for that eye. |
| T-76-05 | Finite/containment bypass: confidence, finite envelope, hard containment, bounds, uniqueness, and duplicate-pixel mutations fail the checker/tests. |
| T-76-06 | Orientation/mirror duplication: existing `CoordinateMapper` tests cover `.up/.down/.left/.right` with input mirroring; the semantic owner has no conversion API. |
| T-76-07 | Overlap-to-source: two per-eye proposals at one pixel produce immutable source bytes and `collisionPixelCount == 1`. |
| T-76-08 | Privacy leakage: diagnostics expose aggregate counts/status only; no raw point, coordinate, mask, pixel, path, or fixture output is persisted. |

## Verification record

- Focused support/detection/composition suite: 52 tests executed, 0 failures; 3 pre-existing Apple Vision integration tests remained environment-skipped by their opt-in gate.
- `UpperEyelidSemanticSupportTests`: 10 tests executed, 0 failures.
- `VisionFaceDetectorTests`: 31 tests executed, 0 failures; the two Phase-76 route tests assert one provider invocation, one owner invocation, selected observation identity, and one-side malformed mapping isolation.
- `BeautyUpperEyelidSupportCompositionTests`: 2 tests executed, 0 failures; assertions cover source bytes, unchanged rejected-region bytes, alpha, width/height, metadata, changed-pixel count, and overlap collision count.
- Mutation gate: T-76-01 through T-76-08 each rejected; no mutation output contains a path or private fixture locator.
- Compatibility gate: exact 61 public parameter fields/coding keys, 5 presets, and 74 renderer cases remain unchanged; no public upper-eyelid-fullness activation exists.
- Full closeout command: `bash scripts/run-no-skip-swiftpm.sh` is required before phase completion and must remain archive-first, zero-skip, zero-failure, and nonzero-test.

Device testing, commercial quality, genuine efficacy/naturalness, packaging, and
release readiness remain out of scope.

## Validation Audit 2026-08-22

| Metric | Count |
| --- | ---: |
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |

SUP-01 and SUP-02 both have focused source/output, mutation, compatibility,
privacy, and archive-first automated owners. No manual-only phase behavior is
used for completion.
