# Editor Shell Function Family

## Business Role

Editor shell coordinates local image/camera input, preview, bottom tool panels, parameter snapshots, compare/debug, and cancel/confirm semantics.

## Branches

- `input-routing/` - Photo and camera inputs; future video input stays outside v1.3.
- `preview-chrome/` - Brand, preview, compare/debug, background protection affordance.
- `bottom-panel/` - Slider, tool rail, category rail, badges.
- `commit-flow/` - Cancel, confirm, parameter snapshot, rollback/apply.

| Branch | Status | Primary owner | Demo-owned details | SDK dependency |
| --- | --- | --- | --- | --- |
| Input routing | implemented | `BeautyDemo/Editor` | Photo/camera entry, route state, loading/error state, input routing, metadata handoff | public `BeautySDK` facade only |
| Preview chrome | implemented | `BeautyDemo/Editor` | Brand/chrome, compare/debug, background-protection affordance, labels, badges | Public result and redacted debug summaries |
| Bottom panel | implemented | `BeautyDemo/Panel` | Category rail, tool rail, labels, badges, slider mapping, disabled/future tool presentation | Public `BeautyParameters` fields |
| Commit flow | implemented | `BeautyDemo/State` | Cancel/confirm, parameter snapshot, rollback/apply, reset/source state | Public `BeautyParameters` snapshots |

## Technical Core

- Owner: `BeautyDemo/Editor`, `BeautyDemo/Panel`, `BeautyDemo/State`.
- SDK integration: public `BeautyEngine`, public `BeautySDK` facade, `BeautyParameters`, result summaries, and redacted debug summaries.
- State model: selected input, selected category/tool, parameter snapshot, processing state.
- Evidence: existing Demo view-state, state, compare/debug, import-boundary, and input privacy tests; facade-only scans must stay clean.

## Boundary

Editor shell does not own effect algorithms or internal SDK targets.
Editor shell does not add additional SwiftUI screens, routes, tool-panel behavior, app-state behavior, public parameters, renderer cases, export behavior, network transfer, paid access, account gating, or historical-doc cleanup during Phase 20 closeout.
Editor shell closeout is Demo-owned documentation and verification of existing app-side support.
