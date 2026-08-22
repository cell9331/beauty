---
gsd_state_version: 1.0
milestone: v1.18
milestone_name: Upper-Eyelid Fullness Reduction
status: planning
last_updated: "2026-08-22T09:40:14+08:00"
last_activity: 2026-08-22
progress:
  total_phases: 5
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-08-22)

**Core value:** An iOS app can integrate `BeautySDK` and get natural,
controllable, real-time and still-image beauty processing through a stable
modular facade.
**Current focus:** v1.18 conditionally evaluates and productizes still-image
upper-eyelid fullness reduction through rights-approved genuine evidence,
per-eye fail-closed support, and original-pixel local composition.

## Current Position

Phase: 75 of 79 (Semantics and Genuine Evidence Contract)
Plan: —
Status: Roadmap approved; ready to discuss and plan Phase 75
Last activity: 2026-08-22 — v1.18 roadmap approved with 18/18 requirements mapped

## v1.18 Roadmap Context

v1.18 is a conditional-productization milestone. It first freezes the cosmetic
semantics and a rights-approved private genuine bundle, then builds independent
per-eye semantic support and a deterministic tone/frequency editor. Phase 78
produces a reproducible pass/fail recommendation under the frozen rubric.
Phase 79 either appends exactly one default-zero field and one renderer case or
proves that the entire public route remains exactly absent.

The starting public compatibility surface is 61 fields, five neutral presets,
and 74 renderer cases. Vision landmarks are geometry envelopes rather than
fullness semantics; optional additive-map work requires independently approved
model/data/redistribution rights and measurable superiority. No phase may use
warp, smoothing, whitening, eye enlargement, brow movement, crease invention,
or upper-eyelid lift as a proxy.

## Current Audit Qualification

v1.17 was historically archived at `afb04b4` with a Metal-available focused
`12/0/0` and full `765/0/0` run. Those numbers and the 5/5 phase, 19/19 plan
progress above are historical lifecycle metrics. The current archive-first
closeout passed XCTest `776/0/0`, all eight opt-ins exactly once, and
`skipped_tests=0`. Public raw metadata compatibility (`53e8da1`), unavailable-host
parity accounting (`d29b90a`), and Metal geometry binding (`556499a`) are
repaired. Only an available branch reports `focused_tests=13` /
`parity_executed=1`; unavailable typed coverage reports `parity_executed=0`.
Today's available branch recorded `metal_available=1`, `metal_unavailable=0`,
`parity_executed=1`, `focused_tests=13`, and `unavailable_tests=0`. Focused
preflights passed backend-neutral `24/0/0`, Metal runtime `42/0/0`, Metal
feature `34/0/0`, configuration `19/0/0`, and CPU reference `41/0/0`.

F-09 is repaired: one immutable `sharedFaceObservation` derives geometry, plan,
control points, locality envelope, and `selectedFaceSupport`; request equality
and two parity-gate mutations fail closed (`a577dd1`).

F-02/F-04/F-05/F-10 are resolved through deliberately narrow contracts: CPU-
owned local-retouch composition and identity Metal transport; exact-opaque
bounded non-extended RGB GPU inputs with named-sRGB output; CPU-oracle Metal
still-image coefficients/lip math; and caller-serialized access to one
intentionally non-`Sendable` engine. Transparent input, end-to-end GPU local-
retouch composition, shared-instance parallel safety, broad device/commercial
equivalence, packaging, shipping, launch, and release readiness remain unclaimed.

## Performance Metrics

**Historical v1.17 milestone:**

- Total plans completed: 19
- Average duration: ~30min
- Total execution time: ~9h

Historical v1.16 metrics remain in `.planning/MILESTONES.md` and archived
roadmaps.
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 70 P01 | 20min | 2 tasks | 9 files |
| Phase 70 P02 | ~40min | 2 tasks | 9 files |
| Phase 71 P01 | ~35min | 2 tasks | 2 files |
| Phase 71 P02 | ~2h25m | 2 tasks | 3 files |
| Phase 71 P03 | 40min | 2 tasks | 11 files |
| Phase 71 P04 | ~15min | 2 tasks | 6 files |
| Phase 72 P01 | 25min | 2 tasks | 8 files |
| Phase 72 P02 | 15 | 2 tasks | 6 files |
| Phase 72 P03 | ~25min | 2 tasks | 13 files |
| Phase 72 P04 | ~20min | 2 tasks | 4 files |
| Phase 73 P01 | ~20min | 2 tasks | 4 files |
| Phase 73 P02 | ~25min | 2 tasks | 5 files |
| Phase 73 P03 | ~15min | 2 tasks | 6 files |
| Phase 73 P04 | ~30min | 2 tasks | 14 files |
| Phase 74 P01 | ~20min | 2 tasks | 3 files |
| Phase 74 P02 | ~20min | 2 tasks | 2 files |
| Phase 74 P03 | ~20min | 2 tasks | 2 files |
| Phase 74 P04 | ~25min | 2 tasks | 4 files |
| Phase 74 P05 | ~15min | 2 tasks | 9 files |

## Accumulated Context

### Decisions

- v1.18 uses conditional productization: all gates passing may produce exactly
  one public field and route; any failure produces verified exact absence and
  keeps the eye taxonomy partial.

- Genuine rights-approved positive/negative evidence and blinded original-
  detail review are mandatory product-feasibility gates. Generated fixtures
  prove deterministic mechanics only.

- The default candidate is deterministic low-frequency tone correction with
  original high-frequency detail carry and original-pixel composition. The
  tested warp remains invalidated; a licensed additive-map model is optional.

- Left and right eyes own support and failure independently from one shared
  Vision observation. Landmarks constrain envelopes but cannot classify
  fullness.

- v1.16 established SDK/algorithm-only ownership, SwiftPM/SDK-owned gates,
  generated CPU reference oracles, and conditional `BeautyResult` sendability.

- v1.17 preserves CPU permanently; backend selection is execution policy outside
  `BeautyParameters` and presets, with `.cpu` as default and legacy fallback.

- Phase 70 owns the shared backend-neutral contract and CPU reference; Phase 71
  owns Metal resources; Phase 72 owns the three shipped Metal pass families.

- Phase 73 owns public `.cpu`/`.gpu` configuration and typed
  `.metalUnavailable`; Phase 74 owns generated parity and closeout evidence.

- No new algorithms, UI/Demo behavior, device evidence, commercial approval,
  packaging, shipping, or release-readiness claim is in this milestone.

- Phase 74 closes PARITY-01/02/03 and CLOSE-01/02 only on generated SDK-owned
  evidence: focused parity `12/0/0`, separate `metal_available=1` and
  `metal_unavailable=0`, and full no-skip `765/0/0` with eight opt-ins exactly
  once and zero skips/failures.

- All SDK milestones use deterministic SwiftPM and SDK-owned image input/output
  oracles as completion authority; a successful command without applicable
  pixel/metadata assertions is insufficient.

- Physical-iPhone testing is optional user evaluation after SDK completion. It
  is not a default gate, dependency, checkpoint, or blocker; reproducible user
  feedback becomes a follow-up regression where possible.

- The lack of physical-device evidence limits device performance, thermal,
  battery, endurance, commercial-quality, packaging, shipping, launch, and
  release claims, but never blocks SDK planning or milestone progression.

- [Phase 70]: Phase 70 Plan 01 freezes a package-only backend-neutral request/result boundary with .cpu as the sole policy; public backend selection remains deferred.
- [Phase 70]: Backend requests reuse canonical input, normalized effect plans, transient support, and bounded aggregate diagnostics; typed executor errors have no retry or fallback.
- [Phase 70]: The retained CPU implementation is the sole package executor, and both facade process families dispatch exactly once without changing public schema or algorithm inventory.
- [Phase 70]: Backend-neutral static/mutation gates run before consumer and CPU-oracle stages; only aggregate pass/fail counts are retained in the ledger.
- [Phase 71]: Plan 01 keeps one package-only Metal runtime instance responsible for device, queue, and pipeline ownership without a global cache or host lifecycle dependency.
- [Phase 71]: Private RGBA8 textures use request-local shared staging/readback buffers, and every tracked request resource is released on success and failure.
- [Phase 71]: Phase 71 Plan 02 keeps .metal package-only and routes one bounded identity transaction through the shared backend contract.
- [Phase 71]: BeautyMetalBackend uses named ExecutionHooks for exactly-one invocation and terminal error accounting without a CPU execution path.
- [Phase 71]: Plan 03 keeps Metal validation package-owned and aggregate-only; host availability is explicit and never GPU success.
- [Phase 71]: The archive-first wrapper runs the Metal preflight once after Phase-70 authorization and before consumer, CPU-oracle, opt-in, and full-child stages.
- [Phase 71]: CPU remains the reference; public backend selection and generated parity stay owned by Phases 73 and 74.
- [Phase 71]: METAL-01 closes only after archive-first runtime/preflight and full no-skip evidence: focused 26/0/0, full 728/0/0, eight opt-ins exactly once, and separate metal_available=1 / metal_unavailable=0 accounting.
- [Phase 71]: The runtime closeout is package-only aggregate evidence; Phase 72 owns feature passes, Phase 73 owns public .cpu/.gpu configuration, and Phase 74 owns parity/SDK-only closeout.
- [Phase 71]: METAL-01 closes only after archive-first runtime/preflight and full no-skip evidence with focused 26/0/0, full 728/0/0, eight opt-ins exactly once, and separate Metal availability classifications.
- [Phase 71]: Phase 71 remains package-only aggregate runtime evidence; CPU stays the reference while Phase 72 owns feature passes, Phase 73 owns public .cpu/.gpu configuration, and Phase 74 owns parity and SDK-only closeout.
- [Phase 72]: Phase 72 Plan 01 uses finite package-only Metal pass carriers and an ordered private-texture ping-pong graph; color/skin uniforms mirror retained CPU coefficients.
- [Phase 72]: Metal color bridges BGRA pixel buffers through request-local RGBA bytes, preserves alpha, and materializes still-image output with named sRGB metadata; geometry/local-retouch semantics remain with their owning plans.
- [Phase 72]: Plan 72-02 keeps BeautyGeometryEffectPipeline.controlPoints as the sole package-internal Metal geometry source and preserves composition collision ownership.
- [Phase 72]: Plan 72-02 uses finite bounded point/count payloads with CPU-compatible inverse displacement, clamped bilinear sampling, alpha, extent, locality, and no-face degradation.
- [Phase 72]: Plan 03 keeps BeautyLocalRetouchCompositionOwner as the sole proposal/source-binding/collision owner; Metal receives only the canonical RGBA8 carrier and six aggregate counters.
- [Phase 72]: Plan 03 dispatches composed-retouch before color and geometry so local-retouch-only bytes remain owner-produced and mixed work starts from immutable composition.
- [Phase 72]: The archive-first wrapper invokes check-metal-feature-passes.sh exactly once after runtime authorization and before consumer, CPU-oracle, opt-in, and full-child stages.

### Pending Todos

None found under `.planning/todos/pending/`.

### Blockers/Concerns

- Promotion cannot occur unless Phase 75 admits a complete rights-approved
  genuine positive/negative bundle. Missing or incomplete evidence is a
  feature-gate failure leading to exact public absence, not permission to tune
  on generated fixtures or substitute a proxy.

- Public research supplies useful periorbital labels and local tone methods but
  no exact production-ready fullness model with a verified product-compatible
  data/weight license; the deterministic path therefore remains primary.

- F-08 result alpha/extent enforcement is remediated with fail-closed contract tests.
- F-02/F-04/F-05/F-10 have approved, mutation-tested bounded dispositions; they
  do not establish transparent input, end-to-end GPU local retouch, or shared-
  instance parallel safety.

- F-09 geometry-envelope provenance is repaired and mutation-tested from one
  immutable observation.

- Physical-iPhone feedback is optional and non-blocking. Device/performance,
  commercial, packaging, shipping, launch, and release-readiness claims remain
  outside this milestone unless explicitly authorized later.

## Deferred Items

| Category | Item | Status | Deferred At |
| --- | --- | --- | --- |
| Algorithm breadth | Hairline/semantic masking, double-chin, and unrelated new beauty features | Future | v1.18 scope |
| Input/runtime breadth | Transparent input, HDR/gain maps, realtime/pixel-buffer, and video | Future | v1.18 scope |
| Product/release | Optional user device feedback plus any separately authorized device/commercial validation, performance budgets, packaging, distribution, shipping, launch, and release readiness | Future/non-blocking | project policy 2026-08-19 |

## Session Continuity

Last session: 2026-08-22T09:10:17+08:00
Stopped at: v1.18 roadmap drafted with 18/18 requirements mapped
Resume file: `.planning/ROADMAP.md`
Next action: approve the roadmap, then discuss and plan Phase 75.

## Operator Next Steps

- Start with Phase 75 semantics, rights manifest, frozen metrics, and sanitized
  review protocol; do not implement or expose a production control first.

- Preserve the exact 61/5/74 public surface until the Phase-78 aggregate
  decision authorizes the passing branch in Phase 79.

- Do not treat package-host parity or historical Phase-74 completion as device,
  transparent-input, end-to-end GPU local-retouch, or release evidence.

- Do not add a physical-iPhone checkpoint to an SDK milestone critical path
  unless the user explicitly creates a later device-focused scope.
