# Editor Branch: Preview Chrome

## Business Logic

- Show the edited media preview as the primary surface.
- Provide compare and debug as editor-level affordances.
- `背景保护` is a visible control concept; it requires segmentation before becoming functional.
- Keep compare/debug read-only; they must not mutate parameters or expose raw geometry payloads.

## Technical Core

- Demo owner: preview view state, compare state, debug overlay state.
- SDK input: processed output plus public-safe summaries/metrics from the public `BeautySDK` facade.
- Future dependency: background protection requires segmentation masks and effect composition rules.
- Status: `implemented`.
- Primary owner: `BeautyDemo/Editor`.
- Dependencies: public result and redacted debug summaries.
- Current public `BeautyParameters` coverage: none; compare/debug reads outputs and summaries only.
- Future parameter needs: background protection requires a promoted SDK design.
- Evidence expectation: `BeautyDemoViewStateTests`, `CompareStateTests`, `InputPipelinePrivacyTests`, and no internal SDK import scan.

## Boundary

Debug overlay must stay read-only and redacted. No landmarks, boxes, control points, file paths, image bytes, or raw framework errors.
No additional SwiftUI screen, renderer case, network behavior, paid access, account gating, or geometry saved-image claim is part of preview chrome closeout.
