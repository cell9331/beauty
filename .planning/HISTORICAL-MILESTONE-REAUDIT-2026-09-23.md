# Historical milestone and current-code re-audit — 2026-09-23

## Scope and status

This is a source-and-evidence review of the milestone ledger, current v1.22 closeout receipt,
root contracts, the face-selection/detection/render call chain, and the current
SDK-owned gate. It does not requalify every historical image effect or revise an
archived milestone. Pre-existing untracked Phase 96 material was left untouched.

- The v1.22 milestone was recorded complete: 7/7 phases, 33/33 plans,
  11/11 active requirements. Before the follow-up repair,
  `python3 scripts/check-phase95-closeout.py verify-complete` returned
  `phase_complete: true` for its then-current normative
  input digest `56d33c8d9ddfbd6899287feeac501139d6ea1bac05250ca8982fa861482ed6f0`.
- v1.0–v1.17 and v1.20–v1.21 have closed historical ledger entries. v1.2
  closed at its owner-approved reduced scope. v1.18 closed a fail-closed
  non-promotion decision; its strict post-archive audit scores 14/18, with
  EVID-01/02 partial and QUAL-01/02 unsatisfied. v1.19 was canceled, with 14 unchecked archived
  requirements. v1.22 explicitly defers FACE-01/`faceContourSmooth` to
  FUTURE-04. Thus “all milestones completed” would misstate the original
  product objectives even though there is no active milestone.

Status sources: [milestone ledger](MILESTONES.md), [v1.18 strict re-audit](v1.18-MILESTONE-REAUDIT.md),
[v1.22 current scope](V1.22-CURRENT.md), and
[v1.22 roadmap](ROADMAP.md).

## Follow-up disposition (2026-09-23)

- TD-023 was a **documentation contract error**, not evidence that the current
  SDK promised multi-face effect rendering. The original selection code and
  its Phase 04 test both define `maximumFaceCount` as a detector selection cap;
  the effect facade has always used the primary face. `DESIGN.md` and
  `PRODUCT_SENSE.md` now state this explicitly, including the meaning of
  `usedFaceCount`. No multi-face renderer was added.
- TD-024 was a real isolation defect. `VisionFaceDetector` now maps each
  eligible face independently, keeps a valid face when a peer fails, and
  publishes only `.partial`/`.mappingFailed` and aggregate counts. A new
  deterministic test covers both observation orders and geometry versus
  combined geometry/local-support detection. Existing all-invalid behavior
  remains source-safe.
- The focused detector suite passed 35 tests with zero failures (three normal
  private opt-ins skipped). The archive-first full gate passed 938 tests with
  zero failures and zero skips, including all eight opt-ins. These prove the
  bounded repair and current package regression, not a renewed portrait
  closeout.
- This source/test edit makes the earlier Phase95 COMPLETE a historical
  snapshot. `verify-complete` currently returns `review_missing_or_stale`;
  the old 65-output portrait and independent review cannot be credited to
  the changed tree without a new closeout.

## Original review findings

### TD-023 — the old `maximumFaceCount` description overstated the facade

`DESIGN.md` describes `maximumFaceCount` as the maximum number of faces
processed per frame. `FaceSelectionPolicy.select` returns up to that many
faces and sets `usedFaceCount` to the selected count. The public engine's
geometry route consumes only `detection.observations.first` when resolving
effects and selecting support. With `maximumFaceCount: 2` and two usable faces,
the result can report `usedFaceCount == 2` while only the first face contributes
geometry or local retouch. Current engine tests exercise one-face results;
the multi-face facade path has no observed output assertion.

Evidence: `DESIGN.md:371`, `BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift:22-39`,
`BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift:58-77`.

Disposition: corrected the documentation to the already tested selection
semantics. Multi-face effect ownership remains outside the current contract.

### TD-024 — one malformed observation suppressed an otherwise usable face

`VisionFaceDetector.summarize` maps every confidence-eligible observation
inside one throwing `Array.map`. A mapping error from any observation resets
selection and returns zero observations with `.mappingFailed`. This happens
before the configured face limit is applied. For example, a valid primary face
followed by a lower-priority face with eyebrow support but invalid/missing
Vision bounds loses the valid primary too. The existing tests cover single-face
mapping failure and independent regions within one face, but do not cover
isolation across two detected faces.

Evidence: `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift:343-395`,
`:532-552`; `BeautySDK/Tests/BeautyDetectionTests/FaceObservationMappingTests.swift:116-139`.

Disposition: per-observation rejection and a deterministic two-face detector
regression are implemented. The current public effect path still selects only
one face, so no new multi-face pixel-effect claim is made.

## Existing accepted limitations

- v1.2's historical HTML captures retain two accepted visual defects; the UI
  material is archive-only and outside the current SDK build.
- v1.17's GPU parity is bounded to its documented opaque package-host cases;
  transparent input, same-instance parallel use, and end-to-end GPU local
  retouch ownership were not established.
- `faceContourSmooth` remains callable but partial; v1.22 gave it no
  effectiveness credit.
- The owner accepted a weak provisional `upperEyelidFullnessReduction` effect
  for local use in v1.21. No genuine qualification, device, commercial-quality,
  packaging, shipping, launch, release-readiness, or distribution conclusion
  follows from these milestones.
- The initial sandboxed full gate stopped during SwiftPM manifest compilation
  because the nested compiler could not write its module cache. The same
  repository gate passed when rerun with the required filesystem access.

## Verification

- Original v1.22 `verify-complete`: passed before follow-up source/test edits.
- Current `verify-complete`: fails closed as `review_missing_or_stale`.
- Pre-repair `bash scripts/run-no-skip-swiftpm.sh`: pass; archive and SDK-only
  checks, backend/Metal/parity and consumer gates, all eight private opt-ins,
  zero skipped tests. This repeat validates the current gate, not the two
  untested multi-face scenarios above.
- Post-repair `bash scripts/run-no-skip-swiftpm.sh`: 938/0/0, all eight opt-ins,
  zero skips; deterministic two-face detector regression present. No new
  multi-face effect-rendering assertion or private fixture was added.
