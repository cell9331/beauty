# Phase 56: Independent Teeth Whitening Slice - Pattern Map

**Mapped:** 2026-08-03
**Files analyzed:** 12 planned new/modified artifacts
**Analogs found:** 12 / 12

## Scope Boundary

Phase 56 is an exact-absence decision slice, not a teeth implementation. The
immutable upstream authority is the closed `teeth_whitening` row in
`54-EVIDENCE-DECISIONS.json`. Production SDK and Demo files are primarily
read-only fixtures: the phase checker and focused tests prove that no public
field, CodingKey, Testing SPI, provider, transform, renderer case, preset,
resource, admission value, dependency, model, or active Demo mapping appeared.

No `56-RESEARCH.md` exists at mapping time. File classification therefore comes
from `56-CONTEXT.md`, the Phase 54/55 artifacts, current tests, and repository
owner documents. The local-retouch spike skill is background for why the gate is
closed; mechanics spikes and `p1.jpg` cannot substitute for Phase 54 eligibility.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `56-TEETH-CLOSED-GATE-EVIDENCE.md` | evidence record | batch projection/report | `55-COMPOSITION-EVIDENCE.md` plus `54-EVIDENCE-EVALUATION.md` | exact workflow, closed-decision specialization |
| `check_phase56_teeth_boundaries.py` | utility / policy gate | batch source/file scan + live mutations | `check_phase55_composition_boundaries.py` | exact live-fixture mutation pattern |
| `56-THREAT-INVENTORY.json` | config / security inventory | deterministic validation | `55-THREAT-INVENTORY.json` | exact |
| `56-VALIDATION.md` | validation config/evidence | batch verification map | `55-VALIDATION.md` | exact workflow |
| `BeautyParametersTests.swift` | test | serialization/reflection compatibility | existing Phase 53 tests in the same file | exact |
| `BeautyResourceCatalogTests.swift` | test | file-I/O / preset decoding | existing Phase 53 tests in the same file | exact |
| `BeautyRendererOutputRegressionTests.swift` | test | request-response / saved-output inventory | existing mouth/Phase 53 absence tests in the same file | exact |
| `BeautyEngineLocalRetouchFoundationTests.swift` | test | request-response lifecycle | existing no-admission facade tests in the same file | exact |
| `BeautyDemoViewStateTests.swift` | test | UI taxonomy/state transform | existing disabled-subcategory test plus `MeituEditorToolModels.swift` fixture | role/data-flow match |
| `PRODUCT_SENSE.md` / `QUALITY_SCORE.md` | product/quality ledgers | append-only record | Phase 55 closeout sections | exact owner pattern |
| `docs/meitu-function-blueprint/FEATURE_MATRIX.md` / `SHAPE_FEATURE_LEDGER.md` | taxonomy ledgers | deterministic status record | current mouth partial/future rows | exact in-place owner pattern |
| `PLANS.md` | project ledger | append-only record | Phase 55 planning/wave/closeout rows | exact owner pattern |

## Pattern Assignments

### `56-TEETH-CLOSED-GATE-EVIDENCE.md` (evidence record, batch report)

**Analogs:** `55-COMPOSITION-EVIDENCE.md` lines 1-17, 25-41, 48-81,
104-134; `54-EVIDENCE-DECISIONS.json` lines 3-16.

Copy the Phase 55 frontmatter and claim-boundary-first structure:

```markdown
---
phase: 56
status: validated
security_standard: OWASP ASVS Level 1
block_on: HIGH
requirements: [TEETH-01, TEETH-02, TEETH-03, TEETH-04, TEETH-05, TEETH-06]
---
```

Then record one deterministic projection of the Phase 54 row, not a competing
eligibility decision:

```json
{
  "feature": "teeth_whitening",
  "status": "closed",
  "reasons": ["missing_genuine_positive", "missing_genuine_negative"],
  "eligible_count": 0,
  "reviewed_count": 0,
  "accepted_count": 0,
  "rejected_count": 0,
  "naturalness_weight": 0
}
```

Use a TEETH-01..06 table. TEETH-01 takes the false branch (`teethWhitening`
absent); TEETH-02..05 must say exactly `not_applicable_closed_gate`; TEETH-06 is
`no_promotion` and must reconcile SDK, evidence, privacy, compatibility, Demo,
and both blueprint ledgers. Follow Phase 55's exact-command/result table for
focused suites, checker modes, full SwiftPM, explicit Simulator build/test,
schema/UI/diff checks, traceability, and HIGH dispositions.

Do not include a portrait path/hash, review session, grant payload, mask,
coordinates, pixels, output digest, human-review claim, containment metric, or
algorithm prose. Do not claim that TEETH-02..05 passed mechanically.

### `check_phase56_teeth_boundaries.py` (utility/policy gate, batch/live mutation)

**Primary analog:**
`55-original-pixel-composition-and-failure-isolation-core/check_phase55_composition_boundaries.py`
lines 118-180, 471-546, and 549-690.

Reuse fail-closed scanner classification:

```python
def classify_rg(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise ScannerFailure("unclassified scanner outcome")
```

Reuse the temporary live-fixture mutation architecture from lines 549-580:
copy only required SDK sources/tests, Demo source/tests, ledgers, Phase 54
decision JSON, and the Phase 56 threat inventory into a temporary root; switch
all checker paths through `configure_root`; mutate one anchored string; invoke
the same live checker; require the named rule ID; restore the fixture in
`finally`. This is stronger than synthetic string samples because it proves the
real parser/scanner path rejects each change.

The Phase 54 checker supplies the exact decision-ledger parser pattern at
`check_phase54_evidence_boundaries.py` lines 33-63 and 326-368: fixed feature
order, exact key order/sets, exact status/reasons, and exact zero-valued counts.
Phase 56 should select `teeth_whitening` by exact feature identity and validate
the entire upstream row; never use array position alone or accept extra reasons.

Required live rule families:

- upstream decision tampering: status, either missing reason, any nonzero count,
  naturalness weight, duplicate/missing teeth row, malformed/unreadable JSON;
- public/SPI absence: no stored field, initializer label, CodingKey, reflection
  member, JSON/default key, Testing SPI candidate name, or alias;
- production absence: resolver stays literal `.none`; admission remains zero;
  no provider/transform/render-plan/renderer/preset/resource/dependency/model;
- compatibility: exact 59 stored/CodingKey fields, five preset IDs and current
  hashes, exact 72 renderer IDs, unchanged facade/pixel-buffer/reset behavior;
- Demo: exact `unsupported("lips.teeth", title: "白牙", ...)` row, no
  `controlID`, binding, processor mapping, slider, or enabled availability;
- ledgers: `FEATURE_MATRIX.md` keeps `嘴唇` partial solely because `白牙` is
  future; `SHAPE_FEATURE_LEDGER.md` keeps the exact future row;
- privacy: Phase 56 artifacts expose fixed rule IDs/counts/status/reasons/totals
  only and contain no forbidden portrait/review/mechanics payload;
- scanner/missing-file/unclassified failures always fail closed.

Use exact parsing and anchored source snippets, not a repository-wide ban on the
string `白牙`: the disabled taxonomy and future ledgers legitimately contain it.
Similarly, candidate-name scans must distinguish allowed test assertions and
documentation from forbidden production declarations.

Self-test output should be a stable aggregate JSON object such as
`highThreatIds`, `mutationCaseCount`, and `status`; failures should expose only
fixed rule IDs. Catch I/O, parse, scanner, key/type, and assertion failures at
`main` and emit one unclassified rule rather than raw paths/errors.

### `56-THREAT-INVENTORY.json` (security inventory, deterministic config)

**Analog:** `55-THREAT-INVENTORY.json` lines 1-56 and checker
`expected_inventory()` lines 137-165.

Copy exact whole-document equality, ordered threat IDs, `OWASP ASVS Level 1`,
`block_on: HIGH`, fixed STRIDE categories, `severity: HIGH`, and
`disposition: mitigate`. Suggested Phase 56 groupings are evidence-authority
tampering, premature production/API activation, aliasing to shipped effects,
privacy disclosure, Demo activation, ledger promotion drift, and compatibility/
scanner failure. Every gate string must have an executable checker or test owner;
do not validate by count alone.

### `56-VALIDATION.md` (validation strategy, batch verification)

**Analog:** `55-VALIDATION.md` lines 1-55 and 57-104.

Retain the frontmatter, quick/focused/final-only command table, one validation
row per actual XML task ID, Wave 0 exact-absence tests/checker before owner-doc
promotion, and final-only full SwiftPM/Demo/schema/UI/traceability/owner sync.
Replace byte-oracle language with closed-gate/absence inventories. The sampling
contract must explicitly say there is no planned production RED or GREEN source
implementation: only test/checker artifact construction and ledger closeout.

Map TEETH-01..06 precisely. A later successful full suite cannot convert an
earlier unrun task to passed. Require actual command/results per row and exact
decision/threat coverage, not inferred totals.

### `BeautyParametersTests.swift` (test, serialization/reflection)

**Analog:** same file lines 1183-1237.

```swift
let stored = Mirror(reflecting: BeautyParameters()).children.compactMap(\.label)
// parse CodingKeys from the real source
XCTAssertEqual(stored.count, 59)
XCTAssertEqual(coding, stored)
XCTAssertEqual(encoded.count, 59)
XCTAssertEqual(Set(encoded.keys), Set(stored))
```

Extend or phase-name the existing absence assertion without duplicating the
whole compatibility suite. Pin `teethWhitening` and aliases independently from
the sibling candidates, including initializer labels/source defaults/Testing
SPI where appropriate. Preserve the legacy source-construction assertion at
lines 1204-1218. Never add a zero-valued field to make the test pass.

### `BeautyResourceCatalogTests.swift` (test, preset file-I/O)

**Analog:** same file lines 220-250.

```swift
XCTAssertEqual(presets.map(\.id),
    ["natural", "clear", "refined", "male-natural", "id-photo-natural"])
XCTAssertEqual(presets.count, 5)
for preset in presets {
    XCTAssertEqual(Mirror(reflecting: preset.parameters).children.count, 59)
    XCTAssertNil(object["teethWhitening"])
}
```

Keep the five source SHA-256 hashes at lines 235-241 exact. Add no Phase 56
preset/resource. Guard aliases without treating ordinary `skinWhitening` as a
teeth implementation.

### `BeautyRendererOutputRegressionTests.swift` (test, renderer inventory)

**Analog:** same file lines 470-504 and 971-979.

```swift
let caseIDs = rendererCaseIDs(in: source)
for alias in ["mouthCombo", "mLip", "teethWhitening", "teethWhite"] {
    XCTAssertFalse(caseIDs.contains { $0 == alias || $0.hasPrefix("\(alias)_") })
    XCTAssertFalse(containsInitializerLabel(alias, in: source))
}
XCTAssertEqual(rendererCaseIDs(in: source), Self.expectedRendererCaseIDs)
XCTAssertEqual(Self.expectedRendererCaseIDs.count, 72)
```

Preserve the shipped mouth/lip cases and exact output behavior. Phase 56 must not
add a saved-output case, helper, gallery file, or disguise teeth work as
`lipColor`, `skinWhitening`, brightness, or a geometry case.

### `BeautyEngineLocalRetouchFoundationTests.swift` (test, facade lifecycle)

**Analog:** existing Phase 53/55 no-admission tests in the same file; production
fixtures are `BeautyEffectResolver.swift` lines 67-74 and
`BeautyLocalRetouchAdmission.swift` lines 1-17.

The production contract to copy into assertions is literal:

```swift
package static func localRetouchAdmission(
    parameters: BeautyParameters
) -> BeautyLocalRetouchAdmission {
    _ = parameters
    return .none
}
```

Assert both public CIImage entries retain no-admission dimensions/bytes,
warnings, metrics, and detection summary; unrelated shipped effects still work;
pixel-buffer/reset perform zero local-retouch work. Keep Phase 55 opaque Testing
composition scenarios feature-neutral. Do not add a teeth-labelled scenario or
expose a digest/source identity.

### `BeautyDemoViewStateTests.swift` (test, disabled taxonomy)

**Production fixture:** `MeituEditorToolModels.swift` lines 117-130.

```swift
unsupported("lips.teeth", title: "白牙", icon: "sparkles")
```

Copy the disabled-state pattern from `BeautyDemoViewStateTests.swift` lines
543-566: exact order, disabled availability, fixed future copy, empty controls
and disabledControls, and no reset interaction. Add a targeted editor-tool
taxonomy assertion for exact ID/title/unsupported state and nil control mapping
if current coverage does not already prove it. Do not change the shipped row,
badge/copy, slider, store, processor, or availability merely to create coverage.

Pitfall: the existing `FacialFeatureSubcategory.teeth` disabled row is adjacent
but not the same object as the editor taxonomy item `lips.teeth`; Phase 56 should
guard both without claiming either is an active SDK route.

### Product and blueprint owner ledgers

**Exact in-place analogs:**

- `PRODUCT_SENSE.md` lines 464-471: `白牙` future and `嘴唇` partial/nonclaims.
- `QUALITY_SCORE.md` line 289 and 526: mouth score does not gain unsupported
  capability credit.
- `FEATURE_MATRIX.md` line 26: branch partial solely because `白牙` is future.
- `SHAPE_FEATURE_LEDGER.md` line 106: `| 嘴唇 | 白牙 | future | None. | ... |`.
- `PLANS.md` lines 36-47: discussion → planning → wave evidence → final closeout
  progression with exact commands/counts and nonclaims.

Append a Phase 56 acceptance/score/plan closeout only after executable gates are
green. Do not rewrite the existing taxonomy rows into a new Phase 56 authority;
their unchanged future/partial values are the evidence. `SECURITY.md` and
`RELIABILITY.md` should change only if the final plan adds an enduring boundary
beyond their existing Phase 54 evidence and Phase 55 composition contracts.
`ARCHITECTURE.md`, `DESIGN.md`, and `FRONTEND.md` are read-only unless planning
identifies a genuinely new invariant; exact absence normally adds none.

## Shared Patterns

### Closed Decision Authority

**Source:** `54-EVIDENCE-DECISIONS.json` lines 3-16.

Apply one exact, immutable teeth-row parse to evidence, checker, validation, and
owner synchronization. No current file selection or human review is allowed.

### Exact Compatibility and Admission

**Sources:** `BeautyParametersTests.swift` lines 1183-1237;
`BeautyResourceCatalogTests.swift` lines 220-250;
`BeautyRendererOutputRegressionTests.swift` lines 971-979;
`BeautyEffectResolver.swift` lines 67-74.

The invariant is `59 / 5 / 72 / .none`, plus unchanged no-admission facade
behavior. All equality checks should use exact inventories, not lower bounds.

### Fail-Closed Mutation Testing

**Source:** Phase 55 checker lines 549-639.

Mutate temporary copies of actual fixtures, require a specific stable failure
rule, restore in `finally`, and classify scanner errors as failures. Include
missing-anchor mutations so benign source refactors cannot silently disable the
checker.

### Privacy-Safe Evidence

**Sources:** Phase 54 checker forbidden-export model lines 82-145 and Phase 55
evidence lines 119-134.

Only fixed IDs, allowlisted status/reasons, counts, and compatibility totals may
be durable. No media, review, mechanics, path, hash, geometry, raw error, or
stable output identity belongs in Phase 56 artifacts.

## Read-Only / No-Change Boundaries

| Boundary | Required Phase 56 posture |
|---|---|
| `BeautyParameters.swift` and public API | no change; no inert field/key/default/SPI |
| providers, transforms, renderer plan/source | no change; no anatomy case or alias |
| preset/resource directories and `Package.swift` | no change; exact five presets, no dependency/target/model/resource |
| `BeautyEffectResolver.swift` / `BeautyLocalRetouchAdmission.swift` | no change; literal `.none`, opaque count zero |
| `BeautyEngine.swift` and Phase 55 composer | no production change; existing feature-neutral Testing mechanics may remain |
| `MeituEditorToolModels.swift` and Demo state/processor | no behavior change; exact disabled `白牙` item remains |
| Phase 54 evidence/reviewer artifacts | immutable input; do not regenerate or edit |
| portrait/review/generated media | do not select, create, track, hash into Phase 56, or inspect as product evidence |
| spike skill/source | read-only background; mechanics have zero promotion weight |

## Pitfalls to Block Explicitly

- Treating `p1.jpg` containment/over-whitening usefulness as a genuine positive
  or complete negative bundle.
- Marking TEETH-02..05 implemented, passed, waived, or mechanically validated;
  their Phase 56 status is `not_applicable_closed_gate`.
- Adding a neutral zero field, dormant provider, empty renderer branch, preset
  key, or admission enum case “for later.” Exact absence forbids API debris.
- Aliasing teeth to `skinWhitening`, brightness, `lipColor`, mouth geometry, or
  opaque Phase 55 mechanics.
- Broad substring checks that reject the legitimate disabled Chinese taxonomy or
  documentation assertions, or that miss alternate identifiers such as
  `teethWhite`.
- Checking only aggregate counts while allowing coordinated inventory swaps.
- Letting a missing `rg`, unreadable file, parse failure, or missing mutation
  anchor report clean.
- Promoting `嘴唇` from partial, changing `白牙` from future, enabling either Demo
  taxonomy surface, or borrowing evidence from sclera/eyelid siblings.
- Updating root architectural/design/frontend contracts when the phase adds no
  enduring runtime behavior.

## No Analog Found

None. The closed-gate evidence is a specialized projection, but Phase 54 owns
the exact decision shape and Phase 55 owns the evidence/checker/validation
workflow. No new production-role analog is needed because production creation is
out of scope.

## Metadata

**Analog search scope:** `.planning/phases/54-*`, `.planning/phases/55-*`,
`BeautySDK/Sources`, `BeautySDK/Tests`, `BeautyDemo/BeautyDemo`,
`BeautyDemo/BeautyDemoTests`, root contract ledgers, and
`docs/meitu-function-blueprint`.

**Strong analogs read:** Phase 54 decision ledger/checker/pattern map; Phase 55
checker, validation, threat inventory, and composition evidence; current
parameter/resource/renderer/admission/resolver/Demo tests and source; product and
blueprint ledgers.

**Pattern extraction date:** 2026-08-03
