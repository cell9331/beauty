---
gsd_state_version: 1.0
milestone: v1.4
milestone_name: Stability, QA, and Debt Cleanup
status: planning
stopped_at: Phase 21 complete
last_updated: "2026-06-30T08:55:00.000Z"
last_activity: 2026-06-30 — Phase 21 completed; ready for Phase 22 discussion
progress:
  total_phases: 5
  completed_phases: 1
  total_plans: 2
  completed_plans: 2
  percent: 20
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-06-30)

**Core value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.
**Current focus:** v1.4 Stability, QA, and Debt Cleanup

## Current Position

Phase: 22 - Automated Demo QA and Screenshot Evidence
Plan: Not planned yet
Status: Phase 21 complete; ready for Phase 22 discussion/planning
Last activity: 2026-06-30 — Phase 21 completed with `21-BASELINE-AUDIT.md` and `21-VERIFICATION.md`

## Performance Metrics

**Velocity:**

- Total phases completed: 14
- Total plans completed: 57
- Total tasks recorded from summaries: 65
- Milestone Swift LOC at close: about 13,266 across `BeautySDK` and `BeautyDemo`

**By Phase:**

| Phase | Plans | Status |
|-------|-------|--------|
| 1. SDK Foundation and Public Facade | 4/4 | Complete |
| 2. Demo Integration Shell | 3/3 | Complete |
| 3. Realtime and Still Input Slice | 4/4 | Complete |
| 4. Detection and Coordinate Safety | 5/5 | Complete |
| 5. Filters, Presets, and Resource Flow | 4/4 | Complete |
| 6. Core Beauty Effects | 5/5 | Complete |
| 7. Rich Demo QA Surface | 3/3 | Complete |
| 8. Meitu Home Rebuild | 4/4 | Complete |
| 9. Meitu Editor Tool Panel | 4/4 | Complete |
| 10. Home-to-Editor Flow and v1.1 QA | 3/3 | Complete |
| 11. HTML Reference Baselines | 4/4 | Complete |
| 12. HTML-to-SwiftUI Delta Contract | 0/3 | Canceled |
| 13. Home SwiftUI Fidelity Pass | 0/3 | Canceled |
| 14. Editor SwiftUI Fidelity Pass | 0/3 | Canceled |
| 15. v1.2 Visual QA and Closeout | 0/3 | Canceled |
| 16. Example Image Validation Harness | 2/2 | Complete |
| 17. Core Beauty Contracts and Module Boundaries | 2/2 | Complete |
| 18. Skin Retouch Core Modules | 3/3 | Complete |
| 19. Beauty Shaping Core Modules | 5/5 | Complete |
| 20. Core Module Closeout | 2/2 | Complete |
| 21. Baseline Audit and Quality Ledger Refresh | 2/2 | Complete |
| Phase 18 P1 | 8 min | 2 tasks | 2 files |
| Phase 18 P2 | 117 min | 3 tasks | 10 files |
| Phase 18 P3 | 19 min | 3 tasks | 6 files |
| Phase 19 P01 | 12 min | 2 tasks | 1 files |
| Phase 19 P02 | 4 min | 2 tasks | 4 files |
| Phase 19 P03 | 3 min | 2 tasks | 4 files |
| Phase 19 P04 | 3 min | 2 tasks | 5 files |
| Phase 19 P05 | 5 min | 2 tasks | 4 files |
| Phase 20 P01 | 11 min | 2 tasks | 10 files |
| Phase 20 P02 | 14 min | 3 tasks | 7 files |

## Accumulated Context

### Decisions

Full decision context is in `.planning/PROJECT.md`.

Recent milestone-level outcomes:

- Product remains a modular iOS SDK with a rich Demo validation app.
- Demo remains facade-only and local-first.
- v1.0 shipped core SDK/Demo capability and deferred advanced modules to future milestones.
- v1.1 replaced the old SDK-dashboard first screen with a Meitu-style Home and editor panel based on `meituxiuxiu/HOME_MAP.md` and `meituxiuxiu/FUNCTION_MAP.md`.
- v1.1 preserved camera/photo processing, compare/debug/JSON behavior, and facade-only `BeautySDK` integration while keeping unsupported Meitu reference capabilities disabled/static.
- v1.2 retained only the inspectable static HTML references for Home and Editor; the delta report and SwiftUI fidelity passes were canceled on 2026-06-26.
- v1.3 narrows scope to core beauty only: beauty shaping, skin retouch, and minimal editor support. Home/discovery, resource/style systems, AI/background, video/body, and account/gallery are deferred.
- v1.3 should not write new SwiftUI screens; it should prepare, design, encapsulate, implement, and verify SDK-level core beauty modules.
- Direct validation should run code modules against `example-images/input/` and save parameter-labeled, watermarked outputs under ignored `example-images/out/`.
- Phase 16 reran `BeautyExampleRenderer` build/run evidence, confirmed `e2__skinWhitening_0p50.png` dimensions match `example-images/input/e2.png`, and kept generated PNGs out of git.
- Release-readiness visual quality, hardware parity, performance budgets, and long-run reliability remain separate QA scope.
- Phase 18 completed Basic skin retouch work behind existing SDK boundaries: focused Basic skin, resolver, and engine tests passed; all current Basic skin renderer cases wrote ignored local outputs; representative output dimensions, labels, and factual visual observations passed; future skin-retouch branches remain future.
- Phase 19 completed beauty-shaping core-module evidence behind SDK boundaries: branch docs and ownership exist, promoted partial branches have provider/resolver/degradation/cap/redaction XCTest evidence, full `swift test --package-path BeautySDK` passed with 141 tests, final API/UI/renderer/status/redaction scans passed, and geometry-heavy saved-image output remains deferred until public facade detection plus geometry rendering exists.
- Phase 20 completed v1.3 core module closeout: editor-shell support is documented as Demo-owned no-new-UI app-side behavior, full `swift test --package-path BeautySDK` passed with 141 tests, `BeautyExampleRenderer` built and ran all current skin/color/filter cases, 45 ignored renderer outputs were non-empty and same-dimension, no public parameter/import/UI/renderer/status drift was found, and `20-VERIFICATION.md` preserves geometry saved-output and release-hardening limitations.
- v1.4 focuses on stability, QA, performance, security, and technical-debt cleanup. It does not add product-area breadth, public parameter fields, hidden remote-processing behavior, paid-account flows, or broad UI redesign.
- v1.4 uses Phase 21 through Phase 25 and keeps existing `.planning/phases/` history directories in place.
- Phase 21 Plan 21-01 captured the current baseline in `.planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-BASELINE-AUDIT.md`: SDK tests pass with 141 XCTest cases, `BeautyExampleRenderer` builds and writes 45 ignored outputs, boundary/privacy scans pass, and Demo simulator build/test evidence is blocked by the missing local Metal Toolchain.
- Phase 21 Plan 21-02 refreshed `QUALITY_SCORE.md` from the baseline, closed AUD-01 through AUD-04, and routes TD-005 to Phase 25, TD-008 to Phases 22/23 with physical iPhone evidence blocked until hardware exists, TD-009 to Phase 22, and TD-010 across Phases 22/23/24/25.
- `.planning/codebase/*` maps are stale background for v1.4 and should not override current source, root docs, or `.planning` ledgers.

### Pending Todos

- Run `$gsd-discuss-phase 22`.
- Preserve v1.4 boundaries while planning: no new product-feature breadth, no public API expansion by default, no hidden network/cloud behavior, and no broad UI redesign.
- Convert release-hardening candidates into measurable evidence or documented blockers: physical-device camera/Vision parity, production naturalness review, screenshot/UI automation, performance budgets, memory/thermal checks, privacy manifest review, and automated visual diffs.

### Blockers/Concerns

- Current repository has unrelated uncommitted documentation changes outside Phase 21 files; future commits should keep file scopes explicit.
- Deferred v2 `ADV-*` items remain outside v1 traceability and are tracked as `TD-007` in `PLANS.md`.
- Manual release risks are now routed by Phase 21: `TD-008` to Phase 22/23 with physical-device checks blocked until hardware exists, `TD-009` to Phase 22, and `TD-010` across Phases 22/23/24/25.
- `TD-005` remains routed to Phase 25 because no `PrivacyInfo.xcprivacy` exists.
- Local Demo simulator build/test evidence is blocked until the Xcode Metal Toolchain component is installed.
- v1.1 reference screenshots are local analysis inputs, not licensed production assets; implementation should recreate structure and feel without copying commercial assets directly.
- Phase 12-15 cancellation is intentional; do not treat canceled AUDIT, HSWIFT, ESWIFT, or VQA requirements as open blockers.
- Geometry-heavy branches need face detection plus geometry rendering output before they can claim saved example-image visual completion.

## Deferred Items

| Category | Item | Status | Deferred At |
|----------|------|--------|-------------|
| Advanced beauty | Makeup, segmentation, body shaping, stickers, AI style, video export, commercial SDK distribution | Deferred to v2+ | Initialization |
| Release QA | Real-device camera/Vision parity, visual naturalness, production render quality, performance budgets, and long-run hardware readiness | Partially promoted into v1.4 hardening scope; feature expansion remains deferred | v1.4 start |
| SwiftUI visual fidelity | HTML-to-SwiftUI delta report, Home SwiftUI fidelity pass, Editor SwiftUI fidelity pass, and v1.2 visual QA closeout | Canceled from v1.2; may be reconsidered as a future milestone | 2026-06-26 |
| Deferred Meitu product areas | Home/discovery, style resources, AI/background, video/body, account/gallery, search, premium access, commerce, account authorization | Deferred outside v1.3 core beauty modules | 2026-06-26 |
| Codebase maps | Formal refresh of stale `.planning/codebase/*` maps | Deferred until explicitly scoped | Phase 21 |

## Session Continuity

Last session: 2026-06-30T08:55:00.000Z
Stopped at: Phase 21 complete
Resume file: .planning/phases/21-baseline-audit-and-quality-ledger-refresh/21-VERIFICATION.md

## Operator Next Steps

- Run `$gsd-discuss-phase 22` to plan automated Demo QA and screenshot/layout evidence.
