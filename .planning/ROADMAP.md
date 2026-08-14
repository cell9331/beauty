# Roadmap: Beauty

## Overview

v1.16 turns the repository into an SDK/algorithm-only project: legacy Demo and
UI material is preserved in verified archives and removed from the active tree,
SwiftPM plus the SDK-owned command-line renderer becomes the sole supported
validation boundary, current CPU behavior is frozen as a deterministic
reference, and the public generic sendability debt is repaired. Metal and GPU
backend work remain queued for v1.17 and are not executable v1.16 scope.

## Milestones

- ✅ **v1.0 MVP** — Phases 1-7, completed 2026-06-23.
- ✅ **v1.1 Meitu UI** — Phases 8-10, completed 2026-06-24.
- ✅ **v1.2 HTML Reference Fidelity** — Phase 11 completed and Phases 12-15 canceled, 2026-06-26.
- ✅ **v1.3 Meitu Core Beauty Module Design and Implementation** — Phases 16-20, completed 2026-06-30.
- ✅ **v1.4 Stability, QA, and Debt Cleanup** — Phases 21-25, completed 2026-07-03.
- ✅ **v1.5 SDK Geometry Output Foundation and Face Shape Slice** — Phases 26-28, completed 2026-07-08.
- ✅ **[v1.6 Broader `美型 / 五官` SDK Slice - Eyes](milestones/v1.6-ROADMAP.md)** — Phases 29-30, completed 2026-07-13.
- ✅ **[v1.7 Broader `美型 / 五官` SDK Slice - Nose](milestones/v1.7-ROADMAP.md)** — Phases 31-32, completed 2026-07-13.
- ✅ **[v1.8 Broader `美型 / 五官` SDK Slice - Mouth](milestones/v1.8-ROADMAP.md)** — Phases 33-34, completed 2026-07-13.
- ✅ **[v1.9 Nose Remaining Tools and Branch Closeout](milestones/v1.9-ROADMAP.md)** — Phases 35-37, completed 2026-07-14.
- ✅ **[v1.10 Mouth Remaining Geometry Controls](milestones/v1.10-ROADMAP.md)** — Phases 38-40, completed 2026-07-14.
- ✅ **[v1.11 Eye Remaining Geometry Controls](milestones/v1.11-ROADMAP.md)** — Phases 41-44, completed 2026-07-19.
- ✅ **[v1.12 Face Shape Remaining Capabilities](milestones/v1.12-ROADMAP.md)** — Phases 45-48, completed 2026-07-24.
- ✅ **[v1.13 Eyebrow Geometry Controls](milestones/v1.13-ROADMAP.md)** — Phases 49-52, completed 2026-07-28.
- ✅ **[v1.14 Local Facial Retouch](milestones/v1.14-ROADMAP.md)** — Phases 53-58, completed 2026-08-05.
- ✅ **[v1.15 Independent Teeth and Sclera Retouch](milestones/v1.15-ROADMAP.md)** — Phases 59-65, completed and audited 2026-08-11.
- 🚧 **v1.16 SDK-Only Foundation and CPU Reference** — Phases 66-69, Phases 66-67 complete; Phase 68 active.
- 📋 **v1.17 Dual CPU/GPU Metal Rendering** — queued future milestone; not part of the executable v1.16 phase list.

## 🚧 v1.16 SDK-Only Foundation and CPU Reference

**Milestone Goal:** Establish an SDK-only repository and validation boundary,
freeze the CPU implementation as a trustworthy reference, and repair public
generic sendability without adding Metal or GPU behavior.

## Phases

**Phase numbering:** v1.16 continues the historical sequence at Phase 66.

- [x] **Phase 66: Legacy UI/Demo Archive and SDK-Only Boundary** — Preserve the legacy application material as verified archives, then leave only SDK-owned active build and validation surfaces. (completed 2026-08-14)
- [x] **Phase 67: SwiftPM Consumer and CLI Validation Contract** — Prove public-product consumption and make the SDK renderer a deterministic input/output validation interface. (completed 2026-08-14)
- [ ] **Phase 68: CPU Algorithm Reference Oracles** — Freeze current CPU behavior with generated fixtures and exact, feature-specific safety oracles.
- [ ] **Phase 69: Public Concurrency Repair and SDK-Only Closeout** — Correct generic sendability and close the milestone through one hardened SwiftPM-only gate.

## Phase Details

### Phase 66: Legacy UI/Demo Archive and SDK-Only Boundary

**Goal**: Maintainers have a verified historical copy of the legacy UI/Demo while the active repository exposes only SDK-owned build, test, documentation, and command-line validation surfaces.
**Depends on**: Phase 65 (v1.15 complete)
**Requirements**: BOUNDARY-01, BOUNDARY-02, ARCHIVE-01, ARCHIVE-02, ARCHIVE-03
**Success Criteria** (what must be TRUE):

  1. A maintainer can inspect each retained ZIP's explicit scope, deterministic listing manifest, and SHA-256 record, then independently extract it and reproduce listing/content-hash agreement.
  2. SDK integrators can find the supported effect taxonomy and algorithm-relevant legacy knowledge in an SDK-owned text authority without depending on visual layout or application behavior.
  3. A clean checkout contains no active original Demo executable, SwiftUI source, Xcode application project, or selected legacy UI-reference tree after archive verification succeeds.
  4. Every active build, test, documentation, and planning command resolves to SwiftPM products, targets, tests, or SDK-owned command-line validation; repository scans find no remaining Xcode, simulator, device, or deleted-tree dependency.

**Plans**: 3/3 complete; independently verified 6/6 must-haves on 2026-08-14

### Phase 67: SwiftPM Consumer and CLI Validation Contract

**Goal**: SDK integrators can validate public `BeautySDK` consumption and deterministic processing entirely through SwiftPM and the SDK-owned command line.
**Depends on**: Phase 66
**Requirements**: SPM-01, SPM-02, CLI-01, CLI-02, CLI-03
**Success Criteria** (what must be TRUE):

  1. A clean external Swift package can depend on the local `BeautySDK` package, import only the public product, and build without `@testable`, Demo, Xcode-project, or internal-target access.
  2. The clean consumer can generate a synthetic image, submit a neutral request through the public facade, and verify successful dimension-preserving output.
  3. A maintainer can list the exact renderer cases and run an explicit input/case/supported-CPU-backend selection into an explicit output directory with reproducible results.
  4. Each CLI run produces a machine-readable aggregate report that identifies requested, succeeded, failed, skipped, input, output, and case identities without exposing private landmark or mask data.
  5. Invalid inputs, unknown cases, decode/write failures, and missing requested outputs produce typed diagnostics and a non-zero exit, while successful generated outputs stay in an ignored/reproducible location.

**Plans**: 4/4 complete; independently verified 5/5 must-haves on 2026-08-14

### Phase 68: CPU Algorithm Reference Oracles

**Goal**: Maintainers can detect any semantic or safety regression in the current CPU implementation without tracked portrait media or a GPU implementation.
**Depends on**: Phase 67
**Requirements**: CPU-01, CPU-02, CPU-03, CPU-04, CPU-05
**Success Criteria** (what must be TRUE):

  1. The mandatory suite creates small Swift RGBA fixtures for opaque colors, alpha boundaries, required transparent rejection, geometry patterns, protected/outside regions, and deterministic landmark/support stubs.
  2. CPU reference tests verify exact neutral bytes, dimensions, color metadata, alpha behavior, outside-region preservation, local-retouch containment, collision-to-source behavior, and per-unit failure isolation.
  3. Each feature family is judged by explicit direction/displacement/locality or color/luminance/chroma/red-excess metrics that retain its public semantics and safety caps, rather than by a generic “output changed” assertion.
  4. Repeating identical CPU requests yields deterministic, finite, bounded results independent of earlier requests, and a failed face-dependent unit does not suppress eligible siblings or face-agnostic work.
  5. The mandatory clean-clone suite passes entirely from generated Swift fixtures with zero skips; rights-approved portrait and native-Vision fixtures remain optional, private, and explicitly gated.

**Plans**: 4 plans

Plans:
- [ ] 68-01-PLAN.md — Add generated in-memory CPU fixture and metric foundations.
- [ ] 68-02-PLAN.md — Freeze geometry and color feature-family semantics with explicit metrics.
- [ ] 68-03-PLAN.md — Freeze local-retouch safety, composition, determinism, and failure isolation.
- [ ] 68-04-PLAN.md — Wire generated-only preflight, optional-fixture separation, and owner closeout.

### Phase 69: Public Concurrency Repair and SDK-Only Closeout

**Goal**: SDK integrators receive an honest generic concurrency contract, and maintainers can close v1.16 with one no-skip SDK-only verification boundary.
**Depends on**: Phase 68
**Requirements**: CONC-01, CONC-02, CLOSE-01, CLOSE-02
**Success Criteria** (what must be TRUE):

  1. An integrator can move `BeautyResult` across a concurrency boundary when its output is `Sendable`, while compile-time coverage proves a non-sendable payload does not gain false `Sendable` conformance.
  2. Existing source use of `BeautyResult` continues to compile, and runtime concurrency coverage confirms sendable outputs preserve their result data safely.
  3. Active architecture, design, reliability, security, product, quality, plans, project, requirements, roadmap, and state owners consistently describe an SDK-only v1.16 with no Metal/GPU, UI, simulator/device, commercial, packaging, shipping, or release-readiness claim.
  4. A maintainer can run the hardened SwiftPM gate with all mandatory tests executed, zero failures, and zero skips; static checks reject restored Demo/UI source, generated binaries, stale Xcode commands, unconditional generic sendability, and Metal scope drift.

**Plans**: TBD

## Coverage

| Phase | Requirement Count | Requirement IDs |
| --- | ---: | --- |
| 66 | 5 | BOUNDARY-01, BOUNDARY-02, ARCHIVE-01, ARCHIVE-02, ARCHIVE-03 |
| 67 | 5 | SPM-01, SPM-02, CLI-01, CLI-02, CLI-03 |
| 68 | 5 | CPU-01, CPU-02, CPU-03, CPU-04, CPU-05 |
| 69 | 4 | CONC-01, CONC-02, CLOSE-01, CLOSE-02 |

**Coverage:** 19/19 v1.16 requirements mapped exactly once; no orphaned or duplicate mappings.

## Queued Future Direction: v1.17 (Not Executable in This Roadmap)

v1.17 preserves the v1.16 CPU implementation as a permanent reference backend
and adds a backend-neutral request/result boundary plus production Metal render
execution. Only after complete GPU coverage may the public API add
`BeautyConfiguration.renderBackend: BeautyRenderBackend` with `.cpu` and `.gpu`.
Default construction and legacy/missing-key decoding remain `.cpu`; an explicitly
requested unavailable `.gpu` fails as `.metalUnavailable` and never silently
falls back. Backend choice remains execution policy, not a `BeautyParameters`
field or preset value. Vision/support discovery and request-local ownership rules
remain shared, and no v1.17 Metal source or API is authorized by v1.16.

## Progress

**Execution Order:** Phase 66 → Phase 67 → Phase 68 → Phase 69

| Phase | Milestone | Plans Complete | Status | Completed |
| --- | --- | --- | --- | --- |
| 66. Legacy UI/Demo Archive and SDK-Only Boundary | v1.16 | 3/3 | Completed | 2026-08-14 |
| 67. SwiftPM Consumer and CLI Validation Contract | v1.16 | 4/4 | Completed | 2026-08-14 |
| 68. CPU Algorithm Reference Oracles | v1.16 | 0/4 | Planned | - |
| 69. Public Concurrency Repair and SDK-Only Closeout | v1.16 | 0/TBD | Not started | - |
