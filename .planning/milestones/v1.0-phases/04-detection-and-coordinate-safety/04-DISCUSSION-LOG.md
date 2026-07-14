# Phase 4: Detection and Coordinate Safety - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-18T01:53:10Z
**Phase:** 4-Detection and Coordinate Safety
**Areas discussed:** Orientation and Mirroring API Boundary, Detection State Exposure, Demo Degradation Behavior, Test and Fixture Scope, Single-Face and Multi-Face Boundary

---

## Orientation and Mirroring API Boundary

| Question | Selected | Alternatives Considered |
| --- | --- | --- |
| Should Phase 4 extend the public facade for full orientation and mirroring metadata? | Add a new metadata overload while preserving the existing orientation-only API. | Thread metadata internally only; replace existing API. |
| What shape should the new metadata API use? | Use a lightweight public metadata struct instead of exposing internal `BeautyFrame` directly. | Expose `BeautyFrame` directly; use expanded parameter lists. |
| How should mirroring semantics be represented? | Keep separate `isInputMirrored` and `isPreviewMirrored` semantics. | Combine into one `isMirrored`; record preview mirroring only. |
| How should old orientation-only APIs relate to the new metadata entry points? | Old APIs delegate to the metadata entry points with default non-mirrored metadata. | Keep old/new implementations separate; mark old API as transitional. |
| Should the metadata shape cover both realtime frame and still image processing? | Use one shared `BeautyInputMetadata` type for both `pixelBuffer` and `CIImage` paths. | Separate frame/image metadata; only add full metadata to realtime frames. |
| How should source and timestamp be represented? | Keep a stable source enum and optional timestamp. | Make both optional; keep timestamp only. |
| What is the Demo default for front-camera mirroring? | Default to input not mirrored and preview mirrored. | Input and preview both mirrored; neither mirrored. |
| Should Demo processing snapshots retain full metadata? | Store full `BeautyInputMetadata` in Camera and Photo snapshots. | Store orientation only; verify metadata only through test processor records. |

**Notes:** The user consistently selected the compatibility-preserving option that makes metadata explicit without prematurely exposing internal frame models.

---

## Detection State Exposure

| Question | Selected | Alternatives Considered |
| --- | --- | --- |
| Which layer should own detection and degradation state exposure? | Expose detection and degradation state in public `BeautyResult` metadata. | Keep state only in internal diagnostics; return detection state as `BeautyError`. |
| Should `BeautyResult` become the main Phase 4 processing return value? | Add result-returning overloads while keeping output-only APIs compatible. | Change existing APIs to return `BeautyResult`; add engine `lastResult`. |
| How much detection detail should public metadata expose? | Expose a stable summary only; do not expose bounding boxes or landmark coordinates. | Expose full face observations; expose only `faceAvailable`. |
| How should detection and degradation reasons be represented? | Use structured enum reason codes. | String code list; reuse `BeautyValidationWarning`. |
| How should no-face and partial-face be expressed at the top level? | Use a clear `DetectionAvailability` state. | Infer from reason codes; use face count plus reason codes. |
| How should disabled, not-run, skipped, reused, and stale states be distinguished? | Represent `disabled`, `notRun`, `skipped/reused`, and `stale` explicitly. | Collapse all into `notRun`; omit non-executed states. |
| Should public metadata contain privacy-safe counts and timings? | Include privacy-safe counts and timing summaries. | Include state/reasons only; no metrics. |
| How should detector or mapping failures appear publicly? | Map them to structured degradation reasons and keep raw framework details only in redacted diagnostics. | Return `BeautyError.detectionFailed`; show generic warning only. |

**Notes:** The selected direction treats no-face and partial-face as safe, diagnosable degradation rather than fatal errors.

---

## Demo Degradation Behavior

| Question | Selected | Alternatives Considered |
| --- | --- | --- |
| How should the normal Demo UI behave for no-face and partial-face results? | Keep the visual output and show a non-blocking short status message. | Disable controls and show reason; show only in debug mode. |
| Should face-dependent controls be disabled during no-face or partial-face states? | Do not disable sliders; allow continued parameter editing. | Disable face/eye/nose/mouth controls; disable only in Photo mode. |
| How specific should normal user-facing degradation copy be? | Use short copy by main state, without landmark or internal Vision details. | One generic message; show specific missing regions. |
| What should Demo debug mode display for detection? | Display availability, reason codes, safe counts, and timings. | Only state/message; overlay boxes and points. |
| How should Camera mode avoid flickering detection status? | Debounce or briefly hold detection status updates. | Update every frame; only show worsening states. |
| How long should Photo mode keep no-face and partial-face status visible? | Persist it with the current image result until reprocess or image change. | Show a short toast once; treat as an error state. |
| Where is the boundary between Phase 4 status UI and Phase 7 debug overlay? | Phase 4 adds status row and debug data source only. | Build debug overlay UI now; only add SDK metadata. |
| How should Demo show unavailable detection metadata? | Normal UI stays quiet; debug state explains unavailable/disabled/notRun. | Show unavailable in normal UI; show nothing anywhere. |

**Notes:** The selected behavior preserves the Phase 3 continuity model and avoids expanding into Phase 7 overlay work.

---

## Test and Fixture Scope

| Question | Selected | Alternatives Considered |
| --- | --- | --- |
| What is the main Phase 4 fixture testing strategy? | Synthetic model/coordinate fixtures primarily, with narrow deterministic images or Vision stubs. | All real images and Vision output; pure model tests only. |
| How broad should coordinate tests be? | Cover core orientation and mirroring combinations. | Happy path only; exhaustive EXIF and mirroring permutation matrix. |
| How should no-face and partial-face tests be organized? | Test both SDK result metadata and Demo state. | SDK only; Demo only. |
| What is the Vision adapter testing boundary? | Injectable detector/stub unit tests plus narrow real-image smoke. | Strict real-image landmarks/boxes; skip adapter tests. |
| Should Phase 4 include public API compatibility tests? | Add old API and new metadata API equivalence tests. | Test only new API; rely on compilation. |
| Should fixtures and metadata tests cover privacy and redaction boundaries? | Test metadata does not leak sensitive geometry or paths. | Rely on `SECURITY.md`; leave to Phase 7. |
| Where should Phase 4 tests run? | Use both SwiftPM SDK tests and Demo simulator XCTest. | SwiftPM only; Demo XCTest only. |
| Is real device camera validation a required Phase 4 completion gate? | Record as risk, not a required gate. | Require real-device validation; omit the risk. |

**Notes:** The selected scope balances stable automated evidence with narrow real-adapter smoke coverage.

---

## Single-Face and Multi-Face Boundary

| Question | Selected | Alternatives Considered |
| --- | --- | --- |
| What should Phase 4's actual face detection usage strategy be? | v1 executes single-face behavior while models/tests support deterministic ordering. | Full multi-face support; take the first Vision face. |
| How should result metadata represent multiple detected faces? | Report `faceCount` and `usedFaceCount`, with `faceLimitApplied` when applicable. | Report only used count; report all observations. |
| How should the primary face be selected? | Largest face first, with stable ID to break close ties. | Always largest; always previous ID. |
| Should `maximumFaceCount` be effective in Phase 4? | Make configuration effective in SDK, Demo default remains 1. | Ignore configuration; expose setting in Demo. |
| What should happen to non-used faces when the face budget is exceeded? | Non-used faces do not participate in effects; record summary reason only. | Apply weak effects; do not record non-primary faces. |
| What is the stability boundary for tracking IDs? | Stable only within current engine lifecycle; reset clears state. | Stable across sessions; do not use stable IDs. |
| Should Photo and Camera use the same primary-face selection rules? | Same sorting rule, but Photo does not reuse tracking state across images. | Photo reuses global tracking; Photo/Camera use different rules. |
| Should Phase 4 reserve public API for future per-face parameters? | No public per-face API; internal extensibility only. | Reserve public per-face parameter structures; support per-face parameters now. |

**Notes:** The selected boundary keeps v1 single-face and avoids prematurely committing host-facing multi-face editing APIs.

---

## the agent's Discretion

None. The user selected concrete options for all discussed decisions.

## Deferred Ideas

- Overlay boxes/points and final debug QA surface remain Phase 7.
- Public per-face parameters, manual main-face selection, multi-face UI, and true multi-face effects remain future/v2+ work.
- Real-device front-camera mirroring and real Vision quality remain manual QA risks rather than required Phase 4 gates.
