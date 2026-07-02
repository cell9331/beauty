# Phase 24: Renderer Output Regression Hardening - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-07-02
**Phase:** 24-Renderer Output Regression Hardening
**Areas discussed:** Renderer Matrix Source, No-op Tolerance, Visible Output Checks, Geometry Status Guard

---

## Renderer Matrix Source

### Source of Truth

| Option | Description | Selected |
|--------|-------------|----------|
| Code-owned | Keep the current `BeautyExampleRenderer` case list canonical, and require docs/evidence/tests to verify and mirror it. | yes |
| Shared manifest | Extract a manifest used by renderer and tests, reducing drift but adding more implementation churn. | |
| Doc-owned table | Make the Markdown matrix authoritative, and require renderer code to match it during verification. | |

**User's choice:** Code-owned.
**Notes:** The user initially selected all options; after clarification they selected `Code-owned` as the primary authority.

### Drift Guard

| Option | Description | Selected |
|--------|-------------|----------|
| Static case inventory check | Add or record a focused test or scan that expects the current 9 case IDs and fails if cases are added/removed without updating docs/evidence. | yes |
| Runtime generated matrix | Have the renderer print/export its case matrix for evidence, then docs quote that generated list. | |
| Manual evidence only | Keep the code-owned list but just document the current 9 cases in planning artifacts. | |

**User's choice:** Static case inventory check.
**Notes:** The check should preserve the code-owned case list without introducing a new manifest unless planning finds one necessary.

### Documentation Location

| Option | Description | Selected |
|--------|-------------|----------|
| Existing renderer doc + phase evidence | Keep `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` as the durable matrix, and add Phase 24 evidence/results under the phase directory. | yes |
| Phase artifact only | Document the matrix only in Phase 24 planning/evidence, leaving existing blueprint docs unchanged. | |
| Root contract too | Also summarize the renderer matrix in a root doc like `QUALITY_SCORE.md`, increasing visibility but adding another place that can drift. | |

**User's choice:** Existing renderer doc plus phase evidence.
**Notes:** Keep the durable matrix close to the renderer validation contract.

### Case Expansion

| Option | Description | Selected |
|--------|-------------|----------|
| No new cases by default | Keep the current 9 visible skin/color/filter cases; any added case must be justified as current behavior coverage, not new feature scope. | yes |
| Add default/no-op case only | Add a no-op renderer case for output evidence, but no new visible effect cases. | |
| Allow small case expansion | Add any low-risk current public parameter cases the planner thinks improve coverage. | |

**User's choice:** No new cases by default.
**Notes:** Phase 24 protects the current matrix rather than broadening visible-output coverage.

---

## No-op Tolerance

### No-op Path

| Option | Description | Selected |
|--------|-------------|----------|
| Facade output before watermark | Test `BeautyEngine.processResult(image:metadata:parameters:)` with default parameters against fixtures before any renderer watermark is drawn. | yes |
| Renderer PNG output after watermark | Compare written PNGs, but the watermark intentionally changes pixels and complicates tolerance. | |
| Both paths | Stronger evidence, but more moving parts and more risk of brittle image checks. | |

**User's choice:** Facade output before watermark.
**Notes:** This isolates no-op processing from renderer watermark side effects.

### Pixel Tolerance

| Option | Description | Selected |
|--------|-------------|----------|
| Exact pixels where deterministic | For the current CIImage no-op path, expect rendered pixels to match exactly; allow only a documented fallback tolerance if platform color-management noise appears. | yes |
| Small fixed tolerance | Always allow a tiny per-channel delta, reducing flake risk but weakening the no-op contract. | |
| Dimension-only plus checksum note | Avoid pixel comparison, but this would not satisfy the existing no-op evidence bar well. | |

**User's choice:** Exact pixels where deterministic.
**Notes:** Fallback tolerance requires a specific documented platform color-management reason.

### Fixture Coverage

| Option | Description | Selected |
|--------|-------------|----------|
| All current fixtures | Cover `example-images/input/e1.png` through `e5.png`, since the renderer matrix already treats all five as the baseline set. | yes |
| One representative fixture | Cheaper and less brittle, but narrower regression coverage. | |
| Synthetic test image only | Very deterministic, but does not prove the example-image validation path. | |

**User's choice:** All current fixtures.
**Notes:** The no-op check should align with the existing example-image fixture set.

### Failure Classification

| Option | Description | Selected |
|--------|-------------|----------|
| Hard fail for deterministic drift | Exact no-op pixel drift fails unless the plan records a specific platform color-management reason and switches to the documented fallback tolerance. | yes |
| Evidence warning first | Record drift as an evidence warning in Phase 24, then decide later whether to fail. | |
| Planner decides per case | Leave failure classification to implementation planning. | |

**User's choice:** Hard fail for deterministic drift.
**Notes:** This keeps no-op behavior as a regression gate, not just a report.

---

## Visible Output Checks

### Automatic Checks

| Option | Description | Selected |
|--------|-------------|----------|
| Mechanical invariants + change signal | Automatically verify files exist, are non-empty, match input dimensions, and differ from input for visible cases. | yes |
| Mechanical invariants only | Verify existence/non-empty/dimensions, leaving visible change to manual notes. | |
| Full image similarity thresholds | Add stronger image-difference thresholds, but likely brittle and easy to overclaim. | |

**User's choice:** Mechanical invariants plus change signal.
**Notes:** This applies to the current 45 generated PNGs.

### Watermark Readability

| Option | Description | Selected |
|--------|-------------|----------|
| Recorded factual inspection | Require a representative inspection note that the bottom watermark is readable and does not cover the face; avoid brittle OCR/pixel heuristics. | yes |
| Automated text/OCR check | Stronger in theory, but heavy and likely brittle for this phase. | |
| Presence by code only | Rely on `drawWatermark(...)` existing and skip output inspection. | |

**User's choice:** Recorded factual inspection.
**Notes:** Phase 24 should not add OCR or fragile visual heuristics.

### Evidence Location

| Option | Description | Selected |
|--------|-------------|----------|
| Phase evidence Markdown only | Keep generated PNGs ignored in `example-images/out/`; record commands, counts, dimensions, change signal, and representative observations in Phase 24 evidence. | yes |
| Commit selected PNGs | Easier future visual comparison, but adds binary artifacts and changes current ignored-output policy. | |
| Store PNGs under `.planning/evidence/v1.4/` but ignored | Keeps local artifacts grouped, but adds another generated-output path. | |

**User's choice:** Phase evidence Markdown only.
**Notes:** Preserve the existing ignored-output policy.

### Visible Wording

| Option | Description | Selected |
|--------|-------------|----------|
| Factual non-quality wording | Say outputs differ visibly/factually for current cases, but do not claim commercial quality, naturalness, release readiness, or Meitu parity. | yes |
| Quality smoke notes | Allow a short human opinion on whether the effect looks acceptable. | |
| No visible wording | Only report computed differences and dimensions. | |

**User's choice:** Factual non-quality wording.
**Notes:** Evidence should avoid subjective quality claims.

---

## Geometry Status Guard

### Geometry Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Guard status only | Preserve `partial`, `blocked-by-geometry-output`, and `future` status with scans/docs; do not attempt geometry output implementation. | yes |
| Add a minimal probe | Add a tiny check proving geometry still lacks saved-output support, but avoid implementation. | |
| Try to unblock geometry output | This would be new capability work and likely exceeds Phase 24 hardening scope. | |

**User's choice:** Guard status only.
**Notes:** No geometry output implementation belongs in Phase 24.

### Protected Statuses

| Option | Description | Selected |
|--------|-------------|----------|
| Current strict status model | Keep `3D塑颜` as `blocked-by-geometry-output`, shaping branches such as `比例/脸型/眼睛/嘴唇/鼻子` as `partial`, and `眉毛`/unpromoted branches as `future` unless real facade output exists. | yes |
| Only protect blocked/future | Focus on preventing overclaim for clearly unavailable branches; leave partial wording looser. | |
| Planner decides from docs | Let the planner infer exact rows from blueprint docs. | |

**User's choice:** Current strict status model.
**Notes:** Protect exact current branch classes.

### Future Evidence Bar

| Option | Description | Selected |
|--------|-------------|----------|
| Facade saved-output evidence | Require public facade detection plus geometry rendering to produce same-dimension, watermarked saved outputs through `BeautyExampleRenderer`. | yes |
| Provider/resolver tests enough | Current provider tests could mark branches implemented, but this conflicts with existing Phase 17/19/20 decisions. | |
| Manual visual judgment enough | A human says it looks right, without public facade output automation. | |

**User's choice:** Facade saved-output evidence.
**Notes:** Provider/resolver evidence alone remains partial for geometry-heavy branches.

### Overclaim Guard

| Option | Description | Selected |
|--------|-------------|----------|
| Static overclaim scans + explicit non-claim text | Scan Phase 24/root/blueprint docs for geometry implemented claims and require explicit non-claim wording in evidence. | yes |
| Manual review only | Rely on human review to catch wording drift. | |
| No extra guard | Existing docs already say this; no Phase 24 check needed. | |

**User's choice:** Static overclaim scans plus explicit non-claim text.
**Notes:** Phase 24 evidence should actively prevent geometry saved-output overclaims.

---

## the agent's Discretion

- Exact test/helper names.
- Exact scan commands.
- Exact image-difference implementation.
- Evidence artifact filenames.
- Representative images for factual watermark inspection.

## Deferred Ideas

- Geometry saved-image output implementation.
- New renderer cases unless justified as existing-behavior coverage.
- Committed PNG baselines.
- OCR watermark checks.
- Broader visual-diff infrastructure.
- Commercial visual quality, production naturalness, release readiness, all-device parity, and Meitu parity claims.
