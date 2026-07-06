# Phase 26: Geometry Facade and Landmark Routing Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-06
**Phase:** 26-Geometry Facade and Landmark Routing Foundation
**Areas discussed:** Detection activation rule, Landmark-to-geometry routing, Phase 26 proof boundary, Diagnostics and redaction surface

---

## Detection Activation Rule

### When should still-image detection run inside `BeautyEngine.processResult(...)`?

| Option | Description | Selected |
|--------|-------------|----------|
| Geometry-triggered only | Run detection only when current parameters need face geometry/landmarks, such as face shape, eyes, nose, mouth, or lip-region work. Keeps no-op/color/filter/basic skin paths cheap and avoids changing `.notRun` behavior unnecessarily. | ✓ |
| Always when tracking is enabled | If `BeautyConfiguration.enableFaceTracking == true`, run detection for every still image. Simpler mental model, but changes current compatibility/no-op behavior and may add cost where no face-dependent effect is needed. | |
| Planner decides | Let Phase 26 planning choose the narrowest implementation that passes `GEO-01`/`GEO-02` while preserving compatibility and privacy. | |
| Other | Freeform preference. | |

**User's choice:** Geometry-triggered only.
**Notes:** This keeps current no-op/color/filter/basic skin compatibility and narrows detection to geometry routing.

### If geometry-triggered detection runs but cannot produce a usable face, what should `processResult(...)` do?

| Option | Description | Selected |
|--------|-------------|----------|
| Degrade and continue | Return output with face-dependent domains skipped, keep safe color/filter work active, attach redacted `BeautyDetectionSummary`, warnings, and numeric metrics. | ✓ |
| Throw a typed detection error | Fail the still-image call when geometry was requested but detection is unavailable/no face/partial. | |
| Return original image silently | Avoid errors and warnings, but hide visible-output degradation. | |
| Other | Freeform preference. | |

**User's choice:** Degrade and continue.
**Notes:** Matches existing degrade-before-fail contracts.

### When no geometry-triggering parameters are present, what should the public detection summary report?

| Option | Description | Selected |
|--------|-------------|----------|
| Preserve current compatibility | Keep `.notRun` when face tracking is enabled but no detection was needed, and `.disabled` when `enableFaceTracking == false`. | ✓ |
| Report `.skipped` with a new reason | More explicit intentional-skip behavior, but adds public behavior/model/docs updates. | |
| Always omit `detectionSummary` | Smaller public surface, but conflicts with current metadata-aware APIs. | |
| Other | Freeform preference. | |

**User's choice:** Preserve current compatibility.
**Notes:** Avoids unnecessary public behavior changes for non-geometry paths.

### Should Phase 26 add a test-only detector seam?

| Option | Description | Selected |
|--------|-------------|----------|
| Yes, test-only/internal seam | Add internal or SPI-only injectable detector path for deterministic SDK tests; keep public API unchanged. | ✓ |
| No, use real Vision only | More realistic but less deterministic and may be blocked by fixture/toolchain variability. | |
| Planner decides | Let planning choose the smallest deterministic seam that does not expose internals publicly. | |
| Other | Freeform preference. | |

**User's choice:** Yes, test-only/internal seam.
**Notes:** Enables reliable facade tests for usable/no-face/low-confidence/missing-landmark/failure states.

---

## Landmark-to-Geometry Routing

### How should Phase 26 route detection output into geometry planning?

| Option | Description | Selected |
|--------|-------------|----------|
| Single selected face first | Convert only the selected/primary usable face into internal geometry for this phase. | ✓ |
| Prepare full multi-face routing now | Route all selected faces according to `maximumFaceCount`; broader and future-ready. | |
| Planner decides | Let planning choose the narrowest route satisfying `GEO-01`/`GEO-02`. | |
| Other | Freeform preference. | |

**User's choice:** Single selected face first.
**Notes:** Keeps first facade geometry route small and aligned with default `maximumFaceCount = 1`.

### What should the routing bridge expose across internal target boundaries?

| Option | Description | Selected |
|--------|-------------|----------|
| Internal `FaceGeometry` only | Keep observation, landmark groups, and coordinate details internal; public result exposes only summary/warnings/metrics. | ✓ |
| Expose a public lightweight face token | Adds public surface and potential privacy ambiguity. | |
| Expose public geometry-lite data | Conflicts with security/design contracts. | |
| Other | Freeform preference. | |

**User's choice:** Internal `FaceGeometry` only.
**Notes:** No public landmark, box, token, or control-point data.

### For Phase 26, how complete should the landmark-to-`FaceGeometry` adapter be?

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal deterministic adapter | Build enough internal geometry from selected-face bounds/landmark availability to activate existing providers and tests. | ✓ |
| Full real Vision landmark point extraction now | More complete but broadens scope before the facade route is proven. | |
| Test-fixture geometry only | Too weak for `GEO-02` unless separately justified. | |
| Other | Freeform preference. | |

**User's choice:** Minimal deterministic adapter.
**Notes:** Full production Vision point extraction can be refined later.

### How should Phase 26 handle missing or incomplete landmark groups after routing?

| Option | Description | Selected |
|--------|-------------|----------|
| Preserve group-specific degradation | Route safely available geometry and let existing resolver behavior skip only affected domains. | ✓ |
| All-or-nothing geometry | If any required landmark group is missing, skip all geometry domains. | |
| Planner decides | Let planning choose the narrowest behavior preserving `GEO-02` and existing degradation tests. | |
| Other | Freeform preference. | |

**User's choice:** Preserve group-specific degradation.
**Notes:** Keeps existing no-face/missing/stale/reused behavior intact.

---

## Phase 26 Proof Boundary

### What should count as Phase 26 success evidence?

| Option | Description | Selected |
|--------|-------------|----------|
| Intent activation through tests | Prove public facade triggers detection, routes selected-face geometry into resolver planning, activates geometry domains/control-point intent, and returns redacted evidence. | ✓ |
| Saved geometry image output now | Stronger evidence but overlaps Phase 27. | |
| Detection summary only | Too weak for `GEO-01`. | |
| Other | Freeform preference. | |

**User's choice:** Intent activation through tests.
**Notes:** Phase 27 remains responsible for saved-output geometry evidence.

### Should Phase 26 modify `BeautyExampleRenderer`?

| Option | Description | Selected |
|--------|-------------|----------|
| No new renderer cases yet | Keep renderer matrix unchanged; saved-output renderer cases belong to Phase 27. | ✓ |
| Add hidden/test-only renderer geometry case | Useful smoke test but blurs Phase 26/27 boundary. | |
| Add public geometry renderer case now | Expands renderer output scope. | |
| Other | Freeform preference. | |

**User's choice:** No new renderer cases yet.
**Notes:** Preserves Phase 24 renderer matrix contract.

### Which test layer should be the primary gate for Phase 26?

| Option | Description | Selected |
|--------|-------------|----------|
| Focused SDK facade tests plus existing resolver/detection tests | Add or update public `BeautySDK` facade tests, with internal/SPI seams only where needed. | ✓ |
| Internal target tests only | Easier internals, but insufficient for a facade phase. | |
| End-to-end Demo simulator tests | Higher integration surface but out of scope for v1.5 no-UI work. | |
| Other | Freeform preference. | |

**User's choice:** Focused SDK facade tests plus existing resolver/detection tests.
**Notes:** Provider/render tests are supporting evidence only.

### Should Phase 26 update status ledgers for `脸型` tools?

| Option | Description | Selected |
|--------|-------------|----------|
| No implementation status changes yet | Document foundation only; keep `SHAPE_FEATURE_LEDGER.md` rows `partial` until Phase 28 saved-output evidence. | ✓ |
| Mark routed tools as implemented | Premature under current evidence ladder. | |
| Add a temporary “foundation ready” marker | Adds a new status concept not in the ledger contract. | |
| Other | Freeform preference. | |

**User's choice:** No implementation status changes yet.
**Notes:** Phase 26 may document routing foundation, but not tool completion.

---

## Diagnostics and Redaction Surface

### What public evidence should show that geometry routing happened?

| Option | Description | Selected |
|--------|-------------|----------|
| Redacted summary + stable numeric metrics | Public result may show summary availability/reasons/counts and stable aggregate metrics only. | ✓ |
| Warnings only | Safer but weaker for tests and evidence. | |
| Debug-only details | Useful later but creates new debug payload surface. | |
| Other | Freeform preference. | |

**User's choice:** Redacted summary plus stable numeric metrics.
**Notes:** No coordinates, boxes, landmarks, raw Vision, or control points.

### Which metric shape is acceptable for geometry evidence?

| Option | Description | Selected |
|--------|-------------|----------|
| Counts and flags only | Numeric counts/flags such as active/skipped domains, aggregate geometry counts, capped/weakened counts, reused scale, and detection count/timing. | ✓ |
| Per-domain point counts | More diagnostic detail but starts revealing geometry structure. | |
| Coordinates under debug mode | Conflicts with current privacy/security contracts. | |
| Other | Freeform preference. | |

**User's choice:** Counts and flags only.
**Notes:** Metrics remain aggregate and non-coordinate.

### How should raw leak prevention be verified in Phase 26?

| Option | Description | Selected |
|--------|-------------|----------|
| Tests plus active-source scans | Assert result payload redaction and run scoped scans over SDK core/facade/detection/effects and active Demo surfaces where relevant. | ✓ |
| Tests only | Good for result payloads but weaker against accidental source-surface regressions. | |
| Scans only | Broad guard but weaker for exact result behavior. | |
| Other | Freeform preference. | |

**User's choice:** Tests plus active-source scans.
**Notes:** Keeps Phase 25-style active leak evidence.

### If a metric name like `geometryPointCount` is too revealing, what should planner/executor do?

| Option | Description | Selected |
|--------|-------------|----------|
| Rename to a safer stable aggregate | Prefer redacted aggregate naming and update tests/docs together. | ✓ |
| Keep existing metric names no matter what | Less churn but preserves potential privacy concern. | |
| Remove geometry metrics entirely | Safest but makes `GEO-01`/`GEO-02` harder to prove. | |
| Other | Freeform preference. | |

**User's choice:** Rename to a safer stable aggregate.
**Notes:** Keep numeric non-coordinate evidence; rename if privacy review requires it.

---

## the agent's Discretion

- Exact internal type names.
- SPI/test detector seam shape.
- Minimal adapter implementation details.
- Safe aggregate metric names.
- Focused test filenames and scan commands.
- Evidence artifact filenames.

## Deferred Ideas

- Full multi-face geometry routing.
- Full production Vision landmark point extraction.
- `BeautyExampleRenderer` geometry cases and saved PNG evidence.
- `脸型` second-level tool status completion.
- Public geometry-lite debug data, face tokens, coordinates, boxes, landmarks, and control points.
