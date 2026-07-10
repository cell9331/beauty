# Phase 30: Eye Safety, Ledger, and Closeout - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-10
**Phase:** 30-Eye Safety, Ledger, and Closeout
**Areas discussed:** Negative Input and Cap Semantics, Stale and Reused Eye Geometry Policy, Eye-Specific Evidence Gate, Boundary Scans and Ledger Promotion

---

## Negative Input and Cap Semantics

### Negative `eyeSize`

| Option | Description | Selected |
|--------|-------------|----------|
| Normalize to zero | Treat `eyeSize` as positive-only; negative input becomes zero without a missing-eye warning. | ✓ |
| Preserve signed value and skip | Keep the signed value but return a stable unsupported-direction degradation reason. | |
| Agent discretion | Let planning choose the smallest safe correction. | |

**User's choice:** Normalize to zero.
**Notes:** Visible negative eye shrinking is not added in Phase 30.

### Negative `eyeTailLift`

| Option | Description | Selected |
|--------|-------------|----------|
| Normalize to zero | Treat `eyeTailLift` as positive-only; negative input becomes zero without a missing-eye warning. | ✓ |
| Preserve signed value and skip | Keep the signed value but return a stable unsupported-direction degradation reason. | |
| Agent discretion | Let planning choose the smallest safe correction. | |

**User's choice:** Normalize to zero.
**Notes:** Visible downward-tail behavior is deferred.

### Cap assertion precision

| Option | Description | Selected |
|--------|-------------|----------|
| Lock direction and exact effective value | Prove signed `±cap` behavior for distance/Y, positive caps and negative-zero behavior for size/tail, plus warning and metric evidence. | ✓ |
| Assert only absolute cap bounds | Prove only that effective values do not exceed cap magnitude. | |
| Agent discretion | Let planning select the assertion depth. | |

**User's choice:** Lock direction and exact effective value.
**Notes:** Relational-only cap checks are insufficient for EYE-04.

### Abnormal public input

| Option | Description | Selected |
|--------|-------------|----------|
| Cover finite overflow and non-finite input for all four fields | Verify finite overflow plus `NaN`, positive infinity, and negative infinity; non-finite input becomes zero. | ✓ |
| Cover finite overflow only | Rely on generic parameter tests for non-finite values. | |
| Agent discretion | Let planning balance independent evidence and duplication. | |

**User's choice:** Cover finite overflow and non-finite input for all four fields.
**Notes:** EYE-04 should stand on an eye-specific public-input matrix.

---

## Stale and Reused Eye Geometry Policy

### Reused eye geometry

| Option | Description | Selected |
|--------|-------------|----------|
| Skip eye geometry completely | Do not activate eyes, generate eye points, or retain non-zero eye effective strengths on `.reused`. | ✓ |
| Preserve current reduced-strength reuse | Continue using reused eye geometry after weakening and reinterpret EYE-05. | |
| Agent discretion | Let planning resolve the requirements/root-contract conflict. | |

**User's choice:** Skip eye geometry completely.
**Notes:** This directly satisfies the Phase 30 no-reused-eye-geometry requirement.

### Other geometry domains on reused input

| Option | Description | Selected |
|--------|-------------|----------|
| Strict skip for eyes only | Keep face-shape, nose, and mouth reused-strength reduction unchanged. | ✓ |
| Skip every geometry domain | Apply the stricter policy across all geometry domains. | |
| Agent discretion | Let planning choose the behavior-change scope. | |

**User's choice:** Strict skip for eyes only.
**Notes:** Cross-domain freshness changes remain outside the eye-only phase.

### One missing eye group

| Option | Description | Selected |
|--------|-------------|----------|
| Skip the entire eye domain | Avoid asymmetric output and continue unaffected geometry and safe domains. | ✓ |
| Process the complete eye only | Apply partial single-eye output and accept asymmetry risk. | |
| Agent discretion | Let planning follow the provider contract. | |

**User's choice:** Skip the entire eye domain.
**Notes:** Phase 30 does not add partial single-eye visible behavior.

### Public skip reasons

| Option | Description | Selected |
|--------|-------------|----------|
| Separate stable redacted reasons | Distinguish missing-eye, reused-eye, and stale-eye skips; expose only state categories and aggregate counts. | ✓ |
| Merge reused and stale | Use one not-fresh eye skip reason; keep missing-eye distinct. | |
| Use one reason for every eye skip | Collapse input and freshness degradation into one warning. | |

**User's choice:** Separate stable redacted reasons.
**Notes:** Exact stable code names remain planner discretion; stale also skips eye geometry completely.

---

## Eye-Specific Evidence Gate

### EYE-05 evidence layers

| Option | Description | Selected |
|--------|-------------|----------|
| Public facade plus resolver/provider | Prove no-face dimensions/redaction/safe domains through `BeautyEngine`, and internal skip/zero/point behavior through resolver/provider tests. | ✓ |
| Resolver/provider only | Prove internal semantics and cite existing facade tests. | |
| Public facade only | Stay caller-facing but lose deterministic internal freshness/point assertions. | |

**User's choice:** Public facade plus resolver/provider.
**Notes:** EYE-05 requires layered evidence.

### EYE-06 combined matrix

| Option | Description | Selected |
|--------|-------------|----------|
| Per-behavior matrix plus all-domain case | Cover size, distance ±, vertical ±, and tail lift with representative face shape, then add one all-eye/multi-domain case. | ✓ |
| One all-eye/multi-domain case only | Use one broad combined test. | |
| Reuse generic combined tests only | Add no Phase 30-specific matrix. | |

**User's choice:** Per-behavior matrix plus all-domain case.
**Notes:** Signed directions must remain correct after weakening.

### Existing and new tests

| Option | Description | Selected |
|--------|-------------|----------|
| Reuse qualifying tests and add requirement-specific assertions | Avoid mechanical duplication and map EYE-04/05/06 to exact tests. | ✓ |
| Create an independent Phase 30 suite | Duplicate current cap, landmark, and combined coverage under new tests. | |
| Cite existing tests only | Add assertions only when an existing test fails. | |

**User's choice:** Reuse qualifying tests and add requirement-specific assertions.
**Notes:** Newly locked semantics require explicit coverage even when current generic tests are reused.

### Visible-output regression

| Option | Description | Selected |
|--------|-------------|----------|
| Rerun the full regression chain | Run focused and full SwiftPM tests, renderer build/run, and the 161/161 plus 36/36 Phase 29 helper. | ✓ |
| Run safety tests and cite Phase 29 | Do not regenerate or recheck saved output. | |
| Run focused tests only | Skip full SDK and visible-output regression. | |

**User's choice:** Rerun the full regression chain.
**Notes:** Gallery generation is required only if gallery logic changes.

---

## Boundary Scans and Ledger Promotion

### Scan scope and classification

| Option | Description | Selected |
|--------|-------------|----------|
| Active code zero tolerance with classified tests/docs | Hard-fail real active-source violations; classify guard literals, examples, and historical evidence; exclude build/generated/ignored worktree content. | ✓ |
| Whole-repository zero matches | Fail on every token match, including negative tests and scan documentation. | |
| Manual review without hard rules | Review every match without a predefined active-source failure policy. | |

**User's choice:** Active code zero tolerance with classified tests/docs.
**Notes:** Active public/SPI, SDK, Demo, and renderer source are the enforcement set.

### Promotion-blocking boundaries

| Option | Description | Selected |
|--------|-------------|----------|
| Every EYE-07 active failure blocks promotion | Raw geometry, internal imports, network/cloud, commercial paths, or new public fields block all four rows. | ✓ |
| Only row-specific failures block | Promote unaffected rows and record other boundary failures as debt. | |
| Boundary failures do not block | Promote from functional tests alone. | |

**User's choice:** Every EYE-07 active failure blocks promotion.
**Notes:** Violations must be fixed and scans rerun before promotion.

### Ledger promotion strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Atomic four-row promotion | Promote all four only after every safety, degradation, boundary, and output gate passes; otherwise keep all partial. | ✓ |
| Independent per-row promotion | Promote each row as its own evidence passes. | |
| Functional-evidence promotion | Treat safety or boundary gaps as non-blocking limitations. | |

**User's choice:** Atomic four-row promotion.
**Notes:** Branch-level `眼睛` remains `partial` in every outcome.

### Documentation synchronization

| Option | Description | Selected |
|--------|-------------|----------|
| Complete targeted sync by contract ownership | Update all owning eye, design, safety, reliability, product, quality, work, GSD, and phase-evidence documents; touch architecture/frontend only if changed. | ✓ |
| Update every root document | Mechanically touch architecture and frontend even without contract changes. | |
| Update only ledger and phase evidence | Leave changed parameter and freshness semantics out of root contracts. | |

**User's choice:** Complete targeted sync by contract ownership.
**Notes:** `ARCHITECTURE.md` and `FRONTEND.md` are conditional, not mandatory churn.

---

## the agent's Discretion

- Exact warning code names, while preserving distinct missing-eye, reused-eye, and stale-eye reasons.
- Exact test file organization and whether existing suites are extended or focused files are added.
- Exact table-driven helper structure, scan command/regex shapes, and evidence artifact names.
- `ARCHITECTURE.md` and `FRONTEND.md` updates only if their owned contracts actually change.

## Deferred Ideas

- Negative `eyeSize` visible shrinking behavior.
- Negative `eyeTailLift` visible downward-tail behavior.
- Strict reused-geometry skipping for non-eye geometry domains.
- New eye tools without existing public parameter/resource design.
- Demo UI, commercial quality, device parity, broad reference-app parity, generated PNG baselines, network/cloud behavior, entitlement behavior, and launch-readiness claims.
