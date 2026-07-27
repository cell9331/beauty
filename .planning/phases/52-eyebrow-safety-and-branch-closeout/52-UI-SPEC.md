---
phase: 52
slug: eyebrow-safety-and-branch-closeout
status: approved
shadcn_initialized: false
preset: none
created: 2026-07-27
reviewed_at: 2026-07-27T14:03:41+08:00
applicability: not-applicable
---

# Phase 52 — UI Design Contract

> Bounded no-UI-change contract for an SDK-core evidence-repair and planning-truth synchronization phase.

---

## Applicability Decision

Phase 52 requires no new or changed visual surface, interaction, UI state, copy,
component, route, screenshot, or accessibility behavior.

This is a source-backed scope decision:

- `52-CONTEXT.md` locks the phase to SDK-core safety, convergence, evidence,
  promotion, and owner synchronization, and explicitly excludes SwiftUI/Demo
  behavior.
- `.planning/REQUIREMENTS.md` lists SwiftUI and Demo UI changes as out of
  scope for v1.13.
- `52-RESEARCH.md` says no Demo simulator build is required and no UI package,
  component library, dependency, or design work is added.
- `52-VERIFICATION.md` identifies only three deterministic SDK test-fixture /
  execution-path gaps plus planning-truth disagreement. It explicitly states
  that no human visual verification is required.
- `PLANS.md` and `FRONTEND.md` keep `BeautyDemo` separate from the SDK and
  preserve the milestone boundary: no SwiftUI or Demo UI.

The repository-wide UI detector reports a frontend because `BeautyDemo`
contains SwiftUI. That repository fact does not expand this phase boundary.
For Phase 52, the UI gate is satisfied by preserving the existing Demo
unchanged.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | Not applicable for Phase 52; preserve the existing native SwiftUI Demo without edits |
| Preset | Not applicable |
| Component library | No component may be added, removed, replaced, or restyled |
| Icon library | No icon work |
| Font | No typography work |

`components.json` is absent because this is an iOS SwiftUI repository rather
than a React, Next.js, or Vite project. The shadcn initialization and registry
gates do not apply.

---

## Spacing Scale

No spacing values are declared for Phase 52 because the phase creates no UI
element or layout. Executors must not change padding, gaps, frames, safe-area
behavior, panel dimensions, or touch targets under `BeautyDemo/`.

| Token | Value | Usage |
|-------|-------|-------|
| Not applicable | — | No Phase 52 UI surface exists |

Exceptions: none. Existing Demo spacing remains owned by `FRONTEND.md` and the
current SwiftUI source; it is not reopened by this gap-closure work.

---

## Typography

Phase 52 introduces zero text roles, zero font sizes, and zero font weights.
Existing Demo typography must remain byte-for-byte/source-unchanged.

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Not applicable | — | — | — |

---

## Color

The 60/30/10 color split is not applicable because Phase 52 introduces no
surface.

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | Not applicable | No new background or surface |
| Secondary (30%) | Not applicable | No new card, sidebar, panel, or navigation |
| Accent (10%) | Not applicable | No Phase 52 element may use accent |
| Destructive | Not applicable | No destructive action exists |

Accent reserved for: none in Phase 52.

---

## Copywriting Contract

| Element | Copy |
|---------|------|
| Primary CTA | Not applicable — no CTA |
| Empty state heading | Not applicable — no UI state |
| Empty state body | Not applicable — no UI state |
| Error state | Not applicable — SDK evidence failures stay in tests/checkers/planning artifacts, not user-facing UI |
| Destructive confirmation | Not applicable — no destructive action |

Phase 52 must not add a cap banner, eyebrow warning row, diagnostic disclosure,
review status message, promotion notice, or milestone-completion copy to the
Demo. Aggregate SDK warnings and metrics remain governed by the existing
privacy/redaction contracts and do not become UI copy in this phase.

---

## Visual Contract

- Do not edit any SwiftUI view, view model, Demo state model, preview, asset
  catalog, Xcode project UI configuration, screenshot, or visual fixture.
- Do not add or enable eyebrow sliders, tool rows, categories, badges, panels,
  alerts, sheets, overlays, debug rows, or navigation routes.
- Preserve the current Demo behavior for the visible `眉毛` taxonomy. SDK-core
  product-owner promotion does not authorize enabling or restyling Demo
  controls.
- Do not recalibrate or redesign the Phase 51 strict `e6` renderer evidence.
  It may be rerun unchanged as non-UI regression evidence.
- Do not interpret a Demo simulator regression run as Phase 52 visual
  acceptance. It is permitted only as an unchanged-surface regression check
  and is not required to close the identified gaps.

---

## Interaction Contract

- No new interaction is authorized.
- Do not map the seven eyebrow parameters into new Demo controls.
- Do not change Camera, Photo, compare, debug, cancel/confirm, reset,
  category, subcategory, or tool-selection behavior.
- Do not add loading, empty, error, partial, overflow, confirmation, or
  cancellation UI states. The cancellation gap in `52-VERIFICATION.md`
  concerns deterministic execution of the actual SDK request path, not a
  user-facing cancellation interaction.
- Do not surface test/checker/review failures through the app. Planning truth
  must instead remain synchronized in repository artifacts.

---

## Accessibility Contract

No accessibility surface changes are required or authorized. Existing labels,
traits, Dynamic Type behavior, contrast, and touch targets remain unchanged.
Any edit under `BeautyDemo/` would be scope drift and requires a separately
scoped frontend phase with its own UI contract.

---

## UI Considerations

Applicable state considerations resolved: none applicable.

| Category | Element(s) | Status | Resolution / Reason |
|----------|------------|--------|---------------------|
| none | none | ✅ covered | Phase 52 creates no UI element or surface; empty, loading, error, populated, partial, overflow, zero/one/many, and long-text UI states therefore do not apply. |

This is not an unexamined state-free surface. It is an explicit no-surface
boundary derived from `52-CONTEXT.md`, `.planning/REQUIREMENTS.md`,
`52-RESEARCH.md`, and `52-VERIFICATION.md`.

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| shadcn official | none | Not applicable — native SwiftUI repository; `components.json` absent — 2026-07-27 |
| Third-party registries | none | Not applicable — no UI block or registry dependency is authorized — 2026-07-27 |

---

## Planning and Verification Contract

The planner and executor must treat the following as the complete UI contract:

1. Fix WR-01 through WR-03 only in SDK test fixtures/seams and their directly
   owned evidence.
2. Resynchronize review, requirement, project, state, plan, validation,
   quality, and verification truth only after the affected focused suites,
   full regression, clean follow-up review, and final checker pass.
3. Keep `BeautyDemo/`, its Xcode project, UI tests, screenshots, and visual
   evidence outside the change set.
4. Verify the no-UI-change boundary with a path-scoped diff check. A compliant
   implementation has no Phase 52 diff under `BeautyDemo/`.
5. If a gap fix appears to require user-facing UI, stop and create a separately
   authorized frontend phase instead of expanding Phase 52.

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS
- [x] Dimension 2 Visuals: PASS
- [x] Dimension 3 Color: PASS
- [x] Dimension 4 Typography: PASS
- [x] Dimension 5 Spacing: PASS
- [x] Dimension 6 Registry Safety: PASS

**Approval:** approved
