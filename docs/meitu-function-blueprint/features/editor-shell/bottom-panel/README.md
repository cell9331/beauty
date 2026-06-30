# Editor Branch: Bottom Panel

## Business Logic

- Organize effects into first-level categories and second-level tool rails.
- Selected tool controls one shared slider where possible.
- Badges such as `限免`, `Pro`, and `OFF` are capability states, not paid-access implementation.
- Category rail, tool rail, labels, badges, slider mapping, disabled/future tool presentation, compare text, and debug text are app-side UI state.

## Technical Core

- Demo owner: category/tool models, category rail/tool rail state, labels, badges, and mapping to `BeautyControlDescriptor`.
- SDK owner: normalized `BeautyParameters`.
- Future extension: each tool must declare parameter mapping, resource need, detection need, and unavailable reason.
- Status: `implemented`.
- Primary owner: `BeautyDemo/Panel`.
- Dependencies: `BeautyDemo/State` and public `BeautyParameters`.
- Current public `BeautyParameters` coverage: slider mapping covers current public skin, color, faceShape, eyes, nose, mouth, lipColor, and filter fields.
- Future parameter needs: any new visible tool needs a product-neutral public parameter or stays disabled.
- Evidence expectation: `BeautyDemoViewStateTests` mapping/disabled-honesty coverage, `BeautyParameterStoreTests` snapshot coverage, and facade-only import scans.

## Boundary

Panel must not import `BeautyCore`, `BeautyEffects`, `BeautyRender`, or `BeautyDetection` directly.
Panel closeout must not add additional SwiftUI screens, visible tools without public product-neutral parameters, resource/style systems, network behavior, paid access, account gating, or renderer cases.
