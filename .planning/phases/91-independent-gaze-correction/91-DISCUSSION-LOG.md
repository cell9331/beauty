# Phase 91: Independent Gaze Correction - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-09-04
**Phase:** 91-independent-gaze-correction
**Areas discussed:** Per-eye anatomy ownership, Correction envelope, Semantic evidence and publication
**Mode:** `--auto`; all gray areas and recommended defaults were selected under the owner's auto-chain authorization.

---

## Per-eye anatomy ownership

| Option | Description | Selected |
|--------|-------------|----------|
| Existing request-local Vision support | Reuse the mapped contour and pupil already owned by the detector/adapter. | ✓ |
| Infer pupil from output pixels | Locate a dark centroid inside fixed target boxes. | |
| Add a model-backed detector | Introduce a new pupil model, resource, and evidence lane. | |

**User's choice:** Auto-selected existing request-local Vision support.
**Notes:** `[auto] Per-eye anatomy ownership — Q: "Which source may establish pupil and own-eye-center geometry?" → Selected: "Existing request-local Vision support" (recommended default).` The Phase 89 darkness proxy remains prohibited.

| Option | Description | Selected |
|--------|-------------|----------|
| Independent per-eye eligibility | Correct the valid side and preserve the invalid side source-safe. | ✓ |
| Require a complete pair | Disable gaze unless both eyes survive validation. | |
| Mirror or borrow peer support | Substitute support from the other eye. | |

**User's choice:** Auto-selected independent per-eye eligibility.
**Notes:** `[auto] Per-eye anatomy ownership — Q: "What happens when only one eye has valid contour and pupil support?" → Selected: "Independent per-eye eligibility" (recommended default).`

---

## Correction envelope

| Option | Description | Selected |
|--------|-------------|----------|
| Preserve locked dead zone and cap | Keep `0.002`, public cap `0.25`, and maximum correction `35%`. | ✓ |
| Center completely | Move every admitted pupil all the way to its eye center. | |
| Retune after portrait results | Change thresholds or caps to fit observed outputs. | |

**User's choice:** Auto-selected the locked Phase 44 envelope.
**Notes:** `[auto] Correction envelope — Q: "How far should an eligible pupil move toward its own eye center?" → Selected: "Preserve the locked dead zone and 35% cap" (recommended default).`

| Option | Description | Selected |
|--------|-------------|----------|
| Anatomy-bounded pupil-local influence | Bound the warp to the narrowest admitted pupil neighborhood. | ✓ |
| Keep fixed face-width radius | Retain the current radius without new containment proof. | |
| Move the whole eye | Translate contour/aperture together with the pupil. | |

**User's choice:** Auto-selected anatomy-bounded pupil-local influence.
**Notes:** `[auto] Correction envelope — Q: "How should the warp protect surrounding anatomy?" → Selected: "Anatomy-bounded pupil-local influence" (recommended default).` CPU remains the oracle and `Warp.metal` is unchanged.

---

## Semantic evidence and publication

| Option | Description | Selected |
|--------|-------------|----------|
| Pixel oracle plus production aggregate anatomy | Link generated actual-pixel evidence with request-local own-eye reduction facts. | ✓ |
| Aggregate control-point evidence only | Treat emitted vectors as sufficient proof. | |
| Image-darkness centroid only | Restore the rejected fixed-box proxy. | |

**User's choice:** Auto-selected the two-layer evidence contract.
**Notes:** `[auto] Semantic evidence and publication — Q: "What evidence may replace the rejected dark-pixel gaze proxy?" → Selected: "Pixel oracle plus production aggregate anatomy" (recommended default).`

| Option | Description | Selected |
|--------|-------------|----------|
| Aggregate-only anatomy; Phase 95 final publication | Persist no raw support and leave the final 65-output rerun to Phase 95. | ✓ |
| Persist per-eye geometry | Save coordinates for later debugging. | |
| Leave gaze unsupported until Phase 95 | Defer metric admission rather than completing Phase 91. | |

**User's choice:** Auto-selected aggregate-only anatomy evidence with Phase 95 final publication.
**Notes:** `[auto] Semantic evidence and publication — Q: "What may persist in reports and diagnostics?" → Selected: "Aggregate-only anatomy evidence with Phase 95 final publication" (recommended default).`

---

## Agent's Discretion

- Exact private type/file names, generated fixture pixels, aggregate integer/Q16 shape, and the narrowest existing temporary transport seam.
- Focused test organization, provided every test binds to the actual production render path and the public inventories/signatures stay unchanged.

## Deferred Ideas

- Phase 95 final clean 65-output publication.
- New model/data/realtime/device/commercial/distribution scope.
- Eyebrow, nose, and mouth repairs remain in Phases 92–94.
