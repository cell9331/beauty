# Skin Branch: Skin Repair

## Business Logic

Skin repair covers blemish, pore, texture, and localized cleanup.

## Technical Core

- Needs region/mask model and local inpainting or guided smoothing.
- Should avoid making irreversible edits without preview/apply flow.
- Requires clear degradation when mask confidence is low.
- Status: `future`.
- Primary owner: `BeautyEffects` if promoted.
- Dependencies: future local repair algorithm and mask/region confidence model.
- Current public `BeautyParameters` coverage: none.
- Future parameter needs: blemish, pore, texture, and localized cleanup controls.
- Evidence expectation: no v1.3 completion evidence until explicitly promoted.

## Boundary

No face-image upload or cloud repair unless a separate privacy milestone approves it.
