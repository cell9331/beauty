---
phase: 59
plan: 04
status: passed-with-external-blocker
---

# Plan 59-04 Summary

Closed the Phase 59 validation, security, and owner records without promoting
the feature. The closed branch is valid and exact; the v1.15 milestone is not
complete because the genuine teeth evidence gate remains unsatisfied. Phases
60–65 must not start production work until the Phase 59 open branch is
independently established.

Final verification:

- Full SwiftPM: 553 executed, 0 failed, 6 documented Vision skips.
- Focused SDK selection: 135 passed, 0 failed.
- Demo build: succeeded on iPhone 17e / iOS 26.5.
- Full Demo test: 121 passed, 0 failed, 0 skipped.
- Phase 59 contract: 5/5 Node tests.
- Boundary checker: 19 mutation cases and all 8/8 HIGH modes green.
- JSON validation and `git diff --check`: passed.

No real portrait bundle, output, effectiveness, naturalness, device,
performance, commercial, packaging, shipping, or release claim is made.

## Additional Mechanics Smoke Run

The existing shared Swift harness was rebuilt and run against the local
candidate `portrait_002` with `teeth-compare`, then against the authorized
already-light comparison fixture `portrait_001`. The first run reproduced an
upper-rim expansion and over-whitening. The harness was then tightened locally:
the adaptive envelope now has a 5% upper safety inset and 10% lower extension,
and whitening requires material yellow excess with neutral/light no-op tests.
The final run produced disposable local before/mask/after images and retained
only these aggregate findings:

| Fixture / path | Strong mask | Changed pixels | Outside computed mask | Finding |
| --- | ---: | ---: | ---: | --- |
| `portrait_002` / fixed | 545 | 4,478 | 0 | Detects central yellow teeth; limited coverage |
| `portrait_002` / adaptive | 9,814 | 12,416 | 0 | Expands coverage after the upper safety inset; yellow teeth visibly improve |
| `portrait_001` / fixed | 9,320 | 3,935 | 0 | Already-light comparison is substantially closer to no-op |
| `portrait_001` / adaptive | 13,453 | 7,043 | 0 | Preserves coverage with low mean luminance delta (0.00239) |

`outside computed mask == 0` only proves composition stayed inside the
algorithm's own mask; it does not prove that the mask is anatomically teeth-
only. The local rerun no longer showed the prior isolated upper-lip expansion,
and the already-light comparison is visually near no-op, but protected-lip
ownership and true negative behavior still require Phase 60 safety work and
licensed original-detail review before any production teeth provider or output
claim. The AI candidate remains mechanics-only and the authorized comparison
remains a mechanics negative candidate until a feature-specific manifest and
frozen review decide otherwise.

## Post-close Real Teeth Bundle Intake

The user subsequently supplied two authorized local portraits: one declared as
the genuine discolored-teeth positive and one as the genuine already-light
negative. The ignored bundle under
`example-images/local-retouch-review/teeth-evidence-20260805/` contains a
complete original/mask/after triple for each fixture. Pure manifest validation
reports `valid=true`, `productEvidenceReady=true`, two approved fixtures, one
positive, one negative, and zero missing assets.

The mechanics rerun against the new bundle reports:

| Fixture / path | Strong mask | Changed pixels | Mean luminance delta | Outside computed mask |
| --- | ---: | ---: | ---: | ---: |
| `teeth_fixture_001` / adaptive positive | 4,793 | 5,421 | 0.00969 | 0 |
| `teeth_fixture_002` / adaptive negative | 4,712 | 1,983 | 0.00133 | 0 |

The offline reviewer page could not be opened in the current browser because
its local `file://` URL is blocked by browser policy; no local server or upload
workaround was used. A human frozen-criteria blinded review is therefore still
pending, and the canonical Phase 59 decision remains closed.

## Submitted Review Export Rejected by Frozen Predicate

The user supplied `teeth_evidence_20260805-review.json`. It is valid as a
Spike 006 sanitized export, but it is not the Phase 54 durable export shape:
it contains `dataset_id`, `generated_at`, and `events`. Its two `accept`/
`none` judgments also fail the frozen predicate: the positive has insufficient
mask coverage and insufficient naturalness, while the already-light negative
has a target-state mismatch and insufficient naturalness. The export was not
passed to the Phase 54 serializer, the canonical ledger was not edited, and
the production boundary remains closed. A fresh review must use the Phase 54
reviewer and record judgments that match the observed images.

## Human Visual Feedback: Positive Effect Insufficient

The user subsequently confirmed that the yellow-teeth positive does not look
visibly whiter, although the computed mask appears correctly contained. This
matches the small positive-run mean luminance delta of `0.00969`: the current
problem is the conservative color transform, not the mask boundary. The
positive therefore cannot pass product evidence. The next mechanics task is to
calibrate the transform against this exact positive while preserving the
already-light negative near-no-op and zero outside-mask changes; no production
or Phase 60 admission is authorized by this feedback.

## Calibrated Candidate Rerun

The shared harness now keeps the material-yellow threshold at `0.08` so lightly
warm enamel remains a no-op, but shortens the upper transition and increases
the bounded blue/yellow correction plus luminance target. Its 24/24 self-tests
pass, including a new material-yellow-excess reduction check. Re-running the
same authorized bundle yielded:

| Fixture / path | Changed pixels | Mean luminance delta | Texture energy ratio | Outside computed mask |
| --- | ---: | ---: | ---: | ---: |
| `teeth_fixture_001` / adaptive positive | 5,523 | 0.01678 | 1.03269 | 0 |
| `teeth_fixture_002` / adaptive negative | 2,087 | 0.00334 | 0.97609 | 0 |

The positive after image has been refreshed in the ignored local bundle for a
new human comparison. The negative remains bounded but is not automatically
accepted; the replacement review must still determine whether its visible
change is suitably near no-op.
