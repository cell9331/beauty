# Editor Branch: Preview Chrome

## Business Logic

- Show the edited media preview as the primary surface.
- Provide compare and debug as editor-level affordances.
- `背景保护` is a visible control concept; it requires segmentation before becoming functional.

## Technical Core

- Demo owner: preview view state, compare state, debug overlay state.
- SDK input: processed output plus public-safe summaries/metrics.
- Future dependency: background protection requires segmentation masks and effect composition rules.
- Status: `implemented`.
- Primary owner: `BeautyDemo/Editor`.
- Dependencies: public result and redacted debug summaries.
- Current public `BeautyParameters` coverage: none; compare/debug reads outputs and summaries only.
- Future parameter needs: background protection requires a promoted SDK design.
- Evidence expectation: Demo view-state tests and no internal SDK import scan.

## Boundary

Debug overlay must stay read-only and redacted. No landmarks, boxes, file paths, or raw framework errors.
