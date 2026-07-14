# Phase 27: Geometry Render Output and Verification Harness - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-07
**Phase:** 27-Geometry Render Output and Verification Harness
**Areas discussed:** Saved-output path, First geometry scope, Evidence bar, Degradation matrix

---

## Saved-output Path

| Option | Description | Selected |
|--------|-------------|----------|
| Add geometry cases to `BeautyExampleRenderer` | Use the existing public-facade saved-output path and Phase 24 invariant pattern. | ✓ |
| Create an equivalent SDK-only verification path | Keep the current renderer matrix separate, but add another evidence surface to maintain. | |
| Start with tests only, no saved PNG command | Lower scope, but weaker against `GEO-03`. | |

**User's choice:** Renderer-first hybrid.
**Notes:** The user initially selected options 1, 2, and 3 together. On confirmation, they selected the renderer-first hybrid: add geometry cases to `BeautyExampleRenderer`, back them with focused tests/helper checks, and create a separate SDK-only verifier only if the renderer cannot cover a required degradation case.

| Option | Description | Selected |
|--------|-------------|----------|
| Append geometry cases to the existing matrix | Keep one executable and one output directory; update invariant helpers/docs to include geometry cases. | ✓ |
| Add a separate geometry-only mode | Same executable, but geometry cases are opt-in so the current 45-output matrix stays unchanged by default. | |
| Create separate geometry case groups in code/docs only | Still one command, but clearly separate skin/color/filter from geometry in evidence and docs. | |

**User's choice:** Append geometry cases to the existing matrix.
**Notes:** Docs and helper checks should expand with the matrix.

| Option | Description | Selected |
|--------|-------------|----------|
| Use existing fixture images with real facade detection first | Proves the public path most directly; if fixture detection is unstable, planner adds a narrow fallback verifier. | ✓ |
| Add a renderer-only deterministic fixture seam | More stable, but risks weakening public-facade evidence unless carefully bounded. | |
| Use SPI test detector for saved-output generation | Deterministic, but less representative of host-facing integration. | |

**User's choice:** Use existing fixture images with real facade detection first.
**Notes:** This keeps `BeautyExampleRenderer` as the main public-facade proof.

| Option | Description | Selected |
|--------|-------------|----------|
| Fallback verifier only | Keep renderer cases real-facade-first, and add a narrow SDK-only verifier for unstable degradation cases. | ✓ |
| Replace unstable fixtures | Choose or add better local portrait fixtures so `BeautyExampleRenderer` remains the only saved-output path. | |
| Use SPI detector for selected geometry cases | Deterministic renderer outputs, but clearly label them SPI-assisted evidence. | |

**User's choice:** Fallback verifier only.
**Notes:** The fallback verifier is allowed only for unstable cases and should not displace the public renderer proof.

---

## First Geometry Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Face-shape first, with supporting degradation | Prove the `脸型`-relevant path needed for Phase 28; keep eye/nose/mouth saved outputs out unless needed for shared degradation. | ✓ |
| All existing geometry domains | Face, eyes, nose, mouth, and lip region all get saved-output cases now. | |
| Representative mixed geometry case | One combined face/eye/nose/mouth case plus degradation, but not per-domain coverage. | |

**User's choice:** Face-shape first, with supporting degradation.
**Notes:** Phase 27 should not broaden into all geometry domains.

| Option | Description | Selected |
|--------|-------------|----------|
| One combined face-shape case | Use existing `faceSlim`, `faceSmall`, `faceVShape`, `jawSlim`, and `chinLength` together at moderate strengths. | ✓ |
| Separate case per parameter | Clearer per-tool evidence, but expands output count and may overlap Phase 28. | |
| Two cases: slim/V and jaw/chin | Balances breadth with output count. | |

**User's choice:** One combined face-shape case.
**Notes:** Per-tool evidence is left to Phase 28.

| Option | Description | Selected |
|--------|-------------|----------|
| No, keep them out unless needed for degradation | Avoids expanding Phase 27 beyond `GEO-03`/`GEO-04`; Phase 28 focuses `脸型`. | ✓ |
| Add one mixed all-geometry case | Useful smoke evidence for shared route, but broadens output claims. | |
| Add them as metrics/tests only, not saved PNG cases | Keeps saved-output proof face-shape focused while checking shared route behavior. | |

**User's choice:** Keep lip, eye, nose, and mouth outputs out unless needed for degradation.
**Notes:** Shared route checks may remain tests/helper evidence.

| Option | Description | Selected |
|--------|-------------|----------|
| Foundation only | Phase 27 proves geometry saved-output infrastructure; Phase 28 owns per-tool `脸型` evidence and ledger promotion. | ✓ |
| Pre-fill Phase 28 evidence | Phase 27 creates enough per-tool saved output that Phase 28 can mostly document and promote. | |
| Promote only shared geometry status | Update docs to say geometry output foundation exists, but do not mark tools implemented. | |

**User's choice:** Foundation only.
**Notes:** Phase 28 still owns `脸型` completion and status promotion.

---

## Evidence Bar

| Option | Description | Selected |
|--------|-------------|----------|
| Same dimensions + non-identical output + redacted geometry metrics | Matches Phase 24 style while adding geometry-specific evidence. | ✓ |
| Pixel-stable deterministic hashes | Stronger regression gate, but may be brittle across Core Image/renderer environments. | |
| Manual visual notes required for every geometry output | Helpful, but risks subjective quality claims. | |

**User's choice:** Same dimensions, non-identical output, and redacted geometry metrics.
**Notes:** Avoid brittle hashes and subjective review gates.

| Option | Description | Selected |
|--------|-------------|----------|
| Compare against no-geometry baseline | Proves the geometry parameter changed output beyond existing color/filter behavior. | ✓ |
| Compare against input image | Simpler, but a combined case with color/filter could pass without proving geometry. | |
| Compare against both | Strongest, but more helper work and output bookkeeping. | |

**User's choice:** Compare against no-geometry baseline.
**Notes:** This prevents color/filter effects from masking whether geometry changed output.

| Option | Description | Selected |
|--------|-------------|----------|
| No committed PNGs | Keep outputs under ignored `example-images/out/`, record commands/counts in Markdown. | ✓ |
| Commit selected representative PNGs | Easier to inspect later, but increases repo churn and binary baseline burden. | |
| Commit hashes/manifests only | Lighter than PNGs, but may still be brittle across environments. | |

**User's choice:** No committed PNGs.
**Notes:** Phase 27 should keep the Phase 24 generated-output policy.

| Option | Description | Selected |
|--------|-------------|----------|
| Representative factual notes only | Allow notes like dimensions, watermark readable, geometry case changed output; forbid quality/parity claims. | ✓ |
| No visual notes at all | Purely mechanical evidence. | |
| Manual notes for every output | More complete, but slower and more subjective. | |

**User's choice:** Representative factual notes only.
**Notes:** Notes must remain factual and non-claiming.

---

## Degradation Matrix

| Option | Description | Selected |
|--------|-------------|----------|
| No-face + missing-landmark + stale/reused + combined-strength | Covers `GEO-04` directly and matches roadmap language. | ✓ |
| Only no-face and missing-landmark saved outputs | Smaller, leaves stale/reused and combined-strength to tests/docs. | |
| Only mechanical tests for degradation, saved output for happy path | Weakest saved-output coverage but least renderer complexity. | |

**User's choice:** Cover no-face, missing-landmark, stale/reused, and combined-strength degradation paths.
**Notes:** This directly maps to `GEO-04`.

| Option | Description | Selected |
|--------|-------------|----------|
| Renderer PNG for happy path and no-face; tests/helper evidence for the rest | Avoids forcing hard-to-reproduce stale/reused/missing landmarks through real fixture detection. | ✓ |
| Renderer or fallback verifier output for every degradation path | Stronger evidence, but likely requires more deterministic seams. | |
| All degradation paths through `BeautyExampleRenderer` only | Clean surface, but may be brittle or impractical with real detection fixtures. | |

**User's choice:** Renderer PNG for happy path and no-face; tests/helper evidence for the rest.
**Notes:** Missing-landmark, stale/reused, and combined-strength can be covered with focused XCTest and helper/evidence summaries.

| Option | Description | Selected |
|--------|-------------|----------|
| Dedicated no-face fixture or fallback verifier | Try a local no-face fixture through the renderer; if awkward or unstable, use the narrow fallback verifier. | ✓ |
| Existing portrait fixtures only | No new fixture or fallback; accept no-face saved output only if current fixtures naturally produce it. | |
| Tests only for no-face | No no-face PNG; keep saved output to happy path. | |

**User's choice:** Dedicated no-face fixture or fallback verifier.
**Notes:** Do not rely on current portrait fixtures naturally producing no-face behavior.

| Option | Description | Selected |
|--------|-------------|----------|
| Focused XCTest + helper output summary | Tests assert redacted metrics/warnings and helper/evidence Markdown records exact cases without requiring PNGs for every path. | ✓ |
| Fallback verifier PNGs for all three | Stronger artifact coverage but more generated-output surface. | |
| XCTest only | Simplest, but weaker traceability for `GEO-04`. | |

**User's choice:** Focused XCTest plus helper output summary.
**Notes:** Applies to missing-landmark, stale/reused, and combined-strength paths.

| Option | Description | Selected |
|--------|-------------|----------|
| Raw geometry and overclaim wording | Forbid coordinates, landmarks, bounding boxes, control points, raw Vision/framework errors, local paths, image bytes, and quality/parity/release claims. | ✓ |
| Only raw geometry leakage | Allow broader product claims if outputs exist. | |
| Only quality overclaims | Rely on existing scans for geometry privacy. | |

**User's choice:** Raw geometry and overclaim wording.
**Notes:** Phase 27 evidence must stay privacy-safe and conservative.

---

## the agent's Discretion

- Choose exact geometry case IDs and moderate parameter strengths.
- Choose exact helper/test filenames and command shapes.
- Decide whether a fallback verifier is necessary after trying real-facade renderer evidence.
- Choose evidence document names and representative factual note format.

## Deferred Ideas

- Per-tool face-shape saved-output evidence and `SHAPE_FEATURE_LEDGER.md` promotion remain Phase 28 scope.
- Eye, nose, mouth, and lip saved-output cases remain out unless required for Phase 27 degradation evidence.
- A separate SDK-only verifier is a narrow fallback, not a parallel first-class evidence path.
- Committed PNG baselines, hash manifests, subjective visual-quality review, commercial readiness, broad device parity, and Meitu parity claims remain out of scope.
