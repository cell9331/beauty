# Requirements: Beauty v1.17

**Defined:** 2026-08-15
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.17 Requirements

### Backend Contract and Configuration

- [x] **BACKEND-01**: SDK execution uses one backend-neutral request/result contract so CPU and Metal share canonical input normalization, support discovery, privacy, alpha, extent, containment, collision-to-source, and failure-isolation semantics.
- [x] **BACKEND-02**: The existing CPU implementation remains a complete selectable reference backend and backend choice is execution policy, not a `BeautyParameters` field, preset value, or new beauty algorithm.
- [ ] **CONFIG-01**: Public `BeautyConfiguration.renderBackend` exposes exactly `.cpu` and `.gpu`, preserves source/Codable compatibility, and decodes defaults or missing legacy keys as `.cpu`.
- [ ] **CONFIG-02**: An explicitly requested GPU fails with typed `.metalUnavailable` when Metal cannot execute, and no unavailable GPU request silently falls back to CPU or reports success.

### Metal Rendering Pipeline

- [x] **METAL-01**: The SDK owns bounded Metal device, command-queue, texture, synchronization, and resource-lifetime handling with deterministic cleanup and no host/UI lifecycle dependency.
- [x] **METAL-02**: Metal color/skin rendering preserves the CPU feature semantics, named color/alpha metadata, finite bounded math, and untouched pixels outside eligible regions.
- [ ] **METAL-03**: Metal geometry-warp rendering preserves existing CPU direction, cap, extent, protected-region, collision, and no-face degradation semantics for the shipped geometry families.
- [ ] **METAL-04**: Metal local-retouch composition preserves request-local mask ownership, immutable-original composition, protected-region bytes, alpha behavior, and per-unit failure isolation for the shipped still-image retouch families.

### CPU/GPU Parity and Validation

- [ ] **PARITY-01**: Generated SwiftPM fixtures compare CPU and GPU outputs through explicit structural checks and bounded floating-point tolerances, with exact neutral bytes and dimensions where the contract requires them.
- [ ] **PARITY-02**: CPU/GPU parity checks cover alpha, color metadata, extent, outside-region preservation, containment, collision-to-source behavior, no-face/degraded requests, and failure-unit isolation without exposing raw masks, landmarks, or pixels in durable reports.
- [ ] **PARITY-03**: Repeated identical requests are deterministic and finite for each available backend, backend selection is request-local and concurrency-safe, and a failed GPU unit does not suppress eligible CPU or face-agnostic siblings.

### SDK-Only Closeout

- [ ] **CLOSE-01**: The mandatory SwiftPM/SDK-owned gate executes CPU reference tests, backend/configuration compatibility tests, Metal available/unavailable paths, parity probes, and static scope checks with zero failures and zero unexpected skips; unavailable-host coverage is explicit and cannot lend success to GPU parity.
- [ ] **CLOSE-02**: Architecture, design, security, reliability, product, quality, plans, project, requirements, roadmap, and state owners consistently describe retained CPU plus selectable GPU semantics while excluding UI/Demo, simulator/device, commercial, packaging, shipping, and release-readiness claims.

## Future Requirements

### Later GPU Expansion

- **GPU-FUTURE-01**: Additional Metal feature families or new beauty parameters are added only through a separately scoped milestone with independent CPU reference and parity evidence.
- **GPU-FUTURE-02**: Device-specific performance budgets, thermal/long-run evidence, binary packaging, distribution, commercial visual approval, and release readiness are evaluated in a dedicated product/release milestone.

## Out of Scope

| Feature | Reason |
| --- | --- |
| SwiftUI screens, Demo behavior, Xcode app targets, simulator automation, or physical-device testing | The active product is the SDK/algorithm package; legacy UI/Demo remains archive-only. |
| New beauty parameters, presets, semantic-mask features, `去脂`, hairline, double-chin, or unrelated algorithm breadth | v1.17 changes render backends for the shipped feature set; new algorithm scope needs separate evidence and requirements. |
| Network/cloud processing, third-party beauty SDKs, remote models, or unapproved assets | Violates the local-first and resource-trust boundaries. |
| Tracked portrait media, raw masks/landmarks/pixels, or durable private fixture locators | Mandatory validation uses generated Swift fixtures and aggregate-only diagnostics. |
| Device/commercial/performance-budget, packaging, distribution, shipping, launch, or release-readiness claims | These require separate product and hardware evidence and are not implied by SDK-host Metal tests. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| BACKEND-01 | Phase 70 | Complete |
| BACKEND-02 | Phase 70 | Complete |
| CONFIG-01 | Phase 73 | Pending |
| CONFIG-02 | Phase 73 | Pending |
| METAL-01 | Phase 71 | Complete |
| METAL-02 | Phase 72 | Complete |
| METAL-03 | Phase 72 | Pending |
| METAL-04 | Phase 72 | Pending |
| PARITY-01 | Phase 74 | Pending |
| PARITY-02 | Phase 74 | Pending |
| PARITY-03 | Phase 74 | Pending |
| CLOSE-01 | Phase 74 | Pending |
| CLOSE-02 | Phase 74 | Pending |

### Phase 71 Completion Evidence

`METAL-01` is complete through the exact Phase-71 plan chain `71-01-PLAN.md`,
`71-02-PLAN.md`, `71-03-PLAN.md`, and `71-04-PLAN.md`. The final aggregate
evidence is archive-first: `check-metal-runtime.sh --self-test` and live
preflight pass with focused `26` tests, `0` failures, `0` skips,
`metal_available=1`, and `metal_unavailable=0`; the post-archive SDK-only
boundary and no-skip wrapper self-test pass; and
`run-no-skip-swiftpm.sh` completes `728` tests with `0` failures, `0` skips,
and all eight documented opt-ins executed exactly once. Runtime cleanup and
terminal-error behavior are represented only by bounded aggregate status in
the package-owned checks.

This completion records package-only runtime mechanics and does not claim a
public `.gpu` selector, feature-pass parity, a new algorithm, UI/Demo
lifecycle, simulator or physical-device validation, performance, commercial
approval, packaging, shipping, launch, or release readiness. Phase 72 owns
Metal feature passes; Phase 73 owns public `.cpu`/`.gpu` configuration and
typed availability policy; Phase 74 owns parity and SDK-only closeout.

**Coverage:**

- v1.17 requirements: 13 total
- Mapped to phases: 13
- Unmapped: 0
- Duplicate mappings: 0
- Coverage: 100%

---
*Requirements defined: 2026-08-15*
*Last updated: 2026-08-16 after Phase 71 METAL-01 runtime closeout and exact requirement traceability*
