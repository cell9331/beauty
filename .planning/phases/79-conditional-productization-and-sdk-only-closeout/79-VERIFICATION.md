---
phase: 79-conditional-productization-and-sdk-only-closeout
verified: 2026-08-22T21:50:57+08:00
status: passed
score: 5/5 must-haves verified
decision: mechanics-only-not-promotion
branch: failing-public-absence
---

# Phase 79 Verification Report

## Goal achievement

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | The Phase 78 decision cannot be bypassed. | ✓ VERIFIED | Live checker requires `decision: mechanics-only-not-promotion`; mutation T-79-01 rejects decision replacement. |
| 2 | Exact public absence is preserved. | ✓ VERIFIED | Public source inventory is exactly 61 fields, five presets, and 74 renderer cases; T-79-02 through T-79-04 reject field, renderer, and package drift. |
| 3 | Taxonomy and docs select the failing branch. | ✓ VERIFIED | `去脂` is `future`, `眼睛` is `partial`, public SDK guidance and docs index record the same decision; T-79-05 rejects taxonomy promotion. |
| 4 | Existing image/backend/failure contracts remain intact. | ✓ VERIFIED | CPU authority, `.cpu`/`.gpu`, terminal `.metalUnavailable`, no fallback, alpha/extent/named-sRGB, deterministic request-local anchors and no production diff pass; T-79-06/07/08 reject drift. |
| 5 | SDK-only closeout gates pass. | ✓ VERIFIED | Phase-79 checker self/live pass; archive-first full no-skip is 797/0/0 with zero skips and all opt-ins once. |

**Score:** 5/5 must-haves verified

## Requirement disposition

- `SAFE-03`: complete on the existing SDK-owned canonical metadata, alpha,
  determinism, request-local failure, CPU/GPU, and typed-unavailable gates.
- `COMPAT-01`: complete with exact 61/5/74 absence.
- `COMPAT-02`: failing branch selected; no 62/5/75 promotion is authorized or
  materialized.
- `BACKEND-01`: complete on the existing CPU-reference and selected-GPU/
  typed-unavailable closeout evidence.
- `PROMOTE-01`: complete for the failed branch; exact absence follows the
  single aggregate decision.
- `DOCS-01`: complete; root contracts, PLANS, quality, public SDK guidance,
  taxonomy, and docs index are synchronized.

## Final nonclaims

v1.18 closes as SDK-only mechanics and compatibility evidence. No genuine
efficacy, naturalness, population coverage, physical-device behavior,
performance, thermal/battery, commercial visual approval, packaging, shipping,
launch, or release-readiness claim is made. No UI/Demo, realtime/video,
transparent-input, HDR/gain-map, new Metal/GPU API, or retained `Warp.metal`
behavior was added.
