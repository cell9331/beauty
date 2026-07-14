# Phase 29: Eye Renderer Output Evidence - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-09
**Phase:** 29-Eye Renderer Output Evidence
**Areas discussed:** Eye Renderer Case Matrix, Helper Evidence Gate, Output Gallery Documentation Boundary

---

## Eye Renderer Case Matrix

### Scope of renderer cases

| Option | Description | Selected |
|--------|-------------|----------|
| Per-tool only | Add `eyeSize`, `eyeDistance` positive/negative, `eyeYPosition` positive/negative, and `eyeTailLift`; no combo requirement. | ✓ |
| Per-tool plus combo | Add the six per-tool directional cases plus an `eyeCombo_*` case. | |
| Combo first | Add one combined eye case first and defer per-tool evidence. | |

**User's choice:** Per-tool only.
**Notes:** The user selected the recommended option. This matches Phase 28 per-tool evidence and avoids making combo output a status prerequisite.

### Naming and strengths

| Option | Description | Selected |
|--------|-------------|----------|
| Moderate per-cap values | Use `eyeSize_0p35`, `eyeDistance_plus0p25`, `eyeDistance_minus0p25`, `eyeYPosition_plus0p20`, `eyeYPosition_minus0p20`, and `eyeTailLift_0p25`. | ✓ |
| Max-cap evidence values | Use cap-level values such as `eyeSize_0p45`, `eyeDistance_plus0p30`, `eyeYPosition_plus0p25`, and `eyeTailLift_0p30`. | |
| Planner decides after fixture probe | Let the planner choose the smallest values that pass top-region checks. | |

**User's choice:** Moderate per-cap values.
**Notes:** Values should be conservative but visible enough to pass the helper.

### Signed direction coverage

| Option | Description | Selected |
|--------|-------------|----------|
| Both signed directions for `eyeDistance` and `eyeYPosition` | Require positive and negative cases for both signed fields. | ✓ |
| Only one direction per signed field | Lighter matrix, but leaves one direction unproven. | |
| Both directions plus negative `eyeTailLift` check | Broader, but drifts toward Phase 30 safety behavior. | |

**User's choice:** Both signed directions for `eyeDistance` and `eyeYPosition`.
**Notes:** Negative `eyeTailLift` is not required in Phase 29.

### No-face output requirement

| Option | Description | Selected |
|--------|-------------|----------|
| One no-face eye output presence check | Require no-face output for a representative eye case, likely `eyeSize_0p35`. | ✓ |
| No no-face eye requirement in Phase 29 | Leave no-face entirely to Phase 30. | |
| No-face output for every eye case | Exhaustive but unnecessary for this renderer evidence phase. | |

**User's choice:** One no-face eye output presence check.
**Notes:** Phase 30 still owns focused no-face and missing-eye safety/degradation tests.

---

## Helper Evidence Gate

### Helper scope

| Option | Description | Selected |
|--------|-------------|----------|
| Full matrix plus eye-specific checks | Verify all expected outputs, then run eye-vs-baseline checks for eye cases. | ✓ |
| Eye cases only | Smaller helper, but weaker matrix drift detection. | |
| Two helpers | Separate broad and eye-only helpers, but more commands to maintain. | |

**User's choice:** Full matrix plus eye-specific checks.
**Notes:** This mirrors the Phase 28 helper shape.

### Portrait comparison threshold

| Option | Description | Selected |
|--------|-------------|----------|
| Every portrait x every eye case must differ above watermark | Require 6 portraits x 6 eye cases = 36 comparisons. | ✓ |
| At least one passing portrait per eye case | More tolerant, but weaker completion evidence. | |
| Majority threshold | Flexible, but less deterministic. | |

**User's choice:** Every portrait x every eye case.
**Notes:** The helper should require 36/36 eye-vs-baseline top-region comparisons.

### Failed comparison handling

| Option | Description | Selected |
|--------|-------------|----------|
| Fail and fix before claiming Phase 29 complete | Adjust implementation, strength, or fixture handling until every required comparison passes. | ✓ |
| Record limitation and continue | Useful for genuine fixture weakness, but blocks strong completion wording. | |
| Drop weak fixture from helper | Fast, but weakens the fixture contract. | |

**User's choice:** Fail and fix before claiming Phase 29 complete.
**Notes:** Phase 29 completion should remain command-backed.

### Output path naming

| Option | Description | Selected |
|--------|-------------|----------|
| Use `example-images/output` as canonical | Align with current renderer default, README, ignore policy, and recent ledger entries. | ✓ |
| Keep accepting both `out` and `output` | Preserves stale command text. | |
| Leave path choice to command invocations | Flexible, but risks scattered evidence paths. | |

**User's choice:** Use `example-images/output` as canonical.
**Notes:** Older docs still saying `out` should be updated when touched.

---

## Output Gallery Documentation Boundary

### Gallery grouping

| Option | Description | Selected |
|--------|-------------|----------|
| Add an `eyes/` gallery group | Update `example-images/generate_gallery.py` and docs; generated files remain ignored. | ✓ |
| No gallery update in Phase 29 | Machine evidence only, but generated review UI lags. | |
| Let Phase 30 update gallery | Defers organization until closeout. | |

**User's choice:** Add an `eyes/` gallery group.
**Notes:** This keeps generated human-review artifacts aligned with the renderer matrix.

### Document update boundary

| Option | Description | Selected |
|--------|-------------|----------|
| Renderer evidence docs only | Update renderer/evidence docs and planning ledgers; do not promote `SHAPE_FEATURE_LEDGER.md`. | ✓ |
| Include provisional ledger notes | More traceability, but risks premature status drift. | |
| Only phase-local artifacts | Safer, but leaves renderer docs stale. | |

**User's choice:** Renderer evidence docs only.
**Notes:** Phase 30 owns `SHAPE_FEATURE_LEDGER.md` status promotion.

### Dedicated evidence artifact

| Option | Description | Selected |
|--------|-------------|----------|
| `29-EYE-RENDERER-EVIDENCE.md` | Record exact commands, counts, dimensions, comparisons, no-face presence, ignore checks, and limitations. | ✓ |
| Only use `29-VERIFICATION.md` later | Fewer files, but blends detailed renderer evidence with final verification. | |
| Rely on helper stdout and `PLANS.md` | Too light for downstream audit. | |

**User's choice:** Create `29-EYE-RENDERER-EVIDENCE.md`.
**Notes:** The evidence artifact is separate from final verification.

### Status wording

| Option | Description | Selected |
|--------|-------------|----------|
| Evidence complete, status still partial | Renderer evidence may be complete, but `眼睛` rows/branch remain partial until Phase 30. | ✓ |
| Promote implemented after renderer evidence | Violates Phase 30 ownership. | |
| Avoid all status wording | Safe, but less useful downstream. | |

**User's choice:** Evidence complete, status still partial.
**Notes:** Phase 29 must not claim full `眼睛` completion.

---

## the agent's Discretion

- Exact helper filename and test method names.
- Exact scan command shapes and evidence wording.
- Whether to extend or mirror the Phase 28 helper, as long as the Phase 29 helper enforces the locked output matrix and 36/36 comparison gate.

## Deferred Ideas

- Eye combo renderer output.
- Eye status promotion and branch closeout.
- New eye tools without existing public parameters.
- Demo UI, commercial quality, device parity, broad Meitu parity, generated PNG baselines, network/cloud behavior, and release-readiness claims.
