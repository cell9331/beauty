# Editor Branch: Commit Flow

## Business Logic

- Cancel rolls back to the last confirmed parameter snapshot.
- Confirm commits current parameters as the new baseline.
- Manual edits after preset/import become custom state.

## Technical Core

- Demo owner: `BeautyParameterStore`, confirmed snapshot state, selected source state.
- SDK owner: immutable parameter values and deterministic processing.
- Verification: tests cover cancel rollback, confirm persistence, and no mutation on failed operations.
- Status: `implemented`.
- Primary owner: `BeautyDemo/State`.
- Dependencies: `BeautyParameterStore` and public `BeautyParameters`.
- Current public `BeautyParameters` coverage: parameter snapshot, cancel/confirm, reset, import, preset, and filter source state.
- Future parameter needs: none; multi-step editor history remains app-side.
- Evidence expectation: state tests and no internal SDK import scan.

## Boundary

Commit flow does not save files, export media, or upload assets by itself.
