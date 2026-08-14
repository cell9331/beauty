# Requirements: Beauty v1.16

**Defined:** 2026-08-14
**Core Value:** An iOS app can integrate `BeautySDK` and get natural, controllable, real-time and still-image beauty processing through a stable modular facade.

## v1.16 Requirements

### SDK-Only Repository Boundary

- [x] **BOUNDARY-01**: The active repository contract names SwiftPM products, targets, tests, and SDK-owned command-line validation as the only supported build/test surface; no active requirement depends on SwiftUI, an Xcode application target, simulator automation, or physical-device execution.
- [x] **BOUNDARY-02**: Before removal, the supported effect taxonomy and any algorithm-relevant knowledge that exists only in legacy UI/Demo material is preserved in an SDK-owned text authority without treating visual layout or application behavior as an SDK requirement.
- [x] **ARCHIVE-01**: `BeautyDemo/` and the selected legacy UI-reference tree are preserved as ZIP artifacts whose scope is explicit and whose manifests exclude transient files such as build products, caches, `.DS_Store`, and per-user Xcode state.
- [x] **ARCHIVE-02**: Each retained archive has a deterministic listing manifest and SHA-256 record, and an automated verification step proves listing agreement, successful extraction, and content-hash agreement before original files are removed.
- [x] **ARCHIVE-03**: After verified archive creation, the original Demo/UI executable and reference files are absent from the active tree, and repository scans find no build, test, documentation, or planning dependency that still requires them.

### SwiftPM Consumer and Command-Line Validation

- [ ] **SPM-01**: A clean external Swift package fixture imports and links only the public `BeautySDK` product through a local SwiftPM dependency, with no `@testable` import, Demo source, Xcode project, or internal target dependency.
- [ ] **SPM-02**: The clean consumer executes a minimal neutral request through the public facade and verifies a successful, dimension-preserving result using generated synthetic input.
- [ ] **CLI-01**: `BeautyExampleRenderer` exposes a deterministic SDK-owned command-line validation contract for selecting inputs/cases/backends, choosing an explicit output directory, and discovering the exact cases that ran.
- [ ] **CLI-02**: The command-line harness emits a machine-readable aggregate report containing requested, succeeded, failed, skipped, input, output, and case identity information without leaking private landmark/mask data.
- [ ] **CLI-03**: Missing or invalid inputs, unknown cases, write/decode failures, and incomplete requested output produce typed diagnostics plus a non-zero process exit; successful runs produce reproducible outputs under an ignored/generated location.

### CPU Reference Oracles

- [ ] **CPU-01**: Small generated RGBA fixtures cover opaque color fields, alpha boundaries, transparent rejection where already required, geometric patterns, protected/outside regions, and deterministic landmark/support stubs without requiring tracked portrait media.
- [ ] **CPU-02**: Reference tests lock exact neutral/no-op bytes, dimensions, color-space metadata, alpha behavior, outside-region preservation, local-retouch containment, collision-to-source behavior, and per-unit failure isolation for the current CPU implementation.
- [ ] **CPU-03**: Feature-family oracles use explicit geometry displacement/direction/locality metrics and color/luminance/chroma/red-excess metrics rather than broad "output changed" assertions, while preserving each feature's existing public semantics and safety caps.
- [ ] **CPU-04**: Repeated identical CPU requests are deterministic, finite, bounded, and independent of prior requests; the suite detects state leakage and verifies face-agnostic siblings continue when face-dependent support fails closed.
- [ ] **CPU-05**: Rights-approved portrait and native-Vision fixtures remain optional, private, and explicitly gated; the mandatory clean-clone suite passes solely with generated Swift fixtures and never borrows success from skipped optional tests.

### Concurrency and Closeout

- [ ] **CONC-01**: `BeautyResult<Output>` is `Sendable` only when `Output: Sendable`; the public API no longer relies on unconditional `@unchecked Sendable` for an arbitrary generic payload.
- [ ] **CONC-02**: Compile-time and runtime tests prove sendable outputs cross concurrency boundaries safely while non-sendable payloads do not gain a false conformance, without breaking existing source use of `BeautyResult`.
- [ ] **CLOSE-01**: Active architecture, design, reliability, security, product, quality, plans, project, requirements, roadmap, and state owners agree that the repository is SDK-only and that v1.16 makes no Metal, GPU, UI, simulator/device, commercial, packaging, shipping, or release-readiness claim.
- [ ] **CLOSE-02**: The hardened no-skip SwiftPM gate runs all mandatory tests with zero failures and zero skips, and static repository checks reject restored Demo/UI sources, generated binary output, stale Xcode commands, unconditional generic sendability, or Metal scope drift.

## Future Requirements

### v1.17 Dual CPU/GPU Metal Rendering

- **GPU-F01**: Preserve the v1.16 CPU implementation as a permanent reference backend while adding a backend-neutral render request/result contract and bounded Metal runtime ownership.
- **GPU-F02**: Implement color/skin, geometry warp, and local-retouch composition on Metal without moving Vision/support discovery or weakening color, alpha, extent, containment, collision, or failure-isolation contracts.
- **GPU-F03**: Add `BeautyConfiguration.renderBackend: BeautyRenderBackend` with `.cpu` and `.gpu`, default and missing-key `.cpu` compatibility, and explicit `.metalUnavailable` failure for an unavailable requested GPU; never silently fall back.
- **GPU-F04**: Add CPU/GPU renderer selection and parity reports with exact structural/safety gates and explicit bounded numeric tolerances for floating-point affected pixels.

## Out of Scope

| Feature | Reason |
| --- | --- |
| Metal shaders, GPU runtime, or public backend selection | Reserved in full for v1.17 so the CPU reference is frozen before GPU work begins. |
| SwiftUI screens, Demo behavior, Xcode app builds, simulator automation, or physical-device tests | The project is an SDK/algorithm repository; legacy application material is archived, not developed. |
| New beauty parameters, presets, semantic-mask features, `去脂`, hairline, or double-chin algorithms | v1.16 restructures validation and freezes current behavior; algorithm breadth remains separately scoped. |
| Tracked portrait media or generated output baselines | Mandatory validation uses small generated Swift fixtures; authorized real fixtures and full-size output remain private/ignored gates. |
| Network/cloud behavior, third-party beauty SDKs, or unapproved model assets | These violate the local-first and rights-approved resource boundaries. |
| Commercial visual approval, performance budgets, binary packaging, distribution, shipping, launch, or release readiness | These require separate product/distribution evidence and are not implied by SDK-core test success. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| BOUNDARY-01 | Phase 66 | Complete |
| BOUNDARY-02 | Phase 66 | Complete |
| ARCHIVE-01 | Phase 66 | Complete |
| ARCHIVE-02 | Phase 66 | Complete |
| ARCHIVE-03 | Phase 66 | Complete |
| SPM-01 | Phase 67 | Pending |
| SPM-02 | Phase 67 | Pending |
| CLI-01 | Phase 67 | Pending |
| CLI-02 | Phase 67 | Pending |
| CLI-03 | Phase 67 | Pending |
| CPU-01 | Phase 68 | Pending |
| CPU-02 | Phase 68 | Pending |
| CPU-03 | Phase 68 | Pending |
| CPU-04 | Phase 68 | Pending |
| CPU-05 | Phase 68 | Pending |
| CONC-01 | Phase 69 | Pending |
| CONC-02 | Phase 69 | Pending |
| CLOSE-01 | Phase 69 | Pending |
| CLOSE-02 | Phase 69 | Pending |

**Coverage:**

- v1.16 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0
- Duplicate mappings: 0
- Coverage: 100%

---
*Requirements defined: 2026-08-14*
*Last updated: 2026-08-14 after roadmap creation and exact traceability validation*
