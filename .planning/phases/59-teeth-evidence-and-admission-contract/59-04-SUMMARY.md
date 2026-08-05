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
already-light comparison fixture `portrait_001`. The run produced disposable
local before/mask/after images and retained only these aggregate findings:

| Fixture / path | Strong mask | Changed pixels | Outside computed mask | Finding |
| --- | ---: | ---: | ---: | --- |
| `portrait_002` / fixed | 545 | 4,570 | 0 | Detects central yellow teeth; limited coverage |
| `portrait_002` / adaptive | 11,149 | 15,179 | 0 | Expands coverage, but visual overlay includes the upper-lip rim |
| `portrait_001` / fixed | 9,320 | 9,938 | 0 | Over-whitens an already-light comparison fixture |
| `portrait_001` / adaptive | 13,709 | 15,245 | 0 | Further over-whitening; adaptive lip-boundary concern remains |

`outside computed mask == 0` only proves composition stayed inside the
algorithm's own mask; it does not prove that the mask is anatomically teeth-
only. The local review therefore found a Phase 60 safety issue: protected-lip
ownership and already-light negative no-op behavior need to be addressed before
any production teeth provider or output claim. The AI candidate remains
mechanics-only and the authorized comparison remains a mechanics negative
candidate until a feature-specific manifest and frozen review decide otherwise.
