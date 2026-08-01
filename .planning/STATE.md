---
gsd_state_version: 1.0
milestone: v1.14
milestone_name: Local Facial Retouch
current_phase: 54
current_phase_name: Rights-Approved Evidence and Eligibility Decisions
status: verifying
stopped_at: Completed 54-05-PLAN.md
last_updated: "2026-08-01T13:35:26.739Z"
last_activity: 2026-07-31
last_activity_desc: Phase 54 execution started
progress:
  total_phases: 2
  completed_phases: 2
  total_plans: 11
  completed_plans: 11
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-07-30)

**Core value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.
**Current focus:** Phase 54 — Rights-Approved Evidence and Eligibility Decisions

## Current Position

Phase: 54 (Rights-Approved Evidence and Eligibility Decisions) — EXECUTING
Plan: 5 of 5
Status: Phase complete — ready for verification
Last activity: 2026-07-31 — Phase 54 execution started

Progress: [██████████] 100%

## Performance Metrics

**Current milestone:**

- Total plans completed: 12
- Average duration: 18.3 min
- Total execution time: 1h 50min

| Phase | Plans | Total | Avg/Plan |
| --- | ---: | --- | --- |
| 53-58 | 6 | 1h 50min | 18.3 min |
| 53 | 6 | - | - |

Historical milestone metrics remain in `.planning/MILESTONES.md` and archived roadmaps.
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 53 P01 | 19 min | 3 tasks | 8 files |
| Phase 53 P02 | 19 min | 2 tasks | 9 files |
| Phase 53 P03 | 9min | 1 tasks | 8 files |
| Phase 53 P04 | 49min | 1 tasks | 13 files |
| Phase 53 P05 | 7 min | 1 tasks | 9 files |
| Phase 53 P06 | 7 min | 1 tasks | 12 files |
| Phase 54 P01 | 10min | 2 tasks | 3 files |
| Phase 54 P02 | 12min | 2 tasks | 3 files |
| Phase 54 P03 | 17min | 2 tasks | 3 files |
| Phase 54 P04 | 9min | 2 tasks | 7 files |
| Phase 54 P05 | 75 min | 1 tasks | 4 files |

## Accumulated Context

### Decisions

Decisions are logged in `.planning/PROJECT.md`. Current roadmap constraints:

- Teeth and sclera are independent peer slices; neither borrows evidence or blocks the other.
- `去脂` is acquisition-first and conditional. A closed evidence/design gate adds no field, provider, renderer case, or inert route and keeps `眼睛` partial.
- Every admitted effect uses one canonical opaque still image, at most one selected-face Vision request, request-local private support, and one original-pixel composition owner.
- Transparent input and all realtime/pixel-buffer, UI, cloud, external-model, tracked-media, device/commercial/performance-budget/packaging/release claims remain outside v1.14.
- [Phase 53]: Canonical still rejection reuses invalidInput and unsupportedPixelFormat — The existing payload-free cases express the two stable caller actions without leaking decoded image facts.
- [Phase 53]: Canonicalization reuses one explicit-sRGB context while pixels remain request-owned — Context reuse avoids repeated setup without caching or sharing portrait pixels across requests.
- [Phase 53]: Extend existing Detection observations in place for actual lip support; add no second Vision request, mapper, target, or proxy. — The existing selected-face mapping boundary already owns the request-local provenance required by D-17.
- [Phase 53]: Preflight outer and inner lips independently at 1...32 finite closed-unit points before one mapping pass. — Region-local rejection preserves valid sibling support and the selected face.
- [Phase 53]: Expose only aggregate outer/inner lip counts; raw support remains package-only, immutable, non-Codable, and request-local. — This mitigates T-53-04 without adding public or SPI geometry.
- [Phase 53]: Keep production local-retouch admission exact-empty; opaque positive Testing demand collapses to one shared canonical request. — Phase 54 evidence gates must admit features independently, while Phase 53 proves routing without a candidate surface.
- [Phase 53]: Own canonical pixels and selected mapped support in one stack-local non-Codable request context. — Request-local ownership prevents stale or crossed portrait support and keeps diagnostics aggregate-only.
- [Phase 53]: Keep pixel-buffer and reset paths structurally free of the local still-image foundation. — v1.14 is still-image-only and cannot broaden realtime behavior.
- [Phase 53]: Admitted rendering accepts the canonical carrier itself; the legacy CIImage overload remains the exact-empty production route. — Keeps one-raster ownership explicit without changing inactive callers.
- [Phase 53]: Admitted geometry rasterization uses explicit sRGB while inactive device-RGB behavior remains compatibility-locked. — Prevents a second device-dependent color interpretation on the canonical route.
- [Phase 53]: Testing exposes only aggregate carrier-identity and sRGB booleans; raw identities, bytes, and support remain private. — Proves the HIGH mitigations without expanding diagnostics.
- [Phase 53]: Phase 55 retains original-pixel composition, mask ownership, and overlap failure semantics. — Phase 53 finishes transport only and must not absorb composition architecture.
- [Phase 53]: Production local-retouch admission remains exact-empty after Phase 53 validation.
- [Phase 53]: Preset source SHA-256 values join exact IDs and decoded inventory as the compatibility lock.
- [Phase 53]: The live checker classifies dependency, network, model, persistence, public/SPI/Codable, color-route, realtime, and candidate boundaries fail-closed.
- [Phase 53]: Three same-engine concurrency/cancellation rows remain flagged under TD-013 rather than promoted into passed claims.

### Pending Todos

- Plan Phase 54 from its six mapped requirements and evidence-first success criteria.
- Begin rights-approved feature-specific fixture acquisition early; promotion remains blocked until Phase 54 records the relevant passing gate.

### Blockers/Concerns

- Teeth still lacks a genuine discoloration positive and complete independent positive/negative bundle.
- Sclera still lacks a genuine redness positive and complete independent positive/negative bundle.
- `去脂` lacks both genuine upper-eyelid-fullness evidence and an approved credible non-warp design; absence is the required result if either remains missing.
- TD-013 public generic-result sendability remains an open API decision outside this milestone and must not be silently absorbed by local-retouch work.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| v1.15 | Approved local semantic masking and `发际线` | Future | v1.14 roadmap |
| v1.16 | `去双下巴`, `去双下巴 Pro`, and narrow taxonomy closeout | Future | v1.14 roadmap |
| Separate evidence | UI, realtime/pixel-buffer, transparent/HDR, model/cloud, device/commercial/performance/packaging/release work | Out of v1.14 | v1.14 roadmap |
| Repository debt | TD-013 concurrency decision and formal stale-codebase-map refresh | Deferred | Existing PLANS.md ledger |

## Session Continuity

Last session: 2026-08-01T13:35:26.732Z
Stopped at: Completed 54-05-PLAN.md
Resume file: .planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-VERIFICATION.md
