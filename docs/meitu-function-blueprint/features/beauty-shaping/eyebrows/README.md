# Beauty Shaping Branch: Eyebrows

## Business Logic

Eyebrow tools include vertical position, thickness, length, spacing, inner spacing, tilt, and arch/peak.

## Technical Core

- Requires eyebrow landmarks or a resource-guided overlay model.
- Thickness/length can be either geometry, texture synthesis, or makeup-resource placement depending on implementation choice.
- Status: `future`.
- Primary owner: `BeautyEffects` if promoted.
- Dependencies: future landmarks or resource support only after design approval.
- Current public `BeautyParameters` coverage: none.
- Future parameter needs: position, thickness, length, distance, head distance, tilt, and peak controls.
- Evidence expectation: no v1.3 completion evidence until explicitly promoted.

## Boundary

No eyebrow makeup asset schema is implied by this branch alone.
