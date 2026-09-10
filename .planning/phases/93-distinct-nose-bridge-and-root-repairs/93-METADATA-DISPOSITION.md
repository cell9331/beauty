# Phase 93 metadata checkpoint: proposed disposition

Status: implemented; independent amendment review passed with zero blockers/warnings. Fresh runtime prerequisites remain pending.

AGENTS.md gives code/tests priority over PLANS.md. Correcting an authored test
expectation to the explicitly retained raw-image contract is within the existing
D-04/D-06 scope; it does not require extending D-09 or changing production policy.

## Observed conflict

Plan 93-02 requires named-sRGB output for nose-only raw-image requests. The
retained contract in DESIGN.md and BeautyGeometryEffectPipeline explicitly uses
Device RGB for this legacy route. Named sRGB belongs to the canonical-carrier
route. Changing that shared rendering policy is excluded by CONTEXT D-06/D-09.

Registration and integer metrics each passed 4/0/0. The first lifecycle method
failed only its named-sRGB assertion (24 assertions); the other three lifecycle
methods and both semantic methods have not run. This is a test/plan contract
mismatch, not a demonstrated nose efficacy failure. The original failed test,
summary, and append-only ledger sequence 15 remain historical evidence.

## Selected bounded change

1. Correct the checked plan and public test to assert the existing route-specific
   color contract: source/neutral/abstaining inputs retain named sRGB; emitted
   raw-image geometry uses the exact Device RGB color space. Require explicit
   RGB model, component count, and color-space identity, not arbitrary RGB or nil.
   All scored bytes still use the same explicit named-sRGB extraction.
2. Preserve every fixture, integer metric, ROI, signal/protection threshold,
   sibling comparison, alpha/extent/orientation/recovery assertion, production
   source, and renderer policy. Do not activate a different route to obtain sRGB.
3. Independently review a narrowly bound gate/plan amendment before resuming.
   Existing baseline, registration binding and failed ledger bytes must remain
   unchanged. Any continuation admission must identify this exact pre-semantic
   metadata-test mismatch; no general failure waiver or stale receipt admission
   is allowed. Fresh lifecycle and semantic evidence is required afterward.
4. Keep the already opened attempt 1 and the overall two-attempt ceiling. Do not
   reissue begin 1, reset the budget, grant a third candidate, or reinterpret the
   historical failed run as passing. No RED binding or efficacy credit exists yet.

The test change is being prepared as an unapplied patch for review. The parent
will implement a hash-linked admission amendment for this exact test-contract
correction and obtain independent review before resuming. This is not a generic
exception to failures or a new substantive effect candidate. No later plan may
start without its unchanged prerequisites.

## Current retained state

The D-09 root correction is committed and registration passes. The provider is
unchanged. One begin and zero finish events exist. Plans 93-03 through 93-05 have
not run, and both NOSE requirements remain active. Pre-existing configuration,
state and runtime changes are preserved.
