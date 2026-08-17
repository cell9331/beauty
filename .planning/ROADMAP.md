# Roadmap: Beauty

## Overview

v1.17 keeps the verified CPU renderer as a permanent reference while adding
one backend-neutral SDK execution boundary and a bounded, SDK-owned Metal
renderer for the shipped color/skin, geometry, and still-image local-retouch
families. Public backend policy arrives only after GPU coverage is complete:
`BeautyConfiguration.renderBackend` exposes `.cpu` and `.gpu`, defaults and
legacy/missing-key decoding stay on `.cpu`, and an explicitly unavailable GPU
fails as typed `.metalUnavailable` without silently falling back. Generated
SwiftPM parity, safety, determinism, and no-skip gates close the milestone.

This milestone is SDK/algorithm and Metal-pipeline work only. It does not add
application or Demo behavior, Xcode targets, simulator or physical-device
validation, new beauty algorithms or parameters, model/network behavior,
commercial approval, packaging, shipping, launch, or release-readiness claims.

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
- ✅ **[v1.16 SDK-Only Foundation and CPU Reference](milestones/v1.16-ROADMAP.md)** — Phases 66-69, independently complete 2026-08-15.
- 🚧 **v1.17 Dual CPU/GPU Metal Rendering** — Phases 70-74, current milestone.

## Current Milestone: v1.17 Dual CPU/GPU Metal Rendering

**Milestone Goal:** Integrators can select a stable CPU or Metal execution
policy for the existing SDK feature set while both backends preserve one
canonical request/result contract and parity is demonstrated through generated
SDK-owned evidence.

**Phase numbering:** v1.17 continues the historical sequence at Phase 70.

## Phases

- [x] **Phase 70: Backend-Neutral Contract and CPU Reference** — Establish one shared request/result boundary and keep CPU selectable as the permanent reference. (completed 2026-08-16)
- [x] **Phase 71: SDK-Owned Metal Runtime** — Add bounded Metal device, queue, texture, synchronization, and resource-lifetime ownership. (completed 2026-08-16)
- [x] **Phase 72: Metal Feature Passes** — Implement color/skin, geometry-warp, and local-retouch passes with the existing CPU semantics and safety rules. (completed 2026-08-17)
- [ ] **Phase 73: Public Backend Configuration and Fail-Closed Availability** — Expose `.cpu`/`.gpu` policy with CPU-compatible defaults and typed unavailable-GPU failure.
- [ ] **Phase 74: CPU/GPU Parity and SDK-Only Closeout** — Prove structural parity, safety, determinism, failure isolation, and the mandatory no-skip scope gate.

## Phase Details

### Phase 70: Backend-Neutral Contract and CPU Reference

**Goal**: SDK execution has one backend-neutral request/result boundary, while
the existing CPU implementation remains a complete, selectable, deterministic
reference for the shipped feature set.
**Depends on**: Phase 69 (v1.16 complete)
**Requirements**: BACKEND-01, BACKEND-02
**Success Criteria** (what must be TRUE):

  1. A request entering either backend uses the same canonical input
     normalization, support discovery, privacy, alpha, extent, containment,
     collision-to-source, and per-unit failure-isolation contract.

  2. An integrator can select CPU execution and receive the existing reference
     behavior, including exact neutral/protected bytes and current output
     dimensions and metadata.

  3. Backend choice changes execution policy only: `BeautyParameters`, preset
     values, and the beauty algorithm inventory remain unchanged and backend
     independent.

  4. Request-local support and intermediate data remain transient, with only
     aggregate-safe result/diagnostic values crossing the backend boundary.
**Plans**: 2/2 plans executed

- [x] 70-01-PLAN.md
- [x] 70-02-PLAN.md

### Phase 71: SDK-Owned Metal Runtime

**Goal**: The SDK can own and safely execute bounded Metal work without relying
on an application lifecycle or leaking state across requests.
**Depends on**: Phase 70
**Requirements**: METAL-01
**Success Criteria** (what must be TRUE):

  1. An available GPU request creates and uses SDK-owned device, command queue,
     textures, synchronization, and resources, then returns through the shared
     request/result boundary.

  2. Successful, failed, repeated, and mixed CPU/GPU requests deterministically
     release command and texture resources and leave no prior-request state in
     a later request.

  3. Metal execution remains bounded and finite under malformed or unsupported
     work, with cleanup completed independently of any external host lifecycle.
**Plans**: 4 plans

- [x] 71-01-PLAN.md — Build and test the SDK-owned bounded Metal runtime.
- [x] 71-02-PLAN.md — Connect internal Metal execution to the shared backend boundary.
- [x] 71-03-PLAN.md — Add the mutation-tested Metal preflight and synchronize owners.
- [x] 71-04-PLAN.md — Close METAL-01 with measured gates and planning ledgers.

**Phase 71 completion evidence:** The archive-first runtime gate passes its
mutation self-test and live preflight with focused `26/0/0` execution and
separate `metal_available=1` / `metal_unavailable=0` accounting. The
post-archive SDK-only boundary and no-skip wrapper self-test pass, and the
full `run-no-skip-swiftpm.sh` wrapper executes `728` tests with zero failures,
zero skips, and all eight documented opt-ins exactly once. The evidence is
aggregate-only and establishes package-owned runtime mechanics; it does not
claim public `.gpu` configuration, feature-pass parity, new algorithms,
simulator/physical-device validation, performance, commercial, packaging,
shipping, launch, or release readiness. Phase 72 is next.

### Phase 72: Metal Feature Passes

**Goal**: The Metal backend renders every shipped feature family in scope while
preserving the CPU semantics and existing safety boundaries.
**Depends on**: Phase 71
**Requirements**: METAL-02, METAL-03, METAL-04
**Success Criteria** (what must be TRUE):

  1. Metal color/skin requests preserve CPU feature direction and bounds,
     named color/alpha metadata, finite math, and untouched ineligible pixels.

  2. Metal geometry requests preserve CPU direction, caps, extent,
     protected-region bytes, collision-to-source ownership, and no-face
     degradation for the shipped geometry families.

  3. Metal local-retouch requests preserve request-local mask ownership,
     immutable-original composition, protected bytes, alpha behavior, and
     smallest-unit failure isolation for the shipped still-image families.

  4. GPU coverage adds no new beauty parameter, preset, semantic-mask feature,
     or unrelated algorithm and does not move support discovery out of the
     shared request boundary.
**Plans**: 4 plans

Plans:

- [x] 72-01-PLAN.md — Establish the bounded Metal pass graph and implement color/skin rendering.
- [x] 72-02-PLAN.md — Wire existing unified geometry control points into the Metal warp pass.
- [x] 72-03-PLAN.md — Preserve local-retouch composition ownership and close the feature-pass gate.
- [x] 72-04-GAP-01-PLAN.md — Restore combined saturation/skin-smoothing CPU semantics and close the verified gap.

### Phase 73: Public Backend Configuration and Fail-Closed Availability

**Goal**: Integrators can explicitly choose CPU or GPU execution with
compatibility-safe defaults and an honest failure when the requested GPU cannot
execute.
**Depends on**: Phase 72
**Requirements**: CONFIG-01, CONFIG-02
**Success Criteria** (what must be TRUE):

  1. Public `BeautyConfiguration.renderBackend` exposes exactly `.cpu` and
     `.gpu`, while existing source/Codable use and the beauty-parameter/preset
     schema remain compatible.

  2. New configurations and configurations decoded from missing legacy backend
     keys select `.cpu` deterministically; an explicit `.cpu` remains a
     complete reference path.

  3. An explicitly requested unavailable GPU returns typed
     `.metalUnavailable`, produces no successful GPU result, and never silently
     executes or reports a CPU fallback.
**Plans**: 3 plans

- [ ] 73-01-PLAN.md — Add the public CPU/GPU configuration contract and legacy Codable compatibility tests.
- [ ] 73-02-PLAN.md — Route engine requests through the selected backend and prove typed unavailable-GPU failure.
- [ ] 73-03-PLAN.md — Add the archive-first configuration gate and synchronize SDK owners/ledgers.

### Phase 74: CPU/GPU Parity and SDK-Only Closeout

**Goal**: Generated SDK-owned evidence demonstrates safe, deterministic parity
between available backends and closes the milestone without weakening the CPU
oracle or expanding the active product boundary.
**Depends on**: Phase 73
**Requirements**: PARITY-01, PARITY-02, PARITY-03, CLOSE-01, CLOSE-02
**Success Criteria** (what must be TRUE):

  1. Generated SwiftPM fixtures compare CPU and GPU through explicit structural
     checks and bounded floating-point tolerances, with exact neutral bytes and
     dimensions wherever the shared contract requires them.

  2. Parity checks cover alpha, color metadata, extent, outside-region
     preservation, containment, collision-to-source behavior, no-face and
     degraded requests, and failure-unit isolation without durable raw masks,
     landmarks, or pixels.

  3. Repeated identical requests are finite and deterministic for each
     available backend, backend selection is request-local and concurrency-safe,
     and prior requests cannot alter later outputs.

  4. A failed GPU unit does not suppress an eligible CPU or face-agnostic
     sibling, and unavailable-host coverage is explicit rather than borrowing
     success from GPU parity.

  5. The mandatory SwiftPM/SDK-owned gate runs CPU reference, configuration,
     available/unavailable Metal, parity, and static scope checks with zero
     failures and zero unexpected skips; current owners agree on retained CPU
     plus selectable GPU semantics and all excluded product/release claims.
**Plans**: TBD

## Coverage

| Phase | Requirement Count | Requirement IDs |
| --- | ---: | --- |
| 70 | 2 | BACKEND-01, BACKEND-02 |
| 71 | 1 | METAL-01 |
| 72 | 3 | METAL-02, METAL-03, METAL-04 |
| 73 | 2 | CONFIG-01, CONFIG-02 |
| 74 | 5 | PARITY-01, PARITY-02, PARITY-03, CLOSE-01, CLOSE-02 |

**Coverage:** 13/13 v1.17 requirements mapped exactly once; no orphaned or
duplicate mappings.

## Progress

**Execution Order:** Phase 70 → Phase 71 → Phase 72 → Phase 73 → Phase 74

| Phase | Milestone | Plans Complete | Status | Completed |
| --- | --- | --- | --- | --- |
| 70. Backend-Neutral Contract and CPU Reference | v1.17 | 2/2 | Complete    | 2026-08-15 |
| 71. SDK-Owned Metal Runtime | v1.17 | 4/4 | Complete | 2026-08-16 |
| 72. Metal Feature Passes | v1.17 | 4/4 | Complete    | 2026-08-17 |
| 73. Public Backend Configuration and Fail-Closed Availability | v1.17 | 0/TBD | Not started | - |
| 74. CPU/GPU Parity and SDK-Only Closeout | v1.17 | 0/TBD | Not started | - |
