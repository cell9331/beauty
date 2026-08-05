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
