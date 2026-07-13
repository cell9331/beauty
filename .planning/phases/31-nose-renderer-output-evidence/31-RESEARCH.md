# Phase 31 Research

**Researched:** 2026-07-13
**Confidence:** HIGH

## Findings

- The existing public-facade renderer has 23 cases and seven fixtures; five locked nose cases produce the required 196 outputs.
- Phase 29's standard-library helper is the authoritative PNG decode/dimension/watermark-exclusion pattern and can be reused without modifying historical evidence.
- `BeautyParameters` and `BeautyEffectResolver` already preserve signed `noseTipSize`; `NoseWarpProvider` alone folds direction through `abs(...)` and must be fixed.
- Gallery grouping and ignore policy already provide safe generated-artifact containment.
- No dependency, public API, Demo UI, network/cloud, or commercial change is needed.

## Validation Architecture

Run focused provider and renderer inventory tests, build/run `BeautyExampleRenderer`, validate 196/196 outputs and 30/30 nose comparisons plus 6/6 signed-tip comparisons, generate 196 ignored gallery files, and prove zero tracked generated files.

## Risks

- Watermark-only differences: exclude the bottom watermark band.
- Signed-output spoofing: compare positive and negative tip outputs directly.
- Historical evidence drift: leave Phase 29 helper and counts intact; add Phase 31-owned evidence.
