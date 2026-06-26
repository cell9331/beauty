# Editor Branch: Input Routing

## Business Logic

- Route still image input to the beauty editor.
- Route camera input to the beauty editor when camera mode is used.
- Treat video input as outside this milestone.

## Technical Core

- Demo owner: `EditorInputMode`, photo picker state, camera permission state.
- SDK owner: frame/image processing via public facade.
- Verification: route tests confirm supported entries reach the expected editor mode.
- Status: `implemented`.
- Primary owner: `BeautyDemo/Editor`.
- Dependencies: public `BeautySDK` facade and existing camera/photo pipelines.
- Current public `BeautyParameters` coverage: input routing creates snapshots but owns no SDK parameter.
- Future parameter needs: none; future video input remains outside v1.3.
- Evidence expectation: Demo route tests and facade-only import scans.

## Boundary

No video import/export or timeline editing in this milestone.
