# Editor Branch: Commit Flow

## Business Logic

- Cancel rolls back to the last confirmed parameter snapshot.
- Confirm commits current parameters as the new baseline.
- Manual edits after preset/import become custom state.
- Reset/source state, rollback/apply, import/preset/custom state, and parameter snapshot ownership remain app-side behavior.

## Technical Core

- Demo owner: `BeautyParameterStore`, confirmed snapshot state, selected source state, rollback/apply state, reset state.
- SDK owner: immutable public parameter values and deterministic processing through the public `BeautySDK` facade.
- Verification: tests cover cancel rollback, confirm persistence, source transitions, import/preset/custom state, reset behavior, and no mutation on failed operations.
- Status: `implemented`.
- Primary owner: `BeautyDemo/State`.
- Dependencies: `BeautyParameterStore` and public `BeautyParameters`.
- Current public `BeautyParameters` coverage: parameter snapshot, cancel/confirm, reset, import, preset, and filter source state.
- Future parameter needs: none; multi-step editor history remains app-side.
- Evidence expectation: `BeautyParameterStoreTests`, `BeautyDemoViewStateTests`, `InputPipelinePrivacyTests`, and no internal SDK import scan.

## Boundary

Commit flow does not save files, export media, transfer assets, add history stacks, add renderer cases, or mutate SDK internals by itself.
