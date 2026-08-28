# Phase 90 Plan Check

**Phase:** Face Contour and Chin Repairs
**Plans verified:** 4
**Status:** VERIFICATION PASSED
**Revision gate:** iteration 3 of 3
**Issues:** 0 blockers, 0 warnings

## Goal-backward verdict

The Phase 90 plan set is executable after the Plan 90-01 evidence-driven
replan. Plan 90-02 is already complete. Revised Plan 90-01 retains the valid
generated RED, repairs only the provider-local contour field, proves the exact
frozen Phase 89 contract in the Effects target, and uses a fixture-aligned
public-facade corroboration without making production position-dependent.

The dedicated typed checker wrote its initial iteration-3 blockers but its
retry was unavailable because of a platform usage limit. A focused,
code-grounded oracle auditor then reviewed each correction against the actual
comparator, provider, CPU warp, SPI fixture topology, and test helpers. The
final fallback verdict is PASS.

## Execution-time disconfirmation and resolution

The retained generated oracle reported:

- source and neutral signed continuity margin `12 < 16`;
- frozen sibling margins `faceSmall = 16` and `faceSlim = 3 < 16`;
- outside signal `2724/284565 > 500/1500`;
- central-anatomy signal `909/138177 > 128/512`;
- target floors passed and background/watermark remained byte-exact.

Independent audit confirmed these failures were not caused by coordinate
orientation, PPM rasterization, target/complement math, RGB tolerance, metric
sign, or neutral handling. It also separated the frozen sibling set
(`faceSmall`, `faceSlim`) from the Phase 90 strengthening comparisons
(`faceVShape`, `jawSlim`, repaired `chinTaper`).

The revised implementation path removes the actual causes:

- face-relative outer-30%-width contiguous runs supply original-adjacency
  anchors while outer-20%-width corridors own emissions and influence;
- endpoints, contour-global horizontal extrema, central transitions, and
  out-of-corridor anchors do not emit;
- branch-local raw deltas are centered once across the combined bilateral set
  and use one representable scale, with separate left/right/whole roughness
  guards;
- radii use the exact `min(0.015 * width, 0.8 * minimumEdgeDistance)` rule,
  remain finite and `0 < radius < 0.04`, and preserve strict source/target
  corridor containment without changing sibling validators;
- Task 1 remains the exact Phase 89 ROI/threshold authority, while Task 2 uses
  a predeclared `.usableFace`-aligned envelope as public-route corroboration.

## Coverage summary

| Requirement | Plans | Executable evidence | Status |
| --- | --- | --- | --- |
| FACE-01 | 90-01, 90-03, 90-04 | Retained RED, exact generated Effects oracle, provider topology/boundary matrix, fixture-aligned public pixels, lifecycle and owner gates | COVERED |
| FACE-02 | 90-02, 90-03, 90-04 | Executed provider, exact generated/public pixels, sibling distinction, lifecycle and owner gates | COVERED |

## Dimension results

| Dimension | Result |
| --- | --- |
| Requirement Coverage | PASS — FACE-01 and FACE-02 have semantic, locality, protection, distinction, degradation, and public evidence |
| Task Completeness | PASS — branch ranges, anchors, emissions, extrema, containment, scale, radii, roughness sets, and failure rules are explicit |
| Dependency Correctness | PASS — completed 90-02 and revised 90-01 converge before serialized owner updates |
| Key Links Planned | PASS — face-relative provider output reaches the existing CPU and `.usableFace` public route |
| Scope Sanity | PASS — production change remains in one provider; no API, backend, shader, renderer, model, data, or UI expansion |
| Verification Derivation | PASS — frozen exact proof and public-route corroboration are explicitly separated |
| Context Compliance | PASS — 62/5/75, exact caps, request-local ownership, privacy, Phase 91/95, and nonrelease boundaries remain intact |
| Cross-Plan Data Contracts | PASS — Plan 90-02 evidence is preserved and both summaries feed Plans 90-03/04 |
| AGENTS.md Compliance | PASS — generated/in-memory evidence is primary and no private portrait detail persists |
| Pattern Compliance | PASS — provider-local named emissions, unified CPU warp, field-local degradation, and owner documents follow existing analogs |

## Structured issues

```yaml
issues: []
```

## Recommendation

Revised Plan 90-01 may resume from its retained RED. Plans 90-03 and 90-04
remain blocked until both Wave 1 summaries exist.
