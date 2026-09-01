# Phase 90 FACE-01 Revision 19 - Diagnostic-Only Research

**Researched:** 2026-09-01
**Domain:** request-local Swift provider instrumentation and privacy-safe failure classification
**Confidence:** HIGH for the diagnostic architecture and rollback contract; LOW for the still-unobserved earliest revision-18 gate

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Preserve exactly 62 public parameter fields, five presets, 75 renderer cases,
  both public still-image facade signatures, and the current CPU/GPU contract.
- Do not change retained `Warp.metal`, add a Metal/GPU API/backend, add public
  controls, restore UI/Demo code, or introduce models, weights, datasets,
  network paths, realtime/video work, or device/commercial claims.
- Keep the exact established safety caps, neutral identity, request-local
  support ownership, per-control degradation, privacy-safe diagnostics, and
  source-safe collision behavior.
- Do not weaken Phase 89 semantic thresholds to make a repair pass and do not
  borrow another control's semantic support or behavior as a proxy.

### the agent's Discretion
All implementation choices are at the agent's discretion — discuss phase was
skipped per user setting. Use the ROADMAP success criteria, the frozen Phase 89
semantic contracts, `DESIGN.md`, `ARCHITECTURE.md`, `RELIABILITY.md`,
`SECURITY.md`, `QUALITY_SCORE.md`, and existing provider/resolver conventions.

### Deferred Ideas (OUT OF SCOPE)
Independent gaze, eyebrow-head spacing, nose, mouth-width, the final complete
eight-direction portrait rerun, local-retouch optimization, and all external or
device evidence remain assigned to Phases 91-95 or future milestones.
</user_constraints>

The text above is copied verbatim from `90-CONTEXT.md`; its locked boundaries
remain authoritative for revision 19. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-CONTEXT.md]

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|---|---|---|
| FACE-01 | Positive `faceContourSmooth` must produce detectable contour-local continuity, remain distinct from the named siblings, and preserve bounded protected regions. | Revision 19 does not satisfy FACE-01; it only identifies why revision 18 returned an empty pre-render field so a later separately authorized plan can make an evidence-based decision. [CITED: .planning/REQUIREMENTS.md] |
</phase_requirements>

## Project Constraints (from AGENTS.md)

- Keep the repository SDK-only; historical UI/Demo material is not an implementation or test input. [CITED: AGENTS.md]
- Use SwiftPM and SDK-owned scripts as mandatory evidence; physical-iPhone feedback remains optional and cannot block this diagnostic. [CITED: AGENTS.md]
- Persist no raw masks, landmarks, pixels, coordinates, private fixture locators, generated images, or child transcripts. [CITED: AGENTS.md]
- Preserve retained `Warp.metal`, the renderer/backend contract, the `62/5/75` public inventory, and the owner-local non-distribution boundary. [CITED: AGENTS.md]
- Use `apply_patch` for every edit and rollback, preserve unrelated work, and update planning records without altering archived milestone evidence. [CITED: AGENTS.md]
- Apply the project skill's request-local support, fail-closed ownership, privacy-safe diagnostic, and mechanics-only evidence rules. [CITED: .codex/skills/spike-findings-beauty/SKILL.md]

## Summary

Revision 19 must be a **diagnostic-only reconstruction**, not another FACE-01
candidate. Revision 18's temporary provider and test bytes were restored and
are not retained; the only recovered implementation identifiers are
`d1V18Template`, `finalizedD1V18Points`, and `d1FieldPassesSafety`. The durable
record proves only that the final cap and half fields were both empty (`0/20`),
which cannot distinguish a nil/empty template from a later finalizer or safety
abstention. [VERIFIED: read-only revision-18 recovery audit supplied in task context; .planning/phases/90-face-contour-and-chin-repairs/90-01-ATTEMPT.md]

Reconstruct the already-planned revision-18 pipeline exactly, but make one
request-local construction result carry its in-memory template, provider cap
and half finalizations, sanitized earliest-failure gate, and aggregate counts.
The diagnostic test must consume that one result once and independently apply
the frozen finalization arithmetic to the same request-local template. This
separates a provider implementation defect from a construction that genuinely
fails its frozen gates without creating a second geometry construction, global
state, rendering path, or oracle call. [VERIFIED: codebase architecture analysis]

The current `scripts/verify-phase90-face01-stop.py` is unsafe for this purpose
in normal mode because it calls `swift test` through `capture_red()` and thereby
invokes the frozen rendered oracle. Revision 19 may run that script only with
`--help`; planning must add a new static verifier that never launches Swift or
another subprocess. [VERIFIED: scripts/verify-phase90-face01-stop.py lines 35-58 and 121-144]

**Primary recommendation:** plan one bounded diagnostic execution that returns
exactly one of `implementation_defect`, `genuine_construction_miss`,
`prior_stop_not_reproduced`, or `diagnostic_invalid`, then restores every
temporary provider/test byte exactly and stops without rendering, oracle
invocation, construction changes, threshold changes, or downstream Phase 90
execution. [VERIFIED: owner authorization and diagnostic boundary]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Revision-18 template reconstruction | `BeautyEffects` provider | `BeautyEffectsTests` | The provider owns request-local observed-contour construction; tests may inspect it only in memory. [CITED: BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift] |
| Earliest-gate facts | request-local provider result | independent test classifier | The provider reports gate facts; it must not self-author the final outcome classification. [VERIFIED: diagnostic separation analysis] |
| Cap/half reference finalization | test-only reference function | shared provider template | The reference consumes the same template and frozen formulas without constructing geometry again. [VERIFIED: diagnostic separation analysis] |
| Persistent diagnostic evidence | append-only ATTEMPT suffix | new static verifier | Only fixed enums, counts, hashes, and optional fixed-point margins may survive rollback. [CITED: SECURITY.md; RELIABILITY.md] |
| Rendering and semantic acceptance | none in revision 19 | frozen oracle remains untouched | Revision 19 has no render or semantic authority. [CITED: .planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md] |

## Standard Stack

### Core

| Tool | Version | Purpose | Why Standard |
|---|---|---|---|
| Swift / SwiftPM | Swift 6.3.3; package tools 6.0 | Compile the temporary package-internal diagnostic and run one narrow XCTest | Already owns the SDK and all current provider tests; no dependency is added. [VERIFIED: local `swift --version`; BeautySDK/Package.swift] |
| XCTest | Swift toolchain bundled | Assert the one-result contract and independent classification | Existing `BeautyEffectsTests` infrastructure already owns FACE-01 provider coverage. [CITED: BeautySDK/Package.swift; FaceContourSmoothRepairTests.swift] |
| Python standard library | 3.9.6 | Implement the static source/ledger/rollback verifier | Existing repository verification uses Python standard-library hashing and parsing. [VERIFIED: local `python3 --version`; scripts/verify-phase90-face01-stop.py] |

### Supporting

| Tool | Version | Purpose | When to Use |
|---|---|---|---|
| Git | 2.50.1 | Read-only diff/status evidence and the final documentation commit | Use after static verification; do not use checkout/reset for rollback. [VERIFIED: local `git --version`; AGENTS.md] |
| ripgrep | 15.1.0 | Plain-text boundary scans | Use for forbidden render/oracle/global-state tokens and exact symbol counts. [VERIFIED: local `rg --version`; AGENTS.md] |

No external package, Swift dependency, model, service, or network access is
needed, so package legitimacy and installation audits are not applicable.
[VERIFIED: repository/package inspection]

## Architecture Patterns

### System Architecture Diagram

```text
generated in-memory FACE-01 support
                |
                v
  d1V19DiagnosticConstruction(face:)       (exactly one call)
                |
                v
  shared request-local D1V18 template result
       |                            |
       |                            +--> provider cap/half finalizers
       |                                      |
       +--> test-only reference finalizer <---+
                          |
                          v
       sanitized counts + earliest gate comparison
                          |
          +---------------+----------------+
          |               |                |
          v               v                v
 implementation_defect  genuine_miss  stop_not_reproduced
          \               |                /
           +--------------+---------------+
                          |
               byte-exact provider/test rollback
                          |
               strict static verifier only
                          |
          optional aggregate-only 11th suffix
```

The path has no renderer, `BeautyEngine`, `CIContext`, `applyMVPProxy`, frozen
oracle, private fixture, file-output, or network edge. [VERIFIED: authorized
diagnostic boundary]

### Recommended Temporary Structure

```text
BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift
  D1V19Gate                         # fixed ordered, sanitized enum
  D1V19ConstructionResult           # request-local template + aggregate facts
  d1V19DiagnosticConstruction       # one reconstruction entry point
  d1V18Template                     # recovered role; frozen v18 construction
  finalizedD1V18Points              # recovered role; frozen v18 finalization
  d1FieldPassesSafety               # recovered role; frozen gate checks

BeautySDK/Tests/BeautyEffectsTests/FaceContourSmoothRepairTests.swift
  testFACE01D1V19DiagnosticOnlyClassification
  referenceFinalizeD1V18Template    # independent, same in-memory template

scripts/verify-phase90-face01-diagnostic.py
  preflight                         # static source/boundary checks only
  rollback                          # hashes/prefix/suffix/diff checks only
```

Every temporary Swift diagnostic symbol must be removed during rollback; the
new static verifier may remain as repository tooling only if Wave 0 plans,
self-tests, and commits it before diagnostic execution. [VERIFIED: rollback and
ledger design]

### Pattern 1: One Construction, Two Independent Finalization Views

**What:** create the revision-18 template once, retain it only inside one
request-local result, and derive provider/reference cap and half facts from that
same template. [VERIFIED: diagnostic design]

**When to use:** only in the revision-19 diagnostic test; production behavior
must be restored after classification. [VERIFIED: owner authorization]

```swift
// Source: project-specific diagnostic pattern derived from the retained
// FaceShapeWarpProvider request-local architecture.
let inspection = provider.d1V19DiagnosticConstruction(face: generatedFace)
// Exactly one provider construction call above.
let reference = referenceFinalizeD1V18Template(inspection.template)
let outcome = classify(provider: inspection.aggregate, reference: reference)
```

The provider must return facts rather than the final classification so the test
does not accept a component's self-reported diagnosis. [VERIFIED: independent
classification requirement]

### Pattern 2: Fixed Earliest-Gate Order

Use this exact order, matching the frozen revision-18 plan. The first failed
category is recorded once; later categories remain `not_reached`. [CITED:
.planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md]

| Order | Enum Case | Required Aggregate |
|---:|---|---|
| 1 | `request_admission` | admitted/rejected only [VERIFIED: plan gate order] |
| 2 | `canonical_branches` | left/right branch counts [VERIFIED: plan gate order] |
| 3 | `slots_extrema_zones` | left/right analytical slot counts [VERIFIED: plan gate order] |
| 4 | `residuals_and_zero_omission` | left/right retained counts [VERIFIED: plan gate order] |
| 5 | `raw_exact_lattice` | aggregate accepted/rejected count [VERIFIED: plan gate order] |
| 6 | `source_clearance_clip` | aggregate accepted/rejected status [VERIFIED: plan gate order] |
| 7 | `exact_linkage_and_half_admission` | linkage failure count only [VERIFIED: plan gate order] |
| 8 | `target_clearance_and_radius` | pass/fail plus optional scaled margin [VERIFIED: plan gate order] |
| 9 | `owner_unit_slack_expanded` | aggregate failure count [VERIFIED: plan gate order] |
| 10 | `overlap_topology` | permitted/forbidden aggregate counts [VERIFIED: plan gate order] |
| 11 | `single_safety` | optional Q16 first-failure margin [VERIFIED: plan gate order] |
| 12 | `adjacent_lipschitz_inverse` | optional Q16 first-failure margin [VERIFIED: plan gate order] |
| 13 | `branch_chain_proxy` | optional Q40 first-failure margin [VERIFIED: plan gate order] |
| 14 | `strength_finalization` | cap-template/cap/half admitted counts [VERIFIED: plan gate order] |
| 15 | `point_budget` | final aggregate count only [VERIFIED: plan gate order] |
| — | `none` | every pre-render gate passed; still no render/oracle authority [VERIFIED: diagnostic boundary] |

`diagnostic_invalid` is not a provider gate. It is an external verdict when the
harness, static verifier, invariants, compilation, execution, parsing, or
rollback contract is not trustworthy. [VERIFIED: separation analysis]

### Pattern 3: Minimum Aggregate Contract

The sanitized result must expose only: one construction-invocation count; first
failure enum and stage; canonical branch counts; analytical slot counts;
retained branch counts; cap-template count before strength finalization;
provider cap and half admitted counts; independent-reference cap and half
counts; and one optional signed fixed-point first-failure margin. [VERIFIED:
owner-authorized minimum instrumentation]

The expected frozen generated shape is two canonical branches, twelve
analytical slots per branch, ten retained emitters per branch, and a 20-point
cap template, but those values are assertions to measure rather than values to
fabricate when an earlier gate fails. [CITED:
.planning/phases/90-face-contour-and-chin-repairs/90-01-REV18-RESEARCH.md]

No result or suffix may contain a point, source/target/radius value, owner
rectangle, contour coordinate, pixel, path, fixture identity, or child output.
[CITED: SECURITY.md; AGENTS.md]

### Pattern 4: Independent Outcome Decision Table

Apply these rules in order after one diagnostic test run and after the static
preflight succeeds. [VERIFIED: diagnostic decision analysis]

| Priority | Condition | Outcome |
|---:|---|---|
| 1 | Compile/test result, one-call rule, enum order, diagnostic aggregate invariants, no-render/oracle scan, bounded marker parse, or rollback verification fails | `diagnostic_invalid` [VERIFIED: diagnostic validity contract] |
| 2 | The diagnostic is valid, but a frozen-contract conformance check identifies an implementation-only deviation, or provider cap/half counts differ from the independent reference counts computed from the same template | `implementation_defect` [VERIFIED: frozen-contract and independent differential rule] |
| 3 | No implementation deviation is found and provider/reference agree, but provider cap/half counts are not both zero | `prior_stop_not_reproduced` [VERIFIED: durable prior stop was cap=0, half=0] |
| 4 | No implementation deviation is found, provider/reference agree, cap/half counts are both zero, and the reported earliest failure is a faithfully evaluated frozen data/safety gate | `genuine_construction_miss` [VERIFIED: faithful frozen construction reproduces whole-field abstention] |

Partial or asymmetric provider output is not silently normalized: if it agrees
with the reference it is `prior_stop_not_reproduced`; if it disagrees it is
`implementation_defect`. [VERIFIED: exhaustive decision table]

Every outcome remains diagnostic evidence only. It neither authorizes a source
fix nor permits the frozen candidate oracle, Tasks 90-01-02/03, or Plans
90-03/04. [VERIFIED: owner authorization boundary]

### Pattern 5: Static Verifier Instead of the Existing Stop Verifier

Create `scripts/verify-phase90-face01-diagnostic.py` from the Python standard
library and prohibit `subprocess`, `os.system`, Swift execution, file writes,
and network access. It must only read bytes, hash, parse fixed source slices,
inspect `git status`, and print a fixed terminal marker. [VERIFIED: static
verification design]

Its `preflight` mode must prove: the frozen oracle method hash is unchanged;
the diagnostic test slice contains exactly one diagnostic-construction call;
the slice contains none of `render(`, `applyMVPProxy`, `semanticSnapshot`,
`CIContext`, `CIImage`, or the frozen oracle method call; the provider adds no
mutable global/static state, logging, file/environment/network access, public
API, renderer, backend, or shader seam; and the ATTEMPT file still equals the
captured ten-heading prefix. [VERIFIED: boundary analysis]

Preflight must report diagnostic-harness violations separately from
revision-18 scaffold deviations. A harness violation makes the result
`diagnostic_invalid`; a valid harness that exposes a concrete wrong frozen
formula, wrong input, wrong gate order, or provider/reference finalization
divergence supports `implementation_defect`. Absence of the original temporary
revision-18 bytes means source identity itself cannot be claimed; if the
reconstruction cannot be shown equivalent to the frozen plan and recovered
roles, the conservative outcome is `diagnostic_invalid`, not a guessed defect.
[VERIFIED: recovery-evidence limitation and classification analysis]

Its `rollback` mode must prove: provider and complete repair-test hashes are
byte-exact baseline values; all other temporary Swift artifacts are restored or
absent; no `90-01-SUMMARY.md` exists; the ten-heading ATTEMPT prefix remains
byte-exact; the suffix is absent or exactly one schema-valid eleventh section;
and the diff allowlist contains only declared planning/evidence files. [VERIFIED:
rollback design]

At research time the current ATTEMPT prefix is exactly 21,739 bytes, has SHA-256
`90d3d33ce495cde92d1fcecea11239d65776bf109ee019d27049eb4694a3c183`,
and contains exactly ten dated retry headings. The execution plan must recapture
and pin these values immediately before editing rather than trusting research
age. [VERIFIED: local byte/hash/heading scan]

### Anti-Patterns to Avoid

- **Calling `fieldEmissions` once for cap and again for half:** this rebuilds geometry and cannot prove both strengths came from one request-local template. [VERIFIED: diagnostic design]
- **Letting the provider emit `implementation_defect`:** a component cannot independently classify its own implementation. [VERIFIED: separation analysis]
- **Using a second template in the reference path:** this confounds construction drift with finalizer behavior. [VERIFIED: differential diagnosis analysis]
- **Running the existing stop verifier normally:** its `capture_red()` launches the frozen oracle. [VERIFIED: scripts/verify-phase90-face01-stop.py]
- **Printing coordinates or a complete test transcript:** only fixed aggregate fields may persist. [CITED: SECURITY.md; RELIABILITY.md]
- **Treating `none` as GREEN:** it means only that pre-render diagnosis reached the end; revision 19 still forbids rendering and semantic acceptance. [VERIFIED: diagnostic boundary]

## Don't Hand-Roll or Reopen

| Problem | Don't Build or Change | Use Instead | Why |
|---|---|---|---|
| Diagnostic state sharing | global/static mutable counters or caches | one local result value passed directly to the test | Shared mutable state can leak across requests and invalidate isolation. [CITED: RELIABILITY.md] |
| Geometry comparison | a second independently reconstructed template | one provider template plus a reference finalizer | The diagnostic question is finalizer behavior, not two construction implementations. [VERIFIED: differential design] |
| Failure taxonomy | free-form strings or raw errors | fixed ordered enums and bounded counts | Fixed categories are privacy-safe and mutation-testable. [CITED: SECURITY.md] |
| Rollback proof | the current stop verifier in normal mode | the new non-executing static verifier | The old verifier invokes the frozen oracle. [VERIFIED: script inspection] |
| Numerical diagnosis | raw per-point values | one signed Q16/Q24/Q40 aggregate margin only when the first failing numerical gate requires it | Aggregate fixed-point evidence identifies the boundary without persisting geometry. [CITED: SECURITY.md; RELIABILITY.md] |

**Key insight:** the diagnostic must compare two finalization views of one
in-memory construction, then destroy both views; otherwise it either repeats the
unknown construction or persists anatomy to explain it. [VERIFIED: diagnostic
and privacy analysis]

## Common Pitfalls

### Conflating Template Absence with Finalizer Abstention

**What goes wrong:** a final empty `fieldEmissions` array hides whether
`d1V18Template` was nil/empty or `finalizedD1V18Points` rejected a nonempty
template. [VERIFIED: recovered revision-18 symbols and durable 0/20 record]

**How to avoid:** record `cap_template_count` before strength finalization and
provider/reference cap/half counts after finalization. [VERIFIED: minimum
diagnostic contract]

### Moving a Gate to Make It Observable

**What goes wrong:** reordering safety or finalization changes the construction
being diagnosed. [VERIFIED: frozen gate-order requirement]

**How to avoid:** attach the first-failure enum to the existing frozen order and
return immediately at the same point; do not evaluate later gates for better
evidence. [CITED: 90-01-PLAN.md]

### Accidentally Invoking the Oracle Through Verification

**What goes wrong:** the current stop verifier executes the frozen test even
when used only to validate rollback. [VERIFIED: script inspection]

**How to avoid:** use it only with `--help`; use the new static verifier for all
preflight and rollback proof. [VERIFIED: diagnostic boundary]

### Persisting a Useful but Forbidden Margin

**What goes wrong:** per-point clearance or displacement values reveal geometry.
[CITED: SECURITY.md]

**How to avoid:** persist no margin unless the first failing gate is numerical;
then persist only the worst signed fixed-point aggregate and its scale tag.
[CITED: SECURITY.md; RELIABILITY.md]

### Treating Diagnosis as Repair Authorization

**What goes wrong:** an `implementation_defect` result is immediately patched,
or a pre-render pass triggers the oracle. [VERIFIED: scope boundary]

**How to avoid:** rollback and stop for all four outcomes. Any repair or oracle
attempt requires a new explicit plan/authorization. [VERIFIED: owner
authorization]

## Code Examples

### Sanitized Result Shape

```swift
// Source: implementation guidance derived from SECURITY.md and RELIABILITY.md.
enum D1V19Gate: String, CaseIterable, Sendable {
    case requestAdmission = "request_admission"
    case canonicalBranches = "canonical_branches"
    case slotsExtremaZones = "slots_extrema_zones"
    case residualsAndZeroOmission = "residuals_and_zero_omission"
    case rawExactLattice = "raw_exact_lattice"
    case sourceClearanceClip = "source_clearance_clip"
    case exactLinkageAndHalfAdmission = "exact_linkage_and_half_admission"
    case targetClearanceAndRadius = "target_clearance_and_radius"
    case ownerUnitSlackExpanded = "owner_unit_slack_expanded"
    case overlapTopology = "overlap_topology"
    case singleSafety = "single_safety"
    case adjacentLipschitzInverse = "adjacent_lipschitz_inverse"
    case branchChainProxy = "branch_chain_proxy"
    case strengthFinalization = "strength_finalization"
    case pointBudget = "point_budget"
    case none = "none"
}

struct D1V19Aggregate: Equatable, Sendable {
    let constructionInvocations: Int
    let firstFailure: D1V19Gate
    let canonicalBranchCounts: SIMD2<Int>
    let analyticalSlotCounts: SIMD2<Int>
    let retainedBranchCounts: SIMD2<Int>
    let capTemplateCount: Int
    let providerCapCount: Int
    let providerHalfCount: Int
    let firstFailureMargin: FixedPointMargin?
}
```

The actual result may retain its template in a package-internal request-local
field for the test reference calculation, but that field must never be printed,
serialized, logged, or copied into the ATTEMPT suffix. [CITED: SECURITY.md]

### Independent Classification

```swift
// Source: revision-19 outcome decision table in this research.
func classify(provider: Counts, reference: Counts, valid: Bool) -> Outcome {
    guard valid else { return .diagnosticInvalid }
    guard provider == reference else { return .implementationDefect }
    return provider.cap == 0 && provider.half == 0
        ? .genuineConstructionMiss
        : .priorStopNotReproduced
}
```

This function must live in test-only code, not in the provider. [VERIFIED:
independent classification requirement]

## State of the Art

| Prior Approach | Revision-19 Approach | Impact |
|---|---|---|
| Revision 18 observed only final `0/20` cap and half fields. [CITED: 90-01-ATTEMPT.md] | Count the shared template before finalization, retained branches, and provider/reference cap/half admissions. [VERIFIED: diagnostic design] | Distinguishes construction absence from finalizer behavior without rendering. [VERIFIED: diagnostic analysis] |
| Existing rollback verifier reruns the frozen RED oracle. [VERIFIED: script inspection] | New verifier is static and non-executing. [VERIFIED: diagnostic design] | Rollback proof no longer violates the no-oracle boundary. [VERIFIED: scope analysis] |
| Earlier retries persisted increasingly broad aggregate schemas. [CITED: 90-01-ATTEMPT.md] | Revision 19 persists only the minimum fixed enum/count/margin classification. [VERIFIED: owner-authorized instrumentation] | Reduces privacy and evidence-drift risk. [CITED: SECURITY.md] |

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|---|---|---|

All prescriptive claims are derived from repository contracts, the explicit
owner authorization, or the supplied read-only recovery findings; no training-
only assumption is used. [VERIFIED: source audit]

## Open Questions

None before planning. The four-outcome decision table deliberately converts
the unknown earliest gate into the diagnostic result rather than requiring a
pre-execution guess. [VERIFIED: research design]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|---|---|---|---|---|
| Swift/SwiftPM | diagnostic compile and narrow XCTest | yes | Swift 6.3.3 | none required [VERIFIED: local CLI] |
| Python 3 | static verifier | yes | 3.9.6 | none required [VERIFIED: local CLI] |
| Git | hash/status evidence | yes | 2.50.1 | byte/hash checks still work in Python, but final commit requires Git [VERIFIED: local CLI] |
| ripgrep | static boundary scan | yes | 15.1.0 | Python regex scan [VERIFIED: local CLI] |

No external service, database, container, package registry, model, fixture, or
device dependency exists. [VERIFIED: phase scope]

## Validation Architecture

### Test Framework

| Property | Value |
|---|---|
| Framework | XCTest through SwiftPM 6.0 package tools [VERIFIED: BeautySDK/Package.swift] |
| Config file | `BeautySDK/Package.swift` [VERIFIED: codebase] |
| Quick run command | `python3 scripts/verify-phase90-face01-diagnostic.py preflight ...` [VERIFIED: recommended Wave 0 contract] |
| Diagnostic command | `swift test --package-path BeautySDK --filter 'FaceContourSmoothRepairTests/testFACE01D1V19DiagnosticOnlyClassification'` [VERIFIED: recommended unique filter] |
| Rollback command | `python3 scripts/verify-phase90-face01-diagnostic.py rollback ...` [VERIFIED: recommended static contract] |
| Existing verifier allowance | `python3 scripts/verify-phase90-face01-stop.py --help` only [VERIFIED: script inspection] |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|---|---|---|---|---|
| FACE-01-DIAG-01 | One shared request-local reconstruction records the earliest frozen gate and minimum counts without rendering | focused unit diagnostic | unique D1-v19 XCTest filter above | no — Wave 0 [VERIFIED: repository scan] |
| FACE-01-DIAG-02 | Independent finalizer classifies exactly one of four outcomes | unit/differential | same unique D1-v19 XCTest filter | no — Wave 0 [VERIFIED: repository scan] |
| FACE-01-DIAG-03 | Source/test rollback, ten-heading prefix, optional eleventh suffix, oracle absence, and diff allowlist are static | Python self-test + live | new diagnostic verifier preflight/rollback modes | no — Wave 0 [VERIFIED: repository scan] |

### Required Static-Verifier Mutations

The new verifier self-test must reject at least: a second diagnostic-construction
call; a render/API/oracle token in the diagnostic test; mutable static/global
diagnostic state; logging/file/environment/network access; reordered or missing
gate enum cases; missing aggregate fields; raw coordinate-like suffix fields;
changed provider/test/oracle hashes after rollback; a modified ten-heading
prefix; two eleventh headings; wrong suffix field order; a present summary; and
an undeclared changed path. [VERIFIED: threat-driven validation design]

### Sampling Rate

- **Wave 0:** new static verifier self-test and `--help`; do not edit provider
  until it passes. [VERIFIED: safe sequencing]
- **After temporary diagnostic edits:** static preflight, then exactly one narrow
  D1-v19 XCTest invocation. [VERIFIED: no-oracle execution contract]
- **After classification:** restore temporary Swift files with `apply_patch`,
  run static rollback verification, then optionally append and verify the
  eleventh aggregate suffix. [VERIFIED: rollback contract]
- **Phase gate:** none; revision 19 cannot complete FACE-01 or Phase 90.
  [VERIFIED: diagnostic-only scope]

### Wave 0 Gaps

- [ ] `scripts/verify-phase90-face01-diagnostic.py` — static preflight/rollback verifier and mutation self-test. [VERIFIED: repository scan]
- [ ] `FaceContourSmoothRepairTests.testFACE01D1V19DiagnosticOnlyClassification` — one-call, no-render diagnostic. [VERIFIED: repository scan]
- [ ] Temporary package-internal request-local result/enum in `FaceShapeWarpProvider.swift`; remove byte-exact after the run. [VERIFIED: diagnostic design]
- [ ] Capture provider, complete repair-test, frozen oracle method, ATTEMPT prefix, later-artifact, PLANS, STATE, and verifier hashes immediately before execution. [VERIFIED: rollback design]

## Eleventh-Suffix Contract

If the diagnostic test starts, append at most one section after byte-exact
rollback and static verification. If preflight stops before Swift execution,
leave the ten-heading file byte-exact with no suffix. [VERIFIED: optional-suffix
contract]

Recommended heading:

```text
## 2026-09-01 FACE-01 D1-v19 diagnostic-only classification
```

Recommended exact fields, in order:

```text
diagnostic_contract
classification
first_failure
construction_invocation_count
canonical_branch_counts
analytical_slot_counts
retained_branch_counts
cap_template_count
provider_cap_admitted_count
provider_half_admitted_count
reference_cap_admitted_count
reference_half_admitted_count
first_failure_margin
render_invocation_count
oracle_invocation_count
rollback_status
static_verifier_status
```

`first_failure_margin` must be `not_needed` unless the first failing gate is
numerical; otherwise it contains exactly one signed integer plus one scale token
from `q16`, `q24`, or `q40`. [VERIFIED: minimum-evidence design]

The suffix must never claim FACE-01 GREEN, create `90-01-SUMMARY.md`, or unblock
Plans 90-03/04. [VERIFIED: phase dependency contract]

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | no | No identity/authentication seam exists in this diagnostic. [CITED: SECURITY.md] |
| V3 Session Management | no | All diagnostic state is one request-local value. [CITED: SECURITY.md; RELIABILITY.md] |
| V4 Access Control | yes, package boundary | Keep every diagnostic symbol package-internal/test-only and restore it after use. [CITED: ARCHITECTURE.md; AGENTS.md] |
| V5 Input Validation | yes | Fixed enum order, bounded counts, checked fixed-point margins, all-or-none field invariants, and fail-closed static parsing. [VERIFIED: diagnostic contract] |
| V6 Cryptography | no runtime crypto | SHA-256 protects evidence integrity only. [VERIFIED: verifier design] |

### Known Threat Patterns for the Diagnostic

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| Provider self-classifies its own bug | Spoofing | Independent test-side reference finalizer and decision table. [VERIFIED: diagnostic design] |
| Gate order changes during instrumentation | Tampering | Fixed `CaseIterable` order plus static/mutation checks. [VERIFIED: validation design] |
| Oracle is invoked through a helper/verifier | Elevation of Privilege | Unique test filter, banned render/oracle tokens, static verifier with no subprocess, old verifier `--help` only. [VERIFIED: script and scope analysis] |
| Geometry leaks in diagnostics | Information Disclosure | Fixed enum/count schema and at most one scaled aggregate margin. [CITED: SECURITY.md] |
| Global diagnostic state survives requests | Information Disclosure / Tampering | No mutable global/static state; one local result lifetime. [CITED: RELIABILITY.md] |
| Diagnostic turns into another retry | Tampering | Restore and stop for all outcomes; no construction/threshold/oracle change. [VERIFIED: owner authorization] |

## Sources

### Primary (HIGH confidence)

- `AGENTS.md`, `PLANS.md`, `.planning/STATE.md`, `.planning/ROADMAP.md`, and
  `.planning/REQUIREMENTS.md` — current project, milestone, ledger, and
  requirement boundaries. [VERIFIED: codebase read]
- Phase 90 `90-CONTEXT.md`, `90-01-REV18-RESEARCH.md`, `90-01-PLAN.md`,
  `90-01-ATTEMPT.md`, and `90-VALIDATION.md` — frozen revision-18 construction,
  gate order, stop evidence, and Nyquist state. [VERIFIED: codebase read]
- `FaceShapeWarpProvider.swift` and `FaceContourSmoothRepairTests.swift` —
  restored provider baseline and immutable frozen oracle location. [VERIFIED:
  codebase read]
- `scripts/verify-phase90-face01-stop.py` — proof that normal mode invokes the
  frozen RED test and is unsuitable for revision-19 rollback. [VERIFIED:
  codebase read]
- `SECURITY.md`, `RELIABILITY.md`, and `QUALITY_SCORE.md` — privacy, request-local
  state, aggregate evidence, SwiftPM, and nonclaim requirements. [VERIFIED:
  codebase read]
- Supplied read-only recovery audit — revision-18 bytes are not retained;
  recovered roles are `d1V18Template`, `finalizedD1V18Points`, and
  `d1FieldPassesSafety`; durable `0/20` cannot locate the first gate. [VERIFIED:
  task context]

### Secondary / Tertiary

None. This is a repository-specific diagnostic design and requires no external
library or current web claim. [VERIFIED: research scope]

## Metadata

**Confidence breakdown:**

- Diagnostic architecture: HIGH — derived from the recovered call roles,
  retained plan order, and one-result differential design. [VERIFIED: source
  synthesis]
- Privacy and rollback: HIGH — directly constrained by project owners and the
  inspected verifier behavior. [CITED: AGENTS.md; SECURITY.md; RELIABILITY.md]
- Earliest revision-18 failure: LOW — intentionally unknown until the bounded
  diagnostic runs. [VERIFIED: durable evidence limitation]

**Research date:** 2026-09-01
**Valid until:** any change to the FACE-01 provider, frozen oracle, revision-18
construction contract, or ten-heading ATTEMPT prefix
