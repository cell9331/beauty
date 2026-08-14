# Roadmap: Beauty

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
- ✅ **[v1.15 Independent Teeth and Sclera Retouch](milestones/v1.15-ROADMAP.md)** — Phases 59-65, 51 plans and 97 tasks completed and audited 2026-08-11; internal SDK milestone only, with no distribution/shipping/launch claim.

## Current Direction

No milestone is active. The next work is intentionally split into two sequential
SDK-only milestones so repository/API cleanup does not become entangled with a
new Metal implementation.

### Planned v1.16 — SDK-Only Foundation and CPU Reference

**Goal:** Remove executable UI/Demo ownership from the active source tree, make
SwiftPM the sole build/test boundary, repair the public concurrency contract,
and freeze the current CPU algorithms as the reference implementation for later
backend parity work. This milestone changes no Metal behavior and adds no GPU
backend API.

| Phase | Name | Outcome |
| --- | --- | --- |
| 66 | Legacy UI/Demo Archive and SDK-Only Boundary | Create verified ZIP archives plus manifests/SHA-256 records for `BeautyDemo/` and legacy UI-reference assets, then remove their original executable/UI files and all active Xcode/simulator verification dependencies. Preserve algorithm taxonomy in SDK-owned docs before removing reference-only UI material. |
| 67 | SwiftPM Consumer and CLI Validation Contract | Prove a clean consumer imports only the `BeautySDK` SPM product; make `BeautyExampleRenderer` the supported command-line input/output harness with deterministic case discovery, explicit output locations, structured aggregate reports, and failing exit status for invalid/missing results. |
| 68 | CPU Algorithm Reference Oracles | Freeze the shipped CPU behavior with small synthetic fixtures, exact no-op/outside-region/alpha assertions, feature-specific geometry/color metrics, deterministic repeatability checks, and optional rights-approved portrait gates. Generated full-size output remains ignored and reproducible rather than a committed binary baseline. |
| 69 | Public Concurrency Repair and SDK-Only Closeout | Replace unconditional `BeautyResult<Output>: @unchecked Sendable` with a source-compatible conditional contract, add compile-time/runtime coverage, rewrite active quality/debt owners around SDK-only verification, and close with the full no-skip SwiftPM suite. |

**v1.16 exclusions:** Metal implementation, GPU selection, SwiftUI/Xcode Demo,
simulator/UI automation, physical-device testing, commercial visual approval,
packaging, shipping, and new beauty features.

### Queued v1.17 — Dual CPU/GPU Metal Rendering

**Goal:** Add a production Metal renderer without deleting or weakening the CPU
implementation. Both backends consume the same normalized parameters, effect
plan, observed support, control points, masks, and ownership rules; only render
execution changes.

| Phase | Name | Outcome |
| --- | --- | --- |
| 70 | Backend-Neutral Render Contract and Metal Runtime | Extract an internal render request/result contract, preserve the v1.16 CPU implementation as the reference backend, and add bounded `MTLDevice`, command-queue, shader-library, pipeline-cache, texture, and command-buffer ownership with typed failures. No public GPU option is exposed while coverage is incomplete. |
| 71 | Metal Color and Skin-Effect Passes | Implement current pixel-buffer/still-image color and skin-effect execution on Metal with explicit color-space, format, alpha, extent, allocation, and no-op behavior, while retaining the CPU path unchanged. |
| 72 | Metal Geometry Warp Pass | Replace the placeholder copy shader with control-point-driven inverse mapping, bounded ROI dispatch, bilinear sampling, coordinate/edge protection, and the existing face/eye/eyebrow/nose/mouth semantics. CPU geometry remains executable and owns the reference oracle. |
| 73 | Metal Local-Retouch Composition | Move accepted teeth/sclera color composition to Metal without moving Vision/support discovery or relaxing request-local masks, original-pixel reads, post-filter hard containment, per-unit failure isolation, or collision-to-source behavior. CPU composition remains available. |
| 74 | Public Backend Switch and Cross-Backend Closeout | Add `BeautyConfiguration.renderBackend: BeautyRenderBackend` with public `.cpu` and `.gpu` choices, default/missing-key `.cpu` compatibility, explicit `.metalUnavailable` failure for requested unavailable GPU, `BeautyExampleRenderer --backend cpu|gpu` plus comparison reports, and full cross-backend acceptance. No silent CPU fallback is permitted for an explicitly selected `.gpu` engine. |

`BeautyRenderBackend` is execution policy, not a beauty strength, so it belongs
to `BeautyConfiguration` rather than the 61-field `BeautyParameters` model or
preset JSON. Apple Vision detection and request-local support construction may
remain CPU work; `.gpu` means effect rendering/composition executes through
Metal. Backend parity requires exact no-op, alpha, extent, containment,
outside-region, collision-to-source, and failure-isolation behavior. Affected
pixel values use explicit per-pass tolerances where floating-point Metal math
cannot be byte-identical, while direction, locality, monotonicity, and protected
region safety remain exact semantic gates.

After v1.17, algorithm breadth such as `去脂`, approved semantic
masking/hairline, and double-chin work remains separate. Those features still
require credible algorithms and qualified evidence; neither CPU/GPU parity nor
the presence of a Metal backend authorizes proxy implementations.
