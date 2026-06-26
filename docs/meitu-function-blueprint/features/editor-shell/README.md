# Editor Shell Function Family

## Business Role

Editor shell coordinates image/video input, preview, bottom tool panels, parameter snapshots, compare/debug, and cancel/confirm semantics.

## Branches

- `input-routing/` - Photo, camera, future video inputs.
- `preview-chrome/` - Brand, preview, compare/debug, background protection affordance.
- `bottom-panel/` - Slider, tool rail, category rail, badges.
- `commit-flow/` - Cancel, confirm, parameter snapshot, rollback/apply.

| Branch | Status | Primary owner | Demo-owned details | SDK dependency |
| --- | --- | --- | --- | --- |
| Input routing | implemented | `BeautyDemo/Editor` | Photo/camera entry, route state, loading/error state, input routing, metadata handoff | Public `BeautySDK` facade only |
| Preview chrome | implemented | `BeautyDemo/Editor` | Brand/chrome, compare/debug, background-protection affordance, labels, badges | Public result and redacted debug summaries |
| Bottom panel | implemented | `BeautyDemo/Panel` | Category rails, tool rail, labels, badges, slider mapping, disabled/future tool presentation | Public `BeautyParameters` fields |
| Commit flow | implemented | `BeautyDemo/State` | Cancel/confirm, parameter snapshot, rollback/apply, reset/source state | Public `BeautyParameters` snapshots |

## Technical Core

- Owner: `BeautyDemo/Editor`, `BeautyDemo/Panel`, `BeautyDemo/State`.
- SDK integration: public `BeautyEngine`, `BeautyParameters`, resource facade.
- State model: selected input, selected category/tool, parameter snapshot, processing state.

## Boundary

Editor shell does not own effect algorithms or internal SDK targets.
Editor shell does not add SwiftUI screens in Phase 17; it only documents existing Demo responsibilities for core beauty implementation phases.
