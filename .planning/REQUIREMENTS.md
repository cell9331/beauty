# Requirements: Beauty v1.17

**Defined:** 2026-08-15
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## Standing Project Validation Requirements

These requirements apply to all current and future SDK milestones. They are
project policy, not additional historical v1.17 checklist rows, so the 13-item
v1.17 traceability count below remains unchanged.

| ID | Requirement |
| --- | --- |
| PROJECT-VALIDATION-01 | Physical iPhone testing is optional post-SDK user evaluation and must not be a default milestone requirement, dependency, checkpoint, completion gate, or blocker. It becomes mandatory only through an explicit later user decision. |
| PROJECT-VALIDATION-02 | Milestone authority is deterministic SwiftPM coverage plus SDK-owned scripts with nonzero execution, zero failures, zero unexpected skips, and fail-closed handling of malformed or incomplete evidence. |
| PROJECT-VALIDATION-03 | Image-producing behavior is accepted only when automation evaluates real input/output pixels and metadata against the owning contract, including applicable dimensions/extent, orientation/mirroring, color space, alpha, neutral identity, intended-region movement, protected-region preservation, bounded tolerance, determinism, and typed failure. Process success alone is insufficient. |
| PROJECT-VALIDATION-04 | Generated in-memory fixtures are the default repeatable mechanism. An algorithm owner may separately require rights-approved local positive/negative fixtures, but those remain script-driven, private, and distinct from physical-device validation. |
| PROJECT-VALIDATION-05 | User device feedback received after SDK completion is supplemental evidence: actionable findings enter `PLANS.md` and should gain an automated regression where reproducible; absence of that feedback does not stop the current plan or later milestone work. |
| PROJECT-VALIDATION-06 | Without separately authorized hardware/product evidence, automated SDK completion makes no device performance, thermal, battery, endurance, commercial visual-quality, packaging, shipping, launch, or release-readiness claim. This is a nonclaim boundary, not a blocker. |
| PROJECT-VALIDATION-07 | Durable evidence remains aggregate and privacy-safe: do not persist raw inputs/outputs, masks, landmarks, private fixture locators, device photos, or unredacted feedback payloads. |

## Post-Archive Audit Qualification

The checked requirements and traceability table below record the historical
v1.17 lifecycle completed at `afb04b4`. Its Metal-available Phase-74 evidence
was focused `12/0/0` and full `765/0/0`; these counts remain historical. The
current archive-first closeout passed on 2026-08-18 with XCTest `776/0/0`, all
eight opt-ins exactly once, and `skipped_tests=0`.

Post-archive fixes have restored public non-up/mirrored raw metadata
compatibility (`53e8da1`), separated unavailable-host coverage from GPU parity
credit (`d29b90a`), and moved oversized Metal geometry point payloads to a
request-local shared `MTLBuffer` (`556499a`). Only an available branch reports
`focused_tests=13` / `parity_executed=1`; unavailable coverage reports
`parity_executed=0`. Today's available branch recorded `metal_available=1`,
`metal_unavailable=0`, `parity_executed=1`, `focused_tests=13`, and
`unavailable_tests=0`; focused preflights passed `24/0/0`, `42/0/0`, `34/0/0`,
`19/0/0`, and `41/0/0` for backend-neutral, Metal runtime, Metal feature,
configuration, and CPU reference respectively. F-08 result alpha/extent
enforcement is remediated. F-09 geometry-envelope provenance now derives from
one immutable observation with mutation-tested request ownership (`a577dd1`).
F-02/F-04/F-05/F-10 now have approved bounded dispositions: CPU-owned local-
retouch composition with identity Metal transport, exact-opaque bounded RGB GPU
input with named-sRGB output, CPU-oracle still-image math within the pinned
generated tolerance, and caller-serialized access to each intentionally non-
`Sendable` engine. These do not add transparent-input support, end-to-end GPU
local-retouch ownership, or shared-instance parallel safety.
Accordingly, `[x]` means historically completed plan
traceability, not current broad CPU/GPU equivalence or release readiness.

## v1.17 Requirements

### Backend Contract and Configuration

- [x] **BACKEND-01**: SDK execution uses one backend-neutral request/result contract so CPU and Metal share canonical input normalization, support discovery, privacy, alpha, extent, containment, collision-to-source, and failure-isolation semantics.
- [x] **BACKEND-02**: The existing CPU implementation remains a complete selectable reference backend and backend choice is execution policy, not a `BeautyParameters` field, preset value, or new beauty algorithm.
- [x] **CONFIG-01**: Public `BeautyConfiguration.renderBackend` exposes exactly `.cpu` and `.gpu`, preserves source/Codable compatibility, and decodes defaults or missing legacy keys as `.cpu`.
- [x] **CONFIG-02**: An explicitly requested GPU fails with typed `.metalUnavailable` when Metal cannot execute, and no unavailable GPU request silently falls back to CPU or reports success.

### Metal Rendering Pipeline

- [x] **METAL-01**: The SDK owns bounded Metal device, command-queue, texture, synchronization, and resource-lifetime handling with deterministic cleanup and no host/UI lifecycle dependency.
- [x] **METAL-02**: Metal color/skin rendering preserves the CPU feature semantics, named color/alpha metadata, finite bounded math, and untouched pixels outside eligible regions.
- [x] **METAL-03**: Metal geometry-warp rendering preserves existing CPU direction, cap, extent, protected-region, collision, and no-face degradation semantics for the shipped geometry families.
- [x] **METAL-04**: Metal local-retouch composition preserves request-local mask ownership, immutable-original composition, protected-region bytes, alpha behavior, and per-unit failure isolation for the shipped still-image retouch families.

### CPU/GPU Parity and Validation

- [x] **PARITY-01**: Generated SwiftPM fixtures compare CPU and GPU outputs through explicit structural checks and bounded floating-point tolerances, with exact neutral bytes and dimensions where the contract requires them.
- [x] **PARITY-02**: CPU/GPU parity checks cover alpha, color metadata, extent, outside-region preservation, containment, collision-to-source behavior, no-face/degraded requests, and failure-unit isolation without exposing raw masks, landmarks, or pixels in durable reports.
- [x] **PARITY-03**: Repeated identical requests are deterministic and finite for each available backend, backend selection is request-local and concurrency-safe, and a failed GPU unit does not suppress eligible CPU or face-agnostic siblings.

### SDK-Only Closeout

- [x] **CLOSE-01**: The mandatory SwiftPM/SDK-owned gate executes CPU reference tests, backend/configuration compatibility tests, Metal available/unavailable paths, parity probes, and static scope checks with zero failures and zero unexpected skips; unavailable-host coverage is explicit and cannot lend success to GPU parity.
- [x] **CLOSE-02**: Architecture, design, security, reliability, product, quality, plans, project, requirements, roadmap, and state owners consistently describe retained CPU plus selectable GPU semantics while excluding UI/Demo, simulator/device, commercial, packaging, shipping, and release-readiness claims.

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

## Historical v1.17 Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| BACKEND-01 | Phase 70 | Complete |
| BACKEND-02 | Phase 70 | Complete |
| CONFIG-01 | Phase 73 | Complete |
| CONFIG-02 | Phase 73 | Complete |
| METAL-01 | Phase 71 | Complete |
| METAL-02 | Phase 72 | Complete |
| METAL-03 | Phase 72 | Complete |
| METAL-04 | Phase 72 | Complete |
| PARITY-01 | Phase 74 | Complete |
| PARITY-02 | Phase 74 | Complete |
| PARITY-03 | Phase 74 | Complete |
| CLOSE-01 | Phase 74 | Complete |
| CLOSE-02 | Phase 74 | Complete |

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
*Last updated: 2026-08-19 with standing project validation requirements; historical Phase-74 traceability retained with current-gap qualification*
