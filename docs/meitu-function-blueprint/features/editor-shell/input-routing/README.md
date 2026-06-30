# Editor Branch: Input Routing

## Business Logic

- Route still image input to the beauty editor.
- Route camera input to the beauty editor when camera mode is used.
- Treat video input as outside this milestone.
- Keep route, loading, error, and local metadata handoff state Demo-owned.

## Technical Core

- Demo owner: `EditorInputMode`, photo picker state, camera permission state, route state, loading state, error state.
- SDK owner: frame/image processing via the public `BeautySDK` facade.
- Verification: route tests confirm supported entries reach the expected editor mode.
- Status: `implemented`.
- Primary owner: `BeautyDemo/Editor`.
- Dependencies: public `BeautySDK` facade and existing camera/photo pipelines.
- Current public `BeautyParameters` coverage: input routing creates snapshots but owns no SDK parameter.
- Future parameter needs: none; future video input remains outside v1.3.
- Evidence expectation: `BeautyDemoViewStateTests` route/input-state coverage, `BeautyDemoImportBoundaryTests`, and `InputPipelinePrivacyTests` facade-only/local-first scans.

## Boundary

No video import/export, timeline editing, network transfer, additional SwiftUI screen, or additional SDK parameter in this milestone.
