# Editor Branch: Bottom Panel

## Business Logic

- Organize effects into first-level categories and second-level tool rails.
- Selected tool controls one shared slider where possible.
- Badges such as `限免`, `Pro`, and `OFF` are capability states, not entitlement implementation.

## Technical Core

- Demo owner: category/tool models and mapping to `BeautyControlDescriptor`.
- SDK owner: normalized `BeautyParameters`.
- Future extension: each tool must declare parameter mapping, resource need, detection need, and unavailable reason.
- Status: `implemented`.
- Primary owner: `BeautyDemo/Panel`.
- Dependencies: `BeautyDemo/State` and public `BeautyParameters`.
- Current public `BeautyParameters` coverage: slider mapping covers current public skin, color, faceShape, eyes, nose, mouth, lipColor, and filter fields.
- Future parameter needs: any new visible tool needs a product-neutral public parameter or stays disabled.
- Evidence expectation: view-state mapping tests and facade-only import scans.

## Boundary

Panel must not import `BeautyCore`, `BeautyEffects`, `BeautyRender`, or `BeautyDetection` directly.
